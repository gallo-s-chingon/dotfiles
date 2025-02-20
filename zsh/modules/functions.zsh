# ===========================
# Miscellaneous Functions
# ===========================

timer() {
  termdown "$1"
  cvlc "$HOME/Music/ddd.mp3" --play-and-exit >/dev/null
}

slug() {
    if [ $# -ne 1 ]; then
        echo "(￣ヘ￣)  slugifying <filename>"
        return 1
    fi

    filename=$1
    slugified=$(slugged "$filename")
    echo "$slugified"
}

trim-video () {
  if [ $# -eq 3 ]; then
    ffmpeg -i "$2" -ss "$1" -c:v copy -c:a copy "$3"

  elif [ $# -eq 2 ]; then
    ffmpeg -i "$1" -c:v copy -c:a copy "$2"
  else
    echo "Usage: trim-video input-file output-file (start-time)"
    return 1
  fi

}

open-nvim-init() {
  nvim "$HOME/il-diab/init.lua"
}

open-wezterm() {
  nvim "$HOME/dots/wezterm.lua"
}

open-ghostty() {
  nvim "$CF/ghostty/config"
}

select-pattern() {
    local selection=$1
    local pattern-dir="$HOME/.config/fabric/patterns"
    local -a patterns

    # Populate the patterns array
    while IFS= read -r -d '' dir; do
        patterns+=("$dir")
    done < <(find "$pattern-dir" -type d -mindepth 1 -maxdepth 1 -print0)

    # Check if the selection is valid
    if [[ $selection -ge 1 && $selection -le ${#patterns[@]} ]]; then
        selected-pattern="${patterns[$((selection-1))]}"
        echo "Selected pattern: $(basename "$selected-pattern")"
    else
        echo "Invalid selection"
        return 1
    fi
}

