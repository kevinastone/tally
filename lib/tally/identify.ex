defmodule Tally.Identify do

  use Behaviour

  @type identity :: binary

  @doc """
  Initializes the store.
  The options returned from this function will be given
  to `get/3`, `put/4` and `delete/3`.
  """
  defcallback init(Plug.opts) :: Plug.opts

  defcallback identify(Plug.Conn.t, Plug.opts) :: {:ok, Plug.Conn.t, identity} | {:next, Plug.Conn.t} | {:fail, Plug.Conn.t}
end
