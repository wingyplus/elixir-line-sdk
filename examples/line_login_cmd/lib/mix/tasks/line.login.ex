defmodule Mix.Tasks.Line.Login do
  @moduledoc """
  Login to LINE to get access token.

  Usages:

    $ mix line.login <channel_id> <channel_secret>
  """

  use Mix.Task

  @shortdoc "Get LINE Access Token from LINE Login."

  def run([channel_id, channel_secret]) do
    # Bootstrap all related applications.
    {:ok, _} = Application.ensure_all_started(:line_login_cmd)
    {:ok, sup} = LINELoginCmd.Application.start_link()

    base_url = "https://access.line.me/oauth2/v2.1/authorize"

    query = %{
      client_id: channel_id,
      redirect_uri: "http://localhost:12345",
      response_type: "code",
      state: "12345abcdq",
      scope: "profile",
      nonce: "09876xyz"
    }

    IO.puts("#{base_url}?#{URI.encode_query(query)}")

    LINELoginCmd.CodeState.polling_code()
    |> LINE.SocialAPI.OAuth.issue_access_token(
      "http://localhost:12345",
      channel_id,
      channel_secret
    )
    |> case do
      {:ok, %{access_token: access_token}} ->
        IO.puts(access_token)

      {:error, error} = error ->
        IO.inspect(error)
    end

    Supervisor.stop(sup)
  end
end
