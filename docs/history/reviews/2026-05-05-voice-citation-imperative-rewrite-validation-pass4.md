# Rewrite Validation Review — Voice-citation imperative pivot (Repair Pass 3)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** 3 files touched by repair pass 3 against the predecessor review's 1 Blocker + 2 Low-severity findings (B1 wordy-output, I1 de-blockquote, I2 supersede-mark)
**Predecessor review:** `docs/history/reviews/2026-05-05-voice-citation-imperative-rewrite-validation-pass3.md`
**Delta ledger:** `docs/history/delta-ledgers/2026-05-04-voice-citation-imperative.md` §"Repair pass 3"

**Verdict:** Approved

## Executive judgment

Repair pass 3 closes all three predecessor findings concretely and structurally. B1 is repaired the durable way: `wordy-output.md:70` no longer cites a count at all ("the promotion criteria"), so future criterion-count changes at the canonical home do not require a downstream pointer chase — the failure mode that produced B1 in the first place. I1 is repaired structurally rather than cosmetically: the `> *Note on this doc's own form:*` blockquote at `output-voice.md:5` is now plain prose with an italicized lead, and a trailing self-referential sentence ("This note itself is rendered as plain prose for the same reason") makes the doc-models-its-claim point legible at the moment a contributor reads the note. I2 is repaired with the lighter touch the predecessor explicitly preferred — a supersede-mark inline at `VERDICT_BEFORE_EVIDENCE.md:96` rather than a history rewrite, with a precise pointer (":12,14,55,60") to the lines using the new frame. The four parity surfaces the predecessor reviewers established — cross-doc enumeration (PLUGIN_ROOT_PATHS:9 ↔ AGENTS.md:47 ↔ ARCHITECTURE.md:53), verdict-line-position frame ("first three non-blank lines" appearing at VERDICT_BEFORE_EVIDENCE:12,14,55,60 and skill-conventions.md:75,106 and output-voice-worked-example.md:97), agent placement (style-guide-rot.md → reviewer-agent-template.md:89 → reviewer-output-shape.md), and promotion-criteria count (output-voice.md:88-94 three bullets + "When all three hold") — all hold. None were broken by the three localized prose edits. The pass-3 reviewer's standing assessment ("After the wordy-output.md fix, the pivot is structurally coherent enough to ship") holds. Approved.

## Blocking issues

None.

## Important issues

None.

## What looked right

- **B1 repair is durable, not byte-for-byte.** `wordy-output.md:70` reads "for the promotion criteria" — no count. The pass-3 reviewer's recommended fix was either "the three promotion criteria" or "the promotion criteria"; this pass picked the latter, which is the more defensive choice. A future rewrite that changes the criteria count at the canonical home (`output-voice.md`) does not need to remember to update this pointer. Same fix shape as `PLUGIN_ROOT_PATHS.md`'s decision to link the canonical convention-pin enumeration rather than restating it (line 38: "this doc cites that list rather than restating it") — the substrate has a coherent "single source of truth, no count duplication" pattern, and pass 3 extends it.
- **I1 repair makes the meta-modeling self-evident.** `output-voice.md:5` now reads "*Note on this doc's own form:* this opening paragraph is plain prose, not a blockquote..." with a closing sentence that explicitly names what just happened: "This note itself is rendered as plain prose for the same reason — the doc models the form it prescribes." A contributor reading the note no longer hits the cognitive contradiction the predecessor flagged (note about retiring blockquotes presented as a blockquote). The doc-form-matches-its-claim property is now structural, not just asserted.
- **I2 repair preserves history while neutralizing the misleading frame.** `VERDICT_BEFORE_EVIDENCE.md:96`'s polish-pass entry retains its original wording ("greps verify *citation/verdict present in lines 1–3 after title*") but appends a parenthetical supersede-mark with a precise line pointer to where the canonical frame now lives ("see `:12,14,55,60`"). This is the lighter of the two options the pass-3 reviewer offered and is the right one — rewriting history entries to use later vocabulary is itself a form of substrate drift; supersede-marking is the durable shape.
- **No new drift introduced.** The three edits touch only `wordy-output.md:70`, `output-voice.md:5`, and `VERDICT_BEFORE_EVIDENCE.md:96`. None of them touch any of the four parity surfaces the prior three passes established. The promotion-criteria count remains three bullets + "When all three hold, promote" at `output-voice.md:88-94`, and `wordy-output.md:70` no longer asserts a count, so the count parity surface now has fewer enforcement points (the canonical home and nothing else) — which is the right shape.
- **Validator-aligned and review-checklist-aligned.** `VERDICT_BEFORE_EVIDENCE.md:74-79` review checklist still names "first three non-blank lines after the outermost header," "voice imperative outside any code block," and "no citation literal in Output format block" — all three reviewer-checkable items map cleanly onto Checks 13a/13b-13c/13d as enumerated at `:53-58`. The substrate's structural fence and its review-time fence agree.
- **`PLUGIN_ROOT_PATHS.md:9` and the convention-pin enumeration at `:36-52` are internally consistent.** Pin 6 names the imperative grep (body prose, outside fenced code blocks) and pin 7 names the anti-citation grep (inside render templates). The shared-ownership paragraph at `:52` correctly frames them as "two halves of one rule." Pass 3 did not touch this file; it remains aligned with AGENTS.md:47 and ARCHITECTURE.md:53.

## Recommended next Cohesive skill

Implementation. The substrate is ready to ship. The captured-not-authored worked transcript remains queued substrate gating any future promotion of the voice-imperative convention to a named invariant — that capture is the one outstanding artifact, and it can only be produced by running a verdict-led skill against a real user invocation. The right next move is `superpowers:writing-plans` (or the V1 `cohesive:plan-implementation` analog if it lands first) to scope the implementation discipline pass: verify the validator runs green in CI, confirm all 7 non-router SKILL.md `## Voice` sections and all 5 reviewer-agent imperative paragraphs are byte-for-byte aligned with the canonical literal at `output-voice.md:7`, and queue the captured-transcript work as a follow-on substrate task.
