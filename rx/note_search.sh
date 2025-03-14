#!/usr/bin/env bash

# note-search.sh - Find notes using enhanced search methods
# Usage: ./note-search.sh [search-term] [options]

# Default location for notes
NOTES_DIR="$HOME/notes"

# Check for search term
if [ $# -lt 1 ]; then
  echo "Usage: note-search [search-term] [options]"
  echo "Options:"
  echo "  -t, --tag TAG     Search by tag"
  echo "  -c, --category CAT  Search by category (project, area, resource, archive)"
  echo "  -d, --date DATE   Search by date (YYYY-MM-DD)"
  echo "  -r, --recent N    Show N most recently modified notes"
  echo "  -h, --help        Show this help message"
  exit 1
fi

# Parse options
SEARCH_TERM=""
SEARCH_TAG=""
SEARCH_CATEGORY=""
SEARCH_DATE=""
RECENT=0

while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--tag)
      SEARCH_TAG="$2"
      shift 2
      ;;
    -c|--category)
      SEARCH_CATEGORY="$2"
      shift 2
      ;;
    -d|--date)
      SEARCH_DATE="$2"
      shift 2
      ;;
    -r|--recent)
      RECENT="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: note-search [search-term] [options]"
      echo "Options:"
      echo "  -t, --tag TAG     Search by tag"
      echo "  -c, --category CAT  Search by category (project, area, resource, archive)"
      echo "  -d, --date DATE   Search by date (YYYY-MM-DD)"
      echo "  -r, --recent N    Show N most recently modified notes"
      echo "  -h, --help        Show this help message"
      exit 0
      ;;
    *)
      SEARCH_TERM="$1"
      shift
      ;;
  esac
done

# Function to display results
display_results() {
  local files="$1"
  local count=0
  
  if [ -z "$files" ]; then
    echo "No results found."
    return
  fi
  
  echo "$files" | while read -r file; do
    ((count++))
    
    # Extract metadata
    title=$(grep -m 1 "^title:" "$file" | sed 's/title: "\(.*\)"/\1/')
    date=$(grep -m 1 "^date:" "$file" | sed 's/date: \(.*\)/\1/')
    modified=$(grep -m 1 "^modified:" "$file" | sed 's/modified: \(.*\)/\1/')
    tags=$(grep -m 1 "^tags:" "$file" | sed 's/tags: \[\(.*\)\]/\1/')
    
    # Display result with metadata
    echo -e "\e[1;36m[$count] $title\e[0m"
    echo -e "  Path: \e[0;33m$(realpath --relative-to="$NOTES_DIR" "$file")\e[0m"
    echo -e "  Created: $date | Modified: $modified"
    echo -e "  Tags: $tags"
    echo ""
  done
  
  # Prompt user to open a result
  echo -n "Enter number to open in Neovim (or q to quit): "
  read selection
  
  if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -le "$count" ] && [ "$selection" -gt 0 ]; then
    file_to_open=$(echo "$files" | sed -n "${selection}p")
    nvim "$file_to_open"
  elif [[ "$selection" != "q" ]]; then
    echo "Invalid selection."
  fi
}

# Handle different search modes
if [ "$RECENT" -gt 0 ]; then
  # Find recent files
  echo "Finding $RECENT most recently modified notes..."
  results=$(find "$NOTES_DIR" -type f -name "*.md" -exec stat -f "%m %N" {} \; | sort -nr | head -n "$RECENT" | cut -d' ' -f2-)
  display_results "$results"
  exit 0
fi

# Build search command based on options
if [ -n "$SEARCH_TAG" ]; then
  echo "Searching for notes with tag: $SEARCH_TAG"
  results=$(grep -l "tags: .*\"$SEARCH_TAG\"" $(find "$NOTES_DIR" -type f -name "*.md"))
elif [ -n "$SEARCH_CATEGORY" ]; then
  echo "Searching for notes in category: $SEARCH_CATEGORY"
  results=$(find "$NOTES_DIR/${SEARCH_CATEGORY}s" -type f -name "*.md" 2>/dev/null)
  if [ -z "$results" ]; then
    results=$(grep -l "category: $SEARCH_CATEGORY" $(find "$NOTES_DIR" -type f -name "*.md"))
  fi
elif [ -n "$SEARCH_DATE" ]; then
  echo "Searching for notes from date: $SEARCH_DATE"
  date_no_hyphens=$(echo "$SEARCH_DATE" | tr -d '-')
  results=$(find "$NOTES_DIR" -type f -name "${date_no_hyphens}-*.md" 2>/dev/null)
  if [ -z "$results" ]; then
    results=$(grep -l "date: $SEARCH_DATE" $(find "$NOTES_DIR" -type f -name "*.md"))
  fi
else
  echo "Searching for: $SEARCH_TERM"
  if command -v rg &> /dev/null; then
    # Use ripgrep if available (faster)
    results=$(rg -l "$SEARCH_TERM" --type md "$NOTES_DIR")
  else
    # Fall back to grep
    results=$(grep -l "$SEARCH_TERM" $(find "$NOTES_DIR" -type f -name "*.md"))
  fi
fi

display_results "$results"
