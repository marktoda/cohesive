# IMPLEMENTATION_PLAN_COVERS_DELTA

> Every entry in a design delta ledger maps to at least one phase in the implementation pass that lands code against that ledger. Phases without a plan persisted at `docs/history/plans/` cannot exist; plans without delta-entry citations cannot pass `delta-coverage-reviewer`. Coverage is structural, not aspirational.

## Rule

For every Cohesive implementation pass driven by `cohesive:implement-cohesively`:

1. Every entry in the design delta ledger (every Files-rewritten entry, every Files-added entry, every Conceptual-change row, every Named-invariant entry, every Behavior-matrix entry, every Gotcha entry, every Tests-proposed entry — excluding entries explicitly marked Deferred) maps to ≥1 phase in the implementation pass.
2. Every phase persists its plan at `docs/history/plans/<YYYY-MM-DD>-<slug>-phase-<N>.md`, authored by `superpowers:writing-plans` from the phase intent.
3. Every phase's commit message cites the plan path and the stable IDs of the delta entries the phase covers.
4. Every phase ends with a `delta-coverage-reviewer` cross-review whose verdict is Covered. Drift and Incomplete verdicts gate phase progression.
5. The implementation pass ends with `cohesive:review-diff` against the branch as a final substrate check.

If any of points 1–5 fail, the implementation pass is non-compliant and substrate has drifted.

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

- **`cohesive:implement-cohesively` Phase 1.** Produces the coverage table; refuses to advance to Phase 2 if any delta entry is uncovered.
- **`cohesive:implement-cohesively` Phase 2 per-phase loop.** Each iteration invokes `superpowers:writing-plans` (plan persistence), `superpowers:executing-plans` (code), `delta-coverage-reviewer` (cross-review verdict).
- **`cohesive:implement-cohesively` Phase 3.** Final substrate check via `cohesive:review-diff`; any non-Pass verdict gates merge.
- **`docs/history/plans/`.** Plans persisted here are the audit trail. A branch with implementation commits but no plans persisted is a violation.
- **`design/<slug>` or `implement/<slug>` branch commit messages.** Each phase commit cites the plan path and the delta-entry stable IDs. A commit with implementation changes but no citation is a violation. Both branch shapes (default one-branch-end-to-end on `design/<slug>` and the split-merge alternative on `implement/<slug>`) are in scope.

## Enforcement

How the invariant is structurally enforced:

- **Skill-body acceptance criteria:** `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md` Hard constraints #4 and #5 require coverage and cross-review. The skill body refuses to advance with uncovered delta entries (Phase 1 acceptance) and requires final substrate review (Phase 3).
- **Reviewer agent verdict:** `${CLAUDE_PLUGIN_ROOT}/agents/delta-coverage-reviewer.md` returns Covered/Drift/Incomplete; Drift and Incomplete are non-advancing verdicts. The agent's "What you check" §1 names coverage as the priority-one judgment.
- **Plan persistence:** `superpowers:writing-plans` writes plans to disk. Plans cannot exist only in conversation. The artifact is the audit surface.
- **Commit message citation:** `implement-cohesively`'s Phase 2d. Commit the phase names the plan path and delta IDs in the commit message body. Lint check (deferred V1): a CI grep that every commit on a `design/<slug>` or `implement/<slug>` branch authored by `implement-cohesively` cites at least one plan path and at least one delta entry stable ID.
- **Final substrate review (Phase 3):** `cohesive:review-diff` runs after the last per-phase iteration of Phase 2 per `implement-cohesively` Hard constraint #5. Its verdict gates merge.

A convention without enforcement is just a hope. The structural fences above (Phase 1 refuses to advance; reviewer returns non-advancing verdicts; plans persisted; final review runs) are the load-bearing enforcement. The deferred CI grep is the convention pin that promotes commit-message citation from "skill-body acceptance" to "CI-enforced."

## Known bypass risks

- **A user invokes `superpowers:writing-plans` directly after `validate-rewrite` Approved**, bypassing `implement-cohesively`. The invariant does not apply (per Scope). The user accepts that the implementation may drift from the rewrite. The `validate-rewrite` Approved footer's decision matrix names this as a legitimate option ("Hand off to Superpowers without delta-coverage discipline") so the bypass is documented, not silent. The handshake is convention: when the user picks the bypass row, `validate-rewrite`'s Output format renders the literal acknowledgment line `Implementation may drift from the rewrite; the IMPLEMENTATION_PLAN_COVERS_DELTA invariant does not apply.` before invoking `superpowers:writing-plans`. The acknowledgment lands in the conversation transcript, not in commit history; this is enough for v0.1 because the bypass is rare and the substrate-side fence (this invariant scoped to `implement-cohesively`) holds independently. A future tightening can require the acknowledgment in commit history if the bypass is taken regularly.
- **Phase 1's coverage table is gamed.** A future implementer could produce a coverage table that maps every delta entry to a phase nominally, but with phase intents so vague that the corresponding plans don't actually implement the entries. Mitigated by: `delta-coverage-reviewer`'s "What you check" §1 (coverage of delta entries in the diff, not in the table); `cohesive:review-diff` at the end. Both fences require the *diff* to make the entry true, not just the *table*.
- **A phase commit doesn't cite the plan or delta IDs.** No automated check catches this in v0.1; reviewer memory is the enforcement until the deferred CI grep ships. Mitigated by: `cohesive:review-codebase` includes commit-citation discipline as a structure-reviewer concern.
- **`writing-plans` is invoked but the produced plan is empty / trivial.** The cross-review reviewer can flag this as Drift (plan-implementation agreement breaks). Mitigated by reviewer judgment.

Naming bypasses is not weakness — it's substrate. Future contributors who encounter a bypass need to know whether it's tolerated, mitigated, or actively being closed.

## Review checklist

When reviewing a change to `implement-cohesively`, the phase-derivation matrix, the `delta-coverage-reviewer` agent, or any branch produced by `implement-cohesively`:

- [ ] Does the implementation pass produce a coverage table in Phase 1?
- [ ] Are all delta-ledger entries (excluding explicit Deferred entries) covered by ≥1 phase?
- [ ] Is every phase's plan persisted under `docs/history/plans/`?
- [ ] Does every phase commit cite the plan path and the delta-entry stable IDs?
- [ ] Did `delta-coverage-reviewer` return Covered for every phase before the next phase started?
- [ ] Did `cohesive:review-diff` run at the end of the pass and return Pass / Pass with notes?
- [ ] If the rule was bypassed (user chose direct `superpowers:writing-plans`), was the bypass documented in the branch's commit history?

## Related

- `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md` — the skill that implements this invariant
- `${CLAUDE_PLUGIN_ROOT}/agents/delta-coverage-reviewer.md` — the per-phase reviewer agent
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/phase-derivation.md` — the matrix that derives phases from delta-ledger sections
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/no-implementation-handoff.md` — the user-reported scar this invariant retires
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/skipping-per-phase-plan.md` — the failure mode that breaks coverage when `writing-plans` is skipped
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/composition-with-superpowers.md` — the seam this invariant pins between Cohesive and Superpowers

## History

- 2026-05-04 — Created. The structural pin behind `implement-cohesively`. Earned invariant status from day one because the rule has a concrete structural failure mode (silent substrate drift), an explicit enforcement path (Phase 1 coverage table; reviewer verdict; final substrate review), and a real cost on regression.
- 2026-05-04 — Repair pass 1 (post first validate-rewrite verdict): Step/Phase numbering reconciled with `implement-cohesively` SKILL body (Phase 4 → Phase 3; the SKILL has three phases plus two Step bookends). §Scope and §Runtime paths extended to cover the alternative `implement/<slug>` child branch (the default `design/<slug>` was the only branch named in the original; the SKILL's "Branch shape" section had named both but the invariant did not). §Known bypass risks specifies the acknowledgment-line handshake for the validate-rewrite decision matrix's bypass row.
