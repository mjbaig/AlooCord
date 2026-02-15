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
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [])
  end
end
