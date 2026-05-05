# Rewrite Validation Review — Cut, Anchor, Pin (pass 6, post repair pass 5)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-04
**Subject:** post-pass-5 substrate
**Design delta ledger:** [`../delta-ledgers/2026-05-04-cut-anchor-pin.md`](../delta-ledgers/2026-05-04-cut-anchor-pin.md)
**Prior validations:** [pass 1](2026-05-04-cut-anchor-pin-rewrite-validation.md), [pass 4](2026-05-04-cut-anchor-pin-rewrite-validation-pass4.md), [pass 5](2026-05-04-cut-anchor-pin-rewrite-validation-pass5.md)

**Status:** Approved

## Executive judgment

A future contributor — agent or human — can implement this rewrite from the docs alone. The three-layer Cut/Anchor/Pin model is legible across AGENTS.md, ARCHITECTURE.md, the skill-conventions and reviewer-agent-template designs, the new invariant, the new gotchas, the matrix, and the worked transcript. Each load-bearing claim is traceable to one canonical home (PLUGIN_ROOT_PATHS for pin enumeration; VERDICT_BEFORE_EVIDENCE for the verdict rule; output-voice for chat shape; skill-conventions for SKILL.md shape; reviewer-agent-template for agent shape). Enforcement is explicit and named, with the implementation handoff cleanly bounded. No cross-doc contradictions remain.

## Blocking issues

None.

## Important issues

None of the remaining surfaces rise to "important" — they are taste-level observations or already-deferred work.

## Substrate gaps

The three deferred gaps (captured-transcripts task; "who reads it, when?" worked example; output-voice/gotchas coupling note) are correctly filed in the ledger and inside the relevant docs themselves. None has become blocking.

## Locality concerns

The PLUGIN_ROOT_PATHS canonical-pins list now solves the prior triple-doc drift surface: AGENTS.md and skill-conventions.md cite the list rather than restating it, and the new "Shared ownership" paragraph names the update protocol with VERDICT_BEFORE_EVIDENCE.md. That is the locality fix the prior pass needed.

## Future-fit concerns

`output-voice.md` §"Why voice-citation is convention-with-grep, not a named invariant" names the promotion criteria explicitly (two release cycles, real regression caught, no further rewording). The future pressure is acknowledged but kept out of normative scope.

## Enforcement concerns

Both named invariants have stated enforcement paths: `PLUGIN_ROOT_PATHS` is currently grep-enforced; `VERDICT_BEFORE_EVIDENCE` has its grep specs documented and explicitly marked as planned-for-implementation, with the substrate-vs-implementation seam preserved. The convention pins (1–6) carry the same explicit current/planned distinction. No invariant is left as a hope.

## Behavior knowable outside implementation?

Yes. The reviewer-output-shape matrix carries the canonical six-field shape with a self-explaining cell legend. The verdict-led skill scope is enumerated in `VERDICT_BEFORE_EVIDENCE.md` "Applies to" / "Does not apply to." The worked transcript at line 73 carries the canonical voice-citation literal byte-for-byte (no backticks), matching every spec doc and the planned grep target — the pass-5 regression is closed.

## Minor observations (non-blocking, for future iteration only)

- `output-voice-worked-example.md:99` says "Verdict appears in line 5" while `VERDICT_BEFORE_EVIDENCE.md:13` and `skill-conventions.md:108` count *non-blank* lines (citation = line 1, verdict = line 2). The transcript's prose context disambiguates ("after the title and the voice citation"), so this isn't a contradiction — but a future contributor consulting both could pause. Reconcile in a minor follow-up by aligning the transcript's counting language to "non-blank lines."
- The density-budget table in `output-voice.md` is still per-skill; the maintenance dependency when adding a new skill is documented in the delta ledger but not in `output-voice.md` itself. Already deferred per pass-4 gaps.

## Vague language to tighten

None worth flagging.

## Recommended repairs (ranked)

None blocking. For the queued implementation follow-up only:

1. Land the two `validate_plugin.sh` greps (verdict-leads, voice-citation).
2. Add the voice citation line to each `skills/*/SKILL.md` Output format block and each `agents/*.md` "How to structure your output" code block.
3. Flip the five `pending` cells in the reviewer-output-shape matrix to `✓` once step 2 lands.

## What looked right

- **Shared-ownership paragraph in PLUGIN_ROOT_PATHS.md.** Naming the bidirectional update protocol between two docs that describe the same grep from different angles is exactly the substrate move that prevents future drift.
- **"Worked-example literal must match the validator grep" bullet in `style-guide-rot.md`.** Encoding the pass-5 lesson into the gotcha that warns about its own failure mode — and citing pass-5 as the worked example — is a model of how scars should be preserved.
- **Substrate-vs-implementation seam is now expressed three ways consistently.** AGENTS.md "who reads it, and when?" test, ARCHITECTURE.md three-tier-plus-substrate framing, and the file layout itself all encode the same axis. A future contributor over-pulling files into substrate (the trap pass 2 fell into) now has three independent guardrails.
- **Title-then-citation-then-verdict layout is canonical in three places that will stay aligned.** `skill-conventions.md` rule 3 specifies it as a markdown shape, `VERDICT_BEFORE_EVIDENCE.md` enumerates the three lines with grep anchors, and the worked transcript demonstrates the byte-exact form.
- **Convention-vs-invariant distinction is principled, not arbitrary.** `output-voice.md` gives two stated reasons that name the actual trade-off (literal-string pinning vs. behavior pinning). Future promotion has clear criteria.

### Recommended next Cohesive skill

**Approved** — `superpowers:writing-plans` (or `plan-implementation` in V1) — substrate is sound; implementation can proceed. The implementation work (validator greps, per-skill Output format edits, per-agent output edits) is queued in the design delta ledger §"Implementation follow-up." After implementation lands, run `cohesive:review-diff` on the result to confirm the runtime artifacts match the substrate.
