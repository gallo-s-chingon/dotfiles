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
  nvim "$HOME/.lua-is-the-devil/nvim/init.lua"
}

open_wezterm() {
  nvim "$XDG_CONFIG_HOME/wezterm.lua"
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
