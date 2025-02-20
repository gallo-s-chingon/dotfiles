# ~/.config/zsh/modules/file-management.zsh
# File and directory management functions

BACKUP_DIR="/Volumes/armor/"

fd-exclude-dir-find-name-move-to-exclude-dir() {
  fd -tf "$1" -E "$2" -x mv {} "$2"  # `-tf` = files only, `-E` = exclude dir
}

fd-files-move-to-dir() {
  fd -tf -d 1 "$1" -x mv -v {} "$2"  # `-d 1` = current dir only
}

fd-type() {
  fd --type d | while read -r dir; do
    echo "$dir"
    eza -1 "$dir" | grep -v '/$' | awk -F. '{print "*."$NF}' | sort -u
  done
}

move-repo-files-larger-than-99M() {
  local target_dir="$HOME/jackpot"
  local files_to_move=($(fd -tf -S +99M))  # `-S +99M` = size > 99MB
  for file in "${files_to_move[@]}"; do
    filename="${file##*/}"
    mk "$target_dir/${file%/*}"
    mv "$file" "$target_dir/${file%/*}/$filename"
  done
}

create-script-file() {
  local script_file="$RX/${1}.sh"
  [ -f "$script_file" ] && { echo "(눈︿눈) Script '$script_file' exists."; return 1; }
  mk "$(dirname "$script_file")"
  echo "#!/bin/zsh" > "$script_file"
  chmod +x "$script_file"
}

open-script-file-in-editor() {
  local script_file="$RX/${1}.sh"
  [ -f "$script_file" ] || { echo "(눈︿눈) Script '$script_file' not found."; return 1; }
  nvim "$script_file"
}

create-script-and-open() {
  create-script-file "$1"
  open-script-file-in-editor "$1"
}

move-iso() {
  local source_dir="$DN/"
  local target_dir="$BACKUP_DIR/iso/"
  [ -d "$target_dir" ] || { echo "0-0 Target '$target_dir' not found."; return 1; }
  setopt null_glob
  for ext in iso dmg pkg; do
    for file in "$source_dir"/*.$ext; do
      [ -e "$file" ] && mv "$file" "$target_dir" && echo "( ⋂‿⋂) $(basename "$file") moved."
    done
  done
}

move-nix() {
  local source_dir="$DN/"
  local target_dir="$BACKUP_DIR/iso/nix/"
  [ -d "$target_dir" ] || { echo "0-0 Target '$target_dir' not found."; return 1; }
  setopt null_glob
  for file in "$source_dir"/*.iso; do
    [ -e "$file" ] && mv "$file" "$target_dir" && echo "( ⋂‿⋂) $(basename "$file") moved."
  done
}

move-download-pix-to-pictures-dir() {
  local source_dir="$DN/"
  local target_dir="$HOME/Pictures/"
  setopt null_glob
  for ext in heic jpg jpeg png webp; do
    for file in "$source_dir"/*.$ext; do
      [ -e "$file" ] && mv "$file" "$target_dir" && echo "( ⋂‿⋂) $(basename "$file") moved."
    done
  done
}

move-ipa-to-target-directory() {
  local source_dir="$DN"
  local target_dir="$BACKUP_DIR/iso/ipa/"
  for file in "$source_dir"/*.ipa; do
    [ -e "$file" ] && mv "$file" "$target_dir" && echo "( ⋂‿⋂) $(basename "$file") moved."
  done
}

remove-pix() {
  local old_dir="$PWD"
  cd /Volumes/cold/ulto/ || return
  fd -e jpg -e jpeg -e png -e webp -e nfo -e txt -x rm -v {} \;  # `-e` = extension match
  cd "$old_dir" || return
}

expand() {
  for filename in "$@"; do
    if [ -f "$filename" ]; then
      case "$filename" in
        *.tar.bz2) tar xjf "$filename" ;;  # Extract tar.bz2
        *.tar.gz) tar xzf "$filename" ;;   # Extract tar.gz
        *.bz2) bunzip2 "$filename" ;;      # Extract bz2
        *.rar) unrar x "$filename" ;;      # Extract rar
        *.gz) gunzip "$filename" ;;        # Extract gz
        *.tar) tar xf "$filename" ;;       # Extract tar
        *.tbz2) tar xjf "$filename" ;;     # Extract tbz2
        *.tgz) tar xzf "$filename" ;;      # Extract tgz
        *.zip) unzip "$filename" ;;        # Extract zip
        *.Z) uncompress "$filename" ;;     # Extract Z
        *.7z) 7z x "$filename" ;;         # Extract 7z
        *) echo "(눈︿눈) '$filename' cannot be extracted." ;;
      esac
    else
      echo "(눈︿눈) '$filename' not found."
    fi
  done
}

mkd() {
  mk "$@" && cd "$@" || return  # Create dir and cd into it
}

bak() {
  local file="$1" filename="${file%.*}" extension="${file##*.}"
  if [[ "$extension" == "bak" ]]; then
    local base_filename="${filename%.*}"
    mv "$file" "$base_filename"
    echo "Removed .bak from $file. New name: $base_filename"
  else
    local new_filename="${file}.bak"
    [ -e "$new_filename" ] && { echo "(눈︿눈) $new_filename exists."; return; }
    mv "$file" "$new_filename"
    echo "Added .bak to $file. New name: $new_filename"
  fi
}

debak() {
  local target="$1"
  if [[ "$target" == *".bak"* ]]; then
    new_name=$(echo "$target" | sed 's/\.bak//g')
    [ -e "$new_name" ] && { echo "(눈︿눈) '$new_name' exists."; return 1; }
    mv "$target" "$new_name"
    echo "Removed .bak from '$target'. New name: '$new_name'"
  else
    echo "No .bak found in '$target'."
  fi
}