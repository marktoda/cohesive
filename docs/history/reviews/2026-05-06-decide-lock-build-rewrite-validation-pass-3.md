# Rewrite Validation Review — Decide → Lock → Build user-facing gate framing (pass 3)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** Decide → Lock → Build user-facing gate framing rewrite (pass 3 of internal repair loop) on branch `design/decide-lock-build`; design delta ledger at `docs/history/delta-ledgers/2026-05-06-decide-lock-build.md`

**Status:** Approved

## Architectural reflection

The locked design is coherent: the gate vocabulary (Decide / Lock / Build) is consistently pinned across five user-facing surfaces (router announcement template, README, audience-separation convention, skills.md design layer, chat-trailer Variants), and the lock→build handoff has a substantive answer-shape (architectural reflection) rather than a methodology-narration. The prose-subsection-vs-fenced-template split for render-conditional rules is now the established pattern in both skills that need it (`validate-rewrite/SKILL.md` and `implement-cohesively/SKILL.md`). The architecture made the right tradeoff: collapse what users see (5 → 3) without renaming dispatch keys, so the audience seam takes the cost rather than the dispatch contract.

- **Easier downstream:** Adding a future skill that fits within an existing gate is a one-line table edit (skills.md Gate column) plus a SKILL.md body, with no router rename or dispatch-contract churn. Per-verdict trailer rendering is now formulaic — three skills follow the same prose-subsection-extracts-render-conditions shape.
- **Harder downstream:** The render-conditional prose pattern is convention, not validator-enforced. A future contributor authoring a third skill with conditional render rules has to spot the precedent in validate-rewrite/SKILL.md or implement-cohesively/SKILL.md and replicate it; there's no Check 13l-style structural enforcement yet. The deferred Check 13l candidate (chain-rendering anti-pattern grep) plus a sibling check for parentheticals-in-fenced-templates would close this.
- **Load-bearing on memory:** Two patterns currently rely on reviewer attention rather than structure: (1) the chain-rendering retirement is enforced by the Red-flags entry in `cohesively/SKILL.md` plus the §"Output" canonical template's literal — neither is greppable yet; (2) the gate vocabulary is the user-facing chat-surface vocabulary by convention in `audience-separation.md`, but the chat-trailer template's literal does not contain "Decide" / "Lock" / "Build" tokens to grep against. Both are promotion-criteria candidates per `docs/substrate/gotchas/style-guide-rot.md` once a real regression occurs.

## Executive judgment

Pass-3 closes the three pass-2 findings (B1: parentheticals in `implement-cohesively`'s render template; I1: four-bullet `### Next` rendering all options; I2: pass-2 classification annotation) by mirroring the same prose-subsection pattern pass-2 applied to `validate-rewrite/SKILL.md`. The fenced render template in `implement-cohesively/SKILL.md` now carries only the literal output, with all render conditions extracted to the §"Render-conditional rules for the body block" prose subsection. The `### Next` bullet renders one verdict-matching shape, with the four options enumerated as prose immediately after the closing fence. The delta-ledger pass-2 classification line is annotated to clarify per-pass scope vs the rewrite's overall Mixed classification. The rewrite is internally coherent across the nine files; the design-implementation seam (lens 13) holds for the three modified skill sections; the chain-rendering retirement (lens 14) is consistently applied across SKILL.md, README, audience-separation.md, and validator. Implementation can proceed.

## Delta at a glance

This rewrite is **Mixed** — primarily Design (user-facing surface restructure: gate vocabulary, chain-rendering retired, lock→build handoff reflection, build-end spec-coverage verdict) with implementation seams in the chat-trailer template, the cohesion-review template, two SKILL.md `## Output format` blocks, and one validator check.

(Full preamble matches `docs/history/delta-ledgers/2026-05-06-decide-lock-build.md` lines 9-37.)

## Important issues

None blocking. One Low-severity observation:

### I1. `## Phases` render-conditional rule line invites ambiguity

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** `implement-cohesively/SKILL.md` line 134 says "Render only non-empty sections per the chat-trailer template's §'Render-only-non-empty rule' (e.g., `## Phases` is always non-empty …)", but the prose render-conditional rules at line 143 already state `## Phases` "always renders". The two statements aren't contradictory but the line-134 wording invites a future contributor to wonder whether render-only-non-empty could collapse `## Phases` if it were empty (it can't, by construction). Minor noise.
- **Evidence:** `skills/implement-cohesively/SKILL.md:134` vs `:143`.
- **Recommended fix:** Drop the parenthetical example on line 134 ("e.g., `## Phases` is always non-empty …"); the prose subsection at 143 carries the per-section conditions definitively.
- **Substrate artifact to add or update:** spec (`skills/implement-cohesively/SKILL.md`).

## What looked right

- The pass-3 mirror of pass-2's prose-subsection extraction pattern is the right move: same shape, same reason, applied to the symmetric skill. Future contributors reading either SKILL.md will see the same render-template-vs-prose split.
- The `### Next` placeholder (line 176) — `<one decision-shaped bullet, matching the internal verdict — the four shapes are enumerated below; the chat trailer renders exactly one>` — is unambiguous. The placeholder names what's missing (the matching bullet) and where to find the choices (below). This avoids the failure mode where placeholders look like literal output the model should reproduce.
- The pass-2 classification annotation in the delta ledger (line 152) is a precise repair for I2: it pins what "Pure implementation" means at the per-pass level without contradicting the rewrite's overall Mixed classification at the top of the ledger.

### Next

**Disposition:** Close inline (≤2 lines per finding) → merge

**Implementation route — default:** Build the locked design and verify the code matches it. *(`cohesive:implement-cohesively`.)* **Scope:** the design delta ledger at `docs/history/delta-ledgers/2026-05-06-decide-lock-build.md` and branch `design/decide-lock-build`.

<details>
<summary>(other options)</summary>

- **Land specs first; implement separately later** — merge `design/decide-lock-build`, then run `cohesive:implement-cohesively` against the merged delta later. Pick when the spec rewrite is independently valuable for human review before code lands.
- **Hand off to Superpowers without delta-coverage discipline** — *(`superpowers:writing-plans`.)* Pick when the rewrite is small and the delta is mostly cosmetic; implementation may drift.
- **Schedule for later** — no immediate action.

</details>
