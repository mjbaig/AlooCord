defmodule Server.Router do
  use Plug.Router

  use Plug.ErrorHandler

  if Mix.env() == :dev || Mix.env() == :test do
    use Plug.Debugger
  end

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  alias Server.Impl.Auth

  # this listens at port 4000 by default
  get "/ws" do
    WebSockAdapter.upgrade(conn, Server.WebsocketHandler, [], [])
  end

  post "/signup" do
    IO.inspect(conn.body_params)

    %{"username" => username, "password" => password, "signup_token" => signup_token} =
      conn.body_params

    Auth.signup(username, password, signup_token)

    # TODO verify email
    # Add whitelist email cause I don't want randos
    send_resp(conn, 200, "signed up")
  end

  post "/login" do
    %{"username" => username, "password" => password} = conn.body_params

    case Auth.login(username, password) do
      {:unauthorized} ->
        send_resp(conn, 401, "invalid credentials homie")

      {:authorized, token} ->
        send_json(conn, %{token: token})
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp send_json(conn, data) do
    body = Jason.encode!(data)

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, body)
  end
end
