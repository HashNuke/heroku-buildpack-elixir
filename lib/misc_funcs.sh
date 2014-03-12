# Runs stuff in a wrapper. If exit code is not zero, it exits
#
# Usage:
#     function greet() {
#       echo "Hello $1"
#     }
#     try_run "greet Akash"
function try_run() {
  (eval $1)
  local cmd_result=$?
  if [[ $cmd_result != 0 ]] ; then
      echo "Exiting"
      exit $cmd_result
  fi
}


# Will exit if the file is present
#
# Usage:
#
#     exit_if_present path/to/file
#
function exit_if_file_exists() {
  test -f $1 && exit 0
}


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


function ensure_erlang_path() {
  mkdir -p $erlang_path
}


# Gets the version, mentioned in the config for the tool
#
# Usage:
#
#     get_version "elixir"
#     get_version "erlang"
#
function get_version() {
  local version_var_name="$1_version"
  echo ${!version_var_name}
}


# Download archive of branch, tag or commit of a project from Github
#
# Usage:
#
#     github_download "elixir-lang" "elixir" "master"
#
function github_download() {
  # We don't use the -J option because curl on Heroku is really old.
  # So we pass a filename ourselves.
  curl -k -s -L "https://github.com/$1/$2/archive/$3.tar.gz" -o "${cache_path}/$2-$3.tar.gz" || exit 1
}


function infer_versions() {
  output_section "Checking Erlang, Elixir and Rebar versions"

  local custom_language_versions_file="${build_path}/.language_versions"

  # Source for default versions file from buildpack first
  source "${build_pack_path}/.language_versions"

  if [ -f $custom_language_versions_file ];
  then
    source $custom_language_versions_file
  else
    output_line "WARNING: .language_versions wasn't found"
    output_line "Using default language versions from Elixir buildpack"
  fi

  output_line "Will use the following versions:"
  output_line "* Erlang ${erlang_version}"
  output_line "* Elixir ${elixir_version[0]} ${elixir_version[1]}"
  output_line "* Rebar ${rebar_version[0]} ${rebar_version[1]}"
}
