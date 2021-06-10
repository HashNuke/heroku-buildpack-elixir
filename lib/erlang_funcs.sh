function erlang_tarball() {
  echo "OTP-${erlang_version}.tar.gz"
}

function download_erlang() {
  mkdir -p $(erlang_cache_path)
  erlang_package_url="$(erlang_builds_url)/$(erlang_tarball)"

  # If a previous download does not exist, then always re-download
  if [ ! -f $(erlang_cache_path)/$(erlang_tarball) ]; then
    clean_erlang_downloads

    # Set this so elixir will be force-rebuilt
    erlang_changed=true

    output_section "Fetching Erlang ${erlang_version} from ${erlang_package_url}"
    curl -s ${erlang_package_url} -o $(erlang_cache_path)/$(erlang_tarball) || exit 1
  else
    output_section "Using cached Erlang ${erlang_version}"
  fi
}

function clean_erlang_downloads() {
  rm -rf $(erlang_cache_path)
  mkdir -p $(erlang_cache_path)
}

function install_erlang() {
  output_section "Installing Erlang ${erlang_version} $(erlang_changed)"

  local tmp_path=$(mktemp -d)

  tar zxf $(erlang_cache_path)/$(erlang_tarball) -C "${tmp_path}" --strip-components=1

  rm -rf $(runtime_erlang_path)
  mkdir -p $(runtime_platform_tools_path)
  ln -s ${tmp_path} $(runtime_erlang_path)
  ${tmp_path}/Install -minimal $(runtime_erlang_path)

  # remove symlink so we can copy into the BUILD_DIR without symlinks
  rm $(runtime_erlang_path)
  mkdir -p $(runtime_erlang_path)
  cp -R ${tmp_path}/* $(runtime_erlang_path)

  # only copy if using old build system;
  # newer versions of the build system run builds with BUILD_PATH=/app
  # https://github.com/HashNuke/heroku-buildpack-elixir/issues/194#issuecomment-800425532
  if [ $(build_erlang_path) != $(runtime_erlang_path) ]; then
    mkdir -p $(build_erlang_path)
    cp -R $(runtime_erlang_path)/* $(build_erlang_path)
  fi

  PATH=$(runtime_erlang_path)/bin:$PATH
}

function erlang_changed() {
  if [ $erlang_changed = true ]; then
    echo "(changed)"
  fi
}
