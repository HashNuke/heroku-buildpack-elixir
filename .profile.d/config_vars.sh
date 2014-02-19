#!/usr/bin/env bash

export PLATFORM=heroku
export PATH=$PATH:/app/erlang/bin:/app/elixir/bin
export MIX_ENV=${MIX_ENV:-prod}
