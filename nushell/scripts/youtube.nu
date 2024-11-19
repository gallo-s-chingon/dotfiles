# ===========================
# YouTube-DL Functions
# ===========================

def yt_dlp_download [...args: string] {
    ^yt-dlp --embed-chapters --no-warnings --format "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" -o "%(title)s.%(ext)s" $args
}

def yt_dlp_extract_audio [...args: string] {
    ^yt-dlp -x --audio-format "mp3/m4a" --audio-quality 0 --write-thumbnail --embed-metadata --concurrent-fragments 6 --yes-playlist -o "%(artist)s - %(title)s.%(ext)s" --ignore-errors --no-overwrites --continue $args
}

def yt_dlp_extract_audio_from_file [source_file: string] {
    let temp_file = (mktemp)
    let output_template = "%(title)s.%(ext)s"

    while read -r url; do
        let existing_file = (^yt-dlp --get-filename -o $output_template --format "mp3/m4a" $url)
        if ($existing_file | path exists) {
            continue
        }

        if (^yt-dlp -x --format "mp3/m4a" --audio-quality 0 --write-thumbnail --embed-metadata --concurrent-fragments 6 --yes-playlist -o $output_template --ignore-errors --no-overwrites --cookies "$HOME/Desktop/cookies.txt" --continue $url | is-success); then
            : # Do nothing on success
        else
            echo $url >> $temp_file
            echo "Failed to download: $url"
        fi
    done < $source_file

    mv $temp_file $source_file
    echo "Completed processing. URLs of failed downloads (if any) remain in $source_file"
}
