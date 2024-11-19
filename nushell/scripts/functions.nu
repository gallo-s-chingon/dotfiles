# ===========================
# Miscellaneous Functions
# ===========================

def source_zshrc [] {
    update_zwc
    source $"($env.HOME)/.config/nushell/config.nu" >/dev/null
}

def update_zwc [] {
    def compile_zdot [file: string] {
        if ($file | path exists) {
            ^zcompile $file
            echo "Compiled $file"
        }
    }

    compile_zdot $"($env.DOTZ)/scripts/*.zsh"
    compile_zdot $"($env.DOTZ)/z*"
    return 0
}

def timer [time: string] {
    ^termdown $time
    ^cvlc $"($env.HOME)/Music/ddd.mp3" --play-and-exit >/dev/null
}

def tree_with_exclusions [] {
    ^tree -a -I ".DS_Store|.git|node_modules|vendor/bundle" -N
}

def fd_exclude_dir_find_name_move_to_exclude_dir [pattern: string, dir: string] {
    ^fd -tf $pattern -E $dir -x mv {} $dir
}

def fd_files_move_to_dir [pattern: string, target_dir: string] {
    ^fd -tf -d 1 $pattern -x mv -v {} $target_dir
}

def fd_type [] {
    ^fd --type d | while read -r dir; do
        echo $dir
        ^eza -1 $dir | grep -v '/$' | awk -F. '{print "*."$NF}' | sort -u
    done
}

def slug [filename: string] {
    if ($filename | is-empty) {
        echo "(￣ヘ￣)  slugifying <filename>"
        return 1
    }

    let slugified = (^slugify -atcdu $filename)
    echo $slugified
}

def trim_video [input_file: string, output_file: string, start_time?: string] {
    if ($start_time | is-empty) {
        ^ffmpeg -i $input_file -c:v copy -c:a copy $output_file
    } else {
        ^ffmpeg -i $input_file -ss $start_time -c:v copy -c:a copy $output_file
    }
}

def open_nvim_init [] {
    nvim $"($env.HOME)/.lua-is-the-devil/nvim/init.lua"
}

def open_wezterm [] {
    nvim $"($env.XDG_CONFIG_HOME)/wezterm.lua"
}

def open_zsh_history [] {
    nvim $"($env.HOME)/.zsh_history"
}

def open_zshrc [] {
    nvim $"($env.DOTZ)/zshrc"
}

def open_aliases [] {
    nvim $"($env.DOTZ)/scripts/aliases.zsh"
}

def open_functions [] {
    cd $"($env.DOTZ)/scripts/"
    nvim -c "args *.zsh"
}

def ffmpeg_remux_audio_video [input_file1: string, input_file2: string, output_file: string] {
    ^ffmpeg -i $input_file1 -i $input_file2 -c copy $output_file
}

def spotify_dl [url: string] {
    ^spotdl download $url
}

def mkv_to_mp4 [] {
    for f in *.mkv; do
        ^ffmpeg -i $f -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "${f%.mkv}.mp4"
    done
    echo "Conversion complete!"
}
