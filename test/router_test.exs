defmodule Tally.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Tally.Router

  defp add_routes(conn, routes) do

    conn |> Plug.Conn.put_private(:tally_routes, Router.init(routes))
  end

  test "Match Route" do

    routes = [{"/", "http://example.com"}]
    conn = conn(:get, "/hello") |> add_routes(routes)

    conn = Router.match(conn, [])

    assert conn.private.tally_route.match == []
  end

  test "Unable to Match Route" do

    routes = []
    conn = conn(:get, "/hello") |> add_routes(routes)

    conn = Router.match(conn, [])

    refute conn.private.tally_route

    conn = Router.dispatch(conn, [])
    assert conn.status == 404
  end
end
