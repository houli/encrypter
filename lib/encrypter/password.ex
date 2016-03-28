defmodule Encrypter.Password do
  alias Encrypter.Repo
  import Ecto.Changeset, only: [put_change: 3]
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  @doc """
  Generates a password for the user changeset and stores it to the changeset as encrypted_password.
  """
  def generate_password(changeset) do
    put_change(changeset, :encrypted_password, hashpwsalt(changeset.params["password"]))
  end

 end
