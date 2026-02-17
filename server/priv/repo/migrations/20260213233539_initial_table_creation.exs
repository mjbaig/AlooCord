defmodule Server.Repo.Migrations.InitialTableCreation do
  use Ecto.Migration

  def change do
    #user table
    create table(:users, primary_key: false) do
      add :account_id, :binary_id, primary_key: true
      add :password_hash, :string, null: false
      add :verification_token, :string
      add :username, :string, size: 16, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:username])


    # signup token to only allow signups from users with tokens
    create table(:signup_tokens, primary_key: false) do
      add :value, :string, primary_key: true
      add :is_used, :boolean, default: false, null: false
      add :username, :string, size: 16, null: false
    end

    create unique_index(:signup_tokens, [:username])

    # channel tables
    # The channels here are referred to as dicord servers, but I don't like that name
    create table(:chat_channels, primary_key: false) do
      add :channel_id, :binary_id, primary_key: true
      add :name, :string, size: 36, null: false
    end

    # topics
    # these are the equivalent of a discord channel
    create table(:topics, primary_key: false) do
      add :topic_id, :binary_id, primary_key: true

      # topics are children of channel ids, so they need a channel id associated with them.
      add :channel_id,
        references(
          :chat_channels,
          column: :channel_id,
          type: :binary_id,
          on_delete: :delete_all
        ),
        null: false

      add :name, :string, size: 36, null: false
    end

    create unique_index(:topics, [:channel_id, :name])

    # Threads are threads. The main tread is like writing directly in to the topic, different threads will be visually moved.
    create table(:threads, primary_key: false) do
      add :thread_id, :binary_id, primary_key: true

      add :topic_id,
        references(
          :topics,
          column: :topic_id,
          type: :binary_id,
          on_delete: :delete_all
        ),
        null: false

      add :name, :string, size: 36, null: false
    end

    create unique_index(:threads, [:topic_id, :name])

    # Messages are messages send to a particular channel, topic and thread combination.
    create table(:messages, primary_key: false) do
      add :message_id, :bigserial, primary_key: true

      add :thread_id,
        references(
          :threads,
          column: :thread_id,
          type: :binary_id,
          on_delete: :delete_all
        ),
        null: false

      add :creator_id,
        references(
          :users,
          column: :account_id,
          type: :binary_id,
          on_delete: :nilify_all
        ),
        null: false

      add :created_at, :utc_datetime_usec, null: false
      add :body, :text, null: false
    end

    create index(:messages, [:created_at])
    create index(:messages, [:thread_id])

    # channel memberships checks whether an account can write to a particular thread or not
    create table(:channel_memberships, primary_key: false) do
      add :account_id,
        references(
          :users,
          column: :account_id,
          type: :binary_id,
          on_delete: :delete_all
        ),
        primary_key: true

      add :channel_id,
        references(
          :chat_channels,
          column: :channel_id,
          type: :binary_id,
          on_delete: :delete_all
        ),
        primary_key: true

      add :is_admin, :boolean, default: false, null: false
      add :is_muted, :boolean, default: false, null: false

      add :username, :string, size: 16

    end

    # Muted topics is used to stop braodcast of messages to these users unless the user asks for them.
    #
    create table(:muted_topics, primary_key: false) do
      add :account_id,
        references(
          :users,
          column: :account_id,
          type: :binary_id,
          on_delete: :delete_all
        ),
        primary_key: true

      add :topic_id,
        references(
          :topics,
          column: :topic_id,
          type: :binary_id,
          on_delete: :delete_all
        ),
        primary_key: true
    end

    # muted threads is used to stop broadcast of messages in threads that the user selected to mute
    create table(:muted_threads, primary_key: false) do
      add :account_id,
        references(
          :users,
          column: :account_id,
          type: :binary_id,
          on_delete: :delete_all
        ),
        primary_key: true

      add :thread_id,
        references(
          :threads,
          column: :thread_id,
          type: :binary_id,
          on_delete: :delete_all
        ),
        primary_key: true
    end

    # roles table contains the role definitions and which channels they belong to
    create table(:roles, primary_key: false) do
      add :role_id, :binary_id, primary_key: true

      add :channel_id,
        references(
          :chat_channels,
          column: :channel_id,
          type: :binary_id,
          on_delete: :delete_all
        ),
        null: false

      add :role_name, :string, size: 36, null: false
      add :can_write, :boolean, default: false, null: false
      add :can_read, :boolean, default: false, null: false
      add :can_emote, :boolean, default: false, null: false

    end

    create unique_index(:roles, [:channel_id, :role_name])

  # user roles assigns roles to an accountId
  create table(:user_roles, primary_key: false) do
    add :account_id,
      references(
        :users,
        column: :account_id,
        type: :binary_id,
        on_delete: :delete_all
      ),
      primary_key: true
      
    add :role_id,
      references(
        :roles,
        column: :role_id,
        type: :binary_id,
        on_delete: :delete_all
      ),
      primary_key: true
  end
  end
  


end
