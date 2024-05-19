#!/bin/zsh
# 1. Install Apple's Command Line Tools
xcode-select --install

# 2. Create SSH key
ssh-keygen -t ed25519 -C "9777026+gallo-s-chingon@users.noreply.github.com"
touch ~/.ssh/config
echo "Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519" >> ~/.ssh/config
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# 3. Clone daught-fylz repository
git clone https://github.com/gallo-s-chingon/daught-fylz.git .dotfiles

# 4. Create hardlinks for dotfiles
ln -s .dotfiles .config
ln -s .config/zsh/zshrc .zshrc
ln -s .config/zsh/zprofile .zprofile
ln -s .config/zsh/zshenv .zshenv
ln -s .config/wezterm.lua .wezterm.lua

# 5. Run mac-os-defaults.sh
open -a Terminal ~/.config/rx/macos-defaults.sh

# 6. Install Homebrew and apps from Brewfile
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file ~/.config/Brewfile
