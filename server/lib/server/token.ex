defmodule Server.Token do
  alias Joken.Signer
  alias Joken

  @secret Application.compile_env!(:server, :jwt_secret)
  @signer Signer.create("HS256", @secret)

  # generate a JWT
  def generate_and_sign(claims) do
    Joken.generate_and_sign(claims, @signer)
  end

  # verify a JWT
  def verify_and_validate(token) do
    Joken.verify_and_validate(token, @signer)
  end
end
