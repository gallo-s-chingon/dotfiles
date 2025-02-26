#!/usr/bin/env bash
# ===========================
# Miscellaneous Functions
# ===========================

timer() {
  termdown "$1"
  cvlc "$HOME/Music/ddd.mp3" --play-and-exit >/dev/null
}

slug() {
    if [ $# -ne 1 ]; then
        echo "(￣ヘ￣)  slugifying <filename>"
        return 1
    fi

    filename=$1
    slugified=$(slugged "$filename")
    echo "$slugified"
}

trim-video () {
  if [ $# -eq 3 ]; then
    ffmpeg -i "$2" -ss "$1" -c:v copy -c:a copy "$3"

  elif [ $# -eq 2 ]; then
    ffmpeg -i "$1" -c:v copy -c:a copy "$2"
  else
    echo "Usage: trim-video input-file output-file (start-time)"
    return 1
  fi

}

open-nvim-init() {
  nvim "$HOME/il-diab/init.lua"
}

open-wezterm() {
  nvim "$HOME/.config/wezterm.lua"
}

open-ghostty() {
  nvim "$CF/ghostty/config"
}

fabric_automation() {
  local VIDEO_URL="$1"
  local PATTERN_NAME="$2"
  local LOG_DIR="$HOME/.config/log"
  local ERROR_LOG="$LOG_DIR/fabric_automation.log"
  local TEMP_DIR="/tmp/fabric_automation_$(date +%s)"
  
  # Create log directories if they don't exist
  mkdir -p "$LOG_DIR"
  touch "$ERROR_LOG"
  
  # Function to log errors
  log_error() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp - Error: $1" >> "$ERROR_LOG"
    echo "Error: $1" >&2
  }
  
  # Function to slugify string
  slugify() {
    echo "$1" | iconv -t ascii//TRANSLIT | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]'
  }
  
  # Validate input URL
  if [[ -z "$VIDEO_URL" ]]; then
    log_error "No URL provided"
    return 1
  fi
  
  # Create temporary directory
  mkdir -p "$TEMP_DIR" || {
    log_error "Failed to create temporary directory"
    return 1
  }
  
  # Extract video information using yt-dlp directly
  echo "Extracting video information..."
  VIDEO_TITLE=$(yt-dlp --print title "$VIDEO_URL" 2> "$TEMP_DIR/yt_dlp_error.txt")
  VIDEO_ID=$(yt-dlp --print id "$VIDEO_URL" 2>> "$TEMP_DIR/yt_dlp_error.txt")
  
  if [[ -z "$VIDEO_TITLE" || -z "$VIDEO_ID" ]]; then
    log_error "Failed to extract video information: $(cat "$TEMP_DIR/yt_dlp_error.txt")"
    rm -rf "$TEMP_DIR"
    return 1
  fi
  
  echo "Debug: Extracted title: $VIDEO_TITLE"
  echo "Debug: Extracted ID: $VIDEO_ID"
  
  # Select pattern if not provided
  if [[ -z "$PATTERN_NAME" ]]; then
    echo "Select a pattern:"
    # Only list the directory names, not their contents
    PATTERN_DIRS=$(find "$HOME/.config/fabric/patterns" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
    PATTERN_NAME=$(echo "$PATTERN_DIRS" | fzf)
    
    if [[ -z "$PATTERN_NAME" ]]; then
      log_error "No pattern selected"
      rm -rf "$TEMP_DIR"
      return 1
    fi
  fi
  
  # Keep the original pattern name for fabric command but create a slugified version for filenames
  local ORIGINAL_PATTERN="$PATTERN_NAME"
  local PATTERN_SLUG=$(slugify "$PATTERN_NAME")
  
  # Slugify video title
  local SLUG_TITLE=$(slugify "$VIDEO_TITLE")
  
  # Determine output directory
  local PARENT_DIR
  if [[ -d "/Volumes/armor/didact/YT" ]]; then
    PARENT_DIR="/Volumes/armor/didact/YT"
  elif [[ -d "/Volumes/Samsung USB/YT" ]]; then
    PARENT_DIR="/Volumes/Samsung USB/YT"
  else
    PARENT_DIR="$PWD"
  fi
  
  # Create output directory - this is the video title slugified folder
  local OUTPUT_DIR="$PARENT_DIR/$SLUG_TITLE"
  
  # Define output file names with the same base structure
  local OUTPUT_BASE="${SLUG_TITLE}-${PATTERN_SLUG}-${VIDEO_ID}"
  local MD_FILE="$OUTPUT_DIR/$OUTPUT_BASE.md"
  local VIDEO_FILE="$OUTPUT_DIR/$OUTPUT_BASE.mp4"
  
  # Check if files already exist
  local FILES_EXIST=0
  if [[ -f "$MD_FILE" || -f "$VIDEO_FILE" ]]; then
    FILES_EXIST=1
    echo "Files for this video and pattern already exist:"
    [[ -f "$MD_FILE" ]] && echo "  Markdown: $MD_FILE"
    [[ -f "$VIDEO_FILE" ]] && echo "  Video: $VIDEO_FILE"
    
    echo "Options:"
    echo "  [s] Skip - do nothing and exit"
    echo "  [o] Overwrite - replace existing files"
    echo "  [k] Keep both - add a numbered suffix to new files"
    read -p "What would you like to do? (s/o/k): " CHOICE
    
    case "$CHOICE" in
      [oO])
        echo "Overwriting existing files..."
        ;;
      [kK])
        # Find a new suffix number
        local COUNT=2
        while [[ -f "$OUTPUT_DIR/${OUTPUT_BASE}-${COUNT}.md" || -f "$OUTPUT_DIR/${OUTPUT_BASE}-${COUNT}.mp4" ]]; do
          ((COUNT++))
        done
        
        OUTPUT_BASE="${OUTPUT_BASE}-${COUNT}"
        MD_FILE="$OUTPUT_DIR/$OUTPUT_BASE.md"
        VIDEO_FILE="$OUTPUT_DIR/$OUTPUT_BASE.mp4"
        echo "Creating new files with suffix: $COUNT"
        echo "  New markdown: $MD_FILE"
        echo "  New video: $VIDEO_FILE"
        ;;
      *)
        echo "Skipping processing for this video."
        rm -rf "$TEMP_DIR"
        return 0
        ;;
    esac
  fi
  
  # Create output directory if needed
  mkdir -p "$OUTPUT_DIR" || {
    log_error "Failed to create output directory: $OUTPUT_DIR"
    rm -rf "$TEMP_DIR"
    return 1
  }
  
  echo "Output directory: $OUTPUT_DIR"
  echo "Output base: $OUTPUT_BASE"
  echo "Pattern name: $ORIGINAL_PATTERN (original directory name)"
  
  # Run fabric with the ORIGINAL pattern name
  echo "Running fabric with pattern: $ORIGINAL_PATTERN"
  fabric -y "$VIDEO_URL" -p "$ORIGINAL_PATTERN" > "$MD_FILE" 2> "$TEMP_DIR/fabric_error.txt"
  
  if [[ ! -s "$MD_FILE" || $(grep -c "could not get pattern" "$MD_FILE") -gt 0 ]]; then
    echo "Content of markdown file:"
    cat "$MD_FILE"
    log_error "Failed to run fabric with pattern $ORIGINAL_PATTERN: $(cat "$TEMP_DIR/fabric_error.txt")"
    rm -rf "$TEMP_DIR"
    return 1
  fi
  
  # Download video
  echo "Downloading video to: $VIDEO_FILE"
  yt-dlp -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" \
    --merge-output-format mp4 \
    -o "$VIDEO_FILE" \
    "$VIDEO_URL" 2> "$TEMP_DIR/yt_dlp_download_error.txt"
  
  if [[ ! -f "$VIDEO_FILE" ]]; then
    log_error "Failed to download video: $(cat "$TEMP_DIR/yt_dlp_download_error.txt")"
    cat "$TEMP_DIR/yt_dlp_download_error.txt"
    rm -rf "$TEMP_DIR"
    return 1
  fi
  
  # Clean up
  rm -rf "$TEMP_DIR"
  
  echo "Process completed successfully."
  echo "Files created:"
  echo "  Markdown: $MD_FILE"
  echo "  Video:    $VIDEO_FILE"
  
  return 0
}
