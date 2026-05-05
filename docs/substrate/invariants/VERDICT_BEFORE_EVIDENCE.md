# VERDICT_BEFORE_EVIDENCE

> Every Cohesive skill that produces a verdict opens its chat-rendered output (and its persisted artifact, if any) with the verdict line. Burying the verdict under a setup paragraph is the most-regressed UX failure mode in chat output, and the one with the cleanest grep-based enforcement.

## Rule

For every Cohesive skill in the **verdict-led** scope below, the canonical "Output format" block in `skills/<name>/SKILL.md` opens — within the first three non-blank lines after the format's outermost header — with the literal string `**Verdict:**` followed by a value drawn from the skill's verdict vocabulary.

The same rule applies to the rendered chat output and to any persisted artifact the skill writes (architecture review, brainstorm, audit report, change cohesion review, spec cohesion review).

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
- `agents/*.md` reviewer agents — produce findings, not verdicts; their per-finding shape opens with `**Severity:**` per `${CLAUDE_PLUGIN_ROOT}/references/reviewer-agent-template.md` §"Output format conventions"
- Documentation, references, templates, scripts — invariant is about skill-rendered output, not about every Markdown file

## Why this matters

Burying the verdict is the highest-leverage form of chat-output bloat: the reader cannot tell whether the change is safe, whether the codebase is healthy, or whether the rewrite is approved without scrolling past methodology recaps and reviewer attributions. Verdict-leads are the single most predictable cure, and they are mechanically detectable, which lets the rule be enforced rather than hoped for.

This is the second named invariant Cohesive ships, joining `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/PLUGIN_ROOT_PATHS.md`. The other UX rules in `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` (header-depth cap, density budgets, forbidden phrasings) remain conventions because their wording is still settling and their failure modes are softer. `VERDICT_BEFORE_EVIDENCE` earns invariant status because (a) the rule is mechanically detectable, (b) the failure mode is the most-reported UX scar, and (c) regressions silently degrade the user experience without breaking the build.

## Enforcement

`scripts/validate_plugin.sh` enforces the invariant via two grep checks (planned for the implementation pass — see `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-04-cut-anchor-pin.md` for the implementation handoff):

1. **Verdict-leads check.** For each skill listed under "Applies to" above, grep the SKILL.md "Output format" block. The first three non-blank lines after the block's outermost header must include the literal string `**Verdict:**`. A violation is a hard fail; the failure message names this invariant.
2. **Voice citation check.** Every `skills/*/SKILL.md` Output format block must contain the line `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` (or the same path under whatever the harness expands `${CLAUDE_PLUGIN_ROOT}` to). This check is broader than the verdict rule — it applies to every skill, including those out-of-scope for the verdict invariant — because the voice citation is what pulls the voice guide into context at generation time, which is where every chat-render rule (verdict-leads or otherwise) actually takes effect. The check pins the citation as convention; the invariant is the verdict rule itself.

The validator runs locally. CI is out of scope for v0.1.

Until the implementation pass lands the validator changes, this invariant is enforced by skill-author memory and by `cohesive:review-diff` flagging violations as `**Verdict:**`-shape regressions.

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
- [ ] Does the skill's Output format block carry the voice citation line?
- [ ] `bash scripts/validate_plugin.sh` passes (once the implementation pass adds the grep)?

## Related

- `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` — the broader voice & density guide; this invariant is one rule from that guide promoted to enforced status
- `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/output-voice-worked-example.md` — the worked transcript that demonstrates verdict-leads alongside the other voice rules
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` — the other named invariant; same enforcement surface (`validate_plugin.sh`)
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` — tracks per-skill verdict-leads compliance as a column
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/wordy-output.md` — the scar this invariant retires
- `${CLAUDE_PLUGIN_ROOT}/references/skill-conventions.md` §"Output format conventions" — the canonical Output format shape this invariant pins

## History

- 2026-05-04 — Created during the `cut-anchor-pin` UX/conciseness rewrite, as the one rule from `references/output-voice.md` promoted to invariant. Validator enforcement (the two grep rules) is queued for the implementation follow-up phase.
