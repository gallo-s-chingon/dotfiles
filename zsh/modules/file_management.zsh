# ~/.config/zsh/modules/file-management.zsh
# File and directory management functions

BACKUP_DIR="/Volumes/armor/"

# Move files matching pattern, excluding a directory
# Usage: fd-exclude-dir-find-name-move-to-exclude-dir PATTERN EXCLUDE_DIR
fd-exclude-dir-find-name-move-to-exclude-dir() {
  fd -tf "$1" -E "$2" -x mv {} "$2"  # `-tf` = files only, `-E` = exclude dir
}

# Move files to a directory
# Usage: fd-files-move-to-dir PATTERN TARGET_DIR
fd-files-move-to-dir() {
  fd -tf -d 1 "$1" -x mv -v {} "$2"  # `-d 1` = current dir only
}

# List unique file extensions by directory
fd-type() {
  fd --type d | while read -r dir; do
    echo "$dir"
    eza -1 "$dir" | grep -v '/$' | awk -F. '{print "*."$NF}' | sort -u
  done
}

# Move files larger than 99MB
# Usage: move-repo-files-larger-than-99M
move-repo-files-larger-than-99M() {
  local target_dir="$HOME/jackpot"
  local files_to_move=($(fd -tf -S +99M))  # `-S +99M` = size > 99MB
  for file in "${files_to_move[@]}"; do
    filename="${file##*/}"
    mk "$target_dir/${file%/*}"
    mv "$file" "$target_dir/${file%/*}/$filename"
  done
}

# Create executable script
# Usage: create-script-file NAME
create-script-file() {
  local script_file="$RX/${1}.sh"
  [ -f "$script_file" ] && { echo "(눈︿눈) Script '$script_file' exists."; return 1; }
  mk "$(dirname "$script_file")"
  echo "#!/bin/zsh" > "$script_file"
  chmod +x "$script_file"
}

# Open script in editor
# Usage: open-script-file-in-editor NAME
open-script-file-in-editor() {
  local script_file="$RX/${1}.sh"
  [ -f "$script_file" ] || { echo "(눈︿눈) Script '$script_file' not found."; return 1; }
  nvim "$script_file"
}

# Create and open script
# Usage: create-script-and-open NAME
create-script-and-open() {
  create-script-file "$1"
  open-script-file-in-editor "$1"
}

# Move ISO-like files
move-iso() {
  local source_dir="$DN/"
  local target_dir="$BACKUP_DIR/iso/"
  [ -d "$target_dir" ] || { echo "0-0 Target '$target_dir' not found."; return 1; }
  setopt null_glob  # Prevents errors if no files match
  for ext in iso dmg pkg; do
    for file in "$source_dir"/*.$ext; do
      [ -e "$file" ] && mv "$file" "$target_dir" && echo "( ⋂‿⋂) $(basename "$file") moved."
    done
  done
}

# Add more file management functions as needed...