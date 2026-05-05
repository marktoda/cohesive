# Rewrite Validation Review — Voice-citation imperative pivot (Repair Pass 1)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** 10 files touched by repair pass 1 against the predecessor review's 7 findings (B1, B2, B3, I1, I2, I3, I4)
**Predecessor review:** `docs/history/reviews/2026-05-04-voice-citation-imperative-rewrite-validation.md`
**Delta ledger:** `docs/history/delta-ledgers/2026-05-04-voice-citation-imperative.md` §"Repair pass 1 (post validation)"

**Verdict:** Issues Found

## Executive judgment

The repair pass closes 6 of 7 predecessor findings concretely, but it introduces two new drifts and fails to fully unify the line-position frame B3 specifically targeted. B1 (reviewer-agent-template), I1 (`## Voice` matrix column), I2 (agent-placement convention), I3 (captured-transcript acceptance criteria), and I4 (output-voice.md top-of-file shape + canonical home + criterion 4) are all done well — the structural reality each finding flagged has changed, not just been paragraph-asserted. B2 is mostly done but missed a co-resident file (`PLUGIN_ROOT_PATHS.md` line 9 still carries the stale "voice-citation pin" phrase in the same enumeration the AGENTS.md/ARCHITECTURE.md edits fixed). B3's claim of unification fails at one of the five sites it enumerated as repaired (`output-voice-worked-example.md:97` says "first non-blank line" while parenthetically attributing that frame to the validator and `VERDICT_BEFORE_EVIDENCE.md` — both of which use "first three"). The repair pass also introduced a *new* contradiction by giving the agent-placement convention two incompatible canonical statements (`reviewer-agent-template.md` and `reviewer-output-shape.md` say "opening prose paragraph of How to structure your output"; `style-guide-rot.md:37` says "a 'Voice' subsection of the system prompt"). These are repairable in another pass; the design itself remains coherent.

## Blocking issues

### B1-residual. `PLUGIN_ROOT_PATHS.md` line 9 still names "voice-citation pin" in the v0.1 conventions enumeration

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** The repair pass explicitly identified the "voice-citation pin" phrase in AGENTS.md/ARCHITECTURE.md as B2 and rewrote both. The same phrase appears in `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md:9` ("Other v0.1 rules (chat-render header-depth cap, density budgets, forbidden phrasings, **voice-citation pin**, fresh-eyes preamble…) live as conventions"), inside the same kind of enumeration the B2 fix targeted, in a doc that pass-1 already touched (the body lines 47–48 *were* correctly updated to "Voice-imperative check" + "Anti-citation check"). The intro paragraph wasn't. A contributor reading PLUGIN_ROOT_PATHS.md learns the demoted-to-convention list says "voice-citation" while the same doc's enforcement enumeration says "voice-imperative." Same drift class as B2; same fix.
- **Evidence:** `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md:9` vs `:47–48`. The repair-pass file list at ledger lines 225–234 does not include `PLUGIN_ROOT_PATHS.md`.
- **Recommended fix:** Replace "voice-citation pin" at `PLUGIN_ROOT_PATHS.md:9` with "voice-imperative pin (body prose), anti-citation lint (render templates)" — the exact phrasing already used in AGENTS.md:47.
- **Substrate artifact to update:** Spec (`PLUGIN_ROOT_PATHS.md`).

### B3-residual. Worked-transcript line 97 still misattributes its frame

- **Severity:** Blocker
- **Category:** Vague language / Domain model
- **Why it matters:** The repair pass said it unified five sites to "first three non-blank lines after the outermost `#` title." Four of the five now use that exact frame. The fifth — `output-voice-worked-example.md:97` — says "Verdict appears on the first non-blank line after the title (the canonical frame the validator and `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md` use…)." This is a category error: "first non-blank line" describes where verdict landed *in this particular render*; "first three non-blank lines" is the frame the validator and invariant doc actually use. By naming the validator and the invariant as the source for "first non-blank line," the worked transcript teaches a reader-cross-checking-against-the-spec that the spec says line 1 — when it says "within three." This is the exact rot B3 was supposed to retire (literal-form parity between spec, invariant, and worked transcript).
- **Evidence:** `output-voice-worked-example.md:97` says "the first non-blank line after the title (the canonical frame the validator and `VERDICT_BEFORE_EVIDENCE.md` use)" against `VERDICT_BEFORE_EVIDENCE.md:12` ("within the **first three non-blank lines**") and `:55,60,67,74` (all "first three").
- **Recommended fix:** Rewrite line 97 to "Verdict appears within the first three non-blank lines after the title (the frame the validator and `VERDICT_BEFORE_EVIDENCE.md` use). In this render it lands on the first non-blank line — the canonical shape; the three-line allowance accommodates skills that introduce a thesis line before the verdict." This separates the concrete observation (this render's line) from the normative frame (validator's three-line window).
- **Substrate artifact to update:** Spec/transcript (`output-voice-worked-example.md`).

### Drift-1 (new). Agent imperative-placement is contradicted across three docs

- **Severity:** Blocker
- **Category:** Spec drift / Locality
- **Why it matters:** The repair pass closed I2 by encoding agent-imperative placement as convention in two docs: `reviewer-agent-template.md:89` ("opening prose paragraph of its 'How to structure your output' section (above the code block, not inside it)") and `reviewer-output-shape.md:35` (same wording). But `style-guide-rot.md:37` — which the repair pass did *not* touch — describes the same convention as "in agents, in a 'Voice' subsection of the system prompt." A "Voice subsection" is a different structural shape from "opening prose paragraph of How to structure your output." A contributor reading style-guide-rot.md (the gotcha doc the validator's failure messages link to: `validate_plugin.sh:316,336`) would create a `## Voice` subsection in their new agent — the wrong shape per the canonical template, but Check 13c passes silently because it only verifies presence outside code blocks. This is not pre-existing drift the repair missed; it was *introduced* by the repair pass adopting one canonical placement statement in the new specs without aligning the existing gotcha that reaches the same convention from a different angle.
- **Evidence:** `style-guide-rot.md:37` ("in agents, in a 'Voice' subsection of the system prompt") vs `reviewer-agent-template.md:89` and `reviewer-output-shape.md:35` ("opening prose paragraph of 'How to structure your output'"). The validator failure messages at `scripts/validate_plugin.sh:316,336` direct readers to `style-guide-rot.md §"Correct pattern"` — i.e., to the doc that gives the wrong placement.
- **Recommended fix:** Update `style-guide-rot.md:37` to match the template/matrix wording: "in agents, as the opening prose paragraph of the 'How to structure your output' section, above the code block." Style-guide-rot.md should not be the canonical home of agent-side placement; it should link to `reviewer-agent-template.md` §"Output format conventions" rule 1.
- **Substrate artifact to update:** Gotcha (`style-guide-rot.md`).

## Important issues

### I-new-1. Promotion criteria 1 and 4 in `output-voice.md` are now nearly identical

- **Severity:** Medium
- **Category:** Vague language / Domain model
- **Why it matters:** The repair pass tightened promotion criterion 4 from "no further rewording is anticipated" (unfalsifiable) to "the imperative wording has not been reworded in the past two release cycles." That wording is now nearly identical to criterion 1 ("Two release cycles pass without the imperative wording changing"). The repair note at ledger line 213 acknowledges this redundancy ("structurally redundant with criterion 1 … but stated as a different lens") and retains both deliberately. The intent is reasonable but the result reads like four gates when there are really three: (a) two-release-cycle stability, (b) a real regression caught by the validator, (c) a captured transcript meeting the four acceptance criteria. Three gates stated as four invites future contributors to satisfy criterion 4 without satisfying criterion 1 (or vice versa). Either collapse 1 and 4 into one bullet, or rewrite criterion 4 to test something distinct.
- **Evidence:** `references/output-voice.md:90` (criterion 1) vs `:93` (criterion 4).
- **Recommended fix:** Either (a) collapse the two into one bullet — "the imperative wording has not been reworded for two release cycles, dated by the imperative literal in this doc and in `validate_plugin.sh` Checks 13b/13c" — or (b) make criterion 4 the *forward-looking* test ("no rewording is on the v0.2 milestone") so the two test different time-horizons.
- **Substrate artifact to update:** Spec (`output-voice.md`).

### I-new-2. The matrix's `Voice` exemption pointer doesn't resolve cleanly

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** The repair pass added a `Voice` column to `skill-section-presence.md`. The router cell is `~ (router exempt; render budget too small to need imperative)`. The legend at line 11 says `~` means "the skill uses a documented exemption (the deviation is named in `docs/substrate/designs/skill-conventions.md` §'When sections may differ')." But the new cell's exemption is documented only in `skill-conventions.md:71` ("The router (`cohesively`) is exempt from the imperative requirement…") — not in §"When sections may differ" (which is where the legend points). A reader following the legend's pointer to verify the router exemption finds the section deviations enumerated but no `Voice`-section exemption named there.
- **Evidence:** `skill-section-presence.md:11,19` (legend points at §"When sections may differ"), `skill-conventions.md:71` (the actual exemption rationale, in §"Output format conventions" rule 1, not in §"When sections may differ" lines 195–203), `skill-conventions.md:195–203` (no Voice-section entry).
- **Recommended fix:** Add one sentence to `skill-conventions.md:195–203` (§"When sections may differ"): "The router (`cohesively`) omits the `## Voice` section because its render budget is 1–2 sentences and its dispatched subskills carry the voice load on its behalf — see §'Output format conventions' rule 1." That's the doc the matrix legend points at.
- **Substrate artifact to update:** Spec (`skill-conventions.md`).

## What looked right

- **B1 is repaired structurally, not paragraph-wise.** `reviewer-agent-template.md:89–99` rewrites rule 1 entirely, swaps two anti-pattern table rows (`:160–161`) to mirror `skill-conventions.md:217–218` exactly, and adds the explicit cross-link to `reviewer-output-shape.md`'s two new columns. A contributor copying this template now produces the post-pivot shape with no leakage. This is exactly the migration pass-1 missed.
- **I1's matrix update names the validator gap honestly.** `skill-section-presence.md:28` ("Validator Check 13b greps each non-router SKILL.md body … this matrix tracks the section's *placement* — a stricter rule than the validator's grep — drift in placement is a regression to file even if Check 13b passes") is the right substrate move: the matrix says exactly which slice of the rule it tracks and which slice the validator covers. No claim that the matrix enforces what only review can catch.
- **I3's acceptance criteria are concrete and disqualifying conditions are named.** `output-voice-worked-example.md:138–149` enumerates four positive criteria (source skill named, tool-call evidence, voice-rule reflection, persistence path) plus three disqualifying conditions (partial, reconstructed, simulated). Two readers with a candidate transcript could now agree on whether it counts. This is the rare case where the gating-artifact spec is more concrete than the artifact itself.
- **I4's "Note on this doc's own form" inline retrospective is a textbook substrate-modeling move.** `output-voice.md:5` retires the doc's own blockquote and explains *why* in a paragraph that future contributors will read at the moment they're tempted to copy the wrong shape. That's how to retire a convention without leaving a deprecated note.
- **B2 in AGENTS.md/ARCHITECTURE.md is byte-for-byte aligned with `skill-conventions.md`.** AGENTS.md:64's reformulation ("the voice imperative lives in the skill body's `## Voice` section, **not** inside the Output format render template; instructions placed inside render templates leak verbatim") matches `skill-conventions.md:69` and `style-guide-rot.md:39` in framing — the contributor-orientation entry points teach the same shape the canonical specs prescribe.

## Recommended repairs (ranked)

1. **Update `style-guide-rot.md:37`** to match `reviewer-agent-template.md:89` agent-placement wording — close Drift-1 (Blocker; failure-message-linked doc currently teaches a different shape).
2. **Update `PLUGIN_ROOT_PATHS.md:9`** to replace "voice-citation pin" with the AGENTS.md:47 phrasing — close B1-residual (Blocker; same drift class B2 already fixed elsewhere).
3. **Rewrite `output-voice-worked-example.md:97`** to separate "this render's line" from "the validator's frame" — close B3-residual (Blocker; the worked transcript is the canonical exemplar, and `style-guide-rot.md:75` names byte-for-byte parity as the rule).
4. **Resolve criterion 1 vs criterion 4 in `output-voice.md:90,93`** — either collapse or differentiate. Three gates dressed as four invites future drift.
5. **Add a one-sentence Voice-section exemption to `skill-conventions.md:195–203`** so the matrix legend's pointer resolves cleanly.

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — repair the three blocking residual issues (style-guide-rot.md agent-placement, PLUGIN_ROOT_PATHS.md line 9, worked-transcript line 97) and the two important issues in the same worktree, then re-run `cohesive:validate-rewrite`. The blockers are localized prose edits; the repair surface is small.
