defmodule DAOPanel.Repo do
  use Ecto.Repo,
    otp_app: :dao_panel,
    adapter: Ecto.Adapters.Postgres
end
