import Config

config :server, Server.Repo,
  username: "admin",
  password: "admin",
  database: "aloocord",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :joken, default_signer: "changethis"
