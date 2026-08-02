#!/usr/bin/env python3
"""PR のフル情報（コミット・レビュー・変更ファイル・コメント）を GraphQL でまとめて取得する。

pr_numbers.txt の番号を BATCH_SIZE 件ずつ GraphQL の alias で束ねて 1 リクエストにする。
1件ずつ `gh pr view` を叩くより桁違いに速い。
取得済みの PR はスキップするので、中断しても再実行すれば続きから走る。

使い方:
    python3 fetch_prs.py <owner/repo>

出力: prs.json（カレントディレクトリ）
"""
import argparse
import json
import subprocess
import sys
import time
from pathlib import Path

BATCH_SIZE = 20  # 1 GraphQL リクエストあたりの PR 数。増やすとタイムアウトしやすい
NUMBERS_FILE = Path("pr_numbers.txt")
OUTPUT_FILE = Path("prs.json")

PR_FRAGMENT = """
  pr%(num)d: pullRequest(number: %(num)d) {
    number
    title
    state
    isDraft
    url
    createdAt
    mergedAt
    closedAt
    additions
    deletions
    changedFiles
    author { login }
    mergedBy { login }
    baseRefName
    headRefName
    body
    labels(first: 20) { nodes { name } }
    milestone { title }
    commits(first: 100) {
      totalCount
      nodes { commit { oid messageHeadline committedDate author { name email } additions deletions } }
    }
    reviews(first: 50) {
      totalCount
      nodes { author { login } state submittedAt body }
    }
    files(first: 100) {
      totalCount
      nodes { path additions deletions changeType }
    }
    comments(first: 50) {
      totalCount
      nodes { author { login } createdAt body }
    }
  }
"""


def build_query(owner, name, numbers):
    inner = "\n".join(PR_FRAGMENT % {"num": n} for n in numbers)
    return (f'query {{\n  repository(owner: "{owner}", name: "{name}") {{\n'
            f"{inner}\n  }}\n}}\n")


def run_query(query, max_retries=10):
    """GraphQL 実行。502 が散発するので指数バックオフで粘る。"""
    last_err = ""
    for attempt in range(max_retries):
        r = subprocess.run(["gh", "api", "graphql", "-f", f"query={query}"],
                           capture_output=True, text=True)
        if r.returncode == 0:
            return json.loads(r.stdout)
        last_err = r.stderr
        wait = min(10 * (attempt + 1), 60)
        print(f"  retry {attempt+1}: {last_err.strip()[:70]} (wait {wait}s)", file=sys.stderr)
        time.sleep(wait)
    raise RuntimeError(last_err)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("repo", help="owner/repo")
    args = p.parse_args()
    owner, name = args.repo.split("/")

    numbers = [int(x) for x in NUMBERS_FILE.read_text().split() if x.strip()]
    collected = json.loads(OUTPUT_FILE.read_text()) if OUTPUT_FILE.exists() else []
    done = {pr["number"] for pr in collected}
    todo = [n for n in numbers if n not in done]
    print(f"total={len(numbers)} done={len(done)} todo={len(todo)}", file=sys.stderr)

    for i in range(0, len(todo), BATCH_SIZE):
        batch = todo[i:i + BATCH_SIZE]
        data = run_query(build_query(owner, name, batch))
        if data.get("errors"):
            print(f"errors in {batch}: {data['errors']}", file=sys.stderr)
        repo = data["data"]["repository"]
        for n in batch:
            pr = repo.get(f"pr{n}")
            if pr is not None:
                collected.append(pr)
        OUTPUT_FILE.write_text(json.dumps(collected, ensure_ascii=False))
        print(f"progress {len(collected)}/{len(numbers)}", file=sys.stderr)

    missing = set(numbers) - {pr["number"] for pr in collected}
    print(f"done: {len(collected)} PRs -> {OUTPUT_FILE}", file=sys.stderr)
    if missing:
        print(f"※ 未取得 {len(missing)} 件: {sorted(missing)[:20]}", file=sys.stderr)


if __name__ == "__main__":
    main()
