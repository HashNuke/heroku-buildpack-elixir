function download_erlang() {
  local erlang_package_url="https://s3.amazonaws.com/heroku-buildpack-erlang/${erlang_tarball}"

  exit_if_file_present ${cache_path}/${erlang_tarball}

  # Delete previously downloaded OTP tar files
  rm -rf ${cache_path}/OTP_*.tgz

  cd ${cache_path}
  output_section "Fetching Erlang ${erlang_version}"
  curl -ksO ${erlang_package_url} -o ${erlang_tarball} || exit 1
}


function install_erlang() {
  output_section "Unpacking Erlang ${erlang_version}"
  tar zxf ${cache_path}/${erlang_tarball} -C ${erlang_path} --strip-components=2

  output_section "Installing Erlang ${erlang_version}"
  # ln -s ${erlang_path} /app/erlang
  ${erlang_path}/Install -minimal /app/.platform_tools/erlang
  PATH=/app/.platform_tools/erlang/bin:$PATH
}