function download_elixir() {
  # If a previous download does not exist, then always re-download
  mkdir -p $(elixir_cache_path)

  if [ ${force_fetch} = true ] || [ ! -f $(elixir_cache_path)/$(elixir_download_file) ]; then
    clean_elixir_downloads
    elixir_changed=true
    local otp_version=$(otp_version ${erlang_version})

    local download_url="https://builds.hex.pm/builds/elixir/${elixir_version}-otp-${otp_version}.zip"

    output_section "Fetching Elixir ${elixir_version} for OTP ${otp_version} from ${download_url}"

    curl -s ${download_url} -o $(elixir_cache_path)/$(elixir_download_file)

    if [ $? -ne 0 ]; then
      output_section "Falling back to fetching Elixir ${elixir_version} for generic OTP version"
      local download_url="https://builds.hex.pm/builds/elixir/${elixir_version}.zip"
      curl -s ${download_url} -o $(elixir_cache_path)/$(elixir_download_file) || exit 1
    fi
  else
    output_section "Using cached Elixir ${elixir_version}"
  fi
}

function install_elixir() {
  output_section "Installing Elixir ${elixir_version} $(elixir_changed)"

  mkdir -p $(build_elixir_path)

  cd $(build_elixir_path)

  if type "unzip" &> /dev/null; then
    unzip -q $(elixir_cache_path)/$(elixir_download_file)
  else
    jar xf $(elixir_cache_path)/$(elixir_download_file)
  fi

  cd - > /dev/null

  if [ $(build_elixir_path) != $(runtime_elixir_path) ]; then
    mkdir -p $(runtime_elixir_path)
    cp -R $(build_elixir_path)/* $(runtime_elixir_path)
  fi

  chmod +x $(build_elixir_path)/bin/*
  PATH=$(build_elixir_path)/bin:${PATH}

  export LC_CTYPE=en_US.utf8
}

function elixir_download_file() {
  local otp_version=$(otp_version ${erlang_version})
  echo elixir-${elixir_version}-otp-${otp_version}.zip
}

function clean_elixir_downloads() {
  rm -rf $(elixir_cache_path)
  mkdir -p $(elixir_cache_path)
}

function restore_mix() {
  if [ -d $(mix_backup_path) ]; then
    mkdir -p $(build_mix_home_path)
    cp -pR $(mix_backup_path)/* $(build_mix_home_path)
  fi

  if [ -d $(hex_backup_path) ]; then
    mkdir -p $(build_hex_home_path)
    cp -pR $(hex_backup_path)/* $(build_hex_home_path)
  fi
}

function backup_mix() {
  # Delete the previous backups
  rm -rf $(mix_backup_path) $(hex_backup_path)

  mkdir -p $(mix_backup_path) $(hex_backup_path)

  cp -pR $(build_mix_home_path)/* $(mix_backup_path)
  cp -pR $(build_hex_home_path)/* $(hex_backup_path)

  # https://github.com/HashNuke/heroku-buildpack-elixir/issues/194
  if [ $(build_hex_home_path) != $(runtime_hex_home_path) ]; then
    mkdir -p $(runtime_hex_home_path)
    cp -pR $(build_hex_home_path)/* $(runtime_hex_home_path)
  fi

  # https://github.com/HashNuke/heroku-buildpack-elixir/issues/194
  if [ $(build_mix_home_path) != $(runtime_mix_home_path) ]; then
    mkdir -p $(runtime_mix_home_path)
    cp -pR $(build_mix_home_path)/* $(runtime_mix_home_path)
  fi
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
    clean_elixir_version_dependent_cache
  fi
}

function otp_version() {
  echo $(echo "$1" | awk 'match($0, /^[0-9][0-9]/) { print substr( $0, RSTART, RLENGTH )}')
}
