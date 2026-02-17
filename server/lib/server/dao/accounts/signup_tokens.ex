defmodule Server.Dao.Accounts.SignupTokens do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:value, :string, []}
  schema "signup_tokens" do
    field(:is_used, :boolean)
    field(:username, :string)
  end

  def changeset(token, attrs) do
    token
    |> cast(attrs, [:is_used, :username])
    |> validate_required([:is_used, :username])
    |> unique_constraint(:username, name: :signup_tokens_username_index)
  end
end
