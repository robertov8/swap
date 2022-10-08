defmodule Swap.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Swap.Repo

  def repository_factory do
    %Swap.Repositories.Repository{
      name: Faker.Internet.domain_word(),
      owner: "swap"
    }
  end
end
