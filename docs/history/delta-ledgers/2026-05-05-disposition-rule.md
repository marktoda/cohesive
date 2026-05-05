# Design Delta Ledger — Disposition rule for validation-review findings

**Date:** 2026-05-05
**Worktree / branch:** `.worktrees/cohesive-disposition-rule` on `design/disposition-rule`
**Approved direction:** Add a per-severity disposition rule to the cohesion rubric so `validate-rewrite` renders a single recommendation derived from `(verdict, highest-severity-present)` instead of an improvised options menu.

This ledger records a substrate change to close the **Three options** failure mode observed across recent `validate-rewrite` outputs (most recently the cohesion-review-cleanup pass-3 review). Reviewer agents were emitting a 3-row "repair / substrate-note / pause" menu in place of a recommendation, violating `references/output-voice.md` rule #5 ("Recommend exactly one next move") and pushing the disposition decision back onto the user. The substrate gap was that `Approved`-with-Important-findings had no canonical recommendation surface — the agent improvised one each time, with rotating jargon labels.

## Delta at a glance

- **Files:** 6 rewritten, 0 added, 0 removed/deprecated (file counts unchanged across all repair passes; only intra-file content tightened)
- **Conceptual changes:** disposition rule promoted to canonical home of validation-review-finding recommendation; "Three options" menu pattern explicitly forbidden; verdict-floor mapping pinned (`Approved` ⇔ highest-severity ≤ Medium; `Issues Found` ⇔ highest-severity ≥ High); `Approved + Low` row made deterministic with substrate-note as user override; severity vocabulary aligned (`Blocking` → `Blocker` in rubric, matching reviewer-agent template); cohesion-review template section headers (`Blocking issues` / `Important issues`) glossed against severity vocabulary
- **Named invariants:** none added (disposition rule lives as convention in cohesion-rubric.md; promotion criteria deferred — see Remaining ambiguity)
- **Behavior matrices:** disposition table embedded in `references/cohesion-rubric.md` §"Disposition rule for validation-review findings" (5-row mapping of `(verdict, highest-severity)` → `(recommendation, re-validate?)`, total over the verdict-floor mapping); not a standalone matrix file
- **Gotchas:** none added (a future "Three options improvisation" gotcha is substrate-noted for follow-up if the pattern recurs)
- **Semantic linters:** none (a future grep that flags option-menu shapes in validation-review chat output is substrate-noted)
- **Tests proposed:** none
- **Deferred (out of scope this pass):** promotion of disposition rule to named invariant; validator check pinning the literal `Disposition:` line in `validate-rewrite` rendered output; gotcha note for the "Three options" failure mode; first-class override-residue ledger section (re-evaluation trigger: >3 silent overrides per release cycle)

## Files rewritten

- `references/cohesion-rubric.md`
  - **Before:** Severity vocabulary used `Blocking` as the noun-state, inconsistent with reviewer-agent template's `Blocker`. No disposition rule for validation-review findings — recommendation surface for `Approved`-with-non-Blocker-findings was undefined; the agent improvised options menus.
  - **After:** Severity vocabulary uses `Blocker` consistently. New §"Disposition rule for validation-review findings" maps `(verdict, highest-severity-present)` to a single recommendation in a 6-row table. The section names itself as canonical home; skill, agent, and ledger template all cite it. Includes "Why this is a rule, not a menu" rationale explicitly retiring the options-menu shape, "Substrate-note disposition" pointing to ledger §"Remaining ambiguity", and "User override" carving out the user's right to override the rule's recommendation as a deliberate move (not a derivation from a menu).
  - **Reason:** Single canonical home for the disposition decision; the dispatching skill and agent cite rather than restate, eliminating the multi-surface drift class that pre-`design/cohesion-review-cleanup` §"Delta at a glance" exhibited.

- `references/templates/design-delta-ledger.md`
  - **Before:** §"Remaining ambiguity" was a single-purpose section for author-time ambiguities the rewriter knew were open. Deferred validation-review findings (the "substrate-note" disposition) had no documented home; they evaporated into chat transcripts.
  - **After:** §"Remaining ambiguity" is the substrate residue for two kinds of unclosed work: (1) author-time ambiguities, and (2) deferred non-Blocker findings from validation reviews per the disposition rule. Each deferred entry carries a stable ID (e.g., `pass-1 I2`), a one-line crux, deferral rationale, and a citation to the validation review that surfaced it. `validate-rewrite` reads this section on subsequent passes and treats previously-deferred findings as either confirmed-deferral or escalation if drift has appeared.
  - **Reason:** Deferred findings need a substrate residue, not a chat-only existence. The ledger is the one durable surface every subsequent reviewer reads.

- `skills/validate-rewrite/SKILL.md`
  - **Before:** Hard constraint #3 said "Approved unlocks the implementation route — but the user picks between [matrix rows]." Process step 4 narrated the four implementation matrix options as the entire next-step recommendation for `Approved`. Output format's `### Recommended next Cohesive skill` block rendered the full implementation matrix unconditionally for `Approved`, with no acknowledgment of non-blocking findings. Red flags omitted any rule against rendering options menus.
  - **After:** Hard constraint #3 cites the disposition rule as the gate between `Approved` and the implementation matrix. Process step 4 describes the two-step render: (a) one-phrase Disposition derived from rubric, (b) implementation matrix iff disposition is merge-ready. Output format's `### Recommended next Cohesive skill` block renders **Disposition:** first, then the **Implementation route** matrix conditionally; the conditional-render guidance lives outside the Output format code block (per the render-template-leak gotcha). New Red flag explicitly forbids "Three options" menus in place of the disposition recommendation. Composition section reframes "Followed by" as the disposition rule's branches.
  - **Reason:** The skill is the dispatch + render surface; it must enforce the disposition rule rather than encode it locally. All recommendation logic now lives in cohesion-rubric.md; the skill cites.

- `agents/spec-cohesion-reviewer.md`
  - **Before:** "What you must not do" omitted any rule against options menus. The agent could (and did) improvise 3-row "repair / substrate-note / pause" blocks in chat output without violating any documented constraint.
  - **After:** Added a "What you must not do" entry: "Render an options menu (e.g., 'Three options: repair pass / substrate-note / persist-and-pause') in place of the disposition recommendation. The disposition rule in `references/cohesion-rubric.md` §'Disposition rule for validation-review findings' determines the recommendation; you commit to one phrase and do not offer alternatives." Cites the output-voice rule #5 violation explicitly.
  - **Reason:** The agent's "What you must not do" list is the closest-to-generation surface for forbidden output shapes; the rule must live there, not just in the skill body.

- `references/templates/cohesion-review.md`
  - **Before:** §"Recommended repairs (ranked)" was the only forward-looking section; there was no canonical render slot for the disposition recommendation. The "What looked right" section followed directly.
  - **After:** Added §"Recommended next Cohesive skill" between "Recommended repairs (ranked)" and "What looked right". The new section renders **Disposition:** (one phrase from the rubric table) and conditionally **Implementation route:** (the matrix, when verdict + disposition allow). The section cites the cohesion-rubric disposition rule rather than restate.
  - **Reason:** The template is the canonical render structure the agent reproduces; the disposition recommendation must be a first-class section there.

- `docs/substrate/designs/skill-conventions.md`
  - **Before:** §"When sections may differ" entry for `validate-rewrite` described the canonical `### Recommended next Cohesive skill` heading as carrying "the verdict-branch decision matrix" — the matrix-only shape from before this rewrite.
  - **After:** Updated entry describes the post-rewrite shape: under the heading, a one-phrase Disposition (derived from cohesion-rubric §"Disposition rule") followed conditionally by the Implementation route matrix.
  - **Reason:** Convention drift surface; the canonical-heading deviation entry must reflect the current render shape.

## Files added

none

## Files removed or deprecated

none

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| `Approved` verdict unlocks implementation directly | `Approved` verdict gated by disposition rule; merge-ready dispositions unlock implementation, repair-required dispositions route back to `rewrite-specs` | Tightened |
| "Three options" menu (repair / substrate-note / pause) emerging in agent-rendered chat output | Single Disposition phrase derived from `(verdict, highest-severity-present)` per rubric table | Replaced; old shape forbidden as Red flag |
| Severity `Blocking` (in rubric) vs. `Blocker` (in reviewer-agent template) | Severity `Blocker` (canonical, both surfaces) | Renamed in rubric to align |
| §"Remaining ambiguity" in delta ledger = author-time ambiguities only | §"Remaining ambiguity" = author-time ambiguities **plus** deferred non-Blocker findings from validation reviews | Tightened |

## New or updated substrate

### Specs
- `references/cohesion-rubric.md` — adds §"Disposition rule for validation-review findings" as canonical home; aligns severity vocabulary
- `docs/substrate/designs/skill-conventions.md` — updates `validate-rewrite` deviation entry to describe new Disposition + Implementation-route shape under the canonical `### Recommended next Cohesive skill` heading

### Behavior matrices
- The 5-row disposition table in `references/cohesion-rubric.md` §"Disposition rule for validation-review findings" is matrix-shaped (rows: severity-presence; columns: recommendation, re-validate?) but lives embedded in the rubric rather than as a standalone matrix file. A future promotion to standalone matrix is queueable if the table grows.

### Named invariants
- none added; promotion of the disposition rule to a named invariant is deferred (see Remaining ambiguity)

### Gotchas
- none added; "Three options improvisation" is substrate-noted for promotion to a gotcha if the pattern recurs after this substrate change lands

### Semantic linter specs
- none; a grep for option-menu shapes ("Three options:", "Repair pass.*Substrate-note.*Persist") in `docs/history/reviews/` is substrate-noted as a follow-up if the Red flag proves insufficient

### Tests / checks proposed (not yet implemented)
- A validator check that the literal `**Disposition:**` line is present in the `validate-rewrite` Output format render template would pin the new shape grep-style. Substrate-noted; not added this pass to keep the rewrite minimal.

## What this rewrite *did not* do

- Implementation code: not changed (no executable code in this substrate)
- Tests: not changed
- CI: not changed (no validator updates beyond what the existing `Recommended next Cohesive skill` grep already catches)
- Verdict vocabulary lexical set: not changed; verdicts remain `{Approved, Issues Found, Design Incoherent}`. **Verdict semantics did change** (per repair pass 1, B2): the verdict-floor mapping pins `Approved` to highest-severity ≤ Medium and `Issues Found` to highest-severity ≥ High. The disposition rule is gated by, not orthogonal to, this mapping. Pre-rewrite semantics ("Approved with non-blocking findings is acceptable") is replaced by the verdict-floor pin; the rubric §"Verdict → severity-floor mapping (validate-rewrite)" is the canonical statement of the new semantics.
- Implementation decision matrix rows: not changed; the four rows (`implement-cohesively` / land-specs-first / `superpowers:writing-plans` / schedule) are unchanged.

## Remaining ambiguity

This section carries author-time ambiguities and deferred validation-review findings per the contract in `references/templates/design-delta-ledger.md` §"Remaining ambiguity".

- **Promotion of the disposition rule to a named invariant:** the rule is first-iteration; the `style-guide-rot` promotion criteria (wording stability across two release cycles, caught regression, captured worked transcript) are not yet met. The rule lives as convention in the rubric for now. Re-evaluate after one release cycle of dogfooding.
- **Validator pin on the literal `Disposition:` line:** would catch agent regressions byte-for-byte. Not added this pass to keep the rewrite minimal; substrate-noted for follow-up if a regression appears.
- **Gotcha note for the "Three options" failure mode:** would document the symptom + tempting wrong fix + correct pattern in `docs/substrate/gotchas/`. Not added this pass; the Red flag in the skill body and agent body is the load-bearing defense for now. Promote to gotcha if the pattern recurs after this substrate lands.
- **Behavior of the override case:** the rubric §"User override" carries an explicit re-evaluation trigger (per repair pass 1, I2): if more than 3 `validate-rewrite` passes in a single release cycle reveal the same finding repeatedly because it was silently overridden, promote a first-class override-residue surface (a §"Overrides applied" section in the ledger) in the next pass. Until the trigger fires, overrides do not require general ledger annotation; substrate-note overrides land in the existing §"Remaining ambiguity" residue.

## Repair pass 1 (post pass-1 validation)

Pass-1 validation review at `docs/history/reviews/2026-05-05-disposition-rule-rewrite-validation.md` returned `Issues Found` with 3 Blockers + 2 Important. All 5 findings closed in this repair pass; no findings substrate-noted.

- **B1 closed** — `Approved + Low` row in the rubric is now deterministic: `Close inline (≤2 lines per finding)` with `Re-validate? No`. Substrate-noting reframed as a user override per new rubric §"Substrate-note as user override". `validate-rewrite` SKILL.md disposition examples (formerly listed both Close-inline and Substrate-note as legitimate phrases) collapsed to the five canonical phrases derived deterministically from the 5-row table. Agent renders the rule's default; the user's substrate-note override is a post-render move that lands in the ledger §"Remaining ambiguity" via the existing residue contract.
- **B2 closed** — `Approved + High` row removed from the disposition table. Verdict-floor mapping pinned in new rubric §"Verdict → severity-floor mapping (validate-rewrite)": `Approved` ⇔ highest-severity ≤ Medium; `Issues Found` ⇔ highest-severity ≥ High; `Design Incoherent` orthogonal. The previous "Approved unlocks subject to disposition" framing in `validate-rewrite` Hard constraint #3 reframed as "Approved unlocks the implementation route" without disposition gating, since the verdict floor now guarantees Approved is merge-ready. Ledger §"What this rewrite did not do" amended to acknowledge verdict semantics changed (the lexical set is unchanged but the meaning is now gated on severity).
- **B3 closed** — `Issues Found` row in the disposition table now covers `High or Blocker` (single row). The verdict-floor mapping makes `Issues Found + High` legitimate; the agent's verdict definitions at `agents/spec-cohesion-reviewer.md:88-91` rewritten to cite the verdict-floor mapping and forbid contract-violating verdict choices (Approved with High, Issues Found without High/Blocker).
- **I1 closed** — `references/templates/cohesion-review.md` §"Blocking issues" and §"Important issues" headers carry severity-class glosses citing the rubric's severity vocabulary. The historic word "Blocking" is preserved as the section label; the **Severity** field within each finding carries the canonical Blocker/High/Medium/Low vocabulary. Section-name vs. severity-name relationship is now stated explicitly.
- **I2 closed** — Rubric §"User override" carries an explicit re-evaluation trigger (>3 silent overrides per release cycle → promote first-class override-residue surface in next pass). Ledger §"Remaining ambiguity" override entry amended to mirror. Substrate-note overrides continue to land in the existing §"Remaining ambiguity" residue per B1's reframing.

## Repair pass 2 (post pass-2 validation)

Pass-2 validation review at `docs/history/reviews/2026-05-05-disposition-rule-rewrite-validation-pass-2.md` returned `Issues Found` with 1 Blocker + 1 Medium. Both new findings (introduced by repair pass 1's incomplete propagation); both closed in this repair pass.

- **pass-2 B1 closed** — `references/templates/cohesion-review.md:91` Disposition phrase list reconciled with `skills/validate-rewrite/SKILL.md:153`. The template now lists the same 5 canonical phrases and explicitly notes that substrate-noting is a user override per rubric §"Substrate-note as user override", not a phrase the agent renders. The Implementation route conditional simplified from "iff verdict is Approved and disposition does not require re-validation" to "iff verdict is Approved" — the verdict-floor mapping makes the re-validation gate redundant for Approved.
- **pass-2 I1 closed** — Ledger §"New or updated substrate" → §"Behavior matrices" line corrected from "6-row" to "5-row". Preamble was already correct; body now matches.

## Repair pass 3 (post pass-3 validation)

Pass-3 validation review at `docs/history/reviews/2026-05-05-disposition-rule-rewrite-validation-pass-3.md` returned `Issues Found` with 1 High Blocker (no Important findings). The finding was the same shape class as pass-2 B1 (citing-surface drift from incomplete repair-pass propagation) — caught one substrate layer deeper at a fifth citing surface. Closed in this repair pass.

- **pass-3 B1 closed** — `docs/substrate/designs/skill-conventions.md:204` deviation entry updated: implementation-route conditional simplified from "iff verdict is `Approved` and disposition does not require re-validation" to "iff verdict is `Approved`", with inline citation of the verdict-floor mapping rationale. The deviation entry now matches the four other citing surfaces (rubric, SKILL.md, agent, cohesion-review template). All five citing surfaces of the disposition rule's render shape now agree.

The "incomplete propagation across citing surfaces" pattern has now appeared and been caught in three consecutive passes (pass 1 set up the surfaces; pass 2 caught template drift; pass 3 caught skill-conventions drift). The pass-3 §"Substrate gaps" entry substrate-notes this as a candidate for a future semantic linter ("disposition rule citation surfaces" grep), parallel to the substrate-noted "Three options" grep already deferred. Not landed this pass; promotion criteria need one more cycle of dogfooding.

## Repair pass 4 (post pass-4 validation)

Pass-4 validation review at `docs/history/reviews/2026-05-05-disposition-rule-rewrite-validation-pass-4.md` returned **Approved** with 1 Medium (I1) + 1 Low (I2). Per the disposition rule, `Approved + Medium` → `Close in same worktree → merge`; the repair is non-scope-changing (column addition + ledger preamble copy-edit), so re-validation is not required per the Approved+Medium row's `Re-validate?` conditional ("Yes if the repair adds a new file or named invariant; otherwise no"). Both findings closed in this repair pass.

- **pass-4 I1 closed** — Added a fifth column `Canonical Disposition phrase` to the rubric table at `references/cohesion-rubric.md` §"Disposition rule for validation-review findings", carrying the literal phrase string per row. The rubric is now the single source of truth for both the recommendation logic AND the canonical phrase strings. Updated `skills/validate-rewrite/SKILL.md:153` and `references/templates/cohesion-review.md:91` to cite the column rather than restate the five phrase literals — closing the multi-surface drift surface the rewrite was designed to eliminate. Updated rubric §"Citations" paragraph to add `skill-conventions.md` deviation entry as a fourth citing surface.
- **pass-4 I2 closed** — Ledger preamble file-count parenthetical updated from "across repair pass 1" to "across all repair passes". One-line copy-edit.

## Ready for fresh-eyes review?

**Yes** — substrate change is internally complete; validator passes (`bash scripts/validate_plugin.sh` returns 0 errors, 0 warnings); all five citing surfaces of the disposition rule agree, and the rubric now holds the literal canonical phrase strings (single source of truth across the entire rule). Pass-4 verdict was Approved with non-scope-changing repairs; per the rule, no further validation is required. Branch is ready to merge.

## How to read this ledger

1. **Approved direction** (top): the destination — disposition rule replaces options-menu improvisation.
2. **Delta at a glance** (above): 8-line summary; preamble that `validate-rewrite` renders verbatim into the validation review at decision time.
3. **Conceptual changes** (table): what's *different* in the substrate, in 4 rows.
4. **Files rewritten** (per-file Before/After/Reason): ground truth for each rewrite.
5. **Remaining ambiguity** (substrate-note surface): deferrals the reviewer should weigh.
