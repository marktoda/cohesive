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
    └── transcripts/      # <date>-<slug>.md (dogfood / scenario captures, optional)
```

`docs/substrate/` is **rewritten in place**. When an invariant is strengthened, the file is edited; the diff in git history records the change. No date in the filename.

`docs/history/` is **append-only**. Reviews, plans, and delta-ledgers are dated point-in-time artifacts; never edited after creation. Date in the filename.

## Why the split

Mixing canonical and historical content in one directory produces the pain Cohesive was designed to fix: you can never tell whether a doc is current or stale. The split makes it structural — `docs/substrate/X` is current *by location*. A reader doesn't have to read the file to know its lifecycle.

## Naming

| Category | Convention | Example |
|---|---|---|
| Architecture | top-level `ARCHITECTURE.md` | `ARCHITECTURE.md` |
| Invariant | `SHOUTY_CASE.md` | `AUDIT_EXTERNAL_MUTATION.md` |
| Behavior matrix | `kebab-case.md` | `intake-decision-kernel.md` |
| Gotcha | `kebab-case.md` | `slack-thread-truncation.md` |
| Design | `kebab-case.md` | `three-layer-architecture.md` |
| Plan | `YYYY-MM-DD-<slug>.md` | `2026-05-04-mvp-implementation.md` |
| Review | `YYYY-MM-DD-<slug>-architecture-review.md` | `2026-05-04-codebase-architecture-review.md` |
| Delta ledger | `YYYY-MM-DD-<slug>.md` | `2026-05-04-intake-classification.md` |
| Transcript | `YYYY-MM-DD-<slug>.md` | `2026-05-04-substrate-collapse.md` |

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

Cohesive skills reading substrate (`discover-substrate`, `cohesive-review`):

- Read this layout if present
- Read existing repo conventions otherwise
- If both exist, treat the existing one as authoritative and flag the duplication for cleanup

## Anti-patterns

- Dated file in `docs/substrate/` — move it to `history/` or remove the date
- Undated file in `docs/history/` — add the date or move it to `substrate/`
- "Design" doc that aspires to canonical state but lives in its own subdir — promote to `ARCHITECTURE.md` once approved; otherwise keep in `history/plans/` until it earns canonical status
- One invariant file with multiple invariants in it — split into one file per named invariant; cross-reference via the substrate map
- Creating subdirs before they have content — adds visual ceremony without teaching anything

## Substrate map

Once `docs/substrate/` has ≥3 artifacts, add `docs/substrate/SUBSTRATE-MAP.md` indexing them and linking to relevant `docs/history/` entries. Use the template at `${CLAUDE_PLUGIN_ROOT}/references/templates/substrate-map.md`.
