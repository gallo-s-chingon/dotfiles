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
