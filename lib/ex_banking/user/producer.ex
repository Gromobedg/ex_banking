defmodule ExBanking.User.Producer do
  use GenStage

  alias ExBanking.Utils

  def start_link(user) do
    GenStage.start_link(__MODULE__, 0, name: Utils.generate_registry_name(user))
  end

  def call(user, {_event_type, params} = event) do
    case Utils.validate_params(params) do
      :valid -> GenStage.call(Utils.generate_registry_name(user), event)
      error -> error
    end
  end

  def init(counter), do: {:producer, {:queue.new(), counter}}

  def handle_call(event, from, {queue, pending_demand})
      when pending_demand > 0 do
    dispatch_events(:queue.in({from, event}, queue), pending_demand, [])
  end
  def handle_call(_event, _from, {queue, pending_demand}) do
    {:reply, {:error, :too_many_requests_to_user}, [], {queue, pending_demand}}
  end

  def handle_demand(incoming_demand, {queue, pending_demand}) do
    dispatch_events(queue, incoming_demand + pending_demand, [])
  end

  defp dispatch_events(queue, demand, events) do
    with d when d > 0 <- demand,
         {{:value, event}, queue} <- :queue.out(queue) do
      dispatch_events(queue, demand - 1, [event | events])
    else
      _ -> {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end

end
