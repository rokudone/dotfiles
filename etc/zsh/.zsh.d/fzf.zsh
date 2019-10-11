# Auto-completion
# ---------------
if [ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh" ]; then
  source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null
fi

# Key bindings
# ------------
#
function fzf-z-widget
{
  local res=$(z | sort -rn | cut -c 12- | fzf)
  if [ -n "$res" ]; then
    BUFFER+="cd $res"
    zle accept-line
  fi
  zle clear-screen
}
zle -N fzf-z-widget

if [ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh" ]; then
  source "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
  bindkey -r '^T'
  bindkey -r '\ec' 
  bindkey '^S' 'fzf-z-widget'
  bindkey '^Z' 'fzf-file-widget'
fi

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --no-ignore'
export FZF_DEFAULT_OPTS='-m --height 40% --no-sort --bind ctrl-q:beginning-of-line,ctrl-o:toggle-up,ctrl-i:toggle-down,ctrl-r:toggle-all'

