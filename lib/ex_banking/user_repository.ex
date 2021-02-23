defmodule ExBanking.UserRepository do
  alias ExBanking.User.Money
  alias ExBanking.User.Protocol.{Deposit, GetBalance, Send, Withdraw}

  @database Vault

  def apply(%GetBalance{user: user, currency: currency}) do
    balance =
      user
      |> get_balance(currency)
      |> Money.to_float
    {:ok, balance}
  end
  def apply(%Deposit{user: user, amount: amount, currency: currency}) do
    amount = Money.to_integer(amount)
    balance = :ets.update_counter(
      @database, {user, currency}, amount, {{user, currency}, 0})
    {:ok, Money.to_float(balance)}
  end
  def apply(%Send{} = event) do
    %Send{
      from_user: from_user,
      to_user: to_user,
      amount: amount,
      currency: currency,
    } = event

    withdraw = %Withdraw{user: from_user, amount: amount, currency: currency}

    with {:ok, from_user_balance} <- apply(withdraw),
         {:ok, to_user_balance} <-
           ExBanking.deposit(to_user, amount, currency) do
      {:ok, from_user_balance, to_user_balance}
    else
      error -> override_error(error)
    end
  end
  def apply(%Withdraw{user: user, amount: amount, currency: currency}) do
    balance = get_balance(user, currency)
    amount = Money.to_integer(amount)
    if balance >= amount do
      balance = :ets.update_counter(
        @database, {user, currency}, -amount, {{user, currency}, 0})
      {:ok, Money.to_float(balance)}
    else
      {:error, :not_enough_money}
    end
  end

  defp get_balance(user, currency) do
    @database
    |> :ets.lookup({user, currency})
    |> case do
      [] -> 0
      [{_, balance}] -> balance
    end
  end

  defp override_error({:error, :too_many_requests_to_user}) do
    {:error, :too_many_requests_to_receiver}
  end
  defp override_error(error), do: error
end
