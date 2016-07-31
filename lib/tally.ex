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
    parse_args(System.argv || []) |> run
  end

  def main(_args) do
    :timer.sleep(:infinity)
  end

  defp run({[help: true], _args}) do
    IO.puts @module_doc
    System.halt(0)
  end

  defp run({options, _args}) do
    Tally.Supervisor.start_link(options)
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

    upstreams = Enum.map(args, fn arg ->
      {"/", arg}
    end)
    {options, upstreams}
  end
end
