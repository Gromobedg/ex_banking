defmodule ExBanking.User.Consumer do
  use GenStage

  alias ExBanking.{UserRepository, Format}

  @min_demand 1
  @max_demand 10

  def start_link(user) do
    consumer_name = Format.registry_name(user <> "_consumer")
    producer_name = Format.registry_name(user)
    {:ok, consumer} = GenStage.start_link(__MODULE__, [], name: consumer_name)
    sync_subscribe_opts = [
      to: producer_name, min_demand: @min_demand, max_demand: @max_demand,
    ]
    GenStage.sync_subscribe(consumer, sync_subscribe_opts)
  end

  def init(_args), do: {:consumer, :ok}

  def handle_events(events, _from, state) do
    for {from, event} <- events do
      result = UserRepository.apply(event)
      GenStage.reply(from, result)
    end

    {:noreply, [], state}
  end
end
