function rebar_tarball() {
  echo "rebar-${rebar_version[1]}".tar.gz
}


function download_rebar() {
  if [ ! -f ${cache_path}/$(rebar_tarball) ]; then
    rebar_changed=true
    output_section "Downloading rebar ${rebar_version[0]} ${rebar_version[1]}"

    rm -rf ${cache_path}/rebar-*.tar.gz
    cd ${cache_path}
    github_download "rebar" "rebar" ${rebar_version[1]}
    cd - > /dev/null
  else
    output_section "[skip] Already downloaded Rebar ${rebar_version[0]} ${rebar_version[1]}"
  fi
}


function build_rebar() {
  if [ $rebar_changed = true ] || [ $erlang_changed = true ];
  then
    rm -rf $(rebar_build_path)
    mkdir $(rebar_build_path)

    output_section "Unpacking rebar ${rebar_version[0]} ${rebar_version[1]}"
    tar zxf $cache_path/$(rebar_tarball) -C $(rebar_build_path) --strip-components=1

    output_section "Building rebar ${rebar_version[0]} ${rebar_version[1]}"
    cd $(rebar_build_path)
    chmod +x bootstrap
    ./bootstrap
    cd - > /dev/null
  fi
}


function install_rebar() {
  output_section "Copying rebar"
  cd $(rebar_build_path)
  cp rebar $(platform_tools_path)
  chmod +x $(platform_tools_path)/rebar
  cd - > /dev/null
  PATH=$(platform_tools_path):$PATH
}
