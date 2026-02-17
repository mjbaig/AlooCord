defmodule Server.Impl.AuthTest do
  use ExUnit.Case, async: false

  alias Server.Dao.Accounts.SignupTokens
  alias Hex.Repo
  alias Server.Impl.Auth

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Server.Repo)
  end

  test "test that creating a user works" do
    Server.Repo.insert(%SignupTokens{username: "test", value: "token"})
    {_, user} = Auth.signup("test", "password", "token")

    assert Argon2.verify_pass("password", user.password_hash)

    assert user.account_id != nil
    assert user.username == "test"
  end

  test "test that creating a user doesn't work if username is nil" do
    Server.Repo.insert(%SignupTokens{username: "test", value: "token"})
    # null contraint throws error
    assert_raise ArgumentError, fn ->
      Auth.signup(nil, "password", "token")
    end
  end

  test "test that creating a user doesn't work if password is nil" do
    Server.Repo.insert(%SignupTokens{username: "test_nil", value: "token"})
    # This throws an argument error because the password is hashed before being written
    assert_raise ArgumentError, fn ->
      {_, user} = Auth.signup("test_nil", nil, "token")
    end
  end

  test "test that login works when user puts in the correct password" do
    Server.Repo.insert(%SignupTokens{username: "test", value: "token"})
    {_, user} = Auth.signup("test", "password", "token")
    {status, token} = Auth.login("test", "password")

    assert status == :authorized
    assert token != nil

    {status, claims} = Server.Token.verify_and_validate(token)

    assert status == :ok

    assert Map.get(claims, "sub") == user.account_id
  end

  test "test that login does not work when user puts in the incorrect password" do
    Server.Repo.insert(%SignupTokens{username: "test", value: "token"})
    Auth.signup("test", "password", "token")
    {status} = Auth.login("test", "wrong")

    assert status == :unauthorized
  end
end
