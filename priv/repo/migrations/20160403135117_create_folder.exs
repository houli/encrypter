defmodule Encrypter.Repo.Migrations.CreateFolder do
  use Ecto.Migration

  def change do
    create table(:folders) do
      add :name, :string
      add :folder_key, :string
      add :owner_id, references(:users, on_delete: :delete_all)

      timestamps
    end
    create unique_index(:folders, [:name])
    create index(:folders, [:owner_id])

  end
end
