defmodule ExBanking.Application do
  use Application

  alias ExBanking.User

  def start(_type, _args) do
    :ets.new(Vault, [
      :set, :public, :named_table, {:read_concurrency, true},
      {:write_concurrency, true},
    ])

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: User.DynamicSupervisor},
      {Registry, keys: :unique, name: Users}
    ]

    opts = [strategy: :one_for_one, name: ExBanking.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
