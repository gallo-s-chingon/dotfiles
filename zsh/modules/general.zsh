# ~/.config/zsh/modules/general.zsh
# General-purpose utility functions

# Countdown timer with sound
# Usage: timer DURATION (e.g., "5m")
timer() {
  termdown "$1"
  cvlc "$HOME/Music/ddd.mp3" --play-and-exit >/dev/null  # `cvlc` = VLC CLI
}

# Slugify filename
# Usage: slug FILENAME
slug() {
  [ $# -ne 1 ] && { echo "(￣ヘ￣) Usage: slug <filename>"; return 1; }
  echo "$(slugged "$1")"  # Assumes `slugged` is custom; adjust if needed
}

# Trim video
# Usage: trim-video START INPUT OUTPUT or trim-video INPUT OUTPUT
trim-video() {
  if [ $# -eq 3 ]; then
    ffmpeg -i "$2" -ss "$1" -c:v copy -c:a copy "$3"  # `-ss` = start time
  elif [ $# -eq 2 ]; then
    ffmpeg -i "$1" -c:v copy -c:a copy "$2"
  else
    echo "Usage: trim-video input output [start-time]"
    return 1
  fi
}