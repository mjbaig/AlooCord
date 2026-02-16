defmodule Server.Impl.AuthTest do
  use ExUnit.Case, async: false

  alias Server.Impl.Auth

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Server.Repo)
  end

  test "test that creating a user works" do
    user = Auth.signup("test", "test@gmail.com", "password")

    assert Argon2.verify_pass("password", user.password_hash)

    assert user.account_id != nil
    assert user.email == "test@gmail.com"
    assert user.username == "test"
  end

  test "test that creating a user doesn't work if values are nil" do
    user = Auth.signup(nil, nil, "password")
  end

  test "test that login works when user puts in the correct password" do
    user = Auth.signup("test", "test@gmail.com", "password")
    {status, token} = Auth.login("test@gmail.com", "password")

    assert status == :authorized
    assert token != nil

    {status, claims} = Server.Token.verify_and_validate(token)

    assert status == :ok

    assert Map.get(claims, "sub") == user.account_id
  end

  test "test that login does not work when user puts in the incorrect password" do
    Auth.signup("test", "test@gmail.com", "password")
    {status} = Auth.login("test@gmail.com", "wrong")

    assert status == :unauthorized
  end
end
