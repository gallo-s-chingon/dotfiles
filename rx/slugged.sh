#!/usr/bin/env bash
#: Name        : slugged
#: Date        : 2025-02-26
#: Author      : gallo-s-chingon, adapted from Benjamin Linton's slugify with enhancements
#: Version     : 0.3.0
#: Description : Convert filenames to a slug format: lowercase alphanumeric with single delimiters,
#:               removing non-ASCII, punctuation, and emojis, preserving extensions.

declare -A CONFIG=(
  ["verbose"]=0
  ["dry_run"]=0
  ["delimiter"]="-"
  ["number_duplicates"]=0
  ["delete_all"]=0
  ["timeout"]=180
)

print_usage() {
  cat <<EOF
usage: slugged [options] source_file ...
  -h, --help            Show this help
  -v, --verbose         Verbose mode (show rename actions)
  -n, --dry-run         Dry run mode (no changes, implies -v)
  -u, --underscore      Use underscores instead of hyphens as delimiter
  -N, --number-duplicates Number duplicates (e.g., file-2)
  -d, --delete-all      Delete all duplicates with confirmation
EOF
}

log_verbose() { 
  [ "${CONFIG["verbose"]}" -eq 1 ] && echo "$1"
}

read_with_timeout() {
  local prompt="$1" var_name="$2" timeout="${CONFIG["timeout"]}"
  read -t "$timeout" -r -p "$prompt" "$var_name" || {
    echo -e "\nTimed out after $timeout seconds." >&2
    return 1
  }
  return 0
}

parse_arguments() {
  local files=()
  
  while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
      print_usage
      exit 0
      ;;
    -v | --verbose) 
      CONFIG["verbose"]=1 
      ;;
    -n | --dry-run)
      CONFIG["dry_run"]=1
      CONFIG["verbose"]=1
      ;;
    -u | --underscore) 
      CONFIG["delimiter"]="_" 
      ;;
    -N | --number-duplicates) 
      CONFIG["number_duplicates"]=1 
      ;;
    -d | --delete-all) 
      CONFIG["delete_all"]=1 
      ;;
    --)
      shift
      while [ $# -gt 0 ]; do
        files+=("$1")
        shift
      done
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      print_usage
      exit 1
      ;;
    *)
      files+=("$1")
      ;;
    esac
    shift
  done
  
  if [ ${#files[@]} -eq 0 ]; then
    print_usage
    exit 1
  fi
  
  for file in "${files[@]}"; do
    echo "$file"
  done
}

slugify_file() {
  local input="$1" 
  local delimiter="${CONFIG["delimiter"]}" 
  local dir_name base_name extension result
  
  # Handle paths correctly
  if [[ "$input" == */* ]]; then
    dir_name="$(dirname "$input")"
    base_name="$(basename "$input")"
  else
    dir_name="."
    base_name="$input"
  fi
  
  # Handle extensions
  if [[ "$base_name" =~ \. ]]; then
    extension="${base_name##*.}"
    base_name="${base_name%.*}"
  else
    extension=""
  fi
  
  # Convert to slug format
  result=$(echo "$base_name" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' "$delimiter")
  result="${result#$delimiter}"
  result="${result%$delimiter}"
  
  # Add extension back if it exists
  [ -n "$extension" ] && result="$result.$extension"
  
  # Add directory back if it exists and isn't current directory
  if [ "$dir_name" != "." ]; then
    result="$dir_name/$result"
  fi
  
  echo "$result"
}

check_duplicate() {
  local target="$1" 
  local target_slug=$(slugify_file "$target")
  shift
  
  for file in "$@"; do
    [ "$file" != "$target" ] && [ "$(slugify_file "$file")" = "$target_slug" ] && return 0
  done
  return 1
}

number_duplicate_files() {
  local -a dups=("$@")
  
  for dup in "${dups[@]}"; do
    local slug=$(slugify_file "$dup") 
    local dir_name=$(dirname "$dup") 
    local base_slug_no_dir="$(basename "$slug")"
    local counter=2 
    local new_slug
    
    while true; do
      if [ "$dir_name" = "." ]; then
        new_slug="$base_slug_no_dir-$counter"
      else
        new_slug="$dir_name/$base_slug_no_dir-$counter"
      fi
      
      # Check if this new slug is already in use
      if [ -z "${slug_map[$new_slug]}" ] && [ ! -e "$new_slug" ]; then
        break
      fi
      ((counter++))
    done
    
    # Store the original file with its new numbered slug
    slug_map["$new_slug"]="$dup"
    log_verbose "number: $dup -> $new_slug"
  done
}

delete_duplicate_files() {
  local -a dups=("$@")
  local answer
  
  echo "Duplicates detected:"
  printf '%s\n' "${dups[@]}" | sed 's/^/  /'
  read_with_timeout "Delete all duplicates? (y/Y) Yes, delete all duplicates (cannot be undone) (n) no, switch to dry-run mode to preview deletions (N) Number duplicate files instead: " answer || return 1
  
  case "$answer" in
  y | Y)
    for dup in "${dups[@]}"; do
      local slug=$(slugify_file "$dup")
      if [ "$dup" != "${slug_map[$slug]}" ]; then
        [ "${CONFIG["dry_run"]}" -eq 0 ] && rm -rf "$dup"
        log_verbose "delete: $dup"
      fi
    done
    ;;
  n)
    CONFIG["dry_run"]=1
    echo "--- Switching to dry run mode ---"
    for dup in "${dups[@]}"; do
      local slug=$(slugify_file "$dup")
      [ "$dup" != "${slug_map[$slug]}" ] && echo "delete: $dup"
    done
    ;;
  N) 
    number_duplicate_files "${dups[@]}"
    ;;
  *)
    echo "Aborting deletion. No changes made to duplicates."
    return 1
    ;;
  esac
  return 0
}

handle_duplicates() {
  [ ${#duplicates[@]} -eq 0 ] && return 0
  
  if [ "${CONFIG["number_duplicates"]}" -eq 1 ]; then
    number_duplicate_files "${duplicates[@]}"
  elif [ "${CONFIG["delete_all"]}" -eq 1 ]; then
    delete_duplicate_files "${duplicates[@]}" || return 1
  else
    echo "Duplicates detected:"
    printf '%s\n' "${duplicates[@]}" | sed 's/^/  /'
    local choice
    read_with_timeout "Handle duplicates by (n)umbering or (d)eleting? (n/d): " choice || return 1
    case "$choice" in
    n | N) 
      number_duplicate_files "${duplicates[@]}"
      ;;
    d | D)
      echo "Duplicates to delete:"
      printf '%s\n' "${duplicates[@]}" | sed 's/^/  /'
      local del_choice
      read_with_timeout "Delete [D]elete all or [a]bort? (D/a): " del_choice || return 1
      if [ "$del_choice" = "D" ] || [ "$del_choice" = "d" ]; then
        for dup in "${duplicates[@]}"; do
          local slug=$(slugify_file "$dup")
          if [ "$dup" != "${slug_map[$slug]}" ]; then
            [ "${CONFIG["dry_run"]}" -eq 0 ] && rm -rf "$dup"
            log_verbose "delete: $dup"
          fi
        done
      else
        echo "Aborting deletion. No changes made to duplicates."
        return 1
      fi
      ;;
    *)
      echo "Invalid choice. Aborting." >&2
      return 1
      ;;
    esac
  fi
  return 0
}

process_renames() {
  for slug in "${!slug_map[@]}"; do
    local file="${slug_map[$slug]}"
    
    # Skip if file already has desired name
    if [ "$file" = "$slug" ]; then
      log_verbose "ignore: $file (already slugified)"
      continue
    fi
    
    # Ensure target directory exists
    local target_dir=$(dirname "$slug")
    if [ ! -d "$target_dir" ] && [ "$target_dir" != "." ]; then
      if [ "${CONFIG["dry_run"]}" -eq 1 ]; then
        echo "mkdir: $target_dir"
      else
        mkdir -p "$target_dir"
      fi
    fi
    
    # Perform the rename
    if [ "${CONFIG["dry_run"]}" -eq 1 ]; then
      echo "rename: $file -> $slug"
    else
      if [ "${CONFIG["verbose"]}" -eq 1 ]; then
        mv -v "$file" "$slug" 2>/dev/null || {
          echo "Error renaming: $file -> $slug" >&2
          echo "  Make sure you have the necessary permissions and the destination is writable." >&2
        }
      else
        mv "$file" "$slug" 2>/dev/null || {
          echo "Error renaming: $file -> $slug" >&2
        }
      fi
    fi
  done
}

main() {
  local IFS=$'\n'
  local files=()
  
  # Parse arguments and get files list
  readarray -t files < <(parse_arguments "$@")
  
  # Show dry run mode message if enabled
  [ "${CONFIG["dry_run"]}" -eq 1 ] && echo "--- Begin dry run mode ---"

  # Global variables to maintain across functions
  declare -A slug_map
  declare -a duplicates=()
  
  # Build the slug map and identify duplicates
  for file in "${files[@]}"; do
    if [ ! -e "$file" ]; then
      echo "not found: $file" >&2
      continue
    fi
    
    local slug=$(slugify_file "$file")
    if [ -n "${slug_map[$slug]}" ] || check_duplicate "$file" "${files[@]}"; then
      duplicates+=("$file")
    else
      slug_map["$slug"]="$file"
    fi
  done

  # Handle duplicate files
  if [ ${#duplicates[@]} -gt 0 ]; then
    handle_duplicates || {
      echo "Duplicate handling failed or was aborted." >&2
      exit 1
    }
  fi
  
  # Process the renames
  process_renames

  # Show dry run mode end message if enabled
  [ "${CONFIG["dry_run"]}" -eq 1 ] && echo "--- End dry run mode ---"
}

# Call the main function with all arguments
main "$@"