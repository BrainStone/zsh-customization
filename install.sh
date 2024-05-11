#! /usr/bin/env sh

command_exists() {
  [ -x "$(command -v "$1")" ]
}

ask_user_yn() {
  while true; do
    printf "%s (y/n) " "$*"
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

missing_commands=""
for command in chmod git mv rm route sed zsh; do
  if ! command_exists "$command"; then
    missing_commands="${missing_commands} $command"
  fi
done

if [ -n "$missing_commands" ]; then
  echo "You are missing the following commands:${missing_commands}"
  echo "Please install them before retrying!"

  exit 1
fi

# Set global installation dir (may be customized externally)
ZSH_GLOBAL_CUSTOMIZATION_BASE="${ZSH_GLOBAL_CUSTOMIZATION_BASE:-/opt/zsh-customization}"
# Whether to install the software globally
ZSH_INSTALL_GLOBALLY="${ZSH_INSTALL_GLOBALLY:-false}"

USER_ID="$(id -u)"

if [ "$USER_ID" -eq 0 ] &&
  [ ! -d "$ZSH_GLOBAL_CUSTOMIZATION_BASE" ] && (
  [ "$ZSH_INSTALL_GLOBALLY" = "true" ] ||
    ask_user_yn "Do you want to install these customizations globally?"
); then
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
elif [ "$USER_ID" -eq "$(stat -c "%u" "$ZSH_CUSTOMIZATION_BASE")" ]; then
  # Get the git branch to use from the variable
  branch="$(git -C "$ZSH_CUSTOMIZATION_BASE" config --get --local zsh-customization.branch 2>/dev/null)"
  branch="${branch:-master}"

  git -C "$ZSH_CUSTOMIZATION_BASE" reset --hard
  git -C "$ZSH_CUSTOMIZATION_BASE" clean -dx -ff
  git -C "$ZSH_CUSTOMIZATION_BASE" checkout "$branch"
  git -C "$ZSH_CUSTOMIZATION_BASE" pull --recurse-submodules --jobs=10
else
  echo "WARNING: Can't update the git repository in \"$ZSH_CUSTOMIZATION_BASE\" because it belongs to \"$(stat -c "%U" "$ZSH_CUSTOMIZATION_BASE")\" instead of you (\"$(id -un)\")!"
fi

if [ "$ZSH_INSTALL_GLOBALLY" = "true" ] && ! git config --get --system safe.directory "$ZSH_CUSTOMIZATION_BASE" >/dev/null 2>&1; then
  git config --add --system safe.directory "$ZSH_CUSTOMIZATION_BASE"
fi

# Remove write permissions for the group and world (if the repo belongs to you)
if [ "$USER_ID" -eq "$(stat -c "%u" "$ZSH_CUSTOMIZATION_BASE")" ]; then
  chmod -R g-w,o-w "$ZSH_CUSTOMIZATION_BASE"
fi

# Take care of existing .zshrc
[ -f "${HOME}/.zshrc" ] &&
  [ "$(head -n1 "${HOME}/.zshrc")" != "$(head -n1 "${ZSH_CUSTOMIZATION_BASE}/zshrc/root_zshrc.zsh")" ] &&
  mv "${HOME}/.zshrc" "${HOME}/.zshrc.orig"

# Install new zshrc
sed -e "s@XXX_GLOBAL_XXX@${ZSH_INSTALL_GLOBALLY}@g" -e "s@XXX_PATH_XXX@${ZSH_CUSTOMIZATION_BASE}@g" "${ZSH_CUSTOMIZATION_BASE}/zshrc/root_zshrc.zsh" >"${HOME}/.zshrc"
if [ "$USER_ID" -eq 0 ] && [ "$ZSH_INSTALL_GLOBALLY" = "true" ]; then
  mkdir -p /etc/skel
  cp -f "${HOME}/.zshrc" /etc/skel/.zshrc
fi

# Get rid of existing Oh My ZSH installation
OHMYZSH="${ZSH:-"${HOME}/.oh-my-zsh"}"
[ "$OHMYZSH" = "${ZSH_CUSTOMIZATION_BASE}/oh-my-zsh" ] && OHMYZSH="${HOME}/.oh-my-zsh"

# Detect python version
python_command=:
for command in python3 python python2; do
  if command_exists "$command"; then
    python_command="$command"
    break
  fi
done

# Migrate bash history if it hasn't already if python installed
[ "$python_command" != ":" ] &&
  [ ! -f "${HOME}/.zsh_history" ] &&
  [ -f "${HISTFILE:="${HOME}/.bash_history"}" ] &&
  "$python_command" "${ZSH_CUSTOMIZATION_BASE}/helper/bash-to-zsh-hist/bash-to-zsh-hist.py" <"${HISTFILE}" >>"${HOME}/.zsh_history"

if [ -d "$OHMYZSH" ]; then
  echo "Found existing \"Oh My ZSH\" installation in \"${OHMYZSH}\"!"

  ask_user_yn "Do you want to remove it?" && rm -rf "$OHMYZSH"
fi

# Run zsh or just update it if already running!
[ "_$1" != "_--skip-restart" ] &&
  exec zsh
