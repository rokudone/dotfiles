setopt no_global_rcs # avoid loading /etc/profile (not to execute /usr/libexec/path_helper)

# zsh プロファイリング
# zmodload zsh/zprof && zprof

# system-wide environment settings for zsh(1)
# if [ -x /usr/libexec/path_helper ]; then
#   eval `/usr/libexec/path_helper -s`
# fi

export PATH="/usr/local/bin:/usr/local/sbin:$PATH";

# brew
case $OSTYPE in
  darwin*)
    export HOMEBREW_PREFIX=$(brew --prefix);
    ;;
  linux*)
    export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew";
    ;;
esac

# homebrew
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH";
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar";
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew";
export MANPATH="$HOMEBREW_PREFIX/share/man:$MANPATH";
export INFOPATH="$HOMEBREW_PREFIX/share/info:$INFOPATH";

export PATH="$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/gnu-indent/libexec/gnubin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/gnu-which/libexec/gnubin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"



# npm
# .zshrcでpathを解決すると、vimがうまく読み取ってくれない
# https://qiita.com/ktrysmt/items/4d8194b0f82bfa91bcdc

# export PATH="$HOMEBREW_PREFIX/opt/node@10/bin:$PATH"
# eval "$(/opt/homebrew/bin/brew shellenv)"
# path=($(npm config get prefix)/bin $path)
# if [[ -s "$HOME/.cargo/env" ]]; then
#   source "$HOME/.cargo/env"
# fi

if [ -e "$HOME"/.cargo/env ]; then
  . "$HOME/.cargo/env"
fi

if command -v nodenv &> /dev/null; then
  eval "$(nodenv init -)"
fi

# eval `ssh-agent -s`
