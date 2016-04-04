defmodule Encrypter.FolderController do
  use Encrypter.Web, :controller
  import Ecto.Changeset, only: [put_change: 3]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  plug Encrypter.Plug.Authenticate
  plug :scrub_params, "folder" when action in [:create]

  def index(conn, _params, _current_user) do
    folders = Repo.all(Folder) |> Repo.preload([:owner, :users])
    render conn, folders: folders
  end

  def show(conn, %{"id" => folder_id}, current_user) do
    folder = load_folder(folder_id) |> Repo.preload([:files, :users])
    folder_key = nil
    if folder.owner == current_user || Enum.member?(folder.users, current_user) do
      [entry] = :public_key.pem_decode(current_user.public_key)
      user_key = :public_key.pem_entry_decode(entry)

      # Encrypt the folder's AES key and encode it do be displayed on the page
      folder_key = Base.encode64(:public_key.encrypt_public(folder.folder_key, user_key))
    end
    render conn, folder: folder, folder_key: folder_key
  end

  def delete(conn, %{"id" => folder_id}, current_user) do
    folder = load_folder(folder_id)
    if folder.owner == current_user do
      Repo.delete!(folder)

      conn
      |> put_flash(:info, "Folder deleted successfully.")
      |> redirect(to: folder_path(conn, :index))
    else
      conn
      |> put_flash(:error, "You are not the owner of this folder.")
      |> redirect(to: folder_path(conn, :index))
    end
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
        |> put_change(:folder_key, Base.encode16(:crypto.strong_rand_bytes(32))) # Create an AES key for this folder
      case Repo.insert new_folder do
        {:ok, new_folder} ->
          conn
          |> put_flash(:info, "Created folder \"#{new_folder.name}\"")
          |> redirect(to: folder_path(conn, :show, new_folder))
        {:error, changeset} ->
          render conn, "new.html", changeset: changeset
      end
    else
      render conn, "new.html", changeset: changeset
    end
  end

  def edit(conn, %{"id" => folder_id}, current_user) do
    folder = load_folder(folder_id) |> Repo.preload(:users)
    changeset = FolderUser.changeset(%FolderUser{})
    if folder.owner == current_user do
      render conn, changeset: changeset, folder: folder, users: Repo.all(User)
    else
      conn
      |> put_flash(:error, "You are not the owner of this folder.")
      |> redirect(to: folder_path(conn, :index))
    end
  end

  def add_user(conn, %{"id" => folder_id, "folder_user" => folder_user}, current_user) do
    user = Repo.get_by!(User, username: folder_user["username"])
    folder = load_folder(folder_id)
    if folder.owner == current_user do
      changeset = FolderUser.changeset(%FolderUser{}, %{folder_id: folder_id, user_id: user.id})
      if changeset.valid? do
        Repo.insert changeset

        conn
        |> put_flash(:info, "User \"#{user.username}\" added to the folder \"#{folder.name}\"")
        |> redirect(to: folder_path(conn, :index))
      else
        render conn, "edit.html", changeset: changeset
      end
    else
      conn
      |> put_flash(:error, "You are not the owner of this folder.")
      |> redirect(to: folder_path(conn, :index))
    end
  end

  defp load_folder(id) do
    Repo.get!(Folder, id) |> Repo.preload(:owner)
  end
end
