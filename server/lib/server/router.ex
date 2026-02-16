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

  # this listens at port 4000 by default
  get "/ws" do
    WebSockAdapter.upgrade(conn, Server.WebsocketHandler, [], [])
  end

  post "/signup" do
    IO.inspect(conn.body_params)
    %{"email" => email, "password" => password} = conn.body_params

    hash = Argon2.hash_pwd_salt(password)

    send_resp(conn, 200, "signed up")
  end

  post "/login" do
    %{"email" => email, "password" => password} = conn.body_params

    case Repo.get_by(Server.Dao.Accounts.User, email: email) do
      nil ->
        send_resp(conn, 401, "invalid credentials homie")

      user ->
        if Argon2.verify_pass(password, user.password_hash) do
          {:ok, token, _claims} =
            Server.Token.generate_and_sign(%{"sub" => user.account_id})

          json(conn, %{token: token})
        else
          send_resp(conn, 401, "invalid credentials homie")
        end
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp send_json(conn, data) do
    body = Jason.encode!(data)

    conn
    |> Plug.Conn.put_resp_header("application/json")
    |> Plug.Conn.send_resp(200, body)
  end
end
