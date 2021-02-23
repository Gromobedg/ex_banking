defmodule ExBanking.User.Protocol.Deposit do
  @type t :: %__MODULE__{
    user: String.t,
    amount: number,
    currency: String.t,
  }

  defstruct [:user, :amount, :currency]
end
