defmodule Server.Dao.Accounts.UserTest do
  use ExUnit.Case, async: false

  alias Server.Dao.Accounts.User

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Server.Repo)
  end

  test "sanity test" do
    user = %User{
      account_id: "9296b08c-2e07-4c9a-a209-962ce1742242",
      email: "dude@gmail.com",
      password_hash: "asdf"
    }

    Server.Repo.insert!(user)
  end
end
