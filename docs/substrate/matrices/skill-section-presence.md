# Skill Section Presence Behavior Matrix

**Status:** Active
**Last reviewed:** 2026-05-05
**Owner:** Mark Toda

## Purpose

The eleven Cohesive skills under `skills/` each carry a SKILL.md body. The canonical body sections — required and optional — are defined in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Required body sections" and §"Optional sections". Section drift across skill files is the kind of regression a reviewer happens to notice but no structural check catches.

This matrix tracks which canonical section each skill carries, in one grid. A cell of `✓` means the section is present at H2 (`##`). A cell of `~` means the skill uses a documented exemption (the deviation is named in `docs/substrate/conventions/skill-shape.md` §"When sections may differ"). A cell of `✗` means the section is absent without an exemption — that's the drift this matrix exists to surface.

Mirror skill: `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` (5 reviewer agents × 6 finding fields). Same pattern, applied to the skill layer.

## Cells: required sections

| Skill | What this skill produces | Voice | Hard constraints | Process | Output format | Acceptance criteria | What this skill is *not* |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| cohesively | ~ (named "What this skill does"; router exemption) | ~ (router exempt; render budget too small to need imperative) | ~ (named "Required behavior"; router exemption) | ~ (named "Routes"; router exemption) | ~ (named "Output"; router exemption) | ✓ | ✓ |
| using-cohesive | ~ (named "What this skill does"; router exemption) | ~ (router exempt; render budget too small to need imperative) | ~ (named "Required behavior"; router exemption) | ~ ("When Cohesive applies" + "When to defer to Superpowers" + "How to enter Cohesive"; session-start orientation exemption) | ~ (named "Output"; router exemption) | ✓ | ✓ |
| discover-substrate | ✓ | ✓ | ~ (replaced by "When to invoke" + "Inputs"; documented exemption) | ✓ | ✓ | ✓ | ✓ |
| brainstorm-design | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| rewrite-specs | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| validate-rewrite | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| implement-cohesively | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| review-codebase | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| review-diff | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| audit-substrate | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| init | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

The `Voice` column tracks the body-level imperative section added in the 2026-05-04 voice-citation-imperative pivot (per `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-04-voice-citation-imperative.md`). For each non-router skill, the `## Voice` section appears between `## What this skill produces` and `## Hard constraints` (or before `## When to invoke` for `discover-substrate`) and contains the literal imperative `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.`. The router (`cohesively`) is exempt — its render budget is 1–2 sentences and its dispatched subskills carry the voice load. Validator Check 13b greps each non-router SKILL.md body (outside fenced code blocks) for the imperative; this matrix tracks the section's *placement* (a stricter rule than the validator's grep) — drift in placement is a regression to file even if Check 13b passes.

## Cells: optional sections

| Skill | Worktree handling | Anti-patterns / Red flags | Composition | Token discipline | Routes |
|---|:-:|:-:|:-:|:-:|:-:|
| cohesively | – | "Red flags" | – | – | ✓ (router only) |
| using-cohesive | – | – | – | – | – |
| discover-substrate | – | "Red flags" | – | – | – |
| brainstorm-design | – | "Red flags" | ✓ | – | – |
| rewrite-specs | ✓ | "Anti-patterns (Red Flags)" | – | – | – |
| validate-rewrite | – | "Red flags" | ✓ | – | – |
| implement-cohesively | – | "Anti-patterns (Red Flags)" | ✓ | – | – |
| review-codebase | – | "Red flags" | ✓ | ✓ | – |
| review-diff | – | "Red flags" | ✓ | ✓ | – |
| audit-substrate | – | "Red flags" | ✓ | – | – |
| init | – | "Red flags" | ✓ | – | – |

A `–` means the section is intentionally absent (the skill genuinely doesn't need it). A `✓` means present.

## Documented exemptions

Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"When sections may differ":

- **`cohesively`** is the router. It replaces "Process" with "Routes" + "Routing decision logic," and may use "Required behavior" instead of "Hard constraints." It also uses "Output" instead of "Output format" because its output is a one-sentence announcement, not a persisted artifact. The router has no "Composition" because it composes nothing — it dispatches.
- **`using-cohesive`** is the session-start orientation skill. It carries the same router exemption as `cohesively` (no `## Voice` — render budget too small to need the imperative; uses "Output" instead of "Output format" because the output is a 1–2 sentence orientation, not a persisted artifact; uses "Required behavior" instead of "Hard constraints"). Unlike `cohesively`, it does not select routes; instead of "Routes" + "Routing decision logic" it carries "When Cohesive applies" + "When to defer to Superpowers" + "How to enter Cohesive" as a 3-section decision rule. The skill has no "Composition" because its only downstream is `cohesively` itself, which is the universal entry point — naming `cohesively` as a composition target would be circular.
- **`discover-substrate`** uses "When to invoke" + "Inputs" + "Process" instead of "Hard constraints" + "Process." It is a no-dispatch utility skill that has prereq-shaped guidance to give callers rather than process-internal constraints to enforce.

These three exemptions are the only deviations accepted in v0.1. Any other deviation is drift to be addressed.

## Rules

- The required-sections grid (first table) must be all `✓` or `~` (with the exemption named in the cell). A `✗` means a regression to be filed.
- New skills follow the canonical section order from `docs/substrate/conventions/skill-shape.md`. Adding a new exemption requires updating `skill-shape.md` §"When sections may differ" *in the same pass* — the matrix must not list an exemption that the convention doc doesn't recognize.
- Optional sections (second table) are skill-by-skill judgment. The matrix records what *is* present so a contributor can compare a new skill against the working set. There is no "must-have" rule for optional sections, only the documented optionals from `skill-shape.md` §"Optional sections".
- This matrix is checked at review time (`cohesive:review-codebase`, `cohesive:review-diff`). Promotion to `validate_plugin.sh` enforcement is possible but not done in v0.1 — section presence is a structural-grep target if drift becomes a real failure mode.

## Out of scope

- The *content* of each section. The convention doc carries content rules; this matrix only tracks presence.
- Sub-section structure (e.g., what's inside Process, how many phases, etc.). That's per-skill judgment.
- Code-block-internal headings. The output-format section frequently contains `## ...` headings that are part of the rendered template; those are not body sections of the skill itself and are not counted here.
- The `### Recommended next Cohesive skill` footer (`H3`, lives inside Output format). Tracked by `validate_plugin.sh` check 12, not by this matrix.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Required body sections" / §"Optional sections" / §"When sections may differ" — the convention this matrix tracks.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` — the working precedent for "field presence across N components" matrix shape.
- `${CLAUDE_PLUGIN_ROOT}/scripts/validate_plugin.sh` — checks frontmatter shape and a small set of body-content greps; does not yet check section presence.

## History

- 2026-05-04 — Created during the v0.1 release-gate Phase 1+2 substrate repair pass. Promoted from finding #7 of `docs/history/reviews/2026-05-04-skill-quality-self-review.md`. The same pass added the canonical "What this skill is *not*" section to `validate-rewrite/SKILL.md`, which the matrix would otherwise have shown as a `✗`.
- 2026-05-04 — Voice-citation-imperative pivot repair pass: added the `Voice` column to track the new mandatory `## Voice` section in 7 non-router skills (and the router exemption). See `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-04-voice-citation-imperative.md` §"Repair pass 1 (post validation)" — finding I1.
- 2026-05-05 — `skill-pack-flow-tightening` rewrite: added rows for `implement-cohesively` (pre-existing drift fix — the row was absent despite the skill shipping in v0.1) and `using-cohesive` (newly authored session-start orientation skill); updated intro skill count 8 → 10; added the `using-cohesive` documented exemption. See `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-05-skill-pack-flow-tightening.md`.
