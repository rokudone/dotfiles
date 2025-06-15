if [ `uname` = "Darwin" ]; then
  #mac用のコード
  if [ -f ~/.bash_profile.darwin ]; then
  . ~/.bash_profile.darwin
  . ~/.bashrc
  fi
elif [ `uname` = "Linux" ]; then
  #Linux用のコード
  # Call common bashrc
  if [ -f ~/.bashrc ]; then
  . ~/.bashrc
  fi
fi
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
if [ -e /Users/filriya/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/filriya/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

. "$HOME/.cargo/env"
