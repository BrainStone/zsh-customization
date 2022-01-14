#!/bin/sh

export CUSTOMIZATION_DIR="${CUSTOMIZATION_DIR:-"${HOME}/zsh-customization"}"

if [ ! -d "$CUSTOMIZATION_DIR" ]; then
  git clone --recursive https://github.com/BrainStone/zsh-customization.git "$CUSTOMIZATION_DIR"
else
  git -C "$CUSTOMIZATION_DIR" pull
  git -C "$CUSTOMIZATION_DIR" submodule update --init
fi

[ -f "${HOME}/.zshrc" ] && mv "${HOME}/.zshrc" "${HOME}/.zshrc.orig"

sed "s@XXX_PATH_XXX@${CUSTOMIZATION_DIR}@g" "${CUSTOMIZATION_DIR}/root_zshrc.zsh" > "${HOME}/.zshrc"

OHMYZSH="${ZSH:-"${HOME}/.oh-my-zsh"}"

if [ -d "$OHMYZSH" ]; then
  echo "Found existing \"Oh My ZSH\" installation in \"${OHMYZSH}\"!"
  read -p "Do you want to remove it?" remove
  
  [ "$remove" ~= "[yY]*" ] && rm -rf "$OHMYZSH"
fi
