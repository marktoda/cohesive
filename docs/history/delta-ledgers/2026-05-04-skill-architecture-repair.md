# Design Delta Ledger — Skill Architecture & Agent Prompt Repair

**Date:** 2026-05-04
**Worktree / branch:** `.worktrees/cohesive-skill-arch-repair` on `design/skill-arch-repair`
**Approved direction:** Address all 12 findings from the focused skill-architecture review at [`docs/history/reviews/2026-05-04-skill-architecture-review.md`](../reviews/2026-05-04-skill-architecture-review.md). The headline failure: ALL 5 reviewer agent files were missing the token-discipline note that `references/reviewer-agent-template.md:119-121` explicitly required — observable as the two reviewers in this very review's machinery emitting ~2K-word reports each. Plus output-shape drift across 5 agents, soft-prereqs gotcha not propagated into the 3 subskills it names, no stop-condition for empty-substrate codebases, no TL;DR convention, brainstorm-design hand-off via human memory, discover-substrate triggers too generic, library-native-reviewer claiming inputs not actually passed.

**Driving review:** [`docs/history/reviews/2026-05-04-skill-architecture-review.md`](../reviews/2026-05-04-skill-architecture-review.md) (12 findings under three sub-questions: skill architecture / sharp edges / agent prompt quality)

## Files added

- `references/templates/substrate-discovery-report.md` — canonical shape for `discover-substrate` output, consumed by 5 downstream skills. Includes a "Which sections each consumer reads" map so the format can evolve without surprising any one consumer. Adds new §"Package files" section that `library-native-reviewer` requires. Documents the empty-substrate verdict line.
- `docs/substrate/matrices/reviewer-output-shape.md` — behavior matrix tracking which canonical fields each reviewer agent teaches. After this pass, all 5 agents teach the same canonical 6 fields (Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact). Prevents re-drift.
- `docs/history/reviews/2026-05-04-skill-architecture-review.md` — the architecture review report this pass implements.
- This ledger.

## Files rewritten

- `agents/spec-cohesion-reviewer.md`
  - **Before:** §"Issue format" used non-canonical keys (Risk / Substrate artifact / Suggested repair); §"What you must not do" missing canonical fresh-eyes bullet (only complementary bullet present); no token-discipline note.
  - **After:** §"Issue format (canonical six-field shape)" matches the canonical six fields and references the matrix; §"What you must not do" includes canonical fresh-eyes bullet; §"Token discipline" added with concrete bound (≤500 words / ≤8 ranked findings).
  - **Reason:** Closes Findings #8, #9, #11 from the review.

- `agents/substrate-alignment-reviewer.md`
  - **Before:** "Claim in docs / Reality in code" pair instead of canonical "Why it matters / Evidence" pair; no token-discipline note.
  - **After:** Canonical six-field shape with doc/code anchors embedded inline as part of "Why it matters" and "Evidence"; optional grouping headings explicitly marked optional; §"Token discipline" added.
  - **Reason:** Closes Findings #8, #9.

- `agents/structure-reviewer.md`
  - **Before:** Six pre-finding observation sections written as obligatory; no token-discipline note.
  - **After:** Pre-finding sections explicitly marked optional ("write 'none observed' or omit"); ranked findings is the contract; §"Token discipline" added.
  - **Reason:** Closes Findings #8, #10.

- `agents/library-native-reviewer.md`
  - **Before:** §"Inputs" claimed package files but the dispatching skill didn't pass them as discrete paths; output template missing "Category" field; six pre-finding sections obligatory; no token-discipline note.
  - **After:** §"Inputs" references the canonical substrate-discovery-report template's §"Package files"; explicit "request the dispatching skill pass package paths rather than globbing"; canonical six-field shape with Category; pre-finding sections marked optional; §"Token discipline" added; new "What you must not do" bullet forbidding glob.
  - **Reason:** Closes Findings #8, #9, #10, #12.

- `agents/agent-readiness-reviewer.md`
  - **Before:** Eight pre-finding obligatory sections; output template missing "Category" field; no token-discipline note.
  - **After:** Pre-finding sections marked optional; canonical six-field shape with Category; §"Token discipline" added.
  - **Reason:** Closes Findings #8, #9, #10.

- `skills/rewrite-specs/SKILL.md`
  - **Before:** Hard constraint #1 said "If `brainstorm-design` hasn't recommended a direction… stop and route to `brainstorm-design`" — invited the soft-prereqs failure mode (heuristic detection from session memory).
  - **After:** Hard constraint #1 names the canonical forced-choice question from the gotcha verbatim; explicit router-bypass note ("when the cohesively router invokes this skill, the router passes the chosen direction explicitly").
  - **Reason:** Closes Finding #4.

- `skills/brainstorm-design/SKILL.md`
  - **Before:** Hard constraint #2 detected discovery state from session memory; no Persistence section; chat-only output meant the brainstorm→rewrite hand-off relied on human memory; "Next Cohesive skill" heading wrong (`## Next` instead of canonical `### Recommended next`).
  - **After:** Hard constraint #2 uses the canonical forced-choice question from the gotcha; new §"Persistence" section persisting accepted recommendations to `docs/history/brainstorms/YYYY-MM-DD-<slug>.md`; canonical heading; empty-substrate-verdict handling for fresh-substrate codebases.
  - **Reason:** Closes Findings #2, #4. Also corrects the "Recommended next" heading drift (skill-conventions enforcement) noted in passing.

- `skills/cohesive-review/SKILL.md`
  - **Before:** Hard constraint #1 used heuristic prereq detection ("Or re-use its output from earlier in this session"); no Phase 1.5 sparse-substrate gate (so a 2-file fresh repo would dispatch 4 reviewers against near-empty substrate); Phase 4 synthesis schema didn't lead with TL;DR.
  - **After:** Hard constraint #1 uses canonical forced-choice question; new Phase 1.5 §"Sparse-substrate gate" stops the review and recommends `substrate-audit` when `Empty-substrate verdict: yes` is present in the discovery report or when fewer than ~5 normative documents surface; Phase 4 synthesis output now leads with TL;DR per the new conventions doc rule. Token-discipline reminder updated to note that each reviewer agent now declares its own bound (≤500 words / ≤8 findings).
  - **Reason:** Closes Findings #4, #5, #6.

- `skills/discover-substrate/SKILL.md`
  - **Before:** Description triggers were broad ("what does the codebase already remember") competing with Superpowers' research/exploration skills; output format inline-only (no canonical template); no empty-substrate-verdict handling.
  - **After:** Description narrowed to substrate-specific scope per the discovery-vs-superpowers gotcha pattern, with explicit "for general codebase exploration use Superpowers… instead" guidance; output format references the canonical `references/templates/substrate-discovery-report.md`; new Step 7 §"Detect empty-substrate codebases" emits `**Empty-substrate verdict: yes**` for sparse repos; renumbered prior Step 7 to Step 8; output schema includes the new §"Package files" section.
  - **Reason:** Closes Findings #1, #5, #7, #12.

- `references/skill-conventions.md`
  - **Before:** §"Output format conventions" had only the recommended-next-skill rule; §"Clarifying questions" defined the at-most-one rule but didn't include the canonical prereq-detection question pattern.
  - **After:** §"Output format conventions" expanded with §"TL;DR convention" — every persisted skill output renders verdict + thesis + top findings + recommended next skill as the first chat content. §"Clarifying questions" expanded with §"Canonical prereq-detection question" — the verbatim question form for skills with discovery/brainstorm prereqs, with explicit router-bypass note.
  - **Reason:** Closes Findings #4, #6.

- `README.md`
  - **Before:** §"What's in the box" templates list missing `substrate-discovery-report`.
  - **After:** Added.
  - **Reason:** Source-of-truth hierarchy.

- `ARCHITECTURE.md`
  - **Before:** §"v0.1 scope" said 8 templates.
  - **After:** 9 templates (substrate-discovery-report added).
  - **Reason:** Same — source-of-truth correctness.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| Token discipline as advisory ("bounded") in the dispatching skill | Each reviewer agent declares its own concrete numeric bound (≤500 words / ≤8 ranked findings) | Tightened. Observable failure mode (~2K-word agent reports) closed. |
| Reviewer output shape varied across 5 agents (3 different keys, 2 missing fields) | All 5 agents teach the same canonical six fields | Tightened. Synthesizer can now merge uniformly. |
| Pre-finding observation sections obligatory in 3 of 5 agents | Optional in all 5; ranked findings is the contract | Tightened. Removes structural pressure toward maximalism. |
| Subskills detect prereq state from session memory ("if discovery hasn't run yet, invoke it") | Subskills ask the user a forced-choice question; router passes state explicitly | Tightened. Closes the soft-prereqs gotcha at the implementation level for the first time. |
| `discover-substrate` output format duplicated as inline prose across 5 consumer skills | Canonical template at `references/templates/substrate-discovery-report.md` with consumer map | Promoted. Single source of truth for the universally-consumed artifact. |
| Brainstorm-design output is conversation-only; rewrite-specs needs the direction | Brainstorm persists to `docs/history/brainstorms/YYYY-MM-DD-<slug>.md` when accepted | Tightened. Hand-off no longer depends on human memory. |
| `cohesive-review --scope codebase` against fresh repo → dispatches 4 reviewers and hallucinates | Phase 1.5 sparse-substrate gate stops and recommends `substrate-audit` | Tightened. Fixes a real first-time-user pain. |
| No TL;DR for persisted skill outputs | Every persisted skill renders verdict + thesis + top findings + next skill as first chat content | New convention. |
| `discover-substrate` description competes with Superpowers' generic discovery | Description narrowed; explicit redirect to Superpowers for non-substrate exploration | Tightened per the discovery-vs-superpowers gotcha. |

## What this rewrite *did not* do

- **`validate_plugin.sh` script:** unchanged. The `PLUGIN_ROOT_PATHS` path-discipline grep remains the named "intended state" in the invariant doc; landing the actual grep is implementation work for a separate pass.
- **`docs/history/brainstorms/` directory:** not pre-created. Will be created on first use per `references/substrate-layout.md`'s "don't create empty directories preemptively" rule.
- **ARCHITECTURE.md keep-together rationale for cohesive-review codebase+diff (Finding #3 "Pass 2"):** not addressed in this pass. Deferred deliberately — the more urgent agent and skill repairs land first; documenting the existing architectural choice can wait for a follow-up.
- **Substrate-discovery `scan_substrate.py` script integration with the empty-substrate verdict:** the verdict logic lives in the skill body's Step 7 instructions, not in the script. The script's bucketing already gives Claude enough signal to decide; promoting the verdict into the script itself is V1.

## Remaining ambiguity

- **`brainstorms/` subdir under `docs/history/`:** This pass declares the path but doesn't add it to `references/substrate-layout.md`'s structure block. Worth a one-line addition in a follow-up to keep the layout doc in sync. (Soft; not blocking.)
- **The reviewer-output-shape matrix's "after-state" cells are all ✓.** This is by design — the matrix is the post-repair-pass canonical state. But fresh-eyes review may want to verify each agent file actually matches the matrix's claim. The agent files now use the same six-field block; the matrix should reflect reality, not aspiration.
- **TL;DR convention not yet retrofitted into the existing architecture-review-report template** (`references/templates/architecture-review-report.md`). The convention is in `skill-conventions.md`; the template hasn't been updated. Worth a follow-up.

## Ready for fresh-eyes review?

**Yes.** The pass is large but each edit is anchored to a specific finding from the prior review. Validator passes. The reviewer-agent corpus is now uniform on output shape and token discipline for the first time. Spec rewrite is internally consistent: 5 agents teach the same 6 fields; 3 skills use the canonical prereq question; cohesive-review has a sparse-substrate gate; the discovery output has a canonical template; brainstorm has a persistence story; conventions doc absorbs the new TL;DR rule.

## How to read this ledger

1. The architecture-review report (`2026-05-04-skill-architecture-review.md`) is the *input*: 12 findings under three sub-questions.
2. This ledger is the *output*: which findings were addressed, in which file, and why.
3. The "Conceptual changes" table is the executive summary of what changed at the level of methodology.
4. Deliberate non-changes are documented above; everything else either landed or is named in "Remaining ambiguity" for the fresh-eyes reviewer.
