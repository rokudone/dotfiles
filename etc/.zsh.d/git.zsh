#
# Defines Git aliases.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# git alias
zstyle -s ':prezto:module:git:log:medium' format '_git_log_medium_format' \
  || _git_log_medium_format='%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'
zstyle -s ':prezto:module:git:log:oneline' format '_git_log_oneline_format' \
  || _git_log_oneline_format='%Cred%h%Creset - %s %Cgreen(%ci) %C(bold blue)<%an>%Creset %C(yellow)%d%Creset'
# Git
alias g='git'

# # Branch (b)
alias gb='git branch --verbose'
alias gba='git branch --all --verbose'
alias gbv='git branch -r --track --sort="authordate" --sort="authorname" --format="%(refname:lstrip=2)  %(authordate) %(authorname)" | column -t'
alias gbx='git branch --delete'
alias gbX='git branch --delete --force'
alias gbm='git branch --move'
alias gbM='git branch --move --force'
# alias gbs='git show-branch'
# alias gbS='git show-branch --all'
alias gbs='git switch'
alias gbS='git_multi_switch'
alias gbsd='git switch --detach'
alias gbc='git switch --create'
# alias gbC='hub sync && git switch --track'
# alias gbc='git checkout -b'
# alias gbr="git branch --remote"

# Branch delete all - ローカルとリモートブランチを同時に削除
function git-branch-delete-all() {
    # 引数チェック
    if [[ $# -eq 0 ]]; then
        echo "Usage: gbxa <branch-name> [<branch-name>...]"
        echo "  Delete both local and remote branches"
        return 1
    fi
    
    # 現在のブランチを取得
    local current_branch="$(git rev-parse --abbrev-ref HEAD)"
    local failed=false
    
    # 各ブランチに対して処理
    for branch_name in "$@"; do
        echo "=== Processing branch: $branch_name ==="
        
        # 現在のブランチを削除しようとしているかチェック
        if [[ "$branch_name" == "$current_branch" ]]; then
            echo "Error: Cannot delete the currently checked out branch '$branch_name'"
            failed=true
            continue
        fi
        
        # ローカルブランチの存在確認
        if ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
            echo "Warning: Local branch '$branch_name' does not exist"
        else
            # ローカルブランチを削除
            echo "Deleting local branch: $branch_name"
            if git branch -D "$branch_name"; then
                echo "✓ Local branch deleted"
            else
                echo "✗ Failed to delete local branch"
                failed=true
            fi
        fi
        
        # リモートブランチの存在確認
        if ! git ls-remote --exit-code --heads origin "$branch_name" > /dev/null 2>&1; then
            echo "Warning: Remote branch 'origin/$branch_name' does not exist"
        else
            # リモートブランチを削除
            echo "Deleting remote branch: origin/$branch_name"
            if git push origin --delete "$branch_name"; then
                echo "✓ Remote branch deleted"
            else
                echo "✗ Failed to delete remote branch"
                failed=true
            fi
        fi
        
        echo  # 空行で区切る
    done
    
    # 失敗があった場合は非ゼロを返す
    if [[ "$failed" == true ]]; then
        return 1
    fi
}

# zsh補完機能
_git_branch_delete_all() {
    local -a branches
    # 現在のブランチを除外してブランチリストを取得
    branches=($(git branch --format='%(refname:short)' 2>/dev/null | grep -v "^$(git rev-parse --abbrev-ref HEAD 2>/dev/null)$"))
    _describe 'branches' branches
}

compdef _git_branch_delete_all git-branch-delete-all

alias gbxa='git-branch-delete-all'

git_multi_switch() {
  # 使用方法をチェック
  if [ $# -lt 2 ]; then
    echo "使用方法: git_multi_switch <ブランチ名> <プロジェクト1> [<プロジェクト2> ...]"
    return 1
  fi

  # 現在のディレクトリを保存
  local original_dir=$(pwd)

  # プロジェクトのベースディレクトリを設定
  local base_dir="$HOME/projects"

  # 第1引数をブランチ名として取得し、シフト
  local branch="$1"
  shift

  # 残りの引数をプロジェクトとして処理
  for project in "$@"; do
    local dir="$base_dir/$project"
    if [ -d "$dir" ]; then
      echo "プロジェクト $project 処理中..."
      (
        cd "$dir" || return
        if git rev-parse --git-dir > /dev/null 2>&1; then
          # コミットされていない変更をチェック
          if ! git diff-index --quiet HEAD --; then
            echo "コミットされていない変更があります。git now を実行します..."
            git now
          fi

          if git show-ref --verify --quiet "refs/heads/$branch"; then
            git switch "$branch"
            echo "ブランチを $branch に切り替えました"
          else
            echo "ブランチ $branch が存在しません"
          fi
        else
          echo "$project はGitリポジトリではありません"
        fi

        echo "originを同期します"
        hub sync
      )
    else
      echo "プロジェクト $project が見つかりません（パス: $dir）"
    fi
    echo
  done

  # 元のディレクトリに戻る
  cd "$original_dir"
  echo "元のディレクトリ $(pwd) に戻りました"
}

# zsh補完機能
_git_multi_switch() {
  local state

  _arguments \
    '1: :->branch' \
    '*: :->projects'

  case $state in
    branch)
      local branches
      branches=($(git branch --format='%(refname:short)' 2>/dev/null))
      _describe 'branch' branches
      ;;
    projects)
      local projects
      projects=($(ls -d $HOME/projects/* 2>/dev/null | xargs -n 1 basename))
      _describe 'projects' projects
      ;;
  esac
}

compdef _git_multi_switch git_multi_switch

git_multi_branch_create() {
  # 使用方法をチェック
  if [ $# -lt 2 ]; then
    echo "使用方法: git_multi_branch_create <ブランチ名> <プロジェクト1> [<プロジェクト2> ...]"
    return 1
  fi

  # 現在のディレクトリを保存
  local original_dir=$(pwd)

  # プロジェクトのベースディレクトリを設定
  local base_dir="$HOME/projects"

  # 第1引数をブランチ名として取得し、シフト
  local branch="$1"
  shift

  # 残りの引数をプロジェクトとして処理
  for project in "$@"; do
    local dir="$base_dir/$project"
    if [ -d "$dir" ]; then
      echo "プロジェクト $project 処理中..."
      (
        cd "$dir" || return
        if git rev-parse --git-dir > /dev/null 2>&1; then
          # コミットされていない変更をチェック
          if ! git diff-index --quiet HEAD --; then
            echo "コミットされていない変更があります。git now を実行します..."
            git now
          fi

          # originにブランチが存在するかチェック
          if git ls-remote --exit-code --heads origin "$branch" > /dev/null 2>&1; then
            echo "origin に $branch が存在します。tracking branchを作成します..."
            git switch -c "$branch" --track "origin/$branch"
          else
            echo "新しいブランチ $branch を作成します..."
            git switch -c "$branch"
          fi
          echo "ブランチ $branch を作成しました"
        else
          echo "$project はGitリポジトリではありません"
        fi
      )
    else
      echo "プロジェクト $project が見つかりません（パス: $dir）"
    fi
    echo
  done

  # 元のディレクトリに戻る
  cd "$original_dir"
  echo "元のディレクトリ $(pwd) に戻りました"
}

# zsh補完機能
_git_multi_branch_create() {
  local state

  _arguments \
    '1: :->branch' \
    '*: :->projects'

  case $state in
    branch)
      local branches
      branches=($(git branch -r --format='%(refname:lstrip=3)' 2>/dev/null))
      _describe 'remote branches' branches
      ;;
    projects)
      local projects
      projects=($(ls -d $HOME/projects/* 2>/dev/null | xargs -n 1 basename))
      _describe 'projects' projects
      ;;
  esac
}

compdef _git_multi_branch_create git_multi_branch_create

function git_now() {
    if [ $# -eq 0 ]; then
        git commit -m "[from now] $(date '+%Y-%m-%d %H:%M:%S')"
    else
        git commit -m "[from now] $*"
    fi
}

function git_now_reset() {
  local EXEC_CMD=$(cat <<'EOF'
git commit --amend --no-edit --date="$(date -R)" && if git log -1 --pretty=%B | grep -q "^\[from now\] "; then git commit --amend -m "$(git log -1 --pretty=%B | sed "s/^\[from now\] //")"; fi
EOF
  )
  git rebase -i $1 --exec "$EXEC_CMD"
}

# git_now_reset の補完関数
_git_now_reset() {
  local -a branches
  branches=($(git branch --format='%(refname:short)' 2>/dev/null))
  _describe 'branches' branches
}

# git_now_reset に補完を設定
compdef _git_now_reset git_now_reset

# # Commit (c)
# alias gc='git commit --verbose'
# alias gc='git commit -m "[temp] $(date "+%Y/%m/%d %H:%M:%S")"'
alias gn='git_now'
alias gnr='git_now_reset'
alias gcm='git commit --message'
alias gca='git commit --verbose --amend'
# alias gci は別ファイルで
alias gcA='git commit --verbose --amend --reuse-message HEAD'
# alias gco='git checkout'
# alias gcop='git checkout --patch' # -p
alias gcp='git cherry-pick --ff'
alias gcpc='git cherry-pick --continue'
alias gcpa='git cherry-pick --abort'
alias gcpn='git cherry-pick --no-commit'
alias gcr='git reset "HEAD^"' # commitをリセット
alias gcR='git revert'
alias gcs='git show'
alias gcl='git-commit-lost'
alias gcy='git cherry -v --abbrev'
alias gcY='git cherry -v'

# Conflict (C)
alias gC='git checkout'
alias gCb='git checkout -b'
alias gCl='git --no-pager diff --name-only --diff-filter=U'
alias gCa='git add $(gCl)'
alias gCe='git mergetool $(gCl)'
alias gCo='git checkout --ours --'
alias gCO='gCo $(gCl)'
alias gCt='git checkout --theirs --'
alias gCT='gCt $(gCl)'

# Data (d)
alias gd='git ls-files'
alias gdc='git ls-files --cached'
alias gdx='git ls-files --deleted'
alias gdm='git ls-files --modified'
alias gdo='git ls-files --other --exclude-standard'
alias gdk='git ls-files --killed'
alias gdi='git status --porcelain --short --ignored | sed -n "s/^!! //p"'

# Fetch (f)
alias gf='git fetch --prune'
alias gfa='git fetch --all --prune'
alias gfc='git clone --recurse-submodules'
alias gfF='git fetch && git reset --hard origin/$(git branch --show-current)'
alias gfp='git pull'
alias gfr='git pull --rebase'
alias gfR='git-pull-rebase-all'


# Flow (F)
# alias gFi='git flow init'
# alias gFf='git flow feature'
# alias gFb='git flow bugfix'
# alias gFl='git flow release'
# alias gFh='git flow hotfix'
# alias gFs='git flow support'
#
# alias gFfl='git flow feature list'
# alias gFfs='git flow feature start'
# alias gFff='git flow feature finish'
# alias gFfp='git flow feature publish'
# alias gFft='git flow feature track'
# alias gFfd='git flow feature diff'
# alias gFfr='git flow feature rebase'
# alias gFfc='git flow feature checkout'
# alias gFfm='git flow feature pull'
# alias gFfx='git flow feature delete'
#
# alias gFbl='git flow bugfix list'
# alias gFbs='git flow bugfix start'
# alias gFbf='git flow bugfix finish'
# alias gFbp='git flow bugfix publish'
# alias gFbt='git flow bugfix track'
# alias gFbd='git flow bugfix diff'
# alias gFbr='git flow bugfix rebase'
# alias gFbc='git flow bugfix checkout'
# alias gFbm='git flow bugfix pull'
# alias gFbx='git flow bugfix delete'
#
# alias gFll='git flow release list'
# alias gFls='git flow release start'
# alias gFlf='git flow release finish'
# alias gFlt='git flow release track'
# alias gFld='git flow release diff'
# alias gFlr='git flow release rebase'
# alias gFlc='git flow release checkout'
# alias gFlm='git flow release pull'
# alias gFlx='git flow release delete'
#
# alias gFhl='git flow hotfix list'
# alias gFhs='git flow hotfix start'
# alias gFhf='git flow hotfix finish'
# alias gFhp='git flow hotfix publish'
# alias gFht='git flow hotfix track'
# alias gFhd='git flow hotfix diff'
# alias gFhr='git flow hotfix rebase'
# alias gFhc='git flow hotfix checkout'
# alias gFhm='git flow hotfix pull'
# alias gFhx='git flow hotfix delete'
#
# alias gFsl='git flow support list'
# alias gFss='git flow support start'
# alias gFsf='git flow support finish'
# alias gFsp='git flow support publish'
# alias gFst='git flow support track'
# alias gFsd='git flow support diff'
# alias gFsr='git flow support rebase'
# alias gFsc='git flow support checkout'
# alias gFsm='git flow support pull'
# alias gFsx='git flow support delete'

# Grep (g)
alias gg='git grep'
alias gg='git grep --ignore-case'
alias ggl='git grep --files-with-matches'
alias ggL='git grep --files-without-matches'
alias ggv='git grep --invert-match'
alias ggw='git grep --word-regexp'

# Hub (h)
function notify-github-actions-ci-finish() {
  gh run watch -i10 && osascript -e 'display notification "run is done!" with title "Terminal"'
}


alias ghb='hub browse'         # Open a GitHub page in the default browser
alias ghc='hub create'         # Create this repository on GitHub and add GitHub as origin
alias ghd='hub compare'        # Open a compare page on GitHub
# alias ghp='hub pr'             # List or checkout GitHub pull requests
# alias ghP='hub pull-request'   # Open a pull request on GitHub
alias ghs='hub sync'           # Fetch git objects from upstream and update branches
alias ghci='hub ci-status'      # Show the status of GitHub checks for a commit
alias ghD='hub delete'         # Delete a repository on GitHub
alias ghf='hub fork'           # Make a fork of a remote repository on GitHub and add as remote
alias ghi='hub issue'          # List or create GitHub issues
alias ghr='hub release'        # List or create GitHub releases
alias ghn='notify-github-actions-ci-finish'

# alias gha='gh auth'        # Authenticate gh and git with GitHub
# alias ghb='gh browse'      # Open the repository in the browser
# alias ghc='gh codespace'   # Connect to and manage codespaces
# alias ghg='gh gist'        # Manage gists
# alias ghi='gh issue'       # Manage issues
# alias gho'gh org'         # Manage organizations
alias ghp='gh pr'          # Manage pull requests
alias ghv='gh pr view --web'          # Manage pull requests
alias ghV='gh pr view'          # Manage pull requests
# alias ghP='gh project'     # Work with GitHub Projects.
# alias ghr='gh release'     # Manage releases
alias ghR='gh repo'        # Manage repositories

# Index (i)
alias gia='git add'
alias giap='git add --patch'
alias giu='git add --update'
alias gid='git diff --cached'
# alias giD='git diff --cached --word-diff'
alias gii='git update-index --assume-unchanged'
alias giI='git update-index --no-assume-unchanged'
alias gir='git restore --staged'
# alias girp='git reset --patch'
alias gix='git rm -r --cached'
alias giX='git rm -rf --cached'

# Log (l)
# lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>%Creset' --abbrev-commit
# lga = log --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=short
# lgg = log --stat --pretty=format:'%Cblue%h %Cgreen%ar %Cred%an %Creset%s %Cred%d'
# lgs = log --stat --abbrev-commit --date=relative

# alias gl='git log --topo-order --pretty=format:"${_git_log_medium_format}"'
alias gl='git log --topo-order --stat --pretty=format:"${_git_log_medium_format}"'
alias gls='git log --topo-order --stat --patch --full-diff --pretty=format:"${_git_log_medium_format}"'
alias glg='git log --topo-order --graph --pretty=format:"${_git_log_oneline_format}"'
alias gla='git log --topo-order --graph --all --pretty=format:"${_git_log_oneline_format}"'
alias glr='git reflog'

# Merge (m)
alias gm='git merge'
alias gms='git merge --squash'
alias gmC='git merge --no-commit'
alias gmF='git merge --no-ff'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gmt='git mergetool'

# Push (p)
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpF='git push --force'
alias gpa='git push --all'
alias gpA='git push --all && git push --tags'
alias gpt='git push --tags'
alias gpx='git push --delete origin'
alias gpc='git push --set-upstream origin "$(git-branch-current 2> /dev/null)"'
alias gpp='git pull --rebase origin "$(git-branch-current 2> /dev/null)" && git push origin "$(git-branch-current 2> /dev/null)"'
alias gP='git lfs push'

git_rebase_interactive() {
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ $# -eq 0 ]]; then
        # 引数がない場合、現在のブランチのoriginに対してrebase
        local target_branch="origin/$current_branch"
        echo "Rebasing interactively onto $target_branch"
        git rebase -i "$target_branch"
    else
        # 引数がある場合、指定されたブランチに対してrebase
        local target_branch="$1"
        echo "Rebasing interactively onto $target_branch"
        git rebase -i "$target_branch"
    fi
}

# Rebase (r)
alias gr='git rebase'
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias gri='git_rebase_interactive'
alias grs='git rebase --skip'
alias gro='git rebase --onto'
alias grf='git_rebase_root_all'
alias grb='git-align-branch'
alias grB='git-align-branch-all'

# Remote (R)
alias gR='git remote'
alias gRl='git remote --verbose'
alias gRa='git remote add'
alias gRx='git remote rm'
alias gRm='git remote rename'
alias gRu='git remote update'
alias gRp='git remote prune'
alias gRs='git remote show'

# Stash (s)
function git-skip-slack() {
  git stash pop
  git update-index --skip-worktree casy-api/app/services/slack_notify.rb casy-ruby/app/services/slack_notify.rb
  git-skip-status
  echo "スキップ設定完了"
}

# スキップを解除する関数
function git-unskip-slack() {
  git update-index --no-skip-worktree casy-api/app/services/slack_notify.rb casy-ruby/app/services/slack_notify.rb
  git stash -m "skip slack notify"
  git-skip-status
  echo "スキップ解除完了"
}

# スキップ状態を確認する関数
function git-skip-status() {
  git ls-files -v | grep "^S" | grep "slack_notify.rb"
}
alias gss='git stash'
alias gsa='git stash apply'
alias gsx='git stash drop'
alias gsl='git stash list'
alias gsd='git stash show --patch --stat'
alias gsp='git-stash-pop'
alias gsP='git stash pop'
# alias gss='git stash save --include-untracked'
# alias gsS='git stash save --patch --no-keep-index'
# alias gsw='git stash save --include-untracked --keep-index'
alias gsS='git-skip-slack'
alias gsU='git-unskip-slack'
# alias gsS='git-skip-status'

# Submodule (S)
# alias gS='git submodule'
# alias gSa='git submodule add'
# alias gSf='git submodule foreach'
# alias gSi='git submodule init'
# alias gSI='git submodule update --init --recursive'
# alias gSl='git submodule status'
# alias gSm='git-submodule-move'
# alias gSs='git submodule sync'
# alias gSu='git submodule foreach git pull origin master'
# alias gSx='git-submodule-remove'

# Tag (t)
# alias gt='git tag'
# alias gtl='git tag -l'
# alias gts='git tag -s'
# alias gtv='git verify-tag'

# Working Copy (w)
alias gw='(git status --short; echo ""; git stash list; git-skip-status)'
alias gws='git status'
alias gwd='git diff'
# alias gwD='git diff --word-diff'
alias gwr='git restore'
alias gwrp='git restore -p'
alias gwR='git reset'
alias gwrs='git reset --soft'
alias gwrm='git reset --mixed'
alias gwrh='git reset --hard'
# alias gwc='git clean -n'
# alias gwC='git clean -f'
alias gwx='git rm -r'
alias gwX='git rm -rf'

alias gwt='git worktree'
#alias gwta='git worktree add'
alias gwta='create_project_worktree'
alias gwts='switch_project_worktree'
alias gwtl='git worktree list'
alias gwtm='git worktree move'
alias gwtp='git worktree prune'
# alias gwtx='git worktree remove'
alias gwtr='remove_project_worktree'
alias gwtX='git worktree remove --force'
alias gwtu='git worktree unlock'
alias gwtL='git worktree lock'

create_project_worktree() {
    local branch_name="$1"

    # 引数チェック
    if [[ -z "$branch_name" ]]; then
        echo "Usage: gwta <branch-name>"
        return 1
    fi

    # Gitリポジトリ内かチェック
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    # 現在のブランチをworktreeに追加しようとしているかチェック
    local current_branch="$(git rev-parse --abbrev-ref HEAD)"
    if [[ "$branch_name" == "$current_branch" ]]; then
        echo "Error: Branch '$branch_name' is already checked out in the current directory"
        echo "Tip: Specify a different branch name"
        return 1
    fi

    # worktree内にいるかチェック
    local git_common_dir="$(git rev-parse --git-common-dir 2>/dev/null)"
    local git_dir="$(git rev-parse --git-dir 2>/dev/null)"
    local toplevel="$(git rev-parse --show-toplevel)"
    
    # worktree内にいる場合は、メインリポジトリに移動
    if [[ "$git_common_dir" != "$git_dir" ]]; then
        # メインリポジトリのパスを取得
        local main_repo="$(dirname "$git_common_dir")"
        echo "Detected worktree. Switching to main repository: $main_repo"
        cd "$main_repo"
        # toplevelを再取得
        toplevel="$(git rev-parse --show-toplevel)"
    fi

    # .git/worktreeディレクトリを作成
    local worktree_base="$toplevel/.git/wt"
    local worktree_path="$worktree_base/$branch_name"

    # 既存のworktreeがあるかチェック
    if [[ -d "$worktree_path" ]]; then
        echo "Error: Worktree already exists for '$branch_name'"
        echo "Use 'gwts $branch_name' to switch to it"
        return 1
    fi

    # 親ディレクトリを作成（feature/ など）
    mkdir -p "$(dirname "$worktree_path")"

    # プロジェクトルートに移動してworktreeを作成
    local original_dir="$(pwd)"
    cd "$toplevel"

    # ブランチが既に存在するかチェック
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        git worktree add "$worktree_path" "$branch_name"
    else
        git worktree add "$worktree_path" -b "$branch_name"
    fi

    if [[ $? -eq 0 ]]; then
        cd "$worktree_path"
        tm
    else
        cd "$original_dir"
    fi
}

# worktreeへ切り替える関数
switch_project_worktree() {
    local branch_name="$1"

    # 引数チェック
    if [[ -z "$branch_name" ]]; then
        echo "Usage: gwts <branch-name>"
        return 1
    fi

    # Gitリポジトリ内かチェック
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    # .git/worktreeディレクトリ
    local git_dir="$(git rev-parse --show-toplevel)"
    local worktree_base="$git_dir/.git/wt"
    local worktree_path="$worktree_base/$branch_name"

    # worktreeが存在するかチェック
    if [[ -d "$worktree_path" ]]; then
        cd "$worktree_path"
        echo "Switched to worktree: $branch_name"
    else
        echo "Error: Worktree not found for '$branch_name'"
        echo "Use 'gwta $branch_name' to create it"
        return 1
    fi
}

# zsh補完機能
_create_project_worktree() {
    local -a branches
    
    # ローカルブランチ
    branches=($(git branch --format='%(refname:short)' 2>/dev/null))
    
    # リモートブランチ（origin/を除去）
    branches+=($(git branch -r --format='%(refname:lstrip=3)' 2>/dev/null | grep -v HEAD))
    
    # 重複を除去
    branches=($(echo "${branches[@]}" | tr ' ' '\n' | sort -u))
    
    _describe 'branches' branches
}

compdef _create_project_worktree create_project_worktree
compdef _create_project_worktree gwta

# zsh補完機能 for gwts
_switch_project_worktree() {
    local git_dir="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [[ -z "$git_dir" ]]; then
        return
    fi
    
    local -a worktrees
    worktrees=()
    
    # 標準的な.git/worktreesディレクトリから取得
    local worktrees_dir="$git_dir/.git/worktrees"
    if [[ -d "$worktrees_dir" ]]; then
        for worktree_dir in "$worktrees_dir"/*/; do
            if [[ -f "$worktree_dir/HEAD" ]]; then
                # HEADファイルからブランチ名を取得
                local branch=$(cat "$worktree_dir/HEAD" | sed 's|ref: refs/heads/||')
                worktrees+=("$branch")
            fi
        done
    fi
    
    # カスタムworktree (.git/wt) も含める（独自実装用）
    local worktree_base="$git_dir/.git/wt"
    if [[ -d "$worktree_base" ]]; then
        # 実際のworktreeのみを取得（.gitファイルが存在するディレクトリ）
        for dir in "$worktree_base"/*/*(N/) "$worktree_base"/*(N/); do
            if [[ -f "$dir/.git" ]]; then
                local branch="${dir#$worktree_base/}"
                worktrees+=("$branch")
            fi
        done
    fi
    
    # 重複を除去
    worktrees=($(echo "${worktrees[@]}" | tr ' ' '\n' | sort -u))
    
    _describe 'worktrees' worktrees
}

compdef _switch_project_worktree switch_project_worktree
compdef _switch_project_worktree gwts

# プロジェクト内worktree削除関数
remove_project_worktree() {
    local branch_name="$1"

    if [[ -z "$branch_name" ]]; then
        echo "Usage: gwtr <branch-name>"
        return 1
    fi

    local repo_root="$(git rev-parse --show-toplevel)"
    local worktree_base="$repo_root/.git/wt"
    local worktree_path="$worktree_base/$branch_name"

    if [[ -d "$worktree_path" ]]; then
        git worktree remove "$worktree_path"

        # 空になった親ディレクトリを削除
        local parent_dir="$(dirname "$worktree_path")"
        while [[ "$parent_dir" != "$worktree_base" ]]; do
            if rmdir "$parent_dir" 2>/dev/null; then
                echo "Removed empty directory: $parent_dir"
                parent_dir="$(dirname "$parent_dir")"
            else
                # ディレクトリが空でない場合は終了
                break
            fi
        done
    else
        echo "Error: Worktree not found at $worktree_path"
        return 1
    fi
}

# zsh補完機能 for gwtr
_remove_project_worktree() {
    local git_dir="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [[ -z "$git_dir" ]]; then
        return
    fi
    
    local -a worktrees
    worktrees=()
    
    # 標準的な.git/worktreesディレクトリから取得
    local worktrees_dir="$git_dir/.git/worktrees"
    if [[ -d "$worktrees_dir" ]]; then
        for worktree_dir in "$worktrees_dir"/*/; do
            if [[ -f "$worktree_dir/HEAD" ]]; then
                # HEADファイルからブランチ名を取得
                local branch=$(cat "$worktree_dir/HEAD" | sed 's|ref: refs/heads/||')
                worktrees+=("$branch")
            fi
        done
    fi
    
    # カスタムworktree (.git/wt) も含める（独自実装用）
    local worktree_base="$git_dir/.git/wt"
    if [[ -d "$worktree_base" ]]; then
        # 実際のworktreeのみを取得（.gitファイルが存在するディレクトリ）
        for dir in "$worktree_base"/*/*(N/) "$worktree_base"/*(N/); do
            if [[ -f "$dir/.git" ]]; then
                local branch="${dir#$worktree_base/}"
                worktrees+=("$branch")
            fi
        done
    fi
    
    # 重複を除去
    worktrees=($(echo "${worktrees[@]}" | tr ' ' '\n' | sort -u))
    
    _describe 'worktrees' worktrees
}

compdef _remove_project_worktree remove_project_worktree
compdef _remove_project_worktree gwtr

function git-branch-current {

  if ! command git rev-parse 2> /dev/null; then
    print "$0: not a repository: $PWD" >&2
    return 1
  fi

  local ref="$(command git symbolic-ref HEAD 2> /dev/null)"

  if [[ -n "$ref" ]]; then
    print "${ref#refs/heads/}"
    return 0
  else
    return 1
  fi

}

function git-branch-list()
{
  local local=$(git branch|perl -pe "s/[*+] /  /")
  local no_branch=$({
  echo $local;
  echo $local;
  git branch -r | perl -pe "s/origin\///g" | perl -ne "print if ! /->/" ;
  } | sort | uniq -u)
  local remote=$(git branch -r|perl -ne "print if ! /->/")

  local_print=$(echo $local|perl -pe "s/^  /  * /")
  no_branch_print=$(echo $no_branch|perl -pe "s/^  /  + /")
  remote_print=$(echo $remote|perl -pe "s/^  /  = /")

  echo -e "$local_print\n$no_branch_print\n$remote_print"
}

alias -g B='`git-branch-list| fzf --query="* "| perl -pe "s/^  . //g"`'

function git-stash-pop()
{
  stash=$(git stash list|grep "on $(git name-rev --name-only HEAD):"| head -n 1 | perl -lne 'print $1 if /(stash\@\{[0-9]*\})/')
  if [[ $stash != '' ]]; then
    git stash pop $stash
  else
    echo 'no stash on this branch'
  fi
}

function git-pull-rebase-all()
{
  local current=$(git name-rev --name-only HEAD)

  # origin を 初期化
  git fetch --all --prune

  local branches=($(git branch|perl -pe "s/(\* |  )//"))
  for br in ${branches[@]}; do
    # 以下、作業
    git checkout $br

    local remotes=$(git branch -r)

    # originが存在すれば実行
    if echo $remotes | grep -q $br; then

      echo -e "\033[0;36mgit checkout $br && git pull --rebase origin $br\033[0;m"
      git pull --rebase origin $br

      # conflict したら そこで終了
      local conflict_count=$(git diff --name-only --diff-filter=U | wc -l)
      if [ $conflict_count -gt 0 ]; then
        echo -e "\033[0;31mrebase $br failed! \033[0;m"
        git rebase --abort
        return 1
      fi
    fi
  done

  git checkout $current >/dev/null
}

function git-align-branch()
{
  # 引数処理
  if [ $# -eq 0 ]; then
    echo "newbase required"
    return 1
  elif [ $# -eq 1 ]; then
    local newbase=$1
    local branch=$(git name-rev --name-only HEAD) # current_branch
  elif [ $# -eq 2 ]; then
    local newbase=$1
    local branch=$2
  fi

  local current=$(git name-rev --name-only HEAD)

  # rebase --onto
  local branch_point=$(git show-branch --merge-base $newbase $branch) # 分岐点
  echo -e "\033[0;36mgit rebase --onto $newbase $branch_point [$branch]\033[0;m"
  git checkout $branch && git rebase --onto $newbase $branch_point

  # conflict したら そこで終了
  local conflict_count=$(git diff --name-only --diff-filter=U | wc -l)
  if [ $conflict_count -gt 0 ]; then
    echo -e "\033[0;31mrebase $branch failed! \033[0;m"
    git rebase --abort
    return 1
  fi
  git checkout $current
}

function git-align-branch-all()
{
  # 引数処理
  if [ $# -eq 0 ]; then
    echo "newbase required"
    return 1
  elif [ $# -eq 1 ]; then
    local newbase=$1
  fi
  local branches=($(git branch --no-merged |grep -v $newbase))
  for branch in ${branches[@]}; do
    git-align-branch "$newbase" "$branch" || return 1
  done
}
