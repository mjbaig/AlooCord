import Config

config :server, Server.Repo,
  database: "aloocord",
  username: System.fetch_env("DB_USER"),
  password: System.fetch_env("DB_PASSWORD"),
  hostname: System.fetch_env("DB_HOST"),
  show_sensitive_data_on_connection_error: false,
  pool_size: 10

config :joken, default_signer: System.fetch_env!("JWT_SECRET") |> Joken.Signer.create("HS256")

config :server, :jwt_secret, System.fetch_env!("JWT_SECRET")
