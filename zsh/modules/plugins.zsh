# ~/.config/zsh/modules/plugins.zsh
# Manages Zsh plugins with Zinit

ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"

# Install Zinit if missing
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME"
fi

# Load Zinit
source "$ZINIT_HOME/zinit.zsh"

# Load plugins
zinit ice depth=1; zinit light romkatv/powerlevel10k  # Powerlevel10k theme
zinit light Aloxaf/fzf-tab                           # fzf tab completion

# Initialize completions
autoload -U compinit && compinit
zinit cdreplay -q

# Additional enhancements
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$(brew --prefix)/share/zsh-autopair/autopair.zsh"
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$(brew --prefix)/share/zsh-completions"

# Initialize fzf and zoxide
source <(fzf --zsh)
eval "$(zoxide init zsh)"

# rbenv setup
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi