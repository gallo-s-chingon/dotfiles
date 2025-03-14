#!/bin/bash

# Directory to process (e.g., 01-inbox/ for testing)
DIR="01-jackpot"

# Loop through Markdown files
for file in "$DIR"/*.md; do
  if [[ -f "$file" ]]; then
    # Extract date from front matter (between ---)
    DATE=$(awk '/^---$/{if (p) exit; p=1; next} p && /^date: /{
      gsub(/date: /, ""); gsub(/[-: ]/, ""); print substr($0, 1, 8); exit
    }' "$file")

    # If date found, rename file
    if [[ -n "$DATE" && "$DATE" =~ ^[0-9]{8}$ ]]; then
      BASENAME=$(basename "$file" .md)
      NEWNAME="$DIR/$DATE-$BASENAME.md"
      if [[ "$file" != "$NEWNAME" ]]; then
        mv -v "$file" "$NEWNAME"
        echo "Renamed: $file -> $NEWNAME"
      fi
    else
      echo "No valid date found in $file, skipping..."
    fi
  fi
done
