# ===========================
# File Management Functions
# ===========================
BACKUP_DIR="/Volumes/armor/"

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
  local target_dir="$BACKUP_DIR/iso/nix/"

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

move_ipa_to_target_directory() {
  local source_directory="$DN"
  local target_directory="$BACKUP_DIR/iso/ipa/"

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
  cd /Volumes/cold/ulto/ || return
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

