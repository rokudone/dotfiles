import { request } from "../../../bin/google/sheet.ts";

interface SheetProps {
  properties: { sheetId: number; title: string };
}
interface Meta {
  properties: { title: string };
  sheets: SheetProps[];
}
interface Values {
  values?: string[][];
}

const [target, range] = process.argv.slice(2);
if (!target) {
  console.error("usage: read.ts <spreadsheet-url-or-id> [range]");
  process.exit(1);
}

const idMatch = target.match(/\/d\/([\w-]+)/);
const id = idMatch ? idMatch[1] : target;
const gidMatch = target.match(/[#&?]gid=(\d+)/);

const meta = await request<Meta>(
  "GET",
  `/spreadsheets/${id}?fields=properties.title,sheets.properties`,
);
console.error(`# ${meta.properties.title}`);
console.error(
  `# sheets: ${meta.sheets.map((s) => `${s.properties.title}(gid=${s.properties.sheetId})`).join(", ")}`,
);

let effectiveRange = range;
if (!effectiveRange) {
  const gid = gidMatch ? Number(gidMatch[1]) : null;
  const sheet =
    gid === null
      ? meta.sheets[0]
      : meta.sheets.find((s) => s.properties.sheetId === gid);
  if (!sheet) {
    console.error(`gid=${gid} が見つかりません`);
    process.exit(1);
  }
  effectiveRange = sheet.properties.title;
}

const values = await request<Values>(
  "GET",
  `/spreadsheets/${id}/values/${encodeURIComponent(effectiveRange)}`,
);
for (const row of values.values ?? []) {
  console.log(row.join("\t"));
}
