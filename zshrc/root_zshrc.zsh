# This system uses a centralized zshrc!
# Please do not customize this file, but instead use either your ~/.zshrc_local or
# ~/.zshrc_local_post files! (Create them if they don't exist)

[ -f ~/.zshrc_local ] && source ~/.zshrc_local

# Are we using the global config?
export ZSH_INSTALL_GLOBALLY=XXX_GLOBAL_XXX
# The actual .zshrc file. Contains all centralized customizations!
source "XXX_PATH_XXX/zshrc/zshrc.zsh"

[ -f ~/.zshrc_local_post ] && source ~/.zshrc_local_post
