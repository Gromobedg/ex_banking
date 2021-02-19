defmodule ExBanking.User.Producer do
  use GenStage

  alias ExBanking.Utils

  def start_link(user) do
    GenStage.start_link(__MODULE__, 0, name: Utils.generate_registry_name(user))
  end

  def init(counter), do: {:producer, {:queue.new(), counter}}

  def handle_call(event, from, {queue, pending_demand}) do
    queue = :queue.in({from, event}, queue)
    dispatch_events(queue, pending_demand, [])
  end

  def handle_demand(incoming_demand, {queue, pending_demand}) do
    demand = incoming_demand + pending_demand
    with {item, queue} <- :queue.out(queue),
         {:value, event} <- item do
      {:noreply, [event], {queue, demand - 1}}
    else
      _ -> {:noreply, [], {queue, demand}}
    end
  end
end
