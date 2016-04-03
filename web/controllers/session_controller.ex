defmodule Encrypter.SessionController do
  use Encrypter.Web, :controller

  plug :scrub_params, "user" when action in [:create]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  def new(conn, _params, current_user) do
    if current_user do
      conn |> redirect(to: folder_path(conn, :index))
    else
      render conn, changeset: User.changeset(%User{})
    end
  end

  def create(conn, %{"user" => user_params}, _current_user) do
    user = if is_nil(user_params["username"]) do
      nil
    else
      Repo.get_by(User, username: user_params["username"])
    end

    user |> sign_in(user_params["password"], conn)
  end

  def delete(conn, _params, _current_user) do
    delete_session(conn, :current_user)
    |> put_flash(:info, "You have been logged out.")
    |> redirect(to: session_path(conn, :new))
  end

  defp sign_in(user, _password, conn) when is_nil(user) do
    conn
    |> put_flash(:error, "Could not find a user with that username.")
    |> render("new.html", changeset: User.changeset(%User{}))
  end

  defp sign_in(user, password, conn) when is_map(user) do
    if Comeonin.Bcrypt.checkpw(password, user.encrypted_password) do
      conn
      |> put_session(:current_user, user.id)
      |> put_flash(:info, "You are now logged in.")
      |> redirect(to: folder_path(conn, :index))
    else
      conn
      |> put_flash(:error, "Username or password are incorrect.")
      |> render("new.html", changeset: User.changeset(%User{}))
    end
  end
end
