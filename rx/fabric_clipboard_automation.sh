#!/bin/bash
# ==========
# script to run `pbpaste | fabric -p $PATTERN_NAME -o $OUTPUT_FILE` or `cat $INPUT_FILE | fabric -p $PATTERN_NAME -o $OUTPUT_FILE`
# ==========

fabric_clipboard_automation() {
  local INPUT="$1"
  local OUTPUT="$2"
  local PATTERN_NAME="$3"
  local LOG_DIR="$HOME/log"
  local ERROR_LOG="$LOG_DIR/fabric_automation.log"
  local TEMP_DIR="/tmp/fabric_automation_$(date +%s)"
  local MAX_RETRIES=3
  local USE_CLIPBOARD=0
  local INPUT_FILE=""

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

  # Create temporary directory
  mkdir -p "$TEMP_DIR" || {
    log_message "fabric_clipboard_automation" "ERROR" "Failed to create temporary directory"
    return 1
  }

  # Check if input is "pbpaste" or a file path
  if [[ "$INPUT" == "pbpaste" || "$INPUT" == "clipboard" ]]; then
    USE_CLIPBOARD=1
    echo "Using clipboard data as input"

    # If no output file is specified, prompt for one
    if [[ -z "$OUTPUT" ]]; then
      echo "Enter output file path (default: clipboard-output.md):"
      read -r OUTPUT
      OUTPUT="${OUTPUT:-clipboard-output.md}"
    fi
  elif [[ -n "$INPUT" && -f "$INPUT" ]]; then
    INPUT_FILE="$INPUT"
    echo "Using file input: $INPUT_FILE"

    # If no output file is specified, use input filename with pattern appended
    if [[ -z "$OUTPUT" ]]; then
      local INPUT_BASE="${INPUT_FILE%.*}"
      OUTPUT="${INPUT_BASE}-output.md"
    fi
  else
    log_message "fabric_clipboard_automation" "ERROR" "Invalid input. Use 'pbpaste' or provide a valid file path."
    echo "Usage:"
    echo "  $0 pbpaste [output_file] [pattern_name]"
    echo "  $0 input_file [output_file] [pattern_name]"
    rm -rf "$TEMP_DIR"
    return 1
  fi

  # Set output file
  local MD_FILE="$OUTPUT"

  # Auto-enumerate markdown file if needed
  if [[ -f "$MD_FILE" ]]; then
    local OUTPUT_DIR=$(dirname "$MD_FILE")
    local OUTPUT_BASE=$(basename "$MD_FILE")
    local OUTPUT_NAME="${OUTPUT_BASE%.*}"
    local OUTPUT_EXT="${OUTPUT_BASE##*.}"

    # Find a new suffix number
    local COUNT=2
    while [[ -f "$OUTPUT_DIR/${OUTPUT_NAME}-${COUNT}.${OUTPUT_EXT}" ]]; do
      ((COUNT++))
    done

    echo "Found matching markdown filename, using numbered suffix: $COUNT"
    MD_FILE="$OUTPUT_DIR/${OUTPUT_NAME}-${COUNT}.${OUTPUT_EXT}"
  fi

  echo "Output file: $MD_FILE"

  # Select pattern if not provided
  if [[ -z "$PATTERN_NAME" ]]; then
    echo "Select a pattern:"
    # Only list the directory names, not their contents
    PATTERN_DIRS=$(find "$HOME/.config/fabric/patterns" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
    PATTERN_NAME=$(echo "$PATTERN_DIRS" | fzf)

    if [[ -z "$PATTERN_NAME" ]]; then
      log_message "fabric_clipboard_automation" "ERROR" "No pattern selected"
      rm -rf "$TEMP_DIR"
      return 1
    fi
  fi

  # Ensure output directory exists
  mkdir -p "$(dirname "$MD_FILE")" || {
    log_message "fabric_clipboard_automation" "ERROR" "Failed to create output directory: $(dirname "$MD_FILE")"
    rm -rf "$TEMP_DIR"
    return 1
  }

  # Clean memory before processing
  clean_memory

  echo "Running fabric with pattern: $PATTERN_NAME"

  # Run with retries for memory issues
  local RETRY_COUNT=0
  local SUCCESS=0

  while [[ $RETRY_COUNT -lt $MAX_RETRIES && $SUCCESS -eq 0 ]]; do
    clean_memory

    if [[ $USE_CLIPBOARD -eq 1 ]]; then
      echo "Processing clipboard content"
      pbpaste | ifne fabric -p "$PATTERN_NAME" -o "$MD_FILE" 2>"$TEMP_DIR/fabric_error.txt"
    else
      echo "Processing file: $INPUT_FILE"
      cat "$INPUT_FILE" | fabric -p "$PATTERN_NAME" -o "$MD_FILE" 2>"$TEMP_DIR/fabric_error.txt"
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
    log_message "fabric_clipboard_automation" "ERROR" "Failed after $MAX_RETRIES attempts due to memory issues"
    echo "Try reducing input size or increasing system memory"
    rm -rf "$TEMP_DIR"
    return 1
  fi

  if [[ ! -s "$MD_FILE" || $(grep -c "could not get pattern" "$MD_FILE") -gt 0 ]]; then
    echo "Content of markdown file:"
    cat "$MD_FILE"
    log_message "fabric_clipboard_automation" "ERROR" "Failed to run fabric with pattern $PATTERN_NAME: $(cat "$TEMP_DIR/fabric_error.txt")"
    rm -rf "$TEMP_DIR"
    return 1
  fi

  # Clean up
  rm -rf "$TEMP_DIR"

  echo "Process completed successfully."
  echo "Output file: $MD_FILE"

  return 0
}

# Check if being called with expected parameters
if [[ "$1" == "pbpaste" || -f "$1" ]]; then
  fabric_clipboard_automation "$@"
else
  echo "Did you mean to use fabric_youtube_automation.sh instead?"
  echo "Usage:"
  echo "  $0 pbpaste [output_file] [pattern_name]"
  echo "  $0 input_file [output_file] [pattern_name]"
  exit 1
fi
