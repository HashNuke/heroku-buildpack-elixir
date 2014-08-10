function erlang_tarball() {
  if [ ${#erlang_version[@]} -eq 2 ];
  then
    echo "OTP_${erlang_version[1]}.tgz"
  else
    echo "OTP_${erlang_version}.tgz"
  fi
}


function erlang_download_file_prefix() {
  if [ ${erlang_version:0:1} == "R" ]; then
    echo "OTP_"
  else
    echo "OTP-"
  fi;
}


function erlang_remote_filename() {
  if [ ${#erlang_version[@]} -eq 2 ];
  then
    echo "${erlang_version[1]}.tgz"
  else
    echo "$(erlang_download_file_prefix)${erlang_version}.tgz"
  fi
}


function download_erlang() {
  local erlang_package_url="https://s3.amazonaws.com/heroku-buildpack-erlang/$(erlang_remote_filename)"

  # If set to always rebuild or
  # if a previous download does not exist, then always re-download
  if [ $always_rebuild = true ] || [ ! -f ${cache_path}/$(erlang_tarball) ]; then
    output_line "Downloading Erlang package"
    clean_erlang_downloads

    # Set this so that rebar and elixir will be force-rebuilt
    erlang_changed=true

    cd ${cache_path}
    output_section "Fetching Erlang ${erlang_version[0]} ${erlang_version[1]}"
    curl -ks ${erlang_package_url} -o $(erlang_tarball) || exit 1
    cd - > /dev/null
  else
    output_section "[skip] Already downloaded Erlang ${erlang_version[0]} ${erlang_version[1]}"
  fi
}


function clean_erlang_downloads() {
  rm -rf ${cache_path}/OTP_*.tgz
}


function install_erlang() {
  output_section "Installing Erlang ${erlang_version}"

  rm -rf $(erlang_build_path)
  mkdir -p $(erlang_build_path)
  tar zxf ${cache_path}/$(erlang_tarball) -C $(erlang_build_path) --strip-components=2

  mkdir -p /app/.platform_tools
  ln -s $(erlang_build_path) /app/.platform_tools/erlang
  $(erlang_build_path)/Install -minimal /app/.platform_tools/erlang

  cp -R $(erlang_build_path) $(erlang_path)
  PATH=$(erlang_path)/bin:$PATH
}
