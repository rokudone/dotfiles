#!/usr/bin/env python3
"""判定結果を feature でグループ分けし、スプレッドシート用の行データを作る。

対象は review_data.json のうち --group で指定したグループ。
Revert で相殺する PR とブランチ同期のマージ PR は除外する（--exclude で番号指定）。

feature 分類は features.json で定義する。形式:
    [["グループ名", ["キーワード1", "キーワード2"]], ...]
上から順に、タイトルにキーワードを含む最初のグループへ振り分ける。
どれにも当たらなければ「その他」。

使い方:
    python3 build_sheet_rows.py --group confirmed --features features.json \
        --exclude 1402,1461,2480,2481,2495,1246

出力: sheet_rows.json
"""
import argparse
import json
from collections import Counter
from pathlib import Path

OUT = Path("sheet_rows.json")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--group", default="confirmed",
                    help="対象グループ (confirmed/specific/shared)。all で全部")
    ap.add_argument("--features", default="features.json")
    ap.add_argument("--exclude", default="",
                    help="除外するPR番号のカンマ区切り（Revert相殺・マージ同期など）")
    args = ap.parse_args()

    features = json.loads(Path(args.features).read_text())
    skip = {int(x) for x in args.exclude.split(",") if x.strip()}
    rows = json.loads(Path("review_data.json").read_text())
    if args.group != "all":
        rows = [r for r in rows if r["group"] == args.group]

    def classify(title):
        for name, keys in features:
            if any(k in title for k in keys):
                return name
        return "その他"

    out = []
    for r in rows:
        if r["number"] in skip:
            continue
        jira = r["jira"][0] if r["jira"] else None
        out.append({
            "feature": classify(r["title"]),
            "ticket": jira["key"] if jira else "",
            "jira_url": jira["url"] if jira else "",
            "gh_url": r["url"],
            "title": r["title"],
            "add": r["additions"],
            "del": r["deletions"],
        })

    order = [name for name, _ in features] + ["その他"]
    out.sort(key=lambda x: (order.index(x["feature"]), -(x["add"] + x["del"])))
    OUT.write_text(json.dumps(out, ensure_ascii=False, indent=2))

    c = Counter(x["feature"] for x in out)
    print(f"{len(out)} 件 -> {OUT}")
    for name in order:
        if c[name]:
            print(f"  {c[name]:3d}  {name}")


if __name__ == "__main__":
    main()
