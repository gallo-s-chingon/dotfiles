# ~/.config/zsh/modules/config.zsh
# Zsh configuration utilities

# Source zshrc and update compiled files
source-zshrc() {
  update-zwc
  source "$HOME/.config/zsh/zshrc" >/dev/null
}

# Compile zsh files for faster loading
# `zcompile` creates .zwc files to speed up sourcing
update-zwc() {
  compile-zdot() { [ -f "$1" ] && zcompile "$1" && echo "Compiled $1"; }
  compile-zdot "$DOTZ/zrx/*.zsh"
  compile-zdot "$DOTZ/z*"
}

# Open config files in Neovim
open-zshrc() { nvim "$DOTZ/zshrc"; }
open-zsh-history() { nvim "$HOME/.zsh_history"; }
open-aliases() { nvim "$DOTZ/zrx/aliases.zsh"; }
open-functions() { cd "$DOTZ/zrx/" && nvim "$DOTZ/zrx/functions.zsh"; }
open-nvim-init() { nvim "$DOTN/init.lua"; }  # Updated to use DOTN
open-wezterm() { nvim "$HOME/dots/wezterm.lua"; }
open-ghostty() { nvim "$CF/ghostty/config"; }