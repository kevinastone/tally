defmodule Tally.Bouncer do
  use Plug.Builder

  plug :identify, adapter: Tally.Identify.BearerToken
  plug :limit, adapter: {Tally.Limit.RateLimit, [{5, :min}]}

  defp do_identify(conn, adapter, opts) do
    case conn |> adapter.identify(adapter.init(opts)) do
      {:ok, conn, identity} -> conn |> Plug.Conn.assign(:identity, identity)
      {:fail, conn} -> conn
    end
  end

  def identify(conn, [adapter: {adapter, adapter_opts}]) do
    do_identify(conn, adapter, adapter_opts)
  end

  def identify(conn, [adapter: adapter]) do
    do_identify(conn, adapter, [])
  end

  defp do_limit(conn, adapter, adapter_opts) do
    identity = conn.assigns[:identity]
    case identity do
      nil -> conn |> send_resp(401, "Unknown") |> halt
      identity -> conn |> adapter.limit(identity, adapter.init(adapter_opts))
    end
  end

  def limit(conn, [adapter: {adapter, adapter_opts}]) do
    do_limit(conn, adapter, adapter_opts)
  end

  def limit(conn, [adapter: adapter]) do
    do_limit(conn, adapter, [])
  end
end
