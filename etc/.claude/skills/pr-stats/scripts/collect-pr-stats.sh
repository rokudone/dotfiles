#!/bin/zsh
# Usage: zsh collect-pr-stats.sh <author> <from> <to> [repo] [blacklist_prs]
# Example: zsh collect-pr-stats.sh furuya-casy 2025-10-01 2026-04-01 casy-co-ltd/casy-hub "1874,1958"

set -euo pipefail

AUTHOR=$1
FROM=$2
TO=$3
REPO=${4:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}
BLACKLIST=${5:-""}

CACHE_DIR="/tmp/pr-stats"
mkdir -p "$CACHE_DIR"

REPO_SLUG=$(echo "$REPO" | tr '/' '_')
PERIOD_SLUG="${FROM}_${TO}"
PR_CACHE="$CACHE_DIR/${REPO_SLUG}-${AUTHOR}-${PERIOD_SLUG}-prs.json"
FILES_CACHE="$CACHE_DIR/${REPO_SLUG}-${AUTHOR}-files.json"

# === Step 1: PR一覧取得(キャッシュ) ===
if [ ! -f "$PR_CACHE" ]; then
  echo "Fetching PR list for $AUTHOR..." >&2
  gh pr list --state all --author "$AUTHOR" --limit 200 \
    --json number,state,createdAt,mergedAt,title,baseRefName,headRefName,additions \
    --repo "$REPO" | jq --arg from "$FROM" --arg to "$TO" '
    [.[] | select(
      (.state == "OPEN" or .state == "MERGED")
      and (
        (.createdAt >= $from and .createdAt < $to)
        or
        (.mergedAt != null and .mergedAt >= $from and .mergedAt < $to)
      )
    )]
  ' > "$PR_CACHE"
  echo "Cached $(jq length "$PR_CACHE") PRs to $PR_CACHE" >&2
else
  echo "Using cached PR list: $PR_CACHE ($(jq length "$PR_CACHE") PRs)" >&2
fi

# === Step 2: Blacklist適用 ===
BLACKLIST_ARRAY=()
if [ -n "$BLACKLIST" ]; then
  IFS=',' read -rA BLACKLIST_ARRAY <<< "$BLACKLIST"
fi

PR_NUMBERS=($(jq -r '.[].number' "$PR_CACHE"))
FILTERED_PRS=()
for pr in "${PR_NUMBERS[@]}"; do
  skip=false
  for bl in "${BLACKLIST_ARRAY[@]}"; do
    if [ "$pr" = "$bl" ]; then
      skip=true
      break
    fi
  done
  # 定期リリース除外
  title=$(jq -r ".[] | select(.number == $pr) | .title" "$PR_CACHE")
  if echo "$title" | grep -q "定期リリース"; then
    skip=true
  fi
  # release-feature / release / main へのマージPR除外（headが release-feature/* のもの）
  headRef=$(jq -r ".[] | select(.number == $pr) | .headRefName // \"\"" "$PR_CACHE")
  if echo "$headRef" | grep -qE "^release-feature/"; then
    echo "  除外(release-featureマージ): #$pr $title" >&2
    skip=true
  fi
  if [ "$skip" = false ]; then
    FILTERED_PRS+=($pr)
  fi
done

echo "Processing ${#FILTERED_PRS[@]} PRs (${#BLACKLIST_ARRAY[@]} blacklisted, 定期リリース excluded)..." >&2

# === Step 3: ファイル別additions取得(キャッシュ) ===
if [ ! -f "$FILES_CACHE" ]; then
  echo "{}" > "$FILES_CACHE"
fi

total_impl=0
total_test=0
total_docs=0
total_all=0
pr_count=0

for pr in "${FILTERED_PRS[@]}"; do
  # キャッシュチェック
  cached=$(jq -r ".[\"$pr\"] // empty" "$FILES_CACHE")
  if [ -z "$cached" ]; then
    # API から取得
    result=$(gh api "repos/$REPO/pulls/$pr/files" --paginate 2>/dev/null | jq '
      [.[] |
        select(.filename |
          test("node_modules/|package-lock|generated/|storybook-static/|\\.agent/|\\.claude/|\\.vscode/|\\.next/|design-tokens|openapi\\.yaml") | not
        ) |
        select(.filename |
          test("\\.(md|csv|xml|json)$") | not
        )
      ] |
      {
        impl: ([.[] | select(.filename | test("\\.stories\\.") | not) | select(.filename | test("_spec\\.rb$|\\.test\\.|\\.spec\\.") | not) | select(.filename | test("docs/") | not) | .additions] | add // 0),
        test: ([.[] | select(.filename | test("_spec\\.rb$|\\.test\\.|\\.spec\\.")) | .additions] | add // 0),
        stories: ([.[] | select(.filename | test("\\.stories\\.")) | .additions] | add // 0),
        docs: ([.[] | select(.filename | test("docs/")) | .additions] | add // 0)
      }
    ')
    # キャッシュに追加
    jq --arg pr "$pr" --argjson data "$result" '.[$pr] = $data' "$FILES_CACHE" > "${FILES_CACHE}.tmp"
    mv "${FILES_CACHE}.tmp" "$FILES_CACHE"
  else
    result=$cached
  fi

  impl=$(echo "$result" | jq '.impl')
  test_v=$(echo "$result" | jq '.test + .stories')
  docs=$(echo "$result" | jq '.docs')

  total_impl=$((total_impl + impl))
  total_test=$((total_test + test_v))
  total_docs=$((total_docs + docs))
  total_all=$((total_all + impl + test_v + docs))
  pr_count=$((pr_count + 1))

  echo "  #$pr: 実装=$impl テスト=$test_v ドキュメント=$docs" >&2
done

echo ""
echo "=== $AUTHOR ($FROM ~ $TO) ==="
echo "PR数: $pr_count"
echo "計: $total_all"
echo "実装: $total_impl"
echo "テスト: $total_test"
echo "ドキュメント: $total_docs"
