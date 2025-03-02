#!/bin/bash
# ===========================
# Miscellaneous Functions
# ===========================

# Centralized logging configuration
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
