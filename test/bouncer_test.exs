defmodule Tally.BouncerTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Tally.Bouncer

  test "Bouncer Identity" do

    conn =
      conn(:get, "/ip")
      |> put_req_header("authorization", "Bearer abcd")
      |> Bouncer.call(nil)


  for expected_header <- [
    {"x-ratelimit-limit", "5"},
    {"x-ratelimit-period", "min"},
    {"x-ratelimit-remaining", "4"},
  ] do
      assert Enum.member?(conn.resp_headers, expected_header)
    end
  end
end
