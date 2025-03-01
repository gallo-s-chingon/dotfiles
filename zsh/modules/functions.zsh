#!/bin/bash
# ===========================
# Miscellaneous Functions
# ===========================

timer() {
  termdown "$1"
  cvlc "$HOME/Music/ddd.mp3" --play-and-exit >/dev/null
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
  
  # Check if video and transcript files exist
  local HAVE_VIDEO=0
  local HAVE_TRANSCRIPT=0
  
  if [[ -f "$VIDEO_FILE" ]]; then
    echo "Video file already exists: $VIDEO_FILE"
    HAVE_VIDEO=1
  fi
  
  if [[ -f "$TRANSCRIPT_FILE" ]]; then
    echo "Transcript file already exists: $TRANSCRIPT_FILE"
    HAVE_TRANSCRIPT=1
  fi
  
  # Download transcript if needed
  if [[ $HAVE_TRANSCRIPT -eq 0 ]]; then
    echo "Downloading transcript to: $TRANSCRIPT_FILE"
    yt-dlp --write-auto-sub --convert-subs=srt --skip-download \
      -o "$OUTPUT_DIR/${VIDEO_BASE}" "$VIDEO_URL" \
      2> "$TEMP_DIR/transcript_download_error.txt"
    
    # Check if transcript was downloaded (looking for auto-generated .en.srt file)
    if [[ -f "$OUTPUT_DIR/${VIDEO_BASE}.en.srt" ]]; then
      # Rename to our standard naming
      mv "$OUTPUT_DIR/${VIDEO_BASE}.en.srt" "$TRANSCRIPT_FILE"
      echo "Transcript downloaded successfully: $TRANSCRIPT_FILE"
      HAVE_TRANSCRIPT=1
    else
      echo "No transcript found for this video"
      cat "$TEMP_DIR/transcript_download_error.txt"
    fi
  fi
  
  # Download video if needed
  if [[ $HAVE_VIDEO -eq 0 ]]; then
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
    else
      HAVE_VIDEO=1
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
  echo "Pattern name: $ORIGINAL_PATTERN (original directory name)"
  
  # Run fabric with the ORIGINAL pattern name
  echo "Running fabric with pattern: $ORIGINAL_PATTERN"
  
  # Use fabric with YouTube URL directly
  echo "No transcript available, using YouTube URL directly"
  fabric -y "$VIDEO_URL" -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2> "$TEMP_DIR/fabric_error.txt"
 
  if [[ ! -s "$MD_FILE" || $(grep -c "could not get pattern" "$MD_FILE") -gt 0 ]]; then
    echo "Content of markdown file:"
    cat "$MD_FILE"
    log_error "Failed to run fabric with pattern $ORIGINAL_PATTERN: $(cat "$TEMP_DIR/fabric_error.txt")"
    rm -rf "$TEMP_DIR"
    return 1
  fi
  
  # Clean up
  rm -rf "$TEMP_DIR"
  
  echo "Process completed successfully."
  echo "Files:"
  if [[ $HAVE_TRANSCRIPT -eq 1 ]]; then
    echo "  Transcript: $TRANSCRIPT_FILE"
  fi
  echo "  Markdown: $MD_FILE"
  echo "  Video: $VIDEO_FILE"
  
  return 0
}

#!/bin/bash

# Config
LOG_FILE="${HOME}/.config/log/srt-to-md.log"
OLLAMA_MODEL="llama3.3"
TEMP_DIR="/tmp/srt-to-md"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null
mkdir -p "$TEMP_DIR" 2>/dev/null

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # Also print to stdout for INFO and ERROR
    if [[ "$level" == "INFO" || "$level" == "ERROR" ]]; then
        echo "[$level] $message"
    fi
}

# Check dependencies
check_dependencies() {
    local deps=("ollama" "bc" "grep" "awk" "sed")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_message "ERROR" "Missing dependencies: ${missing[*]}"
        return 1
    fi
    
    return 0
}

# Extract timestamps from SRT file
extract_timestamps() {
    local input_file="$1"
    local timestamp_file="$TEMP_DIR/timestamps.txt"
    
    grep -E '^[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} -->' "$input_file" | 
        awk '{print $1, $3}' > "$timestamp_file"
    
    echo "$timestamp_file"
}

# Convert timestamp to seconds (works on both macOS and Linux)
timestamp_to_seconds() {
    local timestamp="$1"
    # Remove commas from timestamp
    local clean_ts="${timestamp//,/}"
    
    # Extract hours, minutes, seconds
    local h=$(echo "$clean_ts" | cut -d':' -f1)
    local m=$(echo "$clean_ts" | cut -d':' -f2)
    local s=$(echo "$clean_ts" | cut -d':' -f3)
    
    # Calculate total seconds
    echo "$h * 3600 + $m * 60 + $s" | bc
}

# Calculate average pause duration
calculate_pauses() {
    local timestamp_file="$1"
    local pause_file="$TEMP_DIR/pauses.txt"
    local prev_end=""
    local total_pause=0
    local pause_count=0
    
    > "$pause_file"  # Clear or create pause file
    
    while IFS=' ' read -r start end; do
        if [[ -n "$prev_end" ]]; then
            local start_sec=$(timestamp_to_seconds "$start")
            local end_sec=$(timestamp_to_seconds "$prev_end")
            
            # Only count positive pauses
            if (( start_sec > end_sec )); then
                local pause=$((start_sec - end_sec))
                echo "$pause" >> "$pause_file"
                total_pause=$((total_pause + pause))
                ((pause_count++))
            fi
        fi
        prev_end="$end"
    done < "$timestamp_file"
    
    # Calculate average pause
    if [[ "$pause_count" -gt 0 ]]; then
        echo "scale=2; $total_pause / $pause_count" | bc
    else
        echo "0"
    fi
}

# Extract raw text from SRT
extract_raw_text() {
    local input_file="$1"
    local text_file="$TEMP_DIR/raw_text.txt"
    
    sed '/^[0-9]\+$/d; /^[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\},[0-9]\{3\} --> /d; /^$/d' "$input_file" > "$text_file"
    
    local line_count=$(wc -l < "$text_file" | tr -d ' ')
    log_message "DEBUG" "Raw text has $line_count lines."
    
    echo "$text_file"
}

# Check system resources
check_resources() {
    local min_memory=500  # Minimum memory in MB
    local free_mem
    
    if command -v sysctl >/dev/null 2>&1; then
        # macOS
        free_mem=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024)}')
    elif command -v free >/dev/null 2>&1; then
        # Linux
        free_mem=$(free -m | awk '/^Mem:/{print $4}')
    else
        log_message "WARNING" "Cannot determine available memory"
        return 0
    fi
    
    log_message "DEBUG" "Available memory: $free_mem MB"
    
    if [[ "$free_mem" -lt "$min_memory" ]]; then
        log_message "ERROR" "Not enough memory available ($free_mem MB < $min_memory MB)"
        return 1
    fi
    
    return 0
}

# Generate prompt for Ollama
generate_prompt() {
    local raw_text_file="$1"
    local timestamp_file="$2"
    local avg_pause="$3"
    local prompt_file="$TEMP_DIR/prompt.txt"
    
    cat > "$prompt_file" <<EOF
You are an expert text processor. I have an SRT transcript with timestamps and text. I've calculated the average pause duration between segments as $avg_pause seconds. Below is the raw text with timestamps removed, followed by the original timestamps for reference. Your task is to:

1. Remove duplicate or overlapping text (e.g., "yeah so we should uh, we should go ahead" becomes "so we should go ahead") and concatenate unique lines into coherent paragraphs.
2. Form paragraphs based on natural breaks: a shift in speaker, topic change, or a pause longer than $avg_pause seconds (use the timestamps to determine pause duration).
3. For each paragraph, generate a Markdown header (e.g., ## Topic) based on the content context, followed by an insight block (up to 4 lines, prefixed with > in a [!NOTE] callout) providing context or summary, then the literal transcript text.
4. Separate paragraphs with two newlines.
5. Do NOT rewrite the content beyond removing duplicates/overlaps; preserve the original wording.

### Raw Text
$(cat "$raw_text_file")

### Timestamps (for pause analysis)
$(cat "$timestamp_file")

Output the result in Markdown format.
EOF

    echo "$prompt_file"
}

# Process with Ollama
process_with_ollama() {
    local prompt_file="$1"
    local output_file="$2"
    local ollama_log="$TEMP_DIR/ollama_output.log"
    
    log_message "INFO" "Processing with Ollama (model: $OLLAMA_MODEL)..."
    
    if ollama run "$OLLAMA_MODEL" "$(cat "$prompt_file")" > "$output_file" 2>"$ollama_log"; then
        log_message "INFO" "Successfully processed with Ollama"
        return 0
    else
        log_message "ERROR" "Ollama processing failed. Check $ollama_log for details."
        return 1
    fi
}

# Main function
srt_to_md() {
    # Check if input file is provided and exists
    if [ -z "$1" ] || [ ! -f "$1" ]; then
        log_message "ERROR" "Usage: srt_to_md <input.srt> [output.md]"
        return 1
    fi

    local input_file="$1"
    local output_file="${2:-${input_file%.srt}.md}"
    
    # Check dependencies
    check_dependencies || return 1
    
    # Check system resources
    check_resources || return 1
    
    # Process SRT file
    log_message "INFO" "Processing $input_file to $output_file"
    
    # Extract timestamps and calculate average pause
    local timestamp_file=$(extract_timestamps "$input_file")
    local avg_pause=$(calculate_pauses "$timestamp_file")
    log_message "DEBUG" "Average pause duration: $avg_pause seconds"
    
    # Extract raw text
    local raw_text_file=$(extract_raw_text "$input_file")
    
    # Generate prompt
    local prompt_file=$(generate_prompt "$raw_text_file" "$timestamp_file" "$avg_pause")
    
    # Process with Ollama
    if process_with_ollama "$prompt_file" "$output_file"; then
        log_message "INFO" "Markdown file created: $output_file"
        return 0
    else
        return 1
    fi
}

# Clean up temporary files
cleanup() {
    rm -rf "$TEMP_DIR" 2>/dev/null
}

# Set up trap for cleanup
trap cleanup EXIT

# If script is sourced, just define the function
# If script is executed directly, run with arguments
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Script is being sourced, only define the function
    log_message "DEBUG" "srt_to_md function loaded"
else
    # Script is being executed directly
    srt_to_md "$@"
fi
