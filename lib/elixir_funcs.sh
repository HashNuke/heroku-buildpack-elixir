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

  if [ $git_version = true ];
  then
    output_section "Downloading source from Github"
    github_download "elixir-lang/elixir", ${elixir_version[1]}
    
  else
    output_section "Downloading precompiled binary from Github"
    local download_filename="elixir-${elixir_version}-precompiled.zip"
    exit_if_file_exists ${cache_path}/${download_filename}
    local elixir_download_url="https://github.com/elixir-lang/elixir/releases/download/v${elixir_version}/Precompiled.zip"
    curl -JksL $elixir_download_url -o $download_filename || exit 1
  fi
}