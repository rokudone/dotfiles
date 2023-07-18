#!/bin/bash 

# sudo apt install make gcc
# sudo apt install openssl
# sudo apt-get install zlib1g-dev # for ruby-build

# Make sure using latest Homebrew
brew update
brew upgrade

brew install zsh
# zsh を etc/shells に追加
if ! `grep "$(brew --prefix)/bin/zsh" /etc/shells > /dev/null` ; then
  echo $(brew --prefix)/bin/zsh | sudo tee -a /etc/shells
fi
# nvim
brew install nvim
brew install ripgrep
brew install nkf
brew install exa
brew install fzf
brew install fd
brew install ghq
brew install keychain
brew install gcc

brew install universal-ctags

brew install python3
brew install node
brew install yarn
brew install deno
brew install rbenv
brew install ruby-build
brew install openssl

brew cleanup -s
chsh -s /home/linuxbrew/.linuxbrew/bin/zsh

pip3 install pynvim neovim
yarn global add neovim
