# ~/.config/zsh/modules/aliases.zsh
# Command aliases grouped by category for quick reference and use

# ===== General Aliases =====
alias c='clear'                          # Clear terminal screen
alias c-='cd -'                          # Go back to previous directory
alias cdc='cd && c'                      # Go to home directory and clear screen
alias ctc='copy-file-contents-to-clipboard'  # Copy file contents to clipboard
alias dt='date "+%F"'                    # Show date in YYYY-MM-DD format
alias eng="env | grep -i "               # Search environment variables case-insensitively
alias e='exit 0'                         # Exit shell with success status
alias ex='expand'                        # Expand tabs to spaces (uses `expand` command)
alias ffav='ffmpeg-remux-audio-video'    # Remux audio and video with FFmpeg
alias sdd='spotify-dl'                   # Download Spotify tracks
alias grep='grep --color=auto'           # Grep with colored output
alias lock='chflags uchg '               # Lock a file (macOS: make unchangeable)
alias ln='ln -i'                         # Create symbolic links with overwrite prompt
alias mnf='mediainfo'                    # Show media file info (uses `mediainfo` tool)
alias o.='open .'                        # Open current directory in Finder (macOS)
alias ptc='paste-output-to-clipboard'    # Copy command output to clipboard
alias nowrap='setterm --linewrap off'    # Disable line wrapping in terminal
alias wrap='setterm --linewrap on'       # Enable line wrapping in terminal

# ===== Git Aliases =====
alias g='git'                            # Shortcut for git
alias gad='git-add'                      # Add all changes to staging
alias gac='git-add-commit-push'          # Add, commit, and push in one go
alias gcm='git-commit-message'           # Commit with a custom message
alias gcs='git-check-status'             # Check status of local git repos
alias gfh='git fetch'                    # Fetch updates from remote
alias gpl='git-pull'                     # Pull changes from remote
alias gla='git-pull-all'                 # Pull all repos in specified dirs
alias gph='git-push'                     # Push changes to remote
alias gst='git status'                   # Show git status

# ===== File Management Aliases =====
alias bydate='$RX/sort-file-by-date.sh'  # Sort files by date (custom script)
alias d='fd -H -t f .DS_Store -X rm -frv'  # Remove .DS_Store files (macOS)
alias fdm='fd-files-move-to-dir'         # Move files matching pattern to dir
alias fdd='fd-exclude-dir-find-name-move-to-exclude-dir'  # Move files excluding a dir
alias fdf='fd -tf -d 1 '                 # Find files in current dir (`fd` = fast find)
alias f='fzf '                           # Fuzzy finder with space for args
alias free='freespace'                   # Show free disk space (assumes custom command)
alias ft='fd-type'                       # List file types by extension
alias mk='mkdir -pv'                     # Make directories with parents, verbose
alias mia='move-ipa-to-target-directory' # Move .ipa files to target dir
alias mio='move-iso'                     # Move ISO-like files
alias mtt='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv $HOME/.Trash'  # Empty all trashes
alias rm='rm -rfv'                       # Remove recursively, forcefully, verbose
alias orgf='$RX/sort-file-by-date'       # Alias for sorting file.wqs by date
alias srm='sudo rm -rfv'                 # Remove with sudo, verbose
alias mkrx='create-script-and-open'      # Create and open a script
alias videdit='node $HOME/.config/rx/processVideo.js'
alias fby='fabric_automation'
alias slug='$HOME/.config/rx/slugged.sh'

# ===== Torrent Management Aliases =====
alias mat='move-all-torrents'            # Move all torrents to respective dirs
alias mnx='move-nix'                     # Move nix-related torrents
alias mvb='move-btn-torrents'            # Move BTN torrents
alias mvm='move-mam-torrents'            # Move MAM torrents
alias mvp='move-ptp-torrents'            # Move PTP torrents
alias mve='move-emp-torrents'            # Move EMP torrents
alias mlf='move-repo-files-larger-than-99M'  # Move files > 99MB
alias obt='open-btn-torrents-in-transmission'  # Open BTN torrents in Transmission
alias opt='open-ptp-torrents-in-deluge'  # Open PTP torrents in Deluge
alias odt='open-downloaded-torrents'     # Open downloaded torrents

# ===== Blog Aliases =====
alias blog='$RX/blog.sh blog'            # Run blog script with 'blog' arg
alias epi='$RX/blog.sh epi'              # Run blog script with 'epi' arg
alias feat='$RX/blog.sh feat'            # Run blog script with 'feat' arg

# ===== Image Management Aliases =====
alias 50p='imagemagick-resize-50'        # Resize image to 50%
alias 500='imagemagick-resize-500'       # Resize image to 500 pixels
alias 720='imagemagick-resize-720'       # Resize image to 720 pixels
alias coltxt='pick-color-fill-text'      # Create colored text image
alias mpx='move-download-pix-to-pictures-dir'  # Move pics to Pictures dir
alias rpx='remove-pix'                   # Remove image files
alias shave='imagemagick-shave'          # Shave edges off image
alias ytt='youtube-thumbnail'            # Create YouTube thumbnail

# ===== Miscellaneous Aliases =====
alias clock='tty-clock -B -C 5 -c'       # Show terminal clock (`-B` = big, `-C 5` = color)
alias instadl='$RX/igdn.sh'              # Instagram download script
alias or='open /Volumes/cold/ulto/'      # Open specific volume in Finder
alias oss='open -a ScreenSaverEngine'    # Start screensaver (macOS)
alias res="source $HOME/.zshenv && szr"  # Reload zshenv and zshrc
alias szr='source-zshrc'                 # Reload zshrc
alias trv='trim-video'                   # Trim video with FFmpeg
alias wst='wezterm cli set-tab-title '   # Set WezTerm tab title
alias zl='zellij'                        # Launch Zellij (terminal multiplexer)

# ===== eza (ls alternative) Aliases =====
alias ls='eza --color=always --icons --git'  # Modern ls with icons and git status
alias la='ls -a --git'                   # List all with git status
alias ldn='ls $HOME/Downloads'           # List Downloads dir
alias lsd='ls -D'                        # List dirs only
alias lsf='ls -f'                        # List files only
alias lt='ls --tree --level=2'           # Tree view, 2 levels
alias lta='ls --tree --level=3 --long --git'  # Detailed tree, 3 levels
alias lx='ls -lbhHgUmuSa@'               # Detailed list with all options
alias tree='tree-with-exclusions'        # Custom tree view (assumes function)

# ===== Directory Navigation Aliases =====
alias ...='../..'                        # Go up 2 directories
alias ....='../../..'                    # Go up 3 directories

# ===== Brew Aliases =====
alias bi='brew install '                 # Install Homebrew package
alias bl='brew list'                     # List installed packages
alias bri='brew reinstall'               # Reinstall package
alias brm='brew uninstall --force --zap' # Uninstall and remove all data
alias bu='brew update; brew upgrade; brew cleanup'  # Update, upgrade, clean
alias bci='brew install --cask '         # Install cask (GUI app)
alias bs='brew search '                  # Search for package

# ===== YouTube-DL Aliases =====
alias ytd='yt-dlp-download'              # Download video with yt-dlp
alias ytx='yt-dlp-extract-audio'         # Extract audio from video
alias ytf="yt-dlp-extract-audio-from-file"  # Extract audio from URL file
alias yta='yt-dlp-download-with-aria2c'  # Download with aria2c support

# ===== Luarocks Aliases =====
alias lri='sudo luarocks install '       # Install Lua package
alias lrl='sudo luarocks list'           # List installed Lua packages
alias lrs='sudo luarocks search '        # Search for Lua package

# ===== Cargo Aliases =====
alias ci='cargo install '                # Install Rust package

# ===== Neovim Aliases =====
alias nv='neovide'                       # Launch Neovide (Neovim GUI)
alias v='nvim'                           # Launch Neovim
alias va='open-aliases'                  # Edit aliases.zsh
alias vf='open-functions'                # Edit functions.zsh
alias vm='open-nvim-init'                # Edit Neovim init.lua
alias vs='open-secrets'                  # Edit secrets (assumes file)
alias vz='open-zshrc'                    # Edit zshrc
alias vh='open-zsh-history'              # Edit zsh history
alias vw='open-wezterm'                  # Edit WezTerm config

# ===== Rclone Aliases =====
alias rcm='rclone-move'                  # Move files with rclone
alias rcc='rclone-copy'                  # Copy files with rclone
alias rdo='rclone-dedupe-old'            # Dedupe, keep oldest
alias rdn='rclone-dedupe-new'            # Dedupe, keep newest

# ===== Tmux Aliases =====
alias t='tmux'                           # Launch tmux
alias ta='tmux a -t '                    # Attach to tmux session
alias tl='tmux ls'                       # List tmux sessions
alias tn='tmux-new-sesh'                 # New tmux session (assumes function)
alias tm="tmuxinator"                    # Launch tmuxinator
alias ttmp="tmux new-session -A -s tmp"  # New or attach to 'tmp' session
