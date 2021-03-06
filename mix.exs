defmodule Tally.Mixfile do
  use Mix.Project

  def project do
    [app: :tally,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: Tally],
     deps: deps(),
     aliases: aliases(),
     package: package()]
  end

  def aliases do
    [
      run: ["run --no-halt"]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :cowboy, :plug, :hackney, :con_cache],
     mod: {Tally, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:cowboy, "~> 1.1.0"},
      {:plug, "~> 1.0"},
      {:hackney, "~> 1.8.0"},
      {:con_cache, "~> 0.12.0"},
      {:credo, "~> 0.8", only: [:dev, :test]}
    ]
  end

  defp package do
    %{maintainers: ["Kevin Stone"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/kevinastone/tally"}}
  end
end
