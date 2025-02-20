# ~/.config/zsh/modules/clipboard.zsh
# Clipboard manipulation functions

# Read file content
# Usage: read-file-content FILE
read-file-content() {
  local file_path="$1"
  [ -f "$file_path" ] || { echo "(눈︿눈) File '$file_path' does not exist."; return 1; }
  cat "$file_path"
}

# Copy file contents to clipboard
# Usage: copy-file-contents-to-clipboard FILE
copy-file-contents-to-clipboard() {
  read-file-content "$1" | pbcopy  # `pbcopy` copies to macOS clipboard
}

# Paste clipboard to file
# Usage: paste-to-file FILE
paste-to-file() {
  [ -z "$1" ] && { echo "┐(￣ヘ￣)┌ Usage: paste-to-file <filename>"; return 1; }
  echo "$(pbpaste)" >> "$1"  # `pbpaste` retrieves from macOS clipboard
}

# Copy command output to clipboard
# Usage: paste-output-to-clipboard COMMAND
paste-output-to-clipboard() {
  [ -z "$1" ] && { echo "٩(•̀ᴗ•́)و Usage: paste-output-to-clipboard <command>"; return 1; }
  eval "$1" | pbcopy
}