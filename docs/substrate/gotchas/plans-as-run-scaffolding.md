# Gotcha: per-phase plans are run scaffolding, not decision records

> Per-phase plans (`docs/history/plans/<YYYY-MM-DD>-<slug>-phase-<N>.md`) and discovery reports (`docs/cohesive/discovery/<slug>.md`) live under `docs/history/` alongside brainstorms, delta ledgers, and validation reviews — but they are **run scaffolding**, not decision records. They are load-bearing during the implementation pass, cleaned up at handoff. The branch is the audit surface for plan content; main's tree carries only durable decision records.

## Symptom

A reader on main runs `git log -p docs/history/plans/<slug>-phase-*.md` after a Cohesive-driven feature has merged and finds nothing, even though per-phase commit messages cite plan paths. At PR-review time, Cohesive-driven PRs are dominated by ephemeral artifacts: pinky PR #175 was 43 files / +4399, of which 2451 lines (56%) were three phase plans against ~280 lines of actual substrate change.

## Why it happened

`docs/history/` was originally a single dated-append-only bucket where every artifact persisted forever. That convention worked for brainstorms, ledgers, and reviews — each captures a load-bearing decision. Plans broke the symmetry: they are TDD scratchpads consumed once by `delta-coverage-reviewer` during cross-review and valueless after the phase passes. The lifecycle convention had no axis to express the difference, so plan bloat compounded silently across implementation passes.

## Tempting wrong fix

`.gitignore docs/history/plans/*-phase-*.md`. The bloat goes away immediately, but the file is never tracked: `git show <phase-commit>` cannot resolve cited plan paths and `delta-coverage-reviewer` cannot read them on a fresh worktree of the same branch. Citation rot at commit time, not just after merge — `IMPLEMENTATION_PLAN_COVERS_DELTA` review-checklist item #3 fails immediately.

## Correct pattern

**Strip-at-handoff.** Plans are committed on the `design/<slug>` branch during the implementation pass; `cohesive:implement-cohesively` Phase 3.5 runs `git rm` on the ephemeral paths and produces a single cleanup commit on Implemented verdict only. The cleanup commit's body lists removed paths verbatim — this is the breadcrumb a forensic reader follows from main back to pre-cleanup branch history via `git log --all -- <pattern>`.

Cleanup is gated: it fires only on Phase 3 Pass / Pass with notes. On Phase Drift / Substrate Drift / Aborted, plans remain on the branch — load-bearing for the next attempt or post-mortem. Existing repos with plans already in main can clean them up via a single bulk `git rm` PR; the new convention applies prospectively.

See [`substrate-layout.md`](../conventions/substrate-layout.md) §"Cleanup at handoff" and [`artifact-placement.md`](../matrices/artifact-placement.md) §"Lifecycle by artifact category" for the convention and per-category classification.

## Related invariant

- Invariant: `IMPLEMENTATION_PLAN_COVERS_DELTA` — the phase commit cites the plan path *and* the delta-entry stable IDs; only the stable IDs remain greppable in main after Phase 3.5 cleanup. Plan paths are recoverable from branch history via `git log --all`. See [`IMPLEMENTATION_PLAN_COVERS_DELTA.md`](../invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md) Rule #3 and Rule #6.

## Tests / checks that preserve this

- `cohesive:implement-cohesively` Phase 3.5 — refuses to advance to Step 4 without producing the cleanup commit on Implemented verdict.
- `cohesive:review-codebase` structure-reviewer — flags branches that merged without a cleanup commit, or cleanup commits that fired on a non-Implemented verdict.
- A cleanup commit without a verbatim removed-paths list is a violation — the breadcrumb is structurally required.

## When this was discovered

- Date: 2026-05-07
- Incident or PR: Brainstorm `docs/history/brainstorms/2026-05-07-run-scaffolding-cleanup.md` against pinky PR #175 evidence
- One-line summary: Cohesive's implementation passes produced PRs where 60%+ of additions were process scaffolding, not substrate change.
