# Design Delta Ledger — Audience seam (substrate vs decision rendering)

**Date:** 2026-05-06
**Worktree / branch:** `.worktrees/cohesive-audience-seam` on `design/audience-seam`
**Approved direction:** Option D from `docs/history/brainstorms/2026-05-06-audience-seam.md` — Centralized chat-trailer template + substrate-vocabulary removal + methodology-name removal from chat-render surfaces. Rule 2a amended in place; do not add a sixth voice rule. Templates teach voice more reliably than rules.

This ledger records *what changed* in the substrate during the `audience-seam` rewrite. The pass is **Mixed** per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §1a: the new convention doc and the rule 2a/5a amendments are design-shape; the centralization mechanics across six SKILL.md bodies, the new template files, and the verdict-vocabulary mapping are pure-implementation.

## Delta at a glance

This rewrite is **Mixed**. Design-layer changes: amend rule 2a in `output-voice.md` to "decision-render of the persisted body"; reword rule 5a to remove methodology-name framing; new convention `audience-separation.md`; new behavior matrix-shaped reference `verdict-vocabulary.md`; new centralized template `chat-trailer.md`. Implementation changes: six SKILL.md `## Output format` blocks rewritten to cite the centralized template + body-block specification only; cohesively router announcement template + using-cohesive orientation message rewritten to lead with outcome; reviewer-output-shape matrix extended with audience-seam-compliance section; handoffs.md gains a verdict-translation note; validate_plugin.sh Check 12 renamed (`### Recommended next Cohesive skill` → `### Next`); discover-substrate + rewrite-specs Output format footers renamed in line with the new convention. Worked transcript pair landed at `docs/history/transcripts/2026-05-06-audience-seam.md`.

- **Files:** 13 rewritten, 4 added, 0 removed/deprecated
- **Conceptual changes:** chat-render shell centralized (six skills → one template); methodology-name removed from chat-render surfaces (three sites: announcement, orientation, footer heading); verdict-translation seam introduced (internal-label → user-facing-label mapping); rule 2a "subset" framing → "decision-render of"; `### Recommended next Cohesive skill` heading → `### Next`
- **Named invariants:** `CHAT_TRAILER_VOCABULARY` (candidate, deferred per `style-guide-rot.md` promotion criteria — wording is youngest part of this rewrite); `VERDICT_BEFORE_EVIDENCE` (unchanged, still pinned); `PLUGIN_ROOT_PATHS` (unchanged); `IMPLEMENTATION_PLAN_COVERS_DELTA` (unchanged); `SKILL_DESIGN_DOC_SECTION` (unchanged)
- **Behavior matrices:** `reviewer-output-shape.md` (cells added for audience-seam compliance — 4-column matrix tracking citation + body-block + verdict-translation + heading-rename across 7 skill rows)
- **Gotchas:** none new — `style-guide-rot.md` and `naming-instead-of-showing.md` cover the failure modes; the worked transcript closes the dogfood gap
- **Semantic linters:** Check 12 grep target updated (`### Recommended next Cohesive skill` → `### Next`); Check 13k (forbidden substrate-vocabulary tokens in centralized chat-trailer template) — proposed, deferred until template wording stabilizes
- **Tests proposed:** captured-render lint on the centralized chat-trailer template literal, queued per `style-guide-rot.md` promotion criteria — none ship in this pass
- **Deferred (out of scope this pass):** Check 13k validator backing (gated on wording stability + caught regression + captured transcript); `CHAT_TRAILER_VOCABULARY` named-invariant promotion (same gate); legacy SKILL.md sweep beyond the six verdict-led skills (none other reachable from the audience seam in v0.1)

## Files rewritten

- `references/output-voice.md`
  - **Before:** Rule 2a was "Faithful subset" — the chat render is a subset of the persisted file. Rule 5 named "Recommended next Cohesive skill" as the canonical entry heading. Forbidden phrasings list did not name substrate-vocabulary leaks or methodology-name leaks.
  - **After:** Rule 2a is "Decision-render of the persisted body" — chat is the decision-rendering, not the literal subset; vocabulary differs between the two surfaces. Rule 5 names `### Next` as the canonical heading; methodology framing ("Recommended next Cohesive skill") is removed. Forbidden phrasings list adds two entries: methodology-name-as-user-label leaks, substrate-vocabulary-as-chat-token leaks. Density-budget table updated to reference user-facing verdicts and `verdict-vocabulary.md`. Related-substrate list extended with `audience-separation.md`, `chat-trailer.md`, `verdict-vocabulary.md`, and the new transcript.
  - **Reason:** Audience seam needed a structural home in the voice guide without adding a sixth rule. Amending 2a in place plus rewording 5a's framing keeps rule count at five and fixes the inconsistency where rule 2a's "subset" framing already broke under the audience seam.

- `docs/substrate/conventions/skill-shape.md`
  - **Before:** §"Output format conventions" rule 3 inlined the canonical chat-render shape; §"Recommended-next-skill footer" was the canonical heading. The anti-patterns table named "Missing 'Recommended next Cohesive skill' footer" as the regression to catch.
  - **After:** §"Output format conventions" rule 3 cites the centralized template at `references/templates/chat-trailer.md`; the inline shape is replaced with a 1-paragraph reference. §"Next-step footer (`### Next`)" is the new heading; the legacy heading is named as a deviation tracked in `reviewer-output-shape.md`. Anti-patterns table adds rows for the new compliance surfaces: legacy heading, substrate-vocabulary in Output format blocks, duplicated chat-trailer shells. Deviation entry for `validate-rewrite` updated to use `### Next`. Deviation entry for `using-cohesive` updated to use `### Next`.
  - **Reason:** SKILL.md authoring discipline must point at the centralized template and the audience-separation convention. Anti-patterns table grows by three rows tracking the new failure modes.

- `skills/cohesively/SKILL.md`
  - **Before:** Announcement template was `I'm treating this as a Cohesive **<route>** workflow: <chain>. Reason: <one short clause>.` — methodology-name-led. Required behavior #1 carried this template verbatim.
  - **After:** Announcement template leads with the outcome the user gets — e.g., `I'll explore design tradeoffs and recommend a direction: discover-substrate → brainstorm-design.` Required behavior #1 carries a per-route outcome table mapping internal route names to user-facing outcome sentences. The §"Output" code block has three concrete examples (design / review (codebase) / implement). Internal route names stay unchanged (`design`, `review (codebase)`, `review (diff)`, etc.) — they are dispatch keys for Check 13i.
  - **Reason:** The router's announcement is a chat-render surface; per the audience seam it leads with what the user gets, not the methodology name.

- `skills/using-cohesive/SKILL.md`
  - **Before:** Orientation message was `This is substrate-shaped work. I'll route through cohesive:cohesively to pick the right Cohesive workflow.` — substrate-vocabulary leak in the orientation message.
  - **After:** Orientation message is `I'll route this through cohesive:cohesively to pick the right approach.` — outcome-led, methodology-name only in the skill citation (which appears as the named entry point, not as a user-facing methodology label).
  - **Reason:** Same as router — the orientation message is the user's first contact with Cohesive in a session; it should lead with what the user gets.

- `skills/review-codebase/SKILL.md`
  - **Before:** `## Output format` duplicated the canonical chat-render shell inline; `### Recommended next Cohesive skill` was the heading; the verdict line rendered bare internal labels.
  - **After:** `## Output format` cites `references/templates/chat-trailer.md` and specifies only the body block (per the §"Variants" `review-codebase` row): `## Top findings` with three show-shape findings. `### Next` is the heading. The verdict line renders user-facing labels per `verdict-vocabulary.md`. A "Sample chat-trailer render" code block follows for concrete reference and to satisfy the VERDICT_BEFORE_EVIDENCE grep. Output discipline section updated to forbid substrate-vocabulary in chat. Phase 1.5 sparse-substrate exit message updated to use `### Next` heading.
  - **Reason:** Audience-seam centralization. The skill body now describes its body-block variant; the centralized template owns the shell.

- `skills/review-diff/SKILL.md`
  - **Before:** Same shape as review-codebase pre-rewrite — duplicated chat-render shell inline; legacy heading; bare internal verdict labels; "Suggested substrate" column in Findings table (substrate-vocabulary leak).
  - **After:** Cites the centralized template; body block is `## Findings` table per the §"Variants" `review-diff` row, with columns `Severity | Area | Evidence | Change | Doc to update` (the last column renamed from "Suggested substrate" to "Doc to update" — decision-shape: names the file the change touches in the user's repo). Sample render code block added. Output discipline updated.
  - **Reason:** Same as review-codebase. The Findings table column rename is the audience-seam structural fix for one of the largest substrate-vocabulary surfaces.

- `skills/validate-rewrite/SKILL.md`
  - **Before:** `## Output format` carried the full cohesion-review render template inline; `### Recommended next Cohesive skill` was the heading inside the template.
  - **After:** `## Output format` cites the centralized chat-trailer template + the cohesion-review template; `### Next` is the heading. The verdict line in the inline cohesion-review render template now renders the user-facing label per `verdict-vocabulary.md` (preserving the internal token so dispatch grep targets resolve). The inline template still carries the implementation-route matrix (Approved-only) and the disposition phrase derivation per the rubric.
  - **Reason:** validate-rewrite is the deviation case in the audience seam — its chat output IS the persisted review document. The seam still applies: heading rename + verdict translation. The full review body remains substrate-shape because it doubles as the agent's audit trail.

- `skills/audit-substrate/SKILL.md`
  - **Before:** `## Output format` duplicated the chat-render shell; legacy heading; bare internal verdict labels.
  - **After:** Cites the centralized template; body block is `## Top fixes` per the §"Variants" `audit-substrate` row. `### Next` is the heading. Sample render code block added. The "Where it lives" field per Top Fix uses the user's repo path (substrate-shape vocabulary in the *content* of each fix is the audience seam's recognized exception — audit produces artifact-additions, and the artifacts themselves are substrate-shape).
  - **Reason:** Same as review-codebase / review-diff. The artifact-content exception is documented inline in the Output format section.

- `skills/brainstorm-design/SKILL.md`
  - **Before:** `## Output format` rendered the same body for chat and persisted file; `## Recommendation` block included `**Required substrate before implementation:** Specs / Matrices / Named invariants / Tests / Gotchas / Semantic linters` as the trailing user-facing block. Phase 4 of the Process section required these substrate-shape items in the user-facing recommendation.
  - **After:** Phase 4 surfaces the substrate-shape "Required substrate before implementation" list in the persisted brainstorm file (agent-facing, consumed by `rewrite-specs`); the chat trailer renders only the `## Direction` block (Direction + Main risk + Structural mitigation) per the §"Variants" `brainstorm-design` row. The persisted file shape still carries the full substrate-shape body for `rewrite-specs` to consume. `### Next` is the heading.
  - **Reason:** This is the structural fix for the largest substrate-vocabulary leak the audit-substrate brainstorm surfaced. The agent still needs the substrate list to drive the next chain step (`rewrite-specs` reads it as input); the user does not need to read substrate vocabulary to approve a direction.

- `skills/implement-cohesively/SKILL.md`
  - **Before:** `## Output format` carried the canonical render template inline with `### Recommended next Cohesive skill` and bare internal verdict labels.
  - **After:** Cites the centralized template; body block is the Phases table + Delta coverage line + Final substrate review pointer + Branch state per the §"Variants" `implement-cohesively` row. `### Next` is the heading. Verdict line renders user-facing labels per `verdict-vocabulary.md`. The inline render template stays in the Output format block (this skill's body block is structural and cannot be entirely externalized).
  - **Reason:** Audience seam. The verdict translation is the larger user-facing improvement (`Implemented` → `Implementation complete`, `Phase Drift` → `A phase diverged from its plan`, etc.).

- `skills/discover-substrate/SKILL.md`
  - **Before:** `### Recommended next Cohesive skill` was the footer heading.
  - **After:** `### Next` is the footer heading. Acceptance criteria + red flag references updated to use the new heading name.
  - **Reason:** Heading rename for consistency. discover-substrate doesn't render a chat trailer (it produces a discovery report), but the footer convention applies because the validator's persisting-skills check looks for the heading.

- `skills/rewrite-specs/SKILL.md`
  - **Before:** `### Recommended next Cohesive skill` was the heading in the Output format render block.
  - **After:** `### Next` is the heading.
  - **Reason:** Heading rename for consistency.

- `docs/substrate/architecture/handoffs.md`
  - **Before:** §"Per-handoff contracts" did not document that verdict labels in the per-handoff entries are agent-facing (internal labels for dispatch logic).
  - **After:** §"Per-handoff contracts" carries a paragraph explicitly naming the boundary: handoff entries use internal labels (dispatch keys); chat-render translates via `verdict-vocabulary.md`. Internal labels in the per-handoff edge entries themselves are unchanged.
  - **Reason:** Documentation of the boundary so future contributors don't accidentally translate at the handoff layer.

- `docs/substrate/matrices/reviewer-output-shape.md`
  - **Before:** Two sections — "Per-agent finding shape" and "Synthesizing-skill chat render shape." No tracking of audience-seam compliance.
  - **After:** Three sections — adds "Audience seam compliance" with a 4-column matrix per skill (cites chat-trailer.md / body-block per Variants / verdict translation cited / `### Next` heading not legacy). Pre-rewrite cells documented as ✗ across the board.
  - **Reason:** Per-skill compliance grid for the audience seam. Reviewers consult this matrix when checking a SKILL.md edit.

## Files added

- `references/templates/chat-trailer.md` — the centralized chat-render template every verdict-led skill cites. Carries the shell (Verdict slot / Thesis slot / body block / Persisted record pointer / `### Next`) and a §"Variants" table specifying each skill's per-skill body block. Contains zero substrate-vocabulary tokens.
- `references/verdict-vocabulary.md` — internal-label → user-facing-label mapping consumed by the chat-trailer's `**Verdict:**` slot. One section per verdict-led skill plus the agent-facing rationale for translating at the chat trailer rather than at the rubric or handoff layer.
- `docs/substrate/conventions/audience-separation.md` — the convention that names the seam, points at the centralized template, lists the five forcing functions, names the validator promotion path (Check 13k deferred), and explains why no rule 6 was added to `output-voice.md`.
- `docs/history/transcripts/2026-05-06-audience-seam.md` — dated, append-only worked transcript showing the same `validate-rewrite` review rendered substrate-shape (anti-example) vs decision-shape (canonical). Analog of `output-voice-worked-example.md`.

## Files removed or deprecated

None. The audience seam is a content-removal-shaped rewrite (substrate vocabulary out of chat-render templates, methodology naming out of chat surfaces) but no files are deleted; the substrate-shape content moves into persisted-file templates and skill body prose, where it remains load-bearing.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| `### Recommended next Cohesive skill` (chat-render heading) | `### Next` (chat-render heading) | Renamed |
| Per-skill chat-render shell duplicated across 6 SKILL.md `## Output format` blocks | Centralized chat-render shell at `references/templates/chat-trailer.md`; SKILL.md bodies cite + specify body block | Centralized |
| Bare internal verdict labels in chat (`Approved`, `Substrate gaps`, `Cohesive but under-enforced`) | User-facing verdict labels translated via `verdict-vocabulary.md` (preserving internal token for dispatch grep) | Translated |
| Methodology-name in chat (`Cohesive workflow`, `Cohesive route`, `substrate-shaped work` as user-facing labels) | Outcome-shaped sentences in chat; methodology citations only in inline-code skill names parenthetically | Removed |
| `**Suggested substrate**` Findings-table column in `review-diff` | `**Doc to update**` Findings-table column — names the file in the user's repo, not Cohesive's vocabulary | Renamed |
| `**Required substrate before implementation:**` block in user-facing brainstorm Recommendation | Persisted-file-only block in brainstorm's `## Recommendation` body; chat trailer renders `## Direction` instead | Moved to persisted file |
| Voice rule 2a "faithful subset" framing | Voice rule 2a "decision-render of the persisted body" framing | Amended in place |

## New or updated substrate

### Specs
- `references/output-voice.md` — rules 2a + 5a amended in place; forbidden phrasings list extended; density-budget table refreshed; related-substrate list extended
- `docs/substrate/conventions/skill-shape.md` — §"Output format conventions" rule 3 cites the centralized template; §"Next-step footer" replaces §"Recommended-next-skill footer"; anti-patterns table grows by 3 rows; deviation entries for `validate-rewrite` and `using-cohesive` updated
- `docs/substrate/architecture/handoffs.md` — §"Per-handoff contracts" gains the verdict-translation boundary paragraph
- `docs/substrate/conventions/audience-separation.md` — new convention, normative for chat-render surfaces

### Behavior matrices
- `docs/substrate/matrices/reviewer-output-shape.md` — adds §"Audience seam compliance" with 4 columns × 7 skill rows
- `references/verdict-vocabulary.md` — new mapping table (technically a reference, not a matrix; documented as a reference because it carries decision-tree shape rather than per-cell value semantics)

### Named invariants
- `CHAT_TRAILER_VOCABULARY` — candidate; deferred per `style-guide-rot.md` promotion criteria. Promotion gated on (a) wording stability across two release cycles, (b) caught regression, (c) captured worked-transcript pair. Until then: convention + reviewer judgment.
- `VERDICT_BEFORE_EVIDENCE` — unchanged; still pinned. The chat trailer still leads with `**Verdict:**` within the first three non-blank lines after the `#` title.
- `PLUGIN_ROOT_PATHS`, `IMPLEMENTATION_PLAN_COVERS_DELTA`, `SKILL_DESIGN_DOC_SECTION` — unchanged.

### Gotchas
None new. The convention's failure modes are covered by `style-guide-rot.md` (rules far from generation drift silently — addressed by template-as-rule) and `naming-instead-of-showing.md` (substance-not-bookkeeping in chat — show-shape rule 2b survives in the centralized template).

### Semantic linter specs
- Check 12 (existing) — grep target updated from `^### Recommended next Cohesive skill` to `^### Next$`. The check fires against the same 8 persisting skills.
- Check 13k (proposed, deferred) — grep the centralized chat-trailer template literal for forbidden internal-vocabulary tokens (`Substrate gaps`, `Cohesive but under-enforced`, `Recommended next Cohesive skill` in user-facing labels, etc.). Lands when wording stable.

### Tests / checks proposed (not yet implemented)
- Captured-render lint on the centralized chat-trailer template — a real-session capture demonstrating the model produces decision-shape output when rendering the centralized template. Acceptance criteria mirror those for `output-voice-worked-example.md`'s captured transcript.

## What this rewrite *did not* do

- Implementation code: not changed (no test files, no production code in this plugin)
- Tests: not changed; specifications proposed for follow-up under Check 13k
- CI: `validate.yml` unchanged; `validate_plugin.sh` Check 12 grep target updated as part of the rewrite (this is the validator script, not CI logic)
- Frontmatter `description` strings on any skill: unchanged. Frontmatter is the trigger surface, not a render surface; Check 9a/9b's substrate-vocabulary requirement is preserved.
- Persisted-file templates in `references/templates/<skill>-report.md`: unchanged. They remain substrate-shape, agent-facing.
- Reviewer-agent internals (`agents/*-reviewer.md`): unchanged. Reviewers still produce six-field findings; the chat-trailer template renders the show-shape compression.
- The cohesion-rubric verdict-floor mapping or disposition rules: unchanged. The agent-facing rubric continues to operate on internal verdict labels.

## Repair pass 1

**Source review:** `docs/history/reviews/2026-05-06-audience-seam-rewrite-validation.md` (Issues Found, 5 ranked findings)

The forward rewrite advertised `### Recommended next Cohesive skill` → `### Next` as a clean sweep; pass-1 fresh-eyes review surfaced four citation sites the sweep missed plus one absent file. Repair pass 1 closes B1, B2, I1, I2, I3, I4, I5:

- **Closes B1** — `references/templates/cohesion-review.md:87`: renamed `## Recommended next Cohesive skill` to `### Next`. The heading depth changed from `##` to `###` to match the centralized chat-trailer template's render shell. Prose updated to cite the centralized template at `references/templates/chat-trailer.md` and the audience seam in `docs/substrate/conventions/audience-separation.md`.
- **Closes B2** — `references/cohesion-rubric.md:126,134`: replaced `§"Recommended next Cohesive skill"` citations to cohesion-review.md with `§"Next"` (matching the resolved heading).
- **Closes I1** — `docs/substrate/architecture/handoffs.md:122`: replaced `### Recommended next Cohesive skill` with `### Next` in the §"review-codebase → brainstorm-design" entry.
- **Closes I2** — `docs/substrate/matrices/reviewer-output-shape.md:51`: updated the `Handoff-carries-payload (5a)` column gloss to reference `### Next`. Added a parenthetical noting the rename happened in the audience-seam rewrite and `validate_plugin.sh` Check 12 greps the new heading.
- **Closes I3** — `docs/history/brainstorms/2026-05-06-audience-seam.md`: brainstorm persisted in the worktree (the file existed in the main repo only; pass-1 reviewer correctly flagged the absence in the design worktree because the fresh-eyes Task subprocess reads the worktree, not the main repo). The brainstorm carries the four-option pressure-test (A/B/C/D) and the chosen-direction substance, closing the chosen-direction-not-re-derived seam structurally.
- **Closes I4** — closed structurally by B1's repair (heading depth `###` matches across cohesion-review.md, validate-rewrite SKILL.md, and the centralized chat-trailer template).
- **Closes I5** — this Repair pass 1 section is the substrate residue; it enumerates what the sweep missed and what was actually swept, so future reviewers reading the audit trail see the actual scope.

The four citation sites (cohesion-review.md, cohesion-rubric.md, handoffs.md, reviewer-output-shape.md) plus the missing brainstorm artifact were the entire surface the pass-1 review flagged. No widening — the repair stayed in scope per the rewrite-specs §"Process Step 1b. Repair-pass mode" rule.

**What this repair did NOT do:**

- Re-derive the chosen direction. Option D is still the approved direction; the repairs are textual fixes against named findings, not a fresh design pass.
- Touch the design layer. All five findings were implementation-shape (heading renames + a missing artifact persistence). The classification stays Pure implementation per Step 1a.
- Sweep beyond the named findings. The forward rewrite's substrate citations were checked against the four flagged sites; no other latent legacy-heading references were found.

## Remaining ambiguity

- **Check 13k validator backing.** Deferred per `style-guide-rot.md` promotion criteria. The centralized template is one file; reviewer-judged compliance is reasonable until a real regression motivates the grep target. Re-evaluate when (a) the chat-trailer template wording is unchanged across two release cycles, (b) a regression has been caught (a SKILL.md edit reintroduces substrate vocabulary into chat-render template), and (c) the captured-render transcript meets its acceptance criteria.
- **`CHAT_TRAILER_VOCABULARY` named-invariant promotion.** Same gate as Check 13k. The structural seam (centralized template + content removal) does most of the work; named-invariant promotion is the final layer.
- **Cross-iteration verdict-trajectory rendering in the implement-cohesively `## Phases` table.** Pre-rewrite, the phases table rendered `Cross-review: Covered` (internal vocabulary). Post-rewrite, the same column carries the same value. The user-facing translation (e.g., "Phase 1: passed cross-review" instead of "Phase 1: Covered") is left out of scope this pass — the column header `Cross-review` is short enough that the value is self-explanatory in context.
- **pass-1 I3 — brainstorm absence in worktree:** Closed in repair pass 1 (file copied from main repo to worktree at `docs/history/brainstorms/2026-05-06-audience-seam.md`); the deferral surfaces here only because the fresh-eyes review read the worktree (the canonical scope) and the brainstorm needed to be there for the chosen-direction-not-re-derived seam to hold structurally. Future rewrites authored mid-conversation should persist the brainstorm in the worktree as part of the rewrite-specs forward pass, not after a reviewer flags the gap.

## Ready for fresh-eyes review?

**Yes** — the repair pass closes all five ranked findings; the validator passes 18/18 numbered checks; the four legacy-heading citation sites are resolved; the brainstorm is now in the worktree.

## How to read this ledger

1. The "Approved direction" line names Option D from the brainstorm — centralized chat-trailer template + substrate-vocabulary removal + methodology-name removal + rule 2a amended in place.
2. "Delta at a glance" carries the 8-category preamble for `validate-rewrite` to quote into the validation review.
3. "Conceptual changes" carries the 7 named conceptual moves the rewrite makes.
4. "Files rewritten" carries the per-file before/after with the design-decision driving each rewrite.
5. "Remaining ambiguity" tracks deferred items (Check 13k validator backing, named-invariant promotion, cross-iteration trajectory rendering).

The seam this rewrite implements is structural: the chat-trailer template's content enforces the audience seam more reliably than a sixth voice rule could. Templates teach voice; rules describe it. The brainstorm at `docs/history/brainstorms/2026-05-06-audience-seam.md` carries the full pressure-test trail and the discarded-option analysis (Options A/B/C considered and rejected).
