defmodule Constants do
  def get_github_token() do
    Application.fetch_env!(:dao_panel, :github_token)
  end
end
