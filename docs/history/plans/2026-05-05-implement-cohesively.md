# implement-cohesively Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Register `implement-cohesively` and `delta-coverage-reviewer` with `scripts/validate_plugin.sh` and add three new substrate-pin checks the design delta ledger named, so v0.1 ships with the implementation phase loop's substrate fully under CI enforcement.

**Architecture:** Extend the five existing per-skill check arrays (`expected_skills`, `prereq_subskills`, `persisting_skills`, `verdict_led_skills`, `voice_citation_skills`) to include `implement-cohesively`. Add three new grep-based checks: (a) `validate-rewrite` Approved footer carries the four-option decision matrix; (b) `implement-cohesively` SKILL.md cites the phase-derivation matrix and the `IMPLEMENTATION_PLAN_COVERS_DELTA` invariant; (c) `validate-rewrite` SKILL.md contains the literal bypass-acknowledgment string. Run `cohesive:review-diff` against the branch as the final substrate check before recommending branch finishing.

**Tech Stack:** Bash + awk + grep (same as the existing validator).

**Branch:** `design/implement-cohesively` (worktree at `.claude/worktrees/design+implement-cohesively`). All work continues on this branch.

**Source of truth:** `docs/history/delta-ledgers/2026-05-04-implement-cohesively.md` is the design delta this implementation pass realizes. The substrate-shaped artifacts (SKILLs, agent, matrices, gotchas, invariant) are already on the branch from the rewrite passes; this implementation pass adds CI enforcement for them.

---

## Task 1: Register `implement-cohesively` in `validate_plugin.sh` per-skill arrays

**Files:**
- Modify: `scripts/validate_plugin.sh:129-138` (`expected_skills`)
- Modify: `scripts/validate_plugin.sh:201-207` (`prereq_subskills`)
- Modify: `scripts/validate_plugin.sh:237-245` (`persisting_skills`)
- Modify: `scripts/validate_plugin.sh:259-264` (`verdict_led_skills`)
- Modify: `scripts/validate_plugin.sh:295-303` (`voice_citation_skills`)

The five arrays gate per-skill checks. `implement-cohesively`'s SKILL.md already complies with all five rules (verdict-led with `Implemented / Phase Drift / Substrate Drift / Aborted`; carries the canonical prereq-question stub, the voice citation, and the `### Recommended next Cohesive skill` footer). Adding it to the arrays brings the existing checks to bear.

- [ ] **Step 1.1: Baseline — confirm validator is currently green**

```bash
bash scripts/validate_plugin.sh
```

Expected: `[ OK ] Validation passed (0 warnings)` and `v0.1 skill set complete (8/8 present: ...)`. The current 8 skills do not yet include `implement-cohesively`.

- [ ] **Step 1.2: Edit `expected_skills` to add `implement-cohesively`**

In `scripts/validate_plugin.sh`, change:

```bash
expected_skills=(
  cohesively
  discover-substrate
  brainstorm-design
  rewrite-specs
  validate-rewrite
  review-codebase
  review-diff
  audit-substrate
)
```

to:

```bash
expected_skills=(
  cohesively
  discover-substrate
  brainstorm-design
  rewrite-specs
  validate-rewrite
  implement-cohesively
  review-codebase
  review-diff
  audit-substrate
)
```

Order matters for the chain summary in the OK message: `discover → brainstorm → rewrite → validate → implement` then the three off-chain diagnostics.

- [ ] **Step 1.3: Edit `prereq_subskills` to add `implement-cohesively`**

Change:

```bash
prereq_subskills=(
  brainstorm-design
  rewrite-specs
  review-codebase
  review-diff
  audit-substrate
)
```

to:

```bash
prereq_subskills=(
  brainstorm-design
  rewrite-specs
  implement-cohesively
  review-codebase
  review-diff
  audit-substrate
)
```

The check's grep pattern is `^[[:space:]]*> "I see we're about to run $s\.` which matches `implement-cohesively`'s Hard constraint #1 line `> "I see we're about to run implement-cohesively. Has validate-rewrite returned **Approved**...`. The prereq is workflow-shaped (Approved verdict) rather than discovery-shaped, but the canonical-question grep is structural (looks for the opening blockquote + skill name) — see the dispatch-contract exception documented in `docs/substrate/matrices/router.md` §"Dispatch contract exceptions".

- [ ] **Step 1.4: Edit `persisting_skills` to add `implement-cohesively`**

Change:

```bash
persisting_skills=(
  discover-substrate
  brainstorm-design
  rewrite-specs
  validate-rewrite
  review-codebase
  review-diff
  audit-substrate
)
```

to:

```bash
persisting_skills=(
  discover-substrate
  brainstorm-design
  rewrite-specs
  validate-rewrite
  implement-cohesively
  review-codebase
  review-diff
  audit-substrate
)
```

`implement-cohesively`'s Output format ends with `### Recommended next Cohesive skill` plus per-verdict recommendations.

- [ ] **Step 1.5: Edit `verdict_led_skills` to add `implement-cohesively`**

Change:

```bash
verdict_led_skills=(
  review-codebase
  review-diff
  validate-rewrite
  audit-substrate
)
```

to:

```bash
verdict_led_skills=(
  review-codebase
  review-diff
  validate-rewrite
  audit-substrate
  implement-cohesively
)
```

`implement-cohesively`'s Output format leads with `**Verdict:** Implemented / Phase Drift / Substrate Drift / Aborted` within the first three non-blank lines after `# Implementation Complete — <topic>`.

- [ ] **Step 1.6: Edit `voice_citation_skills` to add `implement-cohesively`**

Change:

```bash
voice_citation_skills=(
  discover-substrate
  brainstorm-design
  rewrite-specs
  validate-rewrite
  review-codebase
  review-diff
  audit-substrate
)
```

to:

```bash
voice_citation_skills=(
  discover-substrate
  brainstorm-design
  rewrite-specs
  validate-rewrite
  implement-cohesively
  review-codebase
  review-diff
  audit-substrate
)
```

The voice citation is already present in `implement-cohesively`'s Output format block (line 113).

- [ ] **Step 1.7: Run validator and verify all six checks pass for the new skill**

```bash
bash scripts/validate_plugin.sh
```

Expected (lines paraphrased; counts increment by 1):

```
[ OK ] v0.1 skill set complete (9/9 present: cohesively discover-substrate brainstorm-design rewrite-specs validate-rewrite implement-cohesively review-codebase review-diff audit-substrate)
[ OK ] all 9 skill descriptions carry a substrate-vocabulary token
[ OK ] all 6 prereq-bearing subskills have the canonical prereq-detection question
[ OK ] all 8 persisting skills have the 'Recommended next Cohesive skill' footer
[ OK ] VERDICT_BEFORE_EVIDENCE: all 5 verdict-led skills lead Output format with **Verdict:**
[ OK ] all 8 skill Output format blocks carry the voice-citation pin
[ OK ] Validation passed (0 warnings)
```

If any check fails, fix the underlying SKILL body issue rather than reverting the array; the array entry pins the rule.

- [ ] **Step 1.8: Commit**

```bash
git add scripts/validate_plugin.sh
git commit -m "implement: register implement-cohesively in validator per-skill arrays

Adds implement-cohesively to expected_skills, prereq_subskills,
persisting_skills, verdict_led_skills, voice_citation_skills.
Six existing checks now apply to the new skill; all pass on current
substrate without further SKILL edits.

Delta entries: skills/implement-cohesively/SKILL.md (Files added);
implement-cohesively listed in 'Tests / checks proposed' under
validate_plugin.sh updates (delta ledger §'Tests / checks proposed').
"
```

---

## Task 2: New validator check — `validate-rewrite` Approved footer carries the decision matrix

**Files:**
- Modify: `scripts/validate_plugin.sh` (add new check after the existing check 13c)

The decision matrix is the structural fix for the `no-implementation-handoff` gotcha. Without the table, the user has no rendered choice between implement-cohesively, land-specs-first, hand-off-to-Superpowers, and schedule-for-later. Pin its presence with a grep.

- [ ] **Step 2.1: Add the check**

After line 350 (end of check 13c) and before line 352 (check 14), insert:

```bash
# 13d. Decision-matrix presence in validate-rewrite Approved footer.
# Per docs/substrate/gotchas/no-implementation-handoff.md and the validate-rewrite
# Output format. The Approved verdict footer must render the four-row decision
# matrix; without it, the user has no canonical choice between implementation
# paths and Cohesive falls back to freeform code-writing.
errors_before=$errors
if grep -qF '| Implement now with delta-coverage discipline (default) | `cohesive:implement-cohesively` |' skills/validate-rewrite/SKILL.md \
   && grep -qF '| Land specs first; implement separately later |' skills/validate-rewrite/SKILL.md \
   && grep -qF '| Hand off to Superpowers without delta-coverage discipline | `superpowers:writing-plans` |' skills/validate-rewrite/SKILL.md \
   && grep -qF '| Schedule for later | (no immediate action) |' skills/validate-rewrite/SKILL.md; then
  ok "validate-rewrite Approved footer carries the four-row decision matrix"
else
  fail "skills/validate-rewrite/SKILL.md missing one or more rows of the implementation decision matrix (per docs/substrate/gotchas/no-implementation-handoff.md). All four canonical rows must be present: implement-now, land-specs-first, hand-off-to-Superpowers, schedule-for-later."
fi
```

- [ ] **Step 2.2: Run validator; expect new check passes**

```bash
bash scripts/validate_plugin.sh 2>&1 | grep -E "(decision matrix|FAIL)"
```

Expected: `[ OK ] validate-rewrite Approved footer carries the four-row decision matrix`. No FAIL lines.

- [ ] **Step 2.3: Verify the check would FAIL on regression (sanity)**

Temporarily modify a copy of the SKILL to exercise the failure path, then revert:

```bash
cp skills/validate-rewrite/SKILL.md /tmp/validate-rewrite.bak
sed -i 's|| Schedule for later | (no immediate action) || REMOVED |' skills/validate-rewrite/SKILL.md
bash scripts/validate_plugin.sh 2>&1 | grep -E "decision matrix"
# Expected: [FAIL] line about missing one or more rows
mv /tmp/validate-rewrite.bak skills/validate-rewrite/SKILL.md
bash scripts/validate_plugin.sh 2>&1 | grep -E "decision matrix"
# Expected: [ OK ] line again
```

If FAIL did not fire after the sed, the grep pattern is too loose; tighten it before committing.

- [ ] **Step 2.4: Commit**

```bash
git add scripts/validate_plugin.sh
git commit -m "implement: validator check 13d — decision matrix presence in validate-rewrite

Greps for all four canonical rows of the Approved-verdict decision matrix
(implement-cohesively / land-specs-first / Superpowers-bypass / schedule).
Closes the deferred lint flagged in docs/substrate/gotchas/no-implementation-handoff.md
\"Tests / checks that preserve this\" bullet 2.

Delta entries: 'Tests / checks proposed' validate_plugin.sh check —
validate-rewrite Approved footer carries the decision matrix.
"
```

---

## Task 3: New validator check — `implement-cohesively` cites the phase-derivation matrix and the invariant

**Files:**
- Modify: `scripts/validate_plugin.sh` (add new check after 13d)

The skill body must cite both substrate artifacts that make it inspectable from outside its own conversation: the phase-derivation matrix (which derives phase intent shape from delta-ledger sections) and the `IMPLEMENTATION_PLAN_COVERS_DELTA` invariant (which pins coverage). A skill that drops either citation breaks the substrate-substrate trail.

- [ ] **Step 3.1: Add the check**

After the new check 13d, insert:

```bash
# 13e. implement-cohesively cites phase-derivation matrix + IMPLEMENTATION_PLAN_COVERS_DELTA.
# Per docs/substrate/gotchas/no-implementation-handoff.md "Tests / checks that preserve this"
# bullet 3. The skill body's Process / Hard constraints must reference both substrate
# artifacts so a reader of the SKILL alone can trace to the matrix and the invariant.
errors_before=$errors
if grep -qF 'docs/substrate/matrices/phase-derivation.md' skills/implement-cohesively/SKILL.md \
   && grep -qF 'docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md' skills/implement-cohesively/SKILL.md; then
  ok "implement-cohesively cites phase-derivation matrix and IMPLEMENTATION_PLAN_COVERS_DELTA invariant"
else
  fail "skills/implement-cohesively/SKILL.md must cite docs/substrate/matrices/phase-derivation.md AND docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md (per docs/substrate/gotchas/no-implementation-handoff.md). One or both citations are missing."
fi
```

- [ ] **Step 3.2: Run validator; expect new check passes**

```bash
bash scripts/validate_plugin.sh 2>&1 | grep -E "(phase-derivation|FAIL)"
```

Expected: `[ OK ] implement-cohesively cites phase-derivation matrix and IMPLEMENTATION_PLAN_COVERS_DELTA invariant`. No FAIL.

- [ ] **Step 3.3: Commit**

```bash
git add scripts/validate_plugin.sh
git commit -m "implement: validator check 13e — implement-cohesively cites matrix + invariant

Greps for substrate-substrate citations the SKILL body must carry:
docs/substrate/matrices/phase-derivation.md and
docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md.
Closes the deferred lint flagged in docs/substrate/gotchas/no-implementation-handoff.md
\"Tests / checks that preserve this\" bullet 3.

Delta entries: 'Tests / checks proposed' validate_plugin.sh check —
implement-cohesively SKILL.md cites phase-derivation.md and
IMPLEMENTATION_PLAN_COVERS_DELTA invariant.
"
```

---

## Task 4: New validator check — `validate-rewrite` contains the literal bypass-acknowledgment string

**Files:**
- Modify: `scripts/validate_plugin.sh` (add new check after 13e)

Per `IMPLEMENTATION_PLAN_COVERS_DELTA` §Known bypass risks: when the user picks the bypass row in the validate-rewrite decision matrix, the SKILL renders a literal acknowledgment line in the conversation transcript. The convention is the literal string itself; pin the string's presence in the SKILL body so a future edit can't drop it silently.

- [ ] **Step 4.1: Add the check**

After the new check 13e, insert:

```bash
# 13f. Literal bypass-acknowledgment string in validate-rewrite.
# Per docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md §Known bypass risks
# and docs/substrate/gotchas/no-implementation-handoff.md "Tests / checks that
# preserve this" bullet 4. The SKILL body must carry the literal string the
# Output format renders to the transcript when the bypass row is picked.
errors_before=$errors
bypass_string='Implementation may drift from the rewrite; the IMPLEMENTATION_PLAN_COVERS_DELTA invariant does not apply.'
if grep -qF "$bypass_string" skills/validate-rewrite/SKILL.md; then
  ok "validate-rewrite carries the literal bypass-acknowledgment string"
else
  fail "skills/validate-rewrite/SKILL.md missing the literal bypass-acknowledgment string (per docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md §Known bypass risks). Expected the string '$bypass_string' to appear in the SKILL body."
fi
```

- [ ] **Step 4.2: Run validator; expect new check passes**

```bash
bash scripts/validate_plugin.sh 2>&1 | grep -E "(bypass-acknowledgment|FAIL)"
```

Expected: `[ OK ] validate-rewrite carries the literal bypass-acknowledgment string`. No FAIL.

- [ ] **Step 4.3: Commit**

```bash
git add scripts/validate_plugin.sh
git commit -m "implement: validator check 13f — bypass-acknowledgment string in validate-rewrite

Greps for the literal string IMPLEMENTATION_PLAN_COVERS_DELTA's bypass
convention requires the SKILL to render in the transcript when the user
picks the bypass row of the validate-rewrite decision matrix.
Closes the deferred lint flagged in docs/substrate/gotchas/no-implementation-handoff.md
\"Tests / checks that preserve this\" bullet 4.

Delta entries: 'Tests / checks proposed' validate_plugin.sh (repair pass 2) —
literal bypass-acknowledgment string check.
"
```

---

## Task 5: Run final substrate review

**Files:** none modified — diagnostic only.

`cohesive:review-diff` is the final substrate check before branch finishing. It compares the branch diff against the rewritten specs and the substrate model. A non-Pass verdict gates merge.

- [ ] **Step 5.1: Run the validator one final time**

```bash
bash scripts/validate_plugin.sh
```

Expected: `[ OK ] Validation passed (0 warnings)`. All checks 1–14 green; total skill count is 9; total reviewer-agent count is 6.

- [ ] **Step 5.2: Invoke `cohesive:review-diff` against the branch**

In the Claude session running this implementation:

```
/cohesive:review-diff
```

The skill will detect the branch diff (`git diff main...HEAD`), discover scoped substrate, dispatch `substrate-alignment-reviewer` and `structure-reviewer` against the diff, and synthesize a verdict (Pass / Pass with notes / Needs substrate / Risky / Block).

- [ ] **Step 5.3: Persist the review**

The skill writes the review to `docs/history/reviews/2026-05-05-implement-cohesively-final-substrate-review.md` (or chat-only with `--no-write`). Default is to persist.

- [ ] **Step 5.4: Act on the verdict**

- **Pass** or **Pass with notes** → proceed to Task 6.
- **Needs substrate** → either extend the rewrite via `cohesive:rewrite-specs` (adding a third repair pass) or revert the divergent code; do not proceed to Task 6 until substrate and code agree.
- **Risky** or **Block** → repair before merge. Re-run Task 5.

- [ ] **Step 5.5: Commit (if review was persisted)**

```bash
git add docs/history/reviews/2026-05-05-implement-cohesively-final-substrate-review.md
git commit -m "review: final substrate check on implement-cohesively branch

Verdict: <from review-diff>
See: docs/history/reviews/2026-05-05-implement-cohesively-final-substrate-review.md
"
```

---

## Task 6: Branch finishing handoff

**Files:** none modified — recommendation only.

Per `implement-cohesively` Hard constraint and the Cohesive↔Superpowers seam, branch finishing is a user action. This task records the recommendation; the user invokes `superpowers:finishing-a-development-branch` when ready.

- [ ] **Step 6.1: Confirm branch state**

```bash
git log --oneline main..HEAD
```

Expected: 7+ commits on `design/implement-cohesively`, including:
- `f08c731` design: rewrite specs for implement-cohesively
- `6362458` review: validate-rewrite verdict (Issues Found, pass 1)
- `67cfcf9` design: repair pass 1
- `ae55cdf` review: validate-rewrite (Approved, pass 2)
- `cda3364` design: repair pass 2
- 4 new commits from Tasks 1–4
- 1 review commit from Task 5 (if persisted)

- [ ] **Step 6.2: Render handoff message**

Surface in chat:

```
Implementation complete on design/implement-cohesively.
Validator green. Final substrate review: <verdict>.
Recommended next step: superpowers:finishing-a-development-branch
(merge to main; push; close design branch).
```

Do not invoke `superpowers:finishing-a-development-branch` — branch finishing is a user action per `implement-cohesively` §Composition.

---

## Self-Review

**Spec coverage:** Each ledger §"Tests / checks proposed" entry under `validate_plugin.sh` updates maps to a task: validator-array additions → Task 1; decision-matrix grep → Task 2; matrix+invariant citation grep → Task 3; bypass-acknowledgment grep → Task 4. The `delta-coverage-reviewer agent file exists if implement-cohesively SKILL.md mentions it` proposed check is covered by the existing `Referenced files exist` warn-level check (line 97–110) — no new task needed; the warn-level reference scan already catches missing referenced files. Manual scenarios (deferred) are documented in the gotcha doc, not in this implementation pass; this is intentional per the ledger §"Out of scope for this implementation pass."

**Placeholder scan:** No TBD/TODO/"implement later." Each step has the actual edit content or command. The temporary-corruption sanity test in Task 2.3 is the only "verify failure path" step; it's complete.

**Type consistency:** Validator-array names (`expected_skills`, `prereq_subskills`, etc.) match across all five tasks. Check IDs (13d, 13e, 13f) are sequential and follow the existing convention (13a/b/c are the verdict-leads and voice-citation checks). Branch name (`design/implement-cohesively`) is consistent.

**Cohesive convention compliance:** Plan persisted under `docs/history/plans/` (overrides Superpowers' default `docs/superpowers/plans/`) per Cohesive's `docs/substrate/designs/substrate-layout.md`. No `${CLAUDE_PLUGIN_ROOT}` paths in shell commands (those are skill-body-only per `PLUGIN_ROOT_PATHS`).
