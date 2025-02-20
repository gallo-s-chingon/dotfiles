# ~/.config/zsh/modules/aliases.zsh
# Command aliases grouped by category

# General
alias c='clear'                  # Clear screen
alias cdc='cd && clear'          # Home and clear
alias dt='date "+%F"'            # Date in YYYY-MM-DD
alias e='exit 0'                 # Exit successfully
alias grep='grep --color=auto'   # Colored grep output
alias ls='eza --color=always --icons --git'  # eza instead of ls
alias la='ls -a --git'           # List all
alias lt='ls --tree --level=2'   # Tree view, 2 levels

# Git
alias g='git'
alias gad='git-add'
alias gac='git-add-commit-push'
alias gcm='git-commit-message'
alias gpl='git-pull'

# File Management
alias mk='mkdir -pv'             # Make dirs with parents, verbose
alias rm='rm -rfv'               # Remove recursively, verbose
alias f='fzf'                    # Fuzzy finder

# Torrent
alias mat='move-all-torrents'
alias obt='open-btn-torrents-in-transmission'

# Add more as needed...