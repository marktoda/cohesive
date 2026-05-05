# VERDICT_BEFORE_EVIDENCE

> Every Cohesive skill that produces a verdict opens its chat-rendered output (and its persisted artifact, if any) with the verdict line. Burying the verdict under a setup paragraph is the most-regressed UX failure mode in chat output, and the one with the cleanest grep-based enforcement.

## Rule

For every Cohesive skill in the **verdict-led** scope below, the canonical "Output format" block in `skills/<name>/SKILL.md` renders, in order:

1. The outermost `#` title naming the rendered output (e.g. `# Change Cohesion Review`)
2. The literal string `**Verdict:**` followed by a value drawn from the skill's verdict vocabulary

`**Verdict:**` appears within the **first three non-blank lines after the outermost `#` title**. The canonical layout places `**Verdict:**` on the very next non-blank line — separated from the title by one blank line in the rendered output, so a reader sees title, blank, verdict in that order. The three-line allowance accommodates skills that introduce a thesis before the verdict in unusual cases; the canonical shape uses the immediately-next non-blank line.

The frame is **non-blank lines**, counted from the line after the outermost `#` title. The validator and the worked transcript at `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/output-voice-worked-example.md` both use this frame; counting raw lines (including blanks) is not normative because the blank between title and verdict is a rendering choice, not a positional constraint.

The voice guide (`${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`) is loaded via a body-level imperative in the skill prose (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/skill-conventions.md` §"Output format conventions" rule 1), not via a citation in the Output format block — the Output format block is a render template, and instructions placed inside it leak verbatim into user-facing output.

The rule applies to:

- The rendered chat output the skill produces
- Any persisted artifact the skill writes (architecture review, brainstorm, audit report, change cohesion review, spec cohesion review). The persisted artifact's first `#` heading is the same title as the chat output's, and the same first-three-non-blank-lines window applies.

Both surfaces are enforced by the validator grep (see "Enforcement" below) — the grep reads SKILL.md Output format blocks, which are the source of truth for both surfaces.

## Scope

### Applies to

- `skills/review-codebase/SKILL.md`'s Output format block (verdict vocabulary: Healthy / Mostly healthy / Cohesive but under-enforced / Spec drift risk / Architecture risk)
- `skills/review-diff/SKILL.md`'s Output format block (Pass / Pass with notes / Needs substrate / Risky / Block)
- `skills/validate-rewrite/SKILL.md`'s Output format block (Approved / Issues Found / Design Incoherent)
- `skills/audit-substrate/SKILL.md`'s Output format block (verdict vocabulary lives in that skill's body)
- The persisted artifacts written by the four skills above
- Any future skill whose output names a verdict drawn from a controlled vocabulary

### Does not apply to

- `skills/cohesively/SKILL.md` — router; produces a one-sentence announcement, not a verdict
- `skills/discover-substrate/SKILL.md` — produces a substrate inventory, not a verdict
- `skills/brainstorm-design/SKILL.md` — produces a recommendation; no controlled-vocabulary verdict (a "Recommendation" header is the analogue)
- `skills/rewrite-specs/SKILL.md` — produces a delta ledger; no verdict
- `agents/*.md` reviewer agents — produce findings, not verdicts; their per-finding shape opens with `**Severity:**` per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/reviewer-agent-template.md` §"Output format conventions"
- Documentation, references, templates, scripts — invariant is about skill-rendered output, not about every Markdown file

## Why this matters

Burying the verdict is the highest-leverage form of chat-output bloat: the reader cannot tell whether the change is safe, whether the codebase is healthy, or whether the rewrite is approved without scrolling past methodology recaps and reviewer attributions. Verdict-leads are the single most predictable cure, and they are mechanically detectable, which lets the rule be enforced rather than hoped for.

This is the second named invariant Cohesive ships, joining `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/PLUGIN_ROOT_PATHS.md`. The other UX rules in `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` (header-depth cap, density budgets, forbidden phrasings) remain conventions because their wording is still settling and their failure modes are softer. `VERDICT_BEFORE_EVIDENCE` earns invariant status because (a) the rule is mechanically detectable, (b) the failure mode is the most-reported UX scar, and (c) regressions silently degrade the user experience without breaking the build.

## Enforcement

`scripts/validate_plugin.sh` enforces the invariant — and the co-resident voice-imperative convention — via four awk-based checks (13a, 13b, 13c, 13d — see the script for line-level detail):

1. **Verdict-leads check (13a).** For each skill listed under "Applies to" above, the validator finds the first `#` title inside a fenced code block in the SKILL.md and verifies `**Verdict:**` appears within the next three non-blank lines. A violation is a hard fail; the failure message names this invariant.
2. **Voice-imperative check, skills (13b).** Every non-router `skills/*/SKILL.md` body (i.e., outside fenced code blocks) contains the literal line `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.`. The router (`cohesively`) is exempt — see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` §"Convention pins enforced alongside this invariant" for the exemption. The check pins the imperative as convention; the named invariant is the verdict-leads rule itself.
3. **Voice-imperative check, agents (13c).** Every `agents/*-reviewer.md` body (outside fenced code blocks) contains the same imperative literal.
4. **Anti-citation check, render templates (13d).** No `skills/*/SKILL.md` Output format code block and no `agents/*-reviewer.md` "How to structure your output" code block contains the literal line `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`. Citation literals in render templates leak verbatim into user-facing output — see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` §"Correct pattern" for why the imperative belongs in body prose, not in the render template. Failure message names this gotcha by path.

Check 13a anchors on the outermost `#` title inside the Output format code block and verifies `**Verdict:**` appears within the first three non-blank lines after that title — the same frame the rule statement uses. Checks 13b/13c grep the SKILL.md/agent body outside code blocks for the imperative literal. Check 13d greps inside Output format / "How to structure your output" code blocks for absence of the citation literal — the inverse of the pre-pivot 13b/13c.

Persisted artifacts inherit the verdict-leads rule because the SKILL.md Output format block is the source of truth for both chat render and persisted file. The validator runs locally and in CI on push/PR via [`.github/workflows/validate.yml`](../../../.github/workflows/validate.yml). A red check blocks merge — checks 13a/13b/13c/13d are part of the structural fence that promotes this invariant from "convention-with-script" to "convention-with-CI-enforcement."

## Known bypass risks

- **Lookalike strings.** A skill body containing `**Verdict (advisory):**` or `Verdict:` (without the surrounding bold) would not satisfy the grep. The grep is intentionally strict on the literal `**Verdict:**` form because that's what `references/output-voice.md` and `output-voice-worked-example.md` model. Skill authors should match the literal form.
- **Verdict in a fenced code block describing a *previous* example.** A skill body whose Output format block includes a code fence containing `**Verdict:**` from a worked example — but whose own canonical format does not lead with verdict — would currently pass a naive grep. The validator scopes the check to the first three non-blank lines after the section header, which excludes embedded examples appearing later in the block.
- **Skills outside the "Applies to" list.** A new skill that produces a verdict but isn't yet listed here would not be enforced. Adding a verdict-led skill is a substrate change: update this invariant's "Applies to" list in the same pass.

## Review checklist

When reviewing a change to a verdict-led skill (or adding one):

- [ ] Does the Output format block open with `**Verdict:**` within the first three non-blank lines after the outermost header?
- [ ] Does the verdict value come from the controlled vocabulary documented in the skill body?
- [ ] Is the same shape carried into the persisted artifact, if one exists?
- [ ] If the skill is new, is it added to this invariant's "Applies to" list?
- [ ] Does the skill body carry the voice imperative (`Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.`) outside any code block?
- [ ] Does the skill's Output format block contain *no* citation literal?
- [ ] `bash scripts/validate_plugin.sh` passes?

## Related

- `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` — the broader voice & density guide; this invariant is one rule from that guide promoted to enforced status
- `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/output-voice-worked-example.md` — the worked transcript that demonstrates verdict-leads alongside the other voice rules
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` — the other named invariant; same enforcement surface (`validate_plugin.sh`)
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` — tracks per-skill verdict-leads compliance as a column
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/wordy-output.md` — the scar this invariant retires
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/skill-conventions.md` §"Output format conventions" — the canonical Output format shape this invariant pins

## History

- 2026-05-04 — Created during the `cut-anchor-pin` UX/conciseness rewrite, as the one rule from `references/output-voice.md` promoted to invariant.
- 2026-05-04 — Repair pass 1: pinned the canonical layout as title-then-citation-then-verdict (matching the worked transcript), tightened the rule statement to enumerate the three lines explicitly, and clarified that persisted artifacts inherit the rule because the SKILL.md Output format block is the single source of truth for both chat and persisted shape.
- 2026-05-04 — Implementation pass: validator checks 13a (verdict-leads), 13b (voice-citation, skills), and 13c (voice-citation, agents) wired into `scripts/validate_plugin.sh`. The invariant is now mechanically enforced; prior "planned for implementation pass" prose retired.
- 2026-05-04 — Polish pass (post review-diff): clarified that the greps verify *citation/verdict present in lines 1–3 after title* but do not enforce the structural ordering between citation and verdict; that ordering is the worked-transcript exemplar, not a structural check. A future tightening can require strict ordering once the shape is dogfooded. *(Superseded by the voice-imperative pivot entry below: the citation grep was retargeted to body-prose-imperative; the line-window frame is now stated as "first three non-blank lines after the outermost `#` title" — see `:12,14,55,60`.)*
- 2026-05-04 — Voice-imperative pivot: the voice-citation literal previously rendered into user-facing output because the convention placed it inside the Output format code block (a render template the model reproduces in output). Replaced with a body-level imperative in skill/agent prose; loading happens via a `Read` tool call the imperative triggers. Validator Checks 13b/13c retargeted from "citation present in render template" to "imperative present in body"; new Check 13d added to lint for absence of the citation literal inside render templates (catches half-migrations). Canonical layout simplified to title-then-verdict (no citation line). The named invariant (`VERDICT_BEFORE_EVIDENCE`) is unchanged in spirit; only its co-resident voice-imperative grep is retargeted. See `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-04-voice-citation-imperative.md`.
