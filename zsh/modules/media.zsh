# ~/.config/zsh/modules/media.zsh
# Media processing functions

ffmpeg-remux-audio-video() {
  ffmpeg -i "$1" -i "$2" -c copy "$3"  # `-c copy` = copy streams without re-encoding
}

wmv-to-mp4() {
  find . -maxdepth 2 -type f -name "*.wmv" | while read -r f; do
    ffmpeg -i "$f" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "${f%.wmv}.mp4"
  done
  echo "Conversion complete!"
}

mkv-to-mp4() {
  find . -maxdepth 2 -type f -name "*.mkv" | while read -r f; do
    ffmpeg -i "$f" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "${f%.mkv}.mp4"
  done
  echo "Conversion complete!"
}

spotify-dl() { spotdl download "$1"; }