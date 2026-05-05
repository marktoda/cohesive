# Rewrite Validation Review — Voice-citation imperative pivot (Repair Pass 2)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** 6 files touched by repair pass 2 against the predecessor review's 5 findings (B1-residual, B3-residual, Drift-1, I-new-1, I-new-2)
**Predecessor review:** `docs/history/reviews/2026-05-05-voice-citation-imperative-rewrite-validation-pass2.md`
**Delta ledger:** `docs/history/delta-ledgers/2026-05-04-voice-citation-imperative.md` §"Repair pass 2 (post pass-2 validation)"

**Verdict:** Issues Found

## Executive judgment

Repair pass 2 closes 5 of 5 predecessor findings concretely and structurally — every offending paragraph has been rewritten to a canonical wording that already exists elsewhere in the substrate, and every byte-for-byte parity claim the ledger makes holds when checked at the line level. The cross-doc enumeration (PLUGIN_ROOT_PATHS:9 ↔ AGENTS.md:47 ↔ ARCHITECTURE.md:53), the verdict-line-position frame (VERDICT_BEFORE_EVIDENCE.md:12 ↔ skill-conventions.md:75 ↔ output-voice-worked-example.md:97), and the agent-placement convention (style-guide-rot.md:37 ↔ reviewer-agent-template.md:89 ↔ reviewer-output-shape.md:35) are all aligned. The Voice-section exemption at skill-conventions.md:200 now makes the matrix-legend pointer at skill-section-presence.md:11 resolve cleanly. However, the I-new-1 collapse from four to three promotion criteria left one downstream reference unmigrated: `wordy-output.md:70` still cites "the four promotion criteria" against an output-voice.md that now lists three. This is the same drift class the original pass-1 review flagged (downstream pointers not following an upstream count change), reintroduced by pass 2 itself. It is a one-line repair, but it is a Blocker because the whole pivot pass has been about making this kind of cross-doc count parity hold. Two further low-severity meta-inconsistencies are noted under "Important issues" but should not block.

## Blocking issues

### B1. `wordy-output.md:70` references "four promotion criteria" — output-voice.md now has three

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** Pass 2 collapsed output-voice.md's promotion criteria from four to three (per ledger §"I-new-1," ledger lines 275–279, output-voice.md:88–94 now enumerates three bullets and the closing line says "When all three hold, promote"). `docs/substrate/gotchas/wordy-output.md:70` reads "See `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` §'Why the voice imperative is convention-with-grep, not a named invariant' for the four promotion criteria." A contributor following this pointer counts three bullets at the destination and either (a) doubts the count, looks for a missing fourth, and re-reads the canonical home expecting more, or (b) treats the gotcha doc's count as authoritative and reintroduces a fourth criterion in a future rewrite. This is the exact failure mode pass-1 §B3 and pass-2's repair of B1-residual were designed to retire — the canonical home updates first; downstream count references must follow in the same pass. Pass 2's file list (ledger lines 287–294) does not include `wordy-output.md`.
- **Evidence:** `docs/substrate/gotchas/wordy-output.md:70` ("the four promotion criteria") vs `references/output-voice.md:88–94` (three bulleted criteria) and `references/output-voice.md:94` ("When all three hold, promote").
- **Recommended fix:** Update `wordy-output.md:70` to "the three promotion criteria" — or, more durable, rephrase as "the promotion criteria" (no count) so future criterion-count changes don't require this pointer to update. The latter is preferable; the count lives at the canonical home and pointers should not duplicate it.
- **Substrate artifact to update:** Gotcha (`wordy-output.md`).

## Important issues

### I1. `output-voice.md:5` "Note on this doc's own form" is itself a blockquote

- **Severity:** Low
- **Category:** Domain model / Vague language
- **Why it matters:** The doc's opening prose retires the blockquote-as-doc-header form, with the rationale (output-voice.md:5) "the imperative form skills and agents copy is a single line of plain prose, never a multi-line blockquote." That note is rendered as a blockquote (`>` prefix). The substantive imperative literal at line 3 is correctly plain prose, so the load-bearing claim holds. But a contributor reading the meta-note about retiring blockquotes finds it in a blockquote, and the doc's claim to "model the form it prescribes" (per ledger pass-1 §I4 line 213, "the doc that prescribes the imperative should model the form it prescribes") is undermined at exactly the moment the doc draws attention to its own form. Cosmetic, not a Blocker. Worth flagging because pass-1 made a deliberate point of this.
- **Evidence:** `references/output-voice.md:5` (blockquote line beginning `> *Note on this doc's own form:*`) vs the same line's prose ("never a multi-line blockquote").
- **Recommended fix:** Remove the `>` prefix from line 5 and italicize "Note on this doc's own form:" inline. The note becomes plain prose with a soft visual cue, and the doc's form matches its own claim.
- **Substrate artifact to update:** Spec (`output-voice.md`).

### I2. `VERDICT_BEFORE_EVIDENCE.md:96` history entry still says "lines 1–3 after title"

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** The pass-1 §B3 repair unified normative prose to "first three non-blank lines after the outermost `#` title" across five sites. The history entry at `VERDICT_BEFORE_EVIDENCE.md:96` ("greps verify *citation/verdict present in lines 1–3 after title*") preserves the older frame in a non-normative section. This is acceptable as a historical record of a prior pass, but the phrase "lines 1–3" without the "non-blank" qualifier is the exact ambiguity B3 retired — and a contributor reading the history block can carry the wrong frame back into a future edit. The entry is also stale in another way: it describes "voice-citation" greps the pivot retired. Not load-bearing for the v0.1 ship; a Low-severity tidy.
- **Evidence:** `VERDICT_BEFORE_EVIDENCE.md:96` ("greps verify *citation/verdict present in lines 1–3 after title*") vs `:12,14` ("first three non-blank lines").
- **Recommended fix:** Either prepend a clarifier ("(at the time; superseded by the 2026-05-04 voice-imperative pivot — see entry below)") or rewrite the entry to use the "first three non-blank lines" frame and note the citation-is-now-imperative migration. The history entry below at `:97` already does the migration; the polish-pass entry at `:96` can simply note its own supersession.
- **Substrate artifact to update:** Spec (`VERDICT_BEFORE_EVIDENCE.md`).

## What looked right

- **B3-residual-r2 is repaired structurally, not by hand-waving.** `output-voice-worked-example.md:97` now separates the concrete observation ("In this render it lands on the first non-blank line") from the normative frame ("within the first three non-blank lines after the title"). The parenthetical is precise: it names "non-blank lines, not raw line numbers" and explains *why* (the blank between title and verdict is a rendering choice). A contributor cross-checking the worked transcript against `VERDICT_BEFORE_EVIDENCE.md:12,14` finds the same frame in both places and the same gloss for why. This is the rare repair that makes the doc clearer than it was before the original drift.
- **Drift-1-r2 closes the failure-message-target gotcha cleanly.** `style-guide-rot.md:37` no longer claims to be the canonical home of agent placement; it links to `reviewer-agent-template.md` and `reviewer-output-shape.md` for the canonical wording. A contributor following a Check 13c failure message lands on the gotcha doc, reads the §"Correct pattern" section, follows the link to the template, and arrives at the placement convention's actual home. The single-source-of-truth chain now resolves.
- **I-new-1 is a real collapse, not a paragraph re-label.** `output-voice.md:88–94` is structurally three bullets ("Wording stability," "Caught regression," "Captured-not-authored worked transcript"), each with a checkable definition, closing with "When all three hold, promote." The pass-1 redundancy where criteria 1 and 4 tested the same thing is gone. The wording-stability criterion absorbs both pass-1 lenses into one bullet that explicitly names the dating mechanism ("dated by the imperative literal's last edit in this file").
- **I-new-2 makes the matrix-legend pointer resolve.** `skill-conventions.md:200` adds the Voice-section exemption to §"When sections may differ" — the section the matrix legend at `skill-section-presence.md:11` directs readers to. The exemption now lives where the legend says it lives.
- **B1-residual-r2 is byte-for-byte aligned.** `PLUGIN_ROOT_PATHS.md:9` reads "voice-imperative pin (body prose), anti-citation lint (render templates)" — the exact phrasing used in `AGENTS.md:47` and `ARCHITECTURE.md:53`. The three intro/enumeration sites in three different docs now match.

## Recommended repairs (ranked)

1. **Update `wordy-output.md:70`** — change "the four promotion criteria" to "the promotion criteria" (or "the three promotion criteria"). Closes B1; preserves canonical-home/pointer discipline that the whole pass has been protecting.
2. **De-blockquote `output-voice.md:5`** — the meta-note about retiring blockquotes should not itself be a blockquote. Closes I1.
3. **Tidy `VERDICT_BEFORE_EVIDENCE.md:96` history entry** — either supersede-mark it or rewrite to the new frame. Closes I2.

After the wordy-output.md fix, the pivot is structurally coherent enough to ship. I1 and I2 are polish, not drift the validator or future contributors will trip over.

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — apply the one Blocker fix (one-line edit at `wordy-output.md:70`) and the two optional polish edits in the same worktree, then re-run `cohesive:validate-rewrite`. The repair surface is three lines across three files. If the I1/I2 polish is deferred, only the Blocker is gating.
