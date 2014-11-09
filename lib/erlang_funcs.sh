function erlang_tarball() {
  echo "OTP-${erlang_version}.tar.gz"
}


function download_erlang() {
  if [ ${STACK} = "cedar-14" ] ; then
    erlang_package_url="http://s3.hex.pm/builds/erlang/ubuntu-14.04"
  else
    erlang_package_url="http://s3.hex.pm/builds/erlang/ubuntu-10.04"
  fi

  erlang_package_url="${erlang_package_url}/$(erlang_tarball)"

  # If a previous download does not exist, then always re-download
  if [ ! -f ${cache_path}/$(erlang_tarball) ]; then
    clean_erlang_downloads

    # Set this so elixir will be force-rebuilt
    erlang_changed=true

    output_section "Fetching Erlang ${erlang_version}"
    curl -ks ${erlang_package_url} -o ${cache_path}/$(erlang_tarball) || exit 1
  else
    output_section "[skip] Already downloaded Erlang ${erlang_version}"
  fi
}


function clean_erlang_downloads() {
  rm -rf ${cache_path}/OTP-*.tar.gz
}


function install_erlang() {
  output_section "Installing Erlang ${erlang_version}"

  rm -rf $(erlang_build_path)
  mkdir -p $(erlang_build_path)
  tar zxf ${cache_path}/$(erlang_tarball) -C $(erlang_build_path) --strip-components=1

  rm -rf /app/.platform_tools/erlang
  mkdir -p /app/.platform_tools
  ln -s $(erlang_build_path) /app/.platform_tools/erlang
  $(erlang_build_path)/Install -minimal /app/.platform_tools/erlang

  cp -R $(erlang_build_path) $(erlang_path)
  PATH=$(erlang_path)/bin:$PATH
}
