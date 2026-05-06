# Rewrite Validation Review — skill-pack-flow-tightening (pass 3)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** 12 rewritten + 3 added specs per the 2026-05-05 skill-pack-flow-tightening delta ledger; validating against findings 1, 2, 3, 4, 5, 12 of the upstream architecture review (post repair pass 3).

**Verdict:** Issues Found

## Executive judgment

A future contributor can read these specs and add the new `using-cohesive` skill, follow the 5-step "Adding a new skill" sequence end-to-end, and understand the Skill-tool vs Task-tool dispatch split — the rewrite is structurally tight on the load-bearing surfaces this pass set out to close. One Blocker stops it being merge-ready: the §"Bootstrap status" prose in `architecture/skills.md` cites "lens-2" for the design-implementation-agreement check, while handoffs.md and the agent's own contract name the relevant lens differently. The three-label bootstrap scheme is the load-bearing innovation of repair pass 3; a reviewer reading the prose to determine which lens to apply on first-touch of a `newly-authored` row will look up a lens that does not exist.

## Delta at a glance

> [unchanged from pass-2 — the preamble describes the rewrite scope, not pass-specific repairs; see the ledger]

## Blocking issues

### B1. `architecture/skills.md` §"Bootstrap status" cites a non-existent "lens-2"

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** The three-label bootstrap scheme is the central artifact of repair pass 3. The §"Bootstrap status" prose tells the reviewer which fresh-eyes lens to apply when a `newly-authored` or `inherited` row is first touched. The prose names "lens-2 (design-implementation agreement) and lens-14 (handoff contract consistency)". Per `handoffs.md` and the spec-cohesion-reviewer's own contract, **lens 13** is the design-implementation agreement check and **lens 14** is the handoff contract consistency check. A reviewer reading skills.md to calibrate skepticism on first touch of a `newly-authored` row will look up "lens 2," find no such lens, and silently fall back to default review depth — the exact failure mode the three-label scheme exists to prevent. This is a pre-existing typo inherited into the new prose; the rewrite did not introduce it but did not catch it either.
- **Evidence:** `docs/substrate/architecture/skills.md` §"Bootstrap status" closing paragraph: "Both `inherited` and `newly-authored` sections may surface lens-2 (design-implementation agreement) and lens-14 (handoff contract consistency) drift…". Cross-reference: `docs/substrate/architecture/handoffs.md` §"Adding a new chain skill or re-entry edge" closing paragraph names lens 13 and lens 14.
- **Recommended fix:** Replace "lens-2" with "lens 13" in the §"Bootstrap status" closing paragraph. Normalize "lens-14" → "lens 14" for typographic consistency with handoffs.md's spacing. (Or, more robustly: replace the numeric citation with descriptive names that survive future lens renumbering — "the design-implementation-agreement and handoff-contract-consistency lenses".)
- **Substrate artifact to add or update:** spec (`docs/substrate/architecture/skills.md` §"Bootstrap status").

## Important issues

### I1. `using-cohesive` Owns "Carrying substrate-narrowed trigger phrases" duplicates SKILL.md Hard Constraint #5 mechanism

- **Severity:** Medium
- **Category:** Locality
- **Why it matters:** Per `skill-shape.md` §"Design layer is canonical for ownership text" the design layer is canonical and SKILL.md should reference rather than duplicate. The skills.md §"using-cohesive" Owns bullet "Carrying the substrate-narrowed trigger phrases that distinguish Cohesive's framing…" is concretely satisfied by the SKILL.md frontmatter description. SKILL.md Hard Constraint #5 ("The frontmatter description is load-bearing… substrate-vocabulary tokens… absence of bare generic-review triggers") restates the same ownership claim with verbatim mechanism details. Two surfaces, two phrasings, same claim. The convention doc says this kind of duplication drifts across release cycles — and the rewrite ships it.
- **Evidence:** `docs/substrate/architecture/skills.md` §"### using-cohesive" Owns bullet 1 vs `skills/using-cohesive/SKILL.md` Hard Constraint #5 + frontmatter description.
- **Recommended fix:** Tighten SKILL.md Hard Constraint #5 to reference the design-layer claim rather than restate the substrate-vocabulary-token list.
- **Substrate artifact to add or update:** spec (either `skills/using-cohesive/SKILL.md` or `docs/substrate/architecture/skills.md` §"### using-cohesive").

### I2. Skill-tool dispatch §"Output" template field conflates persisted vs chat trailer

- **Severity:** Medium
- **Category:** Vague language
- **Why it matters:** The convention's prompt template includes an `## Output` section with prose conflating two return surfaces — branch-side commits (structured, load-bearing) and chat output (advisory, ephemeral). A future contributor authoring a new Skill-tool dispatch will not know whether the field names the persisted artifact, the chat trailer, or both.
- **Evidence:** `docs/substrate/conventions/skill-tool-dispatch.md` §"What the dispatch prompt must contain" final code-block field + the prose right after.
- **Recommended fix:** Split the §"Output" template field into two sub-fields with labels: persisted (commits / persisted plan / file paths) vs chat trailer (the dispatched skill's chat-rendered announcement, if any).
- **Substrate artifact to add or update:** spec (`docs/substrate/conventions/skill-tool-dispatch.md`).

### I3. `skills.md` §"Adding a new skill" Step 5 array enumeration drift watcher

- **Severity:** Low
- **Category:** Vague language
- **Why it matters:** Step 5 names six validator arrays in prose; the §"Remaining ambiguity" entry in the ledger tracks the drift surface. Acceptable as a Low; ledger-noted is the right disposition. On the next validator-array change, encode the array→section mapping as a small matrix.
- **Evidence:** `docs/substrate/architecture/skills.md` §"Adding a new skill" Step 5 + ledger §"Remaining ambiguity" item 3.
- **Recommended fix:** No change this pass per the §"Remaining ambiguity" entry.
- **Substrate artifact to add or update:** ledger §"Remaining ambiguity" — already entered.

## Substrate gaps

- **Lens index for `spec-cohesion-reviewer`.** Skills.md and handoffs.md both cite specific lenses by number ("lens 13", "lens 14", "lens-2"). A canonical numbered lens index in `agents/spec-cohesion-reviewer.md` would let other docs reference lenses without restating their purpose — and would catch the B1 typo at write-time.
- **Bootstrap-status promotion procedure.** Repair pass 3 added the `newly-authored` label but the procedure for `newly-authored → validated` transition is implicit. This is review finding 10 from the upstream architecture review and is deferred per the ledger; correctly out of scope this pass.

## Locality concerns

- The new `using-cohesive` skill correctly separates orientation (advise whether) from routing (advise which) — three-altitude split is clean. The seam between `using-cohesive` and `cohesively` carries no persisted state and no verdict, which the handoff section names explicitly. Locality preserved.
- The Skill-tool vs Task-tool dispatch split is the load-bearing seam improvement of this rewrite. Cross-references in both directions are symmetric. No locality concerns.

## Future-fit concerns

- The `using-cohesive` Hard Constraints #1 and #4 are explicitly substrate-noted in `discovery-vs-superpowers.md` §"Notes for future contributors" as reviewer-judged in v0.1 — promotion path is named (real regression → structural check). Right shape; future pressure acknowledged without smuggling.
- `DISPATCH_CONTRACT_MIRROR` and `HANDOFF_VOCABULARY_PARITY` candidate-invariant deferral is well-documented; promotion criteria are crisp.

## Enforcement concerns

- Check 13i (route-name set equality) shipped this pass and the annotation surfaces match the implementation post-repair-3. Enforcement story is honest.
- The four-constraint Skill-tool dispatch contract is enforceable in principle: constraints 1 and 2 are reviewer-judged; constraint 3 is grep-auditable; constraint 4 is structurally enforced by the Task-tool harness fence. Mixed enforcement appropriate for v0.1.

## Behavior knowable outside implementation?

Yes for everything this pass touched: the 5-shape transition vocabulary, the using-cohesive orientation rule, the Skill-tool contract, the 5-step skill-addition sequence, the bootstrap-status three-label scheme.

## Vague language to tighten

- `docs/substrate/architecture/skills.md` §"Bootstrap status" — "lens-2" (B1: wrong number; also typographic form `lens-2` vs `lens 13` is inconsistent with the doc's own use of `lens 14` later in the same paragraph).
- `docs/substrate/conventions/skill-tool-dispatch.md` §"What the dispatch prompt must contain" — "the dispatched skill's chat output is structured for the loop's consumption" (I2: which structure?).

## Recommended repairs (ranked)

1. Fix B1: replace "lens-2" with "lens 13" in skills.md §"Bootstrap status"; normalize "lens-14" → "lens 14". Two-character edit; high leverage because the bootstrap-status lens-application rule is what the §"Bootstrap status" repair pass added.
2. Address I1: pick one canonical site for the substrate-vocabulary-token mechanism and have the other reference it.
3. Address I2: split the Skill-tool dispatch §"Output" template field into persisted vs chat-trailer sub-fields with worked examples for each.

## What looked right

- The five-transition-shape model in `handoffs.md` is now consistent across the opening blockquote, the heading, and every per-handoff contract section. The `audit-substrate` verdict drift fix is the demonstrated parity issue HANDOFF_VOCABULARY_PARITY would catch.
- The Skill-tool vs Task-tool split is a clean piece of substrate. Two contracts, two conventions, symmetric cross-references.
- Repair pass 3's `newly-authored` label is the right resolution to the overloaded `inherited` status — three labels, distinct semantics, one row per skill, with a forward-looking promotion criterion.
- The "Adding a new skill" 5-step sequence with explicit design / implementation / enforcement layers — and Step 5 calling out validator-array updates — closes a recurring failure class rather than the one instance that surfaced it.

### Recommended next Cohesive skill

**Disposition:** Repair → re-validate
