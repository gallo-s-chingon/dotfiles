# ~/.config/zsh/modules/general.zsh
# General-purpose utility functions

timer() {
  termdown "$1"
  cvlc "$HOME/Music/ddd.mp3" --play-and-exit >/dev/null
}

trim-video() {
  if [ $# -eq 3 ]; then
    ffmpeg -i "$2" -ss "$1" -c:v copy -c:a copy "$3"
  elif [ $# -eq 2 ]; then
    ffmpeg -i "$1" -c:v copy -c:a copy "$2"
  else
    echo "Usage: trim-video input output [start-time]"
    return 1
  fi
}

select-pattern() {
  local selection="$1" pattern_dir="$HOME/.config/fabric/patterns"
  local -a patterns
  while IFS= read -r -d '' dir; do
    patterns+=("$dir")
  done < <(find "$pattern_dir" -type d -mindepth 1 -maxdepth 1 -print0)
  if [[ "$selection" -ge 1 && "$selection" -le "${#patterns[@]}" ]]; then
    selected_pattern="${patterns[$((selection-1))]}"
    echo "Selected pattern: $(basename "$selected_pattern")"
  else
    echo "Invalid selection"
    return 1
  fi
}


slugify() {
  echo "$1" | iconv -t ascii//TRANSLIT | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]'
}

# slugu() {
#   echo "$1" | iconv -t ascii//TRANSLIT | sed -E 's/[^a-zA-Z0-9]+/_/g' | sed -E 's/^_+|_+$//g' | tr '[:upper:]' '[:lower:]'
# }

# run sudo purge to clear memory to continue a bit faster
clean_memory() {
  echo "Freeing up system memory..."
  if command -v purge &>/dev/null && [[ "$(uname)" == "Darwin" ]]; then
    sudo purge || echo "Warning: Memory purge failed" >&2
  elif [[ "$(uname)" == "Linux" ]]; then
    echo 3 | sudo tee /proc/sys/vm/drop_caches &>/dev/null || echo "Warning: Memory cleanup failed" >&2
  else
    echo "Warning: Memory cleanup not supported on this OS" >&2
  fi
  sleep 1
}

srt_to_md() {
    local input_file="$1"
    [[ -z "$input_file" ]] && { echo "ERROR: No input file provided"; return 1; }
    [[ ! -f "$input_file" ]] && { echo "ERROR: Input file $input_file not found"; return 1; }

    local base_name="$(basename "${input_file%.*}")"
    local output_file="${base_name}.md"

    echo "Converting to Markdown: $input_file → $output_file"

    # Add CRLF handling and whitespace normalization
    grep -v -E '^[0-9]+$|-->|^[[:space:]]*$' "$input_file" |
    tr -d '\r' |                         # Remove carriage returns
    awk '{$1=$1; sub(/ $/, "")} 1' |     # Normalize whitespace
    awk '!seen[$0]++' > "$output_file"   # Remove all duplicates

    # Verification with accurate counts
    if [[ -f "$output_file" && -s "$output_file" ]]; then
        wc_before=$(grep -v -E '^[0-9]+$|-->|^[[:space:]]*$' "$input_file" | tr -d '\r' | wc -l)
        wc_after=$(wc -l < "$output_file")
        echo "SUCCESS: Created $output_file (Reduced from $wc_before to $wc_after lines)"
        return 0
    else
        echo "ERROR: Failed to create $output_file"
        return 1
    fi
}

pattern_header_fabric_file() {
    # Check for required arguments
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: pattern_header_fabric_file <input_file> <pattern_name>"
        return 1
    fi

    local input_file="$1"
    local pattern_name="$2"
    
    # Create slugged filename (lowercase, spaces to hyphens)
    local slugged_pattern=$(echo "$pattern_name" | tr '[:upper:]' '[:lower:]' | tr '_' '-' | tr ' ' '-')
    local output_file="${input_file%.*}-${slugged_pattern}.${input_file##*.}"

    # Process with Fabric and capture output
    local fabric_output=$(fabric -p "$pattern_name" -o "$output_file" < "$input_file")

    # Create output file with original content + header + Fabric output
    {
        cat "$input_file"
        echo -e "\n\n# ${pattern_name//_/ } of $(basename "$input_file") via fabric"
        echo "$fabric_output"
    } > "$output_file"

    echo "Created processed file: $output_file"
}
