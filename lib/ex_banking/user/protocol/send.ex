defmodule ExBanking.User.Protocol.Send do
  @type t :: %__MODULE__{
    from_user: String.t,
    to_user: String.t,
    amount: number,
    currency: String.t,
  }

  defstruct [:from_user, :to_user, :amount, :currency]
end
