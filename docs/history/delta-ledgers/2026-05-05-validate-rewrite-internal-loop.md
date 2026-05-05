# Design delta — validate-rewrite internal repair loop + path-prereq directive errors

**Date:** 2026-05-05
**Slug:** validate-rewrite-internal-loop
**Branch:** design/validate-rewrite-internal-loop
**Source:** Direct maintainer rewrite (no preceding `brainstorm-design` artifact; the discussion that drove this change is the conversation log under `docs/history/transcripts/` if persisted, otherwise the chat that led to the "send it" instruction).
**Supersedes:** Patches `5f9ceb0` (rewrite-specs structured-handoff enumeration) and `91dce94` (implement-cohesively structured-handoff enumeration). Both were local fixes that the simpler shape generalizes; not reverted, just superseded.

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

## Per-file changes

| File | Change kind | Closes |
|---|---|---|
| `docs/substrate/architecture/handoffs.md` | Design | — |
| `docs/substrate/architecture/skills.md` | Design | — |
| `docs/substrate/conventions/skill-shape.md` | Design | — |
| `docs/substrate/gotchas/soft-prereqs.md` | Implementation (narrows scope; retires §"Structured-artifact handoff") | Supersedes the structured-handoff enumeration patches |
| `docs/substrate/matrices/router.md` | Implementation (one bullet) | — |
| `skills/validate-rewrite/SKILL.md` | Implementation (loop + Hard constraint #4) | — |
| `skills/rewrite-specs/SKILL.md` | Implementation (Hard constraint #1 collapse) | Supersedes 5f9ceb0 |
| `skills/implement-cohesively/SKILL.md` | Implementation (Hard constraint #1 collapse to directive errors) | Supersedes 91dce94 |
| `scripts/validate_plugin.sh` | Implementation (split Check 10) | — |

## Named invariants impact

No new invariants. The four existing named invariants are unchanged in content:

- `PLUGIN_ROOT_PATHS` — unchanged. New paths cited still use `${CLAUDE_PLUGIN_ROOT}/`.
- `VERDICT_BEFORE_EVIDENCE` — unchanged. The validate-rewrite Output format block still leads with `**Verdict:**`.
- `IMPLEMENTATION_PLAN_COVERS_DELTA` — unchanged.
- `SKILL_DESIGN_DOC_SECTION` — unchanged. All nine skills keep their `### <name>` sections.

## Behavior matrices impact

- `matrices/router.md` — minor (one bullet under §"Dispatch contract exceptions").
- `matrices/artifact-placement.md` — unchanged. Per-pass review file naming (`-pass-N` suffix) is consistent with the existing `reviews/` cell behavior.
- `matrices/phase-derivation.md` — unchanged.
- `matrices/skill-section-presence.md` — unchanged.
- `matrices/reviewer-output-shape.md` — unchanged.

## Tests / checks impact

- `validate_plugin.sh` Check 10 split into 10 + 10b (see Per-file changes). Both pass on the rewrite branch.
- Future planned scenario tests in `gotchas/soft-prereqs.md` updated.

## Why this rewrite

Two pressures, addressed together because they share substrate.

**Pressure 1: the auto-typing complaint.** The user runs `validate-rewrite` → reads the verdict → runs `rewrite-specs` → runs `validate-rewrite` again, looped manually until convergence (recent commits show 4-pass repair sequences shipped this way). Automating the Issues Found → repair → re-validate cycle removes ceremony without changing the workflow shape.

**Pressure 2: the recurring-patch problem in Hard constraint #1.** Both `5f9ceb0` and `91dce94` added a "structured-input enumeration" to skill bodies because the prior shape (canonical question only) didn't recognize legitimate upstream artifacts. The enumeration approach is O(N×M) — every new upstream shape requires N downstream patches. The cleaner shape is to distinguish path prereqs (directive error) from session-discovery prereqs (canonical question), since the failure mode the canonical question closes is specifically session-memory introspection.

The two pressures interact: making `validate-rewrite`'s Issues Found loop internal (Pressure 1) eliminates one of the "structured handoff" cases that drove Pressure 2. The remaining structured-handoff case (validate-rewrite Approved → implement-cohesively) collapses naturally under the path-prereq treatment — the prereq is a file, the failure mode is a missing file, the response is a directive error.

## Acid tests

1. **Auto-typing complaint resolved.** User runs `/cohesive:validate-rewrite` once; loop drives Issues Found internally until verdict converges (Approved), exits to design (Design Incoherent), or stalls at `MAX_REPAIR_PASSES`.
2. **Hard constraint #1 collapse.** `implement-cohesively` and `rewrite-specs` Hard constraint #1 no longer enumerate structured-input cases. Validator Check 10 + 10b enforce the new convention.
3. **Substrate-discovery question survives.** Five discovery-prereq subskills still ask the canonical question when invoked directly without dispatch context. Validator Check 10 confirms.
4. **Soft-prereqs gotcha narrows.** §"Structured-artifact handoff is not this failure mode" is gone; §"What this gotcha does not cover" points at `architecture/handoffs.md` for path-prereq contracts.

## Open follow-ups (not in scope)

- A future `cohesive:status` skill for resume hints in mature worktrees. Deferred.
- Default chat-only persistence for off-chain reviews (`review-codebase`, `review-diff`, `audit-substrate`). Separate scope.
- Detection of "same finding ID across N consecutive passes" for sharper stall-warning. Convention works without it; v0.1 ships with the simple count ceiling.
