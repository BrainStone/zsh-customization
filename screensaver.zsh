########################################################################################################################
# Configuration
########################################################################################################################
export ZSH_SCREENSAVER_DELAY="${ZSH_SCREENSAVER_DELAY:-300}"
export ZSH_SCREENSAVER_NEEDS_EXIT_HELP="${ZSH_SCREENSAVER_NEEDS_EXIT_HELP:-false}"

if ! declare -F screensaver:screensaver >/dev/null; then
  screensaver:screensaver() {
    cmatrix -abs
  }
fi

########################################################################################################################
# Code
########################################################################################################################

# trigger function every second
TMOUT=1

screensaver:invoker() {
  if is_variable_set ZSH_SCREENSAVER_NEEDS_EXIT_HELP; then
    # Start screensaver as background command
    screensaver:screensaver &
    pid=$!

    # Wait for key stroke
    read -k1 -s

    # Stop program
    kill "$pid"
  else
    # Just start the screensaver
    screensaver:screensaver
  fi

  # Reset prompt after program ends
  zle reset-prompt
}

TRAPALRM() {
  # The atime of the tty file descriptor is updated on every key stroke (with rare exceptions)
  local last_action="$(stat --format=%X "$(tty)")"

  # Start the screensaver after ZSH_SCREENSAVER_DELAY seconds of inactivity
  [[ "$ZSH_SCREENSAVER_DELAY" -gt 0 && "$((EPOCHSECONDS - last_action))" -gt "$ZSH_SCREENSAVER_DELAY" ]] &&
    screensaver:invoker
}
