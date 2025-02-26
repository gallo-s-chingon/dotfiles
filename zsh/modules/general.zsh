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
