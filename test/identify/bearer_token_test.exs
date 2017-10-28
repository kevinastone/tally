defmodule Tally.Identify.BearerTokenTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Tally.Identify.BearerToken

  @header_name "authorization"

  test "Extracts Bearer Token" do
    {:ok, _, identity} = conn(:get, "/hello")
    |> put_req_header(@header_name, "Bearer abcd")
    |> BearerToken.identify(@header_name)

    assert identity == "abcd"
  end

  test "Error on Invalid Authorization Header" do
    {:fail, _} =  conn(:get, "/hello")
    |> put_req_header(@header_name, "abcd")
    |> BearerToken.identify(@header_name)
  end

  test "Failure without Bearer Token" do
    {:fail, _} =  conn(:get, "/hello")
    |> BearerToken.identify(@header_name)
  end
end
