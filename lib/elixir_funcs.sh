function download_elixir() {
  if [ ${#elixir_version[@]} -eq 1 ];
  then
    local git_version=false
  elif [ ${#elixir_version[@]} -eq 2 ];
  then
    local git_version=true
  else
    output_line "Invalid Elixir version specified"
    exit 1
  fi

  local download_filename=$(elixir_download_file)

  # If a previous download does not exist
  # or if a branch is being used, then always re-download
  if [ ! -f ${cache_path}/${download_filename} ] || [ ${elixir_version[0]} = "branch" ]; then
    elixir_changed=true

    if [ $git_version = true ]; then
      output_section "Downloading source from Github"
      clean_elixir_downloads

      github_download "elixir-lang" "elixir" ${elixir_version[1]}
    else
      output_section "Downloading precompiled binary from Github"
      clean_elixir_downloads

      local download_url="https://github.com/elixir-lang/elixir/releases/download/v${elixir_version}/Precompiled.zip"
      curl -ksL $download_url -o $cache_path/$download_filename || exit 1
    fi
  else
    output_section "[skip] Already downloaded Elixir ${elixir_version[0]} ${elixir_version[1]}"
  fi
}


function build_elixir() {
  if [ $erlang_changed = true ] || [ $elixir_changed = true ]; then
    output_section "Unpacking Elixir ${elixir_version[0]} ${elixir_version[1]}"
    rm -rf $(elixir_build_path)
    mkdir $(elixir_build_path)

    # If git version (git version specification has 2 array elements)
    if [ ${#elixir_version[@]} -eq 2 ]; then
      tar zxf $cache_path/$(elixir_download_file) -C $(elixir_build_path) --strip-components=1
      cd $(elixir_build_path)
      output_section "Building Elixir from source"
      make
      cd - > /dev/null
    else
      cd $(elixir_build_path)
      jar xf $cache_path/$(elixir_download_file)
      cd - > /dev/null
    fi
  else
    output_section "[skip] Already unpacked and built Elixir"
  fi
}


function install_elixir() {
  output_section "Installing Elixir ${elixir_version[0]} ${elixir_version[1]}"

  cp -R $(elixir_build_path) $(elixir_path)
  chmod +x $(elixir_path)/bin/*
  PATH=$(elixir_path)/bin:$PATH
}


function elixir_download_file() {
  if [ ${#elixir_version[@]} -eq 2 ];
  then
    echo elixir-${elixir_version[1]}.tar.gz
  else
    echo elixir-${elixir_version}-precompiled.zip
  fi
}


function clean_elixir_downloads() {
  rm -rf ${cache_path}/elixir*.tar.gz ${cache_path}/elixir*.zip
}