defmodule LINE.SocialAPI.MixProject do
  use Mix.Project

  def project do
    [
      app: :line_social_api,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # We're require Tesla.Middleware.EncodeFormUrlencoded which's not release
      # it yet.
      {:tesla, github: "teamon/tesla"},
      {:jason, "~> 1.2"},
      {:mint, "~> 1.1"},
      {:castore, "~> 0.1.7"}
    ]
  end
end
