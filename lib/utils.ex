defmodule ExBanking.Utils do
  alias ExBanking.User.DynamicSupervisor

  def generate_registry_name(user), do: {:via, Registry, {Users, user}}

  def validate_params(params) when is_list(params) do
    Enum.reduce_while(params, :valid, fn param, acc ->
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
      not DynamicSupervisor.lookup_user?(user) -> {:error, :user_does_not_exist}
      true -> :valid
    end
  end
  defp validate_param({:currency, currency})
       when is_binary(currency), do: :valid
  defp validate_param(_param), do: {:error, :wrong_arguments}
end
