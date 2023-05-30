defmodule Heyya.MixProject do
  use Mix.Project

  @version "0.3.1"
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
      deps: deps(),
      dialyzer: [plt_add_apps: [:ex_unit]]
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
      {:snapshy, "~> 0.3"},
      {:phoenix_live_view, "~> 0.19.0"},
      {:phoenix, "~> 1.7.1"},
      # Dev deps
      {:ex_doc, "~> 0.29.1", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
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

  defp description, do: "Heyya the testing utility for Phoenix framework components and live view"
end
