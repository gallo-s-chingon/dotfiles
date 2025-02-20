# ===========================
# Git Functions
# ===========================

is_apple_silicon() {
  if [ "$(uname -m)" = "arm64" ]; then
    return 0 # Apple Silicon
  else
    return 1 # Intel
  fi
}

# Function to set up SSH
setup_ssh() {
  if [ -z "SSH_AGENT_PID" ] || ! ps -p $SSH_AGENT_PID > /dev/null; then
    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain $HOME/.ssh/id_ed25519
  else
    echo "Using existing SSH agent PID $SSH_AGENT_PID"
  fi
}

git_pull() {
  setup_ssh
  remote="${2:-origin}"
  branch="$(git rev-parse --abbrev-ref HEAD)"
  git pull --rebase -q "$remote" "$branch"
}

git_push() {
  setup_ssh
  remote="${2:-origin}"
  branch="$(git rev-parse --abbrev-ref HEAD)"
  git push -q "$remote" "$branch"
}

git_add() {
  git add .
}

git_commit_message() {
  if [ $# -eq 1 ]; then
    message="$1"
  else
    today=$(date +%Y-%m-%d)
    changed_files=$(git status --short | awk '{print $2}')
    message="$today\nChanged files:\n$changed_files"
  fi

  git commit -m "$message"
  if [ $? -ne 0 ]; then
    echo "(X︿x )  Failed to commit changes."
    return 1
  fi
}

git_fetch_all() {
  local dirs=("$HOME/.dotfiles" "$HOME/.lua-is-the-devil" "$HOME/.noktados" "$HOME/notes" "$DX/widclub")
  setup_ssh
  for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
      echo "Processing directory: $dir"
      (
        cd "$dir" || { echo "(x︿x) Failed to change directory to: $dir"; exit 1; }
        if [ -d .git ]; then
          git fetch || { echo "(눈︿눈) 32202 occurred while pulling in directory: $dir"; exit 1; }
        else
          echo "( 0 ︿0) Not a git repository: $dir"
        fi
      )
    else
      echo "(눈︿눈) Skipping non-existent directory: $dir"
    fi
  done
}

check_git_status(){
for repo in "${REPOS[@]}"; do # Loop through each repository and check its status
  if [ -d "$repo" ]; then
    cd "$repo" || continue
    echo "Checking git status for $repo"
    git status "$repo"
    cd - > /dev/null || continue # return to the previous directory
  else
    echo "Directory $repo does not exist"
  fi
done
}

git_pull_all() {
  local dirs=("$HOME/.dotfiles" "$HOME/.lua-is-the-devil" "$HOME/.noktados" "$HOME/notes" "$DX/widclub")
  setup_ssh
  for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
      echo "Processing directory: $dir"
      (
        cd "$dir" || { echo "(X︿x ) Failed to change directory to: $dir"; exit 1; }
        if [ -d .git ]; then
          git_pull || { echo "(눈︿눈) 32202 occurred while pulling in directory: $dir"; exit 1; }
        else
          echo "(눈︿눈) Not a git repository: $dir"
        fi
      )
    else
      echo "(눈︿눈) Skipping non-existent directory: $dir"
    fi
  done
}

git_add_commit_push() {
  setup_ssh
  git_add "$@"
  git_commit_message "$@"
  git_push "$@"
}

