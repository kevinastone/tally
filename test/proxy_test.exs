defmodule Tally.ProxyTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Tally.Proxy

  @server_host "localhost"
  @server_port 4002

  defmodule TestServer do
    use Plug.Router

    plug :match
    plug :dispatch

    get "/hello" do
      send_resp(conn, 200, "world")
    end

    get "/fail" do
      Process.exit(Kernel.self, :normal)
      conn
    end

    match _ do
      send_resp(conn, 404, "oops")
    end
  end

  setup_all do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, TestServer, [], [port: @server_port])
    ]
    opts = [strategy: :one_for_one]
    {:ok, supervisor} = Supervisor.start_link(children, opts)
    {:ok, supervisor: supervisor}
  end

  test "Proxy HTTP" do

    upstream = "http://#{@server_host}:#{@server_port}"
    Proxy.init(upstream)
    conn =
      conn(:get, "/hello")
      |> Proxy.call(upstream)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "Proxy HTTP Failure" do

    upstream = "http://#{@server_host}:#{@server_port}"
    Proxy.init(upstream)
    conn =
      conn(:get, "/fail")
      |> Proxy.call(upstream)

    assert conn.state == :sent
    assert conn.status == 503
  end

  test "Proxy HTTP Unavailable" do

    upstream = "http://#{@server_host}:#{@server_port + 1}"
    Proxy.init(upstream)
    conn =
      conn(:get, "/hello")
      |> Proxy.call(upstream)

    assert conn.state == :sent
    assert conn.status == 503
  end

  test "Proxy URI" do

    upstream = "http://example.com"
    Proxy.init(upstream)
    uri =
      conn(:get, "/hello")
      |> Proxy.uri(upstream)

    assert uri == "http://example.com/hello"
  end

  test "Proxy URI with Querystring" do

    upstream = "http://example.com"
    Proxy.init(upstream)
    uri =
      conn(:get, "/hello?test=something")
      |> Proxy.uri(upstream)

    assert uri == "http://example.com/hello?test=something"
  end
end
