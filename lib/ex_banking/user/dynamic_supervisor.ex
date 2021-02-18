defmodule ExBanking.User.DynamicSupervisor do
  use DynamicSupervisor

  alias ExBanking.User
  alias ExBanking.User.{Consumer, Producer}

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def create_user(user) do
    {:ok, _} = start_child(%{id: Consumer, start: {Consumer, :start_link, [user]}})
    start_child(%{id: Producer, start: {Producer, :start_link, [user]}})
  end

  defp start_child(child_spec) do
    DynamicSupervisor.start_child(User.DynamicSupervisor, child_spec)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
