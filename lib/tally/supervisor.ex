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
      worker(ConCache, [[], [name: :tally]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    supervise(children, strategy: :one_for_one)
  end
end
