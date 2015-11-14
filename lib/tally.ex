defmodule Tally do
  use Application

  @module_doc """
      Usage:
        tally --host [host] --port [port]

      Options:
        --host  Host IP Address to listen on
        --port  Port to listen on
        --help  Show this help message.
    """

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _arg) do
    {options, _args} = parse_args(System.argv || [])
    options |> run
  end

  defp run([help: true]) do
    IO.puts @module_doc
    System.halt(0)
  end

  defp run(options) do
    import Supervisor.Spec, warn: false

    config = Application.get_all_env(:tally) |> Keyword.merge(options)

    children = [
      # Define workers and child supervisors to be supervised
      worker(Tally.Server, [config]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end

  defp parse_args(args) do
    {options, args, _} = OptionParser.parse(args,
      strict: [
        port: :integer,
        host: :string,
        help: :boolean,
      ],
      aliases: [
        p: :port,
        h: :host
      ]
    )
    {options, args}
  end
end
