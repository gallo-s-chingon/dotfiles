#!/bin/zsh
export PATH=/opt/homebrew/bin/:$PATH
igdown () {
    cd /Volumes/armor/didact/IG
    instaloader --login=gallo.s.chingon --no-video-thumbnails --no-profile-pic --no-captions --no-metadata-json --latest-stamps /Users/gchingon/.config/instaloader/latest-stamps.ini ignorancebegone
    instaloader --login=gallo.s.chingon --no-video-thumbnails --no-profile-pic --no-captions --no-metadata-json --latest-stamps /Users/gchingon/.config/instaloader/latest-stamps.ini paths2frdm2022
    instaloader --login=gallo.s.chingon --no-video-thumbnails --no-profile-pic --no-captions --no-metadata-json --latest-stamps /Users/gchingon/.config/instaloader/latest-stamps.ini receiptdropper
    instaloader --login=gallo.s.chingon --no-video-thumbnails --no-profile-pic --no-captions --no-metadata-json --latest-stamps /Users/gchingon/.config/instaloader/latest-stamps.ini yusef_el_19
    instaloader --login=gallo.s.chingon --no-video-thumbnails --no-profile-pic --no-captions --no-metadata-json --latest-stamps /Users/gchingon/.config/instaloader/latest-stamps.ini amyr_law
    instaloader --login=gallo.s.chingon --no-video-thumbnails --no-profile-pic --no-captions --no-metadata-json --latest-stamps /Users/gchingon/.config/instaloader/latest-stamps.ini mansamahatha888
}

igdown
