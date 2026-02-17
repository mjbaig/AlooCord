defmodule Server.Impl.Auth do
  alias Server.Dao.Accounts.User
  alias Server.Repo
  alias Server.Dao.Accounts.SignupTokens

  def signup(username, password, signup_token) do
    token =
      SignupTokens
      |> Repo.get_by(value: signup_token, username: username)

    case token do
      nil ->
        {:error, :unauthorized}

      token ->
        if token.is_used do
          {:error, :token_used}
        else
          case insert_user(username, password) do
            {:ok, user} ->
              updated_token =
                token
                |> Ecto.Changeset.change(is_used: true)
                |> Repo.update()

              case updated_token do
                {:ok, _} -> {:ok, user}
                {:error, _} -> {:error, :token_update_failed}
              end

            {:error, _} ->
              {:error, :user_creation_failed}
          end
        end
    end
  end

  defp insert_user(username, password) do
    hash = Argon2.hash_pwd_salt(password)

    user = %User{
      account_id: Ecto.UUID.generate(),
      password_hash: hash,
      username: username,
      verification_token: Ecto.UUID.generate()
    }

    case Server.Repo.insert(user) do
      {:ok, inserted_user} ->
        {:ok, inserted_user}

      {:error, _} ->
        {:error, :user_creation_failed}
    end
  end

  def login(username, password) do
    case Repo.get_by(Server.Dao.Accounts.User, username: username) do
      nil ->
        {:unauthorized}

      user ->
        if Argon2.verify_pass(password, user.password_hash) do
          {:ok, token, _claims} =
            Server.Token.generate_and_sign(%{"sub" => user.account_id})

          {:authorized, token}
        else
          {:unauthorized}
        end
    end
  end
end
