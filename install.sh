#!/bin/sh

# Set installation dir (may be customized externally)
CUSTOMIZATION_DIR="${CUSTOMIZATION_DIR:-"${HOME}/zsh-customization"}"

# Download or update git repo
if [ ! -d "$CUSTOMIZATION_DIR" ]; then
  git clone --recursive https://github.com/BrainStone/zsh-customization.git "$CUSTOMIZATION_DIR"
else
  git -C "$CUSTOMIZATION_DIR" pull
  git -C "$CUSTOMIZATION_DIR" submodule update --init
fi

# Take care of existing .zshrc
[ -f "${HOME}/.zshrc" ] &&
  [ "$(head -n1 "${HOME}/.zshrc")" != "$(head -n1 "${CUSTOMIZATION_DIR}/root_zshrc.zsh")" ] &&
  mv "${HOME}/.zshrc" "${HOME}/.zshrc.orig"

# Install new zshrc
sed "s@XXX_PATH_XXX@${CUSTOMIZATION_DIR}@g" "${CUSTOMIZATION_DIR}/root_zshrc.zsh" >"${HOME}/.zshrc"

# Get rid of existing Oh My ZSH installation
OHMYZSH="${ZSH:-"${HOME}/.oh-my-zsh"}"
[ "$OHMYZSH" == "${CUSTOMIZATION_DIR}/oh-my-zsh" ] && OHMYZSH="${HOME}/.oh-my-zsh"

if [ -d "$OHMYZSH" ]; then
  echo "Found existing \"Oh My ZSH\" installation in \"${OHMYZSH}\"!"

  while true; do
    read -p "Do you want to remove it?" remove
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
