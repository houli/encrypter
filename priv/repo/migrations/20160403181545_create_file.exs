defmodule Encrypter.Repo.Migrations.CreateFile do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :file, :string
      add :iv, :string
      add :storage_uuid, :string
      add :folder_id, references(:folders, on_delete: :delete_all)

      timestamps
    end
    create index(:files, [:folder_id])

  end
end
