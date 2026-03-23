# ----- cmux helpers (v2) -----

cmw() {
  cmux new-workspace --command "cd \"$PWD\" && $SHELL"
  wid=$(cmux list-workspaces | tail -n 1)
  cmux select-workspace --workspace "$wid"
  cmux rename-workspace "$(basename "$PWD")"
}

cms() {
  wid=$(cmux list-workspaces | fzf)
  cmux select-workspace --workspace "$wid"
}

alias cm='cmux'
alias cml='cmux list-workspaces'
alias cmx='cmux close-workspace --workspace'
alias cmc='cmux current-workspace'
alias cmn='cmux notify'

cmr() {
  wid=$(cmux list-workspaces | fzf)
  [[ -z "$wid" ]] && return

  cmd="$*"
  [[ -z "$cmd" ]] && read -r -p "command> " cmd

  cmux send --workspace "$wid" "$cmd"
  cmux send-key --workspace "$wid" Enter
}
# --------------------------------
