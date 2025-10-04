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
