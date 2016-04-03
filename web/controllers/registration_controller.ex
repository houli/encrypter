defmodule Encrypter.RegistrationController do
  use Encrypter.Web, :controller

  alias Encrypter.Password

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params, current_user) do
    if current_user do
      conn |> redirect(to: folder_path(conn, :index))
    else
      changeset = User.changeset(%User{})
      render conn, changeset: changeset
    end
  end

  def create(conn, %{"user" => user_params}, _current_user) do
    changeset = User.changeset(%User{}, user_params)
    if changeset.valid? do
      new_user = Password.generate_password(changeset)
      case Repo.insert new_user do
        {:ok, new_user} ->
          conn
          |> put_flash(:info, "Successfully registered and logged in.")
          |> put_session(:current_user, new_user.id)
          |> redirect(to: folder_path(conn, :index))
        {:error, changeset} ->
          render conn, "new.html", changeset: changeset
      end
    else
      render conn, "new.html", changeset: changeset
    end
  end
end
