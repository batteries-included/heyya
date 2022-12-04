defmodule Heyya.MixProject do
  use Mix.Project

  @version "0.1.2"
  @source_url "https://github.com/batteries-included/heyya"

  def project do
    [
      app: :heyya,
      version: @version,
      elixir: "~> 1.14",
      description: description(),
      docs: docs(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
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

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:snapshy, "~> 0.2"},
      {:phoenix_live_view, "~> 0.18.3"},
      {:phoenix, "~> 1.6.15"},
      # Dev deps
      {:ex_doc, "~> 0.29.1", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
      name: :heyya,
      maintainers: ["Elliott Clark"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: @version,
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end

  defp description, do: "Heyya the snapshot testing utility for Phoenix framework components"
end
