# ExBanking
## About implementation

I want to note that in this implementation, `handle_demand` is redundant. It is required when implementing `gen_stage`, but due to check `pending_demand > 0` will receive an empty queue. 

```elixir
producer.ex

def handle_call(event, from, {queue, pending_demand}) when pending_demand > 0 do
  dispatch_events(:queue.in({from, event}, queue), pending_demand, [])
end
def handle_call(_event, _from, {queue, pending_demand}) do
  {:reply, {:error, :too_many_requests_to_user}, [], {queue, pending_demand}}
end
```

With such a check, we will never exceed `max_demand`, which means we will not put the data in the queue for `handle_demand`.

Now the maximum queue for this implementation is 10. It can be expanded to 1000 then you need to change the implementation.

## Why gen_stage?
1. I just wanted to try it (practice is the best teacher).
2. Simplifies the implementation process (The most difficult part of code if you do without `gen_stage` is to monitor size of queue and subscribe to new events. With `gen_stage` it is very easy to monitor with `GenStage.sync_subscribe` and check queue size with `pending_demand`). 

## Code style
Limiting line 80 characters.
