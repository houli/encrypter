defmodule Encrypter.File do
  use Encrypter.Web, :model
  use Arc.Ecto.Model

  schema "files" do
    field :iv, :string
    field :storage_uuid, :string
    field :file, Encrypter.FolderFile.Type
    belongs_to :folder, Encrypter.Folder

    timestamps
  end

  @required_fields ~w(folder_id)
  @optional_fields ~w()

  @required_file_fields ~w(file)
  @optional_file_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> Ecto.Changeset.put_change(:storage_uuid, UUID.uuid4)
    |> cast_attachments(params, @required_file_fields, @optional_file_fields)
  end
end
