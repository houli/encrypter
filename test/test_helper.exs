ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Encrypter.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Encrypter.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Encrypter.Repo)

