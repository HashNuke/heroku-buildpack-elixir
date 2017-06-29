function download_elixir() {
  fix_elixir_version

  # If a previous download does not exist, then always re-download
  if [ ${force_fetch} = true ] || [ ! -f ${cache_path}/$(elixir_download_file) ]; then
    clean_elixir_downloads
    elixir_changed=true
    local otp_version=$(otp_version ${erlang_version})

    output_section "Fetching Elixir ${elixir_version} for OTP ${otp_version}"

    local download_url="https://repo.hex.pm/builds/elixir/${elixir_version}-otp-${otp_version}.zip"
    curl -s ${download_url} -o ${cache_path}/$(elixir_download_file)

    if [ $? -ne 0 ]; then
      output_section "Falling back to fetching Elixir ${elixir_version} for generic OTP version"
      local download_url="https://repo.hex.pm/builds/elixir/${elixir_version}.zip"
      curl -s ${download_url} -o ${cache_path}/$(elixir_download_file) || exit 1
    fi
  else
    output_section "Using cached Elixir ${elixir_version}"
  fi
}

function install_elixir() {
  output_section "Installing Elixir ${elixir_version} $(elixir_changed)"

  mkdir -p $(elixir_path)
  cd $(elixir_path)

  if type "unzip" &> /dev/null; then
    unzip -q ${cache_path}/$(elixir_download_file)
  else
    jar xf ${cache_path}/$(elixir_download_file)
  fi

  cd - > /dev/null

  chmod +x $(elixir_path)/bin/*
  PATH=$(elixir_path)/bin:${PATH}

  export LC_CTYPE=en_US.utf8
}

function fix_elixir_version() {
  if [ ${#elixir_version[@]} -eq 2 ] && [ ${elixir_version[0]} = "branch" ]; then
    force_fetch=true
    elixir_version=${elixir_version[1]}

  elif [ ${#elixir_version[@]} -eq 1 ]; then
    force_fetch=false

    # If we detect a version string (e.g. 1.14 or 1.14.0) we prefix it with "v"
    if [[ ${elixir_version} =~ ^[0-9]+\.[0-9]+ ]]; then
      elixir_version=v${elixir_version}
    fi

  else
    output_line "Invalid Elixir version specified"
    output_line "See the README for allowed formats at:"
    output_line "https://github.com/HashNuke/heroku-buildpack-elixir"
    exit 1
  fi
}

function elixir_download_file() {
  echo elixir-${elixir_version}.zip
}

function clean_elixir_downloads() {
  rm -rf ${cache_path}/elixir*.zip
}

function restore_mix() {
  if [ -d $(mix_backup_path) ]; then
    cp -pR $(mix_backup_path) ${HOME}/.mix
  fi

  if [ -d $(hex_backup_path) ]; then
    cp -pR $(hex_backup_path) ${HOME}/.hex
  fi
}

function backup_mix() {
  # Delete the previous backups
  rm -rf $(mix_backup_path) $(hex_backup_path)

  cp -pR ${HOME}/.mix $(mix_backup_path)
  cp -pR ${HOME}/.hex $(hex_backup_path)
}

function install_hex() {
  output_section "Installing Hex"
  mix local.hex --force
}

function install_rebar() {
  output_section "Installing rebar"

  mix local.rebar --force
}

function elixir_changed() {
  if [ $elixir_changed = true ]; then
    echo "(changed)"
  fi
}

function otp_version() {
  echo $(echo "$1" | awk 'match($0, /^[0-9][0-9]/) { print substr( $0, RSTART, RLENGTH )}')
}
