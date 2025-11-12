defmodule Cabinet.Auth.Guards do
  alias Cabinet.Auth.Scope
  alias Cabinet.Auth.User

  def is_superuser?(%Scope{user: user}), do: is_superuser?(user)
  def is_superuser?(%User{superuser: true}), do: true
  def is_superuser?(_), do: false

  defguard is_superuser(user) when is_struct(user, User) and user.superuser == true
end
