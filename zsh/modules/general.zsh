# ~/.config/zsh/modules/general.zsh
# General-purpose utility functions

timer() {
  termdown "$1"
  cvlc "$HOME/Music/ddd.mp3" --play-and-exit >/dev/null
}

trim-video() {
  if [ $# -eq 3 ]; then
    ffmpeg -i "$2" -ss "$1" -c:v copy -c:a copy "$3"
  elif [ $# -eq 2 ]; then
    ffmpeg -i "$1" -c:v copy -c:a copy "$2"
  else
    echo "Usage: trim-video input output [start-time]"
    return 1
  fi
}

select-pattern() {
  local selection="$1" pattern_dir="$HOME/.config/fabric/patterns"
  local -a patterns
  while IFS= read -r -d '' dir; do
    patterns+=("$dir")
  done < <(find "$pattern_dir" -type d -mindepth 1 -maxdepth 1 -print0)
  if [[ "$selection" -ge 1 && "$selection" -le "${#patterns[@]}" ]]; then
    selected_pattern="${patterns[$((selection-1))]}"
    echo "Selected pattern: $(basename "$selected_pattern")"
  else
    echo "Invalid selection"
    return 1
  fi
}

# function to log function errs and output

log_message() {
  local func_name="$1"
  local level="$2"
  local message="$3"
  local log_dir="${4:-$HOME/log}"
  local error_log="$log_dir/fabric_errors.log"
  local output_log="$log_dir/fabric_output.log"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  mkdir -p "$log_dir"

  case "$level" in
    "ERROR")
      echo "$timestamp - $func_name [$level]: $message" >>"$error_log"
      echo "$level: $message" >&2
      ;;
    "INFO")
      echo "$timestamp - $func_name [$level]: $message" >>"$output_log"
      echo "$message"
      ;;
    *)
      echo "$timestamp - $func_name [UNKNOWN]: $message" >>"$error_log"
      echo "UNKNOWN: $message" >&2
      ;;
  esac
}

slugify() {
  echo "$1" | iconv -t ascii//TRANSLIT | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]'
}

# run sudo purge to clear memory to continue a bit faster
clean_memory() {
  echo "Freeing up system memory..."
  if command -v purge &>/dev/null && [[ "$(uname)" == "Darwin" ]]; then
    sudo purge || echo "Warning: Memory purge failed" >&2
  elif [[ "$(uname)" == "Linux" ]]; then
    echo 3 | sudo tee /proc/sys/vm/drop_caches &>/dev/null || echo "Warning: Memory cleanup failed" >&2
  else
    echo "Warning: Memory cleanup not supported on this OS" >&2
  fi
  sleep 1
}
