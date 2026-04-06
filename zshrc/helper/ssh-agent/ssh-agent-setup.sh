# Bitwarden SSH Agent Setup
# Prioritizes Bitwarden's SSH agent if available, otherwise falls back to standard ssh-agent

_setup_bitwarden_ssh_agent() {
	local bw_sock="$HOME/.bitwarden-ssh-agent.sock"

	# Check if Bitwarden socket exists (even if not yet a socket, it might be about to become one)
	if [ -e "$bw_sock" ]; then
		# If the socket exists, we want to use it regardless of whether it's "live"
		# at this exact moment. Bitwarden will fulfill requests once it initializes.
		export SSH_AUTH_SOCK="$bw_sock"
		return 0
	fi
	return 1
}

_setup_standard_ssh_agent() {
	# If SSH_AUTH_SOCK is already set and valid, do nothing
	if [ -S "$SSH_AUTH_SOCK" ]; then
		return 0
	fi

	# Fallback to starting a standard ssh-agent
	# We use a shell-agnostic way to find the hostname if possible, or just default
	local host_name
	host_name="$(hostname)"
	local ssh_env_cache="$HOME/.ssh/environment-${host_name}"

	if [ -f "$ssh_env_cache" ]; then
		# shellcheck disable=SC1090
		. "$ssh_env_cache" >/dev/null
		if [ -S "$SSH_AUTH_SOCK" ]; then
			return 0
		fi
	fi

	if [ ! -d "$HOME/.ssh" ]; then
		mkdir -p "$HOME/.ssh"
		chmod 700 "$HOME/.ssh"
	fi

	# Start ssh-agent and save environment
	# Using 'sed' to remove 'echo' lines for clean sourcing
	ssh-agent -s | sed '/^echo/d' >"$ssh_env_cache"
	chmod 600 "$ssh_env_cache"
	# shellcheck disable=SC1090
	. "$ssh_env_cache" >/dev/null
}

# Main logic
# Priority:
# 1. SSH agent forwarding (pre-existing valid SSH_AUTH_SOCK in a remote session)
# 2. Bitwarden SSH agent (if socket exists) - overrides local desktop agents
# 3. Start standard local ssh-agent (if no agent is already running)

# Check if we are in a remote session (SSH)
_is_remote_session() {
	[ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ]
}

if _is_remote_session && [ -S "$SSH_AUTH_SOCK" ]; then
	# Remote session with agent forwarding: don't touch it!
	:
else
	# Local session or no forwarded agent: try Bitwarden first
	if ! _setup_bitwarden_ssh_agent; then
		_setup_standard_ssh_agent
	fi
fi

# Export to systemd user environment for GUI apps/IDEs if available
if command -v systemctl >/dev/null 2>&1; then
	systemctl --user set-environment SSH_AUTH_SOCK="$SSH_AUTH_SOCK"
fi

# Clean up internal functions (shell-specific)
if [ -n "$ZSH_VERSION" ] || [ -n "$BASH_VERSION" ]; then
	unset -f _setup_bitwarden_ssh_agent _setup_standard_ssh_agent _is_remote_session
fi
