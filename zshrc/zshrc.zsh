# Little helper to check if variable is set and not false, no and 0
function is_variable_set() {
  (( ${(P)+1} )) && [[ ${(P)1} != "false" && ${(P)1} != "no" && ${(P)1} != "0" ]]
}

# ~/.bashrc might contain useful aliases
# Lets source it, while also adding compatibility stuff.

if ! is_variable_set ZSH_NO_BASHRC && [[ -f "${HOME}/.bashrc" ]]; then
  alias shopt=true
  alias .=source

  source "${HOME}/.bashrc"

  unalias shopt
  unalias .
fi

# Fix numeric keypad
# 0 . Enter
bindkey -s "^[Op" "0"
bindkey -s "^[On" ","
bindkey -s "^[OM" "^M"
# 1 2 3
bindkey -s "^[Oq" "1"
bindkey -s "^[Or" "2"
bindkey -s "^[Os" "3"
# 4 5 6
bindkey -s "^[Ot" "4"
bindkey -s "^[Ou" "5"
bindkey -s "^[Ov" "6"
# 7 8 9
bindkey -s "^[Ow" "7"
bindkey -s "^[Ox" "8"
bindkey -s "^[Oy" "9"
# + -  * / =
bindkey -s "^[Ol" "+"
bindkey -s "^[Om" "-"; bindkey -s "^[OS" "-"
bindkey -s "^[Oj" "*"; bindkey -s "^[OR" "*"
bindkey -s "^[Oo" "/"; bindkey -s "^[OQ" "/"
bindkey -s "^[OX" "="

# Path to your oh-my-zsh installation.
export ZSH_CUSTOMIZATION_BASE="${0:a:h:h}"
export ZSH_CUSTOMIZATION_ZSHRC_BASE="${ZSH_CUSTOMIZATION_BASE}/zshrc"
if [[ "$ZSH_INSTALL_GLOBALLY" == "true" ]]; then
  export ZSH_GLOBAL_CUSTOMIZATION_BASE="$ZSH_CUSTOMIZATION_BASE"
  export ZSH_GLOBAL_CUSTOMIZATION_ZSHRC_BASE="$ZSH_CUSTOMIZATION_ZSHRC_BASE"
fi
export ZSH="${ZSH_CUSTOMIZATION_ZSHRC_BASE}/oh-my-zsh"
export ZSH_CUSTOM="${ZSH_CUSTOMIZATION_ZSHRC_BASE}/custom"

# Check for updates as before instant prompt
source "${ZSH_CUSTOMIZATION_ZSHRC_BASE}/check_for_update.zsh"

# Prepare direnv
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable direnv
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"
# Enable thefuck
(( ${+commands[thefuck]} )) && emulate zsh -c "$(thefuck --alias)"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  command-not-found
  gitfast
  gitignore
  zsh-autosuggestions
  zsh-hist
  zsh-syntax-highlighting
)

source "${ZSH}/oh-my-zsh.sh"
source "${ZSH_CUSTOMIZATION_ZSHRC_BASE}/aliases.zsh"

# User configuration

export HISTFILE=~/.zsh_history
export HISTSIZE=200000
export SAVEHIST=100000

setopt HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_NO_FUNCTIONS
# Define commands to completely ignore from history (because of sensitive data or spam or whatever). Separate with |
export HISTORY_IGNORE="oc login *"

# Restore defaults before setting my values
#zwt restore-defaults

# Syntax highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Window title customization
export ZSH_WINDOW_TITLE_DIRECTORY_DEPTH=4
export ZSH_WINDOW_TITLE_PREFIX='%n@%M'
export ZSH_WINDOW_TITLE_IDLE='${ZSH_WINDOW_TITLE_PREFIX:+"${ZSH_WINDOW_TITLE_PREFIX} - "}%$ZSH_WINDOW_TITLE_DIRECTORY_DEPTH~${ZSH_WINDOW_TITLE_SUFFIX:+" - ${ZSH_WINDOW_TITLE_SUFFIX}"}'
export ZSH_WINDOW_TITLE_ACTIVE='${ZSH_WINDOW_TITLE_PREFIX:+"${ZSH_WINDOW_TITLE_PREFIX} - "}%$ZSH_WINDOW_TITLE_DIRECTORY_DEPTH~ - %40>...>%1v%>>${ZSH_WINDOW_TITLE_SUFFIX:+" - ${ZSH_WINDOW_TITLE_SUFFIX}"}'

# Temporary setting windows title manually until ZSH Window title merges my PR
window-title:precmd() {
  print -nP "\033]0;${(e)ZSH_WINDOW_TITLE_IDLE}\007"
}
window-title:preexec() {
  local psvar=("$@")
  
  print -nP "\033]0;${(e)ZSH_WINDOW_TITLE_ACTIVE}\007"
}
autoload -U add-zsh-hook
add-zsh-hook precmd window-title:precmd
add-zsh-hook preexec window-title:preexec

# To customize prompt, run `p10k configure` or edit "${ZSH_CUSTOMIZATION_ZSHRC_BASE}/p10k_config.zsh".
[[ ! -f "${ZSH_CUSTOMIZATION_ZSHRC_BASE}/p10k_config.zsh" ]] ||
  source "${ZSH_CUSTOMIZATION_ZSHRC_BASE}/p10k_config.zsh"

# $PATH deduplication
export PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')"
