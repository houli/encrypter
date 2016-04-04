defmodule Encrypter.FolderController do
  use Encrypter.Web, :controller
  import Ecto.Changeset, only: [put_change: 3]

  alias Encrypter.AES
  alias Encrypter.File
  alias Encrypter.Folder

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  plug Encrypter.Plug.Authenticate
  plug :scrub_params, "folder" when action in [:create]
  plug :scrub_params, "file" when action in [:upload_file]

  def index(conn, _params, _current_user) do
    folders = Repo.all(Folder) |> Repo.preload(:owner)
    render conn, folders: folders
  end

  def show(conn, %{"id" => folder_id}, current_user) do
    folder = Repo.get!(Folder, folder_id) |> Repo.preload([:files, :users, :owner])
    folder_key = nil
    if folder.owner == current_user || Enum.member?(folder.users, current_user) do
      [entry] = :public_key.pem_decode(current_user.public_key)
      user_key = :public_key.pem_entry_decode(entry)
      folder_key = Base.encode64(:public_key.encrypt_public(folder.folder_key, user_key))
    end
    render conn, folder: folder, folder_key: folder_key
  end

  def edit(conn, %{"id" => folder_id}, current_user) do
    folder = load_folder(folder_id)
    if folder.owner == current_user do
      render conn, folder: folder
    else
      conn
      |> put_flash(:error, "You are not the owner of this folder")
      |> redirect(to: folder_path(conn, :index))
    end
  end

  def add_user(conn, %{"id" => folder_id}, current_user) do
    folder = load_folder(folder_id)
    if folder.owner == current_user do
      render conn, folder: folder
    else
      conn
      |> put_flash(:error, "You are not the owner of this folder")
      |> redirect(to: folder_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => folder_id}, current_user) do
    folder = Repo.get!(Folder, folder_id) |> Repo.preload(:owner)
    Repo.delete!(folder)

    conn
    |> put_flash(:info, "Folder deleted successfully.")
    |> redirect(to: folder_path(conn, :index))
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
        |> put_change(:folder_key, Base.encode16(:crypto.strong_rand_bytes(32)))
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

  def new_file(conn, %{"id" => folder_id}, current_user) do
    folder = load_folder(folder_id)
    if folder.owner == current_user do
      changeset = File.changeset(%File{})
      render conn, changeset: changeset, folder: folder
    else
      conn
      |> put_flash(:error, "You do not have permission to upload files to that folder.")
      |> redirect(to: folder_path(conn, :index))
    end
  end

  def upload_file(conn, %{"id" => folder_id, "file" => file_params}, current_user) do
    folder = load_folder(folder_id)
    if folder.owner == current_user do

      initialisation_vector = :crypto.strong_rand_bytes(16)
      AES.encrypt_file_aes_256(file_params["file"].path,
                               folder.folder_key,
                               initialisation_vector)

      changeset = File.changeset(%File{}, Map.put(file_params, "folder_id", folder_id))

      if changeset.valid? do
        Repo.insert(changeset |> put_change(:iv, Base.encode16(initialisation_vector)))

        conn
        |> put_flash(:info, "Uploaded and encrypted file.")
        |> redirect(to: folder_path(conn, :show, folder))
      else
        render conn, "new_file.html", changeset: changeset
      end
    else
      conn
      |> put_flash(:error, "You do not have permission to upload files to that folder.")
      |> redirect(to: folder_path(conn, :index))
    end
  end

  defp load_folder(id) do
    Repo.get!(Folder, id) |> Repo.preload(:owner)
  end
end
