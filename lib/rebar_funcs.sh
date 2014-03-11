function rebar_tarball() {
  echo "$(rebar_version_path).tar.gz"
}


function rebar_download_file() {
  echo "rebar-${rebar_version[1]}"
}


function download_rebar() {
  exit_if_file_present ${cache_path}/$(rebar_tarball)
  rm ${cache_path}/$(rebar_tarball)
  rm $rebar_path
  cd ${cache_path}
  github_download "rebar/rebar", ${rebar_version[1]}
  cd -
}


function install_rebar() {
  cd ${cache_path}/$(rebar_download_file)
  cp rebar $platform_tools_path/
  cd -
  PATH=$platform_tools_path/bin:$PATH
}


function build_rebar() {
  #TODO check if it's already been built by matching versions
  cd ${cache_path}/$(rebar_download_file)
  ./bootstrap
  cd -
}
