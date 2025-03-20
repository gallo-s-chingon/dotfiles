#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/colorscheme/colorscheme.sh
# Combines color scheme definition and selection logic for modularity

# Configuration
COLORSCHEME_DIR=~/github/dotfiles-latest/colorscheme/list
COLORSCHEME_SET_SCRIPT=~/github/dotfiles-latest/zshrc/colorscheme-set.sh

# Ensure fzf is installed
check_dependencies() {
  if ! command -v fzf &>/dev/null; then
    echo "Error: fzf is not installed. Please install it first."
    exit 1
  fi
}

# Define the Schingon color scheme
define_schingon_colors() {
  # Lighter markdown headings (darkened 4 steps from original colors)
  schingon_color18="#5b4996"  # Markdown heading 1 (from #987afb)
  schingon_color19="#21925b"  # Markdown heading 2 (from #37f499)
  schingon_color20="#027d95"  # Markdown heading 3 (from #04d1f9)
  schingon_color21="#585c89"  # Markdown heading 4 (from #949ae5)
  schingon_color22="#0f857c"  # Markdown heading 5 (from #19dfcf)
  schingon_color23="#396592"  # Markdown heading 6 (from #5fa9f4)
  schingon_color26="#0D1116"  # Markdown heading foreground (terminal bg)

  # Base colors
  schingon_color04="#987afb"  # Original for heading 1
  schingon_color02="#37f499"  # Original for heading 2
  schingon_color03="#04d1f9"  # Original for heading 3
  schingon_color01="#949ae5"  # Original for heading 4
  schingon_color05="#19dfcf"  # Original for heading 5
  schingon_color08="#5fa9f4"  # Original for heading 6
  schingon_color06="#1682ef"  # Additional color

  # Background shades (progressive steps from #0D1116)
  schingon_color10="#0D1116"  # Terminal/neovim background
  schingon_color17="#141b22"  # Lualine (1 step)
  schingon_color07="#1c242f"  # Markdown codeblock (2 steps)
  schingon_color25="#232e3b"  # Inactive tmux pane (3 steps)
  schingon_color13="#314154"  # Line across cursor (5 steps)
  schingon_color15="#013e4a"  # Tmux inactive windows (7 steps)

  # Miscellaneous
  schingon_color09="#a5afc2"  # Comments
  schingon_color11="#f16c75"  # Underline spellbad
  schingon_color12="#f1fc79"  # Underline spellcap
  schingon_color14="#ebfafa"  # Cursor/tmux window text
  schingon_color16="#e9b3fd"  # Selected text
  schingon_color24="#f94dff"  # Cursor color
}

# List and select color schemes
select_scheme() {
  local schemes=($(ls "$COLORSCHEME_DIR"/*.sh 2>/dev/null | xargs -n 1 basename))
  
  if [ ${#schemes[@]} -eq 0 ]; then
    # If no external schemes, offer the built-in one
    schemes=("schingon-colors.sh")
  fi

  local selected_scheme=$(printf "%s\n" "${schemes[@]}" | fzf --height=40% --reverse \
    --header="Select a Color Scheme" --prompt="Theme > ")

  if [ -z "$selected_scheme" ]; then
    echo "No color scheme selected."
    exit 0
  fi

  echo "$selected_scheme"
}

# Apply the selected scheme
apply_scheme() {
  local scheme="$1"

  if [ "$scheme" = "schingon-colors.sh" ]; then
    define_schingon_colors
    # Simulate exporting variables (normally handled by colorscheme-set.sh)
    for var in $(compgen -A variable | grep "^schingon_color"); do
      echo "export $var=${!var}"
    done
  else
    # For external scripts, delegate to colorscheme-set.sh
    if [ -f "$COLORSCHEME_SET_SCRIPT" ]; then
      "$COLORSCHEME_SET_SCRIPT" "$scheme"
    else
      echo "Error: $COLORSCHEME_SET_SCRIPT not found."
      exit 1
    fi
  fi
}

# Main execution
main() {
  check_dependencies
  local selected=$(select_scheme)
  apply_scheme "$selected"
}

# Run the script
main
