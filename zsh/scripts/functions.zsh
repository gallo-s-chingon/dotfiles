# ===========================
# Miscellaneous Functions
# ===========================

source_zshrc() {
  update_zwc
  source $HOME/.config/zsh/zshrc >/dev/null
}

update_zwc () {
  compile_zdot() { [ -f "$1" ] && zcompile "$1" && info "Compiled $1" }
  compile_zdot "$DOTZ/scripts/*.zsh"
  compile_zdot "$DOTZ/z*"
  return 0
}

timer() {
  termdown "$1"
  cvlc "$HOME/Music/ddd.mp3" --play-and-exit >/dev/null
}

tree_with_exclusions() {
  tree -a -I ".DS_Store|.git|node_modules|vendor/bundle" -N
}

fd_exclude_dir_find_name_move_to_exclude_dir()
{
  fd -tf "$1" -E "$2" -x mv {} "$2"
}

fd_files_move_to_dir() {
  fd -tf -d 1 "$1" -x mv -v {} "$2"
}

fd_type() {
  fd --type d | while read -r dir; do
    echo "$dir"
    eza -1 "$dir" | grep -v '/$' | awk -F. '{print "*."$NF}' | sort -u
  done
}

slug() {
    if [ $# -ne 1 ]; then
        echo "(￣ヘ￣)  slugifying <filename>"
        return 1
    fi

    filename=$1
    slugified=$(slugify -atcdu "$filename")
    echo "$slugified"
}

trim_video () {
  if [ $# -eq 3 ]; then
    ffmpeg -i "$2" -ss "$1" -c:v copy -c:a copy "$3"

  elif [ $# -eq 2 ]; then
    ffmpeg -i "$1" -c:v copy -c:a copy "$2"
  else
    echo "Usage: trim_video input_file output_file (start_time)"
    return 1
  fi

}

open_nvim_init() {
  nvim "$HOME/.lua-is-the-devil/init.lua"
}

open_wezterm() {
  nvim "$HOME/.wezterm.lua"
}

open_zsh_history ()
{
  nvim "$HOME/.zsh_history"
}

open_zshrc() {
  nvim "$DOTZ/zshrc"
}

open_aliases() {
  nvim "$DOTZ/scripts/aliases.zsh"
}

open_functions() {
  cd "$DOTZ/scripts/"
  nvim -c "args *.zsh"
}

ffmpeg_remux_audio_video (){
  ffmpeg -i "$1" -i "$2" -c copy "$3"
}

spotify_dl ()
{
  spotdl download "$1"
}

wmv_to_mp4() {
    find . -maxdepth 2 -type f -name "*.wmv" | while read -r f; do
        output_file="${f%.wmv}.mp4"
        ffmpeg -i "$f" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "$output_file"
    done
    echo "Conversion complete!"
}

mkv_to_mp4() {
    find . -maxdepth 2 -type f -name "*.mkv" | while read -r f; do
        output_file="${f%.mkv}.mp4"
        ffmpeg -i "$f" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "$output_file"
    done
    echo "Conversion complete!"
}

function fabric_pattern() {
    local input_file=$1
    local pattern_name=$2
    local output_dir=${3:-.}  # Default to current directory if no third argument is provided
    local base_filename=$(basename "$input_file" | cut -d. -f1)
    local output_file="${output_dir}/${base_filename}-${pattern_name}.md"

    # Check if the file already exists in the specified directory
    if [ -e "$output_file" ]; then
        local suffix=00
        while [ -e "${output_dir}/${base_filename}-${pattern_name}-${suffix}.md" ]; do
            ((suffix++))
            if [[ $suffix -ge 256 ]]; then
                echo "Error: Maximum number of files reached."
                return 1
            fi
        done

        output_file="${output_dir}/${base_filename}-${pattern_name}-${suffix}.md"
    fi

    # Use fabric with the specified pattern to generate the markdown file
    cat "$input_file" | fabric -p "${pattern_name//_/-}" > "$output_file"
    echo "Output saved to $output_file"
}
