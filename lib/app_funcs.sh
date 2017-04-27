function restore_app() {
  if [ -d $(deps_backup_path) ]; then
    cp -pR $(deps_backup_path) ${build_path}/deps
  fi

  if [ $erlang_changed != true ] && [ $elixir_changed != true ]; then
    if [ -d $(build_backup_path) ]; then
      cp -pR $(build_backup_path) ${build_path}/_build
    fi
  fi
}


function copy_hex() {
  mkdir -p ${build_path}/.mix/archives
  mkdir -p ${build_path}/.hex


  # hex is a directory from elixir-1.3.0
  full_hex_file_path=$(ls -dt ${HOME}/.mix/archives/hex-* | head -n 1)

  # hex file names after elixir-1.1 in the hex-<version>.ez form
  if [ -z "$full_hex_file_path" ]; then
    full_hex_file_path=$(ls -t ${HOME}/.mix/archives/hex-*.ez | head -n 1)
  fi

  # For older versions of hex which have no version name in file
  if [ -z "$full_hex_file_path" ]; then
    full_hex_file_path=${HOME}/.mix/archives/hex.ez
  fi

  cp -R ${HOME}/.hex/ ${build_path}/.hex/

  output_section "Copying hex from $full_hex_file_path"
  cp -R $full_hex_file_path ${build_path}/.mix/archives
}


function app_dependencies() {
  # Unset this var so that if the parent dir is a git repo, it isn't detected
  # And all git operations are performed on the respective repos
  local git_dir_value=$GIT_DIR
  unset GIT_DIR

  cd $build_path
  output_section "Fetching app dependencies with mix"
  mix deps.get --only $MIX_ENV || exit 1

  export GIT_DIR=$git_dir_value
  cd - > /dev/null
}


function backup_app() {
  # Delete the previous backups
  rm -rf $(deps_backup_path) $(build_backup_path)

  cp -pR ${build_path}/deps $(deps_backup_path)
  cp -pR ${build_path}/_build $(build_backup_path)
}


function compile_app() {
  local git_dir_value=$GIT_DIR
  unset GIT_DIR

  cd $build_path
  output_section "Compiling"
  mix compile --force || exit 1

  mix deps.clean --unused

  export GIT_DIR=$git_dir_value
  cd - > /dev/null
}

function post_compile_hook() {
  cd $build_path

  if [ -n "$post_compile" ]; then
    output_section "Executing post compile: $post_compile"
    $post_compile || exit 1
  fi

  cd - > /dev/null
}

function pre_compile_hook() {
  cd $build_path

  if [ -n "$pre_compile" ]; then
    output_section "Executing pre compile: $pre_compile"
    $pre_compile || exit 1
  fi

  cd - > /dev/null
}

function write_profile_d_script() {
  output_section "Creating .profile.d with env vars"
  mkdir -p $build_path/.profile.d

  local export_line="export PATH=\$HOME/.platform_tools:\$HOME/.platform_tools/erlang/bin:\$HOME/.platform_tools/elixir/bin:\$PATH
                     export LC_CTYPE=en_US.utf8
                     export MIX_ENV=${MIX_ENV}"

  echo $export_line >> $build_path/.profile.d/elixir_buildpack_paths.sh
}

function write_export() {
  output_section "Writing export for multi-buildpack support"

  local export_line="export PATH=$(platform_tools_path):$(erlang_path)/bin:$(elixir_path)/bin:$PATH
                     export LC_CTYPE=en_US.utf8
                     export MIX_ENV=${MIX_ENV}"

  echo $export_line > $build_pack_path/export
}
