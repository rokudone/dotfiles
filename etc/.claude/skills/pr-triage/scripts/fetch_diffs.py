#!/usr/bin/env python3
"""判定対象PRの diff (patch) を取得して diffs.json に保存する。

判定に必要なファイルの patch だけ保持する。除外済みファイルの diff は
判定のノイズにしかならないので捨てる（サイズも大幅に減る）。

使い方:
    python3 fetch_diffs.py <owner/repo>

前提: review_data.json が存在すること（build_review_data.py の出力）
出力: diffs.json（PR番号 -> ファイルごとの patch）
"""
import argparse
import json
import subprocess
import sys
import time
from pathlib import Path

REVIEW = Path("review_data.json")
OUT = Path("diffs.json")
MAX_PATCH_CHARS = 20000  # 1ファイルあたりの上限。巨大diffでUIが固まるのを防ぐ


def fetch_files(repo, number, max_retries=5):
    for attempt in range(max_retries):
        r = subprocess.run(
            ["gh", "api", f"repos/{repo}/pulls/{number}/files", "--paginate", "--slurp"],
            capture_output=True, text=True,
        )
        if r.returncode == 0:
            pages = json.loads(r.stdout)
            out = []
            for page in pages:
                out.extend(page if isinstance(page, list) else [page])
            return out
        wait = 10 * (attempt + 1)
        print(f"  #{number} retry {attempt+1}: {r.stderr.strip()[:60]} (wait {wait}s)",
              file=sys.stderr)
        time.sleep(wait)
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("repo", help="owner/repo")
    args = ap.parse_args()

    rows = json.loads(REVIEW.read_text())
    want = {}
    for r in rows:
        keep = {f["path"] for f in r["files"] if f["kept"] or f["core"]}
        if keep:
            want[r["number"]] = keep

    diffs = json.loads(OUT.read_text()) if OUT.exists() else {}
    todo = [n for n in want if str(n) not in diffs]
    print(f"対象 {len(want)} / 取得済 {len(diffs)} / 残り {len(todo)}", file=sys.stderr)

    for i, number in enumerate(todo, 1):
        files = fetch_files(args.repo, number)
        if files is None:
            print(f"  #{number} 取得失敗", file=sys.stderr)
            continue
        picked = []
        for f in files:
            if f.get("filename") not in want[number]:
                continue
            patch = f.get("patch") or ""
            picked.append({
                "path": f["filename"],
                "status": f.get("status", ""),
                "add": f.get("additions", 0),
                "del": f.get("deletions", 0),
                "patch": patch[:MAX_PATCH_CHARS],
                "truncated": len(patch) > MAX_PATCH_CHARS,
            })
        diffs[str(number)] = picked
        if i % 10 == 0 or i == len(todo):
            OUT.write_text(json.dumps(diffs, ensure_ascii=False))
            print(f"  progress {i}/{len(todo)}", file=sys.stderr)
        time.sleep(0.4)

    OUT.write_text(json.dumps(diffs, ensure_ascii=False))
    print(f"done: {len(diffs)} PR分 -> {OUT}", file=sys.stderr)


if __name__ == "__main__":
    main()
