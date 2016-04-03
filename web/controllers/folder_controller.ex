defmodule Encrypter.FolderController do
  use Encrypter.Web, :controller
  import Ecto.Changeset, only: [put_change: 3]

  alias Encrypter.Folder
  alias Encrypter.File

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  plug Encrypter.Plug.Authenticate
  plug :scrub_params, "folder" when action in [:create]
  plug :scrub_params, "file" when action in [:upload_file]

  def index(conn, _params, _current_user) do
    folders = Repo.all(Folder)
    render conn, folders: folders
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
          |> redirect(to: folder_path(conn, :index))
        {:error, changeset} ->
          render conn, "new.html", changeset: changeset
      end
    else
      render conn, "new.html", changeset: changeset
    end
  end

  def new_file(conn, %{"id" => folder_id}, current_user) do
    folder = Repo.get(Folder, folder_id) |> Repo.preload(:owner)
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
    folder = Repo.get(Folder, folder_id) |> Repo.preload(:owner)
    if folder.owner == current_user do

      initialisation_vector = :crypto.strong_rand_bytes(16)
      encrypt_file_aes_256(file_params["file"].path,
                           folder.folder_key,
                           initialisation_vector)

      changeset = File.changeset(%File{}, Map.put(file_params, "folder_id", folder_id))

      if changeset.valid? do
        Repo.insert(changeset |> put_change(:iv, Base.encode16(initialisation_vector)))

        conn
        |> put_flash(:info, "Uploaded and encrypted file.")
        |> redirect(to: folder_path(conn, :index))
      else
        render conn, "new_file.html", changeset: changeset
      end
    else
      conn
      |> put_flash(:error, "You do not have permission to upload files to that folder.")
      |> redirect(to: folder_path(conn, :index))
    end
  end

  defp encrypt_file_aes_256(path, folder_key, initialisation_vector) do
    {:ok, folder_key} = Base.decode16(folder_key)
    {:ok, plain_text} = Elixir.File.read(path)

    cipher_text = :crypto.block_encrypt(:aes_cbc256,
                                        folder_key,
                                        initialisation_vector,
                                        pkcs5_pad(plain_text))
    # Overwrite the uploaded temp file with the encrypted temp file
    Elixir.File.write(path, cipher_text)
  end

  # Padding function according to PKCS#5
  # If it's evenly divisible by 16 add 16 16s
  # Otherwise add 16 - remainder, 16 - remainder times
  defp pkcs5_pad(plain_text) do
    padding = 16 - rem(byte_size(plain_text), 16)
    plain_text <> String.duplicate(<<padding>>, padding)
  end
end
