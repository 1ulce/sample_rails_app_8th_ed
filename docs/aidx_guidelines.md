# AIDX Annotation Guidelines (v1)

This repository uses **AIDX** tags to keep code, tests, and generated docs aligned for both humans and AI-based tooling. Every public-facing symbol and executable test should expose a minimal, machine-readable contract using single-line tags.

## Core ideas
- Code comments remain the single source of truth; generated docs mirror them.
- Tags start with `@a:` (application code) or `@t:` (test code). They can coexist with YARD/JSDoc comments.
- Tag values are either a single line string or **JSON Lite** (one-line JSON with double quotes, no trailing commas).
- Keep each annotation block under ~300 tokens and <=12 AIDX lines; favour concise statements with explicit units.

## Required tags for application code

| Tag | Purpose | Notes |
| --- | --- | --- |
| `@a:id` | Unique symbol key (`<path>#<method>`). | Autogenerators may fill automatically, but include when hand-writing. |
| `@a:summary` | 50–120 char intent. | One line text. |
| `@a:intent` | Why the symbol exists / non-goals. | Text. |
| `@a:contract` | Preconditions & postconditions. | JSON: `{"requires":[...],"ensures":[...]}`. Empty arrays allowed. |
| `@a:io` | Inputs/outputs with types/units. | JSON: `{"input":{...},"output":{...}}`. Use `null` when not applicable. |
| `@a:errors` | Expected failures/exceptions. | JSON array of strings. Use `"none"` if truly impossible. |
| `@a:sideEffects` | State, network, FS changes. | Text. `"none"` if pure. |
| `@a:security` | AuthN/Z, secrecy, rate limits. | Text. |
| `@a:perf` | Time/space or limits. | Text with O-notation / thresholds. |
| `@a:dependencies` | External services/env/config. | JSON array (`["ENV:...","ActiveJob:..."]`). |
| `@a:example` | Minimal success/ failure pair. | JSON: `{"ok":"...", "ng":"..."}`. |
| `@a:cases` | Related test IDs enforcing behaviour. | JSON array of `TEST-...` identifiers. |

Optional tags: `@a:notes`, `@a:invariant`, `@a:featureFlag`, `@a:ownership`, `@a:telemetry`.

## Required tags for tests

| Tag | Purpose | Notes |
| --- | --- | --- |
| `@t:id` | Stable test ID (`TEST-<area>-<slug>`). | Unique across suite. |
| `@t:covers` | Symbols verified. | JSON array of `@a:id` values. |
| `@t:intent` | Behaviour the test guards. | Text. |
| `@t:kind` | `unit` / `integration` / `e2e` / `property` / `mutation`. | Text. |

Recommended extras: `@t:scenarios` (`[{"name":"...","given":"...","when":"...","then":"..."}]`), `@t:risk`, `@t:flaky`, `@t:slow`, `@t:links`.

## Formatting tips
- Keep lines ASCII. Use `\n` for embedded line breaks inside JSON.
- Quote strings with `"`; escape internal quotes as `\"`.
- For hashes with optional keys, omit them instead of leaving placeholder text.
- Prefer explicit numbers (`"<=100 items"`) over vague statements.

## Validation workflow (MVP)
1. **Authoring**: Add/update comments alongside code changes.
2. **Manual check**: Run `bin/aidx validate` to lint JSON and required tags.
3. **Docs generation**: `bin/aidx export` mirrors comments to `docs/apps/**` (directories match source paths).
4. **Coverage binding** (future): Test runs will enrich `docs/coverage/**` with line data.

## TODO
- Wire up GitHub Actions to run `bin/aidx validate` and doc export on PRs.
- Extend SimpleCov/Jest coverage exports to fill `@a:cases` vs `@t:covers` matrices.
