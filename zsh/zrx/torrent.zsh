# ===========================
# Torrent Management Functions
# ===========================
TORRENT_DIR='/Volumes/kalisma/torrent'
BACKUP_DIR='/Volumes/armor'
REPOS=(
  "$HOME/.dotfiles"
  "$HOME/.lua-is-the-devil"
  "$HOME/.noktados"
  "$HOME/Documents/widclub"
  "$HOME/notes"
  )

## Open Torrent Files
function open_downloaded_torrents() {
  open $DN/*.torrent
  open -a wezterm
}

## Move Torrent Files
move_emp_torrents() {
  local source_dir="$DN"
  local target_dir="$TORRENT_DIR/EMP"
  fd -e torrent -i empornium --search-path "$source_dir" -X mv -v {} "$target_dir"
}

move_mam_torrents() {
  local source_dir="$DN"
  local target_dir="$TORRENT_DIR/MAM"
  fd -e torrent "[^[0-9]{6,6}]" --search-path "$source_dir" -X mv -v {} "$target_dir"
}

move_btn_torrents() {
  local destination="$TORRENT_DIR/BTN"
  local torrents=(~/Downloads/*.torrent(N))

  for torrent_file in "${torrents[@]}"; do
    local tracker_info=$(transmission-show "$torrent_file" | grep -o "landof")
    if [ -n "$tracker_info" ]; then
      mv -v "$torrent_file" "$destination"
    fi
  done
}

open_btn_torrents_in_transmission() {
  for torrent_file in "${torrents[@]}"; do
    local tracker_info=$(transmission-show "$torrent_file" | grep -o "landof")
    if [ -n "$tracker_info" ]; then
      open -a "Transmission" "$torrent_file"
    fi
  done
}

move_ptp_torrents () {
    local destination="$TORRENT_DIR/PTP"
    local torrents=(~/Downloads/*.torrent(N))
    for torrent_file in "${torrents[@]}"; do
        local tracker_info=$(transmission-show "$torrent_file" | grep -o "passthepopcorn")
        if [ -n "$tracker_info" ]; then
            mv -v "$torrent_file" "$destination"
        fi
    done
}

open_ptp_torrents_in_deluge () {
    local torrents=(~/Downloads/*.torrent(N))
    for torrent_file in "${torrents[@]}"; do
        local tracker_info=$(transmission-show "$torrent_file" | grep -o "passthepopcorn")
        if [ -n "$tracker_info" ]; then
            open -a "Deluge" "$torrent_file"
        fi
    done
}

move_all_torrents() {
  move_emp_torrents
  move_ptp_torrents
  move_mam_torrents
  move_btn_torrents
  open -a wezterm
}

