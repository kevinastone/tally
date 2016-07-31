defmodule Tally.Handler do
  use Plug.Builder

  plug Tally.Bouncer
  plug Tally.Proxy
end
