defmodule DAOPanelWeb.PageControllerTest do
  use DAOPanelWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Petal"
  end
end
