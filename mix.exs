defmodule FunPipelinex.MixProject do
  use Mix.Project

  @description "fun_pipelinex is a package which filter function's args and return value by your custom Filters."

  @gitee_repo_url "https://gitee.com/lizhaochao/fun_pipelinex"
  @github_repo_url "https://github.com/lizhaochao/fun_pipelinex"

  @version "1.0.0"

  def project do
    [
      app: :fun_pipelinex,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      # Test
      test_pattern: "*_test.exs",

      # Hex
      package: package(),
      description: @description,

      # Docs
      name: "fun_pipelinex",
      docs: [main: "FunPipelinex"]
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps do
    [
      # Dev and test dependencies
      {:excoveralls, "~> 0.14.0", only: :test},
      {:propcheck, "~> 1.4.0", only: :test},
      {:credo, "~> 1.5.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24.2", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1.0", only: :dev, runtime: false},
      {:benchfella, "~> 0.3.5", only: :dev}
    ]
  end

  defp package do
    [
      name: "fun_pipelinex",
      maintainers: ["lizhaochao"],
      licenses: ["MIT"],
      links: %{"Gitee" => @gitee_repo_url, "GitHub" => @github_repo_url}
    ]
  end

  defp aliases, do: [test: ["format", "test"], bench: ["format", "bench"]]
end
