defmodule Tally.Handler do
  use Plug.Builder

  plug Tally.Bouncer
  plug Tally.Proxy

  def call(conn, upstream) do
    conn
    |> Tally.Proxy.configure(upstream)
    |> super(upstream)
  end
end
