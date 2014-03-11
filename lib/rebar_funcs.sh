function rebar_tarball() {
  echo "rebar-${rebar_version[1]}".tar.gz
}


function download_rebar() {
  exit_if_file_present ${cache_path}/$(rebar_tarball)
  rebar_changed=true

  rm -rf ${cache_path}/rebar-*.tar.gz
  rm -rf $rebar_build_path
  cd ${cache_path}
  github_download "rebar/rebar", ${rebar_version[1]}
  cd - > /dev/null
}

function build_rebar() {
  if [ $rebar_changed = true ] || [ $erlang_changed = true ];
  then
    tar zxf $(rebar_tarball) -C ${rebar_build_path} --strip-components=1
    cd $rebar_build_path
    ./bootstrap
    cd - > /dev/null
  fi;
}

function install_rebar() {
  cd $rebar_build_path
  output_section "Copying rebar"
  cp rebar $platform_tools_path/
  cd - > /dev/null
  PATH=$platform_tools_path/bin:$PATH
}

