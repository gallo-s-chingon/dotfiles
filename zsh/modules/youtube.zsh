# ~/.config/zsh/modules/youtube.zsh
# YouTube-DL functions

yt-dlp-download() {
  yt-dlp --embed-chapters --no-warnings --format "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" \
    -o "%(title)s.%(ext)s" "$@"
}

yt-dlp-extract-audio() {
  yt-dlp -x --audio-format "mp3/m4a" --audio-quality 0 --write-thumbnail \
    --embed-metadata --concurrent-fragments 6 --yes-playlist \
    -o "%(artist)s - %(title)s.%(ext)s" --ignore-errors --no-overwrites --continue "$@"
}

yt-dlp-extract-audio-from-file() {
  local source_file="$1" temp_file=$(mktemp) output_template="%(title)s.%(ext)s"
  while IFS= read -r url || [[ -n "$url" ]]; do
    existing_file=$(yt-dlp --get-filename -o "$output_template" --format "mp3/m4a" "$url")
    [[ -f "$existing_file" ]] && continue
    yt-dlp -x --format "mp3/m4a" --audio-quality 0 --write-thumbnail --embed-metadata \
      --concurrent-fragments 6 --yes-playlist -o "$output_template" --ignore-errors \
      --no-overwrites --cookies "$HOME/Desktop/cookies.txt" --continue "$url" || \
      echo "$url" >> "$temp_file"
  done < "$source_file"
  mv "$temp_file" "$source_file"
  echo "Completed. Failed URLs remain in $source_file"
}

spotdl-error-logger() {
  local LOG_FILE="$(pwd)/download_errors.log" TEMP_LOG_FILE="$(pwd)/temp_errors.log"
  local GREEN='\033[0;32m' RED='\033[0;31m' NC='\033[0m'
  true > "$LOG_FILE"  # Clear log
  true > "$TEMP_LOG_FILE"
  spotdl "$@" 2>&1 | while IFS= read -r line; do
    echo "$line"
    [[ "$line" == *"youtube"* ]] && echo "$line" >> "$TEMP_LOG_FILE"
  done
  grep -oE 'https?://[^ ]+' "$TEMP_LOG_FILE" | sort -u > "$LOG_FILE" && rm "$TEMP_LOG_FILE"
  [ -s "$LOG_FILE" ] && { echo -e "\n${GREEN}Log at: $LOG_FILE\nContents:${NC}"; cat "$LOG_FILE"; } || \
    echo -e "\n${RED}No errors logged.${NC}"
}