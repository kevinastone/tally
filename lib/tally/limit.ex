defmodule Tally.Limit do

  @type identity :: binary

  @doc """
  Initializes the store.
  The options returned from this function will be given
  to `get/3`, `put/4` and `delete/3`.
  """
  @callback init(Plug.opts) :: Plug.opts

  @callback limit(Plug.Conn.t, identity, Plug.opts) :: Plug.Conn.t
end
