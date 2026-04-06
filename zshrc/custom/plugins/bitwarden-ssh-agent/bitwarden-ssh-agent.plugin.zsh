# Bitwarden SSH Agent Plugin
# Prioritizes Bitwarden's SSH agent if available, otherwise falls back to standard ssh-agent

# Source the common shell script
# shellcheck disable=SC1090
if [ -f "${ZSH_CUSTOMIZATION_ZSHRC_BASE}/helper/ssh-agent/ssh-agent-setup.sh" ]; then
	. "${ZSH_CUSTOMIZATION_ZSHRC_BASE}/helper/ssh-agent/ssh-agent-setup.sh"
fi
