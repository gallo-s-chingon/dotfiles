#!/bin/bash
# ==========
# script to run `fabric $URL -p $PATTERN_NAME -o $PARENT_DIR/$SLUG_TITLE-$VIDEO_ID-$PATTERN_SLUG.md` or `pbpaste | fabric -p $PATTERN_NAME -o (user entered output dir/filenome)`
# ==========

# Source needed functions from zshenv
. "$HOME/.config/zsh/modules/functions.zsh"

fabric_automation() {
  local INPUT="$1"
  local PATTERN_NAME="$2"
  local LOG_DIR="$HOME/.config/log"
  local ERROR_LOG="$LOG_DIR/fabric_automation.log"
  local TEMP_DIR="/tmp/fabric_automation_$(date +%s)"
  local USE_CLIPBOARD=0
  local VIDEO_URL=""

  # Create log directories if they don't exist
  mkdir -p "$LOG_DIR"
  touch "$ERROR_LOG"

  # Function to log errors
  log_error() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp - Error: $1" >>"$ERROR_LOG"
    echo "Error: $1" >&2
  }

  # Function to slugify string
  slugify() {
    echo "$1" | iconv -t ascii//TRANSLIT | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]'
  }

  # Check if input is "pbpaste" to use clipboard
  if [[ "$INPUT" == "pbpaste" ]]; then
    USE_CLIPBOARD=1
    echo "Using clipboard data as input"
  else
    VIDEO_URL="$INPUT"
    # Validate input URL
    if [[ -z "$VIDEO_URL" ]]; then
      log_error "No URL provided"
      return 1
    fi
  fi

  # Create temporary directory
  mkdir -p "$TEMP_DIR" || {
    log_error "Failed to create temporary directory"
    return 1
  }

  # If using clipboard, skip video info extraction
  if [[ $USE_CLIPBOARD -eq 0 ]]; then
    # Extract video information using yt-dlp directly
    echo "Extracting video information..."
    VIDEO_TITLE=$(yt-dlp --print title "$VIDEO_URL" 2>"$TEMP_DIR/yt_dlp_error.txt")
    VIDEO_ID=$(yt-dlp --print id "$VIDEO_URL" 2>>"$TEMP_DIR/yt_dlp_error.txt")

    if [[ -z "$VIDEO_TITLE" || -z "$VIDEO_ID" ]]; then
      log_error "Failed to extract video information: $(cat "$TEMP_DIR/yt_dlp_error.txt")"
      rm -rf "$TEMP_DIR"
      return 1
    fi

    echo "Debug: Extracted title: $VIDEO_TITLE"
    echo "Debug: Extracted ID: $VIDEO_ID"
  fi

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

  # For clipboard input, use a simplified naming scheme
  if [[ $USE_CLIPBOARD -eq 1 ]]; then
    local OUTPUT_DIR="$PWD"
    local MD_FILE="$OUTPUT_DIR/clipboard-${PATTERN_SLUG}.md"

    # Auto-enumerate markdown file if needed
    if [[ -f "$MD_FILE" ]]; then
      # Find a new suffix number
      local COUNT=2
      while [[ -f "$OUTPUT_DIR/clipboard-${PATTERN_SLUG}-${COUNT}.md" ]]; do
        ((COUNT++))
      done

      echo "Found matching markdown filename, using numbered suffix: $COUNT"
      MD_FILE="$OUTPUT_DIR/clipboard-${PATTERN_SLUG}-${COUNT}.md"
    fi

    echo "Running fabric with pattern: $ORIGINAL_PATTERN"
    echo "Using clipboard data as input"
    pbpaste | ifne fabric -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2>"$TEMP_DIR/fabric_error.txt"

    if [[ ! -s "$MD_FILE" || $(grep -c "could not get pattern" "$MD_FILE") -gt 0 ]]; then
      echo "Content of markdown file:"
      cat "$MD_FILE"
      log_error "Failed to run fabric with pattern $ORIGINAL_PATTERN: $(cat "$TEMP_DIR/fabric_error.txt")"
      rm -rf "$TEMP_DIR"
      return 1
    fi

    echo "Process completed successfully."
    echo "Files:"
    echo "  Markdown: $MD_FILE"

    rm -rf "$TEMP_DIR"
    return 0
  fi

  # Continue with YouTube URL processing
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

  # Define new file naming scheme
  local VIDEO_BASE="${SLUG_TITLE}-${VIDEO_ID}"
  local MD_BASE="${SLUG_TITLE}-${VIDEO_ID}-${PATTERN_SLUG}"

  local VIDEO_FILE="$OUTPUT_DIR/$VIDEO_BASE.mp4"
  local MD_FILE="$OUTPUT_DIR/$MD_BASE.md"
  local TRANSCRIPT_FILE="$OUTPUT_DIR/${VIDEO_BASE}-transcript.srt"

  # Create output directory if needed
  mkdir -p "$OUTPUT_DIR" || {
    log_error "Failed to create output directory: $OUTPUT_DIR"
    rm -rf "$TEMP_DIR"
    return 1
  }

  # Check if files exist
  local VIDEO_EXISTS=0

  if [[ -f "$VIDEO_FILE" ]]; then
    echo "Video file exists: $VIDEO_FILE"
    VIDEO_EXISTS=1
  fi

  echo "Using YouTube API for transcript"
  fabric -y "$VIDEO_URL" -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2>"$TEMP_DIR/fabric_error.txt"

  # Auto-enumerate markdown file if needed
  if [[ -f "$MD_FILE" ]]; then
    # Find a new suffix number
    local COUNT=2
    while [[ -f "$OUTPUT_DIR/${MD_BASE}-${COUNT}.md" ]]; do
      ((COUNT++))
    done

    echo "Found matching markdown filename, using numbered suffix: $COUNT"
    MD_FILE="$OUTPUT_DIR/${MD_BASE}-${COUNT}.md"
  fi

  echo "Output directory: $OUTPUT_DIR"
  echo "Markdown file: $MD_FILE"
  echo "Pattern name: $ORIGINAL_PATTERN (original directory name)"

  # Run fabric with the ORIGINAL pattern name
  echo "Running fabric with pattern: $ORIGINAL_PATTERN"

  if [[ ! -s "$MD_FILE" || $(grep -c "could not get pattern" "$MD_FILE") -gt 0 ]]; then
    echo "Content of markdown file:"
    cat "$MD_FILE"
    log_error "Failed to run fabric with pattern $ORIGINAL_PATTERN: $(cat "$TEMP_DIR/fabric_error.txt")"
    rm -rf "$TEMP_DIR"
    return 1
  fi

  # Download video if it doesn't exist
  if [[ $VIDEO_EXISTS -eq 0 ]]; then
    echo "Downloading video to: $VIDEO_FILE"
    yt-dlp -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" \
      --merge-output-format mp4 \
      -o "$VIDEO_FILE" \
      "$VIDEO_URL" 2>"$TEMP_DIR/yt_dlp_download_error.txt"

    if [[ ! -f "$VIDEO_FILE" ]]; then
      log_error "Failed to download video: $(cat "$TEMP_DIR/yt_dlp_download_error.txt")"
      cat "$TEMP_DIR/yt_dlp_download_error.txt"
      rm -rf "$TEMP_DIR"
      return 1
    fi
  fi

  # Clean up
  rm -rf "$TEMP_DIR"

  echo "Process completed successfully."
  echo "Files:"
  if [[ $TRANSCRIPT_EXISTS -eq 1 ]]; then
    echo "  Transcript: $TRANSCRIPT_FILE"
  fi
  echo "  Markdown: $MD_FILE"
  echo "  Video: $VIDEO_FILE"

  return 0
}
