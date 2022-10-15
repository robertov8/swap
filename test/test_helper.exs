ExUnit.start()
Faker.start()
Hammox.defmock(ClientFakeGithubMock, for: Clients.Github)
Ecto.Adapters.SQL.Sandbox.mode(Swap.Repo, :manual)
