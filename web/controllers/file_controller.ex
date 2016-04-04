defmodule Encrypter.FileController do
  use Encrypter.Web, :controller
  import Ecto.Changeset, only: [put_change: 3]

  alias Encrypter.AES

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  plug Encrypter.Plug.Authenticate
  plug :scrub_params, "file" when action in [:create]

  def new(conn, %{"id" => folder_id}, current_user) do
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

  def create(conn, %{"id" => folder_id, "file" => file_params}, current_user) do
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
