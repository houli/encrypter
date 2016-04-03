defmodule Encrypter.Folder do
  use Encrypter.Web, :model

  schema "folders" do
    field :name, :string
    field :folder_key, :string
    belongs_to :owner, Encrypter.User

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:name, min: 1)
    |> unique_constraint(:name)
  end
end
