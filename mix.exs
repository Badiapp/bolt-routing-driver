defmodule BoltRoutingDriver.MixProject do
  use Mix.Project

  def project do
    [
      app: :bolt_routing_driver,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :retry],
      mod: { Bolt.RoutingDriver, [] }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bolt_sips, git: "https://github.com/Badiapp/bolt_sips", branch: "feature/multiple-and-concurrent-links"},
      {:retry, "~> 0.8"}
    ]
  end
end
