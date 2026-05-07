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

Within `docs/history/`, artifacts split along a second axis: **durable decision records** persist permanently in main; **ephemeral run scaffolding** lives on the implementation branch during the run and is cleaned up at handoff. The split is structural — every artifact category has exactly one lifecycle, defined cell-by-cell in [`docs/substrate/matrices/artifact-placement.md`](../matrices/artifact-placement.md) §"Lifecycle by artifact category".

| Lifecycle | Categories | Persistence after merge |
|---|---|---|
| **Durable** | brainstorms, delta-ledgers, reviews (architecture, audit, validation, final substrate review), transcripts | Permanent in main |
| **Ephemeral** | per-phase plans, discovery reports, per-phase reviewer verdicts (when persisted) | Stripped at handoff; recoverable from pre-cleanup branch history via `git log --all` |

A durable artifact captures a load-bearing decision that explains *why* the system has its current shape — the chosen direction (brainstorm), the contract the implementation honors (delta ledger), the verdict on whether it succeeded (validation review, final substrate review). An ephemeral artifact is run scaffolding — load-bearing during the implementation pass for cross-review fresh-eyes dispatch and TDD execution, valueless after the final substrate review passes.

The cleanup convention for ephemeral artifacts is named in §"Cleanup at handoff" below; it fires only on `cohesive:implement-cohesively` Phase 3 Pass (Implemented verdict). On Phase Drift / Substrate Drift / Aborted, ephemeral artifacts persist on the branch — they are load-bearing for the next attempt or the post-mortem.

The lifecycle axis is orthogonal to the audience seam in [`docs/substrate/conventions/audience-separation.md`](audience-separation.md): the audience seam governs **render surfaces** (chat vs persisted file); the lifecycle axis governs **persistence surfaces** (main vs branch). A durable artifact is rendered in substrate-shape on its persisted file *and* persists in main; an ephemeral artifact is rendered in substrate-shape on its persisted file *and* is cleaned up before main. See [`docs/substrate/gotchas/plans-as-run-scaffolding.md`](../gotchas/plans-as-run-scaffolding.md) for the failure mode this convention prevents.

## Why the split

Mixing canonical and historical content in one directory produces the pain Cohesive was designed to fix: you can never tell whether a doc is current or stale. The canonical/historical split makes it structural — `docs/substrate/X` is current *by location*. A reader doesn't have to read the file to know its lifecycle.

The durable/ephemeral split inside `docs/history/` extends the same principle: a reader on `main` who sees a `docs/history/plans/` directory should know by convention that any plan there is *durable history* (a permanent record), not run scaffolding from an unfinished pass. The cleanup-at-handoff structural enforcement guarantees that.

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
4. **Honor the lifecycle classification.** When creating an ephemeral artifact, write it under `docs/history/<category>/` exactly as for a durable artifact — the file path is shared. The lifecycle distinction is enforced by the cleanup-at-handoff step, not by directory choice. A skill that introduces a new artifact category classifies its lifecycle in [`docs/substrate/matrices/artifact-placement.md`](../matrices/artifact-placement.md) §"Lifecycle by artifact category" *before* the skill ships.

Cohesive skills reading substrate (`discover-substrate`, `review-codebase`, `review-diff`, `audit-substrate`, `validate-rewrite`):

- Read this layout if present
- Read existing repo conventions otherwise
- If both exist, treat the existing one as authoritative and flag the duplication for cleanup

## Cleanup at handoff

Ephemeral artifacts are committed during the implementation pass on the `design/<slug>` branch — `superpowers:writing-plans` writes per-phase plans to `docs/history/plans/`, `cohesive:discover-substrate` writes discovery reports to `docs/cohesive/discovery/`, and per-phase commits cite plan paths per the `IMPLEMENTATION_PLAN_COVERS_DELTA` invariant. The fresh-eyes `delta-coverage-reviewer` agent reads plan paths during cross-review; the citation surface is alive throughout the run.

After Phase 3 (final substrate review) returns Pass / Pass with notes, `cohesive:implement-cohesively` Phase 3.5 strips ephemeral artifacts:

```bash
git rm docs/history/plans/<YYYY-MM-DD>-<slug>-phase-*.md
git rm docs/cohesive/discovery/<slug>.md  # if present
git commit -m "implement: clean up phase scaffolding for <slug>

Removed:
- docs/history/plans/<YYYY-MM-DD>-<slug>-phase-1.md
- ...

Branch history before this commit retains the plans for forensic recovery
via 'git log --all -- docs/history/plans/<slug>-phase-*.md'.
"
```

The cleanup commit is the **breadcrumb back from main to branch history**. A reader on main running `git log -- docs/history/plans/<slug>-phase-*.md` sees nothing in the current tree but finds the cleanup commit; the commit body lists the removed paths verbatim; `git log --all -- docs/history/plans/<slug>-phase-*.md` recovers the plans from pre-cleanup branch history.

Cleanup is **gated, not unconditional**: it fires only on Implemented verdict. On Phase Drift / Substrate Drift / Aborted, ephemeral artifacts remain on the branch — see [`skills/implement-cohesively/SKILL.md`](../../../skills/implement-cohesively/SKILL.md) §"Phase 3.5. Strip implementation scaffolding" for the gating rules and the per-verdict behavior.

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
- Ephemeral artifacts (per-phase plans, discovery reports) surviving into main — Phase 3.5 cleanup didn't fire, or fired on the wrong verdict; the branch merged with run scaffolding still in the tree. See [`docs/substrate/gotchas/plans-as-run-scaffolding.md`](../gotchas/plans-as-run-scaffolding.md).
- New artifact category shipped without lifecycle classification in `artifact-placement.md` §"Lifecycle by artifact category" — the cleanup pattern can't apply because the category isn't classified; bloat compounds silently across implementation passes.
- Gitignoring ephemeral artifacts to suppress PR bloat — produces citation rot at commit time; the file is never tracked, so `git show <phase-commit>` cannot resolve cited plan paths and `IMPLEMENTATION_PLAN_COVERS_DELTA` review-checklist item #3 fails immediately. Use cleanup-at-handoff instead.

## Substrate map

Once `docs/substrate/` has ≥3 artifacts, add `docs/substrate/SUBSTRATE-MAP.md` indexing them and linking to relevant `docs/history/` entries. Use the template at `${CLAUDE_PLUGIN_ROOT}/references/templates/substrate-map.md`.
