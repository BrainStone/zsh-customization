# This checks if an update is available
# Taken from oh-my-zsh
function is_update_available() {
  # Check if we have a default route, else assume no update available (as we don't have an internet connection!)
  if (( ${+commands[route]} )); then
    # If we have a default gateway `route -n` outputs a line that looks like this and we just try to match it:
    # 0.0.0.0 <gateway IP> 0.0.0.0 UG <more stuff>
    # The U means up, G means gateway (not important, that's why we're not checking it). The U is guaranteed to be first.
    route -n | grep -qE "^(0\.){3}0[[:space:]]+([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}[[:space:]]+(0\.){3}0[[:space:]]+U" \
      || return 1
  elif (( ${+commands[ip]} )); then
    # If we have a default gateway `ip route show` outputs a line that looks like this and we just try to match it:
    # default via <gateway IP> dev <device> proto <protocol>[ metric <metric>]
    ip route show | grep -qE "^default[[:space:]]+via[[:space:]]+([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}[[:space:]]+dev[[:space:]]+[^[:space:]]+[[:space:]]+proto[[:space:]]+[^[:space:]]+([[:space:]]+metric[[:space:]]+[[:digit:]]+)?$" \
      || return 1
  else
    # No program available to check for internet connectivity. Assume we have internet connectivity and continue the check
    :
  fi

  local branch
  branch=${"$(git -C "$ZSH_CUSTOMIZATION_BASE" config --get --local zsh-customization.branch 2>/dev/null)":-master}

  local remote remote_url remote_repo
  remote=${"$(git -C "$ZSH_CUSTOMIZATION_BASE" config --get --local zsh-customization.remote 2>/dev/null)":-origin}
  remote_url=$(git -C "$ZSH_CUSTOMIZATION_BASE" config --get --local "remote.$remote.url" 2>/dev/null)

  local repo
  case "$remote_url" in
  https://github.com/*) repo=${${remote_url#https://github.com/}%.git} ;;
  git@github.com:*) repo=${${remote_url#git@github.com:}%.git} ;;
  *)
    # If the remote is not using GitHub we can't check for updates
    # Let's assume there are updates
    return 0 ;;
  esac

  # If the remote repo is not the official one, let's assume there are updates available
  [[ "$repo" = BrainStone/zsh-customization ]] || return 0
  local api_url="https://api.github.com/repos/${repo}/commits/${branch}"

  # Get local HEAD. If this fails assume there are updates
  local local_head
  local_head=$(git -C "$ZSH_CUSTOMIZATION_BASE" rev-parse $branch 2>/dev/null) || return 0

  # Get remote HEAD. If no suitable command is found assume there are updates
  # On any other error, skip the update (connection may be down)
  local remote_head
  remote_head=$(
    if (( ${+commands[curl]} )); then
      curl --connect-timeout 2 -fsSL -H 'Accept: application/vnd.github.v3.sha' $api_url 2>/dev/null
    elif (( ${+commands[wget]} )); then
      wget -T 2 -O- --header='Accept: application/vnd.github.v3.sha' $api_url 2>/dev/null
    elif (( ${+commands[fetch]} )); then
      HTTP_ACCEPT='Accept: application/vnd.github.v3.sha' fetch -T 2 -o - $api_url 2>/dev/null
    else
      exit 0
    fi
  ) || return 1

  # Compare local and remote HEADs (if they're equal there are no updates)
  [[ "$local_head" != "$remote_head" ]] || return 1

  # If local and remote HEADs don't match, check if there's a common ancestor
  # If the merge-base call fails, $remote_head might not be downloaded so assume there are updates
  local base
  base=$(git -C "$ZSH_CUSTOMIZATION_BASE" merge-base $local_head $remote_head 2>/dev/null) || return 0

  # If the common ancestor ($base) is not $remote_head,
  # the local HEAD is older than the remote HEAD
  [[ $base != $remote_head ]]
}

# Always check for updates unless ZSH_DISABLE_UPDATE_CHECK is set
if ! is_variable_set ZSH_DISABLE_UPDATE_CHECK && is_update_available; then
  printf '\r\e[0K' # move cursor to first column and clear whole line
  echo "[zsh-customization] It's time to update! You can do that by running \`update-zsh-theme\`"
  return 0
fi
