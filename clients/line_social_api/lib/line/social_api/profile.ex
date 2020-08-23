defmodule LINE.SocialAPI.Profile.UserProfile do
  defstruct [:display_name, :user_id, :picture_url, :status_message]

  def from_map(user_profile) when is_map(user_profile) do
    %__MODULE__{
      display_name: user_profile["displayName"],
      user_id: user_profile["userId"],
      picture_url: user_profile["pictureUrl"],
      status_message: user_profile["statusMessage"]
    }
  end
end

defmodule LINE.SocialAPI.Profile do
  alias LINE.SocialAPI.Profile.UserProfile

  use Tesla
  adapter Tesla.Adapter.Mint

  plug Tesla.Middleware.BaseUrl, "https://api.line.me"
  plug Tesla.Middleware.DecodeJson

  def get_user_profile(access_token) do
    get("/v2/profile", headers: [{"authorization", "Bearer #{access_token}"}])
    |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body |> UserProfile.from_map()}

      {:ok, %Tesla.Env{body: body}} ->
        {:error, body}

      {:error, _} = error ->
        error
    end
  end
end
