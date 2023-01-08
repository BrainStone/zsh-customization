# Just some useful aliases I picked up over the years.
# Pretty sure this list will grow and grow!

# Helper stuff
check_sudo() {
  # We are root, no need to check.
  [[ "$EUID" -eq 0 ]] && return 0

  # If we don't have a sudo command, don't use it
  [[ -x "$(command -v sudo)" ]] || return 1

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

zsh-theme:branch() {
  local use_sudo=
  [[ "$ZSH_INSTALL_GLOBALLY" == "true" ]] && check_sudo && use_sudo=sudo

  if [[ $# -gt 0 ]]; then
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
      cat <<EOF
zsh-theme:branch - Set or view the current branch of the zsh-customization repository

Usage:
  zsh-theme:branch [BRANCH]
  zsh-theme:branch --unset
  zsh-theme:branch -h | --help

Options:
  -h --help  Show this help text.
  --unset    Unset the current branch.

If BRANCH is specified, sets the current branch of the zsh-customization repository to BRANCH.
If no arguments are given, displays the current branch.
EOF
      return 0
    elif [[ "$1" == "--unset" ]]; then
      $use_sudo git -C "${ZSH_CUSTOMIZATION_BASE}" config --local --unset-all zsh-customization.branch
    else
      $use_sudo git -C "${ZSH_CUSTOMIZATION_BASE}" config --local --replace-all zsh-customization.branch -- "$1"
    fi
  else
    $use_sudo git -C "${ZSH_CUSTOMIZATION_BASE}" config --local --get zsh-customization.branch || echo "<default>"
  fi
}

# Selfupdate!
if [[ "$ZSH_INSTALL_GLOBALLY" == "true" ]] && check_sudo; then
  alias zsh-theme:update='sudo HOME="$HOME" sh "${ZSH_CUSTOMIZATION_BASE}/install.sh" --skip-restart; exec zsh'
else
  alias zsh-theme:update='sh "${ZSH_CUSTOMIZATION_BASE}/install.sh" --skip-restart; exec zsh'
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
