defmodule Tally.Limit.RateLimit do

  @behaviour Tally.Limit

  def init(limits \\ []), do: limits

  defp ttl(limit, :sec), do: limit
  defp ttl(limit, :min), do: ttl(limit, :sec) * 60
  defp ttl(limit, :hour), do: ttl(limit, :min) * 60
  defp ttl(limit, :day), do: ttl(limit, :hour) * 24

  def limit(conn, identity, limits \\ []) do
    IO.inspect({:limits, limits})

    conn |> Plug.Conn.merge_resp_headers(%{"x-ratelimit-id" => identity})

    Enum.reduce limits, conn, fn {limit, duration}, conn ->
      key = "#{identity}.#{limit}#{duration}"

      used = ConCache.get_or_store(:tally, key, fn ->
        %ConCache.Item{value: 0, ttl: ttl(limit, duration)}
      end)

      limit_headers = %{
        "x-ratelimit-limit" => to_string(limit),
        "x-ratelimit-period" => Atom.to_string(duration),
        "x-ratelimit-remaining" => to_string(max(limit - used, 0))
      }
      conn = conn |> Plug.Conn.merge_resp_headers(limit_headers)
      IO.inspect(limit_headers)

      if used >= limit do
        conn = conn |> Plug.Conn.send_resp(429, "Too many requests") |> Plug.Conn.halt
      else

        ConCache.update(:tally, key, fn old_value ->
          {:ok, min(old_value + 1, limit)}
        end)

        used = ConCache.get(:tally, key)
        conn = conn |> Plug.Conn.merge_resp_headers(%{"x-ratelimit-remaining" => to_string(max(limit - used, 0))})
      end
      conn
    end
  end
end
