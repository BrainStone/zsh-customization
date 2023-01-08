########################################################################################################################
# Configuration
########################################################################################################################
export ZSH_SCREENSAVER_DELAY="${ZSH_SCREENSAVER_DELAY:-300}"
export ZSH_SCREENSAVER_NEEDS_EXIT_HELP="${ZSH_SCREENSAVER_NEEDS_EXIT_HELP:-false}"

# If function screensaver:screensaver isn't defined provide a default implementation
if ! type 'screensaver:screensaver' 2>/dev/null | grep -q 'function'; then
  screensaver:screensaver() {
    cmatrix -abs
  }
fi

########################################################################################################################
# Code
########################################################################################################################

# trigger function every second
TMOUT=1

screensaver:clear_stdin() {
  # Include the termios.h library
  emulate -L zsh
  autoload -Uz tcflush
  # Flush stdin
  tcflush stdin 0
}

screensaver:invoker() {
  if is_variable_set ZSH_SCREENSAVER_NEEDS_EXIT_HELP; then
    # Start screensaver as background command
    screensaver:screensaver &
    local pid="$!"

    # Wait for key stroke
    read -sk

    # Stop program
    kill "$pid"
  else
    # Just start the screensaver
    screensaver:screensaver
  fi

  # Ensure we consider a key to be pressed (for example Ctrl+C might not update the atime)
  touch "$(tty)" &>/dev/null

  # Clear out standard input
  screensaver:clear_stdin
  # Reset prompt after program ends
  zle reset-prompt
}

TRAPALRM() {
  local last_action tty
  # The atime of the tty file descriptor is updated on every key stroke (with rare exceptions)
  # And skip if we can't determine the tty (can happen when other commands run, for autocomplete for example)
  tty="$(tty)" || return
  last_action="$(stat --format=%X "$tty" 2>/dev/null)" || return 0

  # Start the screensaver after ZSH_SCREENSAVER_DELAY seconds of inactivity
  [[ "$ZSH_SCREENSAVER_DELAY" -gt 0 && "$((EPOCHSECONDS - last_action))" -gt "$ZSH_SCREENSAVER_DELAY" ]] &&
    screensaver:invoker
}
