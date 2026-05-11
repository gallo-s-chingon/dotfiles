#!/usr/bin/env bash

set -euo pipefail

show_usage() {
  cat <<'EOF'
Usage: daily [title...]
       daily --list [YYYYMMDD|YYYY-MM-DD]

Create or open today's note in the machine-specific notes directory.

Behavior:
  - No title: open an existing YYYYMMDD-*.md note for today if one exists.
  - With title: open YYYYMMDD-slugged-title.md if it exists, otherwise create it.
  - --list: show dated notes, number them, and open the selected note in nvim.
    Pass a date to filter to notes with that YYYYMMDD- or YYYY-MM-DD- prefix.

Examples:
  daily
  daily Project kickoff
  daily "Ideas / wins & next steps"
  daily --list
  daily --list 20260508
  daily -l 2026-05-08
  daily --date 2026-05-08
EOF
}

resolve_notes_dir() {
  local machine_name="" host_name=""

  [[ -f "$HOME/.config/machine.env" ]] && source "$HOME/.config/machine.env"

  if [[ -n "${RW:-}" ]]; then
    printf '%s\n' "$RW"
    return 0
  fi

  machine_name="${MACHINE_NAME:-}"
  host_name="$(hostname -s 2>/dev/null || hostname 2>/dev/null || true)"

  case "${machine_name:-$host_name}" in
    mbp*)
      printf '%s\n' "$HOME/Documents/notes/raw"
      ;;
    4mini*)
      printf '%s\n' "$HOME/Documents/repos/notes/raw"
      ;;
    2mini*)
      printf '%s\n' "$HOME/Documents/2mepos/notes/raw"
      ;;
    *)
      if [[ -n "${NT:-}" ]]; then
        printf '%s\n' "$NT/raw"
      elif [[ -d "$HOME/Documents/notes/raw" ]]; then
        printf '%s\n' "$HOME/Documents/notes/raw"
      else
        printf '%s\n' "$HOME/notes/raw"
      fi
      ;;
  esac
}

slugify() {
  local input="$*" slug=""

  if command -v iconv >/dev/null 2>&1; then
    slug="$(
      printf '%s' "$input" \
        | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null || printf '%s' "$input"
    )"
  else
    slug="$input"
  fi

  slug="$(
    printf '%s' "$slug" \
      | tr '[:upper:]' '[:lower:]' \
      | tr -cs '[:alnum:]' '-' \
      | sed 's/^-*//; s/-*$//'
  )"

  printf '%s\n' "${slug:-daily}"
}

find_existing_daily() {
  local notes_dir="$1" compact_today="$2" legacy_today="$3"
  local preferred fallback

  preferred="${notes_dir}/${compact_today}-daily.md"

  if [[ -f "$preferred" ]]; then
    printf '%s\n' "$preferred"
    return 0
  fi

  shopt -s nullglob
  local matches=("${notes_dir}/${compact_today}-"*.md)
  shopt -u nullglob

  if [[ ${#matches[@]} -gt 0 ]]; then
    fallback="$(printf '%s\n' "${matches[@]}" | sort | head -n 1)"
    printf '%s\n' "$fallback"
    return 0
  fi

  preferred="${notes_dir}/${legacy_today}-daily.md"

  if [[ -f "$preferred" ]]; then
    printf '%s\n' "$preferred"
    return 0
  fi

  shopt -s nullglob
  matches=("${notes_dir}/${legacy_today}-"*.md)
  shopt -u nullglob

  if [[ ${#matches[@]} -gt 0 ]]; then
    fallback="$(printf '%s\n' "${matches[@]}" | sort | head -n 1)"
    printf '%s\n' "$fallback"
    return 0
  fi

  return 1
}

is_date_arg() {
  [[ "$1" =~ ^[0-9]{8}$ || "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
}

list_dated_notes() {
  local notes_dir="$1" date_filter="${2:-}"
  local path basename compact_prefix legacy_prefix

  if [[ -n "$date_filter" ]]; then
    if [[ "$date_filter" =~ ^[0-9]{8}$ ]]; then
      compact_prefix="$date_filter"
      legacy_prefix="${date_filter:0:4}-${date_filter:4:2}-${date_filter:6:2}"
    else
      compact_prefix="${date_filter//-/}"
      legacy_prefix="$date_filter"
    fi
  fi

  shopt -s nullglob
  for path in "${notes_dir}"/*.md; do
    basename="${path##*/}"
    if [[ -n "$date_filter" ]]; then
      [[ "$basename" == "${compact_prefix}-"* || "$basename" == "${legacy_prefix}-"* ]] || continue
    else
      [[ "$basename" =~ ^[0-9]{8}-.*\.md$ || "$basename" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-.*\.md$ ]] || continue
    fi
    printf '%s\n' "$path"
  done | sort
  shopt -u nullglob
}

pick_dated_note() {
  local notes_dir="$1" date_filter="${2:-}"
  local selection index file_path
  local -a notes

  while IFS= read -r file_path; do
    notes+=("$file_path")
  done < <(list_dated_notes "$notes_dir" "$date_filter")

  if [[ ${#notes[@]} -eq 0 ]]; then
    if [[ -n "$date_filter" ]]; then
      echo "No dated notes found for ${date_filter} in ${notes_dir}" >&2
    else
      echo "No dated notes found in ${notes_dir}" >&2
    fi
    exit 1
  fi

  for index in "${!notes[@]}"; do
    printf '%3d  %s\n' "$((index + 1))" "${notes[$index]##*/}"
  done

  read -r -p "Open note number: " selection
  [[ "$selection" =~ ^[0-9]+$ ]] || { echo "Selection must be a number" >&2; exit 1; }
  (( selection >= 1 && selection <= ${#notes[@]} )) || { echo "Selection out of range" >&2; exit 1; }

  file_path="${notes[$((selection - 1))]}"
  exec nvim "$file_path"
}

main() {
  local today daily_stamp notes_dir suffix file_path list_mode=0 date_filter=""
  local -a title_parts=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_usage
        exit 0
        ;;
      -l|--list|--pick)
        list_mode=1
        ;;
      --date)
        list_mode=1
        shift
        [[ $# -gt 0 ]] || { echo "Missing value for --date" >&2; exit 1; }
        is_date_arg "$1" || { echo "Invalid date: $1" >&2; exit 1; }
        date_filter="$1"
        ;;
      --date=*)
        list_mode=1
        date_filter="${1#*=}"
        is_date_arg "$date_filter" || { echo "Invalid date: $date_filter" >&2; exit 1; }
        ;;
      *)
        title_parts+=("$1")
        ;;
    esac
    shift
  done

  today="$(date +%F)"
  daily_stamp="$(date +%Y%m%d)"
  notes_dir="$(resolve_notes_dir)"

  if [[ "$list_mode" -eq 1 ]]; then
    if [[ ${#title_parts[@]} -gt 0 ]]; then
      if [[ ${#title_parts[@]} -eq 1 && -z "$date_filter" ]] && is_date_arg "${title_parts[0]}"; then
        date_filter="${title_parts[0]}"
      else
        echo "Unexpected title arguments in --list mode" >&2
        echo "Use: daily --list [YYYYMMDD|YYYY-MM-DD]" >&2
        exit 1
      fi
    fi

    mkdir -p "$notes_dir"
    pick_dated_note "$notes_dir" "$date_filter"
  fi

  if [[ ${#title_parts[@]} -gt 0 ]]; then
    suffix="$(slugify "${title_parts[@]}")"
    file_path="${notes_dir}/${daily_stamp}-${suffix}.md"
    mkdir -p "$notes_dir"
    [[ -e "$file_path" ]] || : > "$file_path"
  else
    mkdir -p "$notes_dir"
    if file_path="$(find_existing_daily "$notes_dir" "$daily_stamp" "$today")"; then
      :
    else
      file_path="${notes_dir}/${daily_stamp}-daily.md"
      : > "$file_path"
    fi
  fi

  exec nvim "$file_path"
}

main "$@"
