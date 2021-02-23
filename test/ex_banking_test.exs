defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  test "Creates a new user" do
    assert :ok = ExBanking.create_user("create_user")
  end

  test "Deposit user balance" do
    ExBanking.create_user("deposit")
    assert {:ok, 0.00} = ExBanking.deposit("deposit", 0, "rub")
    assert {:ok, 0.00} = ExBanking.deposit("deposit", 0.00, "rub")
    assert {:ok, 10.00} = ExBanking.deposit("deposit", 10, "rub")
    assert {:ok, 21.21} = ExBanking.deposit("deposit", 11.21, "rub")
    assert {:ok, 11.21} = ExBanking.deposit("deposit", 11.21, "dollar")
  end

  test "Withdraw user balance" do
    ExBanking.create_user("withdraw")
    assert {:ok, 0.00} = ExBanking.withdraw("withdraw", 0.00, "rub")
    assert {:ok, 100.00} = ExBanking.deposit("withdraw", 100, "rub")
    assert {:ok, 100.00} = ExBanking.withdraw("withdraw", 0.00, "rub")
    assert {:ok, 90.00} = ExBanking.withdraw("withdraw", 10, "rub")
    assert {:ok, 78.79} = ExBanking.withdraw("withdraw", 11.21, "rub")
    assert {:ok, 67.00} = ExBanking.withdraw("withdraw", 11.799, "rub")
  end

  test "Get user balance" do
    ExBanking.create_user("get_balance")
    assert {:ok, 0.00} = ExBanking.get_balance("get_balance", "rub")
  end

  test "Send amount from sender balance to receiver balance" do
    ExBanking.create_user("sender_balance")
    ExBanking.create_user("receiver_balance")
    ExBanking.deposit("sender_balance", 100, "rub")
    assert {:ok, 77.89, 22.11} =
      ExBanking.send("sender_balance", "receiver_balance", 22.11, "rub")
  end

  test "Wrong arguments" do
    ExBanking.create_user("wrong_arguments")
    assert {:error, :wrong_arguments} =
      ExBanking.get_balance(:not_string, "rub")
    assert {:error, :wrong_arguments} =
      ExBanking.get_balance("wrong_arguments", :not_string)
    assert {:error, :wrong_arguments} =
      ExBanking.deposit("wrong_arguments", :not_number, "rub")
    assert {:error, :wrong_arguments} =
      ExBanking.deposit("wrong_arguments", -1, "rub")
  end

  test "User does not exist" do
    assert {:error, :user_does_not_exist} =
      ExBanking.get_balance("user_does_not_exist", "rub")
  end

  test "User already exist" do
    ExBanking.create_user("user_already_exists")
    assert {:error, :user_already_exists} =
      ExBanking.create_user("user_already_exists")
  end

  test "Not enough money" do
    ExBanking.create_user("not_enough_money_sender")
    ExBanking.create_user("not_enough_money_receiver")
    assert {:error, :not_enough_money} =
      ExBanking.withdraw("not_enough_money_sender", 11.21, "rub")
    assert {:error, :not_enough_money} = ExBanking.send(
      "not_enough_money_sender", "not_enough_money_receiver", 11.21, "rub")
  end

  test "Sender does not exist" do
    ExBanking.create_user("receiver_exist")
    assert {:error, :sender_does_not_exist} =
      ExBanking.send("sender_does_not_exist", "receiver_exist", 10, "rub")
  end

  test "Receiver does not exist" do
    ExBanking.create_user("sender_exist")
    assert {:error, :receiver_does_not_exist} =
      ExBanking.send("sender_exist", "receiver_does_not_exist", 10, "rub")
  end

# Not stable
#  test "Simulate too many requests to user" do
#    ExBanking.create_user("too_many_requests_to_user")
#    result =
#      1..20
#      |> Enum.map(fn _ ->
#        Task.async(fn ->
#          ExBanking.get_balance("too_many_requests_to_user", "rub")
#        end)
#      end)
#      |> Enum.map(&Task.await/1)
#
#    assert 10 = Enum.count(result, fn {res, _} -> res == :ok end)
#    assert 10 = Enum.count(result, fn res ->
#      res == {:error, :too_many_requests_to_user}
#    end)
#  end

# Not stable
#  test "Simulate too many requests to sender" do
#    ExBanking.create_user("too_many_requests_to_sender")
#    ExBanking.create_user("receiver")
#    result =
#      1..20
#      |> Enum.map(fn _ ->
#        Task.async(fn ->
#          ExBanking.send("too_many_requests_to_sender", "receiver", 0, "rub")
#        end)
#      end)
#      |> Enum.map(&Task.await/1)
#
#    assert 10 = Enum.count(result, fn {_, _, _} -> true; _ -> false end)
#    assert 10 = Enum.count(result, fn
#      res -> res == {:error, :too_many_requests_to_sender}
#    end)
#  end

# Not stable
#  test "Simulate too many requests to receiver" do
#    ExBanking.create_user("sender")
#    ExBanking.create_user("too_many_requests_to_receiver")
#
#    get_balance_tasks =
#      1..10
#      |> Enum.map(fn _ ->
#        Task.async(fn ->
#          ExBanking.get_balance("too_many_requests_to_receiver", "rub")
#        end)
#      end)
#
#    send_tasks =
#      1..10
#      |> Enum.map(fn _ ->
#        Task.async(fn ->
#          ExBanking.send("sender", "too_many_requests_to_receiver", 0, "rub")
#        end)
#      end)
#
#    result =
#      get_balance_tasks
#      |> Enum.concat(send_tasks)
#      |> Enum.map(&Task.await/1)
#
#    assert 10 = Enum.count(result, fn
#      res -> res == {:error, :too_many_requests_to_receiver}
#    end)
#  end
end
