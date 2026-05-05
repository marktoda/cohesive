# Substrate layout

The directory structure Cohesive's skills default to when creating or finding substrate artifacts. The structure encodes one principle: **canonical and historical artifacts have different lifecycles and live in different places.**

## The split

```
ARCHITECTURE.md           # top-level canonical architecture; replace-on-update
docs/
├── substrate/            # CURRENT canonical truth — replace-on-update
│   ├── invariants/       # SHOUTY_NAME.md
│   ├── matrices/         # kebab-case.md
│   ├── gotchas/          # kebab-case.md
│   ├── designs/          # kebab-case.md (cross-cutting design decisions)
│   └── SUBSTRATE-MAP.md  # index of the above (optional until ≥3 artifacts)
└── history/              # DATED append-only — workflow outputs and retired docs
    ├── plans/            # YYYY-MM-DD-<slug>.md
    ├── reviews/          # YYYY-MM-DD-<slug>-architecture-review.md, ...
    ├── delta-ledgers/    # YYYY-MM-DD-<slug>.md (rewrite-specs output)
    ├── brainstorms/      # YYYY-MM-DD-<slug>.md (brainstorm-design output, when persisted)
    └── transcripts/      # <date>-<slug>.md (dogfood / scenario captures, optional)
```

`docs/substrate/` is **rewritten in place**. When an invariant is strengthened, the file is edited; the diff in git history records the change. No date in the filename.

`docs/history/` is **append-only**. Reviews, plans, and delta-ledgers are dated point-in-time artifacts; never edited after creation. Date in the filename.

## Why the split

Mixing canonical and historical content in one directory produces the pain Cohesive was designed to fix: you can never tell whether a doc is current or stale. The split makes it structural — `docs/substrate/X` is current *by location*. A reader doesn't have to read the file to know its lifecycle.

## Naming

| Category | Convention | Example | Producing skill |
|---|---|---|---|
| Architecture | top-level `ARCHITECTURE.md` | `ARCHITECTURE.md` | (manually maintained) |
| Invariant | `SHOUTY_CASE.md` | `AUDIT_EXTERNAL_MUTATION.md` | (V1 `create-invariant`) |
| Behavior matrix | `kebab-case.md` | `intake-decision-kernel.md` | (V1 `create-matrix`) |
| Gotcha | `kebab-case.md` | `slack-thread-truncation.md` | (manually authored) |
| Design | `kebab-case.md` | `three-layer-architecture.md` | (manually authored) |
| Plan | `YYYY-MM-DD-<slug>.md` | `2026-05-04-mvp-implementation.md` | (manually authored) |
| Architecture review | `YYYY-MM-DD-<slug>-architecture-review.md` | `2026-05-04-codebase-architecture-review.md` | `review-codebase` |
| Substrate audit | `YYYY-MM-DD-<slug>-audit-substrate.md` | `2026-05-04-codebase-audit-substrate.md` | `audit-substrate` |
| Rewrite validation | `YYYY-MM-DD-<slug>-rewrite-validation.md` | `2026-05-04-intake-classification-rewrite-validation.md` | `validate-rewrite` |
| Delta ledger | `YYYY-MM-DD-<slug>.md` | `2026-05-04-intake-classification.md` | `rewrite-specs` |
| Brainstorm | `YYYY-MM-DD-<slug>.md` | `2026-05-04-intake-classification.md` | `brainstorm-design` |
| Transcript | `YYYY-MM-DD-<slug>.md` | `2026-05-04-substrate-collapse.md` | (manually captured) |

The skill-output filenames embed the *producing-skill name* as the suffix (`-audit-substrate`, `-rewrite-validation`) so a future contributor reading a directory listing can tell which skill produced each artifact. Cohesive's older review artifacts (`-architecture-review.md`, `-self-review.md`) predate the rename and use noun-phrase suffixes; new artifacts use the verb-noun pattern that matches the producing skill.

## Growth pattern

Don't create empty directories preemptively. Grow as needed:

1. **Phase 0** — A repo with a `CLAUDE.md` or `README.md` is fine. No substrate dirs yet.
2. **Phase 1** — First named invariant or behavior matrix → create `docs/substrate/<category>/` and put it there.
3. **Phase 2** — First cross-cutting design decision worth pulling out of `ARCHITECTURE.md` → create `docs/substrate/designs/` and put it there.
4. **Phase 3** — First Cohesive workflow output → create `docs/history/<category>/` and put it there.
5. **Phase 4** — Mature: most subdirs populated; `docs/substrate/SUBSTRATE-MAP.md` indexes them.

Empty subdirs in mature projects are fine — an empty `gotchas/` signals "you should have some of these." But don't create them just to have the structure look complete.

## Skill behavior

Cohesive skills creating new artifacts:

1. **Detect existing convention.** If the repo uses `docs/specs/`, `docs/adr/`, `docs/invariants/`, etc., extend it — don't impose Cohesive's layout on a repo that has its own.
2. **Otherwise default to the layout above.**
3. **Never run parallel.** If `docs/specs/` exists for canonical content, don't create a sibling `docs/substrate/`. Pick one.

Cohesive skills reading substrate (`discover-substrate`, `review-codebase`, `review-diff`, `audit-substrate`, `validate-rewrite`):

- Read this layout if present
- Read existing repo conventions otherwise
- If both exist, treat the existing one as authoritative and flag the duplication for cleanup

## Artifact directory resolution

Persisting skills (`review-codebase`, `audit-substrate`, `rewrite-specs`, `brainstorm-design`, `validate-rewrite`) resolve their output directory by this rule, applied before any write. The rule is the same for every persisting skill; the skills cite this section rather than restate it.

For artifact category C (review / audit / delta-ledger / brainstorm / validation), output goes under the first directory that exists, in this order:

1. **Existing Cohesive layout** — if `docs/history/<C-subdir>/` exists, use it. Subdirs: `reviews/` for review and audit and validation, `delta-ledgers/` for delta-ledger, `brainstorms/` for brainstorm.
2. **Existing repo convention** — if the repo uses one of `docs/adr/`, `docs/specs/`, `docs/design/`, `docs/decisions/`, `docs/architecture/`, place the artifact alongside it under a category-named subdirectory (e.g., `docs/adr/reviews/`, `docs/specs/delta-ledgers/`). Don't create a sibling `docs/history/` next to a populated `docs/adr/`.
3. **External-repo Cohesive default** — if neither exists, create `docs/cohesive/<C-subdir>/`. This makes Cohesive's outputs visible without colonizing the user's `docs/` tree.
4. **No `docs/` directory at all** — create `docs/cohesive/<C-subdir>/`. Skills do not write outside `docs/`.

The resolved path is announced in chat at the start of the persisting skill's run, before any write. This is the "Step 0" preamble each persisting skill carries.

The full cell-by-cell expansion (per artifact category × per repo shape) lives in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/artifact-placement.md` once that matrix exists; until then, the four-rule resolution above is authoritative.

## Anti-patterns

- Dated file in `docs/substrate/` — move it to `history/` or remove the date
- Undated file in `docs/history/` — add the date or move it to `substrate/`
- "Design" doc that aspires to canonical state but lives in its own subdir — promote to `ARCHITECTURE.md` once approved; otherwise keep in `history/plans/` until it earns canonical status
- One invariant file with multiple invariants in it — split into one file per named invariant; cross-reference via the substrate map
- Creating subdirs before they have content — adds visual ceremony without teaching anything

## Substrate map

Once `docs/substrate/` has ≥3 artifacts, add `docs/substrate/SUBSTRATE-MAP.md` indexing them and linking to relevant `docs/history/` entries. Use the template at `${CLAUDE_PLUGIN_ROOT}/references/templates/substrate-map.md`.
