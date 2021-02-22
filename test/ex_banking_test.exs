defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  test "Creates a new user" do
    assert :ok = ExBanking.create_user("create_user")
  end

  test "Get user balance" do
    ExBanking.create_user("get_balance")
    assert {:ok, 0} = ExBanking.get_balance("get_balance", "rub")
  end

  test "Simulate too many requests to user" do
    ExBanking.create_user("too_many_requests_to_user")
    result =
      1..30
      |> Enum.map(fn _ ->
        Task.async(fn ->
          ExBanking.get_balance("too_many_requests_to_user", "rub")
        end)
      end)
      |> Enum.map(&Task.await/1)

    assert 10 = result |> Enum.count(fn {res, _} -> res == :ok end)
    assert 20 = result |> Enum.count(fn {res, _} -> res == :error end)
  end
end
