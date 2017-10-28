defmodule Tally.Identify do

  @type identity :: binary

  @doc """
  Initializes the store.
  The options returned from this function will be given
  to `get/3`, `put/4` and `delete/3`.
  """
  @callback init(Plug.opts) :: Plug.opts

  @callback identify(Plug.Conn.t, Plug.opts) :: {:ok, Plug.Conn.t, identity} | {:next, Plug.Conn.t} | {:fail, Plug.Conn.t}
end
