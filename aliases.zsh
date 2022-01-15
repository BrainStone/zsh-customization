# Just some useful aliases I picked up over the years.
# Pretty sure this list will grow and grow!

# Helper stuff
check_sudo() {
  # We are root, no need to check.
  [ "$EUID" -eq 0 ] && return 0

  local prompt
  prompt=$(sudo -nv 2>&1)
  if [ $? -eq 0 ]; then
    return 0 # Has sudo permissions and password entered recently
  elif echo $prompt | grep -q '^sudo:'; then
    return 0 # Has sudo permissions but needs password
  else
    return 1 # No sudo permissions whatsoever
  fi
}

# Selfupdate!
if [[ "$ZSH_INSTALL_GLOBALLY" == "true" ]] && check_sudo; then
  alias update-zsh-theme='sudo HOME="$HOME" sh "${ZSH_CUSTOMIZATION_BASE}/install.sh" --skip-restart; exec zsh'
else
  alias update-zsh-theme='sh "${ZSH_CUSTOMIZATION_BASE}/install.sh" --skip-restart; exec zsh'
fi

# Generic stuff
alias ,='sudo -i'
alias ll='ls -lAh'
alias sudo='sudo ' # This preserves aliases through sudo!

# git stuff
alias newbranch='git checkout -b'

# systemd stuff
alias jc='journalctl'
alias sc='systemctl'
