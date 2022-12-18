defmodule DAOPanelWeb.PageController do
  use DAOPanelWeb, :controller

  def home(conn, _params) do
    render(conn, :home, active_tab: :home)
  end
end
