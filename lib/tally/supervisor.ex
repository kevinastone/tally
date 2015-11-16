defmodule Tally.Supervisor do
  use Supervisor

  def start_link(options) do

    Supervisor.start_link(__MODULE__, options)
  end

  def init(options) do

    config = Application.get_all_env(:tally) |> Keyword.merge(options)

    children = [
      # Define workers and child supervisors to be supervised
      worker(Tally.Server, [config]),
      worker(ConCache, [
        [
          ttl_check: Application.get_env(:con_cache, :ttl_check),
          ttl: Application.get_env(:con_cache, :ttl_check, 0)
        ],
        [name: :tally]
      ])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    supervise(children, strategy: :one_for_one)
  end
end
