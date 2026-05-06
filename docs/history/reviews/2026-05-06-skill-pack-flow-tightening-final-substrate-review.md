# Change Cohesion Review — skill-pack-flow-tightening (Phase 3 final substrate review)

**Reviewer:** `cohesive:review-diff` (dispatching `substrate-alignment-reviewer` + `structure-reviewer` in parallel)
**Date:** 2026-05-06
**Subject:** branch `design/skill-pack-flow-tightening` vs `main` — 19 files, 1000 insertions / 43 deletions; substrate-only rewrite. This is the final substrate check before merge per `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md` §"Phase 3".

**Verdict:** Pass with notes

## Main concern

None blocking. The branch ships clean — validator green across all 13 checks; both reviewers cross-check the same surfaces and surface only Low-severity observations that confirm documented deferrals or affirm structural choices.

## Findings

| Severity | Area | Finding | Suggested substrate |
|---|---|---|---|
| Low | Spec drift | `skill-tool-dispatch.md` §"Concrete dispatch sites in v0.1" lists 3 Skill-tool sites; the comparison-table cell in §"Skill-tool vs Task-tool dispatch" names 4 Task-tool sites including `validate-rewrite` Step 2 per-pass `spec-cohesion-reviewer`. A reader scanning §"Concrete dispatch sites" alone misses the Task-tool side of the same loop. | One-line cross-reference under §"Concrete dispatch sites" to the comparison-table's Task-tool sites. Not blocking. |
| Low | Implicit invariant | `HANDOFF_VOCABULARY_PARITY` remains reviewer-judged across the dispatch-prompt-contract mirror. Check 13i asserts route-name set equality only; prereq-state strings drift the moment one side gets edited without the other. | Already documented as deferred Check 13j candidate in ledger §"Remaining ambiguity"; promote on next release cycle per `style-guide-rot.md` criteria (one release cycle of grep stability + caught regression + worked transcript). |
| Low | Test guarantee gap | `using-cohesive` Hard Constraints #1/#4 (re-orientation rules) have no detection mechanism — session-state judgment with no persisted artifact, no validator check. | Already substrate-noted in `discovery-vs-superpowers.md` §"Notes for future contributors"; promotion path requires harness session-state introspection (out of scope for static-grep validator). On first regression, consider `session-state-constraints.md` gotcha. |
| Low | Concept | Three-altitude split (`using-cohesive` orient → `cohesively` route → chain workflow) pays a real ceremony tax for repeat users; load-bearing for first-time users. Hard Constraint #4 mitigates within-session; cross-session repetition has no guard. | Watch dogfood for ceremony complaints. If they materialize, the right fix is a session-state signal (transcript-self-suppress), not structural collapse. Gotcha candidate `chain-announcement-stacking` already deferred per ledger. |

## Affirmative observations (the structure reviewer's pressure-tests held)

- **Five-transition-shape typology earns peer status.** "Session-start orientation" does not collapse into "router dispatch": the latter carries an artifact-passing prereq contract, the former carries no artifact and no verdict; the source/target asymmetry (using-cohesive → cohesively, where cohesively is the router itself) makes a "router dispatch" framing structurally incoherent.
- **Skill-tool vs Task-tool as two docs is right-shape.** The contracts differ on the load-bearing axis (fresh-eyes property: present vs absent). One doc with a "depending on tool" branch would force conflation of the surfaces the two-doc split exists to prevent.
- **Bootstrap-status three-label scheme earns its complexity.** `inherited` and `newly-authored` predict *different* lens-13 drift shapes (retroactive-claim-mismatch vs forward-rewrite-mismatch); collapsing to `unvalidated` would erase information.
- **`using-cohesive` exemption is correctly registered as one-off, not category.** N=1; promoting to a category would be premature centralization. Ledger flags the watch surface for promotion when N=2 lands.
- **Branch repair-commit pattern audits cleanly** via `git log --grep "pass-"` over the 9 branch commits.

## Behavior/spec alignment

- All four prior-pass closures verified in cross-surface form: `audit-substrate` verdict drift fixed across all four surfaces (handoffs.md, skills.md at-a-glance, skills.md per-skill Outputs, audit-substrate/SKILL.md); Check 13i mechanics match annotation claim post-pass-3 closure; lens 13/14 citations now correct in skills.md §"Bootstrap status"; Skill-tool dispatch §"Output (persisted)" / §"Output (chat trailer)" split is internally coherent.
- Delta-ledger preamble↔body parity holds: 12 rewritten / 3 added matches §"Files rewritten" enumeration; four §"Repair pass N" sections cite reviews that exist on branch.

## Invariant preservation

- All four named invariants (`PLUGIN_ROOT_PATHS`, `VERDICT_BEFORE_EVIDENCE`, `IMPLEMENTATION_PLAN_COVERS_DELTA`, `SKILL_DESIGN_DOC_SECTION`) — validator passes clean.
- The new `Check 13i` (`DISPATCH_CONTRACT_MIRROR` candidate) shipped and is exercised by validator runs; the annotation surfaces (cohesively/SKILL.md, matrices/router.md) match the implementation.

## Highest-leverage fix

None blocking. The two highest-leverage forward investments are (a) promote `HANDOFF_VOCABULARY_PARITY` to Check 13j once grep wording stabilizes and a regression is caught (deferred per ledger), and (b) capture dogfood evidence for or against the three-altitude ceremony tax to inform whether `chain-announcement-stacking` gotcha promotes.

### Recommended next Cohesive skill

- **Pass with notes:** `superpowers:writing-plans` is the canonical "advance" recommendation, but for this rewrite — substrate-only, the rewrite IS the implementation — the `cohesive:implement-cohesively` Phase 3 mapping is the relevant route. Pass / Pass with notes → **Implemented** verdict from implement-cohesively → hand off to `superpowers:finishing-a-development-branch`.
