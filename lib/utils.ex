defmodule ExBanking.Utils do
  def generate_registry_name(user), do: {:via, Registry, {Users, user}}
end
