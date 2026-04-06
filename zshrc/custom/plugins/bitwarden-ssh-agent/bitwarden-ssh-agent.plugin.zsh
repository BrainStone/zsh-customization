# Bitwarden SSH Agent Plugin
# Prioritizes Bitwarden's SSH agent if available, otherwise falls back to standard ssh-agent

function _setup_bitwarden_ssh_agent() {
	local bw_sock="$HOME/.bitwarden-ssh-agent.sock"

	# Check if Bitwarden socket exists and is a socket
	if [[ -S "$bw_sock" ]]; then
		# Test if we can connect to it (using zsocket if available, otherwise just assume it's okay)
		if zmodload zsh/net/socket &>/dev/null; then
			if zsocket "$bw_sock" 2>/dev/null; then
				export SSH_AUTH_SOCK="$bw_sock"
				return 0
			fi
		else
			# Fallback: just check if it exists and we can read it
			export SSH_AUTH_SOCK="$bw_sock"
			return 0
		fi
	fi
	return 1
}

function _setup_standard_ssh_agent() {
	# Use existing Oh My Zsh ssh-agent plugin logic if possible,
	# or provide a simple implementation here if it's not loaded.

	# If SSH_AUTH_SOCK is already set and valid, do nothing
	if [[ -S "$SSH_AUTH_SOCK" ]]; then
		return 0
	fi

	# Fallback to starting a standard ssh-agent
	local ssh_env_cache="$HOME/.ssh/environment-$SHORT_HOST"

	if [[ -f "$ssh_env_cache" ]]; then
		# shellcheck disable=SC1090
		. "$ssh_env_cache" >/dev/null
		if [[ -S "$SSH_AUTH_SOCK" ]]; then
			return 0
		fi
	fi

	if [[ ! -d "$HOME/.ssh" ]]; then
		mkdir -p "$HOME/.ssh"
		chmod 700 "$HOME/.ssh"
	fi

	ssh-agent -s | sed '/^echo/d' "$ssh_env_cache" >!
	chmod 600 "$ssh_env_cache"
	# shellcheck disable=SC1090
	. "$ssh_env_cache" >/dev/null
}

# Main logic
if ! _setup_bitwarden_ssh_agent; then
	_setup_standard_ssh_agent
fi

# Clean up
unfunction _setup_bitwarden_ssh_agent _setup_standard_ssh_agent
