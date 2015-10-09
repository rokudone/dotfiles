#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# LANG="C.UTF-8"
LC_CTYPE="en_US.UTF-8"
LC_ALL="en_US.UTF-8"

ZSHINITROOT="$HOME/dotfiles"

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# load zshrc.local
if [ -f ${HOME}/.zshrc.local ]; then
  . ${HOME}/.zshrc.local
fi

# linuxとosx、個別にロードしたい設定
if [ `uname` = "Darwin" ]; then
  # mac用のコード
  if [ -f "$ZSHINITROOT/osx.zsh" ]; then
    source "$ZSHINITROOT/osx.zsh"
  fi
elif [ `uname` = "Linux" ]; then
  # Linux用のコード
  if [ -f "$ZSHINITROOT/linux.zsh" ]; then
    source "$ZSHINITROOT/linux.zsh"
  fi
fi

eval $(dircolors ${HOME}/.dircolors )

# rbenv
export PATH="${HOME}/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# wp-completion
autoload bashcompinit
bashcompinit
source $ZSHINITROOT/wp-completion.bash

agent="$HOME/tmp/ssh-agent-$USER"
if [ -S "$SSH_AUTH_SOCK" ]; then
  case $SSH_AUTH_SOCK in
  /tmp/*/agent.[0-9]*)
    ln -snf "$SSH_AUTH_SOCK" $agent && export SSH_AUTH_SOCK=$agent
  esac
elif [ -S $agent ]; then
  export SSH_AUTH_SOCK=$agent
else
  echo "no ssh-agent"
fi

# alias
alias ls="ls --color=auto"
alias cl="clear"


# screen
alias sr=myScreenLaunch
alias sl='screen -list'
function myScreenLaunch ()
{
  if [ $# -eq 1 ]; then
    screen -x -RR -U -S $1
  else
    screen -x -RR -U -S ${USER}
  fi
}

# npm
NPM_PACKAGES="${HOME}/.npm-packages"

NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"

PATH="$NPM_PACKAGES/bin:$PATH"

##nodebrew
##PATH=$HOME/.nodebrew/current/bin:$PATH
#
## Unset manpath so we can inherit from /etc/manpath via the `manpath`
## command
#unset MANPATH # delete if you already modified MANPATH elsewhere in your config
#MANPATH="$NPM_PACKAGES/share/man:$(manpath)"

# percol
function exists { which $1 &> /dev/null }

if exists percol; then
  function percol_select_history()
  {
    local tac
    exists gtac && tac="gtac" || { exists tac && tac="tac" || { tac="tail -r" } }
    BUFFER=$(fc -l -n 1 | eval $tac | percol --query "$LBUFFER")
    CURSOR=$#BUFFER         # move cursor
    zle -R -c               # refresh
  }

  zle -N percol_select_history
  bindkey '^R' percol_select_history
fi

# prompt color
function changecolor()
{
  local color=$1
  PROMPT=`echo $PROMPT|awk -v color=$color '{gsub(/135/, color); print $0}'`
}

if [ ${PROMPTCOLORUSER} ]; then
  changecolor $PROMPTCOLORUSER
fi

function colorcode()
{
  for c in {000..015}; do echo -n "\e[38;5;${c}m $c" ; [ $(($c%6)) -eq 5 ] && echo;done;echo
  echo
  for c in {016..255}; do echo -n "\e[38;5;${c}m $c" ; [ $(($((c-16))%6)) -eq 5 ] && echo;done;echo
}

# aws completion
source /usr/local/bin/aws_zsh_completer.sh

# default editor
EDITOR=`which vim`

export PATH=${HOME}/local/bin:~/bin/:"$PATH"
stty -ixon

