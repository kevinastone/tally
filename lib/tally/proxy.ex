defmodule Tally.Proxy do
  use Plug.Builder

  plug Tally.Bouncer
  plug :proxy

  def call(conn, upstream) do
    conn
    |> Plug.Conn.put_private(:tally_upstream, upstream)
    |> super(upstream)
  end

  def proxy(%Plug.Conn{private: %{tally_upstream: upstream}} = conn, _opts) do
    case :hackney.request(conn.method, uri(conn, upstream), conn.req_headers, :stream, []) do
      {:ok, client} -> conn |> proxy_client(client)
      {:error, reason} -> conn |> proxy_error(reason)
    end
  end

  defp proxy_error(conn, :connect_timeout) do
    conn |> send_resp(504, "Connect timeout") |> halt
  end

  defp proxy_error(conn, reason) do
    conn |> send_resp(503, Atom.to_string(reason)) |> halt
  end

  defp proxy_client(conn, client) do
    conn |> write_proxy(client) |> read_proxy(client)
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

  defp send_proxy_response(conn, client, status, headers) do
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

  defp error_proxy_response(conn, _client, reason) do
    conn |> send_resp(503, Atom.to_string(reason)) |> halt
  end

  # Reads the client response and sends it back.
  defp read_proxy(conn, client) do
    case :hackney.start_response(client) do
      {:ok, status, headers, client} -> send_proxy_response(conn, client, status, headers)
      {:error, reason} ->error_proxy_response(conn, client, reason)
    end
  end

  defp uri(conn, upstream) do
    base = upstream <> "/" <> Enum.join(conn.path_info, "/")
    case conn.query_string do
      "" -> base
      qs -> base <> "?" <> qs
    end
  end
end
