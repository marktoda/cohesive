# Rewrite Validation Review — Re-decide escape hatch + post-implementation review pattern

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** Re-decide escape hatch + tightened post-impl review pattern on branch `design/post-lock-escape-and-post-impl-review`; design delta ledger at `docs/history/delta-ledgers/2026-05-06-post-lock-escape-and-post-impl-review.md`

**Status:** Approved

## Architectural reflection

The rewrite is a surgical extension, not a reshape: a fifth `(other options)` alternative on the Approved trailer, a fourth (optional) input category on `brainstorm-design`, a new off-chain re-entry edge in `handoffs.md`, and a new top-level §"Post-implementation review entry point" section. The escape hatch is named in user-facing chat vocabulary (Re-decide) and agent-internal substrate (re-entry edge), and the audience seam holds.

- **Easier downstream:** The next contributor reading `validate-rewrite`'s Approved trailer can see *all* paths off the lock — including the gate-level reversal — without reconstructing what was discussed at design time. The Re-decide path is now first-class substrate, not a tribal escape route.
- **Harder downstream:** The 2-3 cycle cap is convention-only — both skill bodies cite each other for the cap, but neither owns the counting mechanic. A fresh `validate-rewrite` invocation in a new worktree can't tell whether it's pass 1 or pass 4 of a re-decide chain. The ledger discloses this as deferred; the cost is borne by reviewer attention until promoted.
- **Load-bearing on memory:** Two acknowledgment lines (Bypass + Re-decide) live in §"Output format" prose and are user-action-triggered, not verdict-triggered, so they sit outside the render-conditional rules block. Their presence depends on reviewer attention; the deferred Check 13m grep is the eventual structural fence.

## Executive judgment

The rewrite implements the approved direction faithfully and surgically. Lens 11 (preamble vs body) passes — file counts and category bullets match. Lens 12 (substrate-first) passes — design-layer changes land in `handoffs.md` and `audience-separation.md`; no skill-purpose/topology changes were performed without design-layer edits. Lens 13 (design-implementation agreement) passes — the new re-entry edge in `handoffs.md` is mirrored in both SKILL.md bodies, and cross-citations resolve. Lens 14 (handoff contract consistency) passes — no new verdict gate; the existing `Approved` token remains identical across all sites. Two Medium findings on minor drift and discoverability concerns; both are already named in §"Remaining ambiguity" as deferred.

## Delta at a glance

This rewrite is **Mixed** — primarily Design (new escape-hatch route in the user-facing flow; new substrate input category in `brainstorm-design`; new documented handoff pattern in `handoffs.md`) with implementation seams in two SKILL.md `## Output format` blocks and the audience-separation convention.

(Full preamble matches `docs/history/delta-ledgers/2026-05-06-post-lock-escape-and-post-impl-review.md` lines 9-30.)

## Important issues

### I1. `validate-rewrite` §"Composition" enumerates 3 alternatives, not 4

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** §"Output format" `(other options)` disclosure now lists four alternatives (land-specs-first / Superpowers-bypass / schedule-for-later / Re-decide). §"Composition" §"Followed by" describes only three: `"the alternatives (superpowers:writing-plans / land-specs-first / schedule-for-later)"`. A future contributor scanning the Composition section to understand what follows Approved sees the original three — Re-decide is invisible at this surface. Documents the same fact two ways and they disagree.
- **Evidence:** `skills/validate-rewrite/SKILL.md` §"Composition" "Followed by" line vs §"Output format" `(other options)` disclosure.
- **Recommended fix:** Append `Re-decide` to the parenthesized alternatives list in §"Composition" §"Followed by" — `"the alternatives (superpowers:writing-plans / land-specs-first / schedule-for-later / Re-decide)"`.
- **Substrate artifact to add or update:** spec (`skills/validate-rewrite/SKILL.md` §"Composition")

### I2. Post-implementation review entry-point legibility for non-bypass paths

- **Severity:** Medium
- **Category:** Future-fit
- **Why it matters:** `handoffs.md` §"Post-implementation review entry point" names three trigger conditions (bypass / teammate / external-tool). The pattern's own §"Where this is recommended in chat" lists exactly two surfaces — both inside `validate-rewrite`'s bypass-acknowledgment path. A teammate landing code on a `design/<slug>` branch from a non-Cohesive session, or an external tool's output, has no chat surface that names `cohesive:review-diff` as the verification entry — the user must read `handoffs.md` to discover the pattern.
- **Evidence:** `docs/substrate/architecture/handoffs.md` §"Post-implementation review entry point". The ledger §"Remaining ambiguity" item 2 names this as deferred ("External-implementation entry-point legibility").
- **Recommended fix:** Disclosure is correct (the gap is named in §"Remaining ambiguity"). For closure: a future delta could add a `cohesive:` command that explicitly verifies a branch against a delta ledger, or surface the pattern in `cohesively`'s router announcement when invoked against an existing `design/<slug>` worktree without a recent Cohesive implementation pass. No action this pass.
- **Substrate artifact to add or update:** spec (future delta — possibly a new entry point in `cohesively` router or a new `cohesive:verify-implementation` command alias)

## What looked right

- **Audience seam preserved.** The Re-decide vocabulary lands in `audience-separation.md` §"Gate-level reversal: Re-decide" as user-facing chat-surface vocabulary, with the agent-internal name (`validate-rewrite → brainstorm-design (Re-decide re-entry)`) cited rather than rendered. This is exactly the seam structure the prior decide-lock-build rewrite established.
- **Cross-skill citation discipline.** `brainstorm-design` Phase 1's "What we already tried" cites `validate-rewrite §"Re-decide acknowledgment"` for the cycle cap; `validate-rewrite`'s Re-decide acknowledgment cites `handoffs.md §"validate-rewrite → brainstorm-design (Re-decide re-entry)"`. Single source of truth for both the cap and the contract — no duplicated rules.
- **Failure-mode disclosure in handoffs.md.** The Re-decide re-entry section names three concrete failure modes (brainstorm runs without the input; reflexive re-decide on every Approved; acknowledgment line omission) with detection paths for each. This is the contract shape future contributors can act on.

### Next

**Disposition:** Close in same worktree → merge

**Implementation route — default:** Build the locked design and verify the code matches it. *(`cohesive:implement-cohesively`.)* **Scope:** the design delta ledger at `docs/history/delta-ledgers/2026-05-06-post-lock-escape-and-post-impl-review.md` and branch `design/post-lock-escape-and-post-impl-review`.

Note: This rewrite is docs-only per §"What this rewrite did not do" — closing I1 inline (a one-line edit to §"Composition") before merge; I2 is properly deferred to §"Remaining ambiguity".
