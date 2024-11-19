# ===========================
# Clipboard Functions
# ===========================

def read_file_content [file_path: string] {
    if not ($file_path | path exists) {
        echo "(눈︿눈)  File '$file_path' does not exist."
        return
    }
    cat $file_path
}

def copy_file_contents_to_clipboard [file_path: string] {
    read_file_content $file_path | clip
}

def paste_to_file [filename: string] {
    if ($filename | is-empty) {
        echo "┐(￣ヘ￣)┌  paste_to_file <filename>"
        return
    }
    clip | append $filename
}

def paste_output_to_clipboard [command: string] {
    if ($command | is-empty) {
        echo "٩(•̀ᴗ•́)و  Copying command output to clipboard"
        return
    }
    eval $command | clip
}
