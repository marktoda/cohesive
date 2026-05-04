# SUBSKILL_RECOMMENDS_NEXT

> Every terminal Cohesive skill output names exactly one recommended next Cohesive skill. When a skill returns multiple verdict-branches, it names exactly one recommended next per branch.

## Rule

Every Cohesive skill that produces a chat output ends with a section named `### Recommended next Cohesive skill`. The section contains exactly one entry of the form:

```
`cohesive:<skill-name>` — <one-clause reason>
```

When the skill has multiple verdict-branches (e.g., `review-spec-cohesion` returns Approved / Issues Found / Design Incoherent), the output schema names one recommended next *per branch*. If a branch is terminal (e.g., "Approved" leads to user action outside Cohesive), the entry names the next non-Cohesive step explicitly:

```
`<next non-Cohesive action>` — <reason>
```

The router (`cohesively`) is exempt: its output is a one-sentence announcement, not a workflow output.

## Scope

### Applies to
- `skills/discover-substrate/SKILL.md` output schema
- `skills/brainstorm-design/SKILL.md` output schema
- `skills/rewrite-specs/SKILL.md` output schema
- `skills/review-spec-cohesion/SKILL.md` output schema (one per verdict)
- `skills/cohesive-review/SKILL.md` output schema (one per scope)
- Every future Cohesive subskill

### Does not apply to
- The router (`cohesively`) — it announces, it doesn't terminate a workflow.
- Mid-process intermediate outputs (e.g., a skill that pauses for user approval mid-way). Only the terminal output is constrained.
- The reviewer agents themselves (they return findings to the dispatching skill, not directly to the user).

## Why this matters

The substrate discipline Cohesive teaches is fundamentally about *making the next move obvious*. A user finishing `discover-substrate` shouldn't have to guess whether `brainstorm-design`, `rewrite-specs`, or `cohesive-review` comes next — the substrate skill knows the answer based on what it found. Forcing every skill to name its successor is the simplest way to encode "what's the next move" as part of the skill's contract rather than as a routing question the user has to re-derive.

It also supports composability: skills can be invoked directly without going through the router, and the recommended-next-skill pointer keeps the workflow legible regardless of entry point.

The self-review on 2026-05-04 noted variation: `discover-substrate/SKILL.md:150` enforces this; `cohesive-review/SKILL.md` does not consistently for `--scope diff` or `--scope substrate`; `review-spec-cohesion/SKILL.md:71-75` lists three options without anchoring them to verdicts. The rule itself was correct; its statement drifted across skills.

## Where this rule must hold

Every `skills/<name>/SKILL.md` with an "Output format" section must show, inside that section, a `### Recommended next Cohesive skill` block. New skills inherit the rule via `references/skill-conventions.md`.

## Enforcement

- **Tests:** none yet. V1 will add an output-schema parser that loads each SKILL.md, locates the "Output format" code block, and asserts the block contains a `### Recommended next Cohesive skill` header.
- **Semantic linters:** `scripts/validate_plugin.sh` greps each SKILL.md (excluding `cohesively/SKILL.md`) for the canonical header. For skills with multiple verdict-branches, the validator checks that the header appears once per documented branch.
- **CI checks:** through `validate_plugin.sh`.

## Known bypass risks

- **A skill that legitimately has no obvious next step** ("Approved" verdict leading to user action outside Cohesive). Mitigated by allowing non-Cohesive next-step entries in the section.
- **A skill that recommends multiple skills "depending on context."** Forbidden — pick one (the most likely successor) or split into verdict-branches and name one per branch. The discipline is in forcing the choice; ambiguity defeats the rule.
- **A skill that recommends skipping ahead two steps** (e.g., `brainstorm-design` recommending `review-spec-cohesion`, skipping `rewrite-specs`). Allowed only if the in-between step is genuinely optional in that branch; otherwise recommend the next adjacent step.

## Review checklist

When reviewing a SKILL.md change:

- [ ] Does the "Output format" section contain a `### Recommended next Cohesive skill` block?
- [ ] If the skill has multiple verdict-branches, is there exactly one recommendation per branch?
- [ ] Is each recommendation a specific skill (or non-Cohesive action), not an "it depends" list?
- [ ] Does the recommendation include a one-clause reason?

## Related

- **`references/skill-conventions.md`** carries the rule for new skills.
- **Self-review finding 5** named the inconsistency across skills.

## History

- 2026-05-04 — Created. Promoted from per-skill acceptance criteria to a named cross-cutting invariant. Resolves the verdict-branch ambiguity by allowing one-recommendation-per-branch.
