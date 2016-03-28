defmodule Encrypter.PageController do
  use Encrypter.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
