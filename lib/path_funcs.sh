function platform_tools_path() {
  echo "${build_path}/.platform_tools"
}

function erlang_path() {
  echo "$(platform_tools_path)/erlang"
}

function runtime_platform_tools_path() {
  echo "${runtime_path}/.platform_tools"
}

function runtime_erlang_path() {
  echo "$(runtime_platform_tools_path)/erlang"
}

function elixir_path() {
  echo "$(platform_tools_path)/elixir"
}

function erlang_build_path() {
  if [ -z "$tmp_erlang_build_dir" ]; then
    global tmp_erlang_build_dir=$(mktemp -d)
  fi
  echo "${tmp_erlang_build_dir}/erlang"
}

function deps_backup_path() {
  echo $cache_path/deps_backup
}

function build_backup_path() {
  echo $cache_path/build_backup
}

function mix_backup_path() {
  echo $cache_path/.mix
}

function hex_backup_path() {
  echo $cache_path/.hex
}
