#!/bin/bash
# ===========================
# YouTube-DL Functions
# ===========================

yt_dlp_download() {
  yt-dlp --embed-chapters --no-warnings --format "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" -o "%(title)s.%(ext)s" "$@"
}

yt_dlp_extract_audio() {
    yt-dlp -x --audio-format "mp3/m4a" --audio-quality 0 --write-thumbnail --embed-metadata --concurrent-fragments 6 --yes-playlist -o "%(artist)s - %(title)s.%(ext)s" --ignore-errors --no-overwrites --continue "$@"
}

yt_dlp_extract_audio_from_file () {
    local source_file="$1"
    local temp_file
    local output_template="%(title)s.%(ext)s"

    temp_file=$(mktemp)

    while IFS= read -r url || [[ -n "$url" ]]; do
        # Check if the file already exists
        existing_file=$(yt-dlp --get-filename -o "$output_template" --format "mp3/m4a" "$url")
        if [[ -f "$existing_file" ]]; then
            continue  # Skip this URL as the file already exists
        fi

        if yt-dlp -x --format "mp3/m4a" --audio-quality 0 --write-thumbnail --embed-metadata --concurrent-fragments 6 --yes-playlist -o "$output_template" --ignore-errors --no-overwrites --cookies "$HOME/Desktop/cookies.txt" --continue "$url"; then
            : # Do nothing on success (success message removed)
        else
            echo "$url" >> "$temp_file"
            echo "Failed to download: $url"
        fi
    done < "$source_file"

    mv "$temp_file" "$source_file"
    echo "Completed processing. URLs of failed downloads (if any) remain in $source_file"
}

spotdl_error_logger() {
    local LOG_FILE
    local TEMP_LOG_FILE
    local GREEN
    local RED
    local NC

    # Declare and assign variables separately
    LOG_FILE="$(pwd)/download_errors.log"
    TEMP_LOG_FILE="$(pwd)/temp_errors.log"
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    NC='\033[0m'

    # Clear existing log files using 'true' as a no-op command
    true > "$LOG_FILE"
    true > "$TEMP_LOG_FILE"

    # Main spotdl command with error handling
    spotdl "$@" 2>&1 | while IFS= read -r line; do
        echo "$line"  # Echo the line to maintain original output
        if [[ "$line" == *"youtube"* ]]; then
            echo "$line" >> "$TEMP_LOG_FILE"
        fi
    done

    # Process the temporary log file to extract URLs
    if [[ -f "$TEMP_LOG_FILE" ]]; then
        grep -oE 'https?://[^ ]+' "$TEMP_LOG_FILE" | sort -u > "$LOG_FILE"
        rm "$TEMP_LOG_FILE"
    fi

    # Check if log file exists and show its contents
    if [[ -f "$LOG_FILE" && -s "$LOG_FILE" ]]; then
        echo -e "\n${GREEN}Log file created at: $LOG_FILE${NC}"
        echo -e "${GREEN}Contents of the log file:${NC}"
        cat "$LOG_FILE"
    else
        echo -e "\n${RED}No errors logged or log file is empty.${NC}"
    fi
}

