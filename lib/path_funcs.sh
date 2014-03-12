function platform_tools_path() {
  echo "${build_path}/.platform_tools"
}

function erlang_path() {
  echo "$(platform_tools_path)/erlang"
}

function elixir_path()
  echo "$(platform_tools_path)/elixir"
}

function rebar_path(){
  echo "$(platform_tools_path)/rebar"
}

function erlang_build_path() {
  echo "${cache_path}/erlang"
}

function elixir_build_path() {
  echo "${cache_path}/elixir"
}

function rebar_build_path() {
  echo "${cache_path}/rebar"
}
