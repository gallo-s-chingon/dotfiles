# ===========================
# Torrent Management Functions
# ===========================
TORRENT_DIR='/Volumes/kalisma/torrent'
BACKUP_DIR='/Volumes/armor'
## Open Torrent Files
function open_downloaded_torrents() {
  open $DN/*.torrent
  open -a wezterm
}

## Move Torrent Files
move_emp_torrents() {
  local source_dir="$DN"
  local target_dir="$TORRENT_DIR/EMP"
  fd -e torrent Empornium --search-path "$source_dir" -X mv -v {} "$target_dir"
}

move_mam_torrents() {
  local source_dir="$DN"
  local target_dir="$TORRENT_DIR/MAM"
  fd -e torrent "[^[0-9]{6,6}]" --search-path "$source_dir" -X mv -v {} "$target_dir"
}

move_btn_torrents() {
  local destination="$TORRENT_DIR/BTN"
  local torrents=(~/Downloads/*.torrent(N))

  for torrent_file in "${torrents[@]}"; do
    local tracker_info=$(transmission-show "$torrent_file" | grep -o "landof")
    if [ -n "$tracker_info" ]; then
      mv -v "$torrent_file" "$destination"
    fi
  done
}

open_btn_torrents_in_transmission() {
  for torrent_file in "${torrents[@]}"; do
    local tracker_info=$(transmission-show "$torrent_file" | grep -o "landof")
    if [ -n "$tracker_info" ]; then
      open -a "Transmission" "$torrent_file"
    fi
  done
}

move_ptp_torrents () {
    local destination="$TORRENT_DIR/PTP"
    local torrents=(~/Downloads/*.torrent(N))
    for torrent_file in "${torrents[@]}"; do
        local tracker_info=$(transmission-show "$torrent_file" | grep -o "passthepopcorn")
        if [ -n "$tracker_info" ]; then
            mv -v "$torrent_file" "$destination"
        fi
    done
}

open_ptp_torrents_in_deluge () {
    local torrents=(~/Downloads/*.torrent(N))
    for torrent_file in "${torrents[@]}"; do
        local tracker_info=$(transmission-show "$torrent_file" | grep -o "passthepopcorn")
        if [ -n "$tracker_info" ]; then
            open -a "Deluge" "$torrent_file"
        fi
    done
}

move_all_torrents() {
  move_emp_torrents
  move_ptp_torrents
  move_mam_torrents
  move_btn_torrents
  open -a wezterm
}

# ===========================
# File Management Functions
# ===========================

freespace(){
  if [[ -z "$1" ]]; then
    echo "┐(￣ヘ￣)┌  $0 <disk>"
    echo "Example: $0 /dev/disk1s1"
    echo
    echo "Possible disks:"
    df -h | awk 'NR == 1 || /^\/dev\/disk/'
    return 1
  fi

  echo "٩(•̀ᴗ•́)و  Cleaning purgeable files from disk: $1 ...."
  diskutil secureErase freespace 0 $1
}

move_repo_files_larger_than_99M() {
    local pwd_command="$1"
    local target_dir="$HOME/jackpot"
    local files_to_move=($(fd -tf -S +99M))

    for file in "${files_to_move[@]}"; do
        filename="${file##*/}" # Get the filename without the path
        mkdir -p "$target_dir/${file%/*}" # Create the target directory structure if it doesn't exist
        mv "$file" "$target_dir/${file%/*}/$filename" # Move the file to the target directory
    done
}

## Create and Open Script Files
create_script_file() {
  local script_name="${1}.sh"
  local script_file="${HOME}/.config/rx/${script_name}"

  if [ -f "$script_file" ]; then
    echo "(눈︿눈)  Script file '$script_file' already exists."
    return 1
  fi

  mkdir -p "$(dirname "${script_file}")"
  cat > "$script_file" << EOF
#!/bin/zsh
EOF
  chmod +x "$script_file"
}

open_script_file_in_editor() {
  local script_name="${1}.sh"
  local script_file="${HOME}/.config/rx/${script_name}"

  if [ ! -f "$script_file" ]; then
    echo "(눈︿눈)  Script file '$script_file' does not exist."
    return 1
  fi

  nvim "$script_file"
}

create_script_and_open() {
  create_script_file "$1"
  open_script_file_in_editor "$1"
}

## Move Files
move_iso() {
  local source_dir="$DN/"
  local target_dir="/Volumes/armor/iso/"

  if [ ! -d "$target_dir" ]; then
    echo "0_0 you tard, $target_dir does NOT exist"
    return 1
  fi

  setopt null_glob
  for extension in iso dmg pkg; do
    for file in "$source_dir"/*.$extension(N); do
      if [ -e "$file" ]; then
        mv "$file" "$target_dir"
        echo "( ⋂‿⋂) $(basename "$file") made its way to $target_dir"
      fi
    done
  done
}

move_nix() {
  local source_dir="$DN/"
  local target_dir="BACKUP_DIR/iso/nix/"

  if [ ! -d "$target_dir" ]; then
    echo "0_0 you tard, $target_dir does NOT exist"
    return 1
  fi

  setopt null_glob
  for extension in iso; do
    for file in "$source_dir"/*.$extension(N); do
      if [ -e "$file" ]; then
        mv "$file" "$target_dir"
        echo "( ⋂‿⋂) $(basename "$file") made its way to $target_dir"
      fi
    done
  done
}

move_download_pix_to_pictures_dir() {
  local source_dir="$DN/"
  local target_dir="$HOME/Pictures/"

  setopt null_glob
  for extension in heic jpg jpeg png webp; do
    for file in "$source_dir"/*.$extension(N); do
      if [ -e "$file" ]; then
        mv "$file" "$target_dir"
        echo "( ⋂‿⋂) $(basename "$file") made its way to $target_dir"
      fi
    done
  done
}

move_ipa() {
  check_source_directory_existence || return 1
  move_ipa_to_target_directory
}

move_ipa_to_target_directory() {
  local source_directory="$DN"
  local target_directory="BACKUP_DIR/iso/ipa/"

  for file in "$source_directory"/*.ipa; do
    if [ -e "$file" ]; then
      mv "$file" "$target_directory"
      echo "( ⋂‿⋂) $(basename "$file") was moved to $target_directory"
    fi
  done
}

## Remove Files
remove_pix() {
  local old_dir="$PWD"
  cd /Volumes/noir/rawn/ || return
  fd -e jpg -e jpeg -e png -e webp -e nfo -e txt -x rm -v {} \;
  cd "$old_dir" || return
}

## Extract Archives
expand() {
  for filename in "$@"; do
    if [ -f "$filename" ]; then
      case "$filename" in
        *.tar.bz2) tar xjf "$filename" ;;
        *.tar.gz) tar xzf "$filename" ;;
        *.bz2) bunzip2 "$filename" ;;
        *.rar) unrar x "$filename" ;;
        *.gz) gunzip "$filename" ;;
        *.tar) tar xf "$filename" ;;
        *.tbz2) tar xjf "$filename" ;;
        *.tgz) tar xzf "$filename" ;;
        *.zip) unzip "$filename" ;;
        *.Z) uncompress "$filename" ;;
        *.7z) 7z x "$filename" ;;
        *) echo "(눈︿눈) '$filename' cannot be extracted via ex()" ;;
      esac
    else
      echo "(눈︿눈) '$filename' is not found"
    fi
  done
}

## Create and Navigate to Directory
mkd() {
  mkdir -p "$@" && cd "$@" || return
}

## Backup and Restore Files
bak() {
  local file="$1"
  local filename="${file%.*}"
  local extension="${file##*.}"

  if [[ "$extension" == "bak" ]]; then
    local base_filename="${filename%.*}"
    mv "$file" "$base_filename"
    echo "Removed .bak extension from $file. New filename: $base_filename"
  else
    local new_filename="${file}.bak"
    if [[ -e "$new_filename" ]]; then
      echo "(눈︿눈)  $new_filename already exists."
    else
      mv "$file" "$new_filename"
      echo "Appended .bak extension to $file. New filename: $new_filename"
    fi
  fi
}

debak() {
  local target=$1
  local new_name

  if [[ "$target" == *".bak"* ]]; then
    new_name=$(echo "$target" | sed 's/\.bak//g')
    if [ -e "$new_name" ]; then
      echo "(눈︿눈)  File or directory '$new_name' already exists."
      return 1
    fi
    mv "$target" "$new_name"
    echo "Removed .bak from '$target'. New name: '$new_name'"
  else
    echo "No .bak found in '$target'."
  fi
}

# ===========================
# Rclone functions
# ===========================

base_opts="-P --exclude-from $XDG_CONFIG_HOME/clear --fast-list"
move_opts="--delete-empty-src-dirs"
new_dedupe="--dedupe-mode newest"
old_dedupe="--dedupe-mode oldest"

# rename rclone_operation function to rco for simplicity
function rclone_modular_function() {
    local operation="$1"
    local source_dir="$2"
    local target_dir="$3"

    if [ ! -e "$source_dir" ]; then
        echo "(눈︿눈)   Source file or directory '$source_dir' does not exist."
        return 1
    fi

    case "$operation" in
        cp)
            rcc "$source_dir" "$target_dir"
            ;;
        mv)
            rcm "$source_dir" "$target_dir"
            ;;
        deold) # may be counter intuitive but deold in my mind is remove old
            rcdn "$source_dir"
            ;;
        denew) # may be counter intuitive but denew in my mind is remove old
            rcdo "$source_dir"
            ;;
        *)
            echo "Invalid operation: $operation"
            return 1
            ;;
    esac
}

## Copy with rclone
# usage: rcc <source_dir> <target_dir>
function rclone_copy() {
    local source_dir="$1"
    local target_dir="$2"
    rclone copy "$source_dir" "$target_dir" "$base_opts"
}

## Move with rclone
# usage: rcm <source_dir> <target_dir>
function rclone_move() {
    local source_dir="$1"
    local target_dir="$2"
    rclone move "$source_dir" "$target_dir" "$base_opts" "$move_opts"
}

## Dedupe with rclone keeping newest files
# usage: rcdn <source_dir>
function rclone_dedupe_new() {
    local source_dir="$1"
    rclone dedupe --by-hash "$source_dir" "$new_dedupe" "$base_opts"
}

## Dedupe with rclone keeping oldest files
# usage: rcdo <source_dir>
function rclone_dedupe_old() {
    local source_dir="$1"
    rclone dedupe --by-hash "$source_dir" "$old_dedupe" "$base_opts"
}


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
  eval "$(ssh-agent -s)"
  if is_apple_silicon; then
    ssh-add --apple-use-keychain $HOME/.ssh/id_ed25519
  else
    ssh-add $HOME/.ssh/id_ed25519
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

# ===========================
# YouTube-DL Functions
# ===========================

yt_dlp_download() {
  yt-dlp --embed-chapters --no-warnings --format "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" -o "%(title)s.%(ext)s" "$@"
}

yt_dlp_extract_audio() {
  yt-dlp --x --audio-format mp3 --write-thumbnail -o "%(title)s.%(ext)s" "$@"
}

yt_dlp_extract() {
  yt-dlp -x -o "%(title)s.%(ext)s" "$@"
}

yt_dlp_download_with_aria2c() {
  yt-dlp --no-warnings --part --external-downloader aria2c --format "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" -o "%(title)s.%(ext)s" --cookies-from-browser firefox "$@"
}

# ===========================
# ImageMagick Functions
# ===========================

imagemagick_resize_50() {
  magick "$1" -resize 50% "$2"
}

imagemagick_resize_500() {
  magick "$1" -resize 500 "$2"
}

imagemagick_resize_720() {
  magick "$1" -resize 720 "$2"
}

imagemagick_shave() {
  magick "$1" -shave "$3" "$2"
}

# ===========================
# Clipboard Functions
# ===========================

read_file_content() {
  local file_path="$1"
  if [ ! -f "$file_path" ]; then
    echo "(눈︿눈)  File '$file_path' does not exist."
    return 1
  fi
  cat "$file_path"
}

copy_file_contents_to_clipboard() {
  read_file_content "$1" | pbcopy
}

paste_to_file() {
  if [ -z "$1" ]; then
    echo "┐(￣ヘ￣)┌  paste_to_file <filename>"
    return 1
  fi
  echo "$(pbpaste)" >> "$1"
}

paste_output_to_clipboard() {
  if [ -z "$1" ]; then
    echo "٩(•̀ᴗ•́)و  Copying command output to clipboard"
    return 1
  fi
  eval "$1" | pbcopy
}

# ===========================
# Filename Cleaning Functions
# ===========================

update_zwc () {
  compile_zdot() { [ -f "$1" ] && zcompile "$1" && info "Compiled $1" }
  compile_zdot "$HOME/.config/zsh/*.zsh"
  compile_zdot "$HOME/.config/zsh/z*"
  return 0
}

slug() {
    if [ $# -ne 1 ]; then
        echo "┐(￣ヘ￣)┌  run_slugify <filename>"
        return 1
    fi

    filename=$1
    slugified=$(slugify -atcdu "$filename")
    echo "$slugified"
}

# ===========================
# Miscellaneous Functions
# ===========================

source_zshrc() {
  source $HOME/.config/zsh/zshrc >/dev/null 2>&1
}

tmux_new_sesh() {
  tmux new-session -A -s "$1"
}

timer() {
  termdown "$1"
  cvlc "$HOME/Music/ddd.mp3" --play-and-exit >/dev/null 2>/dev/null
}

tree_with_exclusions() {
  tree -a -I ".DS_Store|.git|node_modules|vendor/bundle" -N
}

fd_exclude_dir_find_name_move_to_exclude_dir()
{
  fd -tf "$1" -E "$2" -x mv {} "$2"
}

fd_files_move_to_dir() {
  fd -tf -d 1 "$1" -x mv {} "$2"
}

fd_type() {
  fd --type d | while read -r dir; do
    echo "$dir"
    eza -1 "$dir" | grep -v '/$' | awk -F. '{print "*."$NF}' | sort -u
  done
}

open_nvim_init() {
  nvim "$XDG_CONFIG_HOME/nvim/init.lua"
}

open_wezterm() {
  nvim "$XDG_CONFIG_HOME/wezterm.lua"
}

open_zshrc() {
  nvim "$DOTZ/zshrc"
}

open_aliases() {
  nvim "$DOTZ/aliases.zsh"
}

open_functions() {
  nvim "$DOTZ/functions.zsh"
}

open_secrets() {
  nvim "$HOME/.mySecrets.env"
}

open_zsh_history() {
  vim "$XDG_CACHE_HOME/zsh/.zsh_history"
}
