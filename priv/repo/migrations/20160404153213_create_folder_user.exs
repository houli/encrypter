defmodule Encrypter.Repo.Migrations.CreateFolderUser do
  use Ecto.Migration

  def change do
    create table(:folder_users, primary_key: false) do
      add :folder_id, references(:folders, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
    end
    create index(:folder_users, [:folder_id])
    create index(:folder_users, [:user_id])
  end
end
