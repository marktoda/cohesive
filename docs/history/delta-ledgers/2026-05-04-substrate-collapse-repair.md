# Design Delta Ledger — Substrate Collapse Repair

**Date:** 2026-05-04
**Worktree / branch:** `.worktrees/cohesive-collapse-repair` on `design/collapse-repair`
**Approved direction:** Address blocking and important issues from the spec-cohesion review of the substrate-collapse rewrite. The collapse's thesis stands; the rewrite scoped itself too tightly and missed three live cross-references plus a count error.

**Driving review:** [`docs/history/delta-ledgers/2026-05-04-substrate-collapse.md`](2026-05-04-substrate-collapse.md) is the rewrite this pass repairs. The fresh-eyes review of that rewrite was rendered in chat (verdict: Issues Found, 3 blockers + 4 important + 1 enforcement concern + 5 vague-language items).

## Files rewritten

- `skills/discover-substrate/SKILL.md`
  - **Before:** line 19 listed `cohesive-review --scope substrate` as a downstream caller.
  - **After:** points at the standalone `substrate-audit` skill.
  - **Reason:** Stale cross-reference into a removed mode (B1).

- `skills/brainstorm-design/SKILL.md`
  - **Before:** line 176 said "Not a substrate audit. That's `cohesive-review --scope substrate`."
  - **After:** points at `cohesive:substrate-audit`.
  - **Reason:** Stale cross-reference (B1).

- `references/architecture-review-rubric.md`
  - **Before:** line 157 recommended `cohesive-review --scope substrate` as a fallback.
  - **After:** recommends `cohesive:substrate-audit`.
  - **Reason:** Stale cross-reference (B1).

- `README.md`
  - **Before:** §"Main commands" listed `cohesive-review # Codebase | diff | substrate modes` and omitted substrate-audit entirely — contradicting §"What's in the box" inside the same file.
  - **After:** `cohesive-review # Codebase | diff review (architecture / PR)` plus a new `substrate-audit # What memory is missing?` line.
  - **Reason:** Same-file source-of-truth disagreement (B2).

- `ARCHITECTURE.md`
  - **Before:** §"v0.1 scope" claimed "5 references, 7 templates."
  - **After:** "8 references, 8 templates." (Skills, agents, scripts counts were already correct.)
  - **Reason:** ARCHITECTURE is binding; the count was wrong against on-disk reality. README §"What's in the box" had the right count (B3).

- `skills/cohesive-review/SKILL.md`
  - **Before:** diff-mode "Recommended next" footer collapsed five verdict-classes into two recommendations (Pass/Pass-with-notes → writing-plans; Needs-substrate/Risky/Block → rewrite-specs).
  - **After:** five branches, each with a discriminating recommendation. "Risky" routes to `cohesive-review --scope codebase` (broader review); "Block" routes to `brainstorm-design` (re-decide direction).
  - **Reason:** "Risky" and "Block" warrant different next-steps than "Needs substrate"; collapsing them costs the discrimination the recommendation is supposed to provide (I1).

- `skills/substrate-audit/SKILL.md`
  - **Before:** §"Composition" named `discover-substrate` as preceding skill but did not mention the canonical `cohesively` route that drives it.
  - **After:** "Most often invoked by: `cohesive:cohesively` route `review (substrate audit)` (cell R007 in router matrix). The router passes 'discovery already complete; report at <path>' so this skill skips its own discovery prompt."
  - **Reason:** A reader of substrate-audit's body alone could not learn it's a router-driven skill (I2).

- `docs/substrate/designs/agent-dispatch-protocol.md`
  - **Before:** §"Concrete dispatch sites in v0.1" admitted the prior false-compliance claim but did not state the *current* corpus state — a fresh reader could believe the agent files were swept to canonical wording during the collapse.
  - **After:** adds a paragraph stating the substrate collapse demoted the verbatim-bullet rule to convention but did not sweep the five agent files; drift survives as drift-from-convention; future tightening pass may sweep when wording stabilizes.
  - **Reason:** Honest framing of where the property is held (harness fence, not agent-file wording) (I3).

- `references/skill-conventions.md`
  - **Before:** §"When sections may differ" exempted only the router. `discover-substrate`'s deviation was an unowned drift.
  - **After:** explicit exemption row for `discover-substrate` ("uses 'When to invoke' + 'Inputs' + 'Process' instead of 'Hard constraints' + 'Process'... it is a no-dispatch utility skill"). Rationale named.
  - **Reason:** Closes a known-deviation hole flagged in the prior post-Phase-1 review and surfaced again in fresh-eyes review (I4). Sweep was explicitly out of scope per the prior ledger; documenting the exemption is the smaller, more honest move for v0.1.

- `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md`
  - **Before:** §"Enforcement" described the path-discipline grep as if it were already running.
  - **After:** explicit "Current state (today)" / "Intended state (follow-up implementation)" split. Today: frontmatter + JSON + file-existence checks. Intended: hardcoded-path grep. The separation closes the credibility gap that the substrate-collapse thesis exists to prevent — the one remaining named invariant should not itself claim enforcement that isn't yet shipped.
  - **Reason:** Folklore-claimed-as-enforcement at 1/5 scale is still folklore-claimed-as-enforcement (enforcement concern from review).

- `references/reviewer-agent-template.md`
  - **Before:** "Every reviewer agent body should declare a token-discipline note." / "New agents should follow the order above. Existing agents will be brought into line in a future cleanup pass."
  - **After:** "Every reviewer agent body declares..." / "New agents follow the order above. *Future cleanup, non-normative:* existing agents will be brought into line when their wording stabilizes."
  - **Reason:** Vague modals in normative sections; future-pressure marked non-normative.

- `skills/cohesively/SKILL.md`
  - **Before:** "Prefer process skills before implementation skills."
  - **After:** "Process skills run before implementation skills."
  - **Reason:** "Prefer" reads as hedge in a normative directive.

## Files added

- This ledger.

## Files removed

- None.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| Substrate-collapse rewrite is internally consistent | Substrate-collapse rewrite is internally consistent *after this repair pass* | Tightened. Three live broken cross-references that the original collapse missed are now fixed. |
| `PLUGIN_ROOT_PATHS` enforcement is "load-bearing" by validator grep | `PLUGIN_ROOT_PATHS` enforcement has a current state (file-existence + reviewer judgment) and an intended state (path-discipline grep) | Honest framing. The claimed enforcement and the actual enforcement are now both in the doc, with the gap explicit. |
| Diff-mode footer collapses 5 verdicts to 2 recommendations | Diff-mode footer has one recommendation per verdict | Tightened to match the conventions doc's per-branch rule. |
| `discover-substrate` is a silent deviation from skill-conventions | `discover-substrate`'s deviation is explicitly enumerated as accepted | Documented; not swept. |

## What this rewrite *did not* do

- **Implementation code:** unchanged. `validate_plugin.sh` is unchanged. The PLUGIN_ROOT_PATHS doc now openly documents the gap between intended and current enforcement; landing the grep is still follow-up work.
- **Reviewer-agent corpus sweep:** unchanged. The drift across 4 of 5 agent files survives. The agent-dispatch-protocol doc now documents this honestly rather than implicitly.
- **`discover-substrate` body:** unchanged. The deviation is documented in skill-conventions; the skill body itself is unchanged.
- **Behavior matrix for substrate-audit:** not added. Reviewer flagged this as not-blocking; deferred.

## Remaining ambiguity

- None blocking. The fresh-eyes review's "What looked right" section confirmed the central thesis and the substrate-audit split. The repair pass closes every blocker and important issue from that review except the corpus sweeps and validator-grep implementation, which are deliberate non-changes per the v0.1-conventions-over-invariants framing.

## Ready for fresh-eyes review?

**Yes.** The repair pass is small (10 file edits, all surgical) and addresses every blocker and important issue from the prior fresh-eyes review. A second fresh-eyes pass should confirm Approved.

## How to read this ledger

This ledger is paired with [`2026-05-04-substrate-collapse.md`](2026-05-04-substrate-collapse.md). Read that one first for the substantive design move; this one is the surgical follow-up that brings the corpus into agreement with what the rewrite already claimed.
