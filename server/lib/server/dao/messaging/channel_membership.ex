defmodule Server.Dao.Messaging.ChannelMembership do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id

  schema "channel_memberships" do
    belongs_to(
      :user,
      Server.Dao.Accounts.User,
      foreign_key: :account_id,
      primary_key: true,
      references: :account_id
    )

    belongs_to(:channel, Server.Dao.Messaging.Channel,
      primary_key: true,
      references: :channel_id
    )

    field(:is_admin, :boolean, default: false)
    field(:is_muted, :boolean, default: false)
    field(:username, :string)

    timestamps()
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:account_id, :channel_id, :is_admin, :is_muted, :username])
    |> validate_required([:account_id, :channel_id])
    |> unique_constraint([:account_id, :channel_id])
  end
end
