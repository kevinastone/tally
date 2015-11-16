defmodule Tally.Identify.BearerToken do

  @behaviour Tally.Identify

  def init(opts \\ []) do
    Keyword.get(opts, :header, "authorization")
  end

  def identify(conn, header_name) do
    header = List.first(Plug.Conn.get_req_header(conn, header_name))
    case header do
      "Bearer " <> authorization -> {:ok, conn, authorization}
      _ -> {:fail, conn}
    end
  end
end
