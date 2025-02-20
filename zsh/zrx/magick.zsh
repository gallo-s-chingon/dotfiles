# ===========================
# ImageMagick Functions
# ===========================

imagemagick_resize_50() {
  magick "$1" -resize 50% "$2"
}

imagemagick_resize_500() {
  magick "$1" -resize 500 "$2"
}

imagemagick_resize_720() {
  magick "$1" -resize 720 "$2"
}

imagemagick_shave() {
  magick "$1" -shave "$3" "$2"
}

pick_color_fill_text() {
    local label="$1"
    local font="$2"
    local font_size="$3"
    local fill="$4"
    local filename="$5"
    local stroke="$6"

    if [ -n "$stroke" ]; then
        magick -background transparent -density 250 -pointsize "$font_size" -font "$font" -interline-spacing -15 -fill "$fill" -stroke "$stroke" -strokewidth 2 -gravity center label:"$label" "$filename.png"
    else
        magick -background transparent -density 250 -pointsize "$font_size" -font "$font" -interline-spacing -15 -fill "$fill" -gravity center label:"$label" "$filename.png"
    fi
}

youtube_thumbnail() {
  local label="$1"
  local filename="$2"
  local font="Arial-Black"
  local template_img="$SCS/images/YT-thumbnail-template.png"
  local output_dir="/Volumes/cold/sucias-pod-files/YT-thumbs"
  local output_file="$output_dir/${filename}-thumb.png"

  ## Create temporary label image
  magick -background transparent -density 250 -pointsize 27 -font "$font" -interline-spacing -35 -fill gold -stroke magenta -strokewidth 2 -gravity center label:"$label" -rotate -12 "$output_file"

  ## Composite label image with template and save final output
  magick composite -geometry +600+20 "$output_file" "$template_img" "$output_file"
}

