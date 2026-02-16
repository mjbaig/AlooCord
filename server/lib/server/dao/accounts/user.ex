defmodule Server.Dao.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:account_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    has_many(
      :channel_memberships,
      Server.Dao.Messaging.ChannelMembership,
      foreign_key: :account_id
    )

    has_many(
      :user_roles,
      Server.Dao.Messaging.UserRole,
      foreign_key: :account_id
    )

    has_many(:roles, through: [:channel_memberships, :roles])

    field(:username, :string)
    field(:email, :string)
    field(:password_hash, :string)

    field(:email_verified, :boolean, default: false)
    field(:email_verification_token, :string)

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password_hash, :email_verified, :email_verification_token])
    |> validate_required([:email, :password_hash])
    |> unique_constraint(:email)
  end
end
