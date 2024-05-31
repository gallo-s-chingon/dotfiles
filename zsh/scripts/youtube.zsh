# ===========================
# YouTube-DL Functions
# ===========================

yt_dlp_download() {
  yt-dlp --embed-chapters --no-warnings --format "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" -o "%(title)s.%(ext)s" "$@"
}

yt_dlp_extract_audio() {
  yt-dlp -x --audio-format mp3 --write-thumbnail -o "%(title)s.%(ext)s" "$@"
}

yt_dlp_extract() {
  yt-dlp -x -o "%(title)s.%(ext)s" "$@"
}

yt_dlp_download_with_aria2c() {
  yt-dlp --no-warnings --part --external-downloader aria2c --format "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" -o "%(title)s.%(ext)s" --cookies-from-browser firefox "$@"
}

