function rebar_tarball() {
  echo "$(rebar_version_path).tar.gz"
}


function rebar_download_file() {
  echo "rebar-${rebar_version[1]}".tar.gz
}


function download_rebar() {
  exit_if_file_present ${cache_path}/$(rebar_tarball)
  rebar_changed=true

  rm ${cache_path}/rebar-*.tar.gz
  rm $rebar_build_path
  cd ${cache_path}
  github_download "rebar/rebar", ${rebar_version[1]}
  cd -
}

function build_rebar() {
  if [ $rebar_changed = true ] || [ $erlang_changed = true ];
  then
    tar zxf $(rebar_download_file) -C ${rebar_build_path} --strip-components=1
    cd $rebar_build_path
    ./bootstrap
    cd -
  fi;
}

function install_rebar() {
  cd $rebar_build_path
  output_section "Copying rebar"
  cp rebar $platform_tools_path/
  cd -
  PATH=$platform_tools_path/bin:$PATH
}

