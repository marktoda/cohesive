---
name: implement-cohesively
description: Use after validate-rewrite has returned Approved on a spec rewrite, when the user wants to land code that makes the rewrite true. Drives an implementation phase loop where Cohesive owns delta-derived phase shape and per-phase cross-review against the design delta ledger; Superpowers owns plan writing and TDD execution inside each phase. Triggers on "implement the approved rewrite", "land docs with implementation", "implement-cohesively", "drive implementation against the delta", "ship the rewrite". Always preceded by validate-rewrite Approved; always pairs with superpowers:writing-plans and superpowers:executing-plans.
---

# Implement cohesively

## What this skill produces

- A **branch with implementation commits** that make every entry in the design delta ledger true in code, test, and CI.
- A **per-phase implementation plan** (one `docs/history/plans/<YYYY-MM-DD>-<slug>-phase-N.md` per phase) authored by `superpowers:writing-plans` from a delta-derived phase intent.
- A **per-phase cross-review** dispatched against (delta entries, plan, diff) by the `delta-coverage-reviewer` agent.
- A **final substrate review** of the branch against the rewritten specs via `cohesive:review-diff`.
- A handoff to `superpowers:finishing-a-development-branch` (or repair to the relevant earlier skill) based on the verdict.

This is the second of Cohesive's flagship skills that owns code-producing work indirectly. The skill itself writes no code: it composes with `superpowers:writing-plans` (which authors plans) and `superpowers:executing-plans` (which writes code with TDD inside each phase). The Cohesive contribution is the **phase loop**: deriving phase shape from substrate, dispatching the cross-review agent against the delta ledger, and gating progression on coverage.

## Voice

Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output. The voice guide is the load-bearing source for verdict-leads, header-depth cap, density budgets, and forbidden phrasings; the imperative above is what triggers the model to load it via a Read tool call. Do not reproduce the imperative or any citation to the voice guide inside the Output format render template — instructions placed inside render templates leak verbatim into user-facing output (the failure mode `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` documents).

## Hard constraints

1. **An Approved validate-rewrite verdict is required, declared as paths.** This skill's prereq is a file path, not session state — the canonical clarifying question per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md` does not apply. Required inputs (validation review path + design delta ledger path + branch name) are declared in §"Step 0. Resolve inputs and confirm prereqs"; the dispatching context (the `cohesively` router, a prior `validate-rewrite` Approved render the user is acting on, or direct user invocation) supplies them explicitly.

   **If any required input is missing,** stop with a directive error per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Path prereqs use directive errors, not the canonical question". The directive names the missing input and the upstream skill that produces it:

   ```
   Missing validation review for slug `<slug>`. Run cohesive:validate-rewrite first;
   expected output at docs/history/reviews/<date>-<slug>-rewrite-validation.md.
   ```

   ```
   Missing design delta ledger for slug `<slug>`. Run cohesive:rewrite-specs first;
   expected output at docs/history/delta-ledgers/<date>-<slug>.md.
   ```

   Do not ask the canonical forced-choice question and do not invent paths. Per `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Verdict → severity-floor mapping (validate-rewrite)", `Approved` is the only verdict that unlocks this route — verify the supplied review's verdict line is `**Verdict:** Approved` before proceeding; on any other verdict, refuse with a pointer to the appropriate upstream skill. The per-handoff input contract is in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` §"validate-rewrite → implement-cohesively (Approved branch)".

2. **Compose with Superpowers; do not reinvent its execution discipline.** This skill invokes `superpowers:writing-plans` once per phase to author the plan and `superpowers:executing-plans` once per phase to execute it. The skill never authors a TDD-shaped plan directly and never writes code itself. If Superpowers is not installed, the skill stops with a hard error and recommends installation — the inline 5-line worktree fallback in `rewrite-specs` does not apply here, because plan-writing and TDD execution are not 5-line operations.
3. **Per-phase cross-review is mandatory.** Every phase ends with a `delta-coverage-reviewer` dispatch (Task subprocess, paths-only inputs, fresh eyes). No phase advances without a Covered verdict. A Drift or Incomplete verdict gates the next phase until repaired.
4. **Coverage of the delta is structural.** Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`, every entry in the design delta ledger maps to at least one phase. Phase 1 produces a coverage table and refuses to advance to Phase 2 if any delta entry is uncovered.
5. **Final substrate review is mandatory.** After the last per-phase iteration of Phase 2 passes its cross-review, Phase 3 dispatches `cohesive:review-diff` against the branch. A non-Pass verdict gates merge.

## Process

The skill body uses `Step 0` and `Step 4` for preflight and handoff bookends, and `Phase 1`, `Phase 2`, `Phase 3` for the three structural phases the named invariant `IMPLEMENTATION_PLAN_COVERS_DELTA` references. Citations to "Phase 1" / "Phase 2" / "Phase 3" elsewhere in the substrate (the invariant, anti-patterns, acceptance criteria) refer to the headings in this section by exactly those labels.

### Step 0. Resolve inputs and confirm prereqs

Required inputs:

- **Design delta ledger path** — usually `docs/history/delta-ledgers/YYYY-MM-DD-<slug>.md`. The skill reads this as the substrate-shaped source of work.
- **Validate-rewrite Approved verdict path** — usually `docs/history/reviews/YYYY-MM-DD-<slug>-rewrite-validation.md`. The skill verifies the verdict is `Approved`.
- **Branch name** — typically `design/<slug>` from the rewrite worktree. Implementation lands on this branch (or a child branch — see "Branch shape" below).
- **Substrate discovery report path** (optional) — passed to per-phase reviewer agents for context.

If any required input is missing, stop and ask. Do not invent inputs.

### Phase 1. Derive phases from the design delta ledger

Read the delta ledger and apply the phase-derivation matrix at `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/phase-derivation.md` to produce an ordered list of phases. Each phase carries:

- A **phase intent** — the substrate-shaped paragraph that will be passed to `superpowers:writing-plans` as input. Format: "Make these delta entries true in code: [list]. Constraints: [named invariants the phase touches]. Acceptance: [the cross-review will check these properties]."
- A list of **delta entries it covers** — references to specific bullets/rows in the ledger. Stable identifiers (file path for "Files rewritten" entries, invariant name for "Named invariants" entries, etc.).
- A list of **predecessor phases** — phases this one depends on (e.g., a code phase depends on the conceptual rename phase that updated identifiers).

Phase ordering rules:

1. Conceptual changes (renames, splits, merges) precede code that uses the new names.
2. New named invariants and their enforcement (test/type/linter) ship in the same phase.
3. New behavior matrices precede code that branches on their cells.
4. New gotchas and their accompanying tests ship in the same phase.
5. Semantic linter specs marked "deferred" in the delta ledger do not produce phases (they are explicitly out of scope for the current implementation pass).

Render the phase list as a **coverage table**. The Phase 1 coverage table uses the same column shape as the final Phases table in §Output format: `# | Intent (one clause) | Delta entries | Plan | Cross-review`. At Phase 1 the `Plan` and `Cross-review` columns are filled with the literal value `pending`; they update as each phase completes. The Phase 1 coverage table and the final Phases table are the same table at two points in time, not two artifacts. If any delta-ledger entry is uncovered, stop and surface the gap. Do not advance until coverage is complete.

After rendering the coverage table, **surface the dispatch budget** to the user: announce the phase count and the corresponding `delta-coverage-reviewer` dispatch count (one per phase, plus one final `cohesive:review-diff` at Phase 3). When the phase count exceeds **8**, pause and confirm before proceeding to Phase 2. Format the announcement in chat as: `Phase 1 derived <N> phases. Phase 2 will dispatch <N> delta-coverage-reviewer agents plus one cohesive:review-diff at Phase 3. Proceeding…` (or `…Confirm before continuing.` when over the threshold). The threshold is a tunable v0.1 default; tighten or relax in a follow-up substrate change as real-world phase-counts inform the budget.

### Phase 2. For each phase, run the loop

For phase N in order:

#### 2a. Plan the phase

Invoke `superpowers:writing-plans` via the Skill tool with the phase intent as input. The plan persists at `docs/history/plans/<YYYY-MM-DD>-<slug>-phase-<N>.md`. Capture the plan path; it is an input to the cross-review agent.

#### 2b. Execute the phase

Invoke `superpowers:executing-plans` via the Skill tool with the persisted plan path. Superpowers owns TDD discipline inside this step: failing test first, minimal implementation, refactor. The skill does not interleave; it waits for the phase to land code on the branch.

#### 2c. Cross-review the phase

Dispatch the `delta-coverage-reviewer` agent via Task tool with `subagent_type: delta-coverage-reviewer`. The dispatch prompt names exactly three artifact paths: the delta-ledger entries this phase covers (passed as a quoted excerpt of the ledger plus the ledger path), the plan path, and the phase diff (`git diff <branch>..HEAD` or equivalent). The reviewer returns one of three verdicts:

- **Covered** — every delta entry the phase claims is implemented; the implementation is consistent with the plan; advance to phase N+1.
- **Drift** — implementation diverges from the plan or the delta. The reviewer names the divergent items. Repair: re-invoke `superpowers:writing-plans` for a focused repair plan, then `superpowers:executing-plans` for the repair, then re-dispatch the reviewer.
- **Incomplete** — the implementation does not cover all delta entries the phase claims. Same repair loop as Drift, with the missing entries called out.

**Escalation rule.** Each phase gets at most **one repair cycle**. If the post-repair re-dispatch of `delta-coverage-reviewer` still returns Drift or Incomplete, the skill stops with verdict `Phase Drift`, surfaces the reviewer's findings to the user, and refuses to advance to phase N+1. The skill does not auto-loop a third time. Repair beyond the second attempt is a user action — either the user repairs by hand and re-invokes the skill, or the user returns to `cohesive:rewrite-specs` because the delta entry itself was misformulated.

#### 2d. Commit the phase

```bash
git add -A
git commit -m "implement: phase <N> — <one-line summary>

Plan: docs/history/plans/<YYYY-MM-DD>-<slug>-phase-<N>.md
Delta entries: <comma-separated list of stable IDs from the ledger>
Cross-review: Covered
"
```

Commit messages cite the plan path and the delta entries by stable ID. This is what makes per-branch grep auditing of "which phase implemented which delta entry" possible — and is the substrate-shape of the proposed `design/<slug>`-or-`implement/<slug>`-branch commit-message linter (deferred).

### Phase 3. Final substrate review

After the last phase passes its cross-review, dispatch `cohesive:review-diff` against the branch. The review compares the branch diff to the rewritten specs and the substrate model. Verdict:

- **Pass** or **Pass with notes** — the implementation is consistent with the substrate. Hand off to `superpowers:finishing-a-development-branch`.
- **Needs substrate** — implementation introduced behavior not covered by the rewrite. Either rewrite the specs (`cohesive:rewrite-specs` to extend the rewrite) or revert the implementation in question.
- **Risky** or **Block** — substrate drift or invariant violation. Repair before merge.

### Step 4. Hand off

Announce the verdict and the recommended next step. Do not invoke `superpowers:finishing-a-development-branch` automatically — branch finishing is a user action.

## Output format

```md
# Implementation Complete — <topic>

**Verdict:** Implemented / Phase Drift / Substrate Drift / Aborted

**Thesis:** <one or two sentences — what landed and what it means>

## Phases

| # | Intent (one clause) | Delta entries | Plan | Cross-review |
|---|---|---|---|---|
| 1 | <intent> | <stable IDs> | `docs/history/plans/<...>-phase-1.md` | Covered |
| 2 | <intent> | <stable IDs> | `docs/history/plans/<...>-phase-2.md` | Covered |
| ... | ... | ... | ... | ... |

## Delta coverage

Every delta entry mapped to ≥1 phase: **yes** / **no**
- Uncovered entries: <none / list with stable IDs>

## Final substrate review

`docs/history/reviews/<YYYY-MM-DD>-<slug>-final-substrate-review.md` (chat render or persisted file)
**Verdict:** <from review-diff vocabulary>

## Branch state

- Branch: `design/<slug>`
- Commits: <count>
- Plans persisted: <count> at `docs/history/plans/`

### Recommended next Cohesive skill

Per verdict:

- **Implemented** — `superpowers:finishing-a-development-branch` — substrate and code agree; ready to merge.
- **Phase Drift** — `cohesive:implement-cohesively` (resume) — repair the flagged phase, re-dispatch `delta-coverage-reviewer`.
- **Substrate Drift** — `cohesive:rewrite-specs` — extend the rewrite to cover the implementation that landed, or revert the divergent code.
- **Aborted** — none; user stopped before completion.
```

## Anti-patterns (Red Flags)

| Anti-pattern | Why it's wrong | Fix |
|---|---|---|
| Skipping `superpowers:writing-plans` per phase to "save tokens" | Collapses the cross-review surface; reviewer cannot distinguish "plan didn't cover delta entry" from "implementation didn't execute plan" — see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/skipping-per-phase-plan.md` | Always invoke `writing-plans`; per-phase plans are inspectable artifacts |
| Authoring TDD-shaped tasks directly from delta entries | Reinvents `superpowers:writing-plans`; defeats the composition seam | Pass delta-derived intent to `writing-plans`; let it produce TDD shape |
| Producing code from this skill body | The skill orchestrates; it never writes code itself | All code-writing happens inside `superpowers:executing-plans` |
| Letting a phase advance without `delta-coverage-reviewer` Covered verdict | Phases that drift compound; final review can't repair the gap | Per-phase cross-review is mandatory per Hard constraint #3 |
| Ignoring uncovered delta entries because they "look small" | Coverage gap = silent substrate drift | Phase 1's coverage table refuses to advance with uncovered entries |
| Auto-looping repair cycles past the first | Hides design defects behind reviewer fatigue; the second-failure case usually means the delta entry itself is wrong, not the code | Per Phase 2c escalation rule: stop at `Phase Drift` after one repair cycle; surface findings to user |
| Skipping the final substrate review (Phase 3) | The branch may pass per-phase reviews and still drift in aggregate | Hard constraint #5 — `cohesive:review-diff` is mandatory before handoff |
| Auto-invoking `superpowers:finishing-a-development-branch` | Branch finishing is a user action per Cohesive↔Superpowers seam | Recommend; do not invoke |
| Pre-summarizing the design for the cross-review agent | Bypasses fresh-eyes per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/fresh-eyes-review.md` | Pass paths only; never summarize the rewrite for the agent |

## Branch shape

The implementation lands on the same `design/<slug>` branch the rewrite produced. The rewrite commit and the implementation commits live on one branch, in commit order. This is what "land docs with implementation" means in practice: the merge brings spec and code together. If the rewrite commit was already merged separately, the implementation lands on a fresh `implement/<slug>` branch off the merge — but the default is one-branch-end-to-end.

## Composition

- **Always preceded by:** `validate-rewrite` (Approved verdict required).
- **Composes with:**
  - `superpowers:writing-plans` — per-phase plan authoring.
  - `superpowers:executing-plans` — per-phase TDD execution.
  - `cohesive:review-diff` — final substrate review.
- **Followed by:** `superpowers:finishing-a-development-branch` (Implemented verdict) or repair via `cohesive:rewrite-specs` (Substrate Drift) or repair via re-invocation (Phase Drift).

## Acceptance criteria

- An Approved validate-rewrite verdict path is in the inputs.
- Phase 1 produces a coverage table that uses the same column shape as the final Phases table in §Output format, with `Plan` and `Cross-review` columns initialized to `pending`; the skill refuses to advance with uncovered delta entries.
- Phase 1 surfaces the dispatch budget (phase count + `delta-coverage-reviewer` dispatch count + one final `review-diff`) and pauses for user confirmation when the phase count exceeds 8.
- Each phase invokes `superpowers:writing-plans`, then `superpowers:executing-plans`, then `delta-coverage-reviewer` — in that order.
- The cross-review agent receives only paths and a quoted ledger excerpt; never a pre-summarized design narrative.
- Each phase commit cites the plan path and the delta-entry stable IDs.
- The Phase 2c escalation rule holds: after one repair cycle, the skill stops with verdict `Phase Drift`; no auto-loop past the first repair.
- Phase 3 (`cohesive:review-diff`) runs after the last per-phase iteration of Phase 2.
- The skill never invokes `superpowers:finishing-a-development-branch` — handoff is a user action.

## What this skill is *not*

- Not a code generator. It writes no code; `superpowers:executing-plans` does that inside each phase.
- Not a planner. It produces phase intent (substrate-shape); `superpowers:writing-plans` produces the plan (TDD-shape).
- Not a substitute for `cohesive:review-diff`. The final review is a delegation, not a built-in.
- Not a substitute for branch finishing. `superpowers:finishing-a-development-branch` owns merge mechanics.
- Not a substitute for `validate-rewrite`. The Approved verdict is a prereq, not produced here.
