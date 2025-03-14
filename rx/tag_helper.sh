#!/usr/bin/env bash

# tag-helper.sh - Suggest tags for a note based on its content using external dictionaries
# Usage: ./tag-helper.sh [path-to-markdown-file]

# Dictionary location
DICT_DIR="$HOME/.config/notes-dictionary"

# Create dictionary directory if it doesn't exist
mkdir -p "$DICT_DIR"

# Create default dictionaries if they don't exist
create_default_dictionaries() {
  # Tech dictionary
  if [ ! -f "$DICT_DIR/tech.dict" ]; then
    cat >"$DICT_DIR/tech.dict" <<EOF
bash:bash shell script command terminal
python:python py script function module pip venv
neovim:neovim nvim vim editor plugin lua
git:git commit push pull repository branch merge
linux:linux ubuntu debian alpine terminal shell command
macos:macos mac osx apple macbook
database:database sql query table schema
api:api rest endpoint request response json
EOF
  fi

  # Learning dictionary
  if [ ! -f "$DICT_DIR/learning.dict" ]; then
    cat >"$DICT_DIR/learning.dict" <<EOF
tutorial:tutorial guide how-to learn step steps
concept:concept theory principle understand understanding
reference:reference documentation doc docs manual
example:example sample instance code-sample demonstration
EOF
  fi

  # Personal dictionary
  if [ ! -f "$DICT_DIR/personal.dict" ]; then
    cat >"$DICT_DIR/personal.dict" <<EOF
recipe:recipe cook cooking food meal ingredient bake
dream:dream sleep nightmare vision
meditation:meditation mindfulness focus calm breath breathing
consciousness:consciousness aware awareness mindful spiritual
spirituality:spiritual spirit energy astral meditation chakra
EOF
  fi

  # Custom dictionary (empty template)
  if [ ! -f "$DICT_DIR/custom.dict" ]; then
    cat >"$DICT_DIR/custom.dict" <<EOF
# Add your custom tags in format: tag:keyword1 keyword2 keyword3
# Example:
# woodworking:wood saw chisel plane joinery furniture workshop
# electronics:circuit pcb solder component resistor capacitor
EOF
  fi

  echo "Default dictionaries created at $DICT_DIR"
  echo "You can customize them by editing the files directly."
}

# Check if a file was provided
if [ $# -ne 1 ] || [ ! -f "$1" ]; then
  echo "Usage: tag-helper [path-to-markdown-file]"
  exit 1
fi

FILE_PATH="$1"

# Create default dictionaries if needed
create_default_dictionaries

# Extract content from the file (excluding front matter)
CONTENT=$(sed -n '/^---$/,/^---$/!p' "$FILE_PATH")

# Initialize tag array
SUGGESTED_TAGS=()

# Function to load a dictionary and check content against it
check_dictionary_file() {
  local dict_file="$1"

  if [ -f "$dict_file" ]; then
    while IFS=: read -r tag keywords || [ -n "$tag" ]; do
      # Skip comments and empty lines
      [[ "$tag" =~ ^#.*$ ]] && continue
      [[ -z "$tag" ]] && continue

      if echo "$CONTENT" | grep -q -i -E "(^|\s)($keywords)(\s|$|\.|\,|\:|;)"; then
        SUGGESTED_TAGS+=("$tag")
      fi
    done <"$dict_file"
  fi
}

# Check content against all dictionary files
for dict_file in "$DICT_DIR"/*.dict; do
  check_dictionary_file "$dict_file"
done

# Extract any potential tags from markdown headings
HEADING_TAGS=$(echo "$CONTENT" | grep -E "^#+\s+" |
  sed 's/^#+\s\+//' |
  tr '[:upper:]' '[:lower:]' |
  sed 's/[^a-z0-9]/-/g' |
  sed 's/--*/-/g' |
  sed 's/^-//' |
  sed 's/-$//')

# Add heading-based tags
for tag in $HEADING_TAGS; do
  if [ ${#tag} -gt 3 ] && [ ${#tag} -lt 20 ]; then
    SUGGESTED_TAGS+=("$tag")
  fi
done

# Remove duplicates
UNIQUE_TAGS=($(echo "${SUGGESTED_TAGS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Output the suggested tags
if [ ${#UNIQUE_TAGS[@]} -gt 0 ]; then
  echo "Suggested tags for $(basename "$FILE_PATH"):"
  echo "${UNIQUE_TAGS[@]}"

  # Ask if user wants to update the file
  read -p "Would you like to add these tags to your note? (y/n): " CHOICE
  if [[ $CHOICE =~ ^[Yy] ]]; then
    # Extract current tags
    CURRENT_TAGS=$(grep -E "^tags: \[.*\]" "$FILE_PATH" | sed 's/tags: \[\(.*\)\]/\1/')

    # Combine current and new tags
    if [ -n "$CURRENT_TAGS" ]; then
      COMBINED_TAGS="$CURRENT_TAGS, \"${UNIQUE_TAGS[@]/%/\", \"}\""
      COMBINED_TAGS=${COMBINED_TAGS%, \"\"}
    else
      COMBINED_TAGS="\"${UNIQUE_TAGS[@]/%/\", \"}\""
      COMBINED_TAGS=${COMBINED_TAGS%, \"\"}
    fi

    # Update the file
    sed -i "s/tags: \[.*\]/tags: [$COMBINED_TAGS]/" "$FILE_PATH"
    echo "Tags added to note!"
  else
    echo "No changes made to the note."
  fi
else
  echo "No tags could be suggested based on the content."
fi

# Provide info about editing dictionaries
echo ""
echo "To add custom tags and keywords, edit files in $DICT_DIR/"
echo "Format: tag:keyword1 keyword2 keyword3"
