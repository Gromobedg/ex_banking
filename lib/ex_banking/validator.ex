defmodule ExBanking.Validator do
  alias ExBanking.User.DynamicSupervisor

  def validate_event(event) when is_map(event) do
    event
    |> Map.from_struct
    |> Enum.reduce_while(:valid, fn param, acc ->
      case validate_param(param) do
        {:error, _type_error} = error -> {:halt, error}
        _valid -> {:cont, acc}
      end
    end)
  end

  defp validate_param({user_type, user})
       when user_type in [:user, :from_user, :to_user] do
    cond do
      not is_binary(user) -> {:error, :wrong_arguments}
      not DynamicSupervisor.lookup_user?(user) ->
        case user_type do
          :user -> {:error, :user_does_not_exist}
          :from_user -> {:error, :sender_does_not_exist}
          :to_user -> {:error, :receiver_does_not_exist}
        end
      true -> :valid
    end
  end
  defp validate_param({:currency, currency})
       when is_binary(currency), do: :valid
  defp validate_param({:amount, amount})
       when is_number(amount) and amount >= 0, do: :valid
  defp validate_param(_param), do: {:error, :wrong_arguments}
end
