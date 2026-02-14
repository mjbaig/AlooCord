import Config

config :server, :ecto_repos, [Server.Repo]

import_config("#{config_env()}.exs")
