# Rewrite Validation Review — skill-pack-flow-tightening (pass 2)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** 12 rewritten + 3 added specs per `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-05-skill-pack-flow-tightening.md` (post repair pass 2)

**Verdict:** Issues Found

## Executive judgment

The rewrite is design-coherent and most surfaces line up cleanly. A future contributor can read `skills.md`, `handoffs.md`, `using-cohesive/SKILL.md`, and `skill-tool-dispatch.md` and understand the new shape without backchannel context. Two findings block merge: the Check 13i annotation overpromises (claims prereq-state-string parity the validator does not actually enforce), and the existing `skill-shape.md` §"Process when adding a new skill" was not reconciled with the new 5-step sequence in `skills.md` §"Adding a new skill" — two normative how-to-add-a-skill sequences now coexist.

## Delta at a glance

> This rewrite is **Mixed**. Design-layer changes: new skill `using-cohesive` (per-skill section in architecture/skills.md, handoff section in handoffs.md, exemption in skill-shape.md, row in skill-section-presence.md); restructured "Adding a new skill" sequence (3-step → 5-step) in architecture/skills.md. Implementation changes: spec drift fixes, new convention doc, validator extension, README/ARCHITECTURE updates, mirror-annotation citations.
>
> - **Files:** 12 rewritten, 3 added, 0 removed/deprecated
> - **Conceptual changes:** session-start orientation as a 5th transition shape; Skill-tool dispatch as a distinct contract; validator-array updates as Step 5 of "Adding a new skill"
> - **Named invariants:** none added/strengthened/weakened (`DISPATCH_CONTRACT_MIRROR`, `HANDOFF_VOCABULARY_PARITY` remain candidates; promotion deferred)
> - **Behavior matrices:** `skill-section-presence` (rows for `implement-cohesively` + `using-cohesive`; intro skill count 8→10; new exemption); `router` (mirror-annotation citation updated to name Check 13i)
> - **Gotchas:** `discovery-vs-superpowers` (added pattern item 3 naming `using-cohesive`); `no-implementation-handoff` (relabeled three lint checks as shipped Checks 13e/13f/13g)
> - **Semantic linters:** `validate_plugin.sh` Check 13i (`DISPATCH_CONTRACT_MIRROR` mirror grep) — added
> - **Tests proposed:** none
> - **Deferred:** review findings 6–11, 13–16; named-invariant promotion of `DISPATCH_CONTRACT_MIRROR` / `HANDOFF_VOCABULARY_PARITY`

## Blocking issues

### B1. Check 13i annotation overpromises prereq-state-string parity

- **Severity:** High
- **Category:** Enforcement
- **Why it matters:** Both `skills/cohesively/SKILL.md` §"Dispatch prompt contract" and `docs/substrate/matrices/router.md` §"Dispatch prompt contract (per route)" tell the reader: "Check 13i greps both surfaces and asserts route-name set equality **plus prereq-state-string parity** to catch the drift mechanically." The grep at `scripts/validate_plugin.sh` only extracts the first backticked token per row (the route name) and asserts set equality of those names. Prereq-state strings are not extracted, normalized, or compared. A contributor renaming a prereq-state string ("Validate-rewrite returned **Approved**…") on one surface but not the other passes the validator and ships exactly the soft-prereqs drift the annotation claims is closed. Worse, this is precisely the parity-check class the candidate invariant `HANDOFF_VOCABULARY_PARITY` would govern — the rewrite ratifies the parity claim in prose while leaving it unenforced.
- **Evidence:** `scripts/validate_plugin.sh` `extract_routes_from_section` function (emits route names only); `skills/cohesively/SKILL.md` §"Dispatch prompt contract" annotation; `docs/substrate/matrices/router.md` §"Dispatch prompt contract (per route)" annotation.
- **Recommended fix:** Either (a) extend `extract_routes_from_section` (or add a sibling extractor) to also emit prereq-state strings per route and compare them across surfaces, or (b) tighten both annotations to state only what the grep enforces ("asserts route-name set equality"), and move prereq-state-string parity into a deferred Check 13j with an explicit `(deferred)` tag, recording the deferral in `## Remaining ambiguity` of the ledger.
- **Substrate artifact to add or update:** semantic linter (extend Check 13i) OR spec (tighten annotation on both surfaces and ledger).

### B2. Two competing "how to add a skill" sequences in normative docs

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** `docs/substrate/architecture/skills.md` §"Adding a new skill" now defines a 5-step design-first sequence. `docs/substrate/conventions/skill-shape.md` §"Process when adding a new skill" still defines a *different* sequence (read closest skill → copy structure → ARCHITECTURE.md → README.md → run validator → run review-diff) that was untouched in this rewrite. Neither cites the other. A contributor entering through `skill-shape.md` (the canonical SKILL.md authoring doc) follows a sequence that omits the design-layer steps entirely and never updates `skills.md`/`handoffs.md`/`router.md`/`skill-section-presence.md` — exactly the failure mode the rewrite's review finding 5 was meant to close. The closure is incomplete.
- **Evidence:** `docs/substrate/architecture/skills.md` §"Adding a new skill" (new 5-step sequence); `docs/substrate/conventions/skill-shape.md` §"Process when adding a new skill" (untouched legacy sequence).
- **Recommended fix:** Replace the body of `skill-shape.md` §"Process when adding a new skill" with a one-paragraph stub that defers to `architecture/skills.md` §"Adding a new skill" as canonical, and reduces to "After steps 1–3 of that sequence land, this doc governs the SKILL.md body shape (step 4)."
- **Substrate artifact to add or update:** spec (skill-shape.md).

## Important issues

### I1. Bootstrap-status label `inherited` overloaded for the new skill

- **Severity:** Medium
- **Category:** Domain model
- **Why it matters:** The bootstrap-status table's prose definition says: "Every section in this doc started life as a *claim* about what the SKILL.md said, not a *spec* the SKILL.md was authored against. Sections earn validated status when a `cohesive:rewrite-specs` pass…" — i.e., `inherited` means "authored retroactively against an existing SKILL.md." For `using-cohesive` both surfaces (the design-layer section *and* the SKILL.md body) are new in this pass; the design layer was *not* inherited from a pre-existing SKILL.md. The row is labeled `inherited` anyway with a clarifying note. The label now denotes two different states (retroactive vs newly-authored-but-unvalidated), which weakens the table's signal — and `skills.md` §"Adding a new skill" Step 1 instructs future skill authors to mark their new section `inherited` too, baking the overload into the convention.
- **Evidence:** `skills.md` §"Bootstrap status" table + definition; `skills.md` §"Bootstrap status" using-cohesive row; `skills.md` §"Adding a new skill" Step 1 instruction.
- **Recommended fix:** Add a third status (`newly-authored` or `unvalidated`) and relabel the `using-cohesive` row to it; update `skills.md` Step 1 to instruct authors to use the new status. Or rename `inherited` to a label that covers both states (e.g., `unvalidated`) and explain in the prose definition that bootstrap-drift skepticism applies to both retroactive sections and forward-but-unvalidated ones.
- **Substrate artifact to add or update:** spec (skills.md bootstrap-status table + Step 1 of Adding-a-new-skill).

### I2. `using-cohesive` Hard Constraint #1 ("Orient at most once per session per request shape") has no detection mechanism

- **Severity:** Low
- **Category:** Enforcement
- **Why it matters:** The constraint is reasonable and reads cleanly, but there's no test, validator check, or runtime guardrail named — "the user is already inside a Cohesive workflow" is a session-state judgment with no canonical signal. The handoff contract for the seam acknowledges no persisted state.
- **Evidence:** `skills/using-cohesive/SKILL.md` Required behavior #1, #4; `docs/substrate/architecture/handoffs.md` §"using-cohesive → cohesively" Persistence: None.
- **Recommended fix:** Either name the detection rule explicitly ("`cohesively` already announced a route in this session" + how that's known) or accept the constraint as reviewer-judged in v0.1 and call it out in the gotcha file's "Notes for future contributors" so the reviewer knows what to look for.
- **Substrate artifact to add or update:** gotcha (discovery-vs-superpowers.md "Notes for future contributors").

## Substrate gaps

- The two-sequence drift in B2 suggests a Substrate artifact gap: there is no canonical "How to add a skill" surface that both docs cite. Adding such a surface (or designating `architecture/skills.md` §"Adding a new skill" as canonical with `skill-shape.md` deferring) is the structural fix.

## Locality concerns

The session-start orientation seam is well-localized: `using-cohesive` SKILL.md, handoff section, gotcha pattern item 3, and skill-section-presence row all reference each other and stop at substrate-narrowing rules. No premature centralization.

## Future-fit concerns

The frontmatter trigger calibration for `using-cohesive` is acknowledged as empirical in the ledger §"Remaining ambiguity"; this is the right place for it. The ledger's deferred items are clearly non-normative and gated on real evidence.

## Enforcement concerns

- See B1 (Check 13i overpromise).
- The new skill-tool-dispatch.md four-constraint contract is enforceable in principle but not yet enforced. Convention-only is acceptable for v0.1; flag if a future Skill-tool dispatch site lands without the four constraints stated inline.

## Behavior knowable outside implementation?

Yes. `skills.md`, `handoffs.md`, `skill-tool-dispatch.md`, `using-cohesive/SKILL.md`, and `discovery-vs-superpowers.md` together let a future contributor know what `using-cohesive` does, when it fires, what it hands off to, and why. The five-shape transition vocabulary is named in the blockquote, the heading, and the per-handoff section.

## Vague language to tighten

None at normative-section severity. No "should/probably/TBD/we will" in normative sections.

## Recommended repairs (ranked)

1. Resolve B1: tighten the Check 13i annotation to match the validator's actual grep, or extend the validator to enforce prereq-state-string parity. Same pass.
2. Resolve B2: stub `skill-shape.md` §"Process when adding a new skill" to defer to `skills.md` §"Adding a new skill". Same pass.
3. Resolve I1: distinguish retroactive `inherited` from newly-authored-unvalidated in the bootstrap-status table, and update Step 1 of "Adding a new skill" to use the new label.
4. Optionally close I2 by naming the detection rule for "already inside a Cohesive workflow" or marking the constraint reviewer-judged.

## What looked right

- The five-shape transition model in `handoffs.md` blockquote, heading, and per-handoff section is consistently rendered; the `audit-substrate` verdict drift fix (`Gaps Found` → `Substrate gaps`) is clean across surfaces.
- `skill-tool-dispatch.md` cleanly distinguishes its contract from `dispatch-protocol.md`; the comparison table and the "two-dispatch shape when both are needed" worked example are load-bearing for future composition seams.
- The `using-cohesive` exemption in `skill-shape.md` §"When sections may differ" is internally consistent with the matrix row in `skill-section-presence.md` and with the SKILL.md body sections.
- The preamble↔body parity (12 rewritten / 3 added / 0 removed) is exact post-repair.
- Lens 13 (design-implementation agreement) for `using-cohesive`: design layer Owns/Inputs/Outputs match SKILL.md verbatim or by clear reference; the bootstrap-skepticism rule was the right lens to apply and the rewrite holds up under it (modulo I1's labeling overload).

### Recommended next Cohesive skill

**Disposition:** Repair → re-validate
