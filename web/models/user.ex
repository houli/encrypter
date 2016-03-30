defmodule Encrypter.User do
  use Encrypter.Web, :model
  use Arc.Ecto.Model

  schema "users" do
    field :username, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :public_key, Encrypter.PublicKey.Type
    timestamps
  end

  @required_fields ~w(username password password_confirmation)
  @optional_fields ~w()

  @required_file_fields ~w(public_key)
  @optional_file_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_attachments(params, @required_file_fields, @optional_file_fields)
    |> validate_length(:password, min: 1)
    |> validate_length(:password_confirmation, min: 1)
    |> validate_confirmation(:password)
    |> unique_constraint(:username)
  end
end
