defmodule ExBanking do
  alias ExBanking.User.Protocol.{Deposit, GetBalance, Send, Withdraw}

  @type banking_error :: {
    :error,
    :wrong_arguments                |
    :user_already_exists            |
    :user_does_not_exist            |
    :not_enough_money               |
    :sender_does_not_exist          |
    :receiver_does_not_exist        |
    :too_many_requests_to_user      |
    :too_many_requests_to_sender    |
    :too_many_requests_to_receiver
  }
  @type send_success_resp :: {
    :ok,
    from_user_balance :: number,
    to_user_balance :: number,
  }

  @spec create_user(user :: String.t) :: :ok | banking_error
  def create_user(user) when is_binary(user) do
    ExBanking.User.DynamicSupervisor.create_user(user)
  end
  def create_user(_user), do: {:error, :wrong_arguments}

  @spec deposit(
    user :: String.t,
    amount :: number,
    currency :: String.t
  ) :: {:ok, new_balance :: number} | banking_error
  def deposit(user, amount, currency) do
    event = %Deposit{user: user, amount: amount, currency: currency}
    ExBanking.User.Producer.call(user, event)
  end

  @spec withdraw(
    user :: String.t,
    amount :: number,
    currency :: String.t
  ) :: {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency) do
    event = %Withdraw{user: user, amount: amount, currency: currency}
    ExBanking.User.Producer.call(user, event)
  end

  @spec get_balance(
    user :: String.t,
    currency :: String.t
  ) :: {:ok, balance :: number} | banking_error
  def get_balance(user, currency) do
    event = %GetBalance{user: user, currency: currency}
    ExBanking.User.Producer.call(user, event)
  end

  @spec send(
    from_user :: String.t,
    to_user :: String.t,
    amount :: number,
    currency :: String.t
  ) :: send_success_resp | banking_error
  def send(from_user, to_user, amount, currency) do
    event = %Send{
      from_user: from_user,
      to_user: to_user,
      amount: amount,
      currency: currency,
    }
    from_user
    |> ExBanking.User.Producer.call(event)
    |> override_error
  end

  defp override_error({:error, :too_many_requests_to_user}) do
    {:error, :too_many_requests_to_sender}
  end
  defp override_error(error), do: error
end
