---
name: ts-strict-typing
description: TypeScriptで as 型アサーション、@ts-expect-error、@ts-ignore、any を禁止する。TypeScriptコードを書く・修正する際に常に適用する。
user-invocable: false
---

# TypeScript 厳密型付けルール

TypeScript コードを書く・修正する際、以下を禁止する。

## 禁止事項

| 禁止 | 許可される代替 |
|:-----|:-------------|
| `as Type`（型アサーション） | 型注釈、`satisfies`、ジェネリクス制約、型ガード |
| `as any` | 型を正しく定義する |
| `as unknown` | 型ガード、ジェネリクス |
| `@ts-expect-error` | 型を正しく修正する |
| `@ts-ignore` | 型を正しく修正する |
| `: any` 型注釈 | 具体的な型、`unknown` + 型ガード |
| `eslint-disable` / `eslint-disable-next-line` | ルールに従って正しく書く |

## 例外

- `as const` は許可（リテラル型の推論に必要）
- `as never` は **型安全なラッパー関数の内部でのみ** 許可（RHF の `setValue` など、ライブラリの型シグネチャが構造的に合わない境界に限定。呼び出し側では使用禁止）

## 代替パターン

### null の型付け

```ts
// NG
const obj = { name: null as string | null };

// OK — 変数に型注釈
const name: string | null = null;
const obj = { name };

// OK — オブジェクト全体に型注釈
const obj: { name: string | null } = { name: null };
```

### react-hook-form の Path 制約

```ts
// NG
// @ts-expect-error field is boolean
setValue(fieldPath, false);

// OK — FieldPathByValue で型制約
import { FieldPathByValue } from 'react-hook-form';
interface Props<T extends FieldValues> {
  field: FieldPathByValue<T, boolean>;
}
```

### 型の絞り込み

```ts
// NG
const value = response as ApiResponse;

// OK — 型ガード
function isApiResponse(v: unknown): v is ApiResponse {
  return typeof v === 'object' && v !== null && 'data' in v;
}
if (isApiResponse(response)) { /* response は ApiResponse */ }

// OK — Zod パース
const value = apiResponseSchema.parse(response);
```