alias cod='code --diff'
alias cor='code --reuse-window $(git rev-parse --show-toplevel)'
alias con='code --new-window $(git rev-parse --show-toplevel)'
alias coR='code --reuse-window'
alias coN='code --new-window'

if [ "$TERM_PROGRAM" = "vscode" ]; then
  unalias rm 2>/dev/null
  unalias mv 2>/dev/null
fi
