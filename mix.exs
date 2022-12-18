defmodule DAOPanel.MixProject do
  use Mix.Project

  def project do
    [
      app: :dao_panel,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {DAOPanel.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.0-rc.0", override: true},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.3"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:petal_components, "~> 0.19.0"},

      # ======
      # Utils
      {:ex_struct_translator, "~> 0.1.1"},

      # cross domain
      {:cors_plug, "~> 2.0"},

      # for user
      {:pow, "~> 1.0.25"},

      # arweave
      {:arweave_sdk_ex, "~> 0.1.1"},

      # handle_uri
      {:ex_url, "~> 1.4"},

      # markdown
      {:earmark, "~> 1.4"},

      # Binary
      {:binary, "~> 0.0.5"},

      # Ethereum
      {:ethereumex, "~> 0.7.0"},
      {:ex_abi, "~> 0.5.2"},
      {:eth_wallet, "~> 0.0.14"},

      # http
      {:httpoison, "~> 1.5"},
      {:poison, "~> 3.1"},
      {:ex_http, "~>0.0.1"},

      # crypto
      {:starkbank_ecdsa, "~> 1.0.0"},
      {:ex_rlp, "~> 0.2.1"},
      {:libsecp256k1, "~> 0.1.9"},
      {:ex_crypto, "~> 0.10.0"},

      # github
      {:tentacat, "~> 2.0"},

      {:ecto, "~> 3.9.0", override: true},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": [
        "tailwind default --minify",
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end
end
