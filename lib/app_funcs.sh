function restore_app() {
  if [ -d $(deps_backup_path) ]; then
    mkdir -p ${build_path}/deps
    cp -pR $(deps_backup_path)/* ${build_path}/deps
  fi

  if [ $erlang_changed != true ] && [ $elixir_changed != true ]; then
    if [ -d $(build_backup_path) ]; then
      mkdir -p ${build_path}/_build
      cp -pR $(build_backup_path)/* ${build_path}/_build
    fi
  fi
}


function copy_hex() {
  mkdir -p $(runtime_hex_home_path)

  # copying hex is only necessary on the old build system.
  # If the build_hex_home_path is the same as runtime_hex_home_path
  # (which is specifified by the buildpack consumer in their elixir_buildpack.config),
  # then we don't need to copy (and doing so will result in an error)
  # https://github.com/HashNuke/heroku-buildpack-elixir/issues/194
  if [ $(build_hex_home_path) != $(runtime_hex_home_path) ]; then
    output_section "Copying hex from $(build_hex_home_path)"
    cp -R $(build_hex_home_path)/* "$(runtime_hex_home_path)/"
  fi
}

function hook_pre_app_dependencies() {
  cd $build_path

  if [ -n "$hook_pre_fetch_dependencies" ]; then
    output_section "Executing hook before fetching app dependencies: $hook_pre_fetch_dependencies"
    $hook_pre_fetch_dependencies || exit 1
  fi

  cd - > /dev/null
}

function hook_pre_compile() {
  cd $build_path

  if [ -n "$hook_pre_compile" ]; then
    output_section "Executing hook before compile: $hook_pre_compile"
    $hook_pre_compile || exit 1
  fi

  cd - > /dev/null
}

function hook_post_compile() {
  cd $build_path

  if [ -n "$hook_post_compile" ]; then
    output_section "Executing hook after compile: $hook_post_compile"
    $hook_post_compile || exit 1
  fi

  cd - > /dev/null
}

function app_dependencies() {
  mkdir -p "$(build_mix_home_path)"

  cd $build_path
  output_section "Fetching app dependencies with mix"

  # Unset this var so that if the parent dir is a git repo, it isn't detected
  # And all git operations are performed on the respective repos
  env \
    -u GIT_DIR \
    mix deps.get --only $MIX_ENV || exit 1

  cd - > /dev/null
}


function backup_app() {
  # Delete the previous backups
  rm -rf $(deps_backup_path) $(build_backup_path)

  mkdir -p $(deps_backup_path) $(build_backup_path)
  cp -pR ${build_path}/deps/* $(deps_backup_path)
  cp -pR ${build_path}/_build/* $(build_backup_path)
}


function compile_app() {
  local git_dir_value=$GIT_DIR
  unset GIT_DIR

  cd $build_path
  output_section "Compiling"

  if [ -n "$hook_compile" ]; then
     output_section "(using custom compile command)"
     $hook_compile || exit 1
  else
     mix compile --force || exit 1
  fi

  mix deps.clean --unused

  export GIT_DIR=$git_dir_value
  cd - > /dev/null
}

function release_app() {
  cd $build_path

  if [ $release = true ]; then
    output_section "Building release"
    mix release --overwrite
  fi

  cd - > /dev/null
}

function post_compile_hook() {
  cd $build_path

  if [ -n "$post_compile" ]; then
    output_section "Executing DEPRECATED post compile: $post_compile"
    $post_compile || exit 1
  fi

  cd - > /dev/null
}

function pre_compile_hook() {
  cd $build_path

  if [ -n "$pre_compile" ]; then
    output_section "Executing DEPRECATED pre compile: $pre_compile"
    $pre_compile || exit 1
  fi

  cd - > /dev/null
}

function export_var() {
  local VAR_NAME=$1
  local VAR_VALUE=$2

  echo "export ${VAR_NAME}=${VAR_VALUE}"
}

function export_default_var() {
  local VAR_NAME=$1
  local DEFAULT_VALUE=$2

  if [ ! -f "${env_path}/${VAR_NAME}" ]; then
    export_var "${VAR_NAME}" "${DEFAULT_VALUE}"
  fi
}

function echo_profile_env_vars() {
  local buildpack_bin="$(runtime_platform_tools_path)"
  buildpack_bin="$(runtime_erlang_path)/bin:${buildpack_bin}"
  buildpack_bin="$(runtime_elixir_path)/bin:${buildpack_bin}"


  export_var "PATH" "${buildpack_bin}:\$PATH"
  export_default_var "LC_CTYPE" "en_US.utf8"

  # Only write MIX_* to profile if the application did not set MIX_*
  export_default_var "MIX_ENV" "${MIX_ENV}"
  export_default_var "MIX_HOME" "$(runtime_mix_home_path)"
  export_default_var "HEX_HOME" "$(runtime_hex_home_path)"
}

function echo_export_env_vars() {
  local buildpack_bin="$(build_platform_tools_path)"
  buildpack_bin="$(build_erlang_path)/bin:${buildpack_bin}"
  buildpack_bin="$(build_elixir_path)/bin:${buildpack_bin}"


  export_var "PATH" "${buildpack_bin}:\$PATH"
  export_default_var "LC_CTYPE" "en_US.utf8"

  # Only write MIX_* to profile if the application did not set MIX_*
  export_default_var "MIX_ENV" "${MIX_ENV}"
  export_default_var "MIX_HOME" "$(build_mix_home_path)"
  export_default_var "HEX_HOME" "$(build_hex_home_path)"
}

function write_profile_d_script() {
  output_section "Creating .profile.d with env vars"
  mkdir -p $build_path/.profile.d
  local profile_path="${build_path}/.profile.d/elixir_buildpack_paths.sh"

  echo_profile_env_vars >> $profile_path
}

function write_export() {
  output_section "Writing export for multi-buildpack support"

  echo_export_env_vars >> "${build_pack_path}/export"
}
