#!/bin/bash
# ==========
# script to run `fabric $URL -p $PATTERN_NAME -o $PARENT_DIR/$SLUG_TITLE-$VIDEO_ID-$PATTERN_SLUG.md`
# Includes transcript download and conversion functionality
# ==========

fabric_youtube_automation() {
  local VIDEO_URL="$1"
  local PATTERN_NAME="$2"
  local LOG_DIR="$HOME/log"
  local ERROR_LOG="$LOG_DIR/fabric_automation.log"
  local TEMP_DIR="/tmp/fabric_automation_$(date +%s)"
  local MAX_RETRIES=3
  local VIDEO_PID=""
  local TRANSCRIPT_PID=""
  local CONVERT_PID=""

  # Create log directories if they don't exist
  mkdir -p "$LOG_DIR"
  touch "$ERROR_LOG"

  # Function to log errors
  log_message() {
    local func_name="$1"
    local level="$2"
    local message="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $func_name [$level]: $message" >>"$ERROR_LOG"
    echo "$level: $message" >&2
  }

  # Function to slugify string
  slugify() {
    echo "$1" | iconv -t ascii//TRANSLIT | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]'
  }

  # Function to clean memory
  clean_memory() {
    echo "Freeing up system memory..."
    if command -v purge &>/dev/null && [[ "$(uname)" == "Darwin" ]]; then
      sudo purge
    elif [[ "$(uname)" == "Linux" ]]; then
      echo 3 | sudo tee /proc/sys/vm/drop_caches &>/dev/null
    fi
    sleep 1
  }

  # Function to convert SRT/VTT to MD
  subtitle_to_md() {
    local input_file="$1"
    local output_file="$2"

    echo "Converting subtitle to Markdown: $input_file → $output_file"

    # Use fabric to convert subtitle to MD
    cat "$input_file" | fabric -p "srt-transcript-to-md" -o "$output_file" 2> >(while read line; do
      log_message "subtitle_to_md" "ERROR" "fabric: $line"
    done)

    local exit_code=$?
    if [[ $exit_code -ne 0 || ! -s "$output_file" ]]; then
      log_message "subtitle_to_md" "ERROR" "Failed to convert subtitle to Markdown"
      return 1
    fi

    log_message "subtitle_to_md" "INFO" "Successfully created markdown file: $output_file"
    echo "Markdown transcript created: $output_file"

    # Delete original subtitle file after successful conversion
    if [[ -f "$input_file" && -s "$output_file" ]]; then
      echo "Removing original subtitle file"
      rm "$input_file"
    fi

    return 0
  }

  # Validate input URL
  if [[ -z "$VIDEO_URL" ]]; then
    log_message "fabric_youtube_automation" "ERROR" "No URL provided"
    return 1
  fi

  # Free up memory before processing
  clean_memory

  # Create temporary directory
  mkdir -p "$TEMP_DIR" || {
    log_message "fabric_youtube_automation" "ERROR" "Failed to create temporary directory"
    return 1
  }

  # Extract video information using yt-dlp directly
  echo "Extracting video information..."
  VIDEO_TITLE=$(yt-dlp --print title "$VIDEO_URL" 2>"$TEMP_DIR/yt_dlp_error.txt")
  VIDEO_ID=$(yt-dlp --print id "$VIDEO_URL" 2>>"$TEMP_DIR/yt_dlp_error.txt")

  if [[ -z "$VIDEO_TITLE" || -z "$VIDEO_ID" ]]; then
    log_message "fabric_youtube_automation" "ERROR" "Failed to extract video information: $(cat "$TEMP_DIR/yt_dlp_error.txt")"
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
      log_message "fabric_youtube_automation" "ERROR" "No pattern selected"
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
  elif [[ -d "/Volumes/Samsung/YT" ]]; then
    PARENT_DIR="/Volumes/Samsung/YT"
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
  local TRANSCRIPT_SRT_FILE="$OUTPUT_DIR/${VIDEO_BASE}-transcript.srt"
  local TRANSCRIPT_VTT_FILE="$OUTPUT_DIR/${VIDEO_BASE}-transcript.vtt"
  local TRANSCRIPT_MD_FILE="$OUTPUT_DIR/${VIDEO_BASE}-transcript.md"

  # Create output directory if needed
  mkdir -p "$OUTPUT_DIR" || {
    log_message "fabric_youtube_automation" "ERROR" "Failed to create output directory: $OUTPUT_DIR"
    rm -rf "$TEMP_DIR"
    return 1
  }

  # Check if files exist
  local VIDEO_EXISTS=0
  local SRT_EXISTS=0
  local VTT_EXISTS=0
  local TRANSCRIPT_MD_EXISTS=0

  if [[ -f "$VIDEO_FILE" ]]; then
    echo "Video file exists: $VIDEO_FILE"
    VIDEO_EXISTS=1
  fi

  if [[ -f "$TRANSCRIPT_SRT_FILE" ]]; then
    echo "SRT transcript file exists: $TRANSCRIPT_SRT_FILE"
    SRT_EXISTS=1
  fi

  if [[ -f "$TRANSCRIPT_VTT_FILE" ]]; then
    echo "VTT transcript file exists: $TRANSCRIPT_VTT_FILE"
    VTT_EXISTS=1
  fi

  if [[ -f "$TRANSCRIPT_MD_FILE" ]]; then
    echo "Markdown transcript file exists: $TRANSCRIPT_MD_FILE"
    TRANSCRIPT_MD_EXISTS=1
  fi

  # Check if markdown file exists BEFORE running fabric
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

  # Function to download video
  download_video() {
    if [[ $VIDEO_EXISTS -eq 0 ]]; then
      echo "Background process: Downloading video to: $VIDEO_FILE"
      yt-dlp -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" \
        --merge-output-format mp4 \
        -o "$VIDEO_FILE" \
        "$VIDEO_URL" 2>"$TEMP_DIR/yt_dlp_download_error.txt"

      if [[ ! -f "$VIDEO_FILE" ]]; then
        log_message "fabric_youtube_automation" "ERROR" "Failed to download video: $(cat "$TEMP_DIR/yt_dlp_download_error.txt")"
        cat "$TEMP_DIR/yt_dlp_download_error.txt"
        return 1
      fi
      echo "Background process: Video download completed"
    fi
    return 0
  }

  # Function to download transcript
  download_transcript() {
    if [[ $SRT_EXISTS -eq 0 && $VTT_EXISTS -eq 0 && $TRANSCRIPT_MD_EXISTS -eq 0 ]]; then
      echo "Background process: Downloading transcript"
      # Try downloading both SRT and VTT
      yt-dlp --write-auto-sub --skip-download --sub-format srt/vtt \
        -o "$OUTPUT_DIR/${VIDEO_BASE}" \
        "$VIDEO_URL" 2>"$TEMP_DIR/transcript_download_error.txt"

      # Find and rename SRT file
      local POTENTIAL_SRT=$(find "$OUTPUT_DIR" -name "*${VIDEO_ID}*.srt" -type f | head -1)
      if [[ -n "$POTENTIAL_SRT" && "$POTENTIAL_SRT" != "$TRANSCRIPT_SRT_FILE" ]]; then
        echo "Background process: Found SRT at $POTENTIAL_SRT, renaming to standardized name"
        mv "$POTENTIAL_SRT" "$TRANSCRIPT_SRT_FILE"
      fi

      # Find and rename VTT file
      local POTENTIAL_VTT=$(find "$OUTPUT_DIR" -name "*${VIDEO_ID}*.vtt" -type f | head -1)
      if [[ -n "$POTENTIAL_VTT" && "$POTENTIAL_VTT" != "$TRANSCRIPT_VTT_FILE" ]]; then
        echo "Background process: Found VTT at $POTENTIAL_VTT, renaming to standardized name"
        mv "$POTENTIAL_VTT" "$TRANSCRIPT_VTT_FILE"
      fi

      if [[ ! -f "$TRANSCRIPT_SRT_FILE" && ! -f "$TRANSCRIPT_VTT_FILE" ]]; then
        log_message "fabric_youtube_automation" "ERROR" "Failed to download transcript: $(cat "$TEMP_DIR/transcript_download_error.txt")"
        cat "$TEMP_DIR/transcript_download_error.txt"
        echo "Background process: Continuing without transcript."
        return 0 # Continue execution even if transcript download fails
      fi
      echo "Background process: Transcript download completed"
    fi
    return 0
  }

  # Start background downloads if needed
  if [[ $VIDEO_EXISTS -eq 0 ]]; then
    download_video &
    VIDEO_PID=$!
    echo "Background process: Video download started with PID $VIDEO_PID"
  fi

  if [[ $SRT_EXISTS -eq 0 && $VTT_EXISTS -eq 0 && $TRANSCRIPT_MD_EXISTS -eq 0 ]]; then
    download_transcript &
    TRANSCRIPT_PID=$!
    echo "Background process: Transcript download started with PID $TRANSCRIPT_PID"
  fi

  # Wait for transcript download to complete if it was started
  if [[ -n "$TRANSCRIPT_PID" ]]; then
    echo "Waiting for transcript download to complete..."
    wait $TRANSCRIPT_PID
    echo "Transcript download process completed"
  fi

  # Convert SRT/VTT to MD if subtitle exists but MD doesn't
  if [[ (-f "$TRANSCRIPT_SRT_FILE" || -f "$TRANSCRIPT_VTT_FILE") && ! -f "$TRANSCRIPT_MD_FILE" ]]; then
    echo "Converting subtitle to Markdown transcript..."
    if [[ -f "$TRANSCRIPT_SRT_FILE" ]]; then
      subtitle_to_md "$TRANSCRIPT_SRT_FILE" "$TRANSCRIPT_MD_FILE" &
    elif [[ -f "$TRANSCRIPT_VTT_FILE" ]]; then
      subtitle_to_md "$TRANSCRIPT_VTT_FILE" "$TRANSCRIPT_MD_FILE" &
    fi
    CONVERT_PID=$!
    echo "Background process: Subtitle to Markdown conversion started with PID $CONVERT_PID"
  fi

  # Wait for all background processes to complete
  if [[ -n "$VIDEO_PID" ]]; then
    echo "Waiting for video download to complete..."
    wait $VIDEO_PID
    echo "Video download process completed"
  fi

  if [[ -n "$CONVERT_PID" ]]; then
    echo "Waiting for subtitle to Markdown conversion to complete..."
    wait $CONVERT_PID
    echo "Subtitle to Markdown conversion completed"
  fi

  # Clean memory before running fabric
  clean_memory

  # Run fabric with the ORIGINAL pattern name
  echo "Running fabric with pattern: $ORIGINAL_PATTERN"

  # Determine source for fabric
  if [[ -f "$TRANSCRIPT_MD_FILE" ]]; then
    echo "Using Markdown transcript as source for fabric"
    local FABRIC_CMD="fabric -f \"$TRANSCRIPT_MD_FILE\" -p \"$ORIGINAL_PATTERN\" -o \"$MD_FILE\""
  else
    echo "Using YouTube API for transcript"
    local FABRIC_CMD="fabric -y \"$VIDEO_URL\" -p \"$ORIGINAL_PATTERN\" -o \"$MD_FILE\""
  fi

  # Run with retries for memory issues
  local RETRY_COUNT=0
  local SUCCESS=0

  while [[ $RETRY_COUNT -lt $MAX_RETRIES && $SUCCESS -eq 0 ]]; do
    clean_memory

    if [[ -f "$TRANSCRIPT_MD_FILE" ]]; then
      echo "Running fabric with local transcript file"
      fabric -f "$TRANSCRIPT_MD_FILE" -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2>"$TEMP_DIR/fabric_error.txt"
    else
      echo "Running fabric with YouTube API"
      fabric -y "$VIDEO_URL" -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2>"$TEMP_DIR/fabric_error.txt"
    fi

    if grep -q "llama runner process has terminated: signal: killed" "$TEMP_DIR/fabric_error.txt"; then
      ((RETRY_COUNT++))
      echo "Attempt $RETRY_COUNT/$MAX_RETRIES: Llama process ran out of memory. Retrying after cleanup..."
      sleep 2
      clean_memory
    else
      SUCCESS=1
    fi
  done

  if [[ $SUCCESS -eq 0 ]]; then
    log_message "fabric_youtube_automation" "ERROR" "Failed after $MAX_RETRIES attempts due to memory issues"
    echo "Try reducing input size or increasing system memory"
    rm -rf "$TEMP_DIR"
    return 1
  fi

  if [[ ! -f "$MD_FILE" || ! -s "$MD_FILE" || $(grep -c "could not get pattern" "$MD_FILE") -gt