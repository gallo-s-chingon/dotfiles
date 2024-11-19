# ===========================
# Git Functions
# ===========================

def is_apple_silicon [] {
    if ($env.CPU_ARCH == "arm64") {
        return true
    } else {
        return false
    }
}

def setup_ssh [] {
    if ($env.SSH_AGENT_PID | is-empty) || (ps -p $env.SSH_AGENT_PID | is-empty) {
        eval (^ssh-agent -s)
        ^ssh-add --apple-use-keychain $env.HOME/.ssh/id_ed25519
    } else {
        echo "Using existing SSH agent PID $env.SSH_AGENT_PID"
    }
}

def git_pull [remote?: string, branch?: string] {
    setup_ssh
    let remote = if ($remote | is-empty) { "origin" } else { $remote }
    let branch = if ($branch | is-empty) { (^git rev-parse --abbrev-ref HEAD) } else { $branch }
    ^git pull --rebase -q $remote $branch
}

def git_push [remote?: string, branch?: string] {
    setup_ssh
    let remote = if ($remote | is-empty) { "origin" } else { $remote }
    let branch = if ($branch | is-empty) { (^git rev-parse --abbrev-ref HEAD) } else { $branch }
    ^git push -q $remote $branch
}

def git_add [] {
    ^git add.
}

def git_commit_message [message?: string] {
    if ($message | is-empty) {
        let today = (^date +%Y-%m-%d)
        let changed_files = (^git status --short | awk '{print $2}' | str join "\n")
        let message = $"$today\nChanged files:\n$changed_files"
    } else {
        let message = $message
    }

    ^git commit -m $message
    if (^git commit -m $message | is-error) {
        echo "(X︿x )  Failed to commit changes."
        return 1
    }
}

def git_fetch_all [] {
    let dirs = [$env.HOME/.dotfiles, $env.HOME/.lua-is-the-devil, $env.HOME/.noktados, $env.HOME/notes, $env.DX/widclub]
    setup_ssh
    for dir in $dirs {
        if ($dir | path exists) {
            echo "Processing directory: $dir"
            (
                cd $dir || { echo "(x︿x) Failed to change directory to: $dir"; exit 1 }
                if ($dir/.git | path exists) {
                    ^git fetch || { echo "(눈︿눈) 32202 occurred while pulling in directory: $dir"; exit 1 }
                } else {
                    echo "( 0 ︿0) Not a git repository: $dir"
                }
            )
        } else {
            echo "(눈︿눈) Skipping non-existent directory: $dir"
        }
    }
}

def check_git_status [repos: array] {
    for repo in $repos {
        if ($repo | path exists) {
            cd $repo || continue
            echo "Checking git status for $repo"
            ^git status
            cd - > /dev/null || continue
        } else {
            echo "Directory $repo does not exist"
        }
    }
}

def git_pull_all [] {
    let dirs = [$env.HOME/.dotfiles, $env.HOME/.lua-is-the-devil, $env.HOME/.noktados, $env.HOME/notes, $env.DX/widclub]
    setup_ssh
    for dir in $dirs {
        if ($dir | path exists) {
            echo "Processing directory: $dir"
            (
                cd $dir || { echo "(X︿x ) Failed to change directory to: $dir"; exit 1 }
                if ($dir/.git | path exists) {
                    git_pull || { echo "(눈︿눈) 32202 occurred while pulling in directory: $dir"; exit 1 }
                } else {
                    echo "(눈︿눈) Not a git repository: $dir"
                }
            )
        } else {
            echo "(눈︿눈) Skipping non-existent directory: $dir"
        }
    }
}

def git_add_commit_push [message?: string] {
    setup_ssh
    git_add
    git_commit_message $message
    git_push
}
