# Reviewer Output Shape Behavior Matrix

**Status:** Active
**Last reviewed:** 2026-05-04
**Owner:** Mark Toda

## Purpose

The five reviewer agents under `agents/` each produce findings. The canonical finding shape is defined in `references/reviewer-agent-template.md` §"Output format conventions": six fields per finding (Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact). The synthesizing skills (`review-codebase` Phase 4, `review-diff`, or `validate-rewrite`) merge findings from one or more agents into a unified report — a merge that only works if the agents produce findings in the same shape.

This matrix tracks which agent file teaches which fields. A cell of `✓` means the agent's "How to structure your output" section explicitly lists the field. A cell of `✗` means the field is absent. A cell of `~` means the field is renamed (cell text names the rename).

When the matrix shows divergence, the synthesizer must hand-merge — exactly the failure mode the canonical shape is supposed to prevent.

## Cells

| Agent | Severity | Category | Why it matters | Evidence | Recommended fix | Substrate artifact |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| substrate-alignment-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| structure-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| library-native-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| agent-readiness-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| spec-cohesion-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

This matrix's cells reflect the state *after* the 2026-05-04 skill-architecture repair pass. Prior state showed drift: `substrate-alignment-reviewer` dropped Evidence; `library-native-reviewer` and `agent-readiness-reviewer` dropped Category; `spec-cohesion-reviewer` used a different shape entirely (Risk / Substrate artifact / Suggested repair). The repair pass swept all five to canonical.

## Rules

- The canonical six fields are mandatory in every reviewer agent's "How to structure your output" section, in the order shown above.
- When adding a new reviewer agent, copy the output-format block from `references/reviewer-agent-template.md` §"Output format conventions" verbatim. Do not invent new fields.
- When adding a new field (e.g., "Confidence" in some V1 setting), update this matrix and all five agent files in the same pass — partial drift breaks synthesis.
- `review-codebase` Phase 4, `review-diff`, and `validate-rewrite` synthesis can assume canonical shape from any reviewer agent dispatched. If a finding arrives in a different shape, that's a regression to be filed against this matrix.

## Severity vocabulary (also canonical)

For the Severity field, every agent uses one of:

- **Blocker** — would produce a defect or already has; substrate must be repaired before further work.
- **High** — high-leverage substrate gap; not yet a defect, but a predictable source of future defects.
- **Medium** — substrate improvement worth making in the next pass.
- **Low** — taste-level observation; useful context but not actionable on its own.

Per `references/cohesion-rubric.md`, agents do not mark every finding Blocker. If everything is Blocker, prioritization is failing.

## Removed cells

| Agent | Removed on | Reason |
|---|---|---|
| _none yet_ | | |

## Out of scope

- The agent's *internal* analysis structure (the "How to scope your reading" section, the "What you check" section). Different agents have different lenses; only the *output* must be uniform.
- The dispatch protocol shape (claimed-system-shape, normative-doc paths, scope, discovery report). That's defined in `docs/substrate/designs/agent-dispatch-protocol.md`.
- The canonical fresh-eyes preamble bullet. That's a convention in `references/reviewer-agent-template.md`; not a finding-shape concern.

## Notes

- This matrix is small (5 rows × 6 columns) but exists for the same reason every behavior matrix does: branchy agreement between independent files needs a single normative grid that a contributor can read at a glance.
- If agent count grows beyond ~8, consider grouping into review families (substrate-side / structure-side / quality-side) and producing per-family sub-matrices.

## Related substrate

- `references/reviewer-agent-template.md` §"Output format conventions" — the canonical shape definition.
- `docs/substrate/designs/agent-dispatch-protocol.md` — dispatch protocol the synthesizer relies on.
- `skills/review-codebase/SKILL.md` Phase 4 and `skills/review-diff/SKILL.md` — synthesis steps that require shape uniformity.
- `skills/validate-rewrite/SKILL.md` — single-agent dispatch; same canonical shape required.

## History

- 2026-05-04 — Created during the skill-architecture repair pass. Promoted from drift identified in `docs/history/reviews/2026-05-04-skill-architecture-review.md` Finding #9 to a tracked behavior matrix.
