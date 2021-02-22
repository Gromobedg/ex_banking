defmodule ExBanking do
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
    _params = [user: user, amount: amount, currency: currency]
    :world
  end

  @spec withdraw(
    user :: String.t,
    amount :: number,
    currency :: String.t
  ) :: {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency) do
    _params = [user: user, amount: amount, currency: currency]
    :world
  end

  @spec get_balance(
    user :: String.t,
    currency :: String.t
  ) :: {:ok, balance :: number} | banking_error
  def get_balance(user, currency) do
    params = [user: user, currency: currency]
    ExBanking.User.Producer.call(user, {:get_balance, params})
  end

  @spec send(
    from_user :: String.t,
    to_user :: String.t,
    amount :: number,
    currency :: String.t
  ) :: send_success_resp | banking_error
  def send(from_user, to_user, amount, currency) do
    _params = [
      from_user: from_user, to_user: to_user, amount: amount,
      currency: currency,
    ]
    :world
  end
end
