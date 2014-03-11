function rebar_tarball() {
  "$(rebar_version_path).tar.gz"
}


function rebar_version_path() {
  "rebar-${rebar_version[1]}"
}


function download_rebar() {
  exit_if_file_present ${cache_path}/$(rebar_tarball)
  cd ${cache_path}
  github_download "rebar/rebar", ${rebar_version[1]}
}


function install_rebar() {
  cd ${cache_path}/$(rebar_version_path)
  cp rebar $platform_tools_path/
}


function build_rebar() {
  #TODO check if it's already been built by matching versions
  cd ${cache_path}/$(rebar_version_path)
  ./bootstrap
}
