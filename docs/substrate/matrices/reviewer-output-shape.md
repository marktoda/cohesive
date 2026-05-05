# Reviewer Output Shape Behavior Matrix

**Status:** Active
**Last reviewed:** 2026-05-04
**Owner:** Mark Toda

## Purpose

The five reviewer agents under `agents/` each produce findings. The canonical finding shape is defined in `docs/substrate/designs/reviewer-agent-template.md` §"Output format conventions": six fields per finding (Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact). The synthesizing skills (`review-codebase` Phase 4, `review-diff`, or `validate-rewrite`) merge findings from one or more agents into a unified report — a merge that only works if the agents produce findings in the same shape.

This matrix tracks which agent file teaches which fields. A cell of `✓` means the agent's "How to structure your output" section explicitly lists the field. A cell of `✗` means the field is absent. A cell of `~` means the field is renamed (cell text names the rename).

When the matrix shows divergence, the synthesizer must hand-merge — exactly the failure mode the canonical shape is supposed to prevent.

## Cells

Cell legend:
- `✓` — both spec required and agent file complies
- `pending` — spec required (substrate has been updated) but agent file does not yet carry the line; queued for implementation follow-up per `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-04-cut-anchor-pin.md`
- `✗` — spec required and agent file is non-compliant (regression; should not appear in a clean release)

| Agent | Severity | Category | Why it matters | Evidence | Recommended fix | Substrate artifact | Voice citation |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| substrate-alignment-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| structure-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| library-native-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| agent-readiness-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| spec-cohesion-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

The first six columns reflect the state *after* the 2026-05-04 skill-architecture repair pass. Prior state showed drift: `substrate-alignment-reviewer` dropped Evidence; `library-native-reviewer` and `agent-readiness-reviewer` dropped Category; `spec-cohesion-reviewer` used a different shape entirely (Risk / Substrate artifact / Suggested repair). That repair pass swept all five to canonical.

The "Voice citation" column was added in the 2026-05-04 `cut-anchor-pin` substrate rewrite. Each agent's "How to structure your output" code block opens with the literal line `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`. All five cells are `✓` after the cut-anchor-pin implementation pass (per `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-04-cut-anchor-pin.md` §"Implementation pass") added the citation line to each agent file and the validator grep that pins it.

### Verdict-leads is tracked elsewhere

Reviewer agents produce findings, not verdicts. The named invariant `VERDICT_BEFORE_EVIDENCE` (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`) applies to the *synthesizing skills* (`review-codebase`, `review-diff`, `validate-rewrite`, `audit-substrate`) that render the user-facing chat output. The truth-table of verdict-led skills lives in that invariant doc's "Applies to" / "Does not apply to" sections — not in this matrix. This matrix scopes to agent-finding shape; verdict shape is a skill-level concern.

## Rules

- The canonical six fields are mandatory in every reviewer agent's "How to structure your output" section, in the order shown above.
- When adding a new reviewer agent, copy the output-format block from `docs/substrate/designs/reviewer-agent-template.md` §"Output format conventions" verbatim. Do not invent new fields.
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
- The canonical fresh-eyes preamble bullet. That's a convention in `docs/substrate/designs/reviewer-agent-template.md`; not a finding-shape concern.

## Notes

- This matrix is small (5 rows × 6 columns) but exists for the same reason every behavior matrix does: branchy agreement between independent files needs a single normative grid that a contributor can read at a glance.
- If agent count grows beyond ~8, consider grouping into review families (substrate-side / structure-side / quality-side) and producing per-family sub-matrices.

## Related substrate

- `docs/substrate/designs/reviewer-agent-template.md` §"Output format conventions" — the canonical shape definition.
- `docs/substrate/designs/agent-dispatch-protocol.md` — dispatch protocol the synthesizer relies on.
- `skills/review-codebase/SKILL.md` Phase 4 and `skills/review-diff/SKILL.md` — synthesis steps that require shape uniformity.
- `skills/validate-rewrite/SKILL.md` — single-agent dispatch; same canonical shape required.

## History

- 2026-05-04 — Created during the skill-architecture repair pass. Promoted from drift identified in `docs/history/reviews/2026-05-04-skill-architecture-review.md` Finding #9 to a tracked behavior matrix.
- 2026-05-04 — `cut-anchor-pin` substrate rewrite: added the "Voice citation" column tracking the new convention pin (each agent's output block opens with the voice citation line). All cells `pending`; implementation follow-up adds the citations and flips them to `✓`. Cross-referenced `VERDICT_BEFORE_EVIDENCE` as the named invariant covering the synthesizing-skill side, which is out of scope for this matrix.
