# ~/.config/zsh/modules/git.zsh
# Git functions

is-apple-silicon() { [ "$(uname -m)" = "arm64" ] && return 0 || return 1; }

setup-ssh() {
  if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID" >/dev/null; then
    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519"
  else
    echo "Using SSH agent PID $SSH_AGENT_PID"
  fi
}

git-pull() {
  setup-ssh
  local remote="${1:-origin}"
  local branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"
  git pull --rebase -q "$remote" "$branch"  # `-q` = quiet
}

git-push() {
  setup-ssh
  local remote="${1:-origin}"
  local branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"
  git push -q "$remote" "$branch"
}

git-add() { git add .; }

git-commit-message() {
  local message="$1"
  [ -z "$message" ] && message="$(date +%Y-%m-%d)\nChanged files:\n$(git status --short | awk '{print $2}')"
  git commit -m "$message" || { echo "(X︿x ) Commit failed."; return 1; }
}

git-add-commit-push() {
  setup-ssh
  git-add "$@"
  git-commit-message "$@"
  git-push "$@"
}