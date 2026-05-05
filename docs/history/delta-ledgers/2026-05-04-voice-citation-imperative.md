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
4. Use "Remaining ambiguity" as the focused review punch list — empirical proof of load, the new `## Voice` section, and reviewer-agent imperative placement. (Pass-1 review found three additional blockers — see "Repair pass 1" below.)

---

## Repair pass 1 (post validation)

**Date:** 2026-05-04
**Predecessor:** [`docs/history/reviews/2026-05-04-voice-citation-imperative-rewrite-validation.md`](../reviews/2026-05-04-voice-citation-imperative-rewrite-validation.md) (verdict: Issues Found, 3 blockers + 4 important issues).

This pass closes all 3 blockers and all 4 important issues from the validation review. Same worktree, same approved direction. No re-brainstorm; the design itself was sound, but the rewrite-pass-1 file list was incomplete and three docs carried internally inconsistent line-position prose.

### Blockers repaired

#### B1. `docs/substrate/designs/reviewer-agent-template.md` migrated to imperative-in-body

- **Before:** §"Output format conventions" rule 1 prescribed the citation literal as the first non-blank line of every reviewer agent's "How to structure your output" code block. Anti-pattern table told contributors to add the citation literal.
- **After:** Rule 1 rewritten to require the imperative as the opening prose paragraph of "How to structure your output" (above the code block, outside any fence). Code block becomes pure render template with the canonical six-field finding shape and no instructions. New paragraph in rule 1 documents the asymmetry with skills (skills use a top-level `## Voice` section; agents use a "How to structure your output"-internal placement) and points at the reviewer-output-shape matrix's per-agent compliance columns and validator Checks 13c/13d. Anti-pattern table swapped one row ("missing the voice citation") for two rows mirroring `skill-conventions.md`: one for "missing the voice imperative in body prose" and one for "voice citation literal placed inside the code block."
- **Why this finding existed:** This doc is cited as canonical from `output-voice.md:104`, `skill-conventions.md:147`, and `reviewer-output-shape.md:9`. A future contributor adding a sixth reviewer agent would have copied this template verbatim and shipped the citation in the render template — the validator would catch it (Check 13d), but only after the contributor had already done the work the substrate told them to do.

#### B2. `AGENTS.md` and `ARCHITECTURE.md` updated to match the new substrate

- **AGENTS.md:**
  - Line 47: "voice-citation pin" → "voice-imperative pin (body prose), anti-citation lint (render templates)" in the v0.1 conventions list.
  - Line 53: "(which now include the voice-citation pin and the verdict-leads invariant)" → "(which include the body-level voice imperative, the anti-citation lint on render templates, and the verdict-leads invariant)" in the §"Convention references" entry for skill-conventions.md.
  - Line 64: "The Output format block must open with the `# <title>` then the voice citation then `**Verdict:**`" → "The Output format block opens with the `# <title>` followed by `**Verdict:**` within the first three non-blank lines (verdict-led skills) per `VERDICT_BEFORE_EVIDENCE`. The voice imperative — `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` — lives in the skill body's `## Voice` section, **not** inside the Output format render template; instructions placed inside render templates leak verbatim into user-facing output."
- **ARCHITECTURE.md:**
  - Line 48: "Runtime methodology cited from every Output format block" → "Loaded at chat-render time via a body-level imperative in each non-router skill and reviewer agent (the imperative literal lives in body prose, never in render templates — see [`docs/substrate/gotchas/style-guide-rot.md`](docs/substrate/gotchas/style-guide-rot.md) §'Correct pattern')."
  - Line 53: "voice-citation pin" → "voice-imperative pin in body prose, anti-citation lint on render templates" in the validator-checks enumeration.
- **Why this finding existed:** AGENTS.md and ARCHITECTURE.md are the contributor-orientation entry points. Reading them post-pivot taught the broken pattern; new contributors would follow the pre-pivot recipe and produce drift the validator catches only after the fact.

#### B3. Verdict line-position prose reconciled to a single frame

The post-pivot canonical layout is `# title` / blank / `**Verdict:**` (rendered with one blank between title and verdict). Three docs carried inconsistent counts of where verdict lands:

- `VERDICT_BEFORE_EVIDENCE.md:12`: "lands on line 1 after the title (or line 2 after a blank)"
- `VERDICT_BEFORE_EVIDENCE.md:19`: "the same line-2 verdict rule applies"
- `VERDICT_BEFORE_EVIDENCE.md:58`: "places title on line 1 and `**Verdict:**` on line 2 (after a blank)"
- `output-voice-worked-example.md:97`: "Verdict appears on line 3 (after the title and a blank)"
- `skill-conventions.md:106`: "the verdict appears in lines 1–3 after the `#` title" (ambiguous between counting raw lines and non-blank lines)

Unified frame: **first three non-blank lines after the outermost `#` title** — what the validator actually checks. All five sites rewritten to use this frame. The blank between title and verdict is a rendering choice, not a positional constraint; counting raw lines made the prose contradict itself across docs because different authors counted differently.

- **Why this finding existed:** The pivot pass swept the citation out of the canonical layout but left behind line-number prose that referenced the citation's old position (line 2). The result was three docs each describing the same render with different line numbers — exactly the rot `style-guide-rot.md:75` warns about ("the worked transcript and the spec must agree byte-for-byte").

### Important issues repaired

#### I1. `## Voice` section added to skill-section-presence matrix

- `docs/substrate/matrices/skill-section-presence.md` Cells: required sections grew a `Voice` column. Cells: 7 of 8 skills `✓` (all non-router), router `~` with the documented exemption ("router exempt; render budget too small to need imperative"). New paragraph below the matrix names what the column tracks (presence + placement between specific neighbors), points at validator Check 13b for the literal grep, and notes that placement is a *stricter* rule than the validator enforces — drift in placement passes Check 13b silently and is caught only at review time. History entry added.
- **Why this finding existed:** The pivot mandated a `## Voice` section in 7 of 8 skills. The matrix that exists for tracking required-section presence had not been updated. The validator pinned the *literal* but not the *section* — leaving the placement rule unenforced and undocumented in the matrix that should track it.

#### I2. Reviewer-agent imperative placement encoded as convention

- `docs/substrate/matrices/reviewer-output-shape.md` gained a new prose section, "Imperative placement (convention, not column)," before §"Verdict-leads is tracked elsewhere." The section names the convention (imperative as opening prose paragraph of "How to structure your output," above the code block), references the asymmetry with skills, and flags that Check 13c does not verify placement — only presence. All five reviewer agents currently comply per the template; drift is a review-time finding rather than a validator failure.
- `reviewer-agent-template.md` §"Output format conventions" rule 1 (rewritten under B1) already names the placement explicitly. The matrix and the template now agree.
- **Why this finding existed:** Skills place the imperative in a top-level `## Voice` section; agents place it inside "How to structure your output." The asymmetry was documented only in this ledger's §"Remaining ambiguity" item 3 — no spec or matrix encoded the agent placement, so a contributor adding a sixth reviewer could place the imperative anywhere in the body and still pass Check 13c.

#### I3. Captured-transcript acceptance criteria specified

- `docs/history/transcripts/output-voice-worked-example.md` §"Captured transcripts" gained a new subsection: "Acceptance criteria for the captured transcript" — four criteria a real capture must meet: (1) source from a real, user-invoked verdict-led skill run, not authored or simulated; (2) tool-call evidence of the Read on `output-voice.md` between invocation and render; (3) voice-rule reflection in the rendered output (at least 3 of the 5 voice rules observably applied, OR absence of forbidden phrasings); (4) persistence at the canonical path with frontmatter naming source skill, date, runtime context. Disqualifying conditions named: partial captures (no tool-call log), reconstructed captures, simulated captures.
- **Why this finding existed:** Four docs converged on "captured-not-authored worked transcript" as the gating artifact for invariant promotion (`output-voice.md`, `style-guide-rot.md`, `output-voice-worked-example.md`, this ledger), but none defined what "shows the Read call happening" required. Without acceptance criteria, the gate was wishful — readers would disagree about whether a given capture counted.

#### I4 + minor polish on `output-voice.md`

- **Top-of-file shape.** The opening blockquote (5-sentence normative paragraph) was downgraded to plain prose. The change is structural: the imperative form skills and agents copy is a single line of plain prose, never a multi-line blockquote. A new "Note on this doc's own form" paragraph immediately after the opener explains why the doc-introduction blockquote was retired. Flagged in I4 as a substrate-modeling concern (the doc that prescribes the imperative should model the form it prescribes).
- **Promotion criterion 4 reworded.** "No further rewording of the imperative line is anticipated" (unfalsifiable as written) → "The imperative wording has not been reworded in the past two release cycles" (a checkable past-tense claim). This is structurally redundant with criterion 1 ("Two release cycles pass without the imperative wording changing") but stated as a different lens — criterion 1 is the cycle-count gate, criterion 4 is the same observation framed as the no-anticipated-rewording check. Both retained because together they make the gate self-evident: an unverifiable forward prediction becomes two checkable past-tense claims.
- **Canonical home named.** A new paragraph after the opener explicitly names `output-voice.md` as the canonical home of the imperative literal — the wording every skill body, every reviewer agent body, and every validator grep target must match byte-for-byte. If the wording evolves, this doc updates first; the validator and 12 enforcement targets follow in the same pass.
- **Captured-transcript pointer added** to promotion criterion 3, naming the four acceptance criteria added under I3 as the gating definition.

### What this repair pass *did not* do

- **No new gotcha for "instructions in render templates leak."** The reviewer's "Substrate gaps" finding noted this meta-lesson is broader than voice and worth a dedicated gotcha doc. The pass-1 ledger §"What this rewrite *did not* do" already deferred this; the deferral stands. The lesson is captured in the rewritten `style-guide-rot.md` §"Tempting wrong fix" (third entry) and §"Notes for future contributors" (the "imperatives go in body, never in render templates" rule). A standalone gotcha would duplicate without adding enforcement; defer until a second instance of the same mistake appears in a different domain.
- **No matrix column for reviewer-agent imperative placement.** I2 was resolved by prose convention rather than a new column. The matrix already grew two columns in the pivot pass; a third tracking placement would add column count without adding enforcement (Check 13c doesn't verify placement either). Convention-with-review is the right tier for now.
- **No further rewording of the imperative literal.** The literal remains `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` byte-for-byte. The validator's Check 13b/13c grep target is unchanged.

### Files touched in repair pass 1

- `docs/substrate/designs/reviewer-agent-template.md` — B1
- `AGENTS.md` — B2
- `ARCHITECTURE.md` — B2
- `docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md` — B3
- `docs/substrate/designs/skill-conventions.md` — B3
- `docs/history/transcripts/output-voice-worked-example.md` — B3 + I3
- `docs/substrate/matrices/skill-section-presence.md` — I1
- `docs/substrate/matrices/reviewer-output-shape.md` — I2
- `references/output-voice.md` — I4 + minor (top-of-file shape, promotion criterion 4, canonical home, captured-transcript pointer)
- `docs/history/delta-ledgers/2026-05-04-voice-citation-imperative.md` — this ledger entry

10 files. Validator green. Persisted review at [`docs/history/reviews/2026-05-04-voice-citation-imperative-rewrite-validation.md`](../reviews/2026-05-04-voice-citation-imperative-rewrite-validation.md) is the predecessor record of issues this pass addresses.

### Ready for fresh-eyes review (pass 2)?

**Yes.** All 3 blockers and all 4 important issues from pass 1's validation report have concrete repairs landed in the same worktree. The repair pass introduced no new design decisions — every change is either (a) extending an existing migration to a doc the pass-1 file list missed, (b) reconciling line-position prose to a single frame, or (c) tightening promotion criteria to be checkable. The reviewer should focus on whether any *new* drift was introduced by these repairs (especially the line-position reconciliation, which touched three docs) and whether the repaired AGENTS.md / ARCHITECTURE.md prose is now coherent with the rewritten `skill-conventions.md` and `output-voice.md`.

---

## Repair pass 2 (post pass-2 validation)

**Date:** 2026-05-05
**Predecessor:** [`docs/history/reviews/2026-05-05-voice-citation-imperative-rewrite-validation-pass2.md`](../reviews/2026-05-05-voice-citation-imperative-rewrite-validation-pass2.md) (verdict: Issues Found, 3 blockers + 2 important issues, all localized prose edits).

The pass-2 review found that repair pass 1 closed 6 of 7 predecessor findings concretely but missed one co-resident reference (`PLUGIN_ROOT_PATHS.md:9`), failed to fully unify B3 at one of the five sites it enumerated (`output-voice-worked-example.md:97`), and introduced a new placement contradiction by adopting one canonical agent-placement statement in the new specs without aligning the existing gotcha (`style-guide-rot.md:37`). Plus two important issues: criteria 1 and 4 in `output-voice.md` had collapsed into near-duplicates, and the `Voice` matrix column's exemption pointer didn't resolve cleanly in `skill-conventions.md` §"When sections may differ".

This pass closes all 5. No new design decisions; every change is either a localized prose alignment to an existing canonical wording or a structural cleanup of redundancy the pass-2 review surfaced.

### Blockers repaired

#### B1-residual-r2. `PLUGIN_ROOT_PATHS.md:9` aligned to AGENTS.md:47 phrasing

- **Before:** Line 9's enumeration of demoted v0.1 conventions read "Other v0.1 rules (chat-render header-depth cap, density budgets, forbidden phrasings, **voice-citation pin**, fresh-eyes preamble…)" — the pre-pivot phrase that B2 of pass-1 already retired in AGENTS.md and ARCHITECTURE.md.
- **After:** Line 9 reads "voice-imperative pin (body prose), anti-citation lint (render templates)" — byte-for-byte aligned with AGENTS.md:47 and ARCHITECTURE.md:53.
- **Why this finding existed:** Pass 1 correctly migrated the body of `PLUGIN_ROOT_PATHS.md` (lines 47–48 became "Voice-imperative check" + "Anti-citation check") but missed the intro paragraph at line 9 in the same doc — same drift class as B2, missed because the file list keyed on the convention-pin enumeration (lines 36–53), not on the intro.

#### B3-residual-r2. `output-voice-worked-example.md:97` reframed to separate render-position from validator-frame

- **Before:** "Verdict appears on the first non-blank line after the title (the canonical frame the validator and `VERDICT_BEFORE_EVIDENCE.md` use…)" — a category error attributing "first non-blank line" (this render's specific position) to the validator (which actually uses "first three").
- **After:** "Verdict appears within the first three non-blank lines after the title (the frame the validator and `VERDICT_BEFORE_EVIDENCE.md` use…). In this render it lands on the first non-blank line — the canonical shape; the three-line allowance accommodates skills that introduce a thesis line before the verdict." Separates the concrete observation from the normative frame.
- **Why this finding existed:** Pass 1's repair of B3 reconciled four of five sites but tightened the worked-transcript line in the wrong direction — collapsed the validator's window to the render's specific position, which made the doc say the validator counts narrower than it does.

#### Drift-1-r2. `style-guide-rot.md:37` aligned to canonical agent-placement wording

- **Before:** "in agents, in a 'Voice' subsection of the system prompt" — a phrasing that suggests agents carry a `## Voice` heading parallel to skills.
- **After:** "in agents, as the opening prose paragraph of the 'How to structure your output' section, above the code block." Plus a new sentence naming the canonical homes: skill-side placement in `skill-conventions.md` §"Output format conventions" rule 1; agent-side placement in `reviewer-agent-template.md` §"Output format conventions" rule 1, with per-agent compliance tracked at `reviewer-output-shape.md`. style-guide-rot.md no longer claims to be the canonical home of placement; it links to where the canonical home lives.
- **Why this finding existed:** Pass 1 introduced this drift by adopting one canonical placement statement in `reviewer-agent-template.md` and `reviewer-output-shape.md` without aligning `style-guide-rot.md`, which the pass-1 file list had not flagged as needing edits in the placement direction (it was in the file list for §"Correct pattern" rewrites, but the imperative-placement paragraph at line 37 was authored fresh in pass 1 with the wrong shape). The validator's failure messages link to style-guide-rot.md, so a contributor following a Check 13c failure would have read the wrong placement.

### Important issues repaired

#### I-new-1. `output-voice.md` promotion criteria collapsed from 4 to 3

- **Before:** Four criteria. Criterion 1 ("Two release cycles pass without the imperative wording changing") and criterion 4 ("The imperative wording has not been reworded in the past two release cycles") tested nearly the same thing. The pass-1 ledger acknowledged the redundancy but retained both as different lenses.
- **After:** Three criteria — wording stability, caught regression, captured-not-authored worked transcript — each named with a bold lead-in and a checkable definition. The retained "wording stability" criterion absorbs both pass-1 criteria 1 and 4 into one bullet that names the dating mechanism (the imperative literal's last edit) explicitly.
- **Why this finding existed:** Pass 1's I4 repair tightened criterion 4 from unfalsifiable to checkable, but the repair produced two near-identical past-tense criteria. Three gates dressed as four was the rot the pass-2 review flagged.

#### I-new-2. `skill-conventions.md` §"When sections may differ" gains the Voice-section exemption

- **Before:** §"When sections may differ" enumerated three deviations (router's Process replacement, discover-substrate's When-to-invoke replacement, optional Token discipline). The new `## Voice` exemption for the router was documented in §"Output format conventions" rule 1 but not in this section, which is where the matrix legend at `skill-section-presence.md:11` directs readers to verify exemptions.
- **After:** A new bullet lists the router's Voice-section omission: "The router (`cohesively`) omits the `## Voice` section. Its render budget is 1–2 sentences and its dispatched subskills carry the voice load on its behalf — see §'Output format conventions' rule 1." A reader following the matrix legend's pointer now finds the exemption named alongside the other documented section deviations.
- **Why this finding existed:** Pass 1's I1 repair added the matrix column and documented the exemption rationale in rule 1 — but the matrix legend's pointer anchored on §"When sections may differ", a different section. The exemption existed but the pointer didn't resolve cleanly.

### Files touched in repair pass 2

- `docs/substrate/gotchas/style-guide-rot.md:37` — Drift-1-r2 (agent placement)
- `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md:9` — B1-residual-r2 (intro phrasing)
- `docs/history/transcripts/output-voice-worked-example.md:97` — B3-residual-r2 (render-frame separation)
- `references/output-voice.md` — I-new-1 (promotion criteria collapsed 4→3)
- `docs/substrate/designs/skill-conventions.md` — I-new-2 (Voice-section exemption added to §"When sections may differ")
- `docs/history/delta-ledgers/2026-05-04-voice-citation-imperative.md` — this ledger entry

6 files. Validator green. Persisted review at [`docs/history/reviews/2026-05-05-voice-citation-imperative-rewrite-validation-pass2.md`](../reviews/2026-05-05-voice-citation-imperative-rewrite-validation-pass2.md) is the predecessor record.

### Ready for fresh-eyes review (pass 3)?

**Yes.** All 3 blockers and all 2 important issues from pass-2's validation report have concrete repairs. No new specs introduced; every change aligns existing prose to a canonical wording that already existed elsewhere in the substrate. The repair surface was 5 prose edits across 5 files plus the ledger entry. The reviewer should focus on whether the canonical-home claim now resolves consistently across all docs (style-guide-rot.md → reviewer-agent-template.md → reviewer-output-shape.md for agent placement; skill-conventions.md §"When sections may differ" → matrix legend for the router's Voice exemption) and whether the trimmed promotion criteria in `output-voice.md` are checkable as written.
