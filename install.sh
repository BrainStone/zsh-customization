#!/bin/sh

ask_user_yn() {
  while true; do
    printf '%s ' "$*"
    read -r yn
    case "$yn" in
    [Yy]*)
      return 0
      ;;
    [Nn]*)
      return 1
      ;;
    *)
      echo "Please answer yes or no."
      ;;
    esac
  done
}

# Set global installation dir (may be customized externally)
ZSH_GLOBAL_CUSTOMIZATION_BASE="${ZSH_GLOBAL_CUSTOMIZATION_BASE:-/opt/zsh-customization}"
ZSH_INSTALL_GLOBALLY="${ZSH_INSTALL_GLOBALLY:-false}"

if [ "$(id -u)" -eq "0" ] &&
  [ ! -d "$ZSH_GLOBAL_CUSTOMIZATION_BASE" ] &&
  ask_user_yn "Do you want to install these customizations globally?"; then
  ZSH_CUSTOMIZATION_BASE="$ZSH_GLOBAL_CUSTOMIZATION_BASE"
  ZSH_INSTALL_GLOBALLY=true
fi

# Global dir exists, we're using that!
if [ -d "$ZSH_GLOBAL_CUSTOMIZATION_BASE" ]; then
  # Remove user local dir if it exists
  [ -n "$ZSH_CUSTOMIZATION_BASE" ] &&
    [ -d "$ZSH_CUSTOMIZATION_BASE" ] &&
    [ "$ZSH_CUSTOMIZATION_BASE" != "$ZSH_GLOBAL_CUSTOMIZATION_BASE" ] &&
    rm -rf "$ZSH_CUSTOMIZATION_BASE"

  # Set ZSH_CUSTOMIZATION_BASE to the global dir
  ZSH_CUSTOMIZATION_BASE="$ZSH_GLOBAL_CUSTOMIZATION_BASE"
  ZSH_INSTALL_GLOBALLY=true
fi

# Set installation dir (may be customized externally)
# If the global installation dir is in use, this gets overridden
ZSH_CUSTOMIZATION_BASE="${ZSH_CUSTOMIZATION_BASE:-"${HOME}/zsh-customization"}"

# Download or update git repo
if [ ! -d "$ZSH_CUSTOMIZATION_BASE" ]; then
  git clone --recursive --jobs=10 https://github.com/BrainStone/zsh-customization.git "$ZSH_CUSTOMIZATION_BASE"
elif [ "$(id -u)" -eq "$(stat --format '%u' "$ZSH_CUSTOMIZATION_BASE")" ]; then
  git -C "$ZSH_CUSTOMIZATION_BASE" git reset --hard
  git -C "$ZSH_CUSTOMIZATION_BASE" clean -d -f
  git -C "$ZSH_CUSTOMIZATION_BASE" pull --recurse-submodules --jobs=10
fi

# Take care of existing .zshrc
[ -f "${HOME}/.zshrc" ] &&
  [ "$(head -n1 "${HOME}/.zshrc")" != "$(head -n1 "${ZSH_CUSTOMIZATION_BASE}/root_zshrc.zsh")" ] &&
  mv "${HOME}/.zshrc" "${HOME}/.zshrc.orig"

# Install new zshrc
sed -e "s@XXX_GLOBAL_XXX@${ZSH_INSTALL_GLOBALLY}@g" -e "s@XXX_PATH_XXX@${ZSH_CUSTOMIZATION_BASE}@g" "${ZSH_CUSTOMIZATION_BASE}/root_zshrc.zsh" >"${HOME}/.zshrc"
[ "$(id -u)" -eq "0" ] && [ "$ZSH_INSTALL_GLOBALLY" = "true" ] && cp "${HOME}/.zshrc" /etc/skel/.zshrc

# Get rid of existing Oh My ZSH installation
OHMYZSH="${ZSH:-"${HOME}/.oh-my-zsh"}"
[ "$OHMYZSH" = "${ZSH_CUSTOMIZATION_BASE}/oh-my-zsh" ] && OHMYZSH="${HOME}/.oh-my-zsh"

# Migrate bash history
[ ! -f "${HOME}/.zsh_history" ] &&
  [ -f "${HOME}/.bash_history" ] &&
  python "${ZSH_CUSTOMIZATION_BASE}/helper/bash-to-zsh-hist/bash-to-zsh-hist.py" <"${HOME}/.bash_history" >>"${HOME}/.zsh_history"

if [ -d "$OHMYZSH" ]; then
  echo "Found existing \"Oh My ZSH\" installation in \"${OHMYZSH}\"!"

  ask_user_yn "Do you want to yn it?" && rm -rf "$OHMYZSH"
fi

# Run zsh or just update it if already running!
[ "_$1" != "_--skip-restart" ] &&
  exec zsh
