#!/bin/bash
# ===========================
# Miscellaneous Functions
# ===========================

# Centralized logging configuration
old_dir="$PWD"
LOG_DIR="$HOME/log"
mkdir -p "$LOG_DIR" 2>/dev/null

# Centralized logging function
log_message() {
  local function_name="$1"
  local level="$2"
  local message="$3"
  local log_file="${LOG_DIR}/${function_name}_$(date +%Y%m%d).log"
  local timestamp=$(date "+%Y%m%dT%H:%M:%S")
  echo "${timestamp} ${function_name} ${level}: ${message}" >> "$log_file"
  
  # Also print to stdout for INFO and ERROR
  if [[ "$level" == "INFO" || "$level" == "ERROR" ]]; then
    echo "[${level}] ${message}"
  fi
}

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

# Config
LOG_FILE="${HOME}/log/srt-to-md.log"
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

process_youtube_csv() {
  local csv_file="$1"
  local success_log="$HOME/youtube_downloads_success.log"
  local temp_file=$(mktemp)

  # Read the entire file
  while IFS= read -r line; do
    # Skip empty lines or comments
    [[ -z "$line" || "$line" == \#* ]] && continue
    
    # Split line into URL and patterns
    IFS=',' read -r url patterns_string <<< "$line"
    
    # Split patterns into an array
    IFS=',' read -rA patterns <<< "$patterns_string"
    
    # Track successful and failed patterns
    successful_patterns=()
    failed_patterns=()
    
    # Process each pattern
    for pattern in "${patterns[@]}"; do
      [[ -z "$pattern" ]] && continue
      
      # Run automation script
      if fabric_youtube_automation.sh "$url" "$pattern"; then
        successful_patterns+=("$pattern")
        # Log successful download
        printf "%s | %s | %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$url" "$pattern" >> "$success_log"
      else
        failed_patterns+=("$pattern")
      fi
    done
    
    # Rebuild line with only failed patterns
    if [[ ${#failed_patterns[@]} -gt 0 ]]; then
      printf "%s,%s\n" "$url" "$(IFS=,; echo "${failed_patterns[*]}")" >> "$temp_file"
    fi
  done < "$csv_file"

  # Replace original file with processed temp file
  mv "$temp_file" "$csv_file"
}
