# Rewrite Validation Review — Cut, Anchor, Pin (pass 5, post repair pass 4)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-04
**Subject:** post-pass-4 substrate
**Design delta ledger:** [`../delta-ledgers/2026-05-04-cut-anchor-pin.md`](../delta-ledgers/2026-05-04-cut-anchor-pin.md)
**Prior validations:** [pass 1](2026-05-04-cut-anchor-pin-rewrite-validation.md), [pass 4](2026-05-04-cut-anchor-pin-rewrite-validation-pass4.md)

**Status:** Issues Found

## Executive judgment

The rewrite is implementable and the substrate is coherent across the four pass-4 repairs (broken links closed, convention-pin canonical list anchored in PLUGIN_ROOT_PATHS.md, README/ARCHITECTURE enumerations consistent, "who reads it, when?" test holds against the file layout). The trajectory across five passes is healthy. One issue blocks: the canonical worked transcript — the load-bearing artifact every Output format author is told to read — renders the voice-citation literal in a form that does not match the validator grep target documented in three other docs. A skill author copying the transcript verbatim ships a citation the validator will reject.

## Blocking issues

### B1. Worked transcript renders a non-canonical voice-citation literal

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** The transcript at `docs/history/transcripts/output-voice-worked-example.md:73` shows the citation as `> Voice and density: \`${CLAUDE_PLUGIN_ROOT}/references/output-voice.md\`` (path wrapped in backticks). The canonical literal — what `VERDICT_BEFORE_EVIDENCE.md:53`, `skill-conventions.md:68`, `output-voice.md` (lines 3–5), and `style-guide-rot.md:30` all specify, and the form the planned validator grep keys on — has no backticks: `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`. AGENTS.md §"Convention references" and §"When you are about to..." both tell the contributor to read this transcript before authoring an Output format block. A future contributor copies the demonstrated form, ships, and the (eventual) validator grep rejects it. The worked transcript is the very artifact that exists to anchor literal form against drift; here it's the source of drift. This is the textbook failure mode `style-guide-rot.md` documents.
- **Substrate artifact:** Spec — the worked transcript file.
- **Suggested repair:** Change line 73 to `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` (no backticks). One-character-class edit.

## Important issues

### I1. Worked transcript self-contradicts on its own provenance

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** Line 4 says "Source: dogfood transcript captured during the `cut-anchor-pin` rewrite. Real user request, both renders authored to compare." Lines 127 and 142 say the file is authored, not captured, and queue capturing a real one as future work. A contributor reading line 4 will believe a real capture already lives here; the §"Captured transcripts (queued)" section then contradicts that.
- **Substrate artifact:** Spec — the worked transcript file.
- **Suggested repair:** Change line 4's "Source:" to make the authored-for-pedagogy framing consistent — e.g., "Source: authored side-by-side example for the cut-anchor-pin rewrite. Real user request shape; both renders authored to compare. A real capture is queued — see §Captured transcripts (queued)."

### I2. PLUGIN_ROOT_PATHS canonical-pins list doesn't cross-note shared ownership

- **Severity:** Low
- **Category:** Locality
- **Why it matters:** Pin #5 (Verdict-leads) and pin #6 (Voice-citation) together are the only enforcement of `VERDICT_BEFORE_EVIDENCE`. A contributor reading VERDICT_BEFORE_EVIDENCE.md sees "two grep checks (planned)"; reading PLUGIN_ROOT_PATHS.md they see #5 and #6. Neither doc states "the canonical pin enumeration includes pins owned by other invariants." Mild locality smell.
- **Substrate artifact:** Spec.
- **Suggested repair:** In PLUGIN_ROOT_PATHS.md §"Convention pins...", add one sentence: "Pins 5 and 6 enforce surface checks owned by `VERDICT_BEFORE_EVIDENCE`; if its scope changes, update its own §Enforcement and this list together."

## Substrate gaps

- **Worked-transcript form-vs-validator handshake.** No doc names "the literal in the worked transcript MUST match the validator's grep target." The lesson of B1 is exactly that, but the substrate doesn't yet encode it. One sentence in `style-guide-rot.md` §"Notes for future contributors" would close it.
- (The three deferred gaps from pass 4 — captured-transcripts task, "who reads it, when?" worked example, output-voice/gotchas coupling note — remain explicitly deferred per the ledger; not re-flagged.)

## Locality concerns

Contributor-vs-user-facing split holds against the file layout. README's `references/` enumeration matches ARCHITECTURE's runtime-references list; both match the actual contents named in skill-conventions.md and reviewer-agent-template.md. No locality regressions introduced by the rewrite.

## Future-fit concerns

Future pressure correctly partitioned. The `output-voice.md` §"Why voice-citation is convention-with-grep" criteria do not smuggle promotion into v0.1. `wordy-output.md` §"Notes for future contributors" names the next promotion candidate without promising it. The matrix's `pending` cells distinguish queued from regression. Healthy.

## Enforcement concerns

Both named invariants ship with stated enforcement paths (validator greps, anchored on the outermost `#` title in Output format blocks). The verdict-leads grep and the voice-citation grep are *planned*, not yet wired in — documented in three places (PLUGIN_ROOT_PATHS.md "Planned (queued)", VERDICT_BEFORE_EVIDENCE.md §"Enforcement", wordy-output.md §"Tests / checks"). The substrate is honest about the gap.

## Vague language to tighten

None blocking.

## Recommended repairs (ranked)

1. Fix the worked-transcript citation literal (B1) — one-line edit, closes the contradiction between the canonical model and every other spec.
2. Reconcile the worked-transcript provenance lines (I1) — one-line edit.
3. Add the cross-noting sentence to PLUGIN_ROOT_PATHS.md's canonical-pins list (I2) — one-line edit.
4. Optional: add the "literal-must-match-validator-grep" rule to `style-guide-rot.md` §"Notes for future contributors" — closes the substrate gap that allowed B1 to land.

## What looked right

- The "who reads it, when?" test in AGENTS.md §"Substrate vs implementation" is the load-bearing move of pass 3 and it holds against the file layout cleanly.
- PLUGIN_ROOT_PATHS.md §"Convention pins enforced alongside this invariant (canonical list)" picks the right canonical home (the doc co-located with the validator) and the legend distinguishing currently-enforced from planned is the kind of small clarity move that prevents drift.
- `reviewer-output-shape.md`'s cell legend (`✓` / `pending` / `✗`) makes the matrix self-explanatory at the table.
- `style-guide-rot.md` documents the trap *the same rewrite must avoid* — a rare and load-bearing form of substrate honesty.
- The four-pass repair trajectory in the ledger is itself substrate: a future contributor doing a similar rewrite can read it as a worked example of how spec passes converge.

### Recommended next Cohesive skill

**Issues Found** — `cohesive:rewrite-specs` — repair pass 5: one-line fix on the transcript literal (B1), one-line provenance reconciliation (B1's neighbor I1), one cross-note in PLUGIN_ROOT_PATHS.md (I2), and optionally one substrate-gap closure in style-guide-rot.md. Then re-run `cohesive:validate-rewrite`.
