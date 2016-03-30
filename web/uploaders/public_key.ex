defmodule Encrypter.PublicKey do
  use Arc.Definition
  use Arc.Ecto.Definition

  def __storage, do: Arc.Storage.Local

  # Override the storage directory:
  def storage_dir(version, {file, scope}) do
    "uploads/user/keys/#{UUID.uuid4}"
  end
end
