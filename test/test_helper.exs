ExUnit.start()
Hammox.defmock(ClientFakeGithubMock, for: Swap.Clients.Github)
Ecto.Adapters.SQL.Sandbox.mode(Swap.Repo, :manual)
