defmodule Tally.Proxy do
  import Plug.Conn

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, upstream) do
    {:ok, client} = :hackney.request(conn.method, uri(conn, upstream), conn.req_headers, :stream, [])

    conn
    |> write_proxy(client)
    |> read_proxy(client)
  end

  # Reads the connection body and write it to the
  # client recursively.
  defp write_proxy(conn, client) do
    # Check Plug.Conn.read_body/2 docs for maximum body value,
    # the size of each chunk, and supported timeout values.
    case read_body(conn, []) do
      {:ok, body, conn} ->
        :hackney.send_body(client, body)
        conn
      {:more, body, conn} ->
        :hackney.send_body(client, body)
        write_proxy(conn, client)
    end
  end

  # Reads the client response and sends it back.
  defp read_proxy(conn, client) do
    {:ok, status, headers, client} = :hackney.start_response(client)
    {:ok, body} = :hackney.body(client)

    # Lowercase the headers
    headers = Enum.map(headers, fn {header, value} -> {String.downcase(header), value} end)

    # Delete the transfer encoding header. Ideally, we would read
    # if it is chunked or not and act accordingly to support streaming.
    #
    # We may also need to delete other headers in a proxy.
    headers = List.keydelete(headers, "transfer-encoding", 0)

    conn
    |> merge_resp_headers(headers)
    |> send_resp(status, body)
  end

  defp uri(conn, upstream) do
    base = upstream <> "/" <> Enum.join(conn.path_info, "/")
    case conn.query_string do
      "" -> base
      qs -> base <> "?" <> qs
    end
  end
end
