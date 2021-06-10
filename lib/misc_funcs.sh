# Outputs log line
#
# Usage:
#
#     output_line "Cloning repository"
#
function output_line() {
  local spacing="      "
  echo "${spacing} $1"
}

# Outputs section heading
#
# Usage:
#
#     output_section "Application tasks"
#
function output_section() {
  local indentation="----->"
  echo "${indentation} $1"
}

function output_warning() {
  local spacing="      "
  echo -e "${spacing} \e[31m$1\e[0m"
}

function output_stderr() {
  # Outputs to stderr in case it is inside a function so it does not
  # disturb the return value. Useful for debugging.
  echo "$@" 1>&2;
}


function assert_elixir_version_set() {
  custom_config_file=$1

  # 0 when found
  # 1 when not found
  # 2 when file does not exist
  grep -q -e "^elixir_version=" $custom_config_file 2>/dev/null

  if [ $? -ne 0 ]; then
    # For now, just print a warning. In the future, we will fail and require an explicit
    # elixir_version to be set.
    output_line ""
    output_warning "IMPORTANT: The default elixir_version will be removed on 2021-06-01. Please explicitly set an elixir_version in your elixir_buildpack.config before then or your deploys will fail."
    output_line ""
  fi
}

function load_config() {
  output_section "Checking Erlang and Elixir versions"

  local custom_config_file="${build_path}/elixir_buildpack.config"

  # Source for default versions file from buildpack first
  source "${build_pack_path}/elixir_buildpack.config"

  if [ -f $custom_config_file ];
  then
    source $custom_config_file
  else
    output_line "WARNING: elixir_buildpack.config wasn't found in the app"
    output_line "Using default config from Elixir buildpack"
  fi

  assert_elixir_version_set $custom_config_file
  fix_erlang_version
  fix_elixir_version

  output_line "Will use the following versions:"
  output_line "* Stack ${STACK}"
  output_line "* Erlang ${erlang_version}"
  output_line "* Elixir ${elixir_version[0]} ${elixir_version[1]}"
}


function export_env_vars() {
  whitelist_regex=${2:-''}
  blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH)$'}
  if [ -d "$env_path" ]; then
    output_section "Will export the following config vars:"
    for e in $(ls $env_path); do
      echo "$e" | grep -E "$whitelist_regex" | grep -vE "$blacklist_regex" &&
      export "$e=$(cat $env_path/$e)"
      :
    done
  fi
}

function export_mix_env() {
  if [ -z "$MIX_ENV" ]; then
    if [ -d $env_path ] && [ -f $env_path/MIX_ENV ]; then
      export MIX_ENV=$(cat $env_path/MIX_ENV)
    else
      export MIX_ENV=${1:-prod}
    fi
  fi

  output_line "* MIX_ENV=${MIX_ENV}"
}

function check_stack() {
  if [ "${STACK}" = "cedar" ]; then
    echo "ERROR: cedar stack is not supported, upgrade to cedar-14"
    exit 1
  fi

  if [ ! -f "${cache_path}/stack" ] || [ $(cat "${cache_path}/stack") != "${STACK}" ]; then
    output_section "Stack changed, will rebuild"
    $(clear_cached_files)
  fi

  echo "${STACK}" > "${cache_path}/stack"
}

# remove any cache files that are not under the stack-based
# cache directory specified by the `stack_based_cache_path`
# function
function clean_old_cache_files() {
  rm -rf \
    $(erlang_build_path) \
    ${cache_path}/deps_backup \
    ${cache_path}/build_backup \
    ${cache_path}/.mix \
    ${cache_path}/.hex
  rm -rf ${cache_path}/OTP-*.zip
  rm -rf ${cache_path}/elixir*.zip
}

function clean_cache() {
  clean_old_cache_files

  if [ $always_rebuild = true ]; then
    output_section "Cleaning all cache to force rebuilds"
    $(clear_cached_files)
  fi
}

function clear_cached_files() {
  rm -rf $(stack_based_cache_path)
}

function fix_erlang_version() {
  erlang_version=$(echo "$erlang_version" | sed 's/[^0-9.]*//g')
}

function fix_elixir_version() {
  # TODO: this breaks if there is an carriage return behind elixir_version=(branch master)^M
  if [ ${#elixir_version[@]} -eq 2 ] && [ ${elixir_version[0]} = "branch" ]; then
    force_fetch=true
    elixir_version=${elixir_version[1]}

  elif [ ${#elixir_version[@]} -eq 1 ]; then
    force_fetch=false

    # If we detect a version string (e.g. 1.14 or 1.14.0) we prefix it with "v"
    if [[ ${elixir_version} =~ ^[0-9]+\.[0-9]+ ]]; then
      # strip out any non-digit non-dot characters
      elixir_version=$(echo "$elixir_version" | sed 's/[^0-9.]*//g')
      elixir_version=v${elixir_version}
    fi

  else
    output_line "Invalid Elixir version specified"
    output_line "See the README for allowed formats at:"
    output_line "https://github.com/HashNuke/heroku-buildpack-elixir"
    exit 1
  fi
}
