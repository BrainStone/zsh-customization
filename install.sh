#!/bin/sh

# Set installation dir (may be customized externally)
ZSH_CUSTOMIZATION_BASE="${ZSH_CUSTOMIZATION_BASE:-"${HOME}/zsh-customization"}"

# Download or update git repo
if [ ! -d "$ZSH_CUSTOMIZATION_BASE" ]; then
  git clone --recursive --jobs=10 https://github.com/BrainStone/zsh-customization.git "$ZSH_CUSTOMIZATION_BASE"
else
  git -C "$ZSH_CUSTOMIZATION_BASE" pull --recurse-submodules --jobs=10
fi

# Take care of existing .zshrc
[ -f "${HOME}/.zshrc" ] &&
  [ "$(head -n1 "${HOME}/.zshrc")" != "$(head -n1 "${ZSH_CUSTOMIZATION_BASE}/root_zshrc.zsh")" ] &&
  mv "${HOME}/.zshrc" "${HOME}/.zshrc.orig"

# Install new zshrc
sed "s@XXX_PATH_XXX@${ZSH_CUSTOMIZATION_BASE}@g" "${ZSH_CUSTOMIZATION_BASE}/root_zshrc.zsh" >"${HOME}/.zshrc"

# Get rid of existing Oh My ZSH installation
OHMYZSH="${ZSH:-"${HOME}/.oh-my-zsh"}"
[ "$OHMYZSH" = "${ZSH_CUSTOMIZATION_BASE}/oh-my-zsh" ] && OHMYZSH="${HOME}/.oh-my-zsh"

if [ -d "$OHMYZSH" ]; then
  echo "Found existing \"Oh My ZSH\" installation in \"${OHMYZSH}\"!"

  while true; do
    printf '%s' "Do you want to remove it?"
    read -r remove
    case "$remove" in
    [Yy]*)
      rm -rf "$OHMYZSH"
      break
      ;;
    [Nn]*)
      break
      ;;
    *)
      echo "Please answer yes or no."
      ;;
    esac
  done
fi

# Run zsh or just update it if already running!
exec zsh
