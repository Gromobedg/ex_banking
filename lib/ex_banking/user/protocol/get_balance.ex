defmodule ExBanking.User.Protocol.GetBalance do
  @type t :: %__MODULE__{
    user: String.t,
    currency: String.t,
  }

  defstruct [:user, :currency]
end
