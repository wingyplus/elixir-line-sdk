defmodule LINELoginCmd.MixProject do
  use Mix.Project

  def project do
    [
      app: :line_login_cmd,
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
      {:castore, "~> 0.1.7"},
      {:plug_cowboy, "~> 2.3"},
      {:line_social_api, path: "../../clients/line_social_api"}
    ]
  end
end
