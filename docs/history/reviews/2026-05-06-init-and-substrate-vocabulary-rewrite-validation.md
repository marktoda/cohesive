# Rewrite Validation Review — cohesive:init + substrate-vocabulary (pass 1)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** Phase 1 pass A on branch `design/init-and-substrate-vocabulary`; design delta ledger at `docs/history/delta-ledgers/2026-05-06-init-and-substrate-vocabulary.md`

**Status:** Issues Found

## Executive judgment

The rewrite is largely coherent: init's purpose is clear, the Rosetta Stone move is well-motivated, R017 + dispatch contract row + skills.md §"### init" + validator arrays are aligned, and lens-13/14 agreement is strong on what the rewrite did touch. Two real defects block merge: (1) substrate-vocabulary.md cites a `conventions/scope.md` negative-space doc that does not exist in this rewrite (and is explicitly deferred to sub-pass B); (2) `docs/substrate/architecture/handoffs.md` was not updated for `init`, despite skills.md §"Adding a new skill" step 2 mandating an inbound/outbound contract entry for every new skill, including non-chain ones.

## Delta at a glance

(Full preamble matches `docs/history/delta-ledgers/2026-05-06-init-and-substrate-vocabulary.md` lines 9-30.)

## Blocking issues

### B1. substrate-vocabulary.md forward-references a non-existent `conventions/scope.md`

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** `references/substrate-vocabulary.md:9` declares as a load-bearing consumer "**The negative-space doc** (`${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/scope.md`...)". That doc does not exist in this rewrite; the ledger §"What this rewrite did not do" explicitly defers it to "Phase 1 sub-pass B." Forward-references to undelivered substrate.
- **Evidence:** `references/substrate-vocabulary.md:9`; ledger lines 113-115.
- **Recommended fix:** Drop bullet 3 from substrate-vocabulary.md and re-add it in sub-pass B when scope.md lands.
- **Substrate artifact to add or update:** spec (`references/substrate-vocabulary.md`)

### B2. `docs/substrate/architecture/handoffs.md` not updated for `init`

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** `skills.md` §"Adding a new skill" step 2 mandates handoffs.md entry for every new skill, including non-chain. handoffs.md contains no `init` entry. The hand-off-to-`audit-substrate` edge described in init's Composition is not in the substrate map where chain edges live.
- **Evidence:** `skills.md:316`; `handoffs.md` (no `init` mentions); `init/SKILL.md:208-211`.
- **Recommended fix:** Add an `init` section to handoffs.md covering inbound (direct or R017), outbound (user-driven keep/reject + `git mv`), and the loose "Often followed by audit-substrate" edge.
- **Substrate artifact to add or update:** spec (`handoffs.md`)

## Important issues

### I1. Hard constraint #1's refusal list is over-broad

- **Severity:** Medium
- **Category:** Domain model
- **Why it matters:** Init refuses if `CLAUDE.md` or `AGENTS.md` exists. These are agent-handoff files present in most mature codebases that would benefit from init most. Treating them as substrate-blockers means init's primary user (a senior engineer adopting Cohesive on an existing real codebase) hits a refusal on the first run.
- **Evidence:** `init/SKILL.md:20-26`; ledger §"Remaining ambiguity" line 122.
- **Recommended fix:** Narrow the refusal list to substrate-shaped paths only (`docs/substrate/`, `docs/adr/`, `docs/design/`, `docs/decisions/` with content). Keep CLAUDE.md/AGENTS.md as detection-and-warn rather than refuse — init's step 4 (skeletal CLAUDE.md generation) already correctly skips when one exists.

### I2. "What it earns over a 'rule'" column does inconsistent load-bearing work

- **Severity:** Medium
- **Category:** Domain model
- **Why it matters:** The column is named load-bearing but two rows do real work (named invariant: "mechanical enforcement"; gotcha: "history") and the others are weak or restate the user-facing definition. The convention row uniquely re-labels the column to "what it earns over an *invariant*", breaking the column's contract.
- **Evidence:** `references/substrate-vocabulary.md:30,40,50,57,67,73`.
- **Recommended fix:** Rename the column to "What this earns" (drop the implicit "over a rule" comparison) and rewrite each cell to name the discriminator concretely. Note the convention row's inversion explicitly in §"How to read this table".

### I3. Rosetta Stone is described in prose; the chat render template only references it

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** SKILL body claims init is the Rosetta Stone but the chat-trailer §"Top translations" sample render shows only 1-line type summaries, not full translation paragraphs. Pedagogical move is in the file the user opens, not the chat the user sees first. Acceptance criteria line 193 says "chat trailer renders 3 example translations" but the sample shows summaries.
- **Evidence:** `init/SKILL.md:12,143-168,193`.
- **Recommended fix:** Commit to chat-shows-index, draft-files-show-Rosetta-Stone. Update the body Description to make the surface seam explicit ("Translation lives in the draft file the user opens; chat surfaces only the index"). Align acceptance criteria.

### I4. Bounded proposal count's user-visible signal is missing

- **Severity:** Low
- **Category:** Future-fit
- **Why it matters:** Init caps at 20 drafts but doesn't surface "init found N total signals; produced top 20" in chat. Users with 200-proto-signal codebases will assume 20 is total.
- **Evidence:** `init/SKILL.md:34,143-156,201`; ledger line 124.
- **Recommended fix:** Add "Signals scanned: N total; surfaced as drafts: M (capped at 20)" line to the chat trailer's `## Drafts produced` section.

## Substrate gaps

- No `init` row in `docs/substrate/matrices/skill-section-presence.md`. Per skills.md §"Adding a new skill" step 5, this matrix is supposed to be updated alongside the validator arrays. Lower severity than B1/B2 but should be addressed in repair.

## What looked right

- **Lens 13 agreement is strong** between skills.md `### init` and the SKILL.md body.
- **Lens 14 mirror is consistent**: R017 + dispatch-contract row + cohesively SKILL §"Dispatch prompt contract" + cohesively §"Routes" all carry matching prereq-state and one-shot semantics.
- **The "Adoption signal" routing rule** between explicit-instruction and verb-tense-cue is well-placed.
- **Ledger preamble matches the body.** No preamble divergence.
- **Pedagogical thesis is tight.** "Users learn the substrate vocabulary by watching their own code translated into it" carries the entire pass.

## Recommended repairs (ranked)

1. B1 — drop the scope.md reference from substrate-vocabulary.md.
2. B2 — add `init` to handoffs.md.
3. I1 — narrow the refusal list to substrate-shaped paths only.
4. I2 — rename and clean up the "what it earns" column.
5. I3 — commit to chat-shows-index, align body Description and acceptance criteria.
6. I4 — surface the truncation signal in chat.
7. Substrate gap — add init row to skill-section-presence.md.

### Next

**Disposition:** Repair → re-validate
