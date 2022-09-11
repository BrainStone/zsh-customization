# This checks if an update is available
# Taken from oh-my-zsh
function is_update_available() {
  local branch
  branch=${"$(builtin cd -q "$ZSH_CUSTOMIZATION_BASE"; git config --local zsh_customization.branch 2>/dev/null)":-master}

  local remote remote_url remote_repo
  remote=${"$(builtin cd -q "$ZSH_CUSTOMIZATION_BASE"; git config --local zsh_customization.remote 2>/dev/null)":-origin}
  remote_url=$(builtin cd -q "$ZSH_CUSTOMIZATION_BASE"; git config remote.$remote.url)

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
  local_head=$(builtin cd -q "$ZSH_CUSTOMIZATION_BASE"; git rev-parse $branch 2>/dev/null) || return 0

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
  base=$(builtin cd -q "$ZSH_CUSTOMIZATION_BASE"; git merge-base $local_head $remote_head 2>/dev/null) || return 0

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
