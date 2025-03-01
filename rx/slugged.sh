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
  
  # Define new file naming scheme
  local VIDEO_BASE="${SLUG_TITLE}-${VIDEO_ID}"
  local MD_BASE="${SLUG_TITLE}-${VIDEO_ID}-${PATTERN_SLUG}"
  
  local VIDEO_FILE="$OUTPUT_DIR/$VIDEO_BASE.mp4"
  local MD_FILE="$OUTPUT_DIR/$MD_BASE.md"
  local TRANSCRIPT_FILE="$OUTPUT_DIR/${VIDEO_BASE}-transcript.srt"
  local TRANSCRIPT_MD_FILE="$OUTPUT_DIR/${VIDEO_BASE}-transcript.md"
  
  # Create output directory if needed
  mkdir -p "$OUTPUT_DIR" || {
    log_error "Failed to create output directory: $OUTPUT_DIR"
    rm -rf "$TEMP_DIR"
    return 1
  }
  
  # First check if both video and transcript exist
  local VIDEO_EXISTS=0
  local TRANSCRIPT_EXISTS=0
  
  # Check if video file exists
  if [[ -f "$VIDEO_FILE" ]]; then
    echo "Video file already exists: $VIDEO_FILE"
    VIDEO_EXISTS=1
  else
    echo "Video file doesn't exist, will download"
  fi
  
  # Check if transcript file exists (either SRT or MD)
  if [[ -f "$TRANSCRIPT_FILE" || -f "$TRANSCRIPT_MD_FILE" ]]; then
    echo "Transcript file already exists: ${TRANSCRIPT_FILE} or ${TRANSCRIPT_MD_FILE}"
    TRANSCRIPT_EXISTS=1
  else
    echo "Transcript doesn't exist, will download"
  fi
  
  # Download transcript if it doesn't exist
  if [[ $TRANSCRIPT_EXISTS -eq 0 ]]; then
    echo "Downloading transcript..."
    yt-dlp --write-auto-sub --convert-subs=srt --skip-download \
      -o "$OUTPUT_DIR/${VIDEO_BASE}" "$VIDEO_URL" \
      2> "$TEMP_DIR/transcript_download_error.txt"
    
    # Check if transcript was downloaded (looking for auto-generated .en.srt file)
    if [[ -f "$OUTPUT_DIR/${VIDEO_BASE}.en.srt" ]]; then
      # Rename to our standard naming
      mv "$OUTPUT_DIR/${VIDEO_BASE}.en.srt" "$TRANSCRIPT_FILE"
      echo "Transcript downloaded successfully: $TRANSCRIPT_FILE"
      TRANSCRIPT_EXISTS=1
      
      # Create markdown version of transcript
      echo "Converting transcript to markdown..."
      sed -e '/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]$/d' \
          -e '/^[[:digit:]]\{1,3\}$/d' \
          -e 's/<[^>]*>//g' \
          -e '/^[[:space:]]*$/d' \
          "$TRANSCRIPT_FILE" > "$TRANSCRIPT_MD_FILE"
      
      echo "Created markdown transcript: $TRANSCRIPT_MD_FILE"
    else
      echo "No transcript found for this video"
      cat "$TEMP_DIR/transcript_download_error.txt"
    fi
  fi
  
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
  if [[ $VIDEO_EXISTS -eq 0 ]]; then
    echo "Video file will be downloaded to: $VIDEO_FILE"
  fi
  echo "Pattern name: $ORIGINAL_PATTERN (original directory name)"
  
  # Run fabric with the ORIGINAL pattern name
  echo "Running fabric with pattern: $ORIGINAL_PATTERN"
  
  # Use transcript if available
  if [[ -f "$TRANSCRIPT_MD_FILE" ]]; then
    echo "Using markdown transcript as input for fabric"
    # Use ctc to copy transcript to clipboard and pipe to fabric
    if command -v ctc &> /dev/null; then
      ctc "$TRANSCRIPT_MD_FILE" && ifne fabric -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2> "$TEMP_DIR/fabric_error.txt"
    else
      # Fallback if ctc is not available
      cat "$TRANSCRIPT_MD_FILE" | fabric -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2> "$TEMP_DIR/fabric_error.txt"
    fi
  elif [[ -f "$TRANSCRIPT_FILE" ]]; then
    echo "Using SRT transcript as input for fabric"
    # Use ctc to copy transcript to clipboard and pipe to fabric
    if command -v ctc &> /dev/null; then
      ctc "$TRANSCRIPT_FILE" && ifne fabric -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2> "$TEMP_DIR/fabric_error.txt"
    else
      # Fallback if ctc is not available
      cat "$TRANSCRIPT_FILE" | fabric -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2> "$TEMP_DIR/fabric_error.txt"
    fi
  else
    # Use fabric with YouTube URL directly
    echo "No transcript found, using YouTube URL directly"
    fabric -y "$VIDEO_URL" -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2> "$TEMP_DIR/fabric_error.txt"
  fi
  
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
      "$VIDEO_URL" 2> "$TEMP_DIR/yt_dlp_download_error.txt"
    
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
  if [[ -f "$TRANSCRIPT_FILE" ]]; then
    echo "  Transcript (SRT): $TRANSCRIPT_FILE"
  fi
  if [[ -f "$TRANSCRIPT_MD_FILE" ]]; then
    echo "  Transcript (MD): $TRANSCRIPT_MD_FILE"
  fi
  echo "  Markdown: $MD_FILE"
  echo "  Video: $VIDEO_FILE" $(if [[ $VIDEO_EXISTS -eq 1 ]]; then echo "(pre-existing)"; fi)
  
  return 0
}