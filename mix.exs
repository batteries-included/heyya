defmodule Heyya.MixProject do
  use Mix.Project

  @version "0.7.0"
  @source_url "https://github.com/batteries-included/heyya"

  def project do
    [
      app: :heyya,
      version: @version,
      elixir: "~> 1.15",
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
      {:phoenix_live_view, "~> 0.20"},
      {:phoenix, "~> 1.7"},
      {:floki, "~> 0.35"},
      # Dev deps
      {:ex_doc, "~> 0.30", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:styler, "~> 0.10", only: [:dev, :test], runtime: false}
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
