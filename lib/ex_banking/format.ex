defmodule ExBanking.Format do
  def registry_name(user), do: {:via, Registry, {Users, user}}
end
