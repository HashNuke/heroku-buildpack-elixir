function rebar_tarball() {
  echo "rebar-${rebar_version[1]}".tar.gz
}


function download_rebar() {
  exit_if_file_exists ${cache_path}/$(rebar_tarball)
  rebar_changed=true
  output_section "Downloading rebar ${rebar_version[0]} ${rebar_version[1]}"

  rm -rf ${cache_path}/rebar-*.tar.gz
  cd ${cache_path}
  echo "Actually starting to download..."
  github_download "rebar" "rebar" ${rebar_version[1]}
  echo "Downloaded"
  cd - > /dev/null
}


function build_rebar() {
  if [ $rebar_changed = true ] || [ $erlang_changed = true ];
  then
    rm -rf $rebar_build_path
    mkdir $rebar_build_path

    output_section "Unpacking rebar ${rebar_version[0]} ${rebar_version[1]}"
    tar zxf $(rebar_tarball) -C ${rebar_build_path} --strip-components=1

    output_section "Building rebar ${rebar_version[0]} ${rebar_version[1]}"
    cd $rebar_build_path
    chmod +x bootstrap
    ./bootstrap
    cd - > /dev/null
  fi;
}


function install_rebar() {
  output_section "Copying rebar"
  cd $rebar_build_path
  cp rebar $platform_tools_path/
  cd - > /dev/null
  PATH=$platform_tools_path/bin:$PATH
}
