# Rewrite Validation Review — audience seam (substrate vs decision rendering)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** the 13 rewritten + 4 added specs in `.worktrees/cohesive-audience-seam`, against the ledger at `docs/history/delta-ledgers/2026-05-06-audience-seam.md`.

**Verdict:** Issues Found

## Executive judgment

The rewrite's structural moves are sound: the centralized chat-trailer template is well-shaped, audience-separation.md names the seam clearly, verdict-vocabulary.md gives translation a single home, and rule 2a's amendment in place is the right call. But the heading-rename from `### Recommended next Cohesive skill` to `### Next` was advertised as a clean sweep and is in fact incomplete — four normative citations to the legacy heading remain across `references/templates/cohesion-review.md`, `references/cohesion-rubric.md`, `docs/substrate/architecture/handoffs.md`, and `docs/substrate/matrices/reviewer-output-shape.md`. The most damaging is `cohesion-review.md` itself: that template is what `validate-rewrite` cites as its body block, so the very chat trailer the audience seam was designed to fix would still render the methodology-name heading. A future contributor following the citation chain finds the legacy heading and reproduces the failure mode.

## Delta at a glance

This rewrite is **Mixed**. Design-layer changes: amend rule 2a in `output-voice.md` to "decision-render of the persisted body"; reword rule 5a to remove methodology-name framing; new convention `audience-separation.md`; new behavior matrix-shaped reference `verdict-vocabulary.md`; new centralized template `chat-trailer.md`. Implementation changes: six SKILL.md `## Output format` blocks rewritten to cite the centralized template + body-block specification only; cohesively router announcement template + using-cohesive orientation message rewritten to lead with outcome; reviewer-output-shape matrix extended with audience-seam-compliance section; handoffs.md gains a verdict-translation note; validate_plugin.sh Check 12 renamed; discover-substrate + rewrite-specs Output format footers renamed.

- **Files:** 13 rewritten, 4 added, 0 removed/deprecated
- **Conceptual changes:** chat-render shell centralized; methodology-name removed from chat surfaces; verdict-translation seam introduced; rule 2a "subset" → "decision-render of"; `### Recommended next Cohesive skill` → `### Next`
- **Named invariants:** `CHAT_TRAILER_VOCABULARY` (candidate, deferred); others unchanged
- **Behavior matrices:** `reviewer-output-shape.md` adds 4-column audience-seam compliance section
- **Gotchas:** none new
- **Semantic linters:** Check 12 grep target updated; Check 13k proposed (deferred)

## Blocking issues

### B1. cohesion-review.md still carries the legacy `## Recommended next Cohesive skill` heading

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** This template is `validate-rewrite`'s body block (per the rewrite's centralized chat-trailer §"Variants" `validate-rewrite` row). The rewrite's headline claim is that all chat-render templates were swept. They were not. The next reviewer rendering a validation review reads this template literally and produces the legacy heading, defeating the audience seam at the surface most visible to users.
- **Evidence:** `references/templates/cohesion-review.md:87` — `## Recommended next Cohesive skill`
- **Recommended fix:** Rename §"Recommended next Cohesive skill" to §"Next" (header level should match validate-rewrite SKILL.md `### Next`, so use `### Next`). Update the prose at lines 87–93 to match the centralized chat-trailer's `### Next` shape (decision-shaped sentence + parenthetical skill citation + payload).
- **Substrate artifact to add or update:** spec (`references/templates/cohesion-review.md`)

### B2. cohesion-rubric.md cites a section that no longer exists post-rename

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** The rubric is the canonical home of the Disposition phrase strings. It directs four downstream surfaces to cite §"Recommended next Cohesive skill" of the cohesion-review template. After B1's repair the section will be `### Next`. Without the same edit here, the rubric's citation contract breaks: the citing surfaces grep for a section name that doesn't exist.
- **Evidence:** `references/cohesion-rubric.md:126`, `:134`
- **Recommended fix:** Replace `§"Recommended next Cohesive skill"` with `§"Next"` (or `§"### Next"` per the template's resolved heading) at both lines.
- **Substrate artifact to add or update:** spec

## Important issues

### I1. handoffs.md describes the legacy heading as the current rendering

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** handoffs.md was supposedly updated for the audience seam (per the rewrite's "Files rewritten" entry adding the verdict-translation paragraph). But §"review-codebase → brainstorm-design" still claims the rendering happens in a `### Recommended next Cohesive skill` footer. A reader of the handoff contract assumes the chat trailer carries the legacy heading and authors against it.
- **Evidence:** `docs/substrate/architecture/handoffs.md:122` — "The review's `### Recommended next Cohesive skill` footer renders this recommendation per verdict."
- **Recommended fix:** Replace with "The review's `### Next` footer renders this recommendation per verdict."
- **Substrate artifact to add or update:** spec

### I2. reviewer-output-shape.md column gloss describes the legacy heading as the current test surface

- **Severity:** High
- **Category:** Spec drift / Enforcement
- **Why it matters:** The §"Synthesizing-skill chat render shape" column legend (lines 49–51) is what reviewers read to understand what the Handoff-carries-payload column tests. Saying it tests the `### Recommended next Cohesive skill` clause means a future reviewer flagging compliance grep for the wrong heading and miscounts compliance. Line 86's column header is fine — it deliberately names the legacy heading as the deviation. Line 51's normative gloss is not.
- **Evidence:** `docs/substrate/matrices/reviewer-output-shape.md:51`
- **Recommended fix:** Update the column gloss to "the skill's Output format chat trailer's `### Next` clause names the concrete inputs..."
- **Substrate artifact to add or update:** behavior matrix

### I3. Brainstorm artifact named in the dispatch input does not exist in the worktree

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** The validate-rewrite dispatch prompt names `docs/history/brainstorms/2026-05-06-audience-seam.md` as the design-rationale source. The file is absent from the worktree (only the 2026-05-04 and 2026-05-05 brainstorms exist). The ledger does not list it under "Files added." The rewrite implements Option D from a brainstorm that is not persisted in the worktree, which makes the chosen-direction-is-not-re-derived seam (handoffs.md §"brainstorm-design → rewrite-specs") rely on conversation memory.
- **Evidence:** `ls .worktrees/cohesive-audience-seam/docs/history/brainstorms/` shows the file is absent.
- **Recommended fix:** Either persist the brainstorm at the cited path with the four-option pressure-test, or add a substrate-note in the ledger §"Remaining ambiguity" stating the brainstorm was conversation-only and that the ledger preamble carries the chosen-direction substance forward.
- **Substrate artifact to add or update:** spec (the brainstorm file) or ledger annotation

### I4. SKILL.md and cited template disagree on `### Next` placement and depth

- **Severity:** Medium
- **Category:** Locality / Spec drift
- **Why it matters:** validate-rewrite SKILL.md line 187 places `### Next` inside the rendered cohesion-review block. The cohesion-review template (line 87 pre-fix) places it as `## Recommended next Cohesive skill` — a different heading depth (`##` vs `###`). After B1's fix is applied, ensure both surfaces agree on `###` depth so VERDICT_BEFORE_EVIDENCE doesn't trip and skill-shape's "header depth cap at `###`" rule holds for the chat render.
- **Evidence:** `references/templates/cohesion-review.md:87` (pre-fix `##`); `skills/validate-rewrite/SKILL.md:187` (`###`).
- **Recommended fix:** Resolve B1 by using `### Next` in cohesion-review.md to match the SKILL.md and the centralized chat-trailer template.
- **Substrate artifact to add or update:** spec

### I5. Ledger §"Conceptual changes" overstates rename completeness

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** Ledger line 109 lists the rename as a completed conceptual change. Findings B1–B2 + I1–I2 demonstrate four sites where it wasn't applied. After repairs, update the ledger so future reviewers reading the audit trail see the actual scope of the sweep.
- **Evidence:** ledger Conceptual changes table — claims `### Recommended next Cohesive skill` heading → `### Next` is a clean rename; the four citation sites (B1–B2, I1–I2) demonstrate that the rename was incomplete. Ledger §"Files rewritten" entry for handoffs.md describes one paragraph addition but does not mention the legacy-heading citation in §"review-codebase → brainstorm-design" was missed.
- **Recommended fix:** After repairing B1–B2 + I1–I2, append a §"Remaining ambiguity" note describing the cleanup or extend the §"Files rewritten" entries to enumerate the sites that needed the rename.
- **Substrate artifact to add or update:** spec (the ledger)

## Substrate gaps

- The cohesion-review template's §"Next" (post-fix) should also enumerate the per-verdict payload pattern the centralized chat-trailer template specifies; currently it only renders the Disposition phrase + matrix mechanics. Optional polish, not blocking.

## Locality concerns

The centralization of the chat trailer is a clear locality win — six skills now reference one template. The cohesion-review template is a legitimate sub-template (a body-block specification per the §"Variants" row), so the citation chain SKILL.md → chat-trailer.md → cohesion-review.md is locality-respecting once B1 lands. No new shared abstractions were created without contract.

## Behavior knowable outside implementation?

Yes once B1–B2 and I1–I2 are repaired. The audience seam is structurally clear: `audience-separation.md` names the seam, `chat-trailer.md` is the centralized shell, `verdict-vocabulary.md` is the translation table, and SKILL.md bodies cite by reference. A future contributor reading these alone could author a new verdict-led skill correctly.

## Vague language to tighten

None substantive. Rule 2a's "decision-render of the persisted body" is precise. The §"Forbidden phrasings" list in `output-voice.md` is specific.

## Recommended repairs (ranked)

1. Repair B1 (cohesion-review.md heading rename) — highest leverage; this is the surface the validate-rewrite render literally consumes.
2. Repair B2 (cohesion-rubric.md citations) in the same pass — same edit class.
3. Repair I1 (handoffs.md §"review-codebase → brainstorm-design") and I2 (reviewer-output-shape.md column gloss) in the same pass.
4. Either persist the cited brainstorm or substrate-note its absence in the ledger §"Remaining ambiguity" (I3).
5. After repairs, extend the ledger to record what was actually swept (I5).

## What looked right

- `references/templates/chat-trailer.md` is well-shaped: the §"Variants" table, the §"Vocabulary the chat trailer never uses" enumeration, and the §"Why methodology naming is removed from chat" rationale together teach voice through structure rather than rule.
- `audience-separation.md` §"How the seam is enforced" lists five forcing functions in order of structural strength — that ranking is load-bearing and exactly the right shape for a convention-with-template doc.
- `verdict-vocabulary.md` §"Why translate at the chat trailer, not earlier" gives three concrete reasons (dispatch keys, agent-facing audit trail, single-grep enforcement) that future contributors will cite when they wonder why the translation isn't in cohesion-rubric.md.
- Rule 2a amended in place rather than adding a sixth voice rule is the right call; the §"Why no rule 6 in `output-voice.md`" section in audience-separation.md anticipates the obvious counter-question and answers it.

### Next

**Disposition:** `Repair → re-validate`

The verdict-floor mapping in `references/cohesion-rubric.md` requires `Issues Found` when any `High` or `Blocker` finding is present (B1, B2 are Blocker; I1, I2 are High). Re-run `cohesive:validate-rewrite` after the rename sweep is completed.
