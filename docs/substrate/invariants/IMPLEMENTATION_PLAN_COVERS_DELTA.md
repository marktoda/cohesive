# IMPLEMENTATION_PLAN_COVERS_DELTA

> Every entry in a design delta ledger is covered by the single implementation plan that lands code against that ledger and is verified by end-of-run dual reviewer dispatch. The plan persists during the run as ephemeral run scaffolding (`docs/history/plans/<YYYY-MM-DD>-<slug>.md`) and is cleaned up at post-implementation cleanup on Implemented verdict. Implementation commits cite both the plan path (resolves during the run; recoverable via `git log --all` after cleanup) and the delta-entry stable IDs (the citation that survives cleanup in main). Coverage is structural via the dual reviewer gate, not aspirational.

## Rule

For every Cohesive implementation pass driven by `cohesive:implement-cohesively`:

1. Every entry in the design delta ledger (every Files-rewritten entry, every Files-added entry, every Conceptual-change row, every Named-invariant entry, every Behavior-matrix entry, every Gotcha entry, every Tests-proposed entry — excluding entries explicitly marked Deferred) is covered by the single implementation plan authored by `superpowers:writing-plans` from the thin intent paragraph the skill composes (delta-entry stable IDs + named invariants the change touches + dual-reviewer acceptance criteria).
2. The plan persists at `docs/history/plans/<YYYY-MM-DD>-<slug>.md` (singular path; no per-phase suffix), committed during the run on the `design/<slug>` (or `implement/<slug>`) branch as part of the implementation commit sequence. The end-of-run `delta-coverage-reviewer` dispatch reads the tracked path. The plan is **ephemeral** per [`docs/substrate/matrices/artifact-placement.md`](../matrices/artifact-placement.md) §"Lifecycle by artifact category" and is cleaned up at post-implementation cleanup on Implemented verdict.
3. Implementation commits on the branch cite both the plan path and the delta-entry stable IDs they implement. After post-implementation cleanup, the stable IDs remain greppable in main; the plan path is recoverable via `git log --all` from branch history.
4. The implementation pass ends with **parallel dispatch** of two reviewers against the branch: `delta-coverage-reviewer` (whole-branch input contract; verifies every claimed delta entry maps to a diff hunk) and `cohesive:review-diff` (substrate alignment against the rewritten specs). The verdict is synthesized AND-shape: both Pass → Implemented; coverage fail only → Coverage Drift; substrate fail only → Substrate Drift; both fail → Substrate Drift wins.
5. On Implemented verdict, post-implementation cleanup strips ephemeral artifacts via a single cleanup commit whose body lists removed paths verbatim, before handoff to `superpowers:finishing-a-development-branch`. On Coverage Drift / Substrate Drift / Aborted, post-implementation cleanup does not fire — ephemeral artifacts remain on the branch for the next attempt or post-mortem.

If any of points 1–5 fail, the implementation pass is non-compliant and substrate has drifted.

A "run" spans the skill's Step 0 input resolution through the end-of-run reviewer synthesis, independent of Claude session boundary. The plan persists on the branch across session disconnects; the run terminates on the synthesized verdict, not on session disconnect. Re-entering on `design/<slug>` in a later session resumes against the same plan; the ephemeral plan the prior session committed is still load-bearing for `delta-coverage-reviewer` dispatch when the run completes.

## Scope

### Applies to

- Every invocation of `cohesive:implement-cohesively`
- Every branch produced by an `implement-cohesively` invocation — the default `design/<slug>` branch (rewrite + implementation on one branch) and the alternative `implement/<slug>` child branch (per `implement-cohesively`'s "Branch shape" section) are both in scope
- The single per-pass plan persisted under `docs/history/plans/`
- Every implementation commit on a `design/<slug>` or `implement/<slug>` branch produced by an `implement-cohesively` invocation

### Does not apply to

- Branches produced by `superpowers:writing-plans` + `superpowers:executing-plans` invoked directly (without `implement-cohesively`). Those branches use Superpowers' generic plan shape; this invariant is about delta-derived plan shape specifically.
- Hotfix branches that don't have a corresponding rewrite. There is no delta to cover.
- Documentation-only branches (e.g., `rewrite-specs` output). The delta ledger is the *output* of those branches, not their input.

Explicit non-applicability matters: a future contributor running `superpowers:writing-plans` directly is not in violation of this invariant — they're using a different workflow with a different shape. The invariant is scoped to `implement-cohesively`.

## Why this matters

The failure mode this invariant prevents is documented in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/no-implementation-handoff.md`: an implementation pass that drifts from the rewrite it was supposed to land. The drift is silent — code merges, tests pass, the branch looks healthy — but the substrate the rewrite established is not actually pinned in the running system. A future change predicated on the substrate then has nothing to break against.

Coverage is the prevention. The single plan is held against the delta ledger by the end-of-run `delta-coverage-reviewer` dispatch; substrate alignment is held against the rewritten specs by the parallel `cohesive:review-diff` dispatch. Both must pass for Implemented. An entry cannot silently fall off the implementation pass — the dual reviewer gate either confirms coverage or names the gap.

This is the third named invariant Cohesive ships, joining `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` and `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`. It earns invariant status because (a) the rule has a concrete structural failure mode (silent substrate drift), (b) the enforcement path is explicit (single plan + end-of-run dual reviewer dispatch + AND-shape synthesis), and (c) regressions have a real cost (rewrite-then-implement is expensive; failures should not hide).

## Runtime paths

Every place this invariant must hold:

- **`cohesive:implement-cohesively` Steps 0–4.** Step 0 resolves inputs (validate-rewrite Approved verdict path + delta ledger path + branch). Step 1 composes the thin intent paragraph from the delta ledger and dispatches `superpowers:writing-plans`. Step 2 dispatches `superpowers:executing-plans` against the persisted plan. Step 3 dispatches `delta-coverage-reviewer` and `cohesive:review-diff` in parallel and synthesizes the verdict AND-shape. Step 3.5 (post-implementation cleanup) strips ephemeral artifacts on Implemented verdict only, via a cleanup commit whose body lists removed paths verbatim. Step 4 hands off.
- **`docs/history/plans/<YYYY-MM-DD>-<slug>.md`.** The plan persists on the branch from the implementation-commit sequence that creates it through post-implementation cleanup. A branch with implementation commits but no plan on the tree is a violation. After cleanup, the plan is absent from main's tree but recoverable via `git log --all` from branch history.
- **Implementation commit messages.** Each implementation commit cites both the plan path and the delta-entry stable IDs it implements. After post-implementation cleanup, the stable IDs remain greppable in main; plan paths are pre-cleanup branch-history references. Both branch shapes (`design/<slug>` and `implement/<slug>`) are in scope.
- **Delta-size budget gate.** Step 1 surfaces the delta-entry count before invoking `superpowers:writing-plans`; when the count exceeds **15** (default; tunable in a follow-up substrate change), the skill pauses for user confirmation. The gate is the structural mitigation for mega-plan abandonment risk per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/large-delta-mega-plan.md`.

## Enforcement

- **Skill-body acceptance criteria:** `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md` Hard constraints require single-plan coverage, end-of-run dual reviewer dispatch, AND-shape verdict synthesis, and gated post-implementation cleanup. The skill refuses to advance past Step 1 with uncovered delta entries (the thin intent paragraph enumerates them) and refuses to declare Implemented without both reviewers returning Pass.
- **Reviewer agent verdicts:** `${CLAUDE_PLUGIN_ROOT}/agents/delta-coverage-reviewer.md` returns Covered / Drift / Incomplete against the whole-branch diff. `cohesive:review-diff` returns Pass / Pass with notes / Needs substrate / Risky / Block. The skill body's verdict-synthesis subsection enumerates the combinations; only `Covered + (Pass | Pass with notes)` synthesizes to Implemented.
- **Plan persistence:** `superpowers:writing-plans` writes the plan to disk during Step 1; the implementation-commit sequence in Step 2 tracks it on the branch. The plan cannot exist only in conversation.
- **Post-implementation cleanup gating:** cleanup fires only on Implemented verdict; the cleanup commit body must list removed paths verbatim. Both rules are violations otherwise.

The deferred CI grep target is the delta-entry stable ID form (the citation that survives cleanup and remains greppable in main); promotion follows the existing convention-with-grep pattern.

## Known bypass risks

- **A user invokes `superpowers:writing-plans` directly after `validate-rewrite` Approved**, bypassing `implement-cohesively`. The invariant does not apply (per Scope). The user accepts that the implementation may drift from the rewrite. The `validate-rewrite` Approved footer's decision matrix names this as a legitimate option ("Implement with Superpowers directly") — conditionally rendered when the rewrite is small enough that the implement-cohesively flow would be ceremony per `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Conditional alternatives" — so the bypass is documented, not silent. The handshake is convention: when the user picks this alternative, `validate-rewrite`'s Output format renders the literal acknowledgment line `Implementing with plain Superpowers — Cohesive's verification of the rewrite doesn't apply. Run cohesive:review-diff after implementation to catch any drift.` in chat before invoking `superpowers:writing-plans`. The user-facing chat line names the verification entry point without surfacing the invariant token (per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2c — substrate-shape vocab stays out of chat); this invariant doc is the substrate-side record.
- **The thin intent paragraph drops a delta-entry stable ID.** If Step 1's intent-paragraph composition omits an entry that wasn't marked Deferred in the ledger, the resulting plan can't cover it and the end-of-run `delta-coverage-reviewer` flags Drift / Incomplete. Mitigated by: the skill body's Step 1 explicitly enumerates every non-Deferred entry from the ledger by stable ID; `cohesive:review-diff` at the end provides a second fence.
- **An implementation commit doesn't cite the plan or delta IDs.** No automated check catches this in v0.1; reviewer memory is the enforcement until the deferred CI grep ships. Mitigated by: `cohesive:review-codebase` includes commit-citation discipline as a structure-reviewer concern.
- **`writing-plans` is invoked but the produced plan is empty / trivial.** The end-of-run `delta-coverage-reviewer` flags Drift / Incomplete (plan-coverage agreement breaks). Mitigated by reviewer judgment.
- **Mega-plan abandonment on large deltas.** A delta with 30+ entries can produce a plan large enough that `executing-plans` runs out of context mid-execution. Mitigated by the delta-size budget gate (Step 1) per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/large-delta-mega-plan.md`; reviewer-judged escalation if the budget gate is set too high to fire when it should.

Naming bypasses is not weakness — it's substrate. Future contributors who encounter a bypass need to know whether it's tolerated, mitigated, or actively being closed.

## Review checklist

When reviewing a change to `implement-cohesively`, the `delta-coverage-reviewer` agent, or any branch produced by `implement-cohesively`:

- [ ] Does Step 1's thin intent paragraph enumerate every non-Deferred delta-ledger entry by stable ID?
- [ ] Is the per-pass plan committed during the run on the `design/<slug>` (or `implement/<slug>`) branch? (Plan present when end-of-run reviewers are dispatched.)
- [ ] Does every implementation commit cite both the plan path and the delta-entry stable IDs?
- [ ] Did `delta-coverage-reviewer` return Covered AND `cohesive:review-diff` return Pass / Pass with notes for the branch? (Both required for Implemented per AND-shape synthesis.)
- [ ] On Implemented verdict, did post-implementation cleanup produce a single cleanup commit with the removed paths listed verbatim in its body? On Coverage Drift / Substrate Drift / Aborted, did cleanup *not* fire?
- [ ] If the delta exceeded the size threshold, did Step 1 surface the count and pause for user confirmation before invoking `writing-plans`?
- [ ] If the bypass was taken (user chose direct `superpowers:writing-plans`), was the literal acknowledgment line rendered in the conversation transcript? (See §Known bypass risks.)

## Related

- `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md` — the skill that implements this invariant
- `${CLAUDE_PLUGIN_ROOT}/agents/delta-coverage-reviewer.md` — the end-of-run coverage reviewer (whole-branch input contract)
- `${CLAUDE_PLUGIN_ROOT}/skills/review-diff/SKILL.md` — the parallel substrate-alignment reviewer dispatched alongside delta-coverage-reviewer at end-of-run
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/artifact-placement.md` §"Lifecycle by artifact category" — the per-category lifecycle classification (singular per-pass plan)
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/plans-as-run-scaffolding.md` — the failure mode the cleanup-at-handoff pattern prevents
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/large-delta-mega-plan.md` — the mega-plan abandonment cliff and the size-budget gate that mitigates it
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/no-implementation-handoff.md` — the adjacent failure mode this invariant pins against

## History

- 2026-05-04 — Created. The structural pin behind `implement-cohesively`. Earned invariant status from day one because the rule has a concrete structural failure mode (silent substrate drift), an explicit enforcement path (per-phase coverage + per-phase reviewer + final substrate review *— per-phase at the time; reformulated to single-pass dual-reviewer dispatch on 2026-05-08; see entry below*), and a real cost on regression.
- 2026-05-04 — Repair pass 1 (post first validate-rewrite verdict): Step/Phase numbering reconciled with `implement-cohesively` SKILL body. §Scope and §Runtime paths extended to cover the alternative `implement/<slug>` child branch. §Known bypass risks specifies the acknowledgment-line handshake for the validate-rewrite decision matrix's bypass row.
- 2026-05-07 — Tightened the audit-citation distinction: durable citation is the **delta-entry stable ID** (survives cleanup); plan path is the **pre-cleanup branch-history pointer**. Added Rule #6 (cleanup gating, gated on Implemented verdict).
- 2026-05-08 — Single-pass redesign per the brainstorm at `docs/history/brainstorms/2026-05-08-implement-cohesively-single-pass.md`. Rules reformulated from phase-shaped (`every entry maps to ≥1 phase`; per-phase plan; per-phase cross-review) to single-pass-shaped (`every entry covered by the single plan`; one per-pass plan; end-of-run dual reviewer dispatch with AND-shape synthesis). The phase-derivation matrix and the skipping-per-phase-plan gotcha retire alongside this rewrite. The mega-plan abandonment cliff that the per-phase fence had implicitly mitigated is now named explicitly via `large-delta-mega-plan.md` and structurally mitigated via the Step 1 size-budget gate.
