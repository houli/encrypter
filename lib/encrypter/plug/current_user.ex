defmodule Encrypter.Plug.CurrentUser do
  import Plug.Conn

  def init(params), do: params

  def call(conn, _params) do
    case get_session(conn, :current_user) do
      nil ->
        assign(conn, :current_user, nil)
      id ->
        assign(conn, :current_user, Encrypter.Repo.get(Encrypter.User, id))
    end
  end
end
