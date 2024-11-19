# ===========================
# ImageMagick Functions
# ===========================

def imagemagick_resize_50 [input_file: string, output_file: string] {
    ^magick $input_file -resize 50% $output_file
}

def imagemagick_resize_500 [input_file: string, output_file: string] {
    ^magick $input_file -resize 500 $output_file
}

def imagemagick_resize_720 [input_file: string, output_file: string] {
    ^magick $input_file -resize 720 $output_file
}

def imagemagick_shave [input_file: string, output_file: string, shave_args: string] {
    ^magick $input_file -shave $shave_args $output_file
}

def pick_color_fill_text [
    label: string,
    font: string,
    font_size: string,
    fill: string,
    filename: string,
    stroke?: string
] {
    if ($stroke | is-empty) {
        ^magick -background transparent -density 250 -pointsize $font_size -font $font -interline-spacing -15 -fill $fill -gravity center label:"$label" "$filename.png"
    } else {
        ^magick -background transparent -density 250 -pointsize $font_size -font $font -interline-spacing -15 -fill $fill -stroke $stroke -strokewidth 2 -gravity center label:"$label" "$filename.png"
    }
}

def youtube_thumbnail [
    label: string,
    filename: string,
    font?: string = "Arial-Black",
    template_img?: string = "$SCS/images/YT-thumbnail-template.png",
    output_dir?: string = "/Volumes/cold/sucias-pod-files/YT-thumbs",
    output_file?: string = "$output_dir/${filename}-thumb.png"
] {
    # Create temporary label image
    ^magick -background transparent -density 250 -pointsize 27 -font $font -interline-spacing -35 -fill gold -stroke magenta -strokewidth 2 -gravity center label:"$label" -rotate -12 $output_file

    # Composite label image with template and save final output
    ^magick composite -geometry +600+20 $output_file $template_img $output_file
}
