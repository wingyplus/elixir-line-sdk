defmodule Tesla.Middleware.EncodeFormUrlEncoded do
  @moduledoc """
  Perform encode only form url encoded.
  """
  @behaviour Tesla.Middleware

  @impl true
  def call(env, next, opts)

  # NOTE: Tesla will try to perform a middleware even the request perform
  # with get method.
  def call(%Tesla.Env{method: :get} = env, next, _opts),
    do: Tesla.run(env, next)

  def call(env, next, _opts) do
    env
    |> encode()
    |> Tesla.run(next)
  end

  defp encode(env) do
    env
    |> Map.update!(:body, &URI.encode_query/1)
  end
end

defmodule LINE.SocialAPI.OAuth do
  @moduledoc """
  Client API for OAuth of LINE Social API v2.1.

  TODO: extract error data to struct.
  """

  use Tesla, only: ~w(get post)a
  adapter Tesla.Adapter.Mint

  plug Tesla.Middleware.BaseUrl, "https://api.line.me"
  plug Tesla.Middleware.Headers, [{"content-type", "application/x-www-form-urlencoded"}]
  plug Tesla.Middleware.EncodeFormUrlEncoded
  plug Tesla.Middleware.DecodeJson, engine_opts: [keys: :atoms]

  @doc """
  Issue access token.
  """
  def issue_access_token(
        code,
        redirect_uri,
        client_id,
        client_secret,
        grant_type \\ "authorization_code"
      ) do
    post(
      "/oauth2/v2.1/token",
      %{
        grant_type: grant_type,
        code: code,
        redirect_uri: redirect_uri,
        client_id: client_id,
        client_secret: client_secret
      }
    )
    |> extract_body()
  end

  @doc """
  Verify the access token validity.
  """
  def verify_access_token(access_token) do
    get("/oauth2/v2.1/verify", query: [access_token: access_token])
    |> extract_body()
  end

  def refresh_access_token(refresh_token, client_id, client_secret, grant_type \\ "refresh_token") do
    post(
      "/oauth2/v2.1/token",
      %{
        grant_type: grant_type,
        refresh_token: refresh_token,
        client_id: client_id,
        client_secret: client_secret
      }
    )
    |> extract_body()
  end

  def revoke_access_token(access_token, client_id, client_secret) do
    post(
      "/oauth2/v2.1/revoke",
      %{
        access_token: access_token,
        client_id: client_id,
        client_secret: client_secret
      }
    )
    |> case do
      {:ok, %Tesla.Env{status: 200}} ->
        :ok

      {:ok, %Tesla.Env{body: body}} ->
        {:error, body}

      {:error, _} = error ->
        error
    end
  end

  defp extract_body({:ok, %Tesla.Env{body: body}}) do
    {:ok, body}
  end

  defp extract_body({:error, _} = error), do: error
end
