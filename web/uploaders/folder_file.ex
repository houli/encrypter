defmodule Encrypter.FolderFile do
  use Arc.Definition
  use Arc.Ecto.Definition

  def __storage, do: Arc.Storage.Local

  # Override the storage directory:
  def storage_dir(version, {file, scope}) do
    "uploads/files/#{scope.storage_uuid}"
  end
end
