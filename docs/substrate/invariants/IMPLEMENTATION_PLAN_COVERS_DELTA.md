# IMPLEMENTATION_PLAN_COVERS_DELTA

> Every entry in a design delta ledger maps to at least one phase in the implementation pass that lands code against that ledger. Phases produce per-phase plans persisted at `docs/history/plans/` during the run; plans without delta-entry citations cannot pass `delta-coverage-reviewer`. Phase commits cite both the plan path (resolves during the run; recoverable via `git log --all` after Phase 3.5 cleanup) and the delta-entry stable IDs (the citation that survives cleanup in main). Coverage is structural, not aspirational.

## Rule

For every Cohesive implementation pass driven by `cohesive:implement-cohesively`:

1. Every entry in the design delta ledger (every Files-rewritten entry, every Files-added entry, every Conceptual-change row, every Named-invariant entry, every Behavior-matrix entry, every Gotcha entry, every Tests-proposed entry — excluding entries explicitly marked Deferred) maps to ≥1 phase in the implementation pass.
2. Every phase persists its plan at `docs/history/plans/<YYYY-MM-DD>-<slug>-phase-<N>.md` during the run, authored by `superpowers:writing-plans` from the phase intent. The plan is committed on the `design/<slug>` (or `implement/<slug>`) branch as part of the phase commit; `delta-coverage-reviewer`'s paths-only dispatch reads the tracked path during Phase 2c. The plan is **ephemeral** per [`docs/substrate/matrices/artifact-placement.md`](../matrices/artifact-placement.md) §"Lifecycle by artifact category" and is cleaned up at Phase 3.5 on Implemented verdict.
3. Every phase's commit message cites both the plan path and the delta-entry stable IDs. After Phase 3.5 cleanup, the stable IDs remain greppable in main; the plan path is recoverable via `git log --all` from branch history.
4. Every phase ends with a `delta-coverage-reviewer` cross-review whose verdict is Covered. Drift and Incomplete verdicts gate phase progression.
5. The implementation pass ends with `cohesive:review-diff` against the branch as a final substrate check (Phase 3).
6. On Phase 3 Pass / Pass with notes (Implemented verdict), Phase 3.5 strips ephemeral artifacts via a single cleanup commit whose body lists removed paths verbatim, before handoff to `superpowers:finishing-a-development-branch`. On Phase Drift / Substrate Drift / Aborted, Phase 3.5 does not fire — ephemeral artifacts remain on the branch for the next attempt or post-mortem.

If any of points 1–6 fail, the implementation pass is non-compliant and substrate has drifted.

A "run" spans Phase 1 inception through Phase 3 verdict, independent of Claude session boundary. Plans persist on the branch across session disconnects; the run terminates on Phase 3 verdict, not on session disconnect. Re-entering on `design/<slug>` in a later session resumes the run; ephemeral artifacts the prior session committed are still load-bearing for `delta-coverage-reviewer` dispatch in subsequent phases.

## Scope

### Applies to

- Every invocation of `cohesive:implement-cohesively`
- Every branch produced by an `implement-cohesively` invocation — the default `design/<slug>` branch (rewrite + implementation on one branch) and the alternative `implement/<slug>` child branch (per `implement-cohesively`'s "Branch shape" section) are both in scope
- Every per-phase plan persisted under `docs/history/plans/`
- Every per-phase commit on a `design/<slug>` or `implement/<slug>` branch produced by an `implement-cohesively` invocation

### Does not apply to

- Branches produced by `superpowers:writing-plans` + `superpowers:executing-plans` invoked directly (without `implement-cohesively`). Those branches use Superpowers' generic plan shape; this invariant is about delta-derived plan shape specifically.
- Hotfix branches that don't have a corresponding rewrite. There is no delta to cover.
- Documentation-only branches (e.g., `rewrite-specs` output). The delta ledger is the *output* of those branches, not their input.

Explicit non-applicability matters: a future contributor running `superpowers:writing-plans` directly is not in violation of this invariant — they're using a different workflow with a different shape. The invariant is scoped to `implement-cohesively`.

## Why this matters

The failure mode this invariant prevents is documented in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/no-implementation-handoff.md`: an implementation pass that drifts from the rewrite it was supposed to land. The drift is silent — code merges, tests pass, the branch looks healthy — but the substrate the rewrite established is not actually pinned in the running system. A future change predicated on the substrate then has nothing to break against.

Coverage is the prevention. If every delta entry must map to a phase and every phase must have a plan and a cross-review verdict, an entry cannot silently fall off the implementation pass. The reviewer will flag the gap; Phase 1 will refuse to advance with uncovered entries.

This is the third named invariant Cohesive ships, joining `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` and `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`. It earns invariant status because (a) the rule has a concrete structural failure mode (silent substrate drift), (b) the enforcement path is explicit (`implement-cohesively`'s Phase 1 coverage table; `delta-coverage-reviewer`'s Covered verdict; `cohesive:review-diff` final check), and (c) regressions have a real cost (rewrite-then-implement is expensive; failures should not hide).

## Runtime paths

Every place this invariant must hold:

- **`cohesive:implement-cohesively` Phases 1, 2, 3, 3.5.** Phase 1 produces the coverage table and refuses to advance with uncovered delta entries. Phase 2 invokes `superpowers:writing-plans`, `superpowers:executing-plans`, and `delta-coverage-reviewer` per phase. Phase 3 runs `cohesive:review-diff`. Phase 3.5 strips ephemeral artifacts on Implemented verdict only, via a cleanup commit whose body lists removed paths verbatim.
- **`docs/history/plans/`.** Plans persist on the branch from the phase commit that creates them through Phase 3.5 cleanup. A branch mid-implementation with phase commits but no plans on the tree is a violation. After cleanup, plans are absent from main's tree but recoverable via `git log --all` from branch history.
- **Phase commit messages.** Each phase commit cites both the plan path and the delta-entry stable IDs. After Phase 3.5 cleanup, the stable IDs remain greppable in main; plan paths are pre-cleanup branch-history references. Both branch shapes (`design/<slug>` and `implement/<slug>`) are in scope.

## Enforcement

- **Skill-body acceptance criteria:** `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md` Hard constraints #4, #5, and #6 require coverage, cross-review, and gated cleanup. The skill refuses to advance with uncovered delta entries; requires final substrate review; gates Phase 3.5 cleanup on Implemented verdict.
- **Reviewer agent verdict:** `${CLAUDE_PLUGIN_ROOT}/agents/delta-coverage-reviewer.md` returns Covered/Drift/Incomplete during Phase 2c. Drift and Incomplete are non-advancing verdicts. The agent reads the plan path during cross-review — alive throughout Phase 2, before Phase 3.5 cleanup.
- **Plan persistence:** `superpowers:writing-plans` writes plans to disk during Phase 2a; the phase commit tracks them on the branch. Plans cannot exist only in conversation.
- **Phase 3.5 gating:** cleanup fires only on Implemented verdict; the cleanup commit body must list removed paths verbatim. Both rules are violations otherwise.

The deferred CI grep target is the delta-entry stable ID form (the citation that survives cleanup and remains greppable in main); promotion follows the existing convention-with-grep pattern.

## Known bypass risks

- **A user invokes `superpowers:writing-plans` directly after `validate-rewrite` Approved**, bypassing `implement-cohesively`. The invariant does not apply (per Scope). The user accepts that the implementation may drift from the rewrite. The `validate-rewrite` Approved footer's decision matrix names this as a legitimate option ("Implement with Superpowers directly") — conditionally rendered when the rewrite is small enough that the phased loop would be ceremony per `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Conditional alternatives" — so the bypass is documented, not silent. The handshake is convention: when the user picks this alternative, `validate-rewrite`'s Output format renders the literal acknowledgment line `Implementing with plain Superpowers — Cohesive's per-phase verification of the rewrite doesn't apply. Run cohesive:review-diff after implementation to catch any drift.` in chat before invoking `superpowers:writing-plans`. The user-facing chat line names the verification entry point without surfacing the invariant token (per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2c — substrate-shape vocab stays out of chat); this invariant doc is the substrate-side record. The acknowledgment lands in the conversation transcript, not in commit history; this is enough for v0.1 because the bypass is rare and the substrate-side fence (this invariant scoped to `implement-cohesively`) holds independently. A future tightening can require the acknowledgment in commit history if the bypass is taken regularly.
- **Phase 1's coverage table is gamed.** A future implementer could produce a coverage table that maps every delta entry to a phase nominally, but with phase intents so vague that the corresponding plans don't actually implement the entries. Mitigated by: `delta-coverage-reviewer`'s "What you check" §1 (coverage of delta entries in the diff, not in the table); `cohesive:review-diff` at the end. Both fences require the *diff* to make the entry true, not just the *table*.
- **A phase commit doesn't cite the plan or delta IDs.** No automated check catches this in v0.1; reviewer memory is the enforcement until the deferred CI grep ships. Mitigated by: `cohesive:review-codebase` includes commit-citation discipline as a structure-reviewer concern.
- **`writing-plans` is invoked but the produced plan is empty / trivial.** The cross-review reviewer can flag this as Drift (plan-implementation agreement breaks). Mitigated by reviewer judgment.

Naming bypasses is not weakness — it's substrate. Future contributors who encounter a bypass need to know whether it's tolerated, mitigated, or actively being closed.

## Review checklist

When reviewing a change to `implement-cohesively`, the phase-derivation matrix, the `delta-coverage-reviewer` agent, or any branch produced by `implement-cohesively`:

- [ ] Does Phase 1 produce a coverage table covering every non-Deferred delta-ledger entry?
- [ ] Is every phase's plan committed during the run on the `design/<slug>` (or `implement/<slug>`) branch? (Plan present when `delta-coverage-reviewer` dispatched.)
- [ ] Does every phase commit cite both the plan path and the delta-entry stable IDs?
- [ ] Did `delta-coverage-reviewer` return Covered for every phase, and `cohesive:review-diff` (Phase 3) return Pass / Pass with notes?
- [ ] On Implemented verdict, did Phase 3.5 produce a single cleanup commit with the removed paths listed verbatim in its body? On Phase Drift / Substrate Drift / Aborted, did Phase 3.5 *not* fire?
- [ ] If the bypass was taken (user chose direct `superpowers:writing-plans`), was the literal acknowledgment line rendered in the conversation transcript? (See §Known bypass risks.)

## Related

- `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md` — the skill that implements this invariant
- `${CLAUDE_PLUGIN_ROOT}/agents/delta-coverage-reviewer.md` — the per-phase reviewer agent
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/artifact-placement.md` §"Lifecycle by artifact category" — the per-category lifecycle classification
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/plans-as-run-scaffolding.md` — the failure mode the cleanup-at-handoff pattern prevents
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/no-implementation-handoff.md`, `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/skipping-per-phase-plan.md` — adjacent failure modes

## History

- 2026-05-04 — Created. The structural pin behind `implement-cohesively`. Earned invariant status from day one because the rule has a concrete structural failure mode (silent substrate drift), an explicit enforcement path (Phase 1 coverage table; reviewer verdict; final substrate review), and a real cost on regression.
- 2026-05-04 — Repair pass 1 (post first validate-rewrite verdict): Step/Phase numbering reconciled with `implement-cohesively` SKILL body (Phase 4 → Phase 3; the SKILL has three phases plus two Step bookends). §Scope and §Runtime paths extended to cover the alternative `implement/<slug>` child branch (the default `design/<slug>` was the only branch named in the original; the SKILL's "Branch shape" section had named both but the invariant did not). §Known bypass risks specifies the acknowledgment-line handshake for the validate-rewrite decision matrix's bypass row.
- 2026-05-07 — Tightened the audit-citation distinction: durable citation is the **delta-entry stable ID** (survives Phase 3.5 cleanup); plan path is the **pre-cleanup branch-history pointer** (resolves during the run, recoverable via `git log --all` after cleanup). Added Rule #6 (Phase 3.5 cleanup, gated on Implemented verdict). §Runtime paths and §Enforcement extended to cover Phase 3.5; §Review checklist added items for cleanup-fires-on-Implemented and cleanup-does-not-fire-on-other-verdicts. Driven by the brainstorm at `docs/history/brainstorms/2026-05-07-run-scaffolding-cleanup.md` against pinky PR #175 evidence.
