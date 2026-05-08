---
name: implement-cohesively
description: Use after validate-rewrite has returned Approved on a spec rewrite, when the user wants to land code that makes the rewrite true. Drives a single-pass implementation where Cohesive owns the substrate-shaped intent (thin paragraph derived from the delta ledger) and the end-of-run dual reviewer dispatch (delta-coverage-reviewer + cohesive:review-diff in parallel, AND-shape verdict synthesis); Superpowers owns plan writing and TDD execution. Triggers on "implement the approved rewrite", "land docs with implementation", "implement-cohesively", "drive implementation against the delta", "ship the rewrite". Always preceded by validate-rewrite Approved; always pairs with superpowers:writing-plans and superpowers:executing-plans.
---

# Implement cohesively

## What this skill produces

- A **branch with implementation commits** that make every non-Deferred entry in the design delta ledger true in code, test, and CI.
- A **single per-pass implementation plan** at `docs/history/plans/<YYYY-MM-DD>-<slug>.md`, authored by `superpowers:writing-plans` from a thin intent paragraph the skill composes from the delta ledger — committed during the run as **ephemeral run scaffolding** per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/artifact-placement.md` §"Lifecycle by artifact category".
- An **end-of-run dual reviewer dispatch**: `delta-coverage-reviewer` (whole-branch input contract; verifies every delta entry maps to a diff hunk) and `cohesive:review-diff` (substrate alignment against the rewritten specs) run in parallel. Verdict is synthesized AND-shape.
- On Implemented verdict only: a **single cleanup commit at Step 3.5** that strips ephemeral artifacts (per-pass plan, discovery report if present) before handoff. The cleanup commit is the breadcrumb back from main to pre-cleanup branch history.
- A handoff to `superpowers:finishing-a-development-branch` (or repair to the relevant earlier skill) based on the verdict.

This is the second of Cohesive's flagship skills that owns code-producing work indirectly. The skill itself writes no code: it composes with `superpowers:writing-plans` (which authors the plan) and `superpowers:executing-plans` (which writes code with TDD). The Cohesive contribution is the **substrate-shaped framing**: composing the intent from the delta ledger, surfacing the delta-size budget gate before invocation, and dispatching the end-of-run dual reviewer pair with AND-shape verdict synthesis.

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

2. **Compose with Superpowers; do not reinvent its execution discipline.** This skill invokes `superpowers:writing-plans` once to author the per-pass plan and `superpowers:executing-plans` once to execute it. The skill never authors a TDD-shaped plan directly and never writes code itself. If Superpowers is not installed, the skill stops with a hard error and recommends installation — the inline 5-line worktree fallback in `rewrite-specs` does not apply here, because plan-writing and TDD execution are not 5-line operations.
3. **Single per-pass plan covers the delta.** Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` Rule #1, every non-Deferred entry in the design delta ledger is covered by the single plan authored from the thin intent paragraph. Step 1 enumerates every non-Deferred entry by stable ID into the intent paragraph; an omitted entry is a substrate violation the end-of-run reviewer will flag.
4. **End-of-run dual reviewer dispatch is mandatory.** The implementation pass ends with parallel dispatch of `delta-coverage-reviewer` (Task subprocess, paths-only inputs, fresh eyes, whole-branch input contract) and `cohesive:review-diff` (Cohesive skill, substrate alignment scope). Both reviewers must complete before verdict synthesis. Skipping either is a violation. The verdict is synthesized AND-shape per §"Verdict synthesis" below.
5. **Step 3.5 cleanup is gated on Implemented verdict.** On Implemented (both reviewers Pass), Step 3.5 strips ephemeral artifacts (per-pass plan, discovery report when present) via a single cleanup commit before handoff. On Coverage Drift / Substrate Drift / Aborted, Step 3.5 does not fire — ephemeral artifacts remain on the branch for the next attempt or post-mortem. The cleanup commit's body lists removed paths verbatim; a cleanup commit without that list is a violation. See §"Step 3.5. Post-implementation cleanup" for operational steps and `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` Rule #5 for the structural pin.
6. **Delta-size budget gate fires above threshold.** Step 1 surfaces the non-Deferred delta-entry count before invoking `superpowers:writing-plans`. When the count exceeds **15** (default; tunable in a follow-up substrate change), the skill pauses for user confirmation. The gate is the structural mitigation for mega-plan abandonment risk per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/large-delta-mega-plan.md`. Below threshold the gate is invisible; above threshold, skipping the surfacing or invoking `writing-plans` without confirmation is a violation.

## Process

The skill body uses `Step 0` and `Step 4` for preflight and handoff bookends, `Step 1` / `Step 2` / `Step 3` for the three structural steps the named invariant `IMPLEMENTATION_PLAN_COVERS_DELTA` references, and `Step 3.5` for the ephemeral-cleanup step inserted between Step 3 and Step 4. Citations to "Step 1" / "Step 2" / "Step 3" / "Step 3.5" elsewhere in the substrate (the invariant, anti-patterns, acceptance criteria) refer to the headings in this section by exactly those labels.

### Step 0. Resolve inputs and confirm prereqs

Required inputs:

- **Design delta ledger path** — usually `docs/history/delta-ledgers/YYYY-MM-DD-<slug>.md`. The skill reads this as the substrate-shaped source of work.
- **Validate-rewrite Approved verdict path** — usually `docs/history/reviews/YYYY-MM-DD-<slug>-rewrite-validation.md`. The skill verifies the verdict is `Approved`.
- **Branch name** — typically `design/<slug>` from the rewrite worktree. Implementation lands on this branch (or a child branch — see §"Branch shape" below).
- **Substrate discovery report path** (optional) — passed to the end-of-run reviewers for context.

If any required input is missing, halt with the directive error per Hard constraint #1; do not ask the canonical forced-choice question and do not invent paths. The directive-error templates and the upstream-skill names live in Hard constraint #1 above; this step does not duplicate them.

### Step 1. Compose the intent paragraph and dispatch writing-plans

Read the delta ledger and enumerate every non-Deferred entry by stable ID (Files-rewritten paths, Conceptual-change row IDs, Named-invariant names, Behavior-matrix paths, Gotcha names, Tests-proposed descriptions). Surface the **delta-size budget gate** before composing the intent:

- If the non-Deferred entry count is at or below **15**, proceed silently to intent composition.
- If above 15, render the budget surfacing in chat and pause for user confirmation:

   ```
   This delta has <N> entries. Single-pass implementation produces one large plan;
   executing-plans runs may abandon on context overflow. Confirm to proceed, or run
   cohesive:rewrite-specs to split the delta into smaller rewrites first.
   ```

  On confirm: proceed. On abort: exit with `Aborted` verdict and recommend scope reduction via `cohesive:rewrite-specs`. The threshold is a v0.1 default; tighten or relax in a follow-up substrate change as real-world delta sizes inform the budget.

After the gate clears, compose the **thin intent paragraph** and pass it to `superpowers:writing-plans` via the Skill tool. The format is exactly three lines:

```
Make these delta entries true: <comma-separated stable-ID list of every non-Deferred entry>.
Constraints: <named invariants the change touches; cite by INVARIANT_NAME>.
Acceptance: cohesive:implement-cohesively dispatches delta-coverage-reviewer (verifies every delta entry maps to a diff hunk) and cohesive:review-diff (verifies substrate alignment with the rewritten specs) at end-of-run; both must Pass.
```

The intent paragraph is the substrate-shape→TDD-shape seam. `writing-plans` produces the TDD-shape plan; the intent paragraph names what the plan must accomplish in substrate terms. Capture the plan path that `writing-plans` returns (`docs/history/plans/<YYYY-MM-DD>-<slug>.md`); it is an input to the end-of-run reviewer dispatch.

### Step 2. Execute the plan

Invoke `superpowers:executing-plans` via the Skill tool with the persisted plan path. Superpowers owns TDD discipline inside this step: failing test first, minimal implementation, refactor. The skill does not interleave; it waits for the implementation commits to land on the branch.

Implementation commits cite both the plan path and the delta-entry stable IDs they implement. The commit-message convention `executing-plans` produces should include both citations; if it does not, the skill body's Hard constraint #3 plus the named invariant `IMPLEMENTATION_PLAN_COVERS_DELTA` Rule #3 govern the citation requirement.

### Step 3. End-of-run dual reviewer dispatch

After the last implementation commit lands, dispatch two reviewers **in parallel**:

- **`delta-coverage-reviewer`** (Task subprocess) with `subagent_type: delta-coverage-reviewer`. The dispatch prompt names exactly three artifact paths: the design delta ledger path, the per-pass plan path, and the whole-branch diff (`git diff <base>..<branch>` or equivalent). The reviewer returns one of three verdicts: **Covered** / **Drift** / **Incomplete**. Persist the reviewer's output at `docs/history/reviews/<YYYY-MM-DD>-<slug>-coverage-review.md`.

- **`cohesive:review-diff`** (Skill tool dispatch) scoped to the branch with the design delta ledger path passed as additional context. The skill dispatches its own reviewer agents (substrate-alignment + structure) per its Process. The verdict is one of: **Pass** / **Pass with notes** / **Needs substrate** / **Risky** / **Block**. The persisted review lives at `docs/history/reviews/<YYYY-MM-DD>-<slug>-final-substrate-review.md`.

Both dispatches happen in the same turn (the harness's parallel-tool-call pattern). Wait for both to complete before synthesizing the verdict.

### Verdict synthesis

The two reviewer outputs combine AND-shape into a single internal verdict:

| `delta-coverage-reviewer` | `cohesive:review-diff` | Internal verdict |
|---|---|---|
| Covered | Pass / Pass with notes | **Implemented** |
| Drift / Incomplete | Pass / Pass with notes | **Coverage Drift** |
| Covered | Needs substrate / Risky / Block | **Substrate Drift** |
| Drift / Incomplete | Needs substrate / Risky / Block | **Substrate Drift** (wins on dual-fail; the rewrite was misformulated, which makes coverage gaps downstream) |

The internal verdict translates to the user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"implement-cohesively". Render the chat trailer per §"Output format" below; persist the synthesis (which reviewer flagged what) in the trailer's `## End-of-run review` body block.

A separate **Aborted** internal verdict applies when the user paused before Step 3 ran (e.g., declined the budget gate, or stopped during Step 2). Aborted does not run reviewers and does not fire Step 3.5.

### Step 3.5. Post-implementation cleanup

Fires **only on Implemented verdict**. On any other verdict, skip directly to Step 4 — ephemeral artifacts remain on the branch for the next attempt or post-mortem.

`git rm` the ephemeral paths for this slug (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/artifact-placement.md` §"Lifecycle by artifact category" — currently `docs/history/plans/<YYYY-MM-DD>-<slug>.md` and `docs/cohesive/discovery/<slug>.md` if present), and produce a single commit whose body lists the removed paths verbatim:

```bash
git rm <enumerated paths>
git commit -m "implement: clean up post-implementation scaffolding for <slug>

Removed:
- <path 1>
- <path 2>

Recoverable via 'git log --all -- <pattern>' from pre-cleanup branch history.
"
```

The verbatim removed-paths body is the breadcrumb a forensic reader on main follows back to branch history. Capture the cleanup commit SHA for the trailer's Branch state slot. Then proceed to Step 4.

### Step 4. Hand off

Announce the verdict and the recommended next step. Do not invoke `superpowers:finishing-a-development-branch` automatically — branch finishing is a user action.

## Output format

The skill renders the centralized chat trailer per `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md`. The chat render is the decision-rendering of what landed per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2a (with sub-rules 2b / 2c) and the audience seam in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.

**Verdict translation.** The internal verdict (`Implemented` / `Coverage Drift` / `Substrate Drift` / `Aborted`) renders in the chat trailer as the user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"implement-cohesively". The user-facing label preserves the internal token so dispatch grep targets still resolve.

**Body block specification.** Per the §"Variants" `implement-cohesively` row of the centralized template: a `## Code matches locked design` slot leads (synthesized AND-shape from the dual reviewer dispatch — this is the **build→done verification** the user reads first), followed by `## End-of-run review` block surfacing both reviewer verdicts with paths to their persisted outputs, and `## Branch state` (branch + implementation commit count + plan path). Long-form review detail lives in the persisted reviewer output files, not chat. Render only non-empty sections per the chat-trailer template's §"Render-only-non-empty rule"; the per-section conditions are enumerated in the §"Render-conditional rules for the body block" subsection below.

**Render-conditional rules for the body block.** The render template below is the agent's literal output template; it does not carry meta-instructions or comments inline (per the failure mode in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` §"Correct pattern" — instructions inside render templates leak into user-facing output). The render conditions live here, in prose, instead:

- **`## Code matches locked design`** — the spec-coverage slot. Render exactly one of three shapes, matching the internal verdict:
  - **Internal `Implemented`** (Covered + Pass / Pass with notes) — render `**Code matches locked design:** ✓` and omit the divergent-items list.
  - **Internal `Coverage Drift` or `Substrate Drift`** — render `**Drift detected:** ✗ <count> places` followed by a bulleted list of divergent items (file:line + what's divergent), aggregated from both reviewer outputs.
  - **Internal `Aborted`** (the user paused before Step 3 ran) — omit both lines and the divergent-items list; the slot collapses to its header. The Branch state section below carries the partial state.
- **`## End-of-run review`** — renders on Implemented / Coverage Drift / Substrate Drift only. Two bullets, one per reviewer, each naming the reviewer verdict and the path to its persisted output. Omitted on Aborted (Step 3 did not run).
- **`## Branch state`** — always renders. On Implemented verdict, includes the cleanup commit SHA on a `Cleanup commit:` line so the user can reference the pre-cleanup boundary for forensic recovery via `git log --all -- docs/history/plans/<slug>.md`. On Coverage Drift / Substrate Drift / Aborted, the cleanup-commit line is omitted (Step 3.5 did not fire).
- **`### Next`** — renders one bullet, matching the internal verdict. The four `Internal <verdict>:` shapes below show the four possible renders; the chat trailer carries exactly one. This implements the per-verdict-branch recommendation rule in the chat-trailer template's §"How `### Next` carries payload" — the payload is the matching bullet, not the full set.

```md
# Implementation Complete — <topic>

**Verdict:** <user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"implement-cohesively" — e.g., **Implementation complete** / **Coverage gap — re-run to fill** / **Implementation went beyond the design** / **Implementation paused**>

**Thesis:** <one or two sentences — what landed and what it means, in decision-shape>

## Code matches locked design

<one of the three shapes per the prose rules above; omit the slot's content entirely on Aborted>

## End-of-run review

- Coverage: <Covered | Drift | Incomplete> — `docs/history/reviews/<YYYY-MM-DD>-<slug>-coverage-review.md`
- Substrate: <Pass | Pass with notes | Needs substrate | Risky | Block> — `docs/history/reviews/<YYYY-MM-DD>-<slug>-final-substrate-review.md`

## Branch state

- Branch: `design/<slug>`
- Implementation commits: <count>
- Plan: `docs/history/plans/<YYYY-MM-DD>-<slug>.md` (committed during the run at `docs/history/plans/`)
- Cleanup commit: `<SHA>` *(rendered only on Implemented verdict; SHA points at the Step 3.5 commit that stripped ephemeral artifacts)*

### Next

<one decision-shaped bullet, matching the internal verdict — the four shapes are enumerated below; the chat trailer renders exactly one>
```

The four `### Next` bullet shapes (one renders per invocation, matching the internal verdict):

- **Internal `Implemented`:** Substrate and code agree; ready to ship. *(`superpowers:finishing-a-development-branch`.)* **Scope:** the `design/<slug>` branch.
- **Internal `Coverage Drift`:** Repair the named coverage gaps, then re-invoke. *(`cohesive:implement-cohesively` resume.)* **Scope:** the delta entries the coverage reviewer flagged as Drift / Incomplete.
- **Internal `Substrate Drift`:** Extend the design to cover what the implementation introduced, or revert the divergent code. *(`cohesive:rewrite-specs`.)* **Files to edit:** <enumerate the docs the substrate review flagged as needing extension>. Slug: `<derived-from-original-slug>-extension`.
- **Internal `Aborted`:** Implementation paused at user request. *(No follow-up skill required.)* The branch state is whatever the last implementation commit landed.

## Anti-patterns (Red Flags)

| Anti-pattern | Why it's wrong | Fix |
|---|---|---|
| Skipping `superpowers:writing-plans` to "save tokens" | Collapses the substrate-shape→TDD-shape seam; the end-of-run coverage reviewer cannot distinguish "plan didn't cover delta entry" from "implementation didn't execute plan" | Always invoke `writing-plans`; the per-pass plan is the inspectable bridge artifact |
| Authoring TDD-shaped tasks directly from delta entries | Reinvents `superpowers:writing-plans`; defeats the composition seam | Pass the thin intent paragraph to `writing-plans`; let it produce TDD shape |
| Producing code from this skill body | The skill orchestrates; it never writes code itself | All code-writing happens inside `superpowers:executing-plans` |
| Skipping or sequencing the dual reviewer dispatch | The dual reviewer pair is the substrate-side enforcement of `IMPLEMENTATION_PLAN_COVERS_DELTA`; running only one or running them sequentially defeats the parallel-fresh-eyes design | Dispatch both reviewers in parallel per Hard constraint #4; wait for both before synthesizing |
| Substituting `cohesive:review-diff`'s coverage check for the dedicated `delta-coverage-reviewer` | Folds two distinct concerns (substrate alignment vs delta coverage) into one prompt; one lens crowds out the other under token pressure | Keep the reviewers separate; the AND-shape synthesis at §"Verdict synthesis" combines them |
| Ignoring the delta-size budget gate above threshold | The gate is the structural mitigation for mega-plan abandonment per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/large-delta-mega-plan.md`; bypassing it makes abandonment silent | Surface the count and pause for confirmation per Step 1; honor abort as `Aborted` verdict |
| Letting the intent paragraph drop a non-Deferred delta entry | Coverage gap = silent substrate drift the end-of-run reviewer will catch but at the cost of a re-run | Step 1 enumerates every non-Deferred entry by stable ID before composing the intent |
| Auto-invoking `superpowers:finishing-a-development-branch` | Branch finishing is a user action per Cohesive↔Superpowers seam | Recommend; do not invoke |
| Pre-summarizing the design for the dispatched reviewers | Bypasses fresh-eyes per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/fresh-eyes-review.md` | Pass paths only; never summarize the rewrite for the agent |
| Step 3.5 mishandling | Cleanup fires on a non-Implemented verdict (strips artifacts load-bearing for the next attempt), skips on Implemented (run scaffolding leaks into main), produces a commit without a verbatim removed-paths body (forensic breadcrumb is lost), or strips durable artifacts (decision records become unrecoverable) | Hard constraint #5 enumerates all four sub-conditions; the ephemeral path list comes from `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/artifact-placement.md` §"Lifecycle by artifact category" |

## Branch shape

The implementation lands on the same `design/<slug>` branch the rewrite produced. The rewrite commit and the implementation commits live on one branch, in commit order. This is what "land docs with implementation" means in practice: the merge brings spec and code together. If the rewrite commit was already merged separately, the implementation lands on a fresh `implement/<slug>` branch off the merge — but the default is one-branch-end-to-end.

## Composition

- **Always preceded by:** `validate-rewrite` (Approved verdict required).
- **Composes with:**
  - `superpowers:writing-plans` — single per-pass plan authoring.
  - `superpowers:executing-plans` — single per-pass TDD execution.
  - `delta-coverage-reviewer` agent — end-of-run coverage verification (parallel dispatch).
  - `cohesive:review-diff` — end-of-run substrate alignment (parallel dispatch).
- **Followed by:** `superpowers:finishing-a-development-branch` (Implemented verdict) or repair via `cohesive:rewrite-specs` (Substrate Drift) or repair via re-invocation (Coverage Drift).

## Acceptance criteria

- An Approved validate-rewrite verdict path is in the inputs.
- Step 1 surfaces the delta-entry count when above 15 and pauses for user confirmation; below threshold the gate is invisible.
- Step 1's thin intent paragraph enumerates every non-Deferred delta-ledger entry by stable ID; the format is exactly the three lines specified (Make / Constraints / Acceptance).
- Step 2 invokes `superpowers:executing-plans` against the persisted plan path; implementation commits cite both the plan path and the delta-entry stable IDs.
- Step 3 dispatches `delta-coverage-reviewer` and `cohesive:review-diff` in parallel; both reviewers receive only paths and a quoted ledger excerpt; never a pre-summarized design narrative.
- Step 3 synthesizes the verdict AND-shape per §"Verdict synthesis"; only `Covered + (Pass | Pass with notes)` synthesizes to Implemented.
- Step 3.5 fires on Implemented verdict only and produces a single cleanup commit whose message body lists removed ephemeral paths verbatim. On Coverage Drift / Substrate Drift / Aborted, Step 3.5 does not fire.
- The trailer's `## Branch state` slot surfaces the cleanup commit SHA on Implemented verdict; on other verdicts, the cleanup-commit line is omitted.
- The skill never invokes `superpowers:finishing-a-development-branch` — handoff is a user action.

## What this skill is *not*

- Not a code generator. It writes no code; `superpowers:executing-plans` does that.
- Not a planner. It produces the thin intent paragraph (substrate-shape); `superpowers:writing-plans` produces the plan (TDD-shape).
- Not a substitute for `cohesive:review-diff`. The end-of-run substrate-alignment review is a delegation, not a built-in.
- Not a substitute for branch finishing. `superpowers:finishing-a-development-branch` owns merge mechanics.
- Not a substitute for `validate-rewrite`. The Approved verdict is a prereq, not produced here.
