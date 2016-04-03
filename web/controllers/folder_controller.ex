defmodule Encrypter.FolderController do
  use Encrypter.Web, :controller
  import Ecto.Changeset, only: [put_change: 3]

  alias Encrypter.Folder

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  plug Encrypter.Plug.Authenticate
  plug :scrub_params, "folder" when action in [:create]

  def index(conn, _params, _current_user) do
    render conn
  end

  def new(conn, _params, _current_user) do
    changeset = Folder.changeset(%Folder{})
    render conn, changeset: changeset
  end

  def create(conn, %{"folder" => folder_params}, current_user) do
    changeset = Folder.changeset(%Folder{}, folder_params)
    if changeset.valid? do
      new_folder =
        changeset
        |> put_change(:owner_id, current_user.id)
        |> put_change(:folder_key, Base.encode16(:crypto.strong_rand_bytes(16)))
      case Repo.insert new_folder do
        {:ok, new_folder} ->
          conn
          |> put_flash(:info, "Created folder \"#{new_folder.name}\"")
          |> redirect(to: folder_path(conn, :index))
        {:error, changeset} ->
          render conn, "new.html", changeset: changeset
      end
    else
      render conn, "new.html", changeset: changeset
    end
  end
end
