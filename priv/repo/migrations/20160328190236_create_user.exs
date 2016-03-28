defmodule Encrypter.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :encrypted_password, :string
      add :public_key, :string

      timestamps
    end

    create unique_index(:users, [:username])

  end
end
