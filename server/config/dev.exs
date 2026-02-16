import Config

config :server, Server.Repo,
  database: "aloocord",
  username: "admin",
  password: "admin",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :server, :jwt_secret, "changethis"
