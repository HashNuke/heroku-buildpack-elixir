function app_dependencies() {
  # ln -s ${elixir_path} /app/.platform_tools/elixir
  PATH=$elixir_path/bin:$PATH
  local git_dir_value=$GIT_DIR

  # Enter build dir to perform app-related actions
  cd $build_path

  # Unset this var so that if the parent dir is a git repo, it isn't detected
  # And all git operations are performed on the respective repos
  unset GIT_DIR

  output_section "Fetching app dependencies with mix"
  MIX_ENV=prod mix deps.get || exit 1

  output_section "Compiling app dependencies"
  MIX_ENV=prod mix deps.compile || exit 1

  export GIT_DIR=$git_dir_value
  cd -
}


function compile_app() {
  cd $build_path
  output_section "Compiling the app"
  MIX_ENV=prod mix compile || exit 1
  cd -
}


function write_profile_d_script() {
  output_section "Creating .profile.d with env vars"
  mkdir $build_path/.profile.d

  local export_line="export PATH=$platform_tools_path:$erlang_path/bin:${elixir_path}/bin:\$PATH"
  echo export_line >> $build_path/.profile.d/elixir_buildpack_paths.sh
}
