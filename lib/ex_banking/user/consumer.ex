defmodule ExBanking.User.Consumer do
  use GenStage

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter)
  end

  def init(_state) do
    {:consumer, :ok}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      IO.inspect({self(), event, state})
    end

    {:noreply, [], state}
  end
end
