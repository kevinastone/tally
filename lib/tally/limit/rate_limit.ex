defmodule Tally.Limit.RateLimit do

  @behaviour Tally.Limit

  def init(_opts \\ []) do
  end

  def limit(conn, identity, _opts) do
    conn |> Plug.Conn.merge_resp_headers(%{"x-ratelimit-id" => identity})
  end
end
