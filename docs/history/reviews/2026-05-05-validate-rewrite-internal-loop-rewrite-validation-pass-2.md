# Rewrite Validation Review — validate-rewrite-internal-loop + path-prereq directive errors

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** Rewritten specs in `docs/history/delta-ledgers/2026-05-05-validate-rewrite-internal-loop.md`; rewrite is Mixed (design-layer + implementation).

**Verdict:** Issues Found

## Executive judgment

The internal repair loop is structurally well-specified and the path-prereq vs. session-prereq distinction is the right collapse of the recurring `Hard constraint #1` patches. The loop-exit shape (Approved / Design Incoherent / max-passes stall) is named identically across `handoffs.md`, `skills.md`, `validate-rewrite/SKILL.md`, and the soft-prereqs gotcha; the `MAX_REPAIR_PASSES` ceiling is stated consistently. However, `implement-cohesively/SKILL.md` Step 0 contradicts its own Hard constraint #1 (B1) — the same skill says "stop with a directive error" in §"Hard constraints" and "stop and ask" in §"Step 0", which is the exact session-prereq vs. path-prereq confusion the rewrite was supposed to retire. A future contributor reading top-to-bottom would implement whichever appears later. That single line undoes the path-prereq half of the rewrite for one of two skills it covers.

## Delta at a glance

This rewrite is **Mixed**.

**Design-layer changes:**
- `docs/substrate/architecture/handoffs.md` — §"The three transition shapes" gains a fourth shape (internal repair loop); §"The chain" diagram updates the validate-rewrite ↔ rewrite-specs edge from public backward edge to internal loop; §"validate-rewrite ↔ rewrite-specs (Issues Found internal repair loop)" replaces the prior public-backward-edge contract with a loop contract (transition shape, per-pass artifact crossing, three loop exits including max-passes stall, fresh-eyes per pass, failure modes).
- `docs/substrate/architecture/skills.md` — `### validate-rewrite` Purpose, Owns, Does not own, Inputs, Outputs, and Why-this-shape sections updated to reflect the internal loop ownership; new `--max-passes=N` input; per-pass review filename convention; max-passes-stall as a third terminal verdict shape.
- `docs/substrate/conventions/skill-shape.md` — new §"Path prereqs use directive errors, not the canonical question" section under §"Canonical prereq-detection question" introducing the path-prereq vs. session-prereq distinction and the directive-error template.

**Implementation changes:**
- `skills/validate-rewrite/SKILL.md` — Hard constraints #1 and #2 gain "per pass" qualifiers; new Hard constraint #4 (the loop is internal, do not auto-pivot to brainstorm); §"What this skill produces" adds loop semantics and per-pass file naming; Process steps 3–5 rewritten as persist+branch / repair-loop / terminal-render; Acceptance criteria gain max-passes/no-auto-pivot guarantees; Red flags gain pass-contamination and auto-loop-past-ceiling; Composition adds the internal dispatch.
- `skills/rewrite-specs/SKILL.md` Hard constraint #1 — three-input-case enumeration collapses to "explicit dispatch (skip the question) | direct user-named direction | otherwise canonical question." Repair-loop dispatch from `validate-rewrite` named explicitly. Step 1b "Repair-pass mode" body unchanged; only the invocation path changes.
- `skills/implement-cohesively/SKILL.md` Hard constraint #1 — three-input-case enumeration retires entirely. Replaced with directive-error template per the new skill-shape convention. The canonical clarifying question retires for this skill — its prereq is a file path, not session state.
- `docs/substrate/gotchas/soft-prereqs.md` — §"Structured-artifact handoff is not this failure mode" retires; replaced with §"What this gotcha does not cover" pointing at handoffs.md for path-prereq contracts. Planned-test list updated: removes the two structured-handoff scenario tests; adds the implement-cohesively directive-error scenario test.
- `docs/substrate/matrices/router.md` §"Dispatch contract exceptions" — implement-cohesively row updated to clarify directive-error vs. canonical-question (router-level R016 question still applies at route classification).
- `scripts/validate_plugin.sh` — Check 10 split into 10 (discovery-prereq subskills require canonical question) and new 10b (path-prereq subskills require directive-error template plus an upstream `cohesive:` skill name).

## Blocking issues

### B1. `implement-cohesively` Step 0 contradicts Hard constraint #1 (path-prereq vs. session-prereq)

- **Severity:** Blocker
- **Category:** Spec drift / Domain model
- **Why it matters:** Hard constraint #1 (lines 24–38) explicitly forbids the canonical forced-choice question and prescribes a directive-error template, naming `Path prereqs use directive errors, not the canonical question` as canonical. Step 0 (line 58) says "If any required input is missing, **stop and ask. Do not invent inputs.**" An agent reading top-to-bottom executes Step 0 last and falls back to the prior session-prereq behavior — the exact failure mode the rewrite was supposed to close for `implement-cohesively`. Validator Check 10b passes because the directive-error template is present elsewhere in the file; the validator does not detect this kind of two-surface contradiction.
- **Evidence:**
  - `skills/implement-cohesively/SKILL.md:24-38` — Hard constraint #1 prescribes directive errors and "Do not ask the canonical forced-choice question and do not invent paths."
  - `skills/implement-cohesively/SKILL.md:58` — Step 0: "If any required input is missing, stop and ask. Do not invent inputs."
- **Recommended fix:** Replace line 58 with a one-sentence pointer to Hard constraint #1, e.g., "If any required input is missing, halt with the directive error per Hard constraint #1; do not ask the canonical forced-choice question."
- **Substrate artifact to add or update:** spec (`skills/implement-cohesively/SKILL.md` Step 0).

## Important issues

### I1. Validate-rewrite Output format omits two sections present in the canonical agent template

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** The skill renders the agent's report (per the comment "The skill's chat output (the agent's report, surfaced)"), and the agent uses `references/templates/cohesion-review.md` which carries §"Behavior knowable outside implementation?" and §"What looked right." The Output format block in `validate-rewrite/SKILL.md` lines 142–192 omits both. A future skill author copying the SKILL render template will produce a render that drifts from the agent's actual output, and reviewers will lose the calibration ("What looked right") explicitly required by the agent prompt.
- **Evidence:** `skills/validate-rewrite/SKILL.md:142-192` (Output format block) vs. `references/templates/cohesion-review.md:67-99`.
- **Recommended fix:** Add `## Behavior knowable outside implementation?` and `## What looked right` placeholder sections to the Output format render template in `validate-rewrite/SKILL.md`, matching the canonical template's order.
- **Substrate artifact to add or update:** spec.

### I2. handoffs.md "internal repair loop" not reflected in skills.md §"Why these skills, not others"

- **Severity:** Low
- **Category:** Locality
- **Why it matters:** `skills.md` §"Why these skills, not others" justifies why `validate-rewrite` is separate from `rewrite-specs` ("fresh-eyes review is structurally impossible inside the skill that produced the artifact"). With the internal loop, that justification needs a one-sentence addendum: per-pass fresh-eyes still holds because each pass dispatches a fresh `spec-cohesion-reviewer` Task subprocess. Without it, a future reader noticing the loop may conclude the seam was relaxed and propose collapsing the skills.
- **Evidence:** `docs/substrate/architecture/skills.md:38` — section unchanged after rewrite; the loop semantics are recorded only in the per-skill `### validate-rewrite` Owns section.
- **Recommended fix:** Append one sentence to §"Why `validate-rewrite` is separate from `rewrite-specs`": "The internal repair loop preserves this seam — each pass dispatches a fresh reviewer Task subprocess with paths-only input."
- **Substrate artifact to add or update:** spec.

### I3. Router R016 cell description still cites canonical question; reads ambiguously alongside new exception text

- **Severity:** Low
- **Category:** Vague language
- **Why it matters:** `matrices/router.md` cell R016 says "Asks the canonical clarifying question per the clarifying-question convention." The §"Dispatch contract exceptions" paragraph below correctly explains R016 is the router's route-classification question, not a subskill prereq question. But cell R016's bare line will be read first by the next contributor scanning the matrix; the disambiguation is buried later. A one-clause inline qualifier in the cell would make the matrix self-contained.
- **Evidence:** `docs/substrate/matrices/router.md:32` (cell R016 Notes column).
- **Recommended fix:** Append "(route-classification level only; `implement-cohesively` itself uses directive errors per skill-shape.md)" to R016's Notes column.
- **Substrate artifact to add or update:** behavior matrix.

## Substrate gaps

- No regression test pins the contradiction in B1. Validator Check 10b confirms presence of the directive-error template but cannot detect that another part of the same file says "stop and ask." A second lint targeting `^If .* missing, stop and ask` in path-prereq subskills would catch this kind of two-surface drift.

## Locality concerns

- The internal-loop transition shape introduces skill→skill dispatch (a new shape `dispatch-protocol.md` does not cover, as the rewrite explicitly notes). The convention is currently load-bearing inline in `validate-rewrite/SKILL.md` Step 4 substep 2. If a second skill ever needs internal dispatch (e.g., a future `audit-substrate` repair loop), this convention will be re-stated rather than referenced. Defer-only — record as remaining ambiguity in the ledger.

## Future-fit concerns

- None blocking. The `MAX_REPAIR_PASSES` ceiling and the "stall is loop-exit shape, not a fourth verdict" framing are well-cordoned future pressure.

## Enforcement concerns

- B1's contradiction would be caught by either (a) a stronger Check 10b that lints for forbidden phrasings (`stop and ask` in path-prereq subskills), or (b) a manual review pass. The current Check 10b's positive-presence test is necessary but insufficient.

## Behavior knowable outside implementation?

- Yes for the loop semantics, the verdict vocabulary, the max-passes stall shape, and the per-pass artifact naming. The loop exits map cleanly to the disposition rule.
- Partially for `implement-cohesively`'s prereq behavior — B1 means a reader cannot tell from the spec alone whether the skill asks or stops with a directive error.

## Vague language to tighten

- `skills/implement-cohesively/SKILL.md:58` — "stop and ask" (see B1).
- `docs/substrate/matrices/router.md:32` — R016 cell language reads ambiguously without the inline qualifier (see I3).

## Recommended repairs (ranked)

1. Fix B1 — replace `implement-cohesively` Step 0's "stop and ask" with a pointer to Hard constraint #1's directive-error contract.
2. Tighten Check 10b in `validate_plugin.sh` to also forbid "stop and ask" / canonical-question phrasings inside path-prereq subskills, so the B1-class regression is structurally pinned.
3. Add the missing two sections to `validate-rewrite/SKILL.md` Output format render template (I1).
4. Append the loop-preserves-seam sentence to `skills.md` §"Why `validate-rewrite` is separate from `rewrite-specs`" (I2).
5. Tighten R016's Notes column with the route-classification qualifier (I3).

## What looked right

- The loop contract in `handoffs.md` §"validate-rewrite ↔ rewrite-specs (Issues Found internal repair loop)" names all three exits with consistent vocabulary across the four touching files. Lens 14 is satisfied for the Approved gate on the implement-cohesively edge.
- The path-prereq vs. session-prereq distinction in `skill-shape.md` §"Path prereqs use directive errors, not the canonical question" gives a clean criterion. The reasoning paragraph (a/b/c) names the failure mode the canonical question closes and explains why path prereqs don't need it.
- `soft-prereqs.md` §"What this gotcha does not cover" symmetrically covers both `validate-rewrite` and `implement-cohesively` path-prereq cases in its planned tests, mirroring Check 10b.
- The repair-mode commit template in `rewrite-specs/SKILL.md` Step 6 makes per-branch grep auditing of pass sequences possible (`git log --grep "pass-"`), realizing the auditing surface `handoffs.md` promises.

---

**Disposition:** Repair → re-validate
