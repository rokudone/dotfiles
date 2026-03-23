# ============ jj aliases — j + {r|b|w|o|m|g} + subcmd head ============

# r: Revision（履歴編集・生成）

# w: Working/View (ファイル・作業)
alias jw='jj status'           # status
alias jwn='jj new'
alias jwe='jj edit'
alias jwc='jj commit'
alias jwd='jj diff'
alias jwr='jj restore'
alias jws='jj show'

# r: Revision (コミット)
alias jra='jj amend'
alias jrd='jj describe'
alias jrp='jj split'
alias jrq='jj squash'
alias jrqi='jj squash --into'
alias jrx='jj abandon'         # ← x (削除のイメージ)
alias jrv='jj revert'

# t: Tree (ツリー構造)
alias jt='jj log'
alias jtl='jj log --stat'
alias jtL='jj log --patch'
alias jtr='jj rebase'
alias jtm='jj merge'
alias jtt='jj transplant'
alias jtd='jj duplicate'
alias jtu='jj undo'

# b: Bookmark
alias jbl='jj bookmark list'         # list
alias jbc='jj bookmark create'       # create
alias jbd='jj bookmark delete'       # delete
alias jbm='jj bookmark move --allow-backwards --to @'  # move（@へ付け替え）
alias jbM='jj bookmark move --allow-backwards'         # move（任意の指定）
alias jbr='jj bookmark rename'       # rename
alias jbt='jj bookmark track'        # track（追従設定）

# o: Operation / Safety（操作履歴）
alias jol='jj op log'              # op log（log の頭文字 'l'）
alias joo='jj obslog'              # obslog（頭文字 'o'）

# m: Meta（設定・タグ）
alias jmc='jj config'              # config
alias jmt='jj tag'                 # tag

# g: Git bridge（jj層も同期／※プレフィックスは jg* に修正）
alias jgf='jj git fetch'           # fetch   ←（ggfではなく jgf に修正）
alias jgP='jj git pull'            # pull
alias jgp='jj git push'            # push  ※ pull と頭文字衝突のため 'P'
alias jgr='jj git remotes'         # remotes
alias jgi='jj git import'          # import
alias jge='jj git export'          # export

jj_sync_all() {
  jj git fetch --prune
  for bm in $(jj bookmark list | awk '{print $1}'); do
    echo "Rebasing $bm..."
    jj rebase -b "$bm" -d "remotes/origin/$bm" || echo "⚠️  failed: $bm"
  done
}
alias jgs='jj_sync_all'
