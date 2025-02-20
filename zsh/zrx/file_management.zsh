# ===========================
# File Management Functions
# ===========================

BACKUP-DIR="/Volumes/armor/"

fd-exclude-dir-find-name-move-to-exclude-dir()
{
  fd -tf "$1" -E "$2" -x mv {} "$2"
}

fd-files-move-to-dir() {
  fd -tf -d 1 "$1" -x mv -v {} "$2"
}

fd-type() {
  fd --type d | while read -r dir; do
    echo "$dir"
    eza -1 "$dir" | grep -v '/$' | awk -F. '{print "*."$NF}' | sort -u
  done
}

move-repo-files-larger-than-99M() {
    local pwd-command="$1"
    local target-dir="$HOME/jackpot"
    local files-to-move=($(fd -tf -S +99M))

    for file in "${files-to-move[@]}"; do
        filename="${file##*/}" # Get the filename without the path
        mk "$target-dir/${file%/*}" # Create the target directory structure if it doesn't exist
        mv "$file" "$target-dir/${file%/*}/$filename" # Move the file to the target directory
    done
}

## Create and Open Script Files
create-script-file() {
  local script-name="${1}.sh"
  local script-file="${HOME}/.config/rx/${script-name}"

  if [ -f "$script-file" ]; then
    echo "(눈︿눈)  Script file '$script-file' already exists."
    return 1
  fi

  mk "$(dirname "${script-file}")"
  cat > "$script-file" << EOF
#!/bin/zsh
EOF
  chmod +x "$script-file"
}

open-script-file-in-editor() {
  local script-name="${1}.sh"
  local script-file="${HOME}/.config/rx/${script-name}"

  if [ ! -f "$script-file" ]; then
    echo "(눈︿눈)  Script file '$script-file' does not exist."
    return 1
  fi

  nvim "$script-file"
}

create-script-and-open() {
  create-script-file "$1"
  open-script-file-in-editor "$1"
}

## Move Files
move-iso() {
  local source-dir="$DN/"
  local target-dir="/Volumes/armor/iso/"

  if [ ! -d "$target-dir" ]; then
    echo "0-0 you tard, $target-dir does NOT exist"
    return 1
  fi

  setopt null-glob
  for extension in iso dmg pkg; do
    for file in "$source-dir"/*.$extension(N); do
      if [ -e "$file" ]; then
        mv "$file" "$target-dir"
        echo "( ⋂‿⋂) $(basename "$file") made its way to $target-dir"
      fi
    done
  done
}

move-nix() {
  local source-dir="$DN/"
  local target-dir="$BACKUP-DIR/iso/nix/"

  if [ ! -d "$target-dir" ]; then
    echo "0-0 you tard, $target-dir does NOT exist"
    return 1
  fi

  setopt null-glob
  for extension in iso; do
    for file in "$source-dir"/*.$extension(N); do
      if [ -e "$file" ]; then
        mv "$file" "$target-dir"
        echo "( ⋂‿⋂) $(basename "$file") made its way to $target-dir"
      fi
    done
  done
}

move-download-pix-to-pictures-dir() {
  local source-dir="$DN/"
  local target-dir="$HOME/Pictures/"

  setopt null-glob
  for extension in heic jpg jpeg png webp; do
    for file in "$source-dir"/*.$extension(N); do
      if [ -e "$file" ]; then
        mv "$file" "$target-dir"
        echo "( ⋂‿⋂) $(basename "$file") made its way to $target-dir"
      fi
    done
  done
}

move-ipa-to-target-directory() {
  local source-directory="$DN"
  local target-directory="$BACKUP-DIR/iso/ipa/"

  for file in "$source-directory"/*.ipa; do
    if [ -e "$file" ]; then
      mv "$file" "$target-directory"
      echo "( ⋂‿⋂) $(basename "$file") was moved to $target-directory"
    fi
  done
}

## Remove Files
remove-pix() {
  local old-dir="$PWD"
  cd /Volumes/cold/ulto/ || return
  fd -e jpg -e jpeg -e png -e webp -e nfo -e txt -x rm -v {} \;
  cd "$old-dir" || return
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
  mk "$@" && cd "$@" || return
}

## Backup and Restore Files
bak() {
  local file="$1"
  local filename="${file%.*}"
  local extension="${file##*.}"

  if [[ "$extension" == "bak" ]]; then
    local base-filename="${filename%.*}"
    mv "$file" "$base-filename"
    echo "Removed .bak extension from $file. New filename: $base-filename"
  else
    local new-filename="${file}.bak"
    if [[ -e "$new-filename" ]]; then
      echo "(눈︿눈)  $new-filename already exists."
    else
      mv "$file" "$new-filename"
      echo "Appended .bak extension to $file. New filename: $new-filename"
    fi
  fi
}

debak() {
  local target=$1
  local new-name

  if [[ "$target" == *".bak"* ]]; then
    new-name=$(echo "$target" | sed 's/\.bak//g')
    if [ -e "$new-name" ]; then
      echo "(눈︿눈)  File or directory '$new-name' already exists."
      return 1
    fi
    mv "$target" "$new-name"
    echo "Removed .bak from '$target'. New name: '$new-name'"
  else
    echo "No .bak found in '$target'."
  fi
}

