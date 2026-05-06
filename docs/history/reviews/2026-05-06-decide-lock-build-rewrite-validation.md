# Rewrite Validation Review — Decide → Lock → Build user-facing gate framing

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** Decide → Lock → Build user-facing gate framing rewrite on branch `design/decide-lock-build`; design delta ledger at `docs/history/delta-ledgers/2026-05-06-decide-lock-build.md`

**Status:** Issues Found

## Executive judgment

The rewrite is a clean reframing of the user-facing surface and the audience seam holds — chain-rendering is structurally retired, the gate vocabulary lands in the right places (router, README, audience-separation), and the Architectural reflection slot is well-specified across the cohesion-review template, the chat-trailer Variants row, and the validate-rewrite Output format. However, three surfaces still carry pre-rewrite "matrix" / "rows" language that contradicts the new default-recommend shape, and one of those — the design-layer claim in `skills.md` — is precisely the lens-13 drift the substrate-first convention exists to prevent. A future contributor reading `validate-rewrite/SKILL.md` Hard constraint #3 plus Step 5 plus skills.md will not be able to tell whether the Approved trailer is a four-row markdown table or a one-default-plus-disclosure list-shape, because the rewrite uses both vocabularies. Repair is local; the design itself is sound.

## Delta at a glance

This rewrite is **Mixed** — primarily Design (user-facing surface restructure: gate vocabulary, chain-rendering retired, lock→build handoff reflection, build-end spec-coverage verdict) with implementation seams in the chat-trailer template, the cohesion-review template, two SKILL.md `## Output format` blocks, and one validator check.

**Design-layer changes:**
- `docs/substrate/architecture/skills.md` — lead paragraph and Skill set table reframed around gates; Gate column added.
- `docs/substrate/conventions/audience-separation.md` — new section "Gate vocabulary is the user-facing chat-surface vocabulary" pinning the gate vocabulary as the user-facing surface.

**Implementation changes:**
- `skills/cohesively/SKILL.md` — restructured around 3 gates + 3 diagnostics; chain-suffix retired from announcements; per-route outcome sentences updated.
- `skills/validate-rewrite/SKILL.md` — Process Step 5 + Output format restructured: Architectural reflection block at top of Approved trailer; render-only-non-empty applied to review sections; Implementation route restructured as default-recommend + (other options) disclosure.
- `skills/implement-cohesively/SKILL.md` — Output format restructured: Code-matches-locked-design slot leads, surfacing the Phase 3 final review-diff verdict prominently.
- `references/templates/chat-trailer.md` — Render-only-non-empty rule and Default-recommend rule added; Variants table updated for validate-rewrite (Architectural reflection block) and implement-cohesively (Code-matches-locked-design slot).
- `references/templates/cohesion-review.md` — Architectural reflection block added (render context + persisted-file format); per-section render-iff-non-empty notes added; Next block reshaped to default-recommend + disclosure.
- `README.md` — Main commands and Workflows sections rewritten around gates.
- `scripts/validate_plugin.sh` — Check 13e generalized from four-row-table grep to four-token coverage grep, accommodating the new default-recommend + disclosure render shape.

- **Files:** 9 rewritten, 1 added (this ledger), 0 removed
- **Conceptual changes:** chain-rendering retired from chat-render surfaces; 5-imperative user-facing chain reframed as 3 user-facing gates (Decide / Lock / Build); lock→build handoff promoted to a substantive architectural-reflection moment; build-end review surfaced as a top-of-trailer spec-coverage verdict
- **Named invariants:** none added / removed / changed; `IMPLEMENTATION_PLAN_COVERS_DELTA` and `VERDICT_BEFORE_EVIDENCE` continue to hold
- **Behavior matrices:** `docs/substrate/matrices/router.md` unchanged (route names stable for Check 13i parity)
- **Gotchas:** none added / retired
- **Semantic linters:** Check 13e in `scripts/validate_plugin.sh` generalized (token-coverage rather than row-shape)
- **Tests proposed:** A future Check 13l candidate could grep `skills/cohesively/SKILL.md` §"Output" canonical announcement template against the literal `: skill-1 → skill-2 → skill-3` anti-pattern. Deferred until wording stabilizes
- **Deferred (out of scope this pass):** Verdict-vocabulary tweaks; Validator check (Check 13l candidate); using-cohesive body prose

## Blocking issues

### B1. Design-layer skills.md still claims a "decision matrix" while implementation switched to default-recommend (lens 13 drift)

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** `docs/substrate/architecture/skills.md` line 148 says `validate-rewrite` Owns "Rendering the per-verdict decision matrix on terminal verdicts (Approved → implementation options; Design Incoherent → re-brainstorm; max-passes stall → user direction)." The decide-lock-build rewrite retired the four-row decision matrix in favor of a default-recommend + `(other options)` disclosure (per ledger conceptual-changes row 3 and `references/templates/chat-trailer.md` §"Default-recommend rule"). Per `docs/substrate/conventions/skill-shape.md` §"When to edit SKILL.md alone, and when to edit the design layer first", a render-shape change of this kind is exactly what should propagate from the design layer; instead skills.md still names the retired shape. A future contributor reading the design layer first will re-derive the matrix shape and contradict the chat-trailer template. The skills.md row is marked `validated` (line 67 of skills.md), so the staleness silently survives the validator.
- **Evidence:**
  - `docs/substrate/architecture/skills.md`:148 — "Rendering the per-verdict decision matrix on terminal verdicts (Approved → implementation options;...)"
  - `references/templates/chat-trailer.md`:84 — "the default-recommend rule applied — `cohesive:implement-cohesively` is the lead recommendation; alternatives sit behind a `(other options)` disclosure"
  - `skills/validate-rewrite/SKILL.md`:124 — "Implementation route — render with the default-recommend rule"
- **Recommended fix:** In `skills.md` `### validate-rewrite` Owns, replace "Rendering the per-verdict decision matrix on terminal verdicts" with "Rendering the per-verdict next step on terminal verdicts (Approved → default-recommend implementation route per the chat-trailer template; Design Incoherent → re-brainstorm; max-passes stall → user direction)." Cite the chat-trailer §"Default-recommend rule" rather than carrying the shape inline.
- **Substrate artifact to add or update:** spec (the design-layer skills.md `### validate-rewrite` section)

### B2. validate-rewrite/SKILL.md normative prose still describes a "matrix" / "rows" the rewrite retired

- **Severity:** High
- **Category:** Vague language
- **Why it matters:** Three normative passages in `skills/validate-rewrite/SKILL.md` describe the Approved-branch implementation route in matrix/row vocabulary that no longer matches what gets rendered. A user reading Hard constraint #3 ("the user picks among the rows of the implementation decision matrix in the Output format block") and arriving at an Output format that renders one default sentence + a `<details>` disclosure has to reconcile the contradiction at read-time. The bypass-acknowledgment instruction at line 218 ("When the user picks the third row (`superpowers:writing-plans` directly)…") is the worst case — there is no third row in the new shape; `superpowers:writing-plans` is the second `<details>` bullet. A future contributor implementing the bypass-acknowledgment trigger will not know what "third row" refers to.
- **Evidence:**
  - `skills/validate-rewrite/SKILL.md`:22 — "the user picks among the rows of the implementation decision matrix in the Output format block"
  - `skills/validate-rewrite/SKILL.md`:142 — "the `### Next` footer carries the **Disposition** phrase + (Approved-only) **Implementation route** matrix"
  - `skills/validate-rewrite/SKILL.md`:216 — "Render the implementation decision matrix iff the verdict is `Approved`"
  - `skills/validate-rewrite/SKILL.md`:218 — "When the user picks the third row (`superpowers:writing-plans` directly)…"
- **Recommended fix:** Replace "decision matrix" / "rows" with "default-recommend route per the chat-trailer §'Default-recommend rule'" and "alternatives in the `(other options)` disclosure". For the bypass acknowledgment at line 218, name the bypass option by its decision-shape phrase ("Hand off to Superpowers without delta-coverage discipline") rather than its render position.
- **Substrate artifact to add or update:** spec (the validate-rewrite SKILL body)

## Important issues

### I1. cohesion-review.md "three questions" prose lists four bullets

- **Severity:** Low
- **Category:** Vague language
- **Why it matters:** `references/templates/cohesion-review.md`:13 says the Architectural reflection "answers three questions concretely:" but the bulleted list immediately following has four items (How it feels now / Easier / Harder / Load-bearing). A reviewer template author who treats the prose as normative will produce three bullets and drop one of the four; a template author who treats the bullets as normative will count four. The persisted-file format block at lines 22-32 has a different shape (one paragraph + three bullets), which adds a third interpretation.
- **Evidence:**
  - `references/templates/cohesion-review.md`:13-18 — "answers three questions concretely:" followed by four bullets
  - `references/templates/cohesion-review.md`:22-32 — persisted-file format with paragraph + three bullets
- **Recommended fix:** Reconcile to one shape. Either say "answers four questions" with four bullets, or restructure as "one paragraph (how it feels now) + three bullets (Easier / Harder / Load-bearing)" matching the persisted-file format block. The chat render template in `validate-rewrite/SKILL.md`:151-157 already follows the latter shape; align the cohesion-review.md prose with it.
- **Substrate artifact to add or update:** spec (cohesion-review.md template)

### I2. chat-trailer.md vs implement-cohesively diverge on "## Final substrate review" naming

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** `references/templates/chat-trailer.md`:87 (Variants row for implement-cohesively) says "long-form review detail lives in the persisted `## Final substrate review` section, not chat" — implying a section *inside* the persisted file. `skills/implement-cohesively/SKILL.md`:151 renders the pointer as a separate file path: `docs/history/reviews/<YYYY-MM-DD>-<slug>-final-substrate-review.md`. A reader implementing the persisted-file shape gets two different artifacts: a section inside an aggregate persisted file vs a standalone review file alongside the trailer.
- **Evidence:**
  - `references/templates/chat-trailer.md`:87 — "the persisted `## Final substrate review` section"
  - `skills/implement-cohesively/SKILL.md`:151 — `Phase 3 review: \`docs/history/reviews/<YYYY-MM-DD>-<slug>-final-substrate-review.md\``
- **Recommended fix:** Pick one. Most consistent with the rest of the substrate (per-pass reviews are standalone files) is the standalone-file shape; update the chat-trailer Variants row to say "long-form review detail lives in the persisted Phase 3 review file, not chat" and cite the path shape from the SKILL.
- **Substrate artifact to add or update:** spec (chat-trailer.md Variants row)

### I3. Architectural reflection render template in validate-rewrite SKILL.md mixes parenthetical render-conditions into the literal template

- **Severity:** Low
- **Category:** Enforcement
- **Why it matters:** Lines 167-194 of `skills/validate-rewrite/SKILL.md` are inside a fenced ```md render template, but several lines carry parenthetical instructions like `*(rendered iff non-empty — already synthesized into Architectural reflection on Approved)*` and an HTML comment at line 165 (`<!-- Render only non-empty review sections... -->`). These are render-meta instructions for the agent, not content the user should see. The substrate already has the gotcha `style-guide-rot.md` documenting that instructions placed inside render templates leak verbatim into user-facing output. The Voice section (line 16) explicitly warns against this, but the meta-instructions in the Output format render template repeat the failure pattern in a softer form.
- **Evidence:**
  - `skills/validate-rewrite/SKILL.md`:165 — `<!-- Render only non-empty review sections per the chat-trailer template's §"Render-only-non-empty rule"... -->` (inside ```md fence)
  - `skills/validate-rewrite/SKILL.md`:177-183 — multiple `*(rendered iff non-empty — already synthesized into Architectural reflection on Approved)*` parentheticals
- **Recommended fix:** Move the render-conditional logic out of the literal render template and into the prose immediately preceding it (e.g., a §"Render-conditional rules for the body block" subsection that names which sections collapse on Approved). The render template should contain only what the model is meant to reproduce.
- **Substrate artifact to add or update:** spec (validate-rewrite SKILL Output format block) and a possible follow-up to the Check 13d anti-citation lint to extend coverage to render-meta instructions

## Substrate gaps

- **No semantic-linter forcing function for design-layer / SKILL.md drift on shape changes (lens 13).** B1 above is a clear instance: a render-shape change in the SKILL implementation should have triggered a same-pass edit to skills.md, but skills.md silently kept the retired vocabulary. The Bootstrap status table marks the row `validated`, so future readers will trust it. The deferred Check 13l candidate already tracks chain-rendering anti-pattern; a parallel candidate would grep skills.md for retired shape vocabulary against current SKILL.md output-format vocabulary, but such a check is hard to specify mechanically. Convention-with-template plus per-pass reviewer attention (lens 13 itself) is the realistic enforcement; the gap is that this rewrite did not exercise it on the design layer.

## Locality concerns

- The chat-trailer template's §"Default-recommend rule" is the canonical home of the disclosure shape. Three skills (validate-rewrite, cohesion-review template, audience-separation) cite it correctly. The validate-rewrite SKILL body still inlines partial matrix vocabulary (B2) — the locality seam is right; the duplication is what's broken.

## Future-fit concerns

- The ledger §"Remaining ambiguity" calls out that "Decide → Lock → Build" parallels Superpowers' `brainstorm → plan → execute` and may need a fourth gate if a future skill emerges between Lock and Build. This is correctly framed as future pressure (non-normative). The ledger's commitment to three gates as v0.1 is appropriate; no smuggling into normative sections.

## Enforcement concerns

- Render-only-non-empty is enforced by template content (the centralized chat-trailer §"Render-only-non-empty rule") + reviewer attention; no validator check yet. Acceptable per `style-guide-rot.md` promotion criteria.
- Default-recommend is enforced the same way. Check 13e was generalized to token-coverage instead of row-shape, which is the correct move — the linter no longer over-specifies render shape.

## Behavior knowable outside implementation?

Mostly yes. The Architectural reflection slot is well-specified across three surfaces (cohesion-review template, validate-rewrite Output format, chat-trailer Variants). The Code-matches-locked-design slot in implement-cohesively is similarly well-specified. The exception is the validate-rewrite Implementation route shape, where the matrix/default-recommend contradiction (B1, B2) means a future reader cannot reliably reproduce the Approved trailer without picking one normative source.

## Vague language to tighten

- `skills/validate-rewrite/SKILL.md`:22 — "the user picks among the rows of the implementation decision matrix"
- `skills/validate-rewrite/SKILL.md`:142 — "the `### Next` footer carries the **Disposition** phrase + (Approved-only) **Implementation route** matrix"
- `skills/validate-rewrite/SKILL.md`:216 — "Render the implementation decision matrix iff the verdict is `Approved`"
- `skills/validate-rewrite/SKILL.md`:218 — "When the user picks the third row"
- `docs/substrate/architecture/skills.md`:148 — "Rendering the per-verdict decision matrix on terminal verdicts"
- `references/templates/cohesion-review.md`:13 — "answers three questions concretely:" (followed by four bullets)

## Recommended repairs (ranked)

1. **Sweep validate-rewrite/SKILL.md and skills.md for "matrix" / "rows" / "third row" residue** (closes B1, B2, three of the six vague-language flags). Replace with default-recommend / `(other options)` vocabulary; cite the chat-trailer §"Default-recommend rule" rather than restate.
2. **Reconcile the cohesion-review.md "three questions / four bullets" mismatch** (closes I1) and align the prose with the persisted-file format block.
3. **Pick one shape for the Phase 3 review persistence and update chat-trailer.md Variants row** to match implement-cohesively SKILL (closes I2).
4. **Move render-conditional parentheticals out of the validate-rewrite Output format render template** (closes I3) into prose preceding the template.

## What looked right

- Chain-rendering retirement is structural across all five user-facing surfaces (cohesively/SKILL.md announcement template, README Workflows, audience-separation table, cohesion-review template, chat-trailer template). The audience seam holds.
- The Architectural reflection slot is specified once (cohesion-review.md §"Architectural reflection") and cited from the two consumers (validate-rewrite Output format, chat-trailer Variants). Clean locality.
- Check 13e generalization to token-coverage is the right substrate move — the linter no longer over-specifies render shape, so future render-shape changes can land without lockstep linter edits.
- audience-separation.md §"Gate vocabulary is the user-facing chat-surface vocabulary" is a textbook structural-mitigation section: it pins the convention with a per-surface lead-vocabulary table, retires the chain-rendering pattern by name, and cites the chat-trailer template as the structural enforcement.

### Next

**Disposition:** Repair → re-validate

Highest severity present is `High` (B1, B2). The verdict-floor mapping in `references/cohesion-rubric.md` §"Verdict → severity-floor mapping (validate-rewrite)" requires `Issues Found`; the disposition rule routes to a repair pass and re-validation. The Implementation route slot is omitted per the rubric — Approved was not reached.
