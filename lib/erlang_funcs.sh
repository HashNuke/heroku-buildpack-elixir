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


function install_erlang() {
  output_section "Installing Erlang ${erlang_version}"

  if [ $erlang_changed != true ];
  then
    # Just copy the previous backup
    cp -R $erlang_build_path $erlang_path
  else
    # Because we want to remove any previous erlang install backups
    rm -rf ${erlang_build_path}

    mkdir ${erlang_path}
    tar zxf ${cache_path}/$(erlang_tarball) -C ${erlang_path} --strip-components=2

    # First install in actual path, because there are internal references to binaries
    ${erlang_path}/Install -minimal ${erlang_path}

    # Then backup up to the build path for later copying
    cp -R $erlang_path $erlang_build_path
  fi

  PATH=${erlang_path}/bin:$PATH
}
