# Rewrite Validation Review — Cut, Anchor, Pin

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-04
**Subject:** five rewritten and five added substrate files for the cut-anchor-pin direction
**Design delta ledger:** [`docs/history/delta-ledgers/2026-05-04-cut-anchor-pin.md`](../delta-ledgers/2026-05-04-cut-anchor-pin.md)

**Status:** Issues Found

## Executive judgment

A future contributor can read these specs and understand the three-layer Cut/Anchor/Pin model, the new invariant, and the citation hook without needing the original conversation. The substrate work is genuinely tight: the gotchas, voice guide, and worked transcript form a coherent self-citing loop. Two issues block confident implementation: (1) the canonical chat-render shape disagrees with itself across `skill-conventions.md` and the worked transcript on whether the voice citation goes before or after the outermost `#` header — exactly the form of drift the validator grep ("first three non-blank lines after the section header") will be sensitive to; and (2) `PLUGIN_ROOT_PATHS.md` was left in the "preserved" set but still claims "This is the one named invariant Cohesive ships at v0.1," directly contradicting the new substrate.

## Blocking issues

### B1. Two normative docs disagree on canonical chat-render layout

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** `skill-conventions.md:83-89` shows the canonical shape with the voice-citation blockquote *before* the `# <Skill output title>` header; `output-voice-worked-example.md:71-75` shows the citation *after* the `#` title. The `VERDICT_BEFORE_EVIDENCE` invariant requires `**Verdict:**` "within the first three non-blank lines after the section header." The two layouts produce different "first three non-blank lines after the header." A skill author copying skill-conventions.md will produce a different shape than one copying the worked transcript, and a future stricter validator could pass one and fail the other. The transcript is explicitly load-bearing, so the disagreement isn't decorative.
- **Substrate artifact:** Spec (skill-conventions.md or worked transcript) + the planned `validate_plugin.sh` grep spec inside `VERDICT_BEFORE_EVIDENCE.md` §"Enforcement"
- **Suggested repair:** Pick one canonical layout. Update the other doc to match. Note the choice in the delta ledger so the implementation grep is written to the same shape.

### B2. PLUGIN_ROOT_PATHS.md still asserts "the one named invariant"

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** `PLUGIN_ROOT_PATHS.md:8` reads "This is the one named invariant Cohesive ships at v0.1." Every other normative doc in this rewrite (AGENTS.md, ARCHITECTURE.md, skill-conventions.md, VERDICT_BEFORE_EVIDENCE.md) now says two. A future contributor reading PLUGIN_ROOT_PATHS first — a plausible entry point given it's the older invariant — will be told a fact that contradicts the rest of the substrate. The delta ledger lists this file under "Files removed or deprecated: _None_" but the rewrite did need to touch it.
- **Substrate artifact:** Named invariant (PLUGIN_ROOT_PATHS.md)
- **Suggested repair:** Edit the line to say "one of two named invariants" (the other being VERDICT_BEFORE_EVIDENCE), with a cross-link. One-line change; substrate-only.

## Important issues

### I1. Reviewer-output-shape matrix ships with all five Voice-citation cells `pending`

- **Severity:** High
- **Category:** Enforcement
- **Why it matters:** The matrix is the tracked grid for drift detection, and at the moment the rewrite ships, every cell in the new column reads `pending`. The matrix itself states all five must be `✓` "after implementation," but until implementation lands, the matrix records a substrate claim that no agent file currently honors. A reader who notices the new column has no way from substrate alone to distinguish "this is queued" from "this is broken." The ledger explains it; the matrix should self-explain.
- **Substrate artifact:** Behavior matrix (reviewer-output-shape.md)
- **Suggested repair:** Move the explanatory note adjacent to the table, or split into two states (`spec-required: ✓` / `agent-file: pending`) so the matrix encodes both the rule and the implementation gap.

### I2. Voice-citation pin status is named-but-unranked

- **Severity:** Medium
- **Category:** Invariant
- **Why it matters:** The voice citation is grep-pinned by `validate_plugin.sh` (planned) but classified as convention-with-enforcement; `style-guide-rot.md:35` says it earns invariant status if it survives two release cycles without drift. But a grep-pinned rule whose failure mode is "voice rules drift silently" — the explicit failure mode named in `wordy-output.md` — meets the same bar that promoted `VERDICT_BEFORE_EVIDENCE`: clean grep, real failure mode, regression-detectable. The asymmetry needs justification or the rule needs promotion.
- **Substrate artifact:** Named invariant (decision) or convention rationale
- **Suggested repair:** Add one paragraph to AGENTS.md §"The named invariants" or to output-voice.md explaining why voice-citation is convention-not-invariant despite meeting the same bar (cleanest answer: "wording isn't fully stable yet"). Or promote it now.

### I3. "Faithful subset" is normative but undefined

- **Severity:** Medium
- **Category:** Vague language
- **Why it matters:** Rule 3 in `skill-conventions.md` and Rule 2 in `output-voice.md` both use "faithful subset of the persisted file" as the contract for chat-rendered output. Neither doc defines what makes a subset "faithful." A reviewer asked "is this chat render a faithful subset?" has no specific test to apply.
- **Substrate artifact:** Spec (output-voice.md)
- **Suggested repair:** Add one bullet to `output-voice.md` rule 2: "Faithful subset means: the verdict matches; every chat claim appears in the persisted file; chat does not introduce findings absent from the persisted file."

### I4. Worked transcript is authored, not captured

- **Severity:** Medium
- **Category:** Future-fit
- **Why it matters:** The worked transcript is positioned as load-bearing, but both renders were authored for contrast rather than captured. Future drift can rationalize the example as hypothetical. Not blocking — anti-patterns are real — but worth a substrate note that schedules the next capture.
- **Substrate artifact:** Transcript (or queue a future substrate task)
- **Suggested repair:** Add a "Captured transcripts" subsection that tracks future real captures, or a queued substrate task naming the next dogfood capture.

## Substrate gaps

- **Cross-skill question budget.** Acknowledged in `wordy-output.md:71` Notes but not encoded. Sits in "Notes" with no track-back.
- **Density-budget locality.** The per-skill density budget table in `output-voice.md:57-66` creates a hidden maintenance dependency: adding a new skill requires updating the budget row. No spec says they must.

## Locality concerns

The substrate-vs-implementation seam is well-marked. The voice-citation hook is a clean example of locality-over-centralization — one source of truth, cited once per skill, not copied. The citation pattern slightly increases context required to author a new skill (skill-conventions + reviewer-agent-template + output-voice + worked transcript). Verify the burden during the implementation pass.

## Future-fit concerns

Promotion criteria for voice-citation → invariant ("two release cycles without drift") in `style-guide-rot.md:35` is specific enough to act on. One small concern: `output-voice.md:53` references `OUTPUT_DENSITY` as a candidate name that doesn't appear elsewhere — reserve it or drop the reference.

## Enforcement concerns

`VERDICT_BEFORE_EVIDENCE.md` says "the same shape carried into the persisted artifact, if one exists" but the enforcement section only describes greps against `skills/*/SKILL.md`. If the enforcement story is "skill bodies only," say so; if broader, name the path.

## Vague language to tighten

- `references/output-voice.md:13` — "may be a faithful subset" — "may" softens a normative rule. Pick "is."
- `references/skill-conventions.md:77` — "may be a faithful subset" — same softening.
- `docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md:9` — "and to any persisted artifact the skill writes" — followed by "if any" elsewhere. Conditional unclear.

## Recommended repairs (ranked)

1. Resolve the canonical-shape disagreement (B1). Pick citation-before-`#` or citation-after-`#`; sweep both docs; write the validator grep accordingly.
2. Update `PLUGIN_ROOT_PATHS.md` (B2) to reflect the second invariant. One-line edit.
3. Tighten "faithful subset" to a testable definition (I3).
4. Decide voice-citation invariant promotion now, or document the deferral criteria explicitly (I2).
5. Improve the Voice-citation matrix column's self-explanation (I1).

## What looked right

- The three-layer Cut/Anchor/Pin framing maps cleanly across the rewritten docs.
- The two new gotchas pair self-awarely — `style-guide-rot.md` names the failure mode `wordy-output.md`'s fix could induce.
- `VERDICT_BEFORE_EVIDENCE.md` §"Known bypass risks" is exemplary (lookalike strings, embedded-example fences both named before the validator is written).
- The reviewer-output-shape matrix correctly scopes verdict-leads *out* of agent findings and explains why. That seam (agent = severity-led, skill = verdict-led) is the kind of nuance that drifts when not written down.

### Recommended next Cohesive skill

**Issues Found** — `cohesive:rewrite-specs` — repair the two blocking issues (B1 layout disagreement, B2 stale PLUGIN_ROOT_PATHS claim) plus the highest-leverage important issues (I3 "faithful subset" definition, I2 voice-citation status decision) in the same worktree, then re-run `cohesive:validate-rewrite`.
