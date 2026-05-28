# Validate-rewrite convergence rule (L3)

**Status:** Brainstorm — design accepted, not yet implemented
**Date:** 2026-05-28
**Author:** Mark + Claude (brainstorm)
**Predecessors:**
- L1 — replace delta ledger with git diff (`docs/internal/2026-05-27-replace-delta-ledger-with-git-diff.md`)
- L2 — router off-ramp for additive changes (`docs/internal/2026-05-27-router-off-ramp-for-additive-changes.md`)

## Motivation

Early-user feedback flagged three structural failure modes in the cohesive flow. L1 and L2 addressed the load-bearing structural causes (parallel-representation artifacts; routing on lexical signals). L3 closes the remaining symptom: **validate-rewrite repair loops that don't converge.** Concrete pattern from the feedback (PR #544 and others): five passes, each surfacing fresh findings, including findings that prior passes had closed, with no rule constraining what qualifies as a blocker by pass N.

The brainstorm doc for L1 sketched four sub-changes for L3 (pass budget, escalating bar, forwarded closed findings, marginal-value heuristic). Through the L3 brainstorm we narrowed to two:

- **Drop the marginal-value heuristic.** The existing verdict-floor mapping (Approved requires ≤ Medium; Issues Found requires ≥ High) already encodes "when to stop" via severity. A K/2 ratio adds machinery without adding signal.
- **Drop the escalating per-pass bar.** The reviewer's mis-grading of prose nits as High is a calibration problem the existing rubric already addresses ("Don't mark every finding Blocker. If you do, prioritization is failing"). A per-pass tier structure is over-engineering — once the existing severity vocab is applied correctly, the pass-N reviewer naturally returns Approved on Medium/Low-only findings.

What's left:

1. **Pass budget default reduces from 5 to 2.** The hard ceiling is the convergence rule.
2. **Forwarded closed findings.** Pass-N reviewer reads prior passes' closed findings as anti-amnesia context.

## Lens

L1's principle: *artifact > description-of-artifact* (kill parallel structures). L2's principle: *route-shape matches change-shape* (one orchestrator with a mode flag > parallel orchestrators). L3's principle: **the existing rubric already does most of the work**. The fix is to use the rubric correctly with a smaller iteration budget, not to add new convergence machinery on top.

Two specific applications of this principle in L3:

- The verdict-floor mapping was *already* the convergence rule — a pass that surfaces only Medium/Low findings returns Approved, automatically. The escalating bar would have been redundant with this.
- Fresh-eyes ≠ amnesia. The pass-N reviewer should know what pass-(N-1) closed, with the discipline that "fresh eyes" preserves objectivity (the reviewer can still escalate) without forcing the loop to re-do work.

## Architecture

### Two small changes to `validate-rewrite`

```
        Before L3                                After L3
        ─────────                                ────────
        MAX_REPAIR_PASSES = 5                    MAX_REPAIR_PASSES = 2
                                                 (configurable via --max-passes)

        Pass N dispatch prompt:                  Pass N dispatch prompt:
        - Approved direction                     - Approved direction
        - Branch / spec-diff path                - Branch / spec-diff path
        - Rewritten specs to review              - Rewritten specs to review
        - Substrate discovery (optional)         - Substrate discovery (optional)
                                                 + Closed findings from prior passes
                                                   (only on pass 2+; do-not-re-raise context)
```

The loop's terminal logic, verdict vocabulary, and stall-banner mechanism are unchanged. The two sub-changes compose: a tight budget plus anti-amnesia context together close the symptom — the loop can't run more than 2 passes, and within that budget the second pass doesn't waste effort re-raising what the first pass closed.

## Per-surface changes

### §1 — `skills/validate-rewrite/SKILL.md`

**Hard constraint #4** currently says:

> When the reviewer returns `Issues Found`, the skill dispatches `cohesive:rewrite-specs` in repair mode via the Skill tool, then re-dispatches `spec-cohesion-reviewer` for the next pass — up to `MAX_REPAIR_PASSES` (default 5).

Update to:

> When the reviewer returns `Issues Found`, the skill dispatches `cohesive:rewrite-specs` in repair mode via the Skill tool, then re-dispatches `spec-cohesion-reviewer` for the next pass — up to `MAX_REPAIR_PASSES` (default 2; configurable via `--max-passes=N`).

**Step 4 (Repair loop)** gains a new substep before "Re-dispatch spec-cohesion-reviewer." Insert:

> **2.5. Build the closed-findings list.** Parse the just-landed repair commits' `Closes:` trailers (the `rewrite-specs` repair-mode convention from L1). For each cited finding ID, look up the title from the corresponding prior pass's review file (`docs/cohesive/reviews/<...>-rewrite-validation[-pass-N].md`). Build an accumulated list across all prior passes (pass-2 list = pass-1's closed findings; pass-3 list = pass-1's + pass-2's; etc.).

**Step 4 substep 3 (Re-dispatch)** adds the closed-findings list to the dispatch prompt. The prompt shape becomes:

```
You are reviewing a spec rewrite. Your inputs are file paths only — do not
assume any prior conversation context exists.

**Approved direction:** <one or two sentences>

**Branch:** design/<slug>

**Spec diff:** .cohesive/tmp/<slug>-spec-diff.patch

**Rewritten specs to review:**
- <path>
- ...

**New specs added:**
- <path>
- ...

**Substrate discovery (for context):** <path or "n/a">

## Closed findings from prior passes — do not re-raise unless the prior closure is wrong

The following findings were raised in earlier passes and closed by repair commits.
Do NOT re-raise these as new findings. If you believe a prior closure was
incorrect (the repair did not actually address the underlying issue, or it
introduced a new problem), you may raise a NEW finding citing the prior ID and
explaining in the "Why it matters" field why the prior closure was wrong.
Re-raising without that justification is a contract violation.

### From pass 1 (<review path>):
- **B1.** <title> — closed by repair-pass-1 commit <SHA>
- **I2.** <title> — closed by repair-pass-1 commit <SHA>
...

Read all of the above. Return a Rewrite Validation Review using the format in
${CLAUDE_PLUGIN_ROOT}/references/templates/cohesion-review.md.

Verdicts: Approved | Issues Found | Design Incoherent.

Do not read any file not listed above unless the spec diff explicitly
references it. Do not run code, tests, or git commands. Your job is judgment
of the rewritten specs.
```

The `## Closed findings from prior passes` section only renders on pass 2+. On pass 1, the dispatch prompt has no prior passes to forward; the section is omitted entirely.

**Acceptance criteria** gains:

- The pass-N reviewer dispatch (N ≥ 2) includes a `## Closed findings from prior passes` section listing the accumulated closed findings with their titles and closing commit SHAs.

### §2 — `agents/spec-cohesion-reviewer.md`

**Inputs you will receive** gains a new line:

> - The **closed-findings list** (only present from pass 2+) — IDs and titles of findings from prior passes that were closed by repair commits. The dispatching skill assembles this from prior review files and repair commit messages.

**What you must not do** gains a new bullet:

> - Re-raise a closed finding from a prior pass as a new finding without (a) citing the prior pass's ID and (b) explaining in "Why it matters" why the prior closure was wrong. Fresh-eyes is about objectivity, not amnesia — the prior pass's closures are visible to you specifically so you can avoid surfacing them again. If you believe a closure was wrong, the new finding's severity should match what you would have raised it as on a fresh review.

### §3 — `scripts/validate_plugin.sh`

Add a small check verifying the pass budget default is 2:

```bash
# 13p. Pass budget default in validate-rewrite. L3 capped the default at 2;
# regressing to 5 (or higher than 3) is a contract violation against the
# convergence rule.
errors_before=$errors
if grep -qE 'default[[:space:]]+(is|=|to)?[[:space:]]*2\b|MAX_REPAIR_PASSES.*=.*2\b' skills/validate-rewrite/SKILL.md \
   || grep -qF 'MAX_REPAIR_PASSES = 2' skills/validate-rewrite/SKILL.md \
   || grep -qF 'default 2' skills/validate-rewrite/SKILL.md; then
  ok "Pass budget default 2 present in validate-rewrite (L3 convergence rule)"
else
  fail "skills/validate-rewrite/SKILL.md missing the L3 pass-budget default of 2. Required: text indicating MAX_REPAIR_PASSES default is 2."
fi
```

Header comment list updated.

## What stays unchanged

- Verdict vocabulary (`Approved` / `Issues Found` / `Design Incoherent`).
- Verdict-floor mapping in `cohesion-rubric.md` (Approved requires ≤ Medium; Issues Found requires ≥ High; Design Incoherent is orthogonal to severity).
- Stall-banner mechanism on max-passes-without-convergence — still fires when budget hits without Approved.
- Fresh-eyes property of every dispatch — the agent runs in a Task subprocess with no inherited conversation context. The closed-findings list is a *file-based* input the reviewer reads as data, exactly like the spec-diff path; it doesn't compromise the structural fresh-eyes fence.
- The repair-pass commit message convention (`Closes: B1, I2`) — already established in L1.

## Migration shape

Clean, small. One implementation pass touches:

- `skills/validate-rewrite/SKILL.md` — Hard constraint #4 wording; Step 4 gains substep 2.5; Step 4 substep 3 dispatch prompt shape; Acceptance criteria line.
- `agents/spec-cohesion-reviewer.md` — Inputs section gains a bullet; "What you must not do" gains a bullet.
- `scripts/validate_plugin.sh` — new check 13p; header comment update.

No new agent. No new template. No deletions. Verdict-vocabulary unchanged.

## Risks and open questions

1. **The closed-findings list might encourage cargo-cult deferral.** A reviewer who reads "do not re-raise" might over-correct and fail to flag genuine regressions of closed findings. Mitigation: the "What you must not do" bullet explicitly says re-raising IS allowed when the prior closure was wrong, with an explanation requirement. The contract is about adding rigor to re-raises, not preventing them.

2. **Budget = 2 might be too tight for genuinely complex rewrites.** A rewrite that touches three subsystems might need pass 3 to clear all the cross-cutting concerns. Mitigation: the `--max-passes=N` override is preserved (existing flag from pre-L3). The default is the "modal case" budget; the override handles edge cases.

3. **Closed-findings list assembly depends on the `Closes:` trailer convention.** If a repair commit omits the trailer (or names IDs incorrectly), the list will be incomplete. Mitigation: `scripts/validate_plugin.sh` already has check 11 for various commit-message convention enforcement; we could add a check that repair-pass `rewrite-specs` commits on `design/*` branches carry the `Closes:` trailer. Deferred until we see real drift.

## Self-review

- **Placeholder scan:** No TBD / TODO / vague requirements.
- **Internal consistency:** §1-§3 align — the dispatch-prompt change in §1 matches the input-contract change in §2; the validator check in §3 enforces the §1 default. No contradictions.
- **Scope:** L3 only. L1 and L2 are predecessors. No new sub-changes (the marginal-value heuristic and escalating bar were considered and dropped during brainstorm, with reasons recorded under "Motivation").
- **Ambiguity:** The closed-findings list assembly logic (parse `Closes:` trailer, look up titles from prior review files) is implementation-detail-level; flagged in §1 substep 2.5 for the implementer. No design-level ambiguity remains.

## Next

After this brainstorm is accepted, the implementation sequence follows the L1/L2 precedent:

1. Open a worktree on branch `design/validate-rewrite-convergence-rule`.
2. Update `skills/validate-rewrite/SKILL.md` (Hard constraint #4, Step 4, Acceptance criteria).
3. Update `agents/spec-cohesion-reviewer.md` (Inputs, What you must not do).
4. Update `scripts/validate_plugin.sh` (new check 13p; header comment).
5. Run validator; iterate.
6. Commit on branch and merge to main with `--no-ff`.

L3 is the last of the three sub-redesigns from the original feedback. After this lands, the cohesive flow has: artifact-shaped substrate (L1), route-shape-matches-change-shape routing (L2), and convergence-bounded validation (L3).
