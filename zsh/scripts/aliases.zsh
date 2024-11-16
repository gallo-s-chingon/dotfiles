# ===== Environment Variables =====
export PATH="$HOME"/myCommands:"$HOME"/myCommands/bin:$PATH
export FZF_DEFAULT_OPTS='--height=40% --cycle --info=hidden --tabstop=4 --black'
export CLICOLOR=1
export EDITOR='nvim'
export MAKEFLAGS="-j$(nproc)"
export CAPTURE_FOLDER="$HOME/Pictures"

# ===== Aliases =====

## General Aliases
alias c='clear'
alias c-='cd -'
alias cdc='cd && c'
alias ctc='copy_file_contents_to_clipboard'
alias dt='date "+%F"'
alias eng="env | grep -i "
alias e='exit 0'
alias ex='expand'
<<<<<<< HEAD
alias ffav='ffmpeg_remux_audio_video'
=======
alias sdd='spotify_dl'
>>>>>>> 8301065 (updates to aliases & functions)
alias grep='grep --color=auto'
alias ln='ln -i'
alias mnf='mediainfo'
alias o.='open .'
alias c-='cd -'
alias ptc='paste_output_to_clipboard'
alias nowrap='setterm --linewrap off'
alias wrap='setterm --linewrap on'

## Git Aliases
alias g='git'
alias gad='git_add'
alias gac='git_add_commit_push'
alias gcm='git_commit_message'
alias gcs='git_check_status' # check the status of local repos, dirs listed at top of functions.zsh
alias gfh='git fetch'
alias gpl='git_pull'
alias gla='git_pull_all'
alias gph='git_push'
alias gst='git status'

## File Management Aliases
alias bydate='$RX/sort-file-by-date.sh'
alias d='fd -H -t f .DS_Store -X rm -frv'
alias fdm='fd_files_move_to_dir'
alias fdd='fd_exclude_dir_find_name_move_to_exclude_dir'
alias fdf='fd -tf -d 1 '
alias f='fzf '
alias free='freespace'
alias ft='fd_type'
alias mk='mkdir -pv'
alias mia='move_ipa_to_target_directory'
alias mio='move_iso'
alias mtt='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv $HOME/.Trash'
alias rm='rm -rfv'
alias orgf='$RX/sort-file-by-date'
alias sdd='spotdl_error_logger'
alias srm='sudo rm -rfv'
alias mkrx='create_script_and_open'

## Torrent Management Aliases
alias mat='move_all_torrents'
alias mnx='move_nix'
alias mvb='move_btn_torrents'
alias mvm='move_mam_torrents'
alias mvp='move_ptp_torrents'
alias mve='move_emp_torrents'
alias mlf='move_repo_files_larger_than_99M'
alias obt='open_btn_torrents_in_transmission'
alias opt='open_ptp_torrents_in_deluge'
alias odt='open_downloaded_torrents'

## Blog Aliases
alias blog='$RX/blog.sh blog'
alias epi='$RX/blog.sh epi'
alias feat='$RX/blog.sh feat'

## Image Management Aliases
alias 50p='imagemagick_resize_50'
alias 500='imagemagick_resize_500'
alias 720='imagemagick_resize_720'
alias coltxt='pick_color_fill_text'
alias mpx='move_download_pix_to_pictures_dir'
alias rpx='remove_pix'
alias shave='imagemagick_shave'
alias ytt='youtube_thumbnail'

## Miscellaneous Aliases
alias clock='tty-clock -B -C 5 -c'
alias instadl='$RX/igdn.sh'
alias or='open /Volumes/cold/ulto/'
alias oss='open -a ScreenSaverEngine'
alias res="source $HOME/.zshenv && szr"
alias szr='source_zshrc'
alias trv='trim_video'
alias wst='wezterm cli set-tab-title '
alias zl='zellij'

## eza (ls alternative)
alias ls='eza --color=always --icons --git '
alias la='ls -a --git'
alias ldn='ls $HOME/Downloads'
alias lsd='ls -D'
alias lsf='ls -f'
alias lt='ls --tree --level=2'
alias lta='ls --tree --level=3 --long --git'
alias lx='ls -lbhHgUmuSa@'
alias tree='tree_with_exclusions'

## Directory Navigation Aliases
alias ...='../..'
alias ....='../../..'

## Brew Aliases
alias bi='brew install '
alias bl='brew list'
alias bri='brew reinstall'
alias brm='brew remove --zap'
alias bu='brew update; brew upgrade; brew cleanup'
alias bci='brew install --cask '
alias bs='brew search '

## YouTube-DL
alias ytd='yt_dlp_download'
alias ytx='yt_dlp_extract_audio'
alias ytf="yt_dlp_extract_audio_from_file"
alias yta='yt_dlp_download_with_aria2c'

## Luarocks Aliases
alias lri='sudo luarocks install '
alias lrl='sudo luarocks list'
alias lrs='sudo luarocks search '

## Cargo Aliases
alias ci='cargo install '

## Nvim Aliases
alias v='nvim'
alias va='open_aliases'
alias vf='open_functions'
alias vm='open_nvim_init'
alias vs='open_secrets'
alias vz='open_zshrc'
alias vh='open_zsh_history'
alias vw='open_wezterm'

## Rclone Aliases
alias rcm='rclone_move'
alias rcc='rclone_copy'
alias rdo='rclone_dedupe_old'
alias rdn='rclone_dedupe_new'

## Tmux Aliases
alias t='tmux'
alias ta='tmux a -t '
alias tl='tmux ls'
alias tn='tmux_new_sesh'
alias tm="tmuxinator"
alias ttmp="tmux new-session -A -s tmp"

# ===== Trap =====
trap 'update_zwc' EXIT
