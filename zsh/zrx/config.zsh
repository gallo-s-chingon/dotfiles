# zsh-config.zsh

source-zshrc() {
  update-zwc
  source "$HOME/.config/zsh/zshrc" >/dev/null
}

update-zwc() {
  compile-zdot() { [ -f "$1" ] && zcompile "$1" && info "Compiled $1" }
  compile-zdot "$DOTZ/zrx/*.zsh"
  compile-zdot "$DOTZ/z*"
  return 0
}

open-zshrc() {
  nvim "$DOTZ/zshrc"
}

open-zsh-history() {
  nvim "$HOME/.zsh-history"
}

open-aliases() {
  nvim "$DOTZ/zrx/aliases.zsh"
}

open-functions() {
  cd "$DOTZ/zrx/"
  nvim -c "$DOTZ/zrx/functions.zsh"
}
