/**
 * sheet_rows.json を Google スプレッドシートに書き込む。
 *
 * 実行前に google-sheets スキルの認証が通っていること。
 *
 * 使い方:
 *   node --experimental-strip-types write_sheet.ts <spreadsheetId> <シート名>
 *
 * 指定シートの A1:G1000 をクリアしてから書き込む（破壊的）。
 * 実行前に必ずユーザーの明示的な指示を得ること。
 */
import { readFileSync } from "node:fs";
import { request } from "/Users/takuma/.claude/bin/google/sheet.ts";

const [id, sheet] = process.argv.slice(2);
if (!id || !sheet) {
  console.error("usage: node --experimental-strip-types write_sheet.ts <spreadsheetId> <シート名>");
  process.exit(1);
}

type Row = {
  feature: string;
  ticket: string;
  jira_url: string;
  gh_url: string;
  title: string;
  add: number;
  del: number;
};

const rows: Row[] = JSON.parse(readFileSync("sheet_rows.json", "utf8"));

const values: (string | number)[][] = [
  ["feature", "チケットID", "JIRAリンク", "GHリンク", "チケットタイトル", "行数+", "行数-"],
];
for (const r of rows) {
  values.push([r.feature, r.ticket, r.jira_url, r.gh_url, r.title, r.add, r.del]);
}

const range = encodeURIComponent(sheet);
await request("POST", `/spreadsheets/${id}/values/${range}!A1:G1000:clear`, {});
await request("PUT", `/spreadsheets/${id}/values/${range}!A1?valueInputOption=USER_ENTERED`, {
  values,
});

console.log(`wrote ${values.length - 1} rows to ${sheet}`);
