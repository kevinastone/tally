defmodule Tally.Auth do

  alias Plug.Conn
  use Behaviour

  @doc """
  Attempts to extract authentication from the conn. Returns:
    * `{:ok, conn, identity}` if the Auth is able to handle the given content-type
    * `{:next, conn}` if the next Auth should be invoked
  """
  defcallback parse(Conn.t, type :: binary, subtype :: binary,
                    headers :: Keyword.t, opts :: Keyword.t) ::
                    {:ok, Conn.params, Conn.t} |
                    {:error, :too_large, Conn.t} |
                    {:next, Conn.t}
end
