# Skill Section Presence Behavior Matrix

**Status:** Active
**Last reviewed:** 2026-05-04
**Owner:** Mark Toda

## Purpose

The eight Cohesive skills under `skills/` each carry a SKILL.md body. The canonical body sections — required and optional — are defined in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/skill-conventions.md` §"Required body sections" and §"Optional sections". Section drift across skill files is the kind of regression a reviewer happens to notice but no structural check catches.

This matrix tracks which canonical section each skill carries, in one grid. A cell of `✓` means the section is present at H2 (`##`). A cell of `~` means the skill uses a documented exemption (the deviation is named in `docs/substrate/designs/skill-conventions.md` §"When sections may differ"). A cell of `✗` means the section is absent without an exemption — that's the drift this matrix exists to surface.

Mirror skill: `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` (5 reviewer agents × 6 finding fields). Same pattern, applied to the skill layer.

## Cells: required sections

| Skill | What this skill produces | Hard constraints | Process | Output format | Acceptance criteria | What this skill is *not* |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| cohesively | ~ (named "What this skill does"; router exemption) | ~ (named "Required behavior"; router exemption) | ~ (named "Routes"; router exemption) | ~ (named "Output"; router exemption) | ✓ | ✓ |
| discover-substrate | ✓ | ~ (replaced by "When to invoke" + "Inputs"; documented exemption) | ✓ | ✓ | ✓ | ✓ |
| brainstorm-design | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| rewrite-specs | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| validate-rewrite | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| review-codebase | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| review-diff | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| audit-substrate | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

## Cells: optional sections

| Skill | Worktree handling | Anti-patterns / Red flags | Composition | Token discipline | Routes |
|---|:-:|:-:|:-:|:-:|:-:|
| cohesively | – | "Red flags" | – | – | ✓ (router only) |
| discover-substrate | – | "Red flags" | – | – | – |
| brainstorm-design | – | "Red flags" | ✓ | – | – |
| rewrite-specs | ✓ | "Anti-patterns (Red Flags)" | – | – | – |
| validate-rewrite | – | "Red flags" | ✓ | – | – |
| review-codebase | – | "Red flags" | ✓ | ✓ | – |
| review-diff | – | "Red flags" | ✓ | ✓ | – |
| audit-substrate | – | "Red flags" | ✓ | – | – |

A `–` means the section is intentionally absent (the skill genuinely doesn't need it). A `✓` means present.

## Documented exemptions

Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/skill-conventions.md` §"When sections may differ":

- **`cohesively`** is the router. It replaces "Process" with "Routes" + "Routing decision logic," and may use "Required behavior" instead of "Hard constraints." It also uses "Output" instead of "Output format" because its output is a one-sentence announcement, not a persisted artifact. The router has no "Composition" because it composes nothing — it dispatches.
- **`discover-substrate`** uses "When to invoke" + "Inputs" + "Process" instead of "Hard constraints" + "Process." It is a no-dispatch utility skill that has prereq-shaped guidance to give callers rather than process-internal constraints to enforce.

These two exemptions are the only deviations accepted in v0.1. Any other deviation is drift to be addressed.

## Rules

- The required-sections grid (first table) must be all `✓` or `~` (with the exemption named in the cell). A `✗` means a regression to be filed.
- New skills follow the canonical section order from `docs/substrate/designs/skill-conventions.md`. Adding a new exemption requires updating `skill-conventions.md` §"When sections may differ" *in the same pass* — the matrix must not list an exemption that the convention doc doesn't recognize.
- Optional sections (second table) are skill-by-skill judgment. The matrix records what *is* present so a contributor can compare a new skill against the working set. There is no "must-have" rule for optional sections, only the documented optionals from `skill-conventions.md` §"Optional sections".
- This matrix is checked at review time (`cohesive:review-codebase`, `cohesive:review-diff`). Promotion to `validate_plugin.sh` enforcement is possible but not done in v0.1 — section presence is a structural-grep target if drift becomes a real failure mode.

## Out of scope

- The *content* of each section. The convention doc carries content rules; this matrix only tracks presence.
- Sub-section structure (e.g., what's inside Process, how many phases, etc.). That's per-skill judgment.
- Code-block-internal headings. The output-format section frequently contains `## ...` headings that are part of the rendered template; those are not body sections of the skill itself and are not counted here.
- The `### Recommended next Cohesive skill` footer (`H3`, lives inside Output format). Tracked by `validate_plugin.sh` check 12, not by this matrix.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/skill-conventions.md` §"Required body sections" / §"Optional sections" / §"When sections may differ" — the convention this matrix tracks.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` — the working precedent for "field presence across N components" matrix shape.
- `${CLAUDE_PLUGIN_ROOT}/scripts/validate_plugin.sh` — checks frontmatter shape and a small set of body-content greps; does not yet check section presence.

## History

- 2026-05-04 — Created during the v0.1 release-gate Phase 1+2 substrate repair pass. Promoted from finding #7 of `docs/history/reviews/2026-05-04-skill-quality-self-review.md`. The same pass added the canonical "What this skill is *not*" section to `validate-rewrite/SKILL.md`, which the matrix would otherwise have shown as a `✗`.
