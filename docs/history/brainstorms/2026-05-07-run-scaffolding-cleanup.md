# Brainstorm — run-scaffolding cleanup (PR artifact lifecycle)

### Current scope

Reduce Cohesive's PR artifact bloat by distinguishing **durable decision records** (worth persisting in main) from **ephemeral run scaffolding** (load-bearing during the implementation pass, valueless after merge). Apply the distinction in `implement-cohesively` and adjacent skills.

Evidence — pinky PR #175 (https://github.com/Uniswap/pinky/pull/175): 43 files / +4399 / -319, of which ~2832 lines (64% of additions) are `docs/history/` + `docs/cohesive/` artifacts. Phase plans alone are 2451 lines (1230 + 730 + 491 across three phases). Substrate that actually outlives this PR (spec edits, CLAUDE.md cross-link, incident postmortem) is ~280 lines.

### Future pressure (not current scope)

- Per-phase `delta-coverage-reviewer` verdicts are currently chat-only; future-pressure says they will eventually persist as files for cross-session resume and audit. The lifecycle convention should pre-classify them as ephemeral so future persistence doesn't reintroduce bloat.
- Cross-session resumption of an in-flight `implement-cohesively` run needs plan files on disk during the run — preserved by the strip-at-handoff design (cleanup only fires on Phase 3 Pass).
- Multi-pass implementation (a `design/<slug>` branch with multiple resume cycles) accumulates per-phase plans across passes; cleanup at final handoff drops them all, regardless of pass count.

### Non-goals

- Changing what artifacts exist. The chain still produces brainstorm → ledger → validation → plans → final review; only their persistence destinations change.
- Changing the audience seam. Substrate-shape vs decision-shape rendering remains; the seam is orthogonal to lifecycle.
- Changing how reviewer agents consume artifacts. Paths-only fresh-eyes dispatch holds — plans must exist on disk during the run.
- Touching durable artifacts. Brainstorm, delta ledger, validation review, and final substrate review keep their current persistence paths and contracts.

## Design options

### Option A: Gitignore ephemeral artifacts

**Summary:** Add `.gitignore` patterns matching `docs/history/plans/*-phase-*.md`, `docs/cohesive/discovery/<slug>.md`, and (when persisted) per-phase reviewer verdict files. Files exist on disk during the run; never tracked by git.

**Substrate changes required:**
- `docs/substrate/conventions/substrate-layout.md` §"Skill behavior" — add gitignore rule for ephemeral subdirs.
- `IMPLEMENTATION_PLAN_COVERS_DELTA` review checklist item #3 — change "Is every phase's plan persisted under `docs/history/plans/`?" to "Is every phase's plan persisted *during the run*?" The "after merge" check disappears.
- A new gotcha doc explaining that plan-path citations in commit messages are intentionally never-tracked references.

**Locality impact:** None — reviewer agents still read from `docs/history/plans/` paths during the run.

**Future fit:** Easy: future ephemeral artifacts (per-phase verdicts) extend the gitignore. Hard: forensic recovery of pre-cleanup plan content — plans were never in git at all, so `git log --all` cannot recover them.

**Initial risks:**
- **Citation rot at commit time.** Per-phase commit messages cite plan paths that `git show <commit>` cannot resolve — the file was never tracked. Future readers running `git log -p docs/history/plans/<slug>-phase-*.md` find nothing.
- **Existing-repo migration.** Repos like pinky have plans already committed. A bulk-cleanup PR is needed; no automatic recovery.

### Option B: Strip-at-handoff

**Summary:** Plans, discovery reports, and (future) per-phase reviewer verdicts are committed during the implementation pass on the `design/<slug>` branch. After Phase 3 (final substrate review Pass) and before Step 4 (handoff), `implement-cohesively` runs a `git rm <ephemeral paths> && git commit -m "implement: clean up phase scaffolding for <slug>"` step. The cleanup commit is part of the branch history; main's tree carries no ephemeral artifacts after merge.

**Substrate changes required:**
- `substrate-layout.md` §"The split" — add "Lifecycle: durable vs ephemeral" axis to the existing canonical/historical split.
- `artifact-placement.md` — add Lifecycle column to the cells matrix (durable artifacts persist permanently; ephemeral get the Cleanup-at-handoff treatment).
- `IMPLEMENTATION_PLAN_COVERS_DELTA` §"Enforcement" + §"Review checklist" — durable audit citation is the delta-entry stable ID; plan path is pre-cleanup branch-history pointer.
- `implement-cohesively` SKILL.md — new "Phase 3.5: Strip implementation scaffolding" between Phase 3 and Step 4; new Hard constraint enumerating when cleanup fires (Implemented only — not Phase Drift / Substrate Drift / Aborted).
- New gotcha `plans-as-run-scaffolding.md` — explains main-tree as decision-shape; branch as implementation-pass-shape.
- `handoffs.md` §"implement-cohesively → finishing-a-development-branch (Implemented)" — note the cleanup commit precedes the handoff.

**Locality impact:** Reviewer agents still read plan paths during the run (no change). After cleanup, the branch's pre-cleanup commits remain accessible via `git log --all`; reviewers running on the post-merge main tree do not see plans, but no reviewer is supposed to (the per-phase reviewer ran during the run, the final review captured cohesion before cleanup).

**Future fit:** Easy: discovery reports and per-phase verdicts extend the cleanup list trivially. Hard: forensic readers in main need to know the branch is the audit surface — the new gotcha doc carries this pedagogy.

**Initial risks:**
- **Citation in main looks dangling.** Per-phase commit messages cite plan paths absent from main's tree. Mitigation: (a) stable IDs co-cited; (b) the cleanup commit body lists removed paths verbatim, serving as the breadcrumb.
- **Squash-merge interaction.** When the user squash-merges, plan-add and plan-remove commits collapse into one; net diff is zero, plans don't appear in the squashed PR. This is actually the desired outcome (smaller PR, plans recoverable from branch history pre-squash).
- **Aborted-state half-cleanup.** If user aborts mid-run, plans remain on disk. Acceptable — the next pass either resumes (plans still useful) or the user discards the worktree (plans go with it).

### Option C: Collapse the four durable artifacts into one Design Record

**Summary:** Brainstorm + delta ledger + validation review + final substrate review all merge into a single `docs/history/design-records/<YYYY-MM-DD>-<slug>.md` file with sections (`## Brainstorm`, `## Delta ledger`, `## Validation review`, `## Final substrate review`). Each producing skill writes/appends its section to the same file. Ephemeral artifacts (plans, discovery, per-phase verdicts) handled separately — option C is orthogonal to the strip-at-handoff question.

**Substrate changes required:**
- Major schema redesign across four producing skills. Each must learn to read the prior sections (validate-rewrite reads the Brainstorm and Delta-ledger sections; implement-cohesively reads Brainstorm + Ledger + Validation).
- `validate-rewrite` Hard constraint #1 path-prereq: now a single path with section anchors instead of a delta-ledger path.
- `implement-cohesively` Hard constraint #1: same — single path, multi-section.
- `delta-coverage-reviewer` agent prompt: now must extract the delta-ledger section from a multi-section file rather than reading a delta-ledger file directly.
- Concurrency: when `validate-rewrite` runs in a separate worktree (its convention), the design-record file's prior sections must merge cleanly with the validation section.

**Locality impact:** Significant. The 1-skill-1-artifact dispatch contract documented in `handoffs.md` (each per-handoff contract names a discrete artifact) becomes 4-skills-1-file. Section anchors become load-bearing for fresh-eyes dispatches.

**Future fit:** Hard: every future skill addition that participates in the chain must learn the design-record schema. Future iterations would want to revert.

**Initial risks:**
- **Breaks paths-only fresh-eyes dispatch.** Reviewer agents currently take a single path; section anchors require the agent to do positioned-read-with-context, which weakens the fresh-eyes property.
- **Concurrency under worktrees.** Spec rewrites happen in worktrees per `superpowers:using-git-worktrees`. Multiple sections in one file cause merge conflicts that didn't exist with separate files.
- **Save savings are minimal.** The four durable artifacts in pinky #175 total ~381 lines / 9% of additions. Collapse saves at most 50–100 lines via deduplicated frontmatter — not the bloat surface.

## Pressure test summary

| Option | Cohesion | Substrate delta | Future fit | Locality | Main risk |
|---|---:|---|---|---|---|
| A. Gitignore | Med | Small (gitignore + checklist edit + 1 gotcha) | Hard for forensic recovery | None | Citation rot at commit time |
| B. Strip-at-handoff | High | Medium (layout + matrix + invariant + skill step + gotcha + handoffs) | Extends cleanly to per-phase verdicts | Branch is audit surface for plans | Forensic readers in main need pedagogy |
| C. Collapse durable | Low | Large (4 skills rewire) | Compounds cost | Section anchors weaken fresh-eyes | Minimal bloat reduction; high coordination cost |

## Breakage analysis

### Option B (recommended)

- **Docs that would change:** `substrate-layout.md`, `artifact-placement.md`, `IMPLEMENTATION_PLAN_COVERS_DELTA.md`, `implement-cohesively/SKILL.md`, `handoffs.md`. New: `plans-as-run-scaffolding.md` gotcha.
- **Existing assumptions that break:** "Every artifact in `docs/history/` persists in main." This was implicit, never named — the rewrite makes the lifecycle split explicit.
- **Behavior matrix impact:** `artifact-placement.md` gets a new Lifecycle column (durable / ephemeral). Existing cells stay valid; the column adds a per-artifact-category classification.
- **Invariant impact:** `IMPLEMENTATION_PLAN_COVERS_DELTA` review checklist item #3 changes from "plan persisted under `docs/history/plans/`" to "plan persisted during the run; cleaned at handoff if Phase 3 Pass." Item #4 (commit message cites plan path AND delta-entry stable IDs) tightens — stable IDs are the durable citation, plan paths are pre-cleanup branch-history pointers.
- **Test guarantee impact:** No test changes; the invariant's enforcement path is reviewer judgment (the deferred CI grep shifts target from plan paths to delta-entry stable IDs when it ships).
- **Gotchas triggered:** New gotcha `plans-as-run-scaffolding.md`. Existing `no-implementation-handoff.md` unchanged — the closure path still holds, just via stable IDs instead of plan paths.
- **Locality / centralization concerns:** None. Cleanup is local to `implement-cohesively`'s phase loop.
- **Easy invalid change still possible:** Yes — a contributor could add a new ephemeral artifact type without registering it in the cleanup list, leaving it in main's tree. Mitigation: `artifact-placement.md`'s Lifecycle column makes the classification explicit at artifact-introduction time; reviewer attention during `cohesive:review-codebase` catches drift.

## Recommendation

**Direction:** Strip-at-handoff (Option B). Ephemeral artifacts (per-phase plans, discovery reports, per-phase reviewer verdicts when they persist) live on the `design/<slug>` branch during the implementation pass. Between Phase 3 (final substrate review Pass) and Step 4 (handoff), `implement-cohesively` runs a cleanup commit (`git rm` + commit) removing ephemeral paths. Main's tree carries only durable decision records.

**Main risk:** Per-phase commit messages cite plan paths that don't exist in main after merge. A reader running `git log -p docs/history/plans/<slug>-phase-*.md` on main finds nothing.

**Structural mitigation:**
- **Delta-entry stable IDs become the durable citation.** Per-phase commits cite both plan path and delta-entry stable IDs (per `IMPLEMENTATION_PLAN_COVERS_DELTA` Phase 2d). Stable IDs survive cleanup; plan paths are explicitly redesignated as branch-history pointers.
- **The cleanup commit message body lists removed paths verbatim.** A reader following the audit trail in main sees the cleanup commit, knows plans existed pre-cleanup, runs `git log --all -- docs/history/plans/<slug>-*.md` to recover them from branch history.
- **Cleanup is gated, not unconditional.** Fires only on Phase 3 Pass (Implemented verdict). On Phase Drift / Substrate Drift / Aborted, plans remain — they're load-bearing for the next attempt or post-mortem.

**Required substrate before implementation:**
- **Specs:** `docs/substrate/conventions/substrate-layout.md` (add lifecycle axis); `docs/substrate/architecture/handoffs.md` (note cleanup commit on Implemented handoff).
- **Matrices:** `docs/substrate/matrices/artifact-placement.md` (add Lifecycle column).
- **Named invariants:** `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` (tighten audit-citation rule, update review checklist items #3 and #4).
- **Tests / checks:** No new tests. The deferred CI grep target shifts from plan paths to delta-entry stable IDs.
- **Gotchas:** `docs/substrate/gotchas/plans-as-run-scaffolding.md` (new) — main-tree-as-decision-record pedagogy.
- **Skill body:** `skills/implement-cohesively/SKILL.md` (new Phase 3.5: Strip implementation scaffolding; new Hard constraint on cleanup-fires-on-Implemented-only; trailer's Branch state surfaces cleanup commit SHA).
- **Semantic linters (proposed):** None for v0.1. A future linter could enforce that newly-added artifact paths declare a lifecycle in `artifact-placement.md` before merge.

### Next

Rewrite the docs to make this direction true. *(`cohesive:rewrite-specs`.)* **Files to edit:**
- `docs/substrate/conventions/substrate-layout.md` — §"The split" extended with "Lifecycle: durable vs ephemeral"; §"Skill behavior" adds the cleanup-at-handoff convention for ephemeral artifacts.
- `docs/substrate/matrices/artifact-placement.md` — Lifecycle column added to §"Cells"; ephemeral row category for plans/discovery/per-phase verdicts.
- `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` — §"Enforcement" + §"Review checklist" tightened: stable IDs are durable citation, plan paths are branch-history pointers; checklist item #3 reflects strip-at-handoff.
- `skills/implement-cohesively/SKILL.md` — new "Phase 3.5: Strip implementation scaffolding" between Phase 3 and Step 4; Hard constraint on cleanup gating (Implemented only); trailer Branch state surfaces cleanup commit SHA.
- `docs/substrate/gotchas/plans-as-run-scaffolding.md` — new gotcha doc.
- `docs/substrate/architecture/handoffs.md` — §"implement-cohesively → finishing-a-development-branch (Implemented)" notes the cleanup commit precedes handoff.

Slug: `run-scaffolding-cleanup`. Classification: Mixed (substrate convention + invariant tightening + skill-body process step + new gotcha).
