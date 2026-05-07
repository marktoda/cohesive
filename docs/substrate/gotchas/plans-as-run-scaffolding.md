# Gotcha: per-phase plans are run scaffolding, not decision records

> Per-phase implementation plans (`docs/history/plans/<YYYY-MM-DD>-<slug>-phase-<N>.md`) and discovery reports (`docs/cohesive/discovery/<slug>.md`) look like permanent audit-trail artifacts because they live under `docs/history/` alongside brainstorms, delta ledgers, and validation reviews. They are not. They are **run scaffolding** — load-bearing during the implementation pass, cleaned up at handoff. The branch is the audit surface for plan content; main's tree carries only durable decision records.

## Symptom

A reader on `main` runs `git log -p docs/history/plans/<slug>-phase-*.md` after a Cohesive-driven feature has merged. They expect to find the per-phase plans the implementation cited. They find nothing. The plans appear to have been deleted, but the per-phase commit messages on the merge cite plan paths as if they were durable artifacts.

A second symptom, observable at PR-review time: PRs produced by `cohesive:implement-cohesively` are dominated by ephemeral artifacts. Pinky PR #175 (https://github.com/Uniswap/pinky/pull/175) was 43 files / +4399 / -319, of which 2451 lines (56% of additions) were three phase plans. The actual substrate change (spec edits + invariants + incident postmortem) was ~280 lines. The reviewer's eye landed on the wrong surface.

## Why it happened

`docs/history/` was originally introduced as a single dated-append-only bucket: reviews, plans, delta-ledgers, brainstorms, transcripts. Every artifact in `docs/history/` carried the same lifecycle by default — once committed, it persisted forever. The convention worked for the first four artifact categories because each captures a load-bearing decision (the architecture review, the rewritten design, the brainstorm's chosen direction, the validation verdict).

Plans broke the symmetry. They are produced by `superpowers:writing-plans` once per phase, consumed by the `delta-coverage-reviewer` agent during cross-review, and carry no value after the phase passes. The phase commit cites the plan path *and* the delta-entry stable IDs (per `IMPLEMENTATION_PLAN_COVERS_DELTA` Phase 2d), but only the stable IDs survive the implementation pass as durable claims about what landed. The plan itself is a TDD scratchpad — a transcript of what was about to be done, not a record of what was decided.

Discovery reports fit the same pattern: produced by `cohesive:discover-substrate` as an internal sub-step of `brainstorm-design` / `audit-substrate` / `review-codebase` / `review-diff`, consumed once by the dispatching skill, superseded by the dispatching skill's chat trailer. The report is a within-run substrate inventory; the consumer skill's output is what the user reads and acts on.

The `docs/history/` lifecycle convention had no axis to express the difference. Every artifact persisted by default; the bloat compounded silently across implementation passes.

## Tempting wrong fix

`.gitignore docs/history/plans/*-phase-*.md` and `.gitignore docs/cohesive/discovery/`. The plans and discovery reports stop appearing in PRs immediately. The bloat goes away.

This is wrong because it produces **citation rot at commit time**. Per-phase commit messages cite plan paths (per `IMPLEMENTATION_PLAN_COVERS_DELTA` Phase 2d). With plans gitignored, the file was never tracked: `git show <phase-commit>` cannot resolve the cited path; `git log -p docs/history/plans/<slug>-phase-*.md` returns nothing even when run *during* the implementation pass on the local branch. The audit surface becomes "the plan exists on disk locally and only locally," which means a fresh worktree of the same branch does not have the plans the commit messages cite. The `IMPLEMENTATION_PLAN_COVERS_DELTA` review-checklist item #3 ("plan persisted") fails immediately, not just after merge.

## Correct pattern

**Strip-at-handoff.** Plans live as committed artifacts on the `design/<slug>` branch during the implementation pass — the per-phase commit creates them, the `delta-coverage-reviewer` agent reads them via `Read` tool against a tracked path, and `git show <phase-commit>` resolves the cited plan path correctly throughout the run. After Phase 3 (final substrate review) returns Pass, `cohesive:implement-cohesively` Phase 3.5 runs:

```bash
git rm docs/history/plans/<YYYY-MM-DD>-<slug>-phase-*.md
git rm docs/cohesive/discovery/<slug>.md  # if present
git commit -m "implement: clean up phase scaffolding for <slug>

Removed:
- docs/history/plans/<YYYY-MM-DD>-<slug>-phase-1.md
- docs/history/plans/<YYYY-MM-DD>-<slug>-phase-2.md
- ...

Branch history before this commit retains the plans for forensic recovery
via 'git log --all -- docs/history/plans/<slug>-phase-*.md'.
"
```

After cleanup and merge, main's tree carries only durable artifacts (brainstorm, delta ledger, validation review, final substrate review). The per-phase commits in main's history still cite plan paths; a forensic reader running `git log --all -- docs/history/plans/<slug>-phase-*.md` recovers the plans from the pre-cleanup branch history.

The cleanup is **gated, not unconditional**. It fires only when Phase 3 returns Pass / Pass with notes (Implemented verdict). On Phase Drift / Substrate Drift / Aborted, plans remain — they are load-bearing for the next attempt or the post-mortem.

The durable-vs-ephemeral classification across all `docs/history/` artifacts is named in [`docs/substrate/matrices/artifact-placement.md`](../matrices/artifact-placement.md) §"Lifecycle by artifact category"; the cleanup convention is named in [`docs/substrate/conventions/substrate-layout.md`](../conventions/substrate-layout.md) §"Lifecycle: durable vs ephemeral".

## Related invariant

- Invariant: `IMPLEMENTATION_PLAN_COVERS_DELTA` — the durable audit citation is the **delta-entry stable ID** appearing in the phase commit message; the plan path is the **pre-cleanup branch-history pointer**. Both are required at commit time; only the stable ID survives in main after Phase 3.5 cleanup. See [`IMPLEMENTATION_PLAN_COVERS_DELTA.md`](../invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md) §"Enforcement" and §"Review checklist".

## Tests / checks that preserve this

- `cohesive:implement-cohesively` Phase 3.5 — the structural pin. The skill body refuses to advance to Step 4 (Hand off) without producing the cleanup commit when Phase 3 returned Pass. See [`skills/implement-cohesively/SKILL.md`](../../../skills/implement-cohesively/SKILL.md) §"Phase 3.5. Strip implementation scaffolding".
- `cohesive:review-codebase` structure-reviewer — flags any `design/<slug>` or `implement/<slug>` branch that merges without a cleanup commit, or any cleanup commit that fires on a non-Implemented verdict.
- The cleanup-commit message body lists removed paths verbatim; this is the breadcrumb a forensic reader follows back to branch history. A cleanup commit without a verbatim removed-paths list is a violation.

## When this was discovered

- Date: 2026-05-07
- Incident or PR: Brainstorm `docs/history/brainstorms/2026-05-07-run-scaffolding-cleanup.md` against pinky PR #175 evidence
- One-line summary: Cohesive's implementation passes were producing PRs where 60%+ of additions were process scaffolding, not substrate change; the lifecycle convention had no axis to distinguish run scaffolding from decision records.

## Notes for future contributors

The audience seam in [`audience-separation.md`](../conventions/audience-separation.md) is about **render surfaces** (chat vs persisted file). This gotcha is about **persistence surfaces** (main vs branch). They are orthogonal: a durable artifact (delta ledger) is rendered in substrate-shape on its persisted file *and* persists in main; an ephemeral artifact (plan) is rendered in substrate-shape on its persisted file *and* gets cleaned up before main. The render seam stays at the chat trailer; the persistence seam lives in the cleanup commit.

When adding a new artifact category to Cohesive, classify its lifecycle in [`artifact-placement.md`](../matrices/artifact-placement.md) §"Lifecycle by artifact category" before merging the skill that produces it. Default to **durable** when ambiguous — the cost of an ephemeral artifact reclassified as durable later is one PR; the cost of a durable artifact discovered to need cleanup later is reviewer attention across every prior implementation pass.

Per-phase `delta-coverage-reviewer` verdicts are currently chat-only (no file persistence). When they promote to file persistence, they ship as **ephemeral** by construction — same lifecycle as the plans they verdict on.
