defmodule Tally.Server do
  @default_config [port: 4001, host: "localhost"]

  def start_link, do: start([])

  def start_link(config) do
    start(config)
  end

  def start(config) do
    config =
      @default_config
      |> Keyword.merge(config)

    host = Keyword.get(config, :host)
    port = Keyword.get(config, :port)
    upstreams = Keyword.get(config, :upstreams, [])
    ip = case host do
      "localhost" -> {127, 0, 0, 1}
      host ->
        case :inet.parse_address(to_charlist host) do
          {:ok, ip} -> ip
        end
    end

    IO.puts "Running Tally with Cowboy on http://#{host}:#{port}"
    Plug.Adapters.Cowboy.http Tally.Router, upstreams, ip: ip, port: port
  end
end
