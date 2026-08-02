#!/usr/bin/env python3
"""判定UI用のデータ review_data.json を生成する。

filter.py と同じ設定を使い、PR を3グループに分ける:
  confirmed - confirm_prefixes に当たった（対象機能の本体を触った・確度最高）
  specific  - 対象機能に固有のファイルを触った（specific_patterns で判定）
  shared    - 共用ファイルのみ（判断が要る本体）

PR本文は判定材料にならない定型セクション以降を削る（body_cut_pattern）。
Jira キーを抽出してリンクにする（jira_pattern / jira_base）。

使い方:
    python3 build_review_data.py [--config filter_config.json]
"""
import argparse
import json
import re
from collections import Counter
from pathlib import Path

import filter as flt

OUT = Path("review_data.json")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", default="filter_config.json")
    args = ap.parse_args()

    cfg = flt.load_config(args.config)
    prs = json.loads(Path("prs.json").read_text())

    excluded = flt.make_excluder(cfg)
    pr_excluded = flt.make_pr_excluder(cfg)
    is_dev = flt.make_dev_check(cfg)
    confirm = cfg.get("confirm_prefixes", [])
    specific = [re.compile(p) for p in cfg.get("specific_patterns", [])]

    cut_pat = cfg.get("body_cut_pattern")
    cut_re = re.compile(cut_pat, re.MULTILINE) if cut_pat else None
    jira_re = re.compile(cfg.get("jira_pattern", r"\b([A-Z][A-Z0-9]+-\d+)\b"))
    jira_base = cfg.get("jira_base", "")

    def trim_body(body):
        if not body:
            return ""
        if cut_re:
            m = cut_re.search(body)
            if m:
                body = body[:m.start()]
        return body.strip()

    def jira_keys(pr):
        text = " ".join([pr.get("title") or "", pr.get("headRefName") or "",
                         pr.get("body") or ""])
        seen = []
        for k in jira_re.findall(text):
            if k not in seen:
                seen.append(k)
        return seen

    rows = []
    for pr in prs:
        if not is_dev(pr) or pr_excluded(pr):
            continue
        ps = flt.paths_of(pr)
        if confirm and any(p.startswith(c) for c in confirm for p in ps):
            group = "confirmed"
        else:
            kept = [p for p in ps if not excluded(p)]
            if not kept:
                continue  # 除外で消えたPR
            group = "specific" if any(r.search(p) for r in specific for p in kept) else "shared"

        files = []
        for f in (pr.get("files") or {}).get("nodes", []):
            p = f["path"]
            is_confirm = any(p.startswith(c) for c in confirm)
            files.append({
                "path": p,
                "add": f.get("additions", 0),
                "del": f.get("deletions", 0),
                "kept": not excluded(p) and not is_confirm,
                "core": is_confirm,
            })

        rows.append({
            "group": group,
            "number": pr["number"],
            "title": pr.get("title", "") or "",
            "author": (pr.get("author") or {}).get("login", ""),
            "mergedAt": (pr.get("mergedAt") or "")[:10],
            "url": pr.get("url", ""),
            "base": pr.get("baseRefName", ""),
            "head": pr.get("headRefName", ""),
            "additions": pr.get("additions", 0),
            "deletions": pr.get("deletions", 0),
            "changedFiles": pr.get("changedFiles", 0),
            "body": trim_body(pr.get("body"))[:4000],
            "jira": [{"key": k, "url": jira_base + k} for k in jira_keys(pr)],
            "files": files,
        })

    # 軽いものから片付けられるよう、変更ファイル数の少ない順
    rows.sort(key=lambda r: (r["changedFiles"], r["number"]))
    OUT.write_text(json.dumps(rows, ensure_ascii=False))

    c = Counter(r["group"] for r in rows)
    print(f"{OUT}: {len(rows)} 件  "
          f"confirmed={c['confirmed']} specific={c['specific']} shared={c['shared']}")


if __name__ == "__main__":
    main()
