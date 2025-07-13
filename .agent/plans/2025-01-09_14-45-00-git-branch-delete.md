# Git Branch Delete Command Implementation Plan

## 概要
git.zshにローカルブランチとリモートブランチを同時に削除するコマンドを追加する

## 実装内容

### 1. 新しい関数の追加
- 関数名: `git-branch-delete-all` (gbda)
- 機能: ローカルブランチとリモートブランチを同時に削除
- エイリアス: `gbda`

### 2. 実装詳細
```zsh
function git-branch-delete-all() {
    local branch_name="$1"
    
    # 引数チェック
    if [[ -z "$branch_name" ]]; then
        echo "Usage: gbda <branch-name>"
        return 1
    fi
    
    # 現在のブランチを削除しようとしているかチェック
    local current_branch="$(git rev-parse --abbrev-ref HEAD)"
    if [[ "$branch_name" == "$current_branch" ]]; then
        echo "Error: Cannot delete the currently checked out branch '$branch_name'"
        return 1
    fi
    
    # ローカルブランチを削除
    echo "Deleting local branch: $branch_name"
    git branch -D "$branch_name"
    
    # リモートブランチを削除
    echo "Deleting remote branch: origin/$branch_name"
    git push origin --delete "$branch_name"
}

# エイリアスの追加
alias gbda='git-branch-delete-all'
```

### 3. 補完機能の追加
```zsh
_git_branch_delete_all() {
    local -a branches
    branches=($(git branch --format='%(refname:short)' 2>/dev/null | grep -v "^$(git rev-parse --abbrev-ref HEAD)$"))
    _describe 'branches' branches
}

compdef _git_branch_delete_all git-branch-delete-all
```

## テスト方法
1. テスト用ブランチを作成
2. gbda コマンドでブランチを削除
3. ローカルとリモートの両方から削除されることを確認

## 追加場所
- git.zshファイルの20-32行目のBranch (b)セクションに追加