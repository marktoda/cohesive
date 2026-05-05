# Design Delta Ledger — Architecture refactor: review-diff repair pass

**Date:** 2026-05-05
**Worktree / branch:** `.claude/worktrees/design+architecture-refactor` on `design/architecture-refactor`
**Approved direction:** Option A from `${CLAUDE_PLUGIN_ROOT}/docs/history/brainstorms/2026-05-05-architecture-refactor.md` (unchanged). The repair scope is the enumerated findings list from the `cohesive:review-diff` four-reviewer panel rendered after `implement-cohesively` Phase 3, classified as **Mixed** because the Blocker and Highs reconcile design-layer surfaces with the SKILL.md body and the spec-cohesion-reviewer agent file.
**Source review:** rendered in conversation, not separately persisted; the repair scope is captured here in §"Per-finding repairs" with each entry citing the originating finding by reviewer + severity.

This ledger records the substrate changes from the repair pass that closes the findings surfaced by `cohesive:review-diff` Phase 3 of the architecture-refactor implementation. The repair pass is a sibling artifact to the parent `2026-05-05-architecture-refactor.md` ledger; the parent covers the original Mixed rewrite plus the rewrite-side repair passes 1 and 2, and this ledger covers the review-diff-driven repair pass that followed `implement-cohesively`'s final substrate review.

## Delta at a glance

This rewrite is **Mixed**. Design-layer changes: bootstrap-status section in `architecture/skills.md`, two-fence model table in `SKILL_DESIGN_DOC_SECTION.md`, chain-exit edges in `architecture/handoffs.md`, design-layer-canonical-for-ownership rule in `skill-shape.md`, lens 13 expansion in `spec-cohesion-reviewer.md`. Implementation changes: verdict-vocabulary reconciliation between `architecture/skills.md` and `skills/implement-cohesively/SKILL.md` (the design layer's table cell was wrong; updated to match the SKILL.md's four terminals). Substrate additions: new gotcha at `gotchas/invariant-claimed-before-enforced.md` documenting the claim-before-enforce pattern that the validate-rewrite series missed.

This is the first **validated** entry in `architecture/skills.md` §"Bootstrap status" — the `implement-cohesively` per-skill section is now confirmed against its SKILL.md body via fresh-eyes review. Other sections remain `inherited` until forward rewrites reach them.

- **Files:** 7 rewritten, 1 added, 0 removed
- **Conceptual changes:** `Implemented / Drift / Incomplete` (skills.md design-layer table) → `Implemented / Phase Drift / Substrate Drift / Aborted` (matches SKILL.md); two-fence model boundary surfaces; bootstrap-status concept introduced (validated vs. inherited per-skill sections)
- **Named invariants:** `SKILL_DESIGN_DOC_SECTION` strengthened (two-fence boundary table added, first-extraction bypass risk added, bootstrap-inherited drift bypass risk added, History row noting Check 15 landing); other three unchanged
- **Behavior matrices:** none touched
- **Gotchas:** `invariant-claimed-before-enforced.md` (added) — documents the claim-before-enforce pattern
- **Semantic linters:** none added; Check 15 implementation already landed in commit `6cdae42`
- **Tests proposed:** captured-transcript test still queued for future dogfood; no new tests this pass
- **Deferred (out of scope this pass):** structure reviewer Low #3 (composition-with-superpowers asymmetry); structure reviewer Low #4 ("Why this shape" slot dual role) — both flagged as defer-until-pressure-surfaces in their findings

## Per-finding repairs

Each repair entry cites the originating finding by reviewer + severity + identifier. The four reviewers were `substrate-alignment-reviewer`, `structure-reviewer`, `library-native-reviewer` (clean — no findings), and `agent-readiness-reviewer`.

### Closes Blocker (agent-readiness): `architecture/skills.md` and `skills/implement-cohesively/SKILL.md` disagreed on terminal verdict vocabulary

**Files rewritten:**
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md`
  - **Before:** at-a-glance table cell for `implement-cohesively` Outputs verdict listed `Implemented / Drift / Incomplete`; per-skill section Owns bullet listed the same three values.
  - **After:** both surfaces list `Implemented / Phase Drift / Substrate Drift / Aborted`. The Owns bullet expands each verdict with its downstream action (Implemented → finishing-a-development-branch; Phase Drift → resume; Substrate Drift → rewrite-specs; Aborted → none) so the design layer captures the same downstream-routing semantics that `skills/implement-cohesively/SKILL.md:155-157` carries.
  - **Reason:** the original skills.md cell was authored retroactively against the SKILL.md body and conflated the per-phase reviewer verdict (Drift/Incomplete) with the skill's terminal verdict (Phase Drift / Substrate Drift / Aborted). Lens 14 didn't catch the mismatch because the verdicts in question are non-gating terminals, not chain-edge gates — exactly the gap High #3 below addresses.

### Closes High (agent-readiness): bootstrap caveat buried in history-only artifacts

**Files rewritten:**
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md`
  - **Before:** §"Per-skill sections" preamble named the regex target (`### <skill-name>`) and the named invariant; nothing about which sections were authored retroactively versus validated.
  - **After:** new §"Bootstrap status" subsection with a per-skill table tracking validated vs. inherited status. `implement-cohesively` and `rewrite-specs` are the first two sections marked validated (both confirmed via this repair cycle and the original repair passes); seven sections remain inherited. The preamble explains that inherited sections may surface predicted bootstrap drift on the first forward rewrite that touches them, and that `spec-cohesion-reviewer` reads this table during dispatch.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md`
  - **Before:** §"Known bypass risks" had three entries (section nesting, section-without-skill-dir, rename without section rename).
  - **After:** added a fourth bypass risk for bootstrap-inherited section drift, citing the §"Bootstrap status" table in skills.md as the surface that records each section's validation status.
- `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md`
  - **Before:** lens 13 (design-implementation agreement) didn't reference the bootstrap status of the section it was reviewing.
  - **After:** lens 13 preamble instructs the reviewer to read `architecture/skills.md` §"Bootstrap status" before applying the lens; flags inherited-section drift as Blocking with annotation "expected bootstrap drift on inherited section; promotion to validated status follows this repair." The reviewer's role in the bootstrap loop is now explicit.

### Closes High (agent-readiness): lens 14 contract narrower than its example

**Files rewritten:**
- `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md`
  - **Before:** lens 13(c) read "Inputs / Outputs — artifact names and verdict vocabulary match." This was satisfied by gate-verdict-only checks; non-gating terminal verdicts (the `Aborted` shape) were unlensed.
  - **After:** lens 13(c) tightened to "artifact names *and the complete verdict vocabulary* match between the design doc and the skill body, **including non-gating terminal verdicts** (verdicts a skill returns to the user that no downstream skill consumes as a prereq still count as the skill's vocabulary; lens 14 only covers gate verdicts on chain edges, so non-gating terminals must be checked here or they go unlensed)." The Blocker above was the witness for this gap.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md`
  - **Before:** §"Adding a new chain skill or re-entry edge" final paragraph described lens 3 (handoff contract consistency) without distinguishing gate verdicts from non-gating terminals.
  - **After:** the final paragraph clarifies that lens 14 covers gate verdicts only; non-gating terminals (the `Aborted` shape) are covered by lens 13 in the reviewer agent. The reader sees the seam between the two lenses without having to read the agent file.

### Closes Medium (substrate-alignment): AGENTS.md "These two are the rules" leftover

**Files rewritten:**
- `${CLAUDE_PLUGIN_ROOT}/AGENTS.md`
  - **Before:** §"The named invariants" enumerated four invariants (lines 44–47) but the closing sentence at line 49 said "These two are the rules with concrete failure modes that justify mechanical enforcement."
  - **After:** "These two" → "These four". One-token fix.

### Closes Medium (substrate-alignment): SKILL_DESIGN_DOC_SECTION.md §Enforcement claimed check not yet in validator

**Files rewritten:**
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md`
  - **Before:** §"Enforcement" said "the bash check itself is not yet in `validate_plugin.sh` as of the architecture refactor commit." This was true at the time of the original rewrite but became false when commit `6cdae42` landed Check 15.
  - **After:** §"Enforcement" rewritten to present-tense ("Check 15 in `scripts/validate_plugin.sh` enforces this invariant"). Two new History rows: one noting commit `6cdae42` closed the gap and that the claim-before-enforce pattern is documented in the new gotcha; one noting the structural changes from this repair pass.

### Closes Medium (structure): Two-fence boundary stated only in prose, not in either fence

**Files rewritten:**
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md`
  - **Before:** §"Enforcement" mentioned the validator-check enforcement; §"Scope" listed what's not enforced negatively but not as a seam diagram.
  - **After:** §"Enforcement" carries a three-row table naming the two fences (presence — this invariant; content alignment — `spec-cohesion-reviewer` lens 13) plus the third surface that has no mechanical fence (section shape, governed by `skill-shape.md` and reviewer-judged). Each row names what it owns and what triggers it; a future contributor adding a sibling check picks the row whose concern matches.

### Closes Medium (structure): Section growth policy migration silently breaks Check 15

**Files rewritten:**
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md`
  - **Before:** §"Known bypass risks" did not enumerate the first-per-skill-extraction case; §"Review checklist" had only the add/rename row.
  - **After:** new bypass-risk entry for first-extraction; new §"Review checklist" sub-section "When extracting a section to its own file" with four checklist rows (extracted file exists, parent stub replaces section, validator regex updated, validator passes). The migration is now coupled to the validator update by checklist.

### Closes Medium (agent-readiness): ARCHITECTURE.md row routes SKILL.md edits without naming the discriminator

**Files rewritten:**
- `${CLAUDE_PLUGIN_ROOT}/ARCHITECTURE.md`
  - **Before:** §"Where to look first" row "Modify a SKILL.md body (no scope or seam change)" routed to `skill-shape.md` and the closest existing skill — assumed the agent had already classified the change as implementation-shape.
  - **After:** row rewritten to instruct the agent to *first verify* the change is implementation-shape per `skill-shape.md` §"When to edit SKILL.md alone, and when to edit the design layer first"; if it is, proceed against `skill-shape.md` and the closest skill; if it's design-shape, the row points back at the "Rethink" row above. The discriminator is named explicitly so a misclassifying agent can self-correct.

### Closes Medium (agent-readiness): Invariant claimed before enforced — pattern is a footgun

**Files added:**
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/invariant-claimed-before-enforced.md` — documents the symptom (an invariant doc claims `validate_plugin.sh` enforcement; check ordinal reserved but not implemented), the wrong fix (cite the reserved ordinal as if it ran), and the correct pattern (mark §"Enforcement" with "Reserved (not yet running)" status flag plus a deferral milestone; land the bash check in the same atomic commit when feasible). Cross-references `SKILL_DESIGN_DOC_SECTION.md` History as the witness, and notes that `spec-cohesion-reviewer` lens 13 catches present-tense-vs-reserved mismatches.

### Closes Low (substrate-alignment): handoffs.md missing implement-cohesively terminal verdict exits

**Files rewritten:**
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md`
  - **Before:** §"Off-chain re-entry" had four re-entry edges (review-codebase → brainstorm; review-codebase → rewrite-specs; audit-substrate → rewrite-specs; validate-rewrite → brainstorm-design Design-Incoherent) plus the review-diff out-of-chain note. No section described `implement-cohesively`'s four terminal verdicts.
  - **After:** new §"Chain exits (implement-cohesively terminal verdicts)" with four per-verdict subsections (Implemented → finishing-a-development-branch; Phase Drift → resume; Substrate Drift → rewrite-specs; Aborted → out of chain). Each subsection follows the standard handoff-contract shape (verdict gate / downstream skill / what-not-to-rederive / failure mode). This makes lens 14 actionable for the chain's terminal edges, not just inbound transitions.

### Closes Low (structure): handoffs.md "Adding a new..." sequence ordering hazard

**Files rewritten:**
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md`
  - **Before:** §"Adding a new chain skill or re-entry edge" had a four-step sequence; cross-referenced `skills.md` §"Adding a new skill" without naming a canonical entry point. Two cross-referencing sequences with no canonical owner.
  - **After:** opening paragraph names `skills.md` as the canonical entry sequence; this section's steps are explicitly subsumed by it. The remaining steps in this section are scoped to *handoff-contract changes that don't add a skill* (e.g., adding a re-entry edge, adjusting a verdict gate). Three steps remain (handoff entry; chain diagram; router.md update if applicable).

### Closes Low (agent-readiness): Owns text duplication between skills.md and SKILL.md without non-overlap rule

**Files rewritten:**
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md`
  - **Before:** §"When to edit SKILL.md alone, and when to edit the design layer first" had the implementation-vs-design checklist and the default-to-Mixed rule, but no rule about which surface is canonical when ownership claims appear on both.
  - **After:** new paragraph at the end of the section: "Design layer is canonical for ownership text. When the same ownership claim could appear in both `architecture/skills.md` and the SKILL.md body, the design layer is canonical; the SKILL.md should reference rather than duplicate. Lens 13 checks both directions." This pairs with the lens 13 expansion in this same repair pass.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| `implement-cohesively` Outputs verdict in skills.md: `Implemented / Drift / Incomplete` | `Implemented / Phase Drift / Substrate Drift / Aborted` (matches SKILL.md) | Replaced |
| Per-skill design layer authored without a record of validated-vs-inherited status | §"Bootstrap status" table in skills.md tracks each section's status | Added |
| Two-fence model (presence + content alignment) implicit | Explicit two-fence table in `SKILL_DESIGN_DOC_SECTION.md` §"Enforcement" naming both fences and what each owns | Tightened |
| Lens 13(c) covered gate verdicts only | Lens 13(c) covers complete verdict vocabulary, including non-gating terminals | Strengthened |
| Section growth policy migration: validator regex update was implicit | First-extraction checklist row pairs migration with validator update | Tightened |
| ARCHITECTURE.md "Modify SKILL.md body" row assumed correct classification | Row instructs agent to first verify implementation-shape via skill-shape.md §"When to edit..." | Tightened |
| Skills.md vs SKILL.md ownership text duplication ungoverned | Skill-shape.md §"When to edit..." names design layer as canonical for ownership | Added |
| Claim-before-enforce pattern unrecorded | New gotcha at `gotchas/invariant-claimed-before-enforced.md` documents symptom, wrong fix, correct pattern | Added |

## What this rewrite *did not* do

- Implementation code: not changed (validator script unchanged this pass; Check 15 already landed in commit `6cdae42`).
- Tests: not changed.
- CI: not changed.
- Structure-reviewer Low #3 (composition-with-superpowers asymmetry): deferred per the reviewer's own recommendation ("revisit on next composition-touching change").
- Structure-reviewer Low #4 ("Why this shape" slot dual role): deferred per the reviewer's recommendation ("defer until a third skill is added").

## Remaining ambiguity

1. **Bootstrap promotion cycle.** Seven of nine per-skill sections remain `inherited`. Each forward rewrite that touches one of them will surface predicted bootstrap drift; the user repairs in place and the section earns validated status. The lifecycle is correct but slow; if a release pressure surfaces (e.g., a v0.2 milestone where all sections must be validated), a dedicated forward-rewrite pass per skill is the path. Not in scope this pass.
2. **`Aborted` verdict handling in the validator.** The validator can't directly check whether a skill's terminal verdicts are exhaustive; this is the kind of check lens 13 owns. If the lens-13 expansion proves insufficient (e.g., a future skill ships with a non-gating terminal not enumerated in skills.md), a structural check could grep SKILL.md output formats for verdict literals and compare against the design-layer table — deferred to v0.2 unless the gap re-surfaces.
3. **Two-fence vs three-surface clarity.** The new two-fence table names a third surface (section shape) that has no mechanical fence. A future contributor might propose graduating the section-shape rule to a fourth fence (e.g., a validator regex that checks each `### <name>` is followed by Purpose/Owns/Does-not-own/Inputs/Outputs/Why-this-shape headings). Worth discussing during the next architecture-shape-affecting pass, not this one.

## Ready for fresh-eyes review?

**Yes** — committed atomically on `design/architecture-refactor`. Validator passes (existing checks + Check 15 unchanged). All 1 Blocker + 2 High + 5 Medium + 3 Low findings from the review-diff panel are addressed; library-native-reviewer's clean verdict was the calibration baseline.

The fresh-eyes review of this repair pass should focus on:
- Lens 13: design-implementation agreement now between skills.md (with the new bootstrap-status table) and the SKILL.md bodies for the two `validated`-marked skills (`rewrite-specs`, `implement-cohesively`).
- Lens 14: handoff contract consistency for the new chain-exit edges in handoffs.md against `skills/implement-cohesively/SKILL.md` Output format.
- The new gotcha (`invariant-claimed-before-enforced.md`): does it correctly capture the symptom, tempting wrong fix, and correct pattern in a way a future contributor would apply?

## How to read this ledger

The intent is that a reviewer can:
1. Read the "Approved direction" line and confirm the repair scope is the review-diff findings (not a fresh design choice).
2. Skim "Delta at a glance" and know the rewrite is Mixed and what's in scope.
3. Skim "Per-finding repairs" with each entry citing the originating finding by reviewer + severity. Verify each finding has a corresponding repair entry.
4. Read "What this rewrite *did not* do" to confirm the deferred Low findings are explicitly acknowledged.
5. Use "Remaining ambiguity" as the focused review punch list.
