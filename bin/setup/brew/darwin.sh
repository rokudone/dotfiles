#!/bin/bash
# Make sure using latest Homebrew
brew update
brew upgrade

brew install zsh
# zsh を etc/shells に追加
if ! `grep "$(brew --prefix)/bin/zsh" /etc/shells > /dev/null` ; then
  echo $(brew --prefix)/bin/zsh | sudo tee -a /etc/shells
fi
brew tap homebrew/cask-versions

brew install autoconf
brew install automake
brew install binutils
brew install diffutils
brew install coreutils
brew install findutils # --with-default-names
brew install gawk
brew install gnu-indent # --with-default-names
brew install gnu-sed # --with-default-names
brew install gnu-tar # --with-default-names
brew install gnu-which # --with-default-names
brew install gnutls
brew install gnu-getopt
brew install grep # --with-default-names

brew tap z80oolong/tmux
# brew install z80oolong/tmux/tmux
brew install tmux

brew tap kyoshidajp/ghkw
brew install ghkw

brew install --HEAD neovim
brew install ansible
brew install gzip
brew install gcc #ctags用
brew install universal-ctags
brew install bat
brew install gibo
brew install jq
brew install fd
brew install tealdeer
brew install exa
brew install peco
brew install fzf
brew install z
brew install ghq hub gh
brew install screen
brew install the_silver_searcher
brew install tig
brew install gina
brew install cmigemo
brew install keychain
brew install rbenv
brew install ruby-build
# brew install rdiff-backup
brew install pyenv
brew install python3
brew install lua
brew install luajit
brew install git
brew install ripgrep
brew install yarn
brew install nkf
brew install n
brew install nodenv
brew install deno

brew install php
brew install sleepwatcher
brew install ssh-copy-id
brew install watch
# brew install wdiff --with-gettext
brew install wget
brew install w3m
brew install bash-completion
brew install boost
brew install cmake
brew install mercurial
brew install mas
brew install pcre
brew install circleci
brew install --HEAD universal-ctags/universal-ctags/universal-ctags
brew install koekeishiya/formulae/yabai
brew install koekeishiya/formulae/skhd
brew install rlwrap



brew install 1password
brew install alacritty
brew install alt-tab
brew install appcleaner
brew install arc
brew install bettertouchtool
brew install brave-browser
brew install chatgpt
brew install clickup
brew install cursor
brew install cursorsense
brew install dropbox
# brew install docker
brew install docker-compose
brew install firefox
brew install google-chrome
brew install google-drive
brew install google-chrome-canary
brew install hammerspoon
brew install iterm2
brew install insomnia
brew install java
brew install karabiner-elements
brew install kindle
brew install raycast
brew install rectangle
brew install tableplus
brew install todoist
brew install tunnelblick
brew install the-unarchiver
brew install orbstack
brew install skim
brew install slack
brew install stoplight-studio
brew install visual-studio-code
brew install watchman
brew install warp
brew install xquartz

brew tap yakitrak/yakitrak
brew install yakitrak/yakitrak/obs
brew install obsidian

# brew cask install objektiv

brew install selenium-server-standalone
brew install chromedriver
brew install geckodriver

brew install ollama

mas install 539883307 # LINE (5.15.0)
mas install 497799835 # Xcode (10.2)

brew cleanup

