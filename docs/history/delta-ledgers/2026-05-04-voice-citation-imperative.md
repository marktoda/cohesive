# Design Delta Ledger — Voice-citation imperative pivot

**Date:** 2026-05-04
**Worktree / branch:** `.worktrees/cohesive-voice-citation-imperative` on `design/voice-citation-imperative`
**Approved direction:** Option A — Imperative load in skill body. Each non-router SKILL.md and each reviewer agent gains a body-level imperative `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` The `> Voice and density: …` literal is removed from every Output format / "How to structure your output" code block. Validator Checks 13b/13c retarget from "citation present in render template" to "imperative present in body"; new Check 13d lints for absence of the citation literal inside render templates.
**Brainstorm:** [`docs/history/brainstorms/2026-05-04-voice-citation-loading-vs-rendering.md`](../brainstorms/2026-05-04-voice-citation-loading-vs-rendering.md)

## Why this rewrite exists

The `cut-anchor-pin` rewrite (2026-05-04, earlier same day) introduced a load-bearing convention: every non-router skill's Output format block opened with `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`, on the stated theory that the citation pulled the voice guide into the rendering model's context. Every reviewer agent's "How to structure your output" code block carried the same line.

That theory was wrong. A markdown blockquote is text, not a file load — placing the citation inside the Output format block (which is a render template the model reproduces in user-facing output) caused the citation to appear in user-facing chat without triggering any read of `output-voice.md`. The convention was doubly broken: ineffective at loading, and visible to users in a way the user objected to.

The pivot moves the load directive out of the render template and into skill/agent body prose as an imperative — `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` — that the model executes via a Read tool call. The render template stays a pure template (no instructions, no citation literal), so nothing in it can leak to users. The validator's grep target migrates from "citation present in template" to "imperative present in body," and a new anti-citation lint fails if any render template carries the citation literal — the inverse check that catches half-migrations.

## Files rewritten

- `references/output-voice.md`
  - **Before:** Top-of-file blockquote claimed the citation in each skill's Output format block was the load-bearing line that pulled the voice guide into context at generation time. §"How this guide is used" repeated the claim. §"Why voice-citation is convention-with-grep" listed three promotion criteria keyed on the citation literal.
  - **After:** Top-of-file blockquote describes the imperative-in-body mechanism: each non-router SKILL.md and each reviewer agent carries `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` in body prose; the imperative is what triggers a Read tool call; the Output format / "How to structure your output" code block is a pure render template with no instructions and no citation literal. §"How this guide is used" rewritten to describe the imperative as the load mechanism. §"Why voice-citation…" renamed to §"Why the voice imperative is convention-with-grep, not a named invariant" with promotion criteria updated (now four; added "captured-not-authored worked transcript demonstrating the model executes the Read at render time").
  - **Reason:** The load-bearing claim shifted from citation to imperative; the doc had to follow.

- `docs/substrate/designs/skill-conventions.md`
  - **Before:** §"Output format conventions" rule 1 was "The voice citation appears immediately under the outermost output title." Required canonical render: title, citation blockquote, optional verdict. Anti-pattern table flagged "Output format block missing the voice citation line." Top-of-file paragraph asserted "Every Output format block in this repo opens with a one-line citation pulling that guide into context."
  - **After:** Rule 1 renamed to "The voice imperative lives in the skill body; the Output format block is a pure render template." Imperative literal placed in body prose in a `## Voice` section; render template stays clean. Canonical chat-render shape simplified to title-then-verdict (no citation line). Rule 2 prose updated to clarify non-verdict skills carry the imperative in body, not citation in template. Rule 5's "Recommended-next-skill footer" prose retained but the router-exemption sentence now references rule 1's new shape. Anti-pattern table swapped one row ("Output format block missing the voice citation line") for two new rows ("Skill body missing the voice imperative" and "Voice citation literal placed inside the Output format code block"). Top-of-file paragraph rewritten to describe the imperative.
  - **Reason:** This doc is the canonical source for SKILL.md shape; the pivot's first-class consumer.

- `docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`
  - **Before:** §"Rule" enumerated three lines (title, voice citation, verdict) and asserted the canonical title-then-citation-then-verdict layout placed citation on line 1 and verdict on line 2. §"Enforcement" described three checks (13a verdict-leads, 13b citation-in-skill-template, 13c citation-in-agent-template) and explained the checks anchor on the outermost `#` title inside a fenced code block. §"Review checklist" included "Does the skill's Output format block carry the voice citation line?".
  - **After:** §"Rule" enumerates two lines (title, verdict). The voice guide load mechanism is described in a separate paragraph: it is the body-level imperative, not the citation. Layout simplified to title-then-verdict. §"Enforcement" describes four checks: 13a verdict-leads (unchanged), 13b imperative-in-skill-body (retargeted), 13c imperative-in-agent-body (retargeted), 13d anti-citation-in-render-templates (new — lints for absence of the citation literal inside Output format / "How to structure your output" code blocks). Anchoring prose updated for the retargeted checks. §"Review checklist" replaced "voice citation line in Output format" with two items: "voice imperative in body outside code blocks" and "no citation literal inside Output format block." History entry added for the pivot.
  - **Reason:** This is a named invariant that bundled the voice-citation greps into its enforcement section — both the rule statement and the enforcement description had to follow the pivot.

- `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md`
  - **Before:** §"Convention pins enforced alongside this invariant" pin #6 named "Voice-citation check" against Output format / first agent code block. §"Shared ownership" tied pin 5 (verdict-leads) and pin 6 (voice-citation) together as the two surface-level greps for two different rules.
  - **After:** Pin #6 retargeted to "Voice-imperative check" (body prose, outside fenced code blocks). New pin #7 added: "Anti-citation check on render templates" (Check 13d). Shared-ownership prose updated to reflect that pins 6 and 7 together enforce the voice-imperative convention as two halves of one rule (imperative present in body + citation absent from template). History entry added.
  - **Reason:** The canonical convention-pin enumeration must match what the validator actually does.

- `docs/substrate/gotchas/style-guide-rot.md`
  - **Before:** §"Correct pattern" prescribed the citation-in-Output-format-block pattern as the structural fix for "rules far from generation." §"Tempting wrong fix" considered two alternatives. §"Tests/checks that preserve this" named the citation grep. §"Notes for future contributors" advised adding a "citation hook in the closest place the model reads."
  - **After:** §"Correct pattern" rewritten: imperative in body prose; render template is text the model reproduces in output and contains no instructions; the v0.1 pre-pivot mistake (citation-in-render-template) named explicitly and described as doubly broken. §"Tempting wrong fix" gains a third entry documenting the v0.1 pre-pivot pattern as the wrong fix the imperative replaces. §"Tests/checks" updated for Checks 13b/13c (retargeted) and 13d (new anti-citation lint). §"Notes for future contributors" updated: imperatives go in body, never in render templates; if a future runtime feature lets skills declare "always pull file X" the imperative pattern retires but the anti-citation lint remains useful. §"When this was discovered" gains a 2026-05-04 same-day pivot entry.
  - **Reason:** This gotcha *prescribed* the broken pattern; correcting it is part of the pivot, not a cleanup.

- `docs/substrate/gotchas/wordy-output.md`
  - **Before:** §"Correct pattern" point 2 named the citation in each Output format block as the load mechanism for the voice guide. §"Tests/checks that preserve this" listed the citation grep as planned. §"Notes for future contributors" suggested promoting the voice-citation requirement to invariant after two release cycles.
  - **After:** Point 2 rewritten to describe the imperative-in-body load mechanism. §"Tests/checks" lists Checks 13a–13d with the post-pivot semantics. §"Notes for future contributors" updates the promotion-criteria pointer to reference the four-criteria list in `output-voice.md` §"Why the voice imperative is convention-with-grep…".
  - **Reason:** The parent scar's Correct-pattern prescription had to follow the citation→imperative pivot.

- `docs/substrate/matrices/reviewer-output-shape.md`
  - **Before:** Single "Voice citation" column tracked whether each agent's "How to structure your output" code block opened with the citation literal. Cell-rationale paragraph described the pre-pivot grep target.
  - **After:** Two columns: "Voice imperative in body" and "Citation absent from output template." All five agents' cells in both columns are `✓` after the pivot. Cell-rationale paragraph rewritten to describe Checks 13c and 13d separately and note that the pre-pivot single column tracked a different artifact and is retired.
  - **Reason:** The matrix tracks the convention's per-agent compliance; the pivot changes what compliance means.

- `docs/history/transcripts/output-voice-worked-example.md`
  - **Before:** §"The punchy render (canonical)" included `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` as line 2 of the canonical render. §"Why this works" cited that line as part of why the render works ("Verdict appears in line 5 (after the title and the voice citation)"). §"Captured transcripts (queued)" framed real captures as nice-to-have queued substrate, not gating.
  - **After:** §"The punchy render (canonical)" drops the citation line; verdict now lands on line 3 (after title + blank). §"Why this works" updated: verdict on line 3, "no instruction lines in user-facing output," and a sentence noting the voice guide loaded from the body-level imperative not the render template. §"Captured transcripts" renamed to "Captured transcripts (required before promoting voice-imperative to invariant)" with prose tying the capture to the imperative pivot's load-bearing assumption (the assumption is reasoned-but-unverified until a real capture exists).
  - **Reason:** The worked transcript is the canonical render exemplar; if its rendering differs from the rule, contributors copy what they see (the lesson §"Notes for future contributors" rule about literal-form parity codifies).

- `scripts/validate_plugin.sh`
  - **Before:** Check 13b grepped each non-router SKILL.md Output format code block for the citation literal in lines 1–3 after the outermost `#` title. Check 13c grepped each agent's first code block for the same literal in lines 1–3.
  - **After:** Check 13b retargeted: greps each non-router SKILL.md body (outside fenced code blocks) for the imperative literal `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.`. Check 13c retargeted: same grep on each agent body. New Check 13d: greps inside every Output format / "How to structure your output" code block for *absence* of the citation literal `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` — fails if the citation is found in any render template. All three checks emit per-pass `ok` lines naming the count and the rule.
  - **Reason:** The validator is the structural fence; pivoting the substrate without pivoting the validator would leave the convention unenforced.

- 7 × `skills/{review-diff,review-codebase,validate-rewrite,audit-substrate,brainstorm-design,rewrite-specs,discover-substrate}/SKILL.md`
  - **Before:** Each carried the citation literal `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` inside its Output format code block (review-diff carried it twice — once in a Phase 4 process snippet, once in Output format).
  - **After:** Each adds a `## Voice` section in body prose carrying the imperative. Each Output format code block has the citation literal removed; review-diff's Phase 4 snippet also drops the citation. The `## Voice` section is placed between `## What this skill produces` and `## Hard constraints` (or before `## When to invoke` for `discover-substrate`, which uses a deviating section order).
  - **Reason:** These are the 7 surfaces the user sees in chat output. The pivot's user-visible effect is removing the citation from these renders.

- 5 × `agents/{structure,substrate-alignment,library-native,agent-readiness,spec-cohesion}-reviewer.md`
  - **Before:** Each "How to structure your output" code block opened with the citation literal.
  - **After:** Each "How to structure your output" section gains the imperative as body prose (in the prose paragraph above the render template), and the citation literal is removed from the code block.
  - **Reason:** Reviewer agents' findings appear in chat through the synthesizing skill's render; the same citation-leak applies to their output templates and the same pivot fixes it.

## Files added

- `docs/history/brainstorms/2026-05-04-voice-citation-loading-vs-rendering.md` — persisted brainstorm output capturing the design options and approved direction. (Created on `main` before the worktree was set up; copied into the worktree for the design branch's history.)
- `docs/history/delta-ledgers/2026-05-04-voice-citation-imperative.md` — this ledger.

## Files removed or deprecated

None.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| Voice citation (in render template) | Voice imperative (in body prose) | Replaced |
| Citation as load mechanism | Read tool call as load mechanism (triggered by imperative) | Replaced |
| Render template carries instructions to the model | Render template is a pure template with no instructions | Tightened |
| Title-then-citation-then-verdict canonical layout | Title-then-verdict canonical layout | Tightened |
| Two enforcement greps (13b/13c citation-in-template) | Three enforcement greps (13b/13c imperative-in-body, 13d anti-citation-in-template) | Tightened |
| Voice-citation promotion criteria (3 items) | Voice-imperative promotion criteria (4 items, adds captured-transcript requirement) | Tightened |
| "Captured transcripts (queued)" — nice-to-have substrate | "Captured transcripts (required before promoting voice-imperative to invariant)" — gating | Tightened |

## New or updated substrate

### Specs

- `references/output-voice.md` — describes the imperative-in-body load mechanism; renames §"Why voice-citation is convention-with-grep…" to §"Why the voice imperative is convention-with-grep…"; adds a fourth promotion criterion (captured transcript demonstrating the Read at render time).
- `docs/substrate/designs/skill-conventions.md` — §"Output format conventions" rule 1 rewritten; canonical chat-render shape simplified; anti-pattern table swapped one row for two.

### Behavior matrices

- `docs/substrate/matrices/reviewer-output-shape.md` — single "Voice citation" column split into two: "Voice imperative in body" + "Citation absent from output template." All five agents' cells `✓` post-pivot.

### Named invariants

- `VERDICT_BEFORE_EVIDENCE` — unchanged in spirit (verdict still leads). §"Rule" enumeration shortened from three lines to two; §"Enforcement" expanded from three checks to four (13b/13c retargeted; 13d added); §"Review checklist" updated.
- `PLUGIN_ROOT_PATHS` — pin #6 retargeted; pin #7 added; shared-ownership paragraph extended.

### Gotchas

- `docs/substrate/gotchas/style-guide-rot.md` — §"Correct pattern" rewritten (citation→imperative); third tempting-wrong-fix added documenting the v0.1 pre-pivot pattern; §"Tests/checks" updated for Checks 13b/13c retarget + new 13d; §"Notes for future contributors" updated; §"When this was discovered" gains a 2026-05-04 same-day pivot entry.
- `docs/substrate/gotchas/wordy-output.md` — §"Correct pattern" point 2 rewritten; §"Tests/checks" updated; §"Notes for future contributors" updates promotion-criteria pointer.

### Semantic linter specs

- `validate_plugin.sh` Check 13d — anti-citation lint on render templates; ships in the same pass that retargets 13b/13c.

### Tests / checks proposed (not yet implemented)

- **Captured-not-authored worked transcript** demonstrating the model invokes `Read` on `output-voice.md` during a chat-render. Required-before-promotion (per `output-voice.md` §"Why the voice imperative is convention-with-grep…" and `output-voice-worked-example.md` §"Captured transcripts (required before promoting voice-imperative to invariant)"). Until this transcript exists, the imperative pattern's load-bearing claim is reasoned-but-unverified — the validator pins the *imperative literal*, not the *Read call*. The capture is queued substrate; this rewrite makes the queue gating rather than nice-to-have.

## What this rewrite *did not* do

- Implementation code: not changed (no production code in this repo; the validator script is the only executable).
- Tests: no test suite exists in this repo. Behavior pinning relies on the validator's greps, which were updated.
- CI: `.github/workflows/validate.yml` is untouched — it already runs `scripts/validate_plugin.sh`, and the script's check-numbering is internal to the script.
- The router (`cohesively`) is unchanged. Its render budget is 1–2 sentences with no `#` title; its dispatched subskills carry the voice load on its behalf. The pre-pivot exemption transfers cleanly.
- No new gotcha doc spun out for "instructions placed in render templates leak to users." That meta-lesson is captured in the rewritten `style-guide-rot.md` §"Correct pattern" and §"Tempting wrong fix" rather than as a separate file. If future drift suggests it needs its own doc, spin it out then.

## Remaining ambiguity

- **Empirical proof of load.** The pivot rests on the assumption that a body-level `Read X` imperative actually triggers a Read tool call at chat-render time. The assumption is reasoned (skills already direct Read calls in other contexts; the imperative is in body prose, not setup-only context) but unverified by capture. The captured-transcript task is required-before-promoting-to-invariant, but the rewrite ships before the capture lands. If models treat "before rendering" imperatives as setup-only and skip them at render time, the leak is gone but the load mechanism is also gone — voice rules would drift silently. The fresh-eyes reviewer should flag whether the imperative wording is strong enough to compel the Read call, or whether a more procedural form ("Step 1: Read X. Step 2: Render output.") would be better.

- **Section name `## Voice`.** The rewritten skill-conventions.md says the imperative lives in a `## Voice` section. That section name is new — pre-pivot, no skill had a `## Voice` heading. The skill-section-presence matrix (`docs/substrate/matrices/skill-section-presence.md`) does not yet list `Voice` as a tracked section. The reviewer should flag whether this is drift to fix in the same pass (add `Voice` to the matrix as a new mandatory section for non-router skills) or whether the section is incidental enough to live as un-tracked convention.

- **Reviewer agent imperative placement.** Skills carry the imperative in a top-level `## Voice` section. Reviewer agents (which are system prompts, not SKILL.md files with the same section structure) carry the imperative as the opening prose paragraph of "How to structure your output." The asymmetry is documented but the rewrite doesn't add a behavior matrix tracking per-agent placement. If placement drifts (e.g., one reviewer slips the imperative into a different section), the validator still passes (Check 13c only requires presence outside code blocks). The reviewer should flag whether placement consistency needs structural enforcement or whether grep-presence is sufficient.

## Ready for fresh-eyes review?

**Yes** — the rewrite is internally consistent (validator green; substrate cross-references updated together), the load-bearing claim is named and a structural mitigation is documented (the gating capture transcript), and the remaining ambiguities are flagged for the reviewer rather than swept under the rug.

## How to read this ledger

1. Read the "Approved direction" line and "Why this rewrite exists" — that's the destination and the reason.
2. Skim "Conceptual changes" to see the seven swaps the pivot performs.
3. Read "Files rewritten" with the before/after framing to verify each change makes sense as a delta.
4. Use "Remaining ambiguity" as the focused review punch list — empirical proof of load, the new `## Voice` section, and reviewer-agent imperative placement.
