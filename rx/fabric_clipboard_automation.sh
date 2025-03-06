#!/bin/bash
# ==========
# Script to process a CSV file with URLs and Fabric patterns
# ==========
fabric_csv_automation() {
  local CSV_FILE="$1"
  local LOG_DIR="$HOME/log"
  local SUCCESS_LOG="$LOG_DIR/fabric_clipboard_automation.log"
  local ERROR_LOG="$LOG_DIR/fabric_clipboard_automation_STDERR.log"
  local TEMP_DIR="/tmp/fabric_csv_automation_$(date +%s)"
  local MAX_RETRIES=3

  # Create log directories
  mkdir -p "$LOG_DIR"
  touch "$SUCCESS_LOG" "$ERROR_LOG"

  # Function to find closest pattern match
  find_closest_pattern() {
    local input_pattern="$1"
    local pattern_dir="$HOME/.config/fabric/patterns"
    local closest_match=""
    local lowest_distance=999

    # Use fuzzy matching to find closest pattern
    for pattern in "$pattern_dir"/*"$input_pattern"*; do
      if [[ -d "$pattern" ]]; then
        local basename_pattern=$(basename "$pattern")
        # Compute Levenshtein distance (could replace with more sophisticated fuzzy matching)
        local distance=$(echo "$basename_pattern" | awk -v pattern="$input_pattern" 'BEGIN{min=length(pattern)} 
          {
            a=length(); b=length(pattern)
            for(i=1;i<=a;i++) 
              for(j=1;j<=b;j++) 
                d[i,j]=min(d[i-1,j]+1, d[i,j-1]+1, d[i-1,j-1]+(substr($0,i,1)!=substr(pattern,j,1)))
            min=d[a,b]
          } 
          END{print min}')

        if [[ $distance -lt $lowest_distance ]]; then
          lowest_distance=$distance
          closest_match="$basename_pattern"
        fi
      fi
    done

    echo "$closest_match"
  }

  # Function to slugify string
  slugify() {
    echo "$1" | iconv -t ascii//TRANSLIT | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]'
  }

  # Validate CSV file
  if [[ ! -f "$CSV_FILE" ]]; then
    echo "Error: CSV file not found" >&2
    return 1
  fi

  # Create temporary directory
  mkdir -p "$TEMP_DIR" || return 1

  # Process each line in CSV
  while IFS=',' read -r url patterns; do
    # Trim whitespace from URL and patterns
    url=$(echo "$url" | xargs)
    patterns=$(echo "$patterns" | xargs)

    # Validate URL
    if [[ -z "$url" ]]; then
      echo "Skipping empty URL" >>"$ERROR_LOG"
      continue
    fi

    # Process each pattern for the URL
    IFS=',' read -ra PATTERN_ARRAY <<<"$patterns"
    for raw_pattern in "${PATTERN_ARRAY[@]}"; do
      pattern=$(echo "$raw_pattern" | xargs)

      # Find closest pattern match
      matched_pattern=$(find_closest_pattern "$pattern")

      if [[ -z "$matched_pattern" ]]; then
        echo "No matching pattern found for: $pattern" >>"$ERROR_LOG"
        continue
      fi

      # Create output filename
      slug_url=$(slugify "$url")
      slug_pattern=$(slugify "$matched_pattern")
      output_file="$HOME/output/${slug_url}-${slug_pattern}.md"

      # Ensure output directory exists
      mkdir -p "$(dirname "$output_file")"

      # Process URL with matched pattern
      echo "$url" | fabric -p "$matched_pattern" -o "$output_file" 2>"$TEMP_DIR/fabric_error.txt"

      # Check for successful processing
      if [[ $? -eq 0 && -s "$output_file" && ! -s "$TEMP_DIR/fabric_error.txt" ]]; then
        echo "Successfully processed $url with pattern $matched_pattern" >>"$SUCCESS_LOG"
      else
        echo "Failed to process $url with pattern $matched_pattern: $(cat "$TEMP_DIR/fabric_error.txt")" >>"$ERROR_LOG"
      fi
    done
  done <"$CSV_FILE"

  # Clean up
  rm -rf "$TEMP_DIR"
}

# Check parameters
if [[ $# -ne 1 || ! -f "$1" ]]; then
  echo "Usage: $0 <csv_file>"
  echo "CSV file should contain: URL,pattern1,pattern2,..."
  exit 1
fi

fabric_csv_automation "$1"

