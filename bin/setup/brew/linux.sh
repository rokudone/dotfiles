#!/bin/bash 
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
brew install yarn
brew install nkf
brew install exa

brew install gcc #ctags用
brew install --HEAD universal-ctags/universal-ctags/universal-ctags

brew cleanup -s
chsh -s /home/linuxbrew/.linuxbrew/bin/zsh

pip3 install pynvim neovim
yarn global add neovim
