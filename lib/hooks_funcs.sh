# Execute a script
#
# Usage:
#
#     exec_hook "A line to print" path/to/script.sh
#
function exec_hook() {
  local exec_hook_file="${build_path}/$2"
  if [ -f $exec_hook_file ]; then
    output_section "$1"
    output_line "Running $2"
    chmod +x $exec_hook_file
    source $exec_hook_file || exit 1
  fi
}

function exec_post_erlang() {
  if [ -n "$post_erlang_hook" ]; then
    exec_hook "Post Erlang hook" $post_erlang_hook
  fi
}

function exec_post_elixir() {
  if [ -n "$post_elixir_hook" ]; then
    exec_hook "Post Elixir hook" $post_elixir_hook
  fi
}

function exec_post_app() {
  if [ -n "$post_app_hook" ]; then
    exec_hook "Post App hook" $post_app_hook
  fi
}
