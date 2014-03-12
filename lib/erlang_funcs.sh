function erlang_tarball() {
  echo "OTP_${erlang_version}.tgz"
}


function download_erlang() {
  local erlang_package_url="https://s3.amazonaws.com/heroku-buildpack-erlang/$(erlang_tarball)"

  output_line "Checking if Erlang has already been downloaded..."
  exit_if_file_exists ${cache_path}/$(erlang_tarball)
  output_line "Downloading Erlang package"

  # Set this so that rebar and elixir will be force-rebuilt
  erlang_changed=true

  # Delete previously downloaded OTP tarballs
  rm -rf ${cache_path}/OTP_*.tgz

  cd ${cache_path}
  output_section "Fetching Erlang ${erlang_version}"
  curl -ksO ${erlang_package_url} -o $(erlang_tarball) || exit 1
  cd - > /dev/null
}


function install_erlang() {
  output_section "Installing Erlang ${erlang_version}"

  local absolute_erlang_path="/app/.platform_tools/erlang"
  mkdir -p $absolute_erlang_path

  tar zxf ${cache_path}/$(erlang_tarball) -C ${absolute_erlang_path} --strip-components=2
  ${absolute_erlang_path}/Install -minimal $absolute_erlang_path
  PATH=${absolute_erlang_path}/bin:$PATH
}
