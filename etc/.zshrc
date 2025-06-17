#!/bin/zsh
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
export LC_CTYPE=ja_JP.UTF-8

autoload -Uz compinit
compinit

if [ ! -e "$HOME"/.tmux.bundle/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux.bundle/tpm"
fi

# zinit
if [ ! -e "$HOME"/.local/share/zinit/zinit.git/zinit.zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
fi

source "${ZDOTDIR:-$HOME}/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit ice pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure
zinit light mnowotnik/extra-fzf-completions
zinit light agkozak/zsh-z
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search

zinit snippet PZT::modules/command-not-found/init.zsh
zinit snippet PZT::modules/completion/init.zsh
zinit snippet PZT::modules/directory/init.zsh
# zinit snippet PZT::modules/docker/init.zsh
zinit snippet PZT::modules/editor/init.zsh
zinit snippet PZT::modules/helper/init.zsh
zinit snippet PZT::modules/history/init.zsh
zinit snippet PZT::modules/homebrew/init.zsh
zinit snippet PZT::modules/osx/init.zsh
zinit snippet PZT::modules/spectrum/init.zsh
zinit snippet PZT::modules/syntax-highlighting/init.zsh
zinit snippet PZT::modules/terminal/init.zsh
zinit snippet PZT::modules/utility/init.zsh


PROMPT="%F{242}[%*]%f "$PROMPT

# Source OS-specific settings
case $OSTYPE in
  darwin*)
    if [ -f "${ZDOTDIR:-$HOME}/.zsh.d/.zshrc.darwin" ]; then
      source "${ZDOTDIR:-$HOME}/.zsh.d/.zshrc.darwin"
    fi
    ;;
  linux*)
    # Linux用のコード
    if [ -f "${ZDOTDIR:-$HOME}/.zsh.d/.zshrc.linux" ]; then
      source "${ZDOTDIR:-$HOME}/.zsh.d/.zshrc.linux"
    fi
    ;;
esac

# Source *.zsh
ZSHHOME="${HOME}/.zsh.d"

if [ -d $ZSHHOME -a -r $ZSHHOME -a -x $ZSHHOME ]; then
  for i in $ZSHHOME/*; do
    [[ ${i##*/} = *.zsh ]] &&
      [ \( -f $i -o -h $i \) -a -r $i ] && . $i
  done
fi

unset GREP_OPTIONS

unsetopt FLOW_CONTROL
stty stop undef
stty start undef

# 全ての割り込み信号を無効化
# stty intr undef  # Ctrl+C
# stty quit undef  # Ctrl+\
# stty susp undef  # Ctrl+Z
# stty stop undef  # Ctrl+S
# stty start undef # Ctrl+Q


# fzf
if [ -f ~/.zsh.d/fzf.zsh ]; then
  source ~/.zsh.d/fzf.zsh
fi
EXTRA_FZF_COMPLETIONS_FZF_PREFIX=,
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
#   dark
# else
#   light
# fi

# gruvbox
# echo " \
#   --color=light \
#   --color=fg:#3c3836,bg:#fbf1c7,hl:#928374,fg+:#3c3836,bg+:#ebdbb2,hl+:#9d0006 \
#   --color=info:#427b58,prompt:#9d0006,spinner:#9d0006,pointer:#9d0006,marker:#9d0006,header:#928374"

# \ { 'fg':      ['fg', 'Normal'],
#   \ 'bg':      ['bg', 'Normal'],
#   \ 'hl':      ['fg', 'Comment'],
#   \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
#   \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
#   \ 'hl+':     ['fg', 'Statement'],
#   \ 'info':    ['fg', 'PreProc'],
#   \ 'border':  ['fg', 'Ignore'],
#   \ 'prompt':  ['fg', 'Conditional'],
#   \ 'pointer': ['fg', 'Exception'],
#   \ 'marker':  ['fg', 'Keyword'],
#   \ 'spinner': ['fg', 'Label'],
#   \ 'header':  ['fg', 'Comment'] }

# alias
alias gosh='rlwrap gosh'
alias phptags='ctags --tag-relative --recurse --sort=yes --exclude=*.js'
alias -g F='| fzf'
alias -g G='| grep'
alias -g V='| grep -v'
alias -g N='&& notify completed || notify error'
alias -g P='| pbcopy'
alias -g SJIS='| nkf'
alias serve="python3 -m http.server"
alias cu='env -u TMUX cursor'
alias -g C="| xargs cursor"

function rc() {
  rg --no-heading --line-number "$1" | fzf | awk -F: '{print $1":"$2}' | xargs cursor -g
}

function fc() {
  fzf | xargs cursor
}

# 反cd
# alias cd='nocd'
symbols() {
  echo "%^&*()-=_+[]{};:'\".,/\\¥<>?"
}
# haskell stack
if type "stack" > /dev/null 2>&1; then
  path=(${ZDOTDIR:-$HOME}/.local/bin $path)
  alias ghci='rlwrap stack ghci'
  alias ghc='stack ghc --'
  alias runghc='stack runghc --'
fi


# exa - alternative ls
if type exa > /dev/null; then
  # "--git" + "-l" + broken symlink + NFS の組み合わせで落ちる
  # alias l="exa --git --group-directories-first"
  # alias ll="exa -l --git --time-style=iso --group-directories-first"
  # alias la="exa -la --git --time-style=iso --group-directories-first"
  # alias lt="exa -lT --git --time-style=iso --group-directories-first -L"
  # alias lT="exa -lT --git --time-style=iso --group-directories-first"

  # alias l="exa --group-directories-first"
  # alias ll="exa -l --time-style=iso --group-directories-first"
  # alias la="exa -la --time-style=iso --group-directories-first"
  # alias lt="exa -lT --time-style=iso --group-directories-first -L"
  # alias lT="exa -lT --time-style=iso --group-directories-first"
fi

if type lsd > /dev/null; then
  alias ls='lsd'
  alias ll='lsd -l'
  alias la='lsd -la'
  alias lt='lsd --tree'
fi

if type tldr > /dev/null; then
  alias man="tldr"
fi

# if type cat > /dev/null; then
#   alias cat="bat"
# fi

if [[ -f ~/dircolors/dircolors.solarized && -x `which dircolors` ]]; then
  eval `dircolors ${HOME}/dircolors/dircolors.solarized`
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
fi

# source "$HOME"/.zsh.bundle/enhancd/init.sh


function cdup() {
  zle kill-whole-line
  cd ..
  # zle reset-prompt
  zle accept-line
}
zle -N cdup
bindkey '^^' cdup

bindkey -r '^q'
bindkey '^q' beginning-of-line

#tmux
# autoload -Uz til
autoload -Uz bk

setopt nonomatch
setopt dotglob

# hub member
function hub-member {
  hub api /orgs/$1/members | perl -pe "s/\,/,\n/g"| grep login | perl -pe 's/.*"login":"(.*)".*/\1/g'
}

# default editor
EDITOR=`which nvim`
export VIMCONFIG="$HOME/.config/nvim"

function starteditor() {
  exec < /dev/tty
  ${EDITOR}
  zle reset-prompt
}
zle -N starteditor
bindkey '^]' starteditor


export HISTSIZE=1000000 # メモリに保存される履歴の件数。(保存数だけ履歴を検索できる)
export SAVEHIST=1000000 # ファイルに何件保存するか
setopt EXTENDED_HISTORY # 実行時間とかも保存する
setopt SHARE_HISTORY # 別のターミナルでも履歴を参照できるようにする
setopt HIST_VERIFY # ヒストリを呼び出してから実行する間に一旦編集できる状態になる
setopt HIST_SAVE_NO_DUPS # historyコマンドは残さない
setopt HIST_EXPIRE_DUPS_FIRST # 古い履歴を削除する必要がある場合、まず重複しているものから削除
setopt HIST_EXPAND # 補完時にヒストリを自動的に展開する
setopt INC_APPEND_HISTORY # 履歴をインクリメンタルに追加
setopt HIST_IGNORE_DUPS # 前と重複する行は記録しない
setopt HIST_IGNORE_ALL_DUPS # 履歴中の重複行をファイル記録前に無くす
setopt HIST_IGNORE_SPACE # 行頭がスペースのコマンドは記録しない
setopt HIST_FIND_NO_DUPS # 履歴検索中、(連続してなくとも)重複を飛ばす
setopt HIST_REDUCE_BLANKS # 余分な空白は詰めて記録
setopt HIST_NO_STORE # histroyコマンドは記録しない


# clang
alias clang-omp="$HOMEBREW_PREFIX/opt/llvm/bin/clang -fopenmp -L$HOMEBREW_PREFIX/opt/llvm/lib -Wl,-rpath,$HOMEBREW_PREFIX/opt/llvm/lib"
alias clang-omp++="$HOMEBREW_PREFIX/opt/llvm/bin/clang++ -fopenmp -L$HOMEBREW_PREFIX/opt/llvm/lib -Wl,-rpath,$HOMEBREW_PREFIX/opt/llvm/lib"

# rg ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# composer
path=(${ZDOTDIR:-$HOME}/.config/composer/vendor/bin $path)

# ruby
path=(/usr/local/lib/ruby/gems/2.6.0 $path)

# yarn
path=($(yarn global bin) $path)

# snap
path=(/snap/bin $path)

# Windows
export WINDOWSHOME="/mnt/c/Users/${USER}"

if [ "$(uname)" == 'Linux' ]; then
  if [[ "$(uname -r)" == *microsoft* ]]; then
    export PATH=$PATH:/mnt/c/Windows/System32
    export PATH=$PATH:/mnt/c/WINDOWS/
    export PATH="$PATH:$WINDOWSHOME/AppData/Local/Programs/Microsoft VS Code/bin"
  fi
fi

alias -g W='$WINDOWSHOME'

# android
export ANDROID_HOME=$HOME/Android/SDK
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# flutter
# export FLUTTER_HOME=$HOME/.asdf/installs/flutter/3.13.6-stable
export FLUTTER_HOME=$HOME/flutter
# path=($HOME/.local/share/flutter/bin $path)
path=($HOME/flutter/bin $path)

# export CHROME_EXECUTABLE="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"

if [[ -d "$HOMEBREW_PREFIX/opt/dart/libexec" ]]; then
  export DART_SDK="$HOMEBREW_PREFIX/opt/dart/libexec"
  PATH="$DART_SDK:$PATH"
fi

# SSH/SCP/RSYNC
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order files hosts-host all-files users hosts-domain hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order hosts-host users hosts-domain users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

zstyle ':completion:*:hosts' hosts

if [ "$SSH_TTY" == "" ]; then
  cache_hosts_file="${ZDOTDIR:-$HOME}/.cache_hosts"
  print_cache_hosts () {
    if [ ! -f $cache_hosts_file ]; then
      update_cache_hosts
    fi
    print $cache_hosts_file
  }

update_cache_hosts () {
  find ~/.ssh/conf.d -type f | xargs grep -ih "host " |cut -d ' ' -f 2|sort >|  $cache_hosts_file
}

update_cache_hosts
_cache_hosts=(print_cache_hosts )
fi


export GOPATH=$HOME/go
path=(${GOPATH}/bin $path)

export XDG_CONFIG_HOME="$HOME/.config"

# docker
alias fig='docker-compose'

if [ -e ~/.zsh.bundle/completion ]; then
  fpath=(~/.zsh.bundle/completion $fpath)
fi

# vim
alias vim='nvim'

# # java
export JAVA_HOME=$(/usr/libexec/java_home -v 23)
export PATH=$JAVA_HOME/bin:$PATH

# rust
export RUST_BACKTRACE=1

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

# if [[ ! -n $TMUX && -z $SSH_TTY ]]; then
#   tm $(tmux list-sessions | grep attached | perl -pe "s/^([^:]*):.*/\1/g")
# fi

# orbstack
# [[ -f ~/.orbstack/shell/init.zsh ]] && . ~/.orbstack/shell/init.zsh 2>/dev/null || true
path=(${ZDOTDIR:-$HOME}/.orbstack/bin $path)



if [ -e "${ZDOTDIR:-$HOME}/.zshrc.local" ]; then
  source "${ZDOTDIR:-$HOME}/.zshrc.local"
fi

function zgit()
{
  echo $(cat ~/.zsh.d/git.zsh \
    | grep --color=never '^alias' \
    | grep -v 'alias -g'\
    | perl -pe 's/alias ([^=]+)=(.*)/\1\t\2/' \
    | fzf \
    | perl -pe "s/.*['\"]([a-zA-Z \-]+)['\"].*/\1/g"
  )
}
# alias -g Z=zgit
#
function zdocker()
{
  echo $(cat ~/.zsh.d/docker.zsh \
    | grep --color=never '^alias' \
    | grep -v 'alias -g'\
    | perl -pe 's/alias ([^=]+)=(.*)/\1\t\2/' \
    | fzf \
    | perl -pe "s/.*['\"]([a-zA-Z \-]+)['\"].*/\1/g"
  )
}

function r() {
    local FILES=$(rg "$@" | fzf | awk -F ':' '{print $1}')
    local COMMAND=$(echo $FILES | xargs -I XXX echo "code XXX" | tr '\n' ' ' | sed 's/ $//')

    if [[ -n $COMMAND ]]; then
        eval $COMMAND
    fi
}

function rf() {
    local FILES=$(rg --files | fzf | awk -F ':' '{print $1}')
    local COMMAND=$(echo $FILES | xargs -I XXX echo "code XXX" | tr '\n' ' ' | sed 's/ $//')

    if [[ -n $COMMAND ]]; then
        eval $COMMAND
    fi
}

function casy_table() {
  # 使用法:
  #   casy_table <テーブル名>          # 1つのテーブル定義を抽出
  #   casy_table <テーブル名1> <テーブル名2> ... # 複数のテーブル定義を抽出
  #   casy_table                      # fzf を使用して対話的にテーブルを選択 (引数なし)
  #
  # スキーマファイルのパスは以下に固定されています:
  #   $HOME/projects/casy-ruby/db/schema.rb
  #
  # 依存関係:
  #   この関数は fzf コマンドに依存しています。
  #   fzf がインストールされていない場合は、動作しません。

  local file_path="$HOME/projects/casy-ruby/db/schema.rb"
  local table_name="$1"

  if [ -z "$table_name" ]; then
    table_name=$(grep '^  create_table' "$file_path" | awk '{print $2}' | sed 's/[,"]//g' | fzf)
    if [ -z "$table_name" ]; then
      return 0
    fi
  fi

  if [ $# -gt 1 ]; then
    for table_name in "$@"; do
      sed -n "/^  create_table \"$table_name\"/,/^  end\$/p" "$file_path"
    done
  else
    sed -n "/^  create_table \"$table_name\"/,/^  end\$/p" "$file_path"
  fi
}

fpath=(${ZDOTDIR:-$HOME}/.zsh.d/**/functions $fpath)
path=(${ZDOTDIR:-$HOME}/bin $path)

typeset -U PATH # 重複削除

# alias -g Z=zgit
export LESSCHARSET=utf-8

# VSCode以外の環境でのみ適用する設定
if [[ $TERM_PROGRAM != "vscode" ]]; then
  if [ -e "${ZDOTDIR:-$HOME}/.ssh/id_rsa" ]; then
    keychain $HOME/.ssh/id_rsa
  fi
  if [ -e "${ZDOTDIR:-$HOME}/.ssh/id_ed25519" ]; then
    keychain $HOME/.ssh/id_ed25519
  fi
  source $HOME/.keychain/`hostname`-sh
else
  alias rm="rm"
fi

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

if [ "$(uname)" == 'Linux' ]; then
  if [[ "$(uname -r)" == *microsoft* ]]; then
    source $HOME/.zshrc.wsl
  fi
fi

alias ml='aws sso login --profile'
alias mlp='aws sso login --profile production'
alias mls='aws sso login --profile staging'

function me() {
  local PROFILE=$1
  shift
  local SERVICE=$1
  shift
  local COMMAND="$@"
  local TASK_ARN=$(aws --profile $PROFILE ecs list-tasks --cluster DX --service-name $SERVICE | jq -r .taskArns[0] | perl -pe "s/.*\/(.*)/\1/g")
  echo $TASK_ARN
  aws --profile $PROFILE ecs execute-command --region ap-northeast-1 --cluster DX --container "rails-$SERVICE" --interactive --task $TASK_ARN --command "$COMMAND"
}

alias mep="me production"
alias mepb="me production batch"
alias mepa="me production api"
alias mepw="me production worker"
alias mes="me staging"
alias mesb="me staging batch"
alias mesa="me staging api"
alias mesw="me staging worker"

# if [ -z $TMUX ]; then
#   tmux a -t $(basename ~ | perl -pe 's/\\./_/g') || tmux new -s $(basename ~ | perl -pe 's/\\./_/g')
# fi

for i in {1..9}; do
  alias $i="pushd +$i"
done

# Created by `pipx` on 2024-06-17 17:35:34
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
export PATH="$HOME/.orbstack/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"
export PATH="/Library/TeX/texbin:$PATH"

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

alias c="claude"
alias cr="claude --resume"

path=(~/some/directory/claude-code-config/bin $path)
source ~/.zshrc.claude

### End of Zinit's installer chunk

# zsh プロファイリング
# if (which zprof > /dev/null 2>&1) ;then
#   zprof
# fi
