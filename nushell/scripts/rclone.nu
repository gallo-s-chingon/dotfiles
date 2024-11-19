# ===========================
# Rclone functions
# ===========================

let base_opts = "-P --exclude-from $env.XDG_CONFIG_HOME/clear --fast-list"
let move_opts = "--delete-empty-src-dirs"
let new_dedupe = "--dedupe-mode newest"
let old_dedupe = "--dedupe-mode oldest"

# Define a function to execute rclone commands
def execute_rclone_command [
    command: string,
    source_dir: string,
    target_dir?: string,
    extra_opts?: string
] {
    if not ($source_dir | path exists) {
        echo "(눈︿눈)   Source file or directory '$source_dir' does not exist."
        return 1
    }

    ^rclone $command $base_opts $source_dir $target_dir $extra_opts
}

## Copy with rclone
# usage: rclone_copy <source_dir> <target_dir>
def rclone_copy [source_dir: string, target_dir: string] {
    execute_rclone_command "copy" $source_dir $target_dir
}

## Move with rclone
# usage: rclone_move <source_dir> <target_dir>
def rclone_move [source_dir: string, target_dir: string] {
    execute_rclone_command "move" $source_dir $target_dir $move_opts
}

## Dedupe with rclone keeping newest files
# usage: rclone_dedupe_new <source_dir>
def rclone_dedupe_new [source_dir: string] {
    execute_rclone_command "dedupe" $source_dir "--by-hash" $new_dedupe
}

## Dedupe with rclone keeping oldest files
# usage: rclone_dedupe_old <source_dir>
def rclone_dedupe_old [source_dir: string] {
    execute_rclone_command "dedupe" $source_dir "--by-hash" $old_dedupe
}
