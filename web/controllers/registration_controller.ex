defmodule Encrypter.RegistrationController do
  use Encrypter.Web, :controller

  alias Encrypter.Password

  plug Encrypter.Plug.Authenticate
  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)
    if changeset.valid? do
      new_user = Password.generate_password(changeset)
      case Encrypter.Repo.insert new_user do
        {:ok, new_user} ->
          conn
          |> put_flash(:info, "Successfully registered and logged in")
          |> put_session(:current_user, new_user)
          |> redirect(to: page_path(conn, :index))
        {:error, changeset} ->
          render conn, "new.html", changeset: changeset
      end
    else
      render conn, "new.html", changeset: changeset
    end
  end
end
