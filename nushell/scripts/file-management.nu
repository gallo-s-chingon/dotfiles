# ===========================
# File Management Functions
# ===========================
let BACKUP_DIR = "/Volumes/armor/"

def freespace [disk?: string] {
    if ($disk | is-empty) {
        echo "┐(￣ヘ￣)┌  ($env.CURRENT_FILE) <disk>"
        echo "Example: ($env.CURRENT_FILE) /dev/disk1s1"
        echo ""
        echo "Possible disks:"
        ^df -h | lines | where { $it | str starts-with "/dev/disk" or $it | str contains "Filesystem" }
        return
    }

    echo "٩(•̀ᴗ•́)و  Cleaning purgeable files from disk: ($disk)...."
    ^diskutil secureErase freespace 0 $disk
}

def move_repo_files_larger_than_99M [pwd_command: string] {
    let target_dir = $"($env.HOME)/jackpot"
    let files_to_move = (fd -tf -S +99M | lines)

    for file in $files_to_move {
        let filename = ($file | path basename)
        let target_path = $"($target_dir)/($file | path dirname)"
        mkdir $target_path
        mv $file $"($target_path)/($filename)"
    }
}

## Create and Open Script Files
def create_script_file [name: string] {
    let script_name = $"($name).sh"
    let script_file = $"($env.HOME)/.config/rx/($script_name)"

    if ($script_file | path exists) {
        echo "(눈︿눈)  Script file '($script_file)' already exists."
        return
    }

    mkdir ($script_file | path dirname)
    $"#!/bin/zsh" | save $script_file
    chmod +x $script_file
}

def open_script_file_in_editor [name: string] {
    let script_name = $"($name).sh"
    let script_file = $"($env.HOME)/.config/rx/($script_name)"

    if (not ($script_file | path exists)) {
        echo "(눈︿눈)  Script file '($script_file)' does not exist."
        return
    }

    nvim $script_file
}

def create_script_and_open [name: string] {
    create_script_file $name
    open_script_file_in_editor $name
}

## Move Files
def move_iso [] {
    let source_dir = $env.DN
    let target_dir = "/Volumes/armor/iso/"

    if (not ($target_dir | path exists)) {
        echo "0_0 you tard, ($target_dir) does NOT exist"
        return
    }

    for ext in [iso dmg pkg] {
        ls $"($source_dir)/*\.($ext)" | each { |file|
            mv $file.name $target_dir
            echo "( ⋂‿⋂) ($file.name | path basename) made its way to ($target_dir)"
        }
    }
}

def move_nix [] {
    let source_dir = $env.DN
    let target_dir = $"($BACKUP_DIR)/iso/nix/"

    if (not ($target_dir | path exists)) {
        echo "0_0 you tard, ($target_dir) does NOT exist"
        return
    }

    ls $"($source_dir)/*.iso" | each { |file|
        mv $file.name $target_dir
        echo "( ⋂‿⋂) ($file.name | path basename) made its way to ($target_dir)"
    }
}

def move_download_pix_to_pictures_dir [] {
    let source_dir = $env.DN
    let target_dir = $"($env.HOME)/Pictures/"

    for ext in [heic jpg jpeg png webp] {
        ls $"($source_dir)/*\.($ext)" | each { |file|
            mv $file.name $target_dir
            echo "( ⋂‿⋂) ($file.name | path basename) made its way to ($target_dir)"
        }
    }
}

def move_ipa_to_target_directory [] {
    let source_directory = $env.DN
    let target_directory = $"($BACKUP_DIR)/iso/ipa/"

    ls $"($source_directory)/*.ipa" | each { |file|
        mv $file.name $target_directory
        echo "( ⋂‿⋂) ($file.name | path basename) was moved to ($target_directory)"
    }
}

## Remove Files
def remove_pix [] {
    let old_dir = $env.PWD
    cd /Volumes/cold/ulto/
    fd -e jpg -e jpeg -e png -e webp -e nfo -e txt -x rm -v
    cd $old_dir
}

## Extract Archives
def expand [...filenames: string] {
    for filename in $filenames {
        if ($filename | path exists) {
            match ($filename | path extension) {
                "tar.bz2" => { tar xjf $filename },
                "tar.gz" => { tar xzf $filename },
                "bz2" => { bunzip2 $filename },
                "rar" => { unrar x $filename },
                "gz" => { gunzip $filename },
                "tar" => { tar xf $filename },
                "tbz2" => { tar xjf $filename },
                "tgz" => { tar xzf $filename },
                "zip" => { unzip $filename },
                "Z" => { uncompress $filename },
                "7z" => { 7z x $filename },
                _ => { echo "(눈︿눈) '$filename' cannot be extracted via ex()" }
            }
        } else {
            echo "(눈︿눈) '$filename' is not found"
        }
    }
}

## Create and Navigate to Directory
def mkd [...dirs: string] {
    mkdir $dirs
    cd ($dirs | last)
}

## Backup and Restore Files
def bak [file: string] {
    let filename = ($file | path parse).stem
    let extension = ($file | path parse).extension

    if $extension == "bak" {
        let base_filename = ($filename | path parse).stem
        mv $file $base_filename
        echo "Removed.bak extension from ($file). New filename: ($base_filename)"
    } else {
        let new_filename = $"($file).bak"
        if ($new_filename | path exists) {
            echo "(눈︿눈)  ($new_filename) already exists."
        } else {
            mv $file $new_filename
            echo "Appended.bak extension to ($file). New filename: ($new_filename)"
        }
    }
}

def debak [target: string] {
    if ($target | str contains ".bak") {
        let new_name = ($target | str replace ".bak" "")
        if ($new_name | path exists) {
            echo "(눈︿눈)  File or directory '$new_name' already exists."
            return
        }
        mv $target $new_name
        echo "Removed.bak from '$target'. New name: '$new_name'"
    } else {
        echo "No.bak found in '$target'."
    }
}
