defmodule ExBanking.User.Money do
  def to_integer(number), do: number |> Kernel.*(100) |> Kernel.trunc

  def to_float(0), do: 0.00
  def to_float(number), do: number / 100
end
