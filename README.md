# Tally

[![Build Status](https://travis-ci.org/kevinastone/tally.svg?branch=master)](https://travis-ci.org/kevinastone/tally)

HTTP Proxy for enforcing Rate Limiting.  Acts as an HTTP middleware for
enforcing client rate limits.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add tally to your list of dependencies in `mix.exs`:

        def deps do
          [{:tally, "~> 0.0.1"}]
        end

  2. Ensure tally is started before your application:

        def application do
          [applications: [:tally]]
        end
