# Auto-completion
# ---------------
if [ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh" ]; then
  source "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh" 2> /dev/null
fi

# Key bindings
# ------------
#
function fzf-z-widget
{
  local res=$(z | sort -rn | cut -c 12- | fzf)
  if [ -n "$res" ]; then
    BUFFER+="cd \"$res\""
    zle accept-line
  fi
  zle clear-screen
}
zle -N fzf-z-widget

function fzf-open-widget
{
  local res=$(fd -d 3 --type d| sort -rn | fzf)
  if [ -n "$res" ]; then
    BUFFER+="cd \"$res\""
    zle accept-line
  fi
  zle clear-screen
}
zle -N fzf-open-widget

if [ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh" ]; then
  source "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
  bindkey -r '\ec' 
  bindkey -r '^t'
  bindkey '^s' fzf-z-widget
  bindkey '^g' fzf-open-widget
  # bindkey '^Z' 'fzf-file-widget'
fi

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --no-ignore'
if [[ $FIND_IT_FASTER_ACTIVE -eq 1 ]]; then
  export FZF_DEFAULT_OPTS="
    --height 100%
    --reverse
  "
  # export FZF_DEFAULT_OPTS="
  #   -m
  #   --height 100%
  #   --reverse
  #   --bind ctrl-q:beginning-of-line,ctrl-o:toggle-up,ctrl-i:toggle-down,ctrl-r:toggle-all,ctrl-g:toggle-sort,?:preview:'bat --style=numbers --line-range :500 {}'
  # "
else
  export FZF_DEFAULT_OPTS="
    -m
    --height 30%
    --reverse
    --bind ctrl-q:beginning-of-line,ctrl-o:toggle-up,ctrl-i:toggle-down,ctrl-r:toggle-all,ctrl-g:toggle-sort
  "
fi
export FZF_COMPLETION_TRIGGER=','
