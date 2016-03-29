defmodule Encrypter.Plug.CurrentUser do
  import Plug.Conn

  def init(params), do: params

  def call(conn, _params) do
    assign(conn, :current_user, get_session(conn, :current_user))
  end
end
