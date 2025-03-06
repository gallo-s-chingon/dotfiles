#!/bin/bash
source ~/.config/zsh/modules/functions.zsh

srt_to_md() {
  local input_file="$1"
  local output_file="${input_file%.srt}.md"

  echo "Converting SRT to Markdown: $input_file → $output_file"
  nvim --headless -u NONE -c "luafile ~/.config/nvim/scripts/srt_to_md.lua" "$input_file" 2>/dev/null

  if [[ ! -f "$output_file" || ! -s "$output_file" ]]; then
    log_message "srt_to_md" "ERROR" "Failed to convert $input_file to Markdown"
    return 1
  fi

  log_message "srt_to_md" "INFO" "Successfully converted $input_file to $output_file"
  rm "$input_file"
  return 0
}

fabric_youtube_automation() {
  local VIDEO_URL="$1"
  local PATTERN_NAME="$2"
  local LOG_DIR="$HOME/log"
  local PARENT_DIR

  [[ -z "$VIDEO_URL" ]] && {
    log_message "fabric_youtube_automation" "ERROR" "No URL provided"
    return 1
  }
  mkdir -p "$LOG_DIR"

  VIDEO_TITLE=$(yt-dlp --print title "$VIDEO_URL" 2>/dev/null) || {
    log_message "fabric_youtube_automation" "ERROR" "Failed to extract title"
    return 1
  }
  VIDEO_ID=$(yt-dlp --print id "$VIDEO_URL" 2>/dev/null) || {
    log_message "fabric_youtube_automation" "ERROR" "Failed to extract ID"
    return 1
  }

  [[ -z "$PATTERN_NAME" ]] && PATTERN_NAME=$(find "$HOME/.config/fabric/patterns" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | fzf)
  [[ -z "$PATTERN_NAME" ]] && {
    log_message "fabric_youtube_automation" "ERROR" "No pattern selected"
    return 1
  }

  local ORIGINAL_PATTERN="$PATTERN_NAME"
  local PATTERN_SLUG=$(slugify "$PATTERN_NAME")
  local SLUG_TITLE=$(slugify "$VIDEO_TITLE")

  PARENT_DIR=$([[ -d "/Volumes/armor/didact/YT" ]] && echo "/Volumes/armor/didact/YT" || echo "${PWD}")
  local OUTPUT_DIR="$PARENT_DIR/$SLUG_TITLE"
  local MD_FILE="$OUTPUT_DIR/${SLUG_TITLE}-${VIDEO_ID}-${PATTERN_SLUG}.md"
  local TRANSCRIPT_FILE="$OUTPUT_DIR/${SLUG_TITLE}-${VIDEO_ID}-transcript.srt"
  local TRANSCRIPT_MD_FILE="$OUTPUT_DIR/${SLUG_TITLE}-${VIDEO_ID}-transcript.md"

  mkdir -p "$OUTPUT_DIR" || {
    log_message "fabric_youtube_automation" "ERROR" "Failed to create $OUTPUT_DIR"
    return 1
  }

  if [[ ! -f "$TRANSCRIPT_MD_FILE" && ! -f "$TRANSCRIPT_FILE" ]]; then
    yt-dlp --write-auto-sub --skip-download --sub-format srt -o "$OUTPUT_DIR/${SLUG_TITLE}-${VIDEO_ID}" "$VIDEO_URL" 2>/dev/null || echo "Transcript download failed, continuing..."
  fi

  if [[ -f "$TRANSCRIPT_FILE" && ! -f "$TRANSCRIPT_MD_FILE" ]]; then
    srt_to_md "$TRANSCRIPT_FILE" || return 1
  fi

  clean_memory
  if [[ -f "$TRANSCRIPT_MD_FILE" ]]; then
    fabric -f "$TRANSCRIPT_MD_FILE" -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2>/dev/null
  else
    fabric -y "$VIDEO_URL" -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2>/dev/null
  fi

  [[ ! -f "$MD_FILE" || ! -s "$MD_FILE" ]] && {
    log_message "fabric_youtube_automation" "ERROR" "Failed to create $MD_FILE"
    return 1
  }

  log_message "fabric_youtube_automation" "INFO" "Successfully completed processing $VIDEO_URL in $OUTPUT_DIR"
  echo "Markdown file: $MD_FILE"
  [[ -f "$TRANSCRIPT_MD_FILE" ]] && echo "Transcript Markdown: $TRANSCRIPT_MD_FILE"
  return 0
}

fabric_youtube_automation "$@"

