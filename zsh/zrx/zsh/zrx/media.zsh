# media.zsh

trim-video() {
  if [ $# -eq 3 ]; then
    ffmpeg -i "$2" -ss "$1" -c:v copy -c:a copy "$3"
  elif [ $# -eq 2 ]; then
    ffmpeg -i "$1" -c:v copy -c:a copy "$2"
  else
    echo "Usage: trim-video input-file output-file (start-time)"
    return 1
  fi
}

ffmpeg-remux-audio-video() {
  ffmpeg -i "$1" -i "$2" -c copy "$3"
}

wmv-to-mp4() {
  find . -maxdepth 2 -type f -name "*.wmv" | while read -r f; do
    output-file="${f%.wmv}.mp4"
    ffmpeg -i "$f" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "$output-file"
  done
  echo "Conversion complete!"
}

mkv-to-mp4() {
  find . -maxdepth 2 -type f -name "*.mkv" | while read -r f; do
    output-file="${f%.mkv}.mp4"
    ffmpeg -i "$f" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "$output-file"
  done
  echo "Conversion complete!"
}

spotify-dl() {
  spotdl download "$1"
}
ffmpeg-remux-audio-video (){
  ffmpeg -i "$1" -i "$2" -c copy "$3"
}
