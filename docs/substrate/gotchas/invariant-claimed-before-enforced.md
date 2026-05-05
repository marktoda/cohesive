# Gotcha: invariant claimed before enforced

## Symptom

A named invariant graduates to invariant status (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` §promotion or by structural-simplicity-on-day-one), but its `## Enforcement` section reserves a validator-check ordinal that hasn't yet been implemented in `scripts/validate_plugin.sh`. Cross-citing docs (ARCHITECTURE.md, AGENTS.md, README.md, the canonical-pin-list in `PLUGIN_ROOT_PATHS.md`) state the invariant is mechanically enforced. A reader of any of those surfaces concludes the structural fence exists; a reader of `scripts/validate_plugin.sh` finds no check at the cited ordinal. Between graduation and check-implementation, the invariant is *claimed-as-enforced* but only documentation-enforced.

## What goes wrong

A future contributor relies on the structural fence claim. They:
- Add a skill that violates the invariant. The local validator run passes (the check doesn't exist). CI passes. The violation lands in main.
- Repair an unrelated finding. Their repair pass introduces a second violation of the unenforced invariant. Same outcome: validator passes, drift lands.
- Debate whether to graduate a different rule to invariant status. They cite the existing one as precedent for "graduate first, implement check later" — extending the gap pattern instead of closing it.

The substrate-vs-implementation collapse `cohesive:audit-substrate` is meant to detect happens here in reverse: the substrate (invariant doc) claims more than the implementation (validator script) provides, and reviewers reading either side alone don't see the gap. `cohesive:review-codebase` Phase 2 (spec-prior gate) catches this only if a reviewer happens to grep the validator for the cited ordinal.

The gap closed once the check landed (commit `6cdae42` in the architecture-refactor pass closed it for `SKILL_DESIGN_DOC_SECTION` between commits `a80e7f1` and `dbe441e`), but during the gap the invariant produces no behavior change — every claim is honored by reviewer judgment, not structure.

## Tempting wrong fix

Cite the reserved ordinal in the invariant's §"Enforcement" section *as if it ran*: `scripts/validate_plugin.sh runs Check 15` (when in fact Check 15 has not yet been added). This is wrong because:

- A future contributor reading the invariant doc cold cannot tell whether the check exists. The doc claims it does; the script disagrees. Substrate disagrees with implementation — the original collapse, in miniature.
- The validator script's pass-line for the invariant (`[ OK ] <INVARIANT_NAME>: ...`) does not appear in CI output, but the doc's claim implies it should. Anyone watching CI outputs for the new invariant looks for an OK line that never appears.
- Lens 13 in `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md` (design-implementation agreement) doesn't cover validator-check existence; the gap is reviewer-judged at best, undetected at worst.

## Correct pattern

When graduating a rule to invariant on day one with deferred check implementation:

1. **Mark §"Enforcement" with a "Reserved (not yet running)" status flag.** The first paragraph reads, e.g., `Reserved ordinal: Check N. Implementation lands during <named milestone>; until that commit, the invariant is asserted by structural-fence claim plus reviewer judgment.` Don't claim present-tense enforcement in the same doc.
2. **Reserve the ordinal in the canonical-pin-list** (`${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` §"Convention pins enforced alongside this invariant") with the same status flag. Cross-cite the gap so AGENTS.md, ARCHITECTURE.md, README.md, and the invariant doc itself agree on what's running versus reserved.
3. **Land the bash check in the same atomic commit when feasible.** When deferral is unavoidable (e.g., the check needs a new skill to author the surface it greps, or it depends on a substrate file authored in the same pass), the deferral milestone is a named phase in the implementation pass — not an open-ended "future".
4. **On check-landing, rewrite §"Enforcement" to present-tense in the same commit** that adds the bash check. Add a History row noting the gap closed (date + commit hash). Update the canonical-pin-list to drop the Reserved flag.
5. **`spec-cohesion-reviewer` lens 13** (design-implementation agreement) catches the present-tense vs reserved-ordinal mismatch when the invariant doc is part of the rewrite scope; in particular, an invariant doc that claims `Check N runs` is checked against `scripts/validate_plugin.sh` for an actual `# N.` comment and matching `ok` line.

## Tests / checks that preserve this

- `cohesive:review-codebase` Phase 2 (spec-prior gate) reads the invariant docs and the validator script side-by-side. A graduated invariant whose §"Enforcement" claims present-tense check existence without a matching ordinal in the script is a Blocking Issue under the substrate-alignment-reviewer lens.
- `cohesive:validate-rewrite` lens 13 (design-implementation agreement) catches design-implementation disagreement broadly, including present-tense vs reserved-ordinal mismatches when an invariant doc is part of the rewrite scope: an §"Enforcement" section that claims `Check N` enforces the invariant must agree with `scripts/validate_plugin.sh` actually containing `Check N`. The lens does not run a dedicated ordinal-grep; it surfaces the disagreement as a Purpose/Owns content-alignment finding when the reviewer reads both surfaces side-by-side.
- The canonical-pin-list in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` uses an explicit Reserved-vs-Running status column when entries are mid-graduation; a Reserved entry without a deadline or named milestone is a Medium finding under reviewer judgment.

## Notes for future contributors

The pattern this gotcha closes appeared during the 2026-05-05 architecture refactor: `SKILL_DESIGN_DOC_SECTION` graduated on day one with Check 15 reserved but not yet in the validator. Between commits `a80e7f1` (rewrite landed; invariant graduated) and `6cdae42` (Check 15 implemented; gap closed), the invariant was claim-without-structure. The agent-readiness reviewer caught this during `cohesive:review-diff` Phase 3 of the implementation pass.

A graduate-on-day-one move is valid when the regex is mechanical and the failure mode binary — `SKILL_DESIGN_DOC_SECTION` qualifies. The gotcha is not "don't graduate on day one" but "don't claim enforcement that hasn't shipped." If the gap is unavoidable for a release cycle, the §"Enforcement" section says so explicitly until the check lands.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md` — the invariant whose graduation gap motivated this gotcha; §"History" notes the closure commit.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` §"Convention pins enforced alongside this invariant" — the canonical-pin-list where Reserved-vs-Running status surfaces.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` §promotion — the criteria gating ordinary graduation (which `SKILL_DESIGN_DOC_SECTION` bypassed via structural-simplicity-on-day-one).
- `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md` lens 13 — the reviewer-side fence that catches present-tense-vs-reserved mismatches.
