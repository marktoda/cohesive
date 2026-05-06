# Design Delta Ledger — Re-decide escape hatch + post-implementation review pattern

**Date:** 2026-05-06
**Worktree / branch:** `.claude/worktrees/post-lock-escape-and-post-impl-review` on `design/post-lock-escape-and-post-impl-review`
**Approved direction:** Two surgical additions to the just-merged Decide → Lock → Build framing — a Re-decide escape hatch at the lock→build handoff (returns Lock → Decide on user architectural-judgment override) and a tightened post-implementation review pattern (bypass-acknowledgment imperative + named entry point in handoffs.md). Both are extensions of the prior rewrite, not reshapes of it.

## Delta at a glance

This rewrite is **Mixed** — primarily Design (new escape-hatch route in the user-facing flow; new substrate input category in `brainstorm-design`; new documented handoff pattern in `handoffs.md`) with implementation seams in two SKILL.md `## Output format` blocks and the audience-separation convention.

**Design-layer changes:**
- `docs/substrate/architecture/handoffs.md` — new `validate-rewrite → brainstorm-design (Re-decide re-entry)` section under §"Off-chain re-entry"; new top-level §"Post-implementation review entry point" section before §"What this doc does not cover".
- `docs/substrate/conventions/audience-separation.md` — added "Gate-level reversal: Re-decide" paragraph naming the Lock → Decide reversal as user-facing chat-surface vocabulary.

**Implementation changes:**
- `skills/validate-rewrite/SKILL.md` — added fifth Re-decide alternative to `(other options)` disclosure; tightened bypass-acknowledgment line with the `cohesive:review-diff` follow-up imperative; added §"Re-decide acknowledgment" parallel to §"Bypass acknowledgment".
- `skills/brainstorm-design/SKILL.md` — added "What we already tried" optional input category to Phase 1; specified shape (discarded direction + reflection's harder-downstream + load-bearing-on-memory + cycle count) and how it biases option-generation.

- **Files:** 4 rewritten, 1 added (this ledger), 0 removed
- **Conceptual changes:** Lock → Decide gate-level reversal added (the **Re-decide** path; user-action override on Approved verdicts); post-implementation review pattern named explicitly for non-canonical implementation paths (bypass + external implementation); brainstorm-design grows a fourth optional input category for re-decide cycles
- **Named invariants:** none added / removed / changed; `IMPLEMENTATION_PLAN_COVERS_DELTA` and `VERDICT_BEFORE_EVIDENCE` continue to hold
- **Behavior matrices:** `docs/substrate/matrices/router.md` unchanged
- **Gotchas:** none added / retired
- **Semantic linters:** none added; a future check candidate could grep `skills/validate-rewrite/SKILL.md` for the bypass-acknowledgment line carrying the `cohesive:review-diff` follow-up imperative — deferred until wording stabilizes
- **Tests proposed:** none
- **Deferred (out of scope this pass):** validator check for bypass-acknowledgment imperative; cap-on-re-decide-cycles validator (currently convention)

## Files rewritten

- `skills/validate-rewrite/SKILL.md`
  - **Before:** `(other options)` disclosure on Approved trailer carried three alternatives (land specs first, hand off to Superpowers, schedule for later); §"Bypass acknowledgment" rendered the bypass line without naming a post-implementation verification entry point.
  - **After:** `(other options)` disclosure carries four alternatives — the fourth, **Re-decide**, names the gate-level reversal back to `cohesive:brainstorm-design` with the discarded reflection's bullets passed as substrate residue (per `brainstorm-design`'s "What we already tried" input). §"Bypass acknowledgment" tightened with the imperative `Run cohesive:review-diff against the branch when implementation lands — bypass means accepting drift risk, not skipping verification.` Added §"Re-decide acknowledgment" rendering the parallel acknowledgment line for the Re-decide path (`Discarding the locked design and returning to Decide. Capture the reflection's harder-downstream / load-bearing-on-memory bullets in brainstorm-design's "What we already tried" input.`) plus the 2-3-cycle cap.
  - **Reason:** The lock→build handoff's whole point (per the decide-lock-build rewrite) is to give the user a substantive moment to decide whether the architecture feels right after the lock. Without a Re-decide path, the only escape was a bad-faith pick of one of the existing Approved-trailer options or manual abandonment of the worktree — neither of which preserves what was learned. The bypass-acknowledgment tightening addresses the "user picks bypass and forgets to verify" failure mode the original review surfaced.

- `skills/brainstorm-design/SKILL.md`
  - **Before:** Phase 1 captured three input categories (Current scope / Future pressure / Non-goals); the clarifying-question suggestion was scoped to future-pressure choices only.
  - **After:** Phase 1 captures three required + one optional category. The new optional category, **What we already tried**, is populated when this brainstorm is invoked from a `validate-rewrite` Approved trailer's Re-decide option; it carries the discarded direction summary, the discarded reflection's harder-downstream bullets, the discarded reflection's load-bearing-on-memory bullets, and a re-decide cycle count. The brainstorm uses these inputs to bias option-generation — new options must either resolve the discarded reflection's concerns or explicitly accept them with a different structural mitigation. Pressure-test in Phase 3 attacks new options against the discarded concerns. Clarifying-question suggestion expanded with a second form ("Which of the prior reflection's concerns is the most load-bearing for this re-decide: <A> or <B>?") for re-decide cycles.
  - **Reason:** Without this input category, the brainstorm runs ignorant of why the prior lock failed user judgment, and the next round of options can re-derive the discarded path. Capturing the substrate residue of a failed lock is what closes the re-decide loop on what was learned.

- `docs/substrate/architecture/handoffs.md`
  - **Before:** Off-chain re-entry section enumerated four edges (review-codebase → brainstorm-design / review-codebase → rewrite-specs / audit-substrate → rewrite-specs / validate-rewrite → brainstorm-design (Design Incoherent)). No top-level section covered the post-implementation review case for non-canonical implementation paths.
  - **After:** Off-chain re-entry section grows a fifth edge — `validate-rewrite → brainstorm-design (Re-decide re-entry)` — distinct from the Design Incoherent re-entry: Re-decide fires on Approved + user override (the rewrite locked coherently, but the user's architectural judgment after reading the reflection says the design has costs that weren't visible at brainstorm time). New top-level §"Post-implementation review entry point" section names `cohesive:review-diff` as the verification skill for three trigger conditions (bypass path, teammate implementation against locked design, external-tool implementation) with artifact-crossing / skill-invoked / verdict-gate / failure-mode contracts mirroring the per-handoff shape.
  - **Reason:** The post-implementation review entry point existed implicitly (review-diff is the right skill) but was not named anywhere — a future contributor would have to re-derive that review-diff is what answers "does the code match the locked design?" outside the implement-cohesively phase loop. Naming the pattern in handoffs.md makes it findable for the failure modes the original review surfaced.

- `docs/substrate/conventions/audience-separation.md`
  - **Before:** §"Gate vocabulary is the user-facing chat-surface vocabulary" pinned the forward-flow gate vocabulary (Decide / Lock / Build). No mention of gate-level reversals.
  - **After:** Added paragraph naming both backward gate transitions — Build → Lock (existing Substrate Drift verdict) and Lock → Decide (new Re-decide path) — and pinning "Re-decide" as the user-facing chat-surface term for the Lock → Decide reversal. Cites the handoffs.md re-entry section as the agent-internal substrate equivalent.
  - **Reason:** Without this note, future contributors authoring chat-render surfaces would have to re-derive whether "Re-decide" is gate vocabulary (user-facing) or handoff vocabulary (agent-facing). Pinning it as gate vocabulary keeps the audience seam consistent with the decide-lock-build rewrite's framing.

## Files added

- `docs/history/delta-ledgers/2026-05-06-post-lock-escape-and-post-impl-review.md` — this file.

## Files removed or deprecated

None.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| (no Lock → Decide reversal path; user had to pick bypass / manual abandon to escape) | Re-decide path explicit in `validate-rewrite` Approved trailer; gate-level reversal in `audience-separation.md`; new re-entry edge in `handoffs.md` | Added |
| brainstorm-design Phase 1 takes three inputs (Current scope / Future pressure / Non-goals) | brainstorm-design Phase 1 takes three required + one optional ("What we already tried" — for re-decide cycles) | Extended |
| Bypass-acknowledgment line names IMPLEMENTATION_PLAN_COVERS_DELTA bypass; no post-implementation verification imperative | Bypass-acknowledgment line names the bypass + the post-implementation verification imperative (run `cohesive:review-diff` when code lands) | Extended |
| Post-implementation review for non-canonical implementation paths is implicit (review-diff would work, but pattern is unnamed) | §"Post-implementation review entry point" in handoffs.md names the pattern with artifact-crossing / skill / verdict-gate / failure-mode contract | Promoted to substrate |

## New or updated substrate

### Specs

- `skills/validate-rewrite/SKILL.md` — fifth Re-decide alternative; tightened bypass-acknowledgment; new Re-decide acknowledgment.
- `skills/brainstorm-design/SKILL.md` — fourth optional input category "What we already tried"; expanded clarifying-question form for re-decide cycles.
- `docs/substrate/architecture/handoffs.md` — fifth Off-chain re-entry edge; new Post-implementation review entry point section.
- `docs/substrate/conventions/audience-separation.md` — gate-level reversal paragraph.

### Behavior matrices

None changed.

### Named invariants

None added, removed, strengthened, or weakened.

### Gotchas

None added or retired.

### Semantic linter specs

- A future Check 13m candidate (deferred): grep `skills/validate-rewrite/SKILL.md` §"Bypass acknowledgment" for the literal `Run cohesive:review-diff against the branch when implementation lands` substring; ensure it stays present so the bypass acknowledgment carries the post-implementation verification imperative. Promote when wording stabilizes.

### Tests / checks proposed (not yet implemented)

- Check 13m above (chain-acknowledgment-imperative grep).
- Worked-transcript demonstration of a Re-decide cycle (a brainstorm → lock → reflection-reveals-bad-design → re-decide → second brainstorm → lock → build flow). Documents the convention with a real example before promoting any structural enforcement.

## What this rewrite *did not* do

- **Implementation code:** not changed. This rewrite is docs-only; the SKILL.md bodies, conventions, and handoffs.md are themselves the implementation surface for a Cohesive plugin.
- **Verdict-vocabulary changes:** the Re-decide path is a *user override* on the existing `Approved` verdict, not a new verdict label. `validate-rewrite` continues to return `Approved` / `Issues Found` / `Design Incoherent`.
- **Validator structural enforcement:** the bypass-acknowledgment imperative and the re-decide cycle cap are convention-with-template, not validator checks. Promotion criteria in `docs/substrate/gotchas/style-guide-rot.md` apply.
- **Re-render of the centralized chat-trailer template's `(other options)` disclosure shape:** the disclosure shape itself is unchanged; this rewrite adds a fourth alternative under it. Future skills with multi-option Approved trailers can still adopt the existing disclosure pattern.

## Remaining ambiguity

- **Cap-on-re-decide-cycles enforcement.** The 2-3 cycle cap is convention; if users hit a fourth re-decide reflexively, the recommendation is "commit to a direction or cut scope" but there's no structural fence. A future delta could promote the cap to a runtime check inside `validate-rewrite` (track re-decide pass count via the discarded brainstorm's persisted file's lineage; surface a stall banner at cycle 3+).
- **External-implementation entry-point legibility.** The post-implementation review pattern is now named in `handoffs.md`, but the user discovers this only by reading handoffs.md or by being prompted by the bypass-acknowledgment line. A future delta could surface the pattern more prominently (e.g., a `cohesive:` command that explicitly verifies a branch against a delta ledger, with the delta-ledger path as a positional argument).
- **Re-decide loop's interaction with the validate-rewrite repair loop.** If a re-decide produces a new direction that locks Approved-with-Issues that drives the repair loop, the persistence shape interleaves: discarded brainstorm + discarded validation + new brainstorm + new rewrite + per-pass repair reviews. The per-pass file-naming convention (`<date>-<slug>-rewrite-validation[-pass-N].md`) handles this naturally — the new lock's slug is distinct — but contributors should know this is what the resulting `docs/history/` directory looks like for re-decide chains.
