#!/usr/bin/env python3
"""workspace のラベル先頭に状態の絵文字を付け外しする。

サイドバーの workspace 行は label しか表示枠を持たないため、
label の先頭を状態の印として使う。
"""
from __future__ import annotations

import json
import os
import subprocess
import sys

# 状態名 -> 印。順序は cycle の巡回順を兼ねる。
FLAGS = [
    ("todo", "❤️‍🔥"),   # 要対応
    ("doing", "☀️"),   # 対応中
    ("done", "⏳"),    # 済み
]
BY_NAME = dict(FLAGS)
MARKS = [mark for _, mark in FLAGS]

DEFAULT_FLAG = "todo"

# 印とラベル本体の区切り。表示上の詰まりを避けるための半角スペース。
SEP = " "


def herdr_bin() -> str:
    return os.environ.get("HERDR_BIN_PATH") or "herdr"


def context() -> dict:
    try:
        return json.loads(os.environ.get("HERDR_PLUGIN_CONTEXT_JSON") or "{}")
    except json.JSONDecodeError:
        return {}


def run_json(args: list[str]) -> dict:
    result = subprocess.run(
        [herdr_bin(), *args], text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    if result.returncode != 0:
        raise SystemExit(result.stderr or result.stdout or f"herdr {' '.join(args)} failed")
    try:
        payload = json.loads(result.stdout)
    except json.JSONDecodeError as err:
        raise SystemExit(f"herdr {' '.join(args)} did not return JSON: {err}")
    if "error" in payload:
        raise SystemExit(json.dumps(payload["error"], indent=2))
    return payload


def target_workspace() -> str:
    ctx = context()
    wid = ctx.get("workspace_id") or os.environ.get("HERDR_WORKSPACE_ID")
    if wid:
        return wid
    payload = run_json(["workspace", "list"])
    for ws in payload["result"]["workspaces"]:
        if ws.get("focused"):
            return ws["workspace_id"]
    raise SystemExit("wsflag: 対象の workspace が見つかりません")


def current_label(wid: str) -> str:
    payload = run_json(["workspace", "list"])
    for ws in payload["result"]["workspaces"]:
        if ws.get("workspace_id") == wid:
            return ws.get("label") or ""
    raise SystemExit(f"wsflag: workspace が見つかりません: {wid}")


def split_label(label: str) -> tuple[str | None, str]:
    """先頭の印と、印を除いた本体に分ける。"""
    for name, mark in FLAGS:
        if label.startswith(mark):
            return name, label[len(mark) :].lstrip()
    return None, label


def apply(wid: str, flag: str | None) -> None:
    _, body = split_label(current_label(wid))
    label = body if flag is None else f"{BY_NAME[flag]}{SEP}{body}"
    run_json(["workspace", "rename", wid, label])


def main(argv: list[str]) -> int:
    if not argv:
        print("usage: wsflag.py <cycle|set <todo|doing|done>|clear|default>", file=sys.stderr)
        return 2

    cmd = argv[0]
    wid = target_workspace()

    if cmd == "cycle":
        current, _ = split_label(current_label(wid))
        # 印なし(None)も輪に含める: 要対応 → 対応中 → 済み → 印なし → 要対応
        ring = [name for name, _ in FLAGS] + [None]
        apply(wid, ring[(ring.index(current) + 1) % len(ring)])
    elif cmd == "set":
        if len(argv) < 2 or argv[1] not in BY_NAME:
            print(f"wsflag: 不正な状態: {argv[1:] }", file=sys.stderr)
            return 2
        apply(wid, argv[1])
    elif cmd == "clear":
        apply(wid, None)
    elif cmd == "default":
        # 既に印が付いていれば触らない（rename 由来の再入を避ける）。
        current, _ = split_label(current_label(wid))
        if current is None:
            apply(wid, DEFAULT_FLAG)
    else:
        print(f"wsflag: 不明なコマンド: {cmd}", file=sys.stderr)
        return 2

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
