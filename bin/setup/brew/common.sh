#/bin/bash
# Make sure using latest Homebrew
brew update
brew upgrade

brew tap unversal-ctags/universal-ctags

# Packages
brew install bash-completion
brew install boost
brew install cmake
brew install universal-ctags
brew install lua
brew install luajit
brew install git
brew install gibo
brew install mercurial
brew install pcre
brew install python
brew install jq

brew install zsh
# zsh を etc/shells に追加
if ! `grep "$(brew --prefix)/bin/zsh" /etc/shells > /dev/null` ; then
  echo $(brew --prefix)/bin/zsh | sudo tee -a /etc/shells
fi

brew install fd
brew install exa
brew install peco
brew install fzf
brew install z
brew install ghq hub
brew install screen
brew install the_silver_searcher
brew install ripgrep
brew install tig
brew install cmigemo

# nvim
brew install vim
brew install nvim
pip3 install --user pynvim

brew cleanup -s

