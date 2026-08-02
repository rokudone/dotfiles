#!/usr/bin/env python3
"""除外ルールを重ねて PR 母集合を削り、残りを判定対象として出力する。

考え方（重要）:
- PR を消すのではなく「ファイル行」を消す。
  1 PR = 複数のファイル行として扱い、除外ルールに当たる行を削る。
  全行が削られて 1 行も残らなかった PR だけが母集合から落ちる。
  → 無関係ファイルと対象ファイルを両方触った PR は、対象ファイルの行が残るので生き残る。
    「casy-ruby も触ったから丸ごと除外」のような取りこぼしが構造的に起きない。
- CONFIRM_PREFIX に当たる PR は「読む対象確定」として除外プロセスの外に置く。
- 統合PR（release→master 等）と定期リリース束は個別開発ではないので母集合から外す。
  これらは中身が寄せ集めで、含まれる開発は個別 PR として別途母集合にいる（二重計上になる）。

設定は filter_config.json に書く。同ディレクトリの例を参照。

使い方:
    python3 filter.py [--config filter_config.json] [--show-dirs] [--depth 4]

    --show-dirs  残ったPRが触るディレクトリを頻度順に表示（次の除外ワードを探す用）
    --depth      --show-dirs の階層の深さ（既定4）
"""
import argparse
import json
import re
from collections import Counter
from pathlib import Path


def load_config(path):
    return json.loads(Path(path).read_text())


def paths_of(pr):
    return [f["path"] for f in (pr.get("files") or {}).get("nodes", [])]


def make_excluder(cfg):
    """パスが除外対象かを判定する関数を返す。keep が exclude に優先する。"""
    keep = cfg.get("keep_substrings", [])
    prefixes = cfg.get("exclude_prefixes", [])
    substrings = cfg.get("exclude_substrings", [])
    basenames = set(cfg.get("exclude_basenames", []))

    def excluded(p):
        if any(k in p for k in keep):
            return False  # 到達可能と確認済み。除外に優先して残す
        if any(p.startswith(x) for x in prefixes):
            return True
        if p.split("/")[-1] in basenames:
            return True
        if any(s in p for s in substrings):
            return True
        return False

    return excluded


def make_pr_excluder(cfg):
    """PR単位の除外判定を返す。

    ファイル行を消す方式と違い、指定パターンを1ファイルでも含む PR を丸ごと落とす。
    「移植先の新実装」のように、混ざっていたら PR ごと対象外にすべきものに使う。
    """
    patterns = cfg.get("exclude_pr_if_touches", [])

    def excluded(pr):
        if not patterns:
            return False
        return any(pat in f["path"] for f in (pr.get("files") or {}).get("nodes", [])
                   for pat in patterns)

    return excluded


def make_dev_check(cfg):
    """個別開発PRかを判定する。統合PR・リリース束を False にする。"""
    heads = set(cfg.get("nondev_head_refs", []))
    titles = [t.lower() for t in cfg.get("nondev_titles", [])]
    patterns = [re.compile(p) for p in cfg.get("nondev_title_patterns", [])]

    def is_dev(pr):
        title = (pr.get("title") or "").strip()
        if (pr.get("headRefName") or "") in heads:
            return False
        if title.lower() in titles:
            return False
        if any(p.search(title) for p in patterns):
            return False
        return True

    return is_dev


def classify(prs, cfg):
    """PR を confirmed / kept / dropped / nondev に分類する。"""
    excluded = make_excluder(cfg)
    pr_excluded = make_pr_excluder(cfg)
    is_dev = make_dev_check(cfg)
    confirm = cfg.get("confirm_prefixes", [])

    confirmed, nondev, pr_dropped = [], [], []
    lines = []
    for pr in prs:
        if not is_dev(pr):
            nondev.append(pr)
            continue
        if pr_excluded(pr):
            pr_dropped.append(pr)
            continue
        ps = paths_of(pr)
        if confirm and any(p.startswith(c) for c in confirm for p in ps):
            confirmed.append(pr)
            continue
        for p in ps:
            lines.append((pr["number"], p))

    kept_nums = {n for n, p in lines if not excluded(p)}
    all_nums = {n for n, _ in lines}
    return {
        "confirmed": confirmed,
        "nondev": nondev,
        "pr_dropped": pr_dropped,
        "kept": [pr for pr in prs if pr["number"] in kept_nums],
        "dropped_count": len(all_nums - kept_nums),
        "pool_count": len(all_nums),
        "excluded": excluded,
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", default="filter_config.json")
    ap.add_argument("--show-dirs", action="store_true")
    ap.add_argument("--depth", type=int, default=4)
    ap.add_argument("--top", type=int, default=30)
    args = ap.parse_args()

    cfg = load_config(args.config)
    prs = json.loads(Path("prs.json").read_text())
    r = classify(prs, cfg)

    print(f"統合PR・リリース束 (母集合外): {len(r['nondev'])} 件")
    print(f"PR単位で除外 (exclude_pr_if_touches): {len(r['pr_dropped'])} 件")
    print(f"読む対象確定 (confirm_prefixes): {len(r['confirmed'])} 件")
    print(f"母集合 (個別開発のみ): {r['pool_count']} 件")
    print(f"  除外で消えた: {r['dropped_count']} 件")
    print(f"  残り(要確認): {len(r['kept'])} 件")

    if args.show_dirs:
        excluded = r["excluded"]
        c = Counter()
        for pr in r["kept"]:
            for p in paths_of(pr):
                if excluded(p):
                    continue
                c["/".join(p.split("/")[:args.depth])] += 1
        print(f"\n=== 残りが触るパス 第{args.depth}階層 (ファイル行数 上位{args.top}) ===")
        for k, v in c.most_common(args.top):
            print(f"{v:5d}  {k}")


if __name__ == "__main__":
    main()
