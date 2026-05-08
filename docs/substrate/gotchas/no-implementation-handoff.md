# Gotcha: Cohesive starts writing code with no task breakdown when the user requests immediate implementation

## Symptom

A user runs the design route through to `validate-rewrite` Approved. The footer recommends `superpowers:writing-plans` (or `cohesive:implement-cohesively`). The user, instead, types "just implement it now and land docs with implementation" or "let's ship this."

Cohesive responds by *starting to write code* — opening files, applying edits, running tests — without invoking `cohesive:implement-cohesively`, without dispatching `superpowers:writing-plans`. There is no plan persisted. There is no end-of-run dual reviewer dispatch. The first sign of trouble appears later, when the implementation has drifted from the rewritten specs and `cohesive:review-diff` flags substrate divergence — at which point repair is expensive.

The user's experience: "I asked Cohesive to do the obvious thing and it skipped its own discipline." The substrate's experience: the rewrite's value (delta ledger as inspectable work-shape; per-phase fence; final substrate review) was bypassed by a single freeform user request.

## Why it happened

Before `implement-cohesively` shipped, Cohesive's design route ended at `validate-rewrite`. The implementation handoff lived in three skill footers and one prose line in `composition-with-superpowers.md`. There was no:

- Substrate document for the post-`validate-rewrite` phase.
- Matrix for the user's options after Approved.
- Router route for "implement the approved rewrite."
- Cohesive skill that drove implementation against the delta.

When the user asked to implement, Claude had nothing canonical to consult. The fallback was the universal default: improvise. Improvising on implementation broke Cohesive's own substrate-first thesis: implementation that bypasses the substrate is exactly the failure mode Cohesive exists to prevent.

The gap was anticipated. `composition-with-superpowers.md` line 84 (in v0.1's pre-implement-cohesively shape) named "If a Cohesive V1 skill genuinely needs to drive implementation (e.g., `implement-cohesively`)" as a future trigger to revisit the seam. Until that skill shipped, the trigger was dormant — and the user's "implement now" request fell into the dormancy.

## Tempting wrong fix

Add stronger prose to the `validate-rewrite` Approved footer telling Claude to "always recommend Superpowers before writing code." This *appears* to close the gap with a documentation pass.

Why it's wrong:

- Prose-only recommendations have no structural enforcement. Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md`, rules far from the point of generation drift silently — the `validate-rewrite` footer is far from the moment the user types "implement now."
- The user's request *is reasonable*. "Implement now and land docs with implementation" is a legitimate workflow — they want the rewrite and the code to merge as one branch. Telling Claude to refuse and recommend Superpowers' chain instead is fighting the user's legitimate intent.
- The real failure mode is Cohesive having no structural answer for "implement now." Adding prose to the footer doesn't add one.

A second tempting wrong fix: make the `cohesively` router auto-invoke `superpowers:writing-plans` when the user says "implement." This *appears* to add structure.

Why it's wrong: it violates the principle that the router doesn't auto-cross plugin boundaries — phase transitions are user-driven. More importantly, it loses Cohesive's substrate-shape: Superpowers' `writing-plans` produces a generic plan, not a delta-derived plan. The user's complaint isn't that no plan was produced; it's that no *delta-coverage* plan was produced.

## Correct pattern

Ship `cohesive:implement-cohesively` as a v0.1 skill, not a V1-deferred one. The skill:

- Takes the design delta ledger and validate-rewrite Approved verdict as required inputs.
- Composes a thin intent paragraph from the delta ledger (delta-entry stable IDs + named invariants + dual-reviewer acceptance) and surfaces a delta-size budget gate above 15 entries.
- Invokes `superpowers:writing-plans` once (intent → TDD plan) and `superpowers:executing-plans` once (plan → code) per implementation pass.
- Dispatches `delta-coverage-reviewer` and `cohesive:review-diff` in parallel at end-of-run; synthesizes the verdict AND-shape.

The router (`cohesively`) gains an `implement` route that dispatches `implement-cohesively` when the user says "implement the approved rewrite," "land docs with implementation," "implement-cohesively," or "drive implementation against the delta."

The `validate-rewrite` Approved footer becomes an explicit decision matrix — the default plus zero or more conditionally-rendered alternatives, each gated by a triggering condition the agent judges from the rewrite's substrate shape (per `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Conditional alternatives"):

- **Default** — Implement now → `cohesive:implement-cohesively`
- **Conditional** — Land specs first → merge the spec-rewrite branch, then run `cohesive:implement-cohesively` against the merged delta ledger later (fires when the rewrite adds substantive new substrate worth independent human review before code lands)
- **Conditional** — Implement with Superpowers directly → `superpowers:writing-plans` (fires when the rewrite is small enough that Cohesive's implement-cohesively flow with end-of-run dual reviewer dispatch would be ceremony; the user accepts that implementation may drift)
- **Conditional** — Re-decide → `cohesive:brainstorm-design` (fires when the Architectural reflection identifies a structural concern the brainstorm missed)

The user picks from the rendered options; Cohesive does not improvise. When no conditional alternative fires, the trailer collapses to the default — the user can still invoke any other skill manually if they prefer.

## Related conventions

- **Composition with Superpowers** ([`docs/substrate/architecture/composition-with-superpowers.md`](../architecture/composition-with-superpowers.md)) — the seam now includes `implement-cohesively` as Cohesive's substrate-shaped implementation orchestrator.
- **Implementation plan coverage** ([`docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`](../invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md)) — the structural rule that every delta entry is covered by the single per-pass plan and verified by end-of-run dual reviewer dispatch.
- **Mega-plan abandonment** ([`large-delta-mega-plan.md`](large-delta-mega-plan.md)) — the abandonment cliff that surfaces when a delta ledger exceeds the size threshold; mitigated by the Step 1 budget gate.
- **Soft-prereqs gotcha** ([`soft-prereqs.md`](soft-prereqs.md)) — the analogous failure mode at the front of the workflow chain. Both gotchas share a fix shape: encode the prevention as substrate, don't rely on Claude's heuristic improvisation.

## Tests / checks that preserve this

- **Router has an `implement` route** — covered by `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md` cell R015. Reviewed in `cohesive:review-codebase`.
- **`validate-rewrite` Approved footer renders the decision matrix** — covered by `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` Output format block, mechanically enforced by `scripts/validate_plugin.sh` Check 13e (greps the four canonical decision-matrix rows).
- **`implement-cohesively` skill exists and is in the expected skill set** — covered by `scripts/validate_plugin.sh` Check 8 (`expected_skills` array includes `implement-cohesively`) and Check 13f (greps that the skill body cites `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`).
- **`validate-rewrite` Approved footer renders the bypass-acknowledgment line when row 3 is picked** — covered by `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` Output format §"Bypass acknowledgment" and `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` §Known bypass risks. The convention is the literal acknowledgment string `Implementation may drift from the rewrite; the IMPLEMENTATION_PLAN_COVERS_DELTA invariant does not apply.` rendered in the conversation transcript before `superpowers:writing-plans` is invoked. Mechanically enforced by `scripts/validate_plugin.sh` Check 13g (greps `validate-rewrite/SKILL.md` for the literal acknowledgment string).
- **Manual scenario test (planned):** with both Cohesive and Superpowers installed, after a `validate-rewrite` Approved verdict, type "implement now and land docs with implementation"; verify the router selects `implement` and `implement-cohesively` runs, not freeform code-writing.

## When this was discovered

- Date: 2026-05-04
- Source: user-reported scar during a Cohesive-on-Cohesive design conversation. Mark Toda described the exact failure mode: "Cohesive suggested merging substrate and design docs but didn't give an implementation option. I said 'implement now and land docs with implementation' and it just started working with no task breakdown."
- One-line summary: Cohesive's design route ended at `validate-rewrite` with no structural answer for "implement now"; freeform code-writing followed by default, bypassing the substrate the rewrite established.

## Notes for future contributors

- This gotcha is the substrate-side scar. The structural fix is `implement-cohesively`, the `implement` router route, and the sharpened `validate-rewrite` Approved footer. If any of those three is removed in a future change, this gotcha must be re-read before merge.
- The "implement now" trigger phrase will keep evolving. Future routes should add new trigger phrases without removing the old ones — the failure mode is "user said something natural; Cohesive had no canonical answer," and broadening the trigger surface narrows the dormancy window.
- The same shape — "Cohesive has no canonical answer for a legitimate user request, so it improvises and bypasses substrate" — is the one to watch for elsewhere in the chain. If it shows up again, document it as substrate (gotcha + matrix + skill or route), not as prose-only discipline.
