# Design Delta Ledger — Decide → Lock → Build user-facing gate framing

**Date:** 2026-05-06
**Worktree / branch:** `.claude/worktrees/decide-lock-build` on `design/decide-lock-build`
**Approved direction:** Hard cut-over to a 3-gate user-facing model (Decide → Lock → Build) with chain-rendering retired from announcements; architectural reflection added at the lock→build handoff; spec-coverage verdict surfaced at the end of build; render-only-non-empty trailer rule and default-recommend disclosure pattern added to the centralized chat-trailer template.

This ledger records what the substrate looks like *after* this rewrite, as a delta from the prior 5-imperative chain framing.

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
- **Conceptual changes:** chain-rendering retired from chat-render surfaces (`<outcome>: skill-1 → skill-2 → skill-3` → just `<outcome>`); 5-imperative user-facing chain reframed as 3 user-facing gates (Decide / Lock / Build); lock→build handoff promoted to a substantive architectural-reflection moment; build-end review surfaced as a top-of-trailer spec-coverage verdict
- **Named invariants:** none added / removed / changed; `IMPLEMENTATION_PLAN_COVERS_DELTA` and `VERDICT_BEFORE_EVIDENCE` continue to hold
- **Behavior matrices:** `docs/substrate/matrices/router.md` unchanged (route names stable for Check 13i parity)
- **Gotchas:** none added / retired
- **Semantic linters:** Check 13e in `scripts/validate_plugin.sh` generalized (token-coverage rather than row-shape)
- **Tests proposed:** A future Check 13l candidate could grep `skills/cohesively/SKILL.md` §"Output" canonical announcement template against the literal `: skill-1 → skill-2 → skill-3` anti-pattern to mechanically enforce no-chain-rendering. Deferred until wording stabilizes (per `docs/substrate/gotchas/style-guide-rot.md` promotion criteria)
- **Deferred (out of scope this pass):**
  - Verdict-vocabulary tweaks to align labels with gate vocabulary (e.g., implement-cohesively's "Implementation complete" → "Build complete") — small, can land in a follow-up
  - Validator check (Check 13l candidate) for chain-rendering anti-pattern in cohesively/SKILL.md
  - using-cohesive's body prose has unchanged substrate vocabulary; orientation message itself is already decision-shape and not changed

## Files rewritten

- `skills/cohesively/SKILL.md`
  - **Before:** "The user-facing skill set" presented the flagship workflow as five imperatives (`discover → brainstorm → rewrite → validate → implement`) and three off-chain diagnostics; canonical announcement template included a chain suffix (`: skill-1 → skill-2 → skill-3`); per-route outcome sentences referenced methodology framing ("inventory what memory the codebase is missing") and were not aligned with a gate model.
  - **After:** "The three gates (flagship workflow)" presents Decide / Lock / Build as the user-facing model with subskill IDs as agent-internal dispatch keys; "The three diagnostics (standalone)" presents review-codebase, review-diff, audit-substrate as standalone tools; per-route outcome sentences updated to gate-aligned outcomes ("I'll lock the chosen direction into specs and pressure-test the architecture"; "I'll build the locked design and verify the code matches it"); canonical announcement template is now `<one-sentence outcome>.` with no chain rendering; Required behavior #1 and #7 explicit about gate vocabulary; Acceptance criteria add the "no chain rendering" and "gate vocabulary is the user-facing surface" assertions; Red flags include the chain-rendering anti-pattern.
  - **Reason:** The user observed that substrate (and the underlying subskill chain) is agent plumbing — users care about architectural decisions and tradeoffs, not which subskill runs underneath. Three gates is the simplest user-facing model that still makes the architectural shape legible.

- `skills/validate-rewrite/SKILL.md`
  - **Before:** Process Step 5 specified a two-step Approved render (Disposition phrase + four-row Implementation decision matrix). Output format rendered the cohesion-review body in fixed shape with all section headers regardless of content; Implementation route was a four-row markdown table.
  - **After:** Process Step 5 specifies a four-step Approved render: (1) Architectural reflection at the top of the body block, (2) only non-empty review sections per the chat-trailer template's render-only-non-empty rule, (3) Disposition recommendation, (4) Implementation route as default-recommend + (other options) disclosure. Output format reflects the new shape; the four canonical implementation paths remain documented (now in default-recommend shape rather than table rows).
  - **Reason:** The lock→build handoff is the moment the user decides whether the architectural lock has held — the substantive answer ("how does the architecture feel after the lock?") deserves prominent rendering, not burial under seven empty review-section headers. Default-recommend reduces the user's decision load on the modal Approved verdict.

- `skills/implement-cohesively/SKILL.md`
  - **Before:** Output format body block rendered `## Phases` table + `## Delta coverage` line + `## Final substrate review` pointer + `## Branch state`. The Phase 3 final cohesive:review-diff verdict was buried as one of four sections.
  - **After:** Output format body leads with `## Code matches locked design` — surfacing `**Code matches locked design:** ✓` (Implemented verdict) or `**Drift detected:** ✗ <count> places` (Substrate Drift / Phase Drift) directly from the Phase 3 final review verdict, with divergent items inline. Long-form review detail moves to the persisted file. Phases table and Branch state follow.
  - **Reason:** Build-end spec-coverage is the question the user is most interested in (did the code match the locked design?). Surfacing it as the lead — not as one of four equal-weight sections — matches user intent.

- `references/templates/chat-trailer.md`
  - **Before:** Slot rules covered Verdict / Thesis / body block / Persisted record / Next. Variants table specified body blocks per skill. No formal rule about empty section rendering or default-recommend patterns.
  - **After:** Two new normative sections — Render-only-non-empty rule (empty body-block sections collapse out of chat) and Default-recommend rule (multi-row decision matrices lead with one default + alternatives behind a `(other options)` disclosure). Variants table updated for validate-rewrite (Architectural reflection block) and implement-cohesively (Code-matches-locked-design slot). Slot rules cross-reference the two new rules.
  - **Reason:** The render-only-non-empty rule was implicit but unenforced; making it explicit lets every verdict-led skill collapse empty headers without re-deriving the pattern. The default-recommend rule resolves the "user picks among four options" decision-load issue without losing the option set.

- `references/templates/cohesion-review.md`
  - **Before:** Sections rendered in fixed shape regardless of content. `### Next` block specified Disposition + (Approved-only) Implementation route, with the route shape deferred to validate-rewrite's SKILL.md.
  - **After:** New top-of-body `## Architectural reflection` section with render context + persisted-file format (one paragraph + three bullets: easier downstream / harder downstream / load-bearing on memory). Per-section render-iff-non-empty notes added. `### Next` block rewritten to cite the chat-trailer template's default-recommend rule; the route's full alternatives list is deferred to validate-rewrite's SKILL.md.
  - **Reason:** The Architectural reflection is the canonical answer to the user's question "is this design OK to build?" — it lives in the cohesion-review template because the spec-cohesion-reviewer agent already produces the underlying material (locality + future-fit + enforcement findings) that the synthesis draws from.

- `docs/substrate/architecture/skills.md`
  - **Before:** Lead described "one chain (`discover-substrate → brainstorm-design → rewrite-specs → validate-rewrite → implement-cohesively`)" as the user-facing model. Skill set table grouped by Chain / Off-chain / Router / Session-start orientation.
  - **After:** Lead describes "**three gates: Decide → Lock → Build**" with subskill order named explicitly as the agent-internal sequence underneath each gate. Skill set table adds a Gate column showing which gate each subskill runs under (or `_diagnostic_` / `_router_` / `_orientation_` for off-chain skills); the per-skill-section roles updated for `validate-rewrite` (architectural reflection) and `implement-cohesively` (spec-coverage verdict).
  - **Reason:** Contributor doc must reflect the new user-facing surface; without this update, contributors authoring new SKILL.md output blocks would re-derive the retired chain framing.

- `docs/substrate/conventions/audience-separation.md`
  - **Before:** Convention covered chat-trailer vs persisted-file vocabulary distinction. No explicit pin on the gate-vs-chain user-facing surface vocabulary.
  - **After:** New section "Gate vocabulary is the user-facing chat-surface vocabulary" pins the gate vocabulary as the lead in router announcements, chat trailers, `### Next` blocks, and TodoWrite progress; subskill IDs stay agent-internal; the chain-rendering pattern is named as retired; a small table maps surfaces to lead vocabulary.
  - **Reason:** The audience seam was structurally enforced for chat *bodies* via the centralized chat-trailer template. The chain-rendering pattern in router announcements was a separate leak surface; this section pins the gate vocabulary as the structural mitigation.

- `README.md`
  - **Before:** Main commands described the flagship as "five imperatives" with the workflow chain enumerated; Workflows section had separate "Design rewrite" and "Implementation against an approved rewrite" subsections naming subskills.
  - **After:** Main commands present three gates with subskills annotated as "underneath each"; Workflows section rewritten as one "Decide → Lock → Build (the flagship workflow)" subsection that walks through the three gates with what the user gets at each stop point.
  - **Reason:** README is user-facing entry surface; mismatch with the new gate vocabulary would re-introduce the chain framing the rewrite retired.

- `scripts/validate_plugin.sh`
  - **Before:** Check 13e grepped for four exact table-row literals in skills/validate-rewrite/SKILL.md (`| Implement now ... |`, `| Land specs first ... |`, `| Hand off to Superpowers ... |`, `| Schedule for later ... |`).
  - **After:** Check 13e generalized to four-token coverage grep — verifies that all four canonical implementation paths appear in skills/validate-rewrite/SKILL.md regardless of render shape (table or default-recommend disclosure). Comment explains the shape change and the reason for token-coverage rather than row-shape.
  - **Reason:** The default-recommend rule changed the render shape; the substantive coverage requirement (no canonical implementation path silently disappears) is preserved.

## Files added

- `docs/history/delta-ledgers/2026-05-06-decide-lock-build.md` — this file.

## Files removed or deprecated

None. The hard cut-over is in-place rewriting; no skills, conventions, or templates removed.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| 5-imperative chain (user-facing) | 3 gates (Decide / Lock / Build) (user-facing); 5-subskill chain stays agent-internal | Reframed |
| Chain rendering in announcements (`: skill-1 → skill-2 → skill-3`) | No chain rendering; one-sentence outcome only | Retired |
| Implementation decision matrix (4-row table on every Approved verdict) | Default-recommend (`cohesive:implement-cohesively`) + alternatives behind `(other options)` disclosure | Reshaped |
| Buried "Final substrate review" section in implement-cohesively trailer | Top-of-trailer "Code matches locked design" verdict (✓ / ✗ + drift items) | Promoted |
| Validate-rewrite Approved trailer rendering all 7 review sections regardless of content | Render-only-non-empty rule applied; clean Approved trailer is just Architectural reflection + Delta at a glance | Tightened |
| (no concept) | Architectural reflection at lock→build handoff | Added |

## New or updated substrate

### Specs

- `skills/cohesively/SKILL.md` — restructured around gates; chain-rendering retired; per-route outcome sentences updated; Acceptance + Red flags updated.
- `skills/validate-rewrite/SKILL.md` — Process Step 5 + Output format restructured for Approved-branch architectural reflection and default-recommend.
- `skills/implement-cohesively/SKILL.md` — Output format restructured for build-end spec-coverage verdict surfacing.

### Behavior matrices

None changed. `docs/substrate/matrices/router.md` route names preserved for Check 13i parity.

### Named invariants

None added, removed, strengthened, or weakened. `IMPLEMENTATION_PLAN_COVERS_DELTA` and `VERDICT_BEFORE_EVIDENCE` continue to hold; the rewrite preserves their structural enforcement.

### Gotchas

None added or retired. The chain-rendering anti-pattern is named in `skills/cohesively/SKILL.md` Red flags; promotion to a dedicated gotcha doc is deferred until a real regression occurs (per `docs/substrate/gotchas/style-guide-rot.md` promotion criteria).

### Semantic linter specs

- Check 13e in `scripts/validate_plugin.sh` generalized — substantive change, not a new check.
- Check 13l candidate (deferred) — grep `skills/cohesively/SKILL.md` §"Output" against `: skill-1 → skill-2 → skill-3` chain-rendering literal as a structural enforcement of the no-chain-rendering rule. Promote when the wording stabilizes.

### Tests / checks proposed (not yet implemented)

- Check 13l (above).
- A render-time test that synthesizes a sample Approved verdict and verifies the chat trailer collapses empty review-section headers (render-only-non-empty rule). Stays convention-with-template until a real regression motivates the test.

## What this rewrite *did not* do

- **Implementation code:** not changed. The skill bodies, the validator, and the templates govern *render shape* — the runtime dispatch contract (which skill runs, with what prereq state) is preserved. Check 13i continues to pass; route names are stable; the dispatch prompt contract is unchanged.
- **Verdict-vocabulary labels:** not changed. The internal labels (`Approved` / `Issues Found` / `Implemented` / etc.) and their user-facing translations stay the same. A small follow-up could align labels with gate vocabulary (e.g., implement-cohesively's "Implementation complete" → "Build complete") but is deferred.
- **Subskill IDs:** not renamed. `discover-substrate`, `brainstorm-design`, `rewrite-specs`, `validate-rewrite`, `implement-cohesively` keep their identities as agent-internal dispatch keys. The rewrite changes the *user-facing surface*, not the dispatch substrate.
- **Persisted-file shapes:** the persisted file (per skill) keeps the substrate-shape body — the audience seam is preserved. The render-only-non-empty rule applies to chat only; persisted files keep section headers as scaffolding for future passes.

## Remaining ambiguity

- **Verdict-vocabulary alignment with gate vocabulary.** Should `implement-cohesively`'s "Implementation complete" become "Build complete — code matches locked design"? Should `validate-rewrite`'s "Approved — ready to implement" become "Locked — ready to build"? Decision deferred; tracked above.
- **using-cohesive body prose.** The orientation message (the user-facing surface) is already decision-shape; the body prose uses substrate-shape vocabulary deliberately per the audience seam. Whether to also gate-frame the body prose for contributors — making "substrate-first work" / "five triggers" more legible — is open.
- **Future-fit pressure on the gate vocabulary.** "Decide → Lock → Build" parallels "brainstorm → plan → execute" but is not identical; if a future skill emerges that fits between Lock and Build (e.g., "validate the implementation plan before execution"), the gate name would need to be re-thought. The rewrite is committed to three gates as the v0.1 user-facing surface; future pressure may motivate a fourth.

## Repair pass 2

**Pass:** 2
**Source review:** `docs/history/reviews/2026-05-06-decide-lock-build-rewrite-validation.md` (pass 1, Issues Found)
**Closes:** B1, B2, I1, I2, I3
**Classification:** Pure implementation (textual fixes against named findings; one design-layer file edit to close B1's stale claim).

### Repairs applied

- **B1 / B2 — Matrix/rows residue swept across `validate-rewrite/SKILL.md` and `skills.md`.** The Approved-branch implementation route is now described consistently as "default-recommend per the chat-trailer template's §'Default-recommend rule' (one default + alternatives behind a `(other options)` disclosure)" everywhere. Specific edits:
  - `skills/validate-rewrite/SKILL.md` Hard constraint #3 — replaced "the user picks among the rows of the implementation decision matrix" with "the trailer leads with one default move (`cohesive:implement-cohesively`) and surfaces alternatives behind a `(other options)` disclosure per the chat-trailer template's §'Default-recommend rule'".
  - `skills/validate-rewrite/SKILL.md` §"Output format" preamble — replaced "the `### Next` footer carries the **Disposition** phrase + (Approved-only) **Implementation route** matrix" with the same default + disclosure language; cited the chat-trailer template's §"Render-only-non-empty rule" alongside.
  - `skills/validate-rewrite/SKILL.md` §"Conditional implementation route" — replaced "Render the implementation decision matrix iff the verdict is `Approved`" with "Render the implementation route slot iff the verdict is `Approved`"; "Omit the matrix entirely" → "Omit the slot entirely".
  - `skills/validate-rewrite/SKILL.md` §"Bypass acknowledgment" — replaced "When the user picks the third row (`superpowers:writing-plans` directly)" with "When the user picks the **Hand off to Superpowers without delta-coverage discipline** option (one of the alternatives in the `(other options)` disclosure — invokes `superpowers:writing-plans` directly)" — naming the option by its decision-shape phrase rather than its render position.
  - `skills/validate-rewrite/SKILL.md` §"Composition" Followed-by row — replaced "the implementation decision matrix in §'Output format' picks among …" with "the default-recommend implementation route in §'Output format' leads with `cohesive:implement-cohesively` and surfaces the alternatives … behind the `(other options)` disclosure".
  - `docs/substrate/architecture/skills.md` `### validate-rewrite` Owns — replaced "Rendering the per-verdict decision matrix on terminal verdicts" with "Rendering the per-verdict next step on terminal verdicts (Approved → default-recommend implementation route per the chat-trailer template's §'Default-recommend rule'; Design Incoherent → re-brainstorm; max-passes stall → user direction)". Closes the lens-13 design-layer drift.

- **I1 — Architectural reflection prose vs format mismatch in `cohesion-review.md`.** Replaced the "answers three questions concretely:" + four-bullet shape with an aligned shape: one paragraph (How it feels now) + three bullets (Easier / Harder / Load-bearing). Prose now matches the persisted-file format block at lines 22-32.

- **I2 — Phase 3 review persistence shape in `chat-trailer.md`.** Updated the Variants row for `implement-cohesively`: replaced "long-form review detail lives in the persisted `## Final substrate review` section, not chat" with "The Phase-3 final-review pointer renders inline beside the spec-coverage line as a path to the standalone persisted review file (`docs/history/reviews/<YYYY-MM-DD>-<slug>-final-substrate-review.md`); long-form review detail lives in that file, not chat". Aligned with the standalone-file shape in `implement-cohesively/SKILL.md`.

- **I3 — Render-conditional parentheticals extracted from `validate-rewrite/SKILL.md` Output format render template.** Added a new prose subsection §"Render-conditional rules for the body block" preceding the render template; this subsection enumerates the per-section render conditions (Architectural reflection: Approved-only; Locality/Future-fit/Enforcement concerns: only when non-empty AND not Approved; What looked right: persisted-file only; etc.). Stripped all `*(rendered iff non-empty …)*` parentheticals and the HTML comment from inside the ```md fence; the render template now contains only the literal output the model is meant to reproduce. The `## What looked right` section is omitted from the chat render template entirely (persisted-file only per the new prose rules).

### Repair-pass file changes

- `skills/validate-rewrite/SKILL.md` — five edits closing B1 (one), B2 (four), I3 (one).
- `docs/substrate/architecture/skills.md` — one edit closing B1.
- `references/templates/cohesion-review.md` — one edit closing I1.
- `references/templates/chat-trailer.md` — one edit closing I2.
