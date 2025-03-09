#!/bin/zsh
source ~/.config/zsh/modules/general.zsh

fabric_youtube_automation() {
  local VIDEO_URL="$1"
  local PATTERN_NAME="$2"
  local LOG_DIR="$HOME/log"
  local PARENT_DIR

  [[ -z "$VIDEO_URL" ]] && { log_message "fabric_youtube_automation" "ERROR" "No URL provided"; return 1; }
  mkdir -p "$LOG_DIR"

  VIDEO_TITLE=$(yt-dlp --print title "$VIDEO_URL" 2>/dev/null) || { log_message "fabric_youtube_automation" "ERROR" "Failed to extract title"; return 1; }
  VIDEO_ID=$(yt-dlp --print id "$VIDEO_URL" 2>/dev/null) || { log_message "fabric_youtube_automation" "ERROR" "Failed to extract ID"; return 1; }

  [[ -z "$PATTERN_NAME" ]] && PATTERN_NAME=$(find "$HOME/.config/fabric/patterns" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | fzf)
  [[ -z "$PATTERN_NAME" ]] && { log_message "fabric_youtube_automation" "ERROR" "No pattern selected"; return 1; }

  local ORIGINAL_PATTERN="$PATTERN_NAME"
  local PATTERN_SLUG=$(slugify "$PATTERN_NAME")
  local SLUG_TITLE=$(slugify "$VIDEO_TITLE")

  if [[ -d "/Volumes/armor/didact/YT" ]]; then
    PARENT_DIR="/Volumes/armor/didact/YT"
  elif [[ -d "/Volumes/Samsung/YT" ]]; then
    PARENT_DIR="/Volumes/Samsung/YT"
  else
    PARENT_DIR="$HOME/jactpot"
  fi

  local OUTPUT_DIR="$PARENT_DIR/$SLUG_TITLE"
  local MD_FILE="$OUTPUT_DIR/${SLUG_TITLE}-${VIDEO_ID}-${PATTERN_SLUG}.md"
  local TRANSCRIPT_SRT="$OUTPUT_DIR/${SLUG_TITLE}-${VIDEO_ID}-transcript.srt"
  local TRANSCRIPT_VTT="$OUTPUT_DIR/${SLUG_TITLE}-${VIDEO_ID}-transcript.vtt"
  local VTT_FILE="$OUTPUT_DIR/${SLUG_TITLE}-${VIDEO_ID}.en.vtt"

  mkdir -p "$OUTPUT_DIR" || { log_message "fabric_youtube_automation" "ERROR" "Failed to create $OUTPUT_DIR"; return 1; }

  # Download transcript if neither SRT nor VTT exists
  if [[ ! -f "$TRANSCRIPT_SRT" && ! -f "$TRANSCRIPT_VTT" ]]; then
    yt-dlp --write-auto-sub --skip-download --sub-format srt -o "$OUTPUT_DIR/${SLUG_TITLE}-${VIDEO_ID}" "$VIDEO_URL" 2>/dev/null || echo "Transcript download failed, continuing..."
    # Check if .en.vtt was downloaded and rename to -transcript.vtt
    if [[ -f "$VTT_FILE" && ! -f "$TRANSCRIPT_VTT" ]]; then
      mv "$VTT_FILE" "$TRANSCRIPT_VTT"
      log_message "fabric_youtube_automation" "INFO" "Renamed $VTT_FILE to $TRANSCRIPT_VTT"
    fi
  fi

  # Run fabric with available transcript
  clean_memory
  if [[ -f "$TRANSCRIPT_SRT" ]]; then
    fabric -f "$TRANSCRIPT_SRT" -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2>/dev/null
  elif [[ -f "$TRANSCRIPT_VTT" ]]; then
    fabric -f "$TRANSCRIPT_VTT" -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2>/dev/null
  else
    fabric -y "$VIDEO_URL" -p "$ORIGINAL_PATTERN" -o "$MD_FILE" 2>/dev/null
  fi

  [[ ! -f "$MD_FILE" || ! -s "$MD_FILE" ]] && { log_message "fabric_youtube_automation" "ERROR" "Failed to create $MD_FILE"; return 1; }

  log_message "fabric_youtube_automation" "INFO" "Successfully completed processing $VIDEO_URL in $OUTPUT_DIR"
  echo "Markdown file: $MD_FILE"
  [[ -f "$TRANSCRIPT_SRT" ]] && echo "Transcript SRT: $TRANSCRIPT_SRT"
  [[ -f "$TRANSCRIPT_VTT" ]] && echo "Transcript VTT: $TRANSCRIPT_VTT"
  return 0
}

fabric_youtube_automation "$@"