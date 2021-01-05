defmodule AdeptModal.MixProject do
  use Mix.Project

  def project do
    [
      app: :adept_modal,
      version: "0.1.0",
      elixir: "~> 1.11",
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
      {:phoenix_live_view, "~> 0.15"},
      {:phoenix_html, "~> 2.14"},
      {:jason, "~> 1.2"},

      # test only tools
      {:floki, ">= 0.29.0", only: :test},
    ]
  end
end
