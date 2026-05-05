# Gotcha: skipping `superpowers:writing-plans` per phase collapses the cross-review surface

## Symptom

`cohesive:implement-cohesively` is running an implementation pass. The implementer (or a future contributor reading the skill body) decides that calling `superpowers:writing-plans` for every phase is "ceremony" — the delta-ledger entry already names what the phase must accomplish; why translate it into a plan? The skill is modified (or invoked with a flag, or interpreted loosely by Claude) to skip the plan step and pass the phase intent directly to `superpowers:executing-plans`, or to author the TDD tasks inline.

A few phases later, `delta-coverage-reviewer` returns Drift on a phase. The reviewer's finding is unclear: it can't tell whether the implementer didn't cover a delta entry (Incomplete), or did cover it but in a way that diverges from what was planned (Drift). Without a per-phase plan, those failure modes silently merge into one verdict the reviewer can't distinguish, and the repair direction is ambiguous.

Worse: phase commits cite no plan path. A reviewer auditing the branch later cannot reconstruct what each phase was supposed to do, only what it did.

## Why it happened

Per-phase plans look redundant on their face. The delta ledger names what each phase covers. The phase intent paraphrases that. `superpowers:writing-plans` then translates the intent into TDD tasks. Three artifacts describing the same work — the ledger, the intent, the plan — feels like one too many.

The redundancy is intentional and load-bearing:

- **The ledger is substrate-shape** — Files rewritten, Conceptual changes, Named invariants. It does not name TDD tasks.
- **The phase intent is substrate-shape** — derived from the ledger via the phase-derivation matrix. Still substrate-shape; still doesn't name TDD tasks.
- **The plan is TDD-shape** — failing test first, minimal implementation, refactor. The shape Superpowers' `executing-plans` consumes.

The cross-review needs both substrate-shape and TDD-shape artifacts to compare against the diff:

- Did the diff implement the **plan**? (Plan-implementation agreement — the `executing-plans` discipline.)
- Did the **plan** cover the **delta entry**? (Plan-coverage agreement — the substrate↔plan seam.)

Without the plan, the reviewer has only the diff and the delta. A finding like "this hunk doesn't match what the delta entry described" cannot be decomposed: maybe the plan never named that work (planning gap), or maybe the plan named it but the implementation skipped it (execution gap). Both gaps need different repairs. Collapsing them blocks repair.

## Tempting wrong fix

Make `implement-cohesively` author TDD-shaped tasks itself, skipping `superpowers:writing-plans`. The argument: "Cohesive owns the delta-derivation; just keep going." This *appears* to simplify by removing one composition step.

Why it's wrong:

- It violates the Cohesive↔Superpowers seam documented in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md`. Cohesive owns *substrate-shape*; Superpowers owns *TDD-shape*. Collapsing one into the other reinvents Superpowers inside Cohesive.
- It removes the inspectable per-phase plan artifact. Branch auditors lose the ability to ask "what was this phase trying to accomplish?" without re-deriving from the diff.
- It removes the planning gap from the cross-review. The reviewer can no longer flag "the plan didn't cover entry X" as distinct from "the implementation skipped entry X."
- It scales badly: a Cohesive-authored TDD layer would have to track every Superpowers improvement to plan structure, branch hooks, baseline tests, etc. The composition seam exists precisely to avoid this.

A second tempting wrong fix: produce one plan for the entire implementation pass (one plan covering all phases), rather than per-phase. This *appears* to reduce overhead.

Why it's wrong: the cross-review is per-phase by design. A monolithic plan defeats the per-phase fence — drift in phase 2 is caught only at the end, when repair is expensive. The fence's value is structural: each phase is reviewed before the next begins.

## Correct pattern

Per-phase: phase intent (Cohesive) → plan (Superpowers writes) → execution (Superpowers executes) → cross-review (Cohesive dispatches reviewer). Three artifacts; one Cohesive-shape, one Superpowers-shape, one diff. The reviewer compares all three.

Plan persistence is mandatory: every phase's plan is written to `docs/history/plans/<YYYY-MM-DD>-<slug>-phase-<N>.md` and cited by the phase commit. The plan is read by `delta-coverage-reviewer` as input. Without persistence, the reviewer has nothing to compare against.

## Related conventions

- **Composition with Superpowers** ([`docs/substrate/architecture/composition-with-superpowers.md`](../architecture/composition-with-superpowers.md)) — the seam this gotcha protects. Cohesive owns substrate-shape; Superpowers owns TDD-shape.
- **Implementation plan coverage** ([`docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`](../invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md)) — the structural rule that every delta entry maps to a phase, and every phase has a plan.
- **Dispatch protocol** ([`docs/substrate/conventions/dispatch-protocol.md`](../conventions/dispatch-protocol.md)) — the cross-review depends on paths-only inputs; the plan path is one of those inputs.

## Tests / checks that preserve this

- **`implement-cohesively/SKILL.md` Hard constraint #2** — composes with Superpowers; never authors TDD-shape directly. Reviewed in `cohesive:review-codebase` against the skill body.
- **`implement-cohesively/SKILL.md` Anti-patterns table** — first row names this gotcha by reference.
- **Manual scenario test (planned, deferred):** invoke `implement-cohesively` with a delta-ledger that has 3 entries; verify three plans are persisted at `docs/history/plans/` and three cross-review dispatches happen.
- **Lint check (deferred V1):** grep `implement-cohesively/SKILL.md` for the literal Skill-tool invocations of `superpowers:writing-plans` and `superpowers:executing-plans`. The skill body must invoke both, in order, per phase.

If the test list is empty, the gotcha is enforced by reviewer memory only. The first concrete test should land in the implementation pass that produces the new phase loop.

## When this was discovered

- Date: 2026-05-04
- Source: design conversation that produced the `implement-cohesively` skill. The user's pressure-test question — "if we do orchestrate-not-drive, should we also do a write-plan phase based on the phase?" — surfaced this exact failure mode before the skill shipped. Capturing it as a gotcha keeps the answer (yes, per-phase plan; no, do not skip) substrate-bound.
- One-line summary: a phase loop that skips `writing-plans` collapses the cross-review's two failure modes (planning gap, execution gap) into one indistinguishable verdict, blocking targeted repair.

## Notes for future contributors

- The temptation to skip the plan grows with implementation-pass token budgets. Resist. The plan is what makes per-phase cross-review work.
- If a future Superpowers ergonomic change makes `writing-plans` cheaper, the redundancy concern fades further. If a future Superpowers change removes `writing-plans` entirely, this gotcha needs revisiting along with the composition-with-superpowers design doc.
- The same logic applies, in principle, to skipping the cross-review itself. That failure mode is even worse and is enforced by `implement-cohesively`'s Hard constraint #3, not by this gotcha.
