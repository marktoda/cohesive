# Rewrite Validation Review — audience-seam (pass 2)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** Centralize chat-trailer shell across six verdict-led skills; remove substrate-vocabulary and methodology-name from chat-render surfaces; amend `output-voice.md` rule 2a in place. Per the design delta ledger at `docs/history/delta-ledgers/2026-05-06-audience-seam.md`.

**Verdict:** Approved

## Executive judgment

The rewrite is internally coherent and implementable by a future contributor without conversation-context inheritance. The audience seam is structurally enforced (centralized template literal + content removal) rather than rule-based, which closes the style-guide-rot failure mode the brainstorm flagged. Verdict translation is correctly localized to one render slot; internal labels stay agent-facing across the rubric, handoffs, and reviewer dispatch. Rule 2a's amendment from "subset" to "decision-render of" is consistent with the new template content. The only weaknesses are minor: residual phrasing drift between the cohesion-review template and the chat-trailer template's payload contract, and a `### Next` heading-depth artifact from the rename. All Low-severity, all close-inline.

## Delta at a glance

This rewrite is **Mixed**. Design-layer changes: amend rule 2a in `output-voice.md` to "decision-render of the persisted body"; reword rule 5a to remove methodology-name framing; new convention `audience-separation.md`; new behavior matrix-shaped reference `verdict-vocabulary.md`; new centralized template `chat-trailer.md`. Implementation changes: six SKILL.md `## Output format` blocks rewritten to cite the centralized template + body-block specification only; cohesively router announcement template + using-cohesive orientation message rewritten to lead with outcome; reviewer-output-shape matrix extended with audience-seam-compliance section; handoffs.md gains a verdict-translation note; validate_plugin.sh Check 12 renamed; discover-substrate + rewrite-specs Output format footers renamed.

- **Files:** 13 rewritten, 4 added, 0 removed/deprecated
- **Conceptual changes:** chat-render shell centralized; methodology-name removed from chat surfaces; verdict-translation seam introduced; rule 2a "subset" → "decision-render of"; `### Recommended next Cohesive skill` → `### Next`
- **Named invariants:** `CHAT_TRAILER_VOCABULARY` (candidate, deferred); others unchanged
- **Behavior matrices:** `reviewer-output-shape.md` adds 4-column audience-seam compliance section
- **Gotchas:** none new
- **Semantic linters:** Check 12 grep target updated; Check 13k proposed (deferred)

## Blocking issues

None — highest severity present is Low. Per `cohesion-rubric.md` §"Verdict → severity-floor mapping", Approved is correct.

## Important issues

### I1. cohesion-review.md `### Next` heading depth artifact from the rename

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** The chat-trailer template caps header depth at `###` per voice rule 3; the cohesion-review.md template carries `## Recommended repairs (ranked)` and `## What looked right` as `##` headings — peers of `## Executive judgment`. The pass-1 rename to `### Next` produces a level drop from `##` to `###` with no intermediate hierarchy, reading as an unfinished rename. Not a render failure — the cohesion review is a full review document where this is acceptable — but the inconsistency reads as drift to a fresh reader.
- **Evidence:** `references/templates/cohesion-review.md:81` (`## Recommended repairs (ranked)`) followed by `:87` (`### Next`).
- **Recommended fix:** Add a one-line note in the template's `### Next` prose stating "the `### Next` heading depth matches the centralized chat-trailer template's footer convention per `references/templates/chat-trailer.md` §The shell."
- **Substrate artifact to add or update:** `references/templates/cohesion-review.md` §"Next".

### I2. cohesion-review.md `### Next` block omits the chat-trailer template's payload-kind shape

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** The chat-trailer template specifies the `### Next` shape as `<decision-shaped sentence>. *(skill citation.)* **<Payload-kind>:** <payload>.` The cohesion-review template instead carries `**Disposition:**` followed by `**Implementation route:**` — a different shape. This is correct for `validate-rewrite` (the deviation entry in `skill-shape.md` §"When sections may differ" documents it), but the cohesion-review template doesn't say so inline. A future skill author copying this template would replicate the disposition-then-matrix shape instead of the canonical chat-trailer payload shape.
- **Evidence:** `references/templates/cohesion-review.md:91-93` versus `references/templates/chat-trailer.md` §"The shell" and §"Variants" `validate-rewrite` row.
- **Recommended fix:** Add a one-line comment at `cohesion-review.md` `### Next` block noting that this is the `validate-rewrite` variant per `chat-trailer.md` §"Variants"; future verdict-led skills follow the chat-trailer template's canonical shape.
- **Substrate artifact to add or update:** `references/templates/cohesion-review.md` §"Next".

### I3. discover-substrate/SKILL.md `### Next` block uses non-canonical payload-kind label

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** The chat-trailer template enumerates exactly three payload-kind labels: `**Files to edit:**` / `**Files to add:**`, `**Scope:**`, `**Design question:**`. `discover-substrate/SKILL.md:177` renders a generic `**Payload:**` label that elides the three specific kinds. A future skill author copying this generic shape undermines the lens-3 consistency the matrix at `reviewer-output-shape.md` §"Audience seam compliance" is asserting.
- **Evidence:** `skills/discover-substrate/SKILL.md:177` versus `references/templates/chat-trailer.md` §"How `### Next` carries payload" and `output-voice.md:33-37` rule 5a's three-kinds enumeration.
- **Recommended fix:** Replace the generic `**Payload:**` label with a substitution rule pointing at the chat-trailer's three-kinds table, since discover-substrate's recommendations are heterogeneous (different consumers want different payloads).
- **Substrate artifact to add or update:** `skills/discover-substrate/SKILL.md` §"Output format" `### Next` block.

## Substrate gaps

- Centralized chat-trailer template lacks a worked-render example for the `validate-rewrite` variant. §"Variants" row references the cohesion-review template, but the chat-trailer template itself has no inline example. Low-leverage; close in next pass.

## Locality concerns

The centralization is well-shaped. The drift surface is `O(1)`, not `O(n_skills)`, as `audience-separation.md` forcing-function #2 claims.

## Future-fit concerns

None blocking. `audience-separation.md` §"Promotion path to validator enforcement" names the gate criteria for `CHAT_TRAILER_VOCABULARY` invariant + Check 13k. The deferral is honest and gated.

## Enforcement concerns

`validate_plugin.sh` Check 12 grep target was correctly updated. Check 13k is named, scoped, and deferred with explicit promotion criteria. Voice-imperative checks (13b/13c/13d) are unchanged and continue to work.

## Behavior knowable outside implementation?

Yes. A future contributor reading only the rewritten specs (chat-trailer template, audience-separation convention, verdict-vocabulary mapping, output-voice rule 2a, reviewer-output-shape matrix, the six SKILL.md output formats, and the worked transcript) can reproduce the audience-seam contract end-to-end. The worked transcript is the load-bearing teaching artifact.

## Vague language to tighten

- `references/templates/chat-trailer.md:77` — "When a future contributor adds a new verdict to a skill, they add a row..." — uses "adds" not "must add"; tighten if normative per Check 13k's eventual scope.
- `docs/substrate/conventions/audience-separation.md:60` — "A real regression has occurred — a SKILL.md edit or chat-trailer edit reintroduced substrate vocabulary..." — fine; this is the gate criterion for promotion, deliberately conditional.

## Recommended repairs (ranked)

1. **I2** — close the cohesion-review.md / chat-trailer.md `### Next` shape inconsistency with a one-line citation. Highest leverage.
2. **I3** — tighten `discover-substrate/SKILL.md` payload-kind label.
3. **I1** — add the one-line note in `cohesion-review.md` explaining the `### Next` heading depth.

### Next

**Disposition:** Close inline (≤2 lines per finding) → merge.

(Highest severity present is Low; per `cohesion-rubric.md` §"Disposition rule for validation-review findings", `Approved + Low` maps to close-inline. No re-validation required after repair.)

**Implementation route** — pick one:

| Option | Skill | When to pick |
|---|---|---|
| Implement now with delta-coverage discipline (default) | `cohesive:implement-cohesively` | Substantial rewrites — the rewrite added new docs, structural conventions, or cross-cutting changes. Phase loop with per-phase cross-review against the delta. |
| Land specs first; implement separately later | merge the `design/<slug>` branch first; later run `cohesive:implement-cohesively` against the merged delta ledger | The doc rewrite is independently valuable for human review before code lands. |
| Hand off to Superpowers without delta-coverage discipline | `superpowers:writing-plans` | Small rewrites where the doc delta is mostly cosmetic; user accepts that the implementation may drift from the rewrite. |
| Schedule for later | (no immediate action) | The rewrite is approved; implementation is not currently in scope. |

This rewrite is doc-only (no code surfaces; the validator-script Check 12 grep target update is the sole non-doc edit and was atomic with the rename). The "schedule for later" or "land specs first" rows are the natural fit; implementing-cohesively against a doc-only delta would mostly produce a no-op phase.

## What looked right

- **Structural enforcement over rule addition.** Replacing "add rule 6" with "centralize the template + remove forbidden tokens from the literal" is the right move per `style-guide-rot.md`'s thesis. The brainstorm pressure-test that surfaced this (Option B → Option D) is the exemplary use of the pressure-test machinery.
- **Verdict translation localized to one render slot.** Internal labels stay agent-facing across `cohesion-rubric.md`, `handoffs.md` edge entries, and reviewer-agent verdict vocabularies. The translation lives in one file consumed by one slot. Lens-13/lens-14 chain-edge consistency holds.
- **Worked transcript pair carries decision-shape vs substrate-shape side-by-side.** The "What's wrong with this" annotations on the anti-example are concrete enough that a contributor authoring a new skill can self-check.
- **`reviewer-output-shape.md` §"Audience seam compliance" tracks per-skill citation + body-block + verdict-translation + heading state.** Four well-chosen columns; the matrix generalizes when a new verdict-led skill is added.
