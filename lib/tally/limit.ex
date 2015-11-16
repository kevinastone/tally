defmodule Tally.Limit do

  use Behaviour

  @type identity :: binary

  @doc """
  Initializes the store.
  The options returned from this function will be given
  to `get/3`, `put/4` and `delete/3`.
  """
  defcallback init(Plug.opts) :: Plug.opts

  defcallback limit(Plug.Conn.t, identity, Plug.opts) :: Plug.Conn.t
end
