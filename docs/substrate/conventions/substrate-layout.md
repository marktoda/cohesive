# Substrate layout

The directory structure Cohesive's skills default to when creating or finding substrate artifacts. The structure encodes two principles: **canonical and historical artifacts have different lifecycles and live in different places**, and **within the historical bucket, durable decision records persist permanently while ephemeral run scaffolding is cleaned up at handoff**.

## The split

```
ARCHITECTURE.md           # top-level canonical architecture; replace-on-update
docs/
├── substrate/            # CURRENT canonical truth — replace-on-update
│   ├── architecture/     # kebab-case.md (cross-cutting architecture decisions)
│   ├── conventions/      # kebab-case.md (prescriptive component rules)
│   ├── invariants/       # SHOUTY_NAME.md
│   ├── matrices/         # kebab-case.md
│   ├── gotchas/          # kebab-case.md
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

## Lifecycle: durable vs ephemeral

Within `docs/history/`, artifacts split along a second axis. **Durable** decision records (brainstorms, delta-ledgers, reviews, transcripts) persist permanently in main; **ephemeral** run scaffolding (per-phase plans, discovery reports) lives on the implementation branch and is cleaned up at handoff per §"Cleanup at handoff" below. Per-category classification lives in [`docs/substrate/matrices/artifact-placement.md`](../matrices/artifact-placement.md) §"Lifecycle by artifact category".

The lifecycle axis is orthogonal to the audience seam in [`audience-separation.md`](audience-separation.md): the audience seam governs render surfaces (chat vs persisted file); lifecycle governs persistence surfaces (main vs branch). See [`gotchas/plans-as-run-scaffolding.md`](../gotchas/plans-as-run-scaffolding.md) for the failure mode this prevents.

## Why the split

Mixing canonical and historical content in one directory produces the pain Cohesive was designed to fix: you can never tell whether a doc is current or stale. The canonical/historical split makes it structural — `docs/substrate/X` is current *by location*. The durable/ephemeral sub-axis extends the same principle inside `docs/history/`: a reader on `main` who sees a plan path knows it's a permanent record, because the cleanup-at-handoff convention strips run scaffolding before merge.

## Naming

| Category | Convention | Example | Producing skill |
|---|---|---|---|
| Architecture | top-level `ARCHITECTURE.md` | `ARCHITECTURE.md` | (manually maintained) |
| Invariant | `SHOUTY_CASE.md` | `AUDIT_EXTERNAL_MUTATION.md` | (V1 `create-invariant`) |
| Behavior matrix | `kebab-case.md` | `intake-decision-kernel.md` | (V1 `create-matrix`) |
| Gotcha | `kebab-case.md` | `slack-thread-truncation.md` | (manually authored) |
| Architecture (cross-cutting decisions) | `kebab-case.md` | `three-tier-architecture.md` | (manually authored) |
| Convention (prescriptive component rules) | `kebab-case.md` | `skill-shape.md` | (manually authored) |
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
3. **Phase 2** — First cross-cutting architecture decision worth pulling out of `ARCHITECTURE.md` → create `docs/substrate/architecture/` and put it there. First prescriptive component rule worth pulling out of `ARCHITECTURE.md` → create `docs/substrate/conventions/` and put it there.
4. **Phase 3** — First Cohesive workflow output → create `docs/history/<category>/` and put it there.
5. **Phase 4** — Mature: most subdirs populated; `docs/substrate/SUBSTRATE-MAP.md` indexes them.

Empty subdirs in mature projects are fine — an empty `gotchas/` signals "you should have some of these." But don't create them just to have the structure look complete.

## Skill behavior

Cohesive skills creating new artifacts:

1. **Detect existing convention.** If the repo uses `docs/specs/`, `docs/adr/`, `docs/invariants/`, etc., extend it — don't impose Cohesive's layout on a repo that has its own.
2. **Otherwise default to the layout above.**
3. **Never run parallel.** If `docs/specs/` exists for canonical content, don't create a sibling `docs/substrate/`. Pick one.
4. **Write ephemeral artifacts to `docs/history/<category>/` like durable ones** — directory choice doesn't encode lifecycle; cleanup-at-handoff does. Per-category classification lives in [`artifact-placement.md`](../matrices/artifact-placement.md) §"Lifecycle by artifact category".

Cohesive skills reading substrate (`discover-substrate`, `review-codebase`, `review-diff`, `audit-substrate`, `validate-rewrite`):

- Read this layout if present
- Read existing repo conventions otherwise
- If both exist, treat the existing one as authoritative and flag the duplication for cleanup

## Cleanup at handoff

After Step 3 (end-of-run dual reviewer dispatch) synthesizes the Implemented verdict, `cohesive:implement-cohesively` Step 3.5 runs `git rm` on the ephemeral paths for this slug and produces a single commit whose body lists the removed paths verbatim. The verbatim list is the breadcrumb a forensic reader on main follows back to pre-cleanup branch history via `git log --all -- <pattern>`. Cleanup gates on Implemented verdict only; on Coverage Drift / Substrate Drift / Aborted, ephemeral artifacts remain on the branch for the next attempt or post-mortem.

A "run" spans Step 0 input resolution through Step 3 verdict synthesis, independent of Claude session boundary. The plan persists on the branch across session disconnects; the run terminates when Step 3 returns a synthesized verdict, not when the user closes a session. See [`skills/implement-cohesively/SKILL.md`](../../../skills/implement-cohesively/SKILL.md) §"Step 3.5. Post-implementation cleanup" for the operational steps and the cleanup commit format.

**Forensic recovery edges.** When the branch is merged via merge-commit, the cleanup commit and the prior implementation commits are both visible in main's history graph; `git log --all -- <pattern>` recovers the plan. When the branch is squash-merged, the implementation `add` and the cleanup `rm` collapse into the squashed commit's net diff (zero — the plan doesn't appear), which is the desired outcome (smaller PR); pre-squash branch history retains the plan content if the branch ref is preserved. When the branch is force-pushed or deleted before merge, plan content is unrecoverable — preserve the implementation branch ref until merge if forensic recovery matters.

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
- Lifecycle mishandling — ephemeral artifacts surviving into main (Step 3.5 didn't fire), gitignored ephemeral artifacts (causes citation rot at commit time), or new artifact categories shipped without a lifecycle row in `artifact-placement.md`. See [`gotchas/plans-as-run-scaffolding.md`](../gotchas/plans-as-run-scaffolding.md).

## Substrate map

Once `docs/substrate/` has ≥3 artifacts, add `docs/substrate/SUBSTRATE-MAP.md` indexing them and linking to relevant `docs/history/` entries. Use the template at `${CLAUDE_PLUGIN_ROOT}/references/templates/substrate-map.md`.
