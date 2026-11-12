#!/usr/bin/env python3
"""文書ビューア + 質問受付サーバー。

- 同じディレクトリの 00-*.html と dayNN-*.html / NN-*.html を配信する。
- 本文を選択して送られた質問を questions.jsonl に一行追記する。
- questions.jsonl の answer を埋めるとページに表示される。

起動: python3 server.py  (http://localhost:8765、PORT 環境変数で変更可)
"""

import json
import os
import re
import sys
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

ROOT = os.path.dirname(os.path.abspath(__file__))
QUESTIONS = os.path.join(ROOT, "questions.jsonl")
PORT = int(os.environ.get("PORT", "8765"))

TITLE_RE = re.compile(r"<title>(.*?)</title>", re.S)
# ページとして扱うファイル名: 先頭が英数字の連番か day 番号。例: 00-plan.html, 01-intro.html, day03-scope.html
PAGE_FILE_RE = re.compile(r"^((?:day)?\d+)-.*\.html$")


def list_pages():
    pages = []
    for f in sorted(os.listdir(ROOT)):
        m = PAGE_FILE_RE.match(f)
        if not m:
            continue
        with open(os.path.join(ROOT, f), encoding="utf-8") as fp:
            t = TITLE_RE.search(fp.read(4000))
        title = t.group(1).strip() if t else m.group(1)
        label = re.split(r"[:：]", title)[0]
        pages.append({"key": m.group(1), "path": "/" + m.group(1), "label": label, "file": f})
    return pages


def read_questions():
    if not os.path.exists(QUESTIONS):
        return []
    items = []
    with open(QUESTIONS, encoding="utf-8") as fp:
        for line in fp:
            line = line.strip()
            if line:
                try:
                    items.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
    return items


def append_question(q):
    items = read_questions()
    q["id"] = (max([it.get("id", 0) for it in items]) + 1) if items else 1
    q["asked_at"] = time.strftime("%Y-%m-%d %H:%M:%S")
    q["answer"] = None
    with open(QUESTIONS, "a", encoding="utf-8") as fp:
        fp.write(json.dumps(q, ensure_ascii=False) + "\n")
    return q


CTYPES = {
    ".html": "text/html; charset=utf-8",
    ".css": "text/css; charset=utf-8",
    ".js": "text/javascript; charset=utf-8",
    ".png": "image/png",
    ".svg": "image/svg+xml",
}


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        sys.stderr.write("%s %s\n" % (time.strftime("%H:%M:%S"), fmt % args))

    def send(self, code, body, ctype="text/plain; charset=utf-8"):
        data = body.encode("utf-8") if isinstance(body, str) else body
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(data)

    def send_file(self, name):
        path = os.path.join(ROOT, name)
        if not os.path.isfile(path):
            return self.send(404, "not found")
        with open(path, "rb") as fp:
            data = fp.read()
        ext = os.path.splitext(name)[1]
        return self.send(200, data, CTYPES.get(ext, "application/octet-stream"))

    def do_GET(self):
        u = urlparse(self.path)
        pages = list_pages()
        if u.path == "/api/pages":
            return self.send(200, json.dumps(pages, ensure_ascii=False), "application/json; charset=utf-8")
        if u.path == "/api/questions":
            key = parse_qs(u.query).get("page", [None])[0]
            items = [q for q in read_questions() if not key or q.get("page") == key]
            return self.send(200, json.dumps(items, ensure_ascii=False), "application/json; charset=utf-8")
        if u.path == "/":
            if not pages:
                return self.send(404, "no pages")
            return self.send_file(pages[0]["file"])
        for p in pages:
            if u.path == p["path"]:
                return self.send_file(p["file"])
        name = u.path.lstrip("/")
        if re.fullmatch(r"[\w.-]+\.(css|js|png|svg|html)", name):
            return self.send_file(name)
        return self.send(404, "not found")

    def do_POST(self):
        u = urlparse(self.path)
        if u.path != "/api/questions":
            return self.send(404, "not found")
        length = int(self.headers.get("Content-Length", "0"))
        try:
            q = json.loads(self.rfile.read(length).decode("utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError):
            return self.send(400, "bad json")
        q = {
            "page": str(q.get("page", ""))[:32],
            "section": str(q.get("section", ""))[:64],
            "section_title": str(q.get("section_title", ""))[:200],
            "quote": str(q.get("quote", ""))[:2000],
            "question": str(q.get("question", ""))[:4000],
        }
        if not q["question"]:
            return self.send(400, "empty")
        saved = append_question(q)
        return self.send(200, json.dumps(saved, ensure_ascii=False), "application/json; charset=utf-8")


if __name__ == "__main__":
    srv = ThreadingHTTPServer(("127.0.0.1", PORT), Handler)
    print(f"http://localhost:{PORT}", flush=True)
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass
