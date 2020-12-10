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

function generate_tmp_erlang_build_dir() {
  # Do not call this in a subshell e.g. $(generate_tmp_erlang_build_dir)
  tmp_erlang_build_dir="$(mktemp -d)"
}

# We just go head and call it here before erlang_build_path is even defined so we should be good
generate_tmp_erlang_build_dir

function erlang_build_path() {
  if [ -z "$tmp_erlang_build_dir" ]; then
    # We have to generate this tmp folder outside this function because this function is often called
    # in a subshell. If we generate the tmp folder inside the subshell, we can not remember the folder
    # name in the parent shell and subsequent calls to this function will return a different folder.
    # See https://stackoverflow.com/questions/23564995/how-to-modify-a-global-variable-within-a-function-in-bash
    output_warning "You must call generate_tmp_erlang_build_dir before calling erlang_build_path"
    exit 1
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
