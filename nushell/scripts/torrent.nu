# ===========================
# Torrent Management Functions
# ===========================
let TORRENT_DIR = '/Volumes/kalisma/torrent'
let BACKUP_DIR = '/Volumes/armor'
let REPOS = [
  $"($env.HOME)/.dotfiles",
  $"($env.HOME)/.lua-is-the-devil",
  $"($env.HOME)/.noktados",
  $"($env.HOME)/Documents/widclub",
  $"($env.HOME)/notes"
]

## Open Torrent Files
def open_downloaded_torrents [] {
  ls $"($env.DN)/*.torrent" | each { |file| open $file.name }
  open -a wezterm
}

## Move Torrent Files
def move_torrents [source_dir: string, target_dir: string, pattern: string] {
  if not ($target_dir | path exists) {
    mkdir $target_dir
  }
  fd -e torrent $pattern --search-path $source_dir -X mv -v {} $target_dir
}

def move_emp_torrents [] {
  move_torrents $env.DN $"($TORRENT_DIR)/EMP" --search 'empornium'
}

def move_mam_torrents [] {
  move_torrents $env.DN $"($TORRENT_DIR)/MAM" --search '[^[0-9]{6,6}]'
}

def move_btn_torrents [] {
  let destination = $"($TORRENT_DIR)/BTN"
  ls $"($env.DN)/*.torrent" | each { |file|
    let tracker_info = (^transmission-show $file.name | grep -o "landof")
    if ($tracker_info | is-not-empty) {
      mv -v $file.name $destination
    }
  }
}

def open_btn_torrents_in_transmission [] {
  ls $"($env.DN)/*.torrent" | each { |file|
    let tracker_info = (^transmission-show $file.name | grep -o "landof")
    if ($tracker_info | is-not-empty) {
      open -a "Transmission" $file.name
    }
  }
}

def move_ptp_torrents [] {
  let destination = $"($TORRENT_DIR)/PTP"
  ls $"($env.DN)/*.torrent" | each { |file|
    let tracker_info = (^transmission-show $file.name | grep -o "passthepopcorn")
    if ($tracker_info | is-not-empty) {
      mv -v $file.name $destination
    }
  }
}

def open_ptp_torrents_in_deluge [] {
  ls $"($env.DN)/*.torrent" | each { |file|
    let tracker_info = (^transmission-show $file.name | grep -o "passthepopcorn")
    if ($tracker_info | is-not-empty) {
      open -a "Deluge" $file.name
    }
  }
}

def move_all_torrents [] {
  move_emp_torrents
  move_ptp_torrents
  move_mam_torrents
  move_btn_torrents
  open -a wezterm
}
