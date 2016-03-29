defmodule Encrypter.Plug.Authenticate do
  import Plug.Conn
  import Encrypter.Router.Helpers
  import Phoenix.Controller

  def init(params), do: params

  def call(conn, _params) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You need to be logged in to view this page.")
      |> redirect(to: session_path(conn, :new))
      |> halt
    end
  end
end
