# Gotcha: Cohesive's chat output names findings and handoffs instead of showing them

## Symptom

A user invokes a Cohesive synthesizing skill — most often `cohesive:review-codebase`, `cohesive:review-diff`, or `cohesive:audit-substrate`, sometimes routed through `cohesive:cohesively` — and the chat-rendered output reads like an audit log of the review process rather than architectural critique:

- Findings are named by ID across iterations: "promote finding 7," "see finding N family," "the prior pass's deferred items"
- A promote/defer disposition table appears in the chat trailer, mapping finding IDs to actions across iterations
- Verdict-ratchet language ("verdict improved from X to Y," "ratchets to ⬆") replaces concrete observation
- "Top findings" render as a numbered list of `<title> — <one-clause why>` with no evidence and no specific change
- "Recommended next Cohesive skill" reads like `cohesive:rewrite-specs to close the 5 promoted findings` — the skill name plus a count, no payload
- A reader of the chat alone cannot answer either of: *what is the architectural defect?* / *what specifically would I change to close it?*

The persisted file is usually fine — it has the six-field finding shape with file:line evidence and recommended fixes. The chat is what fails: it carries the bookkeeping (IDs, disposition, ratchet) but not the substance, and the substance is what the user reads chat for.

The user's experience, in their own words during the 2026-05-06 iteration-2 architecture review of the skill pack: *"it says a lot of meta stuff (how the substrate is doing, finding IDs and numbers, claims and divergences etc), but almost no actual substantial architecture feedback or tangible solutions/improvements! In fact it tells me to rewrite specs but is not even super clear what are the changes I am rewriting!"*

## Why it happened

The persisted artifacts (architecture reviews, audit reports, validation reviews) accumulate state across iterations of an iterative review loop. Tracking that state is real work — finding IDs, deferral criteria, disposition over time, verdict trajectory — and the synthesizing skill has to write it somewhere. Pre-rewrite, the skills wrote it in the chat trailer alongside the substance, because the chat trailer was the "summary surface" and the bookkeeping was part of the summary. The result was that bookkeeping crowded out substance: a chat with limited space rendered the audit-log layer (which has a clear shape — a table) and lost the architecture-critique layer (which doesn't).

Specific contributing factors:

- **The "Top findings" render in `review-codebase` was `<title> — <one-clause why>`.** No evidence column, no fix column. The shape did not require showing.
- **The "Recommended next Cohesive skill" footer convention was `cohesive:<skill-name> — <one-clause reason>`.** The shape did not require payload. A reviewer saying "next: rewrite-specs" met the convention without naming a single file to edit.
- **The voice guide rule 2 ("faithful subset") tested presence, not substance.** Test: every chat claim appears in the persisted file. A chat full of "promote finding 7" passes that test trivially — the persisted file has finding 7, so the claim is faithful — even though a fresh reader cannot act on it.
- **The persisted-file/chat-trailer split was the right architecture but had no rule about *which kind* of content goes where.** Bookkeeping content (cross-iteration IDs, disposition matrices) and substantive content (this iteration's defects + fixes) both fell into "summary," and both rendered in chat by default.

## Tempting wrong fix

Add "be more specific" or "include file:line" to the voice guide and trust the model to internalize it.

Why it's wrong: the same mechanism that made "be more concise" insufficient for the wordy-output scar makes "be more specific" insufficient here. The fix has to be structural, at the rendering surface — the Output format render template that the model copies into chat. If the template requires a title-only finding row, the model produces a title-only finding row; the voice guide's prose elsewhere does not override the template at render time.

A second tempting wrong fix: keep the bookkeeping in chat but prefix it with a divider ("--- audit trail below ---") so the reader knows to skip it. Why it's wrong: the chat budget is finite. Below-the-fold content in a chat trailer is content the user paid attention-cost on; a divider doesn't change that. The persisted file is where below-the-fold content belongs.

A third tempting wrong fix: produce two chat blocks — substance first, then a collapsed bookkeeping block. Why it's wrong: the chat surface has no "collapse" affordance. Two blocks is two blocks of attention cost.

## Correct pattern

Three layers of structural enforcement, each at the surface where the failure happens.

1. **The voice guide rule 2 splits into three sub-rules.** `references/output-voice.md` rule 2 reads "the chat render is substance, not bookkeeping," with three independently-testable sub-rules: 2a (faithful subset, the original test), 2b (findings shown not named — title + evidence + change is the minimum shape), 2c (bookkeeping displaces to the persisted file — disposition matrices, finding-ID continuity, verdict-ratchet language do not appear in chat). Rule 5 grows a sub-rule 5a: the recommended-next-skill clause carries actionable payload (files, scope, or design question), not just a count.

2. **Each synthesizing skill's Output format render template requires the show-shape per finding.** `skills/review-codebase/SKILL.md` Output format renders Top findings as title + Evidence + Recommended change, not as title + one-clause why. `skills/review-diff/SKILL.md` Findings table carries an Evidence column. `skills/audit-substrate/SKILL.md` Top fixes name the artifact path and the specific content that goes in it. `skills/discover-substrate/SKILL.md` Missing memory items are concrete defects, never finding-ID family references. The render template is what the model copies; the rule lives where the model reads it.

3. **The synthesizing-skill section of [`docs/substrate/matrices/reviewer-output-shape.md`](../matrices/reviewer-output-shape.md) tracks per-skill compliance.** Three columns: shows-not-names (each finding carries title + evidence + change), bookkeeping-displaced (chat trailer carries no disposition matrix / finding-ID continuity / verdict-ratchet language), handoff-carries-payload (recommended-next clause names files / scope / design question). A `✗` in any cell is a regression filed against the matrix. The matrix is reviewed during `cohesive:review-codebase` and `cohesive:review-diff` of the skill pack itself.

## Related invariant

None promoted. The voice rule 2 is convention pinned by structural enforcement at the render-template surface and reviewer judgment at the matrix surface. Promotion criteria mirror those for the voice imperative (see `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` §"Why the voice imperative is convention-with-grep, not a named invariant"): wording stability across two release cycles, a captured regression, and a worked transcript.

A grep for the failure is hard. The pattern "a chat-rendered finding without an Evidence line" is not directly testable against a render template alone — the template uses placeholders, and the failure is in what the model produces from the template, not in the template itself. The candidate for promotion is a synthesis-skill output lint that diffs the chat render against the persisted file and flags chat findings whose substance does not appear in the persisted file's findings — but that lint requires a working captured-render before it can be specified. Until then, reviewer-output-shape matrix review is the enforcement.

## Tests / checks that preserve this

- `cohesive:review-codebase` and `cohesive:review-diff` flag chat-render bookkeeping creep as a substrate-alignment finding when reviewing the skill pack itself. Reviewer reads the relevant skill's Output format block and the most recent chat render side-by-side; bookkeeping content (disposition tables, finding-ID continuity, verdict ratchet) in the chat trailer is a regression.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` §"Synthesizing-skill chat render shape" — three columns track per-skill compliance. A `✗` cell is a tracked regression.
- `cohesive:validate-rewrite` flags Output format blocks that drop the show-shape during a rewrite as an Issues Found finding (substrate-alignment lens).
- The user's chat experience is the integration test. If the user reading chat alone cannot name the architectural defect and the change that closes it, the substance test is failing — flag it.

No structural grep enforcement ships in `scripts/validate_plugin.sh` for this gotcha as of the 2026-05-06 rewrite. The render-template/render-output diff-lint discussed above is the candidate; it ships when wording stabilizes and a captured regression earns promotion.

## When this was discovered

- Date: 2026-05-06
- Source: User feedback on the iteration-2 architecture review of the Cohesive skill pack itself (`docs/history/reviews/2026-05-06-skill-pack-flow-iteration-2-architecture-review.md`). The review's chat trailer rendered as audit log: promote/defer matrix, finding-ID references back to a 2-day-old prior review, verdict-ratchet language ("Mostly healthy ⬆ from Cohesive but under-enforced"), and a `cohesive:rewrite-specs` recommendation that named no files and no changes. The user's response was the direct quote in §"Symptom."
- One-line summary: the chat trailer rendered the audit-trail layer (legitimate content) at the cost of the architecture-critique layer (the substance the user invoked the skill for).

## Notes for future contributors

- The audit trail is real and valuable. Cross-iteration finding-ID continuity, disposition matrices, verdict ratchet — these are how a reader of review #5 in an iterative loop tracks what the loop has accomplished. The fix is not to delete that content; the fix is to put it in the persisted file's history section, where the reader who wants it can find it.
- This gotcha and `wordy-output.md` are siblings, not duplicates. Wordy-output is about *ceremony* (the render is too long, header soup, methodology recap); naming-instead-of-showing is about *substance* (the render is short enough but says nothing concrete). A render can fail one without the other. Test density and substance independently.
- The 5a payload rule is the most regression-prone part of this gotcha. A skill author can satisfy 2b (every finding shows evidence + change) and still fail 5a (the recommended-next skill is bare). When reviewing a synthesizing skill, the next-skill clause is the second test, after the per-finding shape.
- If you find yourself wanting to render bookkeeping in chat *because the persisted file path is hard to reach*, the right fix is to make the persisted file path easier to reach — render it prominently in the chat trailer's `## Persisted report` section. Bookkeeping in chat to compensate for a hard-to-reach file is a workaround for a different problem.
