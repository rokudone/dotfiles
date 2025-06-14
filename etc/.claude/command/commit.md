# Git操作（レビュー後コミット）

セッション変更ファイルをレビューしてコミット：

**手順：**
1. `git reset` → セッション限定ファイル特定 → `git add`
2. 変更内容をエディタで表示：
   ```bash
   git diff --cached {files} > /tmp/diff_${UNIQUE_ID}.txt
   ${EDITOR:-vim} -R /tmp/diff_${UNIQUE_ID}.txt
   ```
3. 「コミットしますか？(y/n)」確認
4. y選択時のみコミット実行

**注意：**
- `git diff --name-only`使用禁止（他プロセス混入防止）
- セッション記録ベースでファイル特定
- 他プロセス変更中ファイル除外

**コミット形式：**
```
[Session-{ID}] 作業要約
- file1: 変更理由
- file2: 変更理由
```

