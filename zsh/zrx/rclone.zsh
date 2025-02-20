# ===========================
# Rclone functions
# ===========================

base_opts="-P --exclude-from $XDG_CONFIG_HOME/clear --fast-list"
move_opts="--delete-empty-src-dirs"
new_dedupe="--dedupe-mode newest"
old_dedupe="--dedupe-mode oldest"

# Define a function to execute rclone commands
function execute_rclone_command() {
    local command="$1"
    local source_dir="$2"
    local target_dir="$3"
    local extra_opts="$4"

    if [ ! -e "$source_dir" ]; then
        echo "(눈︿눈)   Source file or directory '$source_dir' does not exist."
        return 1
    fi

    rclone "$command" "$base_opts" "$source_dir" "$target_dir" "$extra_opts"
}

## Copy with rclone
# usage: rclone_copy <source_dir> <target_dir>
function rclone_copy() {
    local source_dir="$1"
    local target_dir="$2"
    execute_rclone_command "copy" "$source_dir" "$target_dir"
}

## Move with rclone
# usage: rclone_move <source_dir> <target_dir>
function rclone_move() {
    local source_dir="$1"
    local target_dir="$2"
    execute_rclone_command "move" "$source_dir" "$target_dir" "$move_opts"
}

## Dedupe with rclone keeping newest files
# usage: rclone_dedupe_new <source_dir>
function rclone_dedupe_new() {
    local source_dir="$1"
    execute_rclone_command "dedupe" "$source_dir" "--by-hash" "$new_dedupe"
}

## Dedupe with rclone keeping oldest files
# usage: rclone_dedupe_old <source_dir>
function rclone_dedupe_old() {
    local source_dir="$1"
    execute_rclone_command "dedupe" "$source_dir" "--by-hash" "$old_dedupe"
}

