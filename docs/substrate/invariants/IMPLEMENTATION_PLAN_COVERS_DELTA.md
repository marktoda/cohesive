# IMPLEMENTATION_PLAN_COVERS_DELTA

> Every entry in a design delta ledger maps to at least one phase in the implementation pass that lands code against that ledger. Phases produce per-phase plans persisted at `docs/history/plans/` *during the run*; plans without delta-entry citations cannot pass `delta-coverage-reviewer`. The durable audit citation is the **delta-entry stable ID** in the phase commit message; the plan path is the **pre-cleanup branch-history pointer** that resolves during the run and is recoverable from branch history after Phase 3.5 cleanup. Coverage is structural, not aspirational.

## Rule

For every Cohesive implementation pass driven by `cohesive:implement-cohesively`:

1. Every entry in the design delta ledger (every Files-rewritten entry, every Files-added entry, every Conceptual-change row, every Named-invariant entry, every Behavior-matrix entry, every Gotcha entry, every Tests-proposed entry — excluding entries explicitly marked Deferred) maps to ≥1 phase in the implementation pass.
2. Every phase persists its plan at `docs/history/plans/<YYYY-MM-DD>-<slug>-phase-<N>.md` *during the run*, authored by `superpowers:writing-plans` from the phase intent. The plan is committed on the `design/<slug>` (or `implement/<slug>`) branch as part of the phase commit; `delta-coverage-reviewer`'s paths-only fresh-eyes dispatch reads the tracked path during Phase 2c. The plan is **ephemeral** per [`docs/substrate/matrices/artifact-placement.md`](../matrices/artifact-placement.md) §"Lifecycle by artifact category"; it is cleaned up at Phase 3.5 on Implemented verdict and recoverable from branch history thereafter.
3. Every phase's commit message cites both the **delta-entry stable IDs** (the durable citation that survives Phase 3.5 cleanup) and the **plan path** (the pre-cleanup branch-history pointer that resolves during the run via `git show <phase-commit>`).
4. Every phase ends with a `delta-coverage-reviewer` cross-review whose verdict is Covered. Drift and Incomplete verdicts gate phase progression.
5. The implementation pass ends with `cohesive:review-diff` against the branch as a final substrate check (Phase 3).
6. On Phase 3 Pass / Pass with notes (Implemented verdict), Phase 3.5 strips ephemeral artifacts (per-phase plans, discovery reports if present) via a single cleanup commit before handoff to `superpowers:finishing-a-development-branch`. On Phase Drift / Substrate Drift / Aborted, Phase 3.5 does not fire — ephemeral artifacts remain on the branch for the next attempt or post-mortem.

If any of points 1–6 fail, the implementation pass is non-compliant and substrate has drifted.

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
- **`cohesive:implement-cohesively` Phase 3.5.** On Implemented verdict only, strips ephemeral artifacts via a single cleanup commit before handoff. The cleanup commit's body lists removed paths verbatim; this is the breadcrumb a forensic reader on main follows back to pre-cleanup branch history.
- **`docs/history/plans/`.** Plans persisted here are the **runtime audit surface** — they exist on the branch from the phase commit that creates them through the cleanup commit at Phase 3.5. A branch mid-implementation with phase commits but no plans on the tree is a violation. After Phase 3.5 cleanup, plans are absent from the tree but recoverable via `git log --all -- docs/history/plans/<slug>-phase-*.md` from branch history.
- **`design/<slug>` or `implement/<slug>` branch commit messages.** Each phase commit cites the **delta-entry stable IDs** (durable; survive Phase 3.5 cleanup) and the **plan path** (pre-cleanup branch-history pointer). A phase commit with implementation changes but no stable-ID citation is a violation regardless of cleanup state. Both branch shapes (default one-branch-end-to-end on `design/<slug>` and the split-merge alternative on `implement/<slug>`) are in scope.
- **Phase 3.5 cleanup commit.** Required on Implemented verdict; forbidden on Phase Drift / Substrate Drift / Aborted. The commit message body must list removed paths verbatim.

## Enforcement

How the invariant is structurally enforced:

- **Skill-body acceptance criteria:** `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md` Hard constraints #4, #5, and #6 require coverage, cross-review, and gated cleanup. The skill body refuses to advance with uncovered delta entries (Phase 1 acceptance), requires final substrate review (Phase 3), and gates Phase 3.5 cleanup on Implemented verdict.
- **Reviewer agent verdict:** `${CLAUDE_PLUGIN_ROOT}/agents/delta-coverage-reviewer.md` returns Covered/Drift/Incomplete; Drift and Incomplete are non-advancing verdicts. The agent's "What you check" §1 names coverage as the priority-one judgment. The agent reads the plan path during cross-review (Phase 2c, before Phase 3.5 cleanup) — the path is alive throughout Phase 2.
- **Plan persistence:** `superpowers:writing-plans` writes plans to disk during Phase 2a; the phase commit (Phase 2d) tracks the plan as part of the branch history. Plans cannot exist only in conversation. The artifact is the runtime audit surface; the durable audit surface is the delta-entry stable ID citation in the phase commit message.
- **Durable vs runtime citation:** the phase commit message body cites both forms (per Rule #3). Stable IDs survive Phase 3.5 cleanup as the audit-trail-in-main; plan paths resolve via `git show <phase-commit>` during the run and via `git log --all` after cleanup. The deferred CI grep target is the **delta-entry stable ID** form — that's the citation that survives cleanup and remains greppable in main.
- **Final substrate review (Phase 3):** `cohesive:review-diff` runs after the last per-phase iteration of Phase 2 per `implement-cohesively` Hard constraint #5. Its verdict gates Phase 3.5 cleanup *and* merge.
- **Phase 3.5 gating:** cleanup fires only on Implemented verdict per `implement-cohesively` Hard constraint #6. Cleanup on a non-Implemented verdict (or skipping cleanup on Implemented) is a violation. The cleanup commit's verbatim removed-paths list is the breadcrumb; a cleanup commit without that list is a violation.

A convention without enforcement is just a hope. The structural fences above (Phase 1 refuses to advance; reviewer returns non-advancing verdicts; plans persisted on the branch; final review runs; Phase 3.5 gates cleanup on verdict) are the load-bearing enforcement. The deferred CI grep is the convention pin that promotes stable-ID commit-message citation from "skill-body acceptance" to "CI-enforced."

## Known bypass risks

- **A user invokes `superpowers:writing-plans` directly after `validate-rewrite` Approved**, bypassing `implement-cohesively`. The invariant does not apply (per Scope). The user accepts that the implementation may drift from the rewrite. The `validate-rewrite` Approved footer's decision matrix names this as a legitimate option ("Implement with Superpowers directly") — conditionally rendered when the rewrite is small enough that the phased loop would be ceremony per `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Conditional alternatives" — so the bypass is documented, not silent. The handshake is convention: when the user picks this alternative, `validate-rewrite`'s Output format renders the literal acknowledgment line `Implementing with plain Superpowers — Cohesive's per-phase verification of the rewrite doesn't apply. Run cohesive:review-diff after implementation to catch any drift.` in chat before invoking `superpowers:writing-plans`. The user-facing chat line names the verification entry point without surfacing the invariant token (per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2c — substrate-shape vocab stays out of chat); this invariant doc is the substrate-side record. The acknowledgment lands in the conversation transcript, not in commit history; this is enough for v0.1 because the bypass is rare and the substrate-side fence (this invariant scoped to `implement-cohesively`) holds independently. A future tightening can require the acknowledgment in commit history if the bypass is taken regularly.
- **Phase 1's coverage table is gamed.** A future implementer could produce a coverage table that maps every delta entry to a phase nominally, but with phase intents so vague that the corresponding plans don't actually implement the entries. Mitigated by: `delta-coverage-reviewer`'s "What you check" §1 (coverage of delta entries in the diff, not in the table); `cohesive:review-diff` at the end. Both fences require the *diff* to make the entry true, not just the *table*.
- **A phase commit doesn't cite the plan or delta IDs.** No automated check catches this in v0.1; reviewer memory is the enforcement until the deferred CI grep ships. Mitigated by: `cohesive:review-codebase` includes commit-citation discipline as a structure-reviewer concern.
- **`writing-plans` is invoked but the produced plan is empty / trivial.** The cross-review reviewer can flag this as Drift (plan-implementation agreement breaks). Mitigated by reviewer judgment.

Naming bypasses is not weakness — it's substrate. Future contributors who encounter a bypass need to know whether it's tolerated, mitigated, or actively being closed.

## Review checklist

When reviewing a change to `implement-cohesively`, the phase-derivation matrix, the `delta-coverage-reviewer` agent, or any branch produced by `implement-cohesively`:

- [ ] Does the implementation pass produce a coverage table in Phase 1?
- [ ] Are all delta-ledger entries (excluding explicit Deferred entries) covered by ≥1 phase?
- [ ] Is every phase's plan committed under `docs/history/plans/` *during the run* on the `design/<slug>` (or `implement/<slug>`) branch? (After Phase 3.5 cleanup the plan is absent from the tree but recoverable via `git log --all`; the runtime check is "plans existed on the branch when `delta-coverage-reviewer` dispatched.")
- [ ] Does every phase commit cite both the delta-entry stable IDs (the durable citation) and the plan path (the pre-cleanup branch-history pointer)?
- [ ] Did `delta-coverage-reviewer` return Covered for every phase before the next phase started?
- [ ] Did `cohesive:review-diff` run at the end of the pass (Phase 3) and return Pass / Pass with notes?
- [ ] On Implemented verdict, did Phase 3.5 produce a single cleanup commit removing per-phase plans (and discovery report if present), with the commit message body listing removed paths verbatim?
- [ ] On Phase Drift / Substrate Drift / Aborted, did Phase 3.5 *not* fire? (Cleanup on a non-Implemented verdict is a violation; ephemeral artifacts are load-bearing for the next attempt or post-mortem.)
- [ ] If the rule was bypassed (user chose direct `superpowers:writing-plans` from the validate-rewrite Approved decision matrix), was the literal acknowledgment line `Implementation may drift from the rewrite; the IMPLEMENTATION_PLAN_COVERS_DELTA invariant does not apply.` rendered in the conversation transcript before `superpowers:writing-plans` was invoked? (Commit-history landing of the acknowledgment is a future tightening, not a v0.1 expectation — see §Known bypass risks.)

## Related

- `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md` — the skill that implements this invariant; §"Phase 3.5. Strip implementation scaffolding" is the cleanup-gating enforcement
- `${CLAUDE_PLUGIN_ROOT}/agents/delta-coverage-reviewer.md` — the per-phase reviewer agent
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/phase-derivation.md` — the matrix that derives phases from delta-ledger sections
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/artifact-placement.md` §"Lifecycle by artifact category" — the per-category lifecycle classification this invariant honors
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md` §"Cleanup at handoff" — the cleanup convention this invariant operationalizes
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/no-implementation-handoff.md` — the user-reported scar this invariant retires
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/skipping-per-phase-plan.md` — the failure mode that breaks coverage when `writing-plans` is skipped
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/plans-as-run-scaffolding.md` — the failure mode the durable-vs-runtime citation distinction prevents
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md` — the seam this invariant pins between Cohesive and Superpowers

## History

- 2026-05-04 — Created. The structural pin behind `implement-cohesively`. Earned invariant status from day one because the rule has a concrete structural failure mode (silent substrate drift), an explicit enforcement path (Phase 1 coverage table; reviewer verdict; final substrate review), and a real cost on regression.
- 2026-05-04 — Repair pass 1 (post first validate-rewrite verdict): Step/Phase numbering reconciled with `implement-cohesively` SKILL body (Phase 4 → Phase 3; the SKILL has three phases plus two Step bookends). §Scope and §Runtime paths extended to cover the alternative `implement/<slug>` child branch (the default `design/<slug>` was the only branch named in the original; the SKILL's "Branch shape" section had named both but the invariant did not). §Known bypass risks specifies the acknowledgment-line handshake for the validate-rewrite decision matrix's bypass row.
- 2026-05-07 — Tightened the audit-citation distinction: durable citation is the **delta-entry stable ID** (survives Phase 3.5 cleanup); plan path is the **pre-cleanup branch-history pointer** (resolves during the run, recoverable via `git log --all` after cleanup). Added Rule #6 (Phase 3.5 cleanup, gated on Implemented verdict). §Runtime paths and §Enforcement extended to cover Phase 3.5; §Review checklist added items for cleanup-fires-on-Implemented and cleanup-does-not-fire-on-other-verdicts. Driven by the brainstorm at `docs/history/brainstorms/2026-05-07-run-scaffolding-cleanup.md` against pinky PR #175 evidence.
