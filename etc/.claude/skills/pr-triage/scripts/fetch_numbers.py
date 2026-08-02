#!/usr/bin/env python3
"""マージ済みPRの番号を、マージ月ごとに分割して漏れなく取得する。

GitHub Search API は 1 クエリ最大 1000 件（100件×10ページ）。
月ウィンドウで分割すれば各月は 1000 件未満に収まるので取りこぼさない。
`gh pr list --search` は上限で頭打ちして黙って切れるため使わない。

使い方:
    python3 fetch_numbers.py <owner/repo> <開始YYYY-MM> [終了YYYY-MM] [--base BRANCH]

例:
    python3 fetch_numbers.py casy-co-ltd/casy-hub 2025-06
    python3 fetch_numbers.py casy-co-ltd/casy-hub 2025-06 2026-07 --base release

出力: pr_numbers.txt（カレントディレクトリ、PR番号の昇順）
既存ファイルがあれば読み込んで追記する（再実行で差分だけ増える）。
"""
import argparse
import calendar
import json
import subprocess
import sys
import time
from datetime import date
from pathlib import Path

OUT = Path("pr_numbers.txt")


def month_range(start, end):
    """'2025-06' から '2026-07' までの年月文字列を列挙する。"""
    y, m = map(int, start.split("-"))
    ey, em = map(int, end.split("-"))
    while (y, m) <= (ey, em):
        yield f"{y:04d}-{m:02d}"
        m += 1
        if m > 12:
            y, m = y + 1, 1


def last_day(ym):
    y, m = map(int, ym.split("-"))
    return f"{ym}-{calendar.monthrange(y, m)[1]:02d}"


def fetch_page(query, page, max_retries=8):
    """Search API を1ページ取得。レート制限(30req/min)に当たったら待って再試行。"""
    for attempt in range(max_retries):
        r = subprocess.run(
            ["gh", "api", "-X", "GET", "search/issues",
             "--raw-field", f"q={query}",
             "--raw-field", "per_page=100",
             "--raw-field", f"page={page}"],
            capture_output=True, text=True,
        )
        if r.returncode == 0:
            time.sleep(2.2)  # 30 req/min の安全域
            return json.loads(r.stdout)
        if "rate limit" in r.stderr.lower():
            wait = 30 * (attempt + 1)
            print(f"  rate limited, wait {wait}s", file=sys.stderr)
            time.sleep(wait)
            continue
        raise RuntimeError(r.stderr)
    raise RuntimeError("max retries exceeded")


def main():
    p = argparse.ArgumentParser()
    p.add_argument("repo", help="owner/repo")
    p.add_argument("start", help="開始年月 YYYY-MM")
    p.add_argument("end", nargs="?", default=None, help="終了年月 YYYY-MM（省略時は今月）")
    p.add_argument("--base", default=None, help="ベースブランチで絞る（省略時は全base）")
    args = p.parse_args()

    end = args.end or date.today().strftime("%Y-%m")
    base_filter = f" base:{args.base}" if args.base else ""

    numbers = set()
    if OUT.exists():
        numbers = {int(x) for x in OUT.read_text().split() if x.strip()}
        print(f"resume: {len(numbers)} already collected", file=sys.stderr)

    grand_total = 0
    for ym in month_range(args.start, end):
        query = (f"repo:{args.repo} is:pr is:merged{base_filter} "
                 f"merged:{ym}-01..{last_day(ym)}")
        first = fetch_page(query, 1)
        total = first["total_count"]
        grand_total += total
        got = {it["number"] for it in first["items"]}
        page = 2
        while len(got) < total and page <= 10:
            data = fetch_page(query, page)
            if not data["items"]:
                break
            got.update(it["number"] for it in data["items"])
            page += 1
        numbers.update(got)
        OUT.write_text("\n".join(str(n) for n in sorted(numbers)) + "\n")
        print(f"{ym}: total={total} got={len(got)} cumulative={len(numbers)}", file=sys.stderr)

    print(f"合計 {grand_total} / ユニーク {len(numbers)} -> {OUT}", file=sys.stderr)
    if len(numbers) != grand_total:
        print("※ 月合計とユニーク数が不一致。重複や取りこぼしを確認すること", file=sys.stderr)


if __name__ == "__main__":
    main()
