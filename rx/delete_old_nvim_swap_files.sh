#!/bin/zsh
cd
fd -tf -e swp --age 6h -x rm -frv {} > /dev/null
