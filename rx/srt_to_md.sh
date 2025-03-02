#!/bin/bash


srt_to_md() {
  local func_name="srt_to_md"
  local input_file=""
  local output_file=""
  local from_clipboard=false
  local pattern_name="srt-transcript-to-md"
  
  # Check arguments
  if [[ "$1" == "pbpaste" || "$1" == "clipboard" ]]; then
    from_clipboard=true
    output_file="${2:-clipboard_transcript.md}"
    log_message "$func_name" "INFO" "Using clipboard input, output to $output_file"
  elif [[ -n "$1" && -f "$1" ]]; then
    input_file="$1"
    output_file="${2:-${input_file%.srt}.md}"
    log_message "$func_name" "INFO" "Using file input $input_file, output to $output_file"
  else
    log_message "$func_name" "ERROR" "Usage: srt_to_md <input.srt> [output.md] or srt_to_md pbpaste [output.md]"
    echo "Usage: srt_to_md <input.srt> [output.md] or srt_to_md pbpaste [output.md]"
    return 1
  fi
  
  # Handle clipboard input
  if [[ "$from_clipboard" == true ]]; then
    log_message "$func_name" "INFO" "Processing clipboard content with fabric"
    # Use fabric directly with clipboard input
    pbpaste | fabric -p "$pattern_name" -o "$output_file" 2> >(while read line; do 
      log_message "$func_name" "ERROR" "fabric: $line"
    done)
    
    if [[ $? -ne 0 || ! -s "$output_file" ]]; then
      log_message "$func_name" "ERROR" "Failed to process clipboard content with fabric"
      return 1
    fi
  else
    # Handle file input
    log_message "$func_name" "INFO" "Processing file $input_file with fabric"
    
    # Check if file has .srt extension
    if [[ "${input_file##*.}" != "srt" ]]; then
      log_message "$func_name" "WARNING" "Input file doesn't have .srt extension"
    fi
    
    # Check if file exists and is readable
    if [[ ! -r "$input_file" ]]; then
      log_message "$func_name" "ERROR" "Input file doesn't exist or is not readable"
      return 1
    }
    
    # Use cat to pass file content to fabric
    cat "$input_file" | fabric -p "$pattern_name" -o "$output_file" 2> >(while read line; do 
      log_message "$func_name" "ERROR" "fabric: $line"
    done)
    
    if [[ $? -ne 0 || ! -s "$output_file" ]]; then
      log_message "$func_name" "ERROR" "Failed to process file with fabric"
      return 1
    fi
  fi
  
  log_message "$func_name" "INFO" "Successfully created markdown file: $output_file"
  echo "Markdown file created: $output_file"
  return 0
}
