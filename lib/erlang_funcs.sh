function erlang_tarball() {
  echo "OTP_${erlang_version}.tgz"
}


function download_erlang() {
  local erlang_package_url="https://s3.amazonaws.com/heroku-buildpack-erlang/$(erlang_tarball)"

  exit_if_file_exists ${cache_path}/$(erlang_tarball)

  # Set this so that rebar and elixir will be force-rebuilt
  erlang_changed=true

  # Delete previously downloaded OTP tar files
  rm -rf ${cache_path}/OTP_*.tgz

  cd ${cache_path}
  output_section "Fetching Erlang ${erlang_version}"
  curl -ksO ${erlang_package_url} -o $(erlang_tarball) || exit 1
  cd - > /dev/null
}


function build_erlang() {
  if [ $erlang_changed != true ];
  then
    exit 0
  fi

  output_section "Unpacking Erlang ${erlang_version}"

  # Because we want to remove any previous erlang install
  rm -rf ${erlang_source_path} ${erlang_build_path}

  mkdir ${erlang_source_path} ${erlang_build_path}
  tar zxf ${cache_path}/$(erlang_tarball) -C ${erlang_source_path} --strip-components=2

  output_section "Installing Erlang ${erlang_version}"
  ${erlang_source_path}/Install -minimal ${erlang_build_path}
}


function install_erlang() {
  cp -R $erlang_build_path $erlang_path
  PATH=${erlang_path}/bin:$PATH
}