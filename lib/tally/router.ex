defmodule Tally.Router do

  defmodule Route do
    defstruct [:match, :callback]

    def new(path, upstream) do

      {_vars, match}   = Plug.Router.Utils.build_path_match(path)

      %Route{
        match: match,
        callback: fn conn -> Tally.Proxy.call(conn, Tally.Proxy.init(upstream)) end
      }
    end
  end

  use Plug.Builder

  plug Plug.Logger
  plug :match
  plug :dispatch

  def init(upstreams \\ []) do
    for upstream <- upstreams do
      case upstream do
        upstream = %Route{} -> upstream
        {path, upstream} -> Route.new(path, upstream)
      end
    end
  end

  def call(conn, routes) do
    conn = Plug.Conn.put_private conn, :tally_routes, routes
    super(conn, routes)
  end

  defp route_matches?(route, conn) do
    path = Stream.map(conn.path_info, &URI.decode/1)
    Enum.all?(
      Stream.zip(route.match, path),
      fn {a, b} -> a == b end
    )
  end

  def match(%Plug.Conn{private: %{tally_routes: routes}} = conn, _opts) do
    route = Enum.find routes, fn route -> route_matches?(route, conn) end
    Plug.Conn.put_private conn, :tally_route, route
  end

  def dispatch(%Plug.Conn{private: %{tally_route: nil}} = conn, _opts) do
    conn |> send_resp(404, "Not Found")
  end

  def dispatch(%Plug.Conn{private: %{tally_route: %Route{callback: callback}}} = conn, _opts) do
    callback.(conn)
  end
end
