---
name: implement-cohesively
description: Use after either validate-rewrite has returned Approved on a spec rewrite (standard mode) or rewrite-specs has landed an extension rewrite directly on a branch (extend mode), when the user wants to land code that makes the rewrite true. Drives a single-pass implementation where Cohesive owns the substrate-shaped intent (thin paragraph anchored to the spec diff) and the end-of-run reviewer dispatch — dual (delta-coverage-reviewer + cohesive:review-diff, AND-shape) in standard mode, or solo (cross-mirror-reviewer) in extend mode; Superpowers owns plan writing and TDD execution. Triggers on "implement the approved rewrite", "land docs with implementation", "implement-cohesively", "drive implementation against the rewrite", "ship the rewrite", "extend the existing concept". Always preceded by either validate-rewrite Approved (standard) or rewrite-specs extension commit (extend); always pairs with superpowers:writing-plans and superpowers:executing-plans.
---

# Implement cohesively

## What this skill produces

The skill operates in one of two modes, picked from the inputs:

| Mode | Trigger | Required inputs | End-of-run reviewer dispatch |
|---|---|---|---|
| **standard** | Reached via `implement` route, post-validate-rewrite-Approved | Validation review path (with `**Rewrite-tip:**` SHA) + branch name | Dual: `delta-coverage-reviewer` + `cohesive:review-diff`, AND-shape synthesis |
| **extend** | Reached via `extend` route, post-rewrite-specs-extension | Change-surface description + branch name | Solo: `cross-mirror-reviewer` |

The two modes share most of the body — what differs is the input contract (Step 0), how the spec-diff boundary is established (Step 1), and the end-of-run reviewer dispatch (Step 3). The middle (writing-plans + executing-plans + Step 3.5 cleanup) is identical.

Shared outputs across both modes:

- A **branch with implementation commits** that make every promise in the spec diff true in code, test, and CI.
- A **spec-diff snapshot** at `.cohesive/tmp/<slug>-spec-diff.patch`, captured at Step 1 before any implementation commits land. This is the substrate-shaped source of work.
- A **single per-pass implementation plan** at `docs/cohesive/plans/<YYYY-MM-DD>-<slug>.md`, authored by `superpowers:writing-plans` from a thin intent paragraph the skill composes — committed during the run as **ephemeral run scaffolding**.
- An **end-of-run reviewer dispatch** (dual in standard mode, solo in extend mode — see table above).
- On Implemented verdict only: a **single cleanup commit at Step 3.5** that strips ephemeral artifacts (per-pass plan, spec-diff snapshot, discovery report if present) before handoff. The cleanup commit is the breadcrumb back from main to pre-cleanup branch history.
- A handoff to `superpowers:finishing-a-development-branch` (or repair to the relevant earlier skill) based on the verdict.

This is the second of Cohesive's flagship skills that owns code-producing work indirectly. The skill itself writes no code: it composes with `superpowers:writing-plans` (which authors the plan) and `superpowers:executing-plans` (which writes code with TDD). The Cohesive contribution is the **substrate-shaped framing**: anchoring the implementation intent to the spec diff, surfacing the diff-size budget gate before invocation, and dispatching the appropriate end-of-run reviewer(s) per mode.

## Voice

Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output. The voice guide is the load-bearing source for verdict-leads, header-depth cap, density budgets, and forbidden phrasings; the imperative above is what triggers the model to load it via a Read tool call. Do not reproduce the imperative or any citation to the voice guide inside the Output format render template — instructions placed inside render templates leak verbatim into user-facing output.

## Hard constraints

1. **Required inputs are mode-conditional, declared as paths.** This skill's prereqs are paths, not session state — the canonical clarifying question does not apply. Required inputs differ by mode (see §"What this skill produces"); the dispatching context (the `cohesively` router via the `implement` or `extend` route, a prior `validate-rewrite` Approved render the user is acting on, a prior `rewrite-specs` extension run, or direct user invocation) supplies them explicitly.

   **Standard mode** requires the validation review path (with `**Rewrite-tip:**` SHA) plus the branch name. **Extend mode** requires the change-surface description plus the branch name; Step 0 dispatches `discover-substrate` scoped to the change surface to find sibling sites.

   **If any required input is missing,** stop with a directive error. The directive names the missing input and the upstream skill that produces it. Standard-mode directives:

   ```
   Missing validation review for slug `<slug>`. Run cohesive:validate-rewrite first;
   expected output at docs/cohesive/reviews/<date>-<slug>-rewrite-validation.md
   with a **Rewrite-tip:** SHA header line on Approved verdict.
   ```

   ```
   Missing rewrite branch for slug `<slug>`. Run cohesive:rewrite-specs and
   cohesive:validate-rewrite first; expected branch `design/<slug>` with
   rewrite commits and an Approved validation review.
   ```

   Extend-mode directives:

   ```
   Missing change-surface description for extend mode. Provide one or two
   sentences naming what to extend (e.g., "add HOME to SurfaceRole"), or
   route through cohesive:cohesively which will ask the gate question and
   collect this input.
   ```

   ```
   Missing rewrite branch for extend mode. Run cohesive:rewrite-specs first
   to land the extension commit on `design/<slug>`; expected branch with
   at least one `design: rewrite specs for ...` commit ahead of main.
   ```

   Do not ask the canonical forced-choice question and do not invent paths. Per `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Verdict → severity-floor mapping (validate-rewrite)", `Approved` is the only verdict that unlocks **standard** mode — verify the supplied review's verdict line is `**Verdict:** Approved` before proceeding; on any other verdict, refuse with a pointer to the appropriate upstream skill. Extend mode does not require a validate-rewrite verdict (the route deliberately skips that stage).

2. **Compose with Superpowers; do not reinvent its execution discipline.** This skill invokes `superpowers:writing-plans` once to author the per-pass plan and `superpowers:executing-plans` once to execute it. The skill never authors a TDD-shaped plan directly and never writes code itself. If Superpowers is not installed, the skill stops with a hard error and recommends installation — the inline 5-line worktree fallback in `rewrite-specs` does not apply here, because plan-writing and TDD execution are not 5-line operations.
3. **Single per-pass plan covers the spec diff.** Every promise in the spec diff (standard mode: `git diff $(merge-base main <rewrite-tip>)..<rewrite-tip>` using the SHA from the validation review; extend mode: `git diff $(merge-base main HEAD)..<rewrite-tip-commit>` where `<rewrite-tip-commit>` is the most recent `design: rewrite specs` commit on the branch) is covered by the single plan authored from the thin intent paragraph. Step 1 hands the spec diff to `writing-plans` as the work to do; an uncovered promise is a substrate violation the end-of-run reviewer will flag.
4. **End-of-run reviewer dispatch is mandatory and mode-conditional.** Standard mode dispatches `delta-coverage-reviewer` (Task subprocess, paths-only inputs, fresh eyes, spec-diff-vs-implementation-diff input contract) and `cohesive:review-diff` (Cohesive skill, substrate alignment scope) in parallel; verdict synthesized AND-shape. Extend mode dispatches `cross-mirror-reviewer` solo (Task subprocess, paths-only inputs, fresh eyes, sibling-site + extension-shape input contract); its verdict is the run's verdict directly. Skipping the dispatch in either mode is a violation. See §"Verdict synthesis" below.
5. **Step 3.5 cleanup is gated on Implemented verdict.** On Implemented (standard: dual Pass; extend: Covered), Step 3.5 strips ephemeral artifacts (per-pass plan, spec-diff snapshot, discovery report when present) via a single cleanup commit before handoff. On Coverage Drift / Substrate Drift / Aborted, Step 3.5 does not fire — ephemeral artifacts remain on the branch for the next attempt or post-mortem. The cleanup commit's body lists removed paths verbatim; a cleanup commit without that list is a violation. See §"Step 3.5. Post-implementation cleanup" for operational steps.
6. **Diff-size budget gate fires above threshold.** Step 1 surfaces the spec-diff changed-line count before invoking `superpowers:writing-plans`. When the count exceeds **1000** (default; tunable in a follow-up substrate change), the skill pauses for user confirmation. The gate is the structural mitigation for mega-plan abandonment risk. Below threshold the gate is invisible; above threshold, skipping the surfacing or invoking `writing-plans` without confirmation is a violation. Applies in both modes.

## Process

The skill body uses `Step 0` and `Step 4` for preflight and handoff bookends, `Step 1` / `Step 2` / `Step 3` for the three structural steps the named invariant `IMPLEMENTATION_COVERS_SPEC_DIFF` references, and `Step 3.5` for the ephemeral-cleanup step inserted between Step 3 and Step 4. Citations to "Step 1" / "Step 2" / "Step 3" / "Step 3.5" elsewhere in the substrate (the invariant, anti-patterns, acceptance criteria) refer to the headings in this section by exactly those labels.

### Step 0. Resolve inputs and confirm prereqs

The first action of Step 0 is **mode detection**: standard or extend.

- **Mode detection rule.** If the inputs include a validation review path, mode is standard. Else if the inputs include a change-surface description, mode is extend. If neither (or both), halt with a directive error asking the user to specify (per Hard constraint #1).

The rest of Step 0 then branches on mode:

**Standard mode inputs:**

- **Validate-rewrite Approved verdict path** — usually `docs/cohesive/reviews/YYYY-MM-DD-<slug>-rewrite-validation.md`. The skill verifies the verdict is `Approved` and parses the `**Rewrite-tip:**` SHA from the header.
- **Branch name** — typically `design/<slug>` from the rewrite worktree. Implementation lands on this branch (or a child branch — see §"Branch shape" below).
- **Substrate discovery report path** (optional) — passed to the end-of-run reviewers for context.

**Standard-mode verification:** Verify the rewrite-tip SHA exists in branch history via `git cat-file -e <SHA>`. On missing (e.g., the branch was rebased after Approved), halt with a directive error:

```
Rewrite tip SHA `<X>` not found on branch `design/<slug>`.
The branch was likely rebased or rewritten after validate-rewrite Approved.
Re-run cohesive:validate-rewrite to capture a fresh rewrite-tip SHA.
```

**Extend mode inputs:**

- **Change-surface description** — one or two sentences naming what to extend (e.g., "add HOME to SurfaceRole"). This is what the `extend` route's dispatch contract supplies.
- **Branch name** — typically `design/<slug>` from the rewrite worktree (the extension rewrite already landed via `rewrite-specs`).

**Extend-mode discovery dispatch:** Dispatch `cohesive:discover-substrate` via the Skill tool, scoped to the change surface, to enumerate sibling sites (everywhere the existing concept is referenced, pattern-matched, or enumerated). The dispatch prompt names the change surface and instructs discovery to focus on the locations a future implementer would need to update. Capture the discovery report path returned — it is an input to Step 1's intent paragraph and to the end-of-run reviewer dispatch.

**Extend-mode verification:** Verify the branch has at least one `design: rewrite specs for ...` commit ahead of `main` via `git log main..HEAD --grep="^design: rewrite specs" -n 1 --format=%H` returning non-empty. Capture this SHA as the **rewrite-tip commit** for Step 1. On missing, halt with the extend-mode directive error per Hard constraint #1.

If any other required input is missing, halt with the directive error per Hard constraint #1; do not ask the canonical forced-choice question and do not invent paths.

### Step 1. Capture the spec diff and dispatch writing-plans

Capture the spec diff to a tmp file. The capture command differs by mode:

**Standard mode** uses the rewrite-tip SHA parsed at Step 0:

```bash
REWRITE_TIP=<SHA from validation review file>
mkdir -p .cohesive/tmp
git diff $(git merge-base main $REWRITE_TIP)..$REWRITE_TIP > .cohesive/tmp/<slug>-spec-diff.patch
```

**Extend mode** uses the rewrite-tip commit captured at Step 0 (the latest `design: rewrite specs` commit on the branch):

```bash
REWRITE_TIP=<SHA from Step 0's git log lookup>
mkdir -p .cohesive/tmp
git diff $(git merge-base main $REWRITE_TIP)..$REWRITE_TIP > .cohesive/tmp/<slug>-spec-diff.patch
```

In both modes the spec diff is anchored to a stable SHA, not to "HEAD at invocation time" — this makes Coverage Drift retries and interrupted runs handle cleanly (same SHA → same spec diff, even after partial implementation commits land).

Surface the **diff-size budget gate** before composing the intent. Count changed lines via `wc -l < .cohesive/tmp/<slug>-spec-diff.patch`:

- If the changed-line count is at or below **1000**, proceed silently to intent composition.
- If above 1000, render the budget surfacing in chat and pause for user confirmation:

   ```
   This spec diff has <N> changed lines. Single-pass implementation produces one large plan;
   executing-plans runs may abandon on context overflow. Confirm to proceed, or run
   cohesive:rewrite-specs to split the rewrite into smaller pieces first.
   ```

  On confirm: proceed. On abort: exit with `Aborted` verdict and recommend scope reduction via `cohesive:rewrite-specs`. The 1000-line threshold is a v0.1 default; tighten or relax in a follow-up substrate change as real-world rewrite sizes inform the budget.

After the gate clears, compose the **thin intent paragraph** and pass it to `superpowers:writing-plans` via the Skill tool. The format differs by mode:

**Standard mode** — three lines:

```
Make this spec diff true in code: .cohesive/tmp/<slug>-spec-diff.patch.
Constraints: <named invariants the docs cite; reference by INVARIANT_NAME>.
Acceptance: cohesive:implement-cohesively dispatches delta-coverage-reviewer (verifies every spec-diff promise is delivered) and cohesive:review-diff (verifies substrate alignment with the rewritten specs) at end-of-run; both must Pass.
```

**Extend mode** — three lines, with sibling sites surfaced from the discovery report:

```
Make this spec diff true in code: .cohesive/tmp/<slug>-spec-diff.patch.
Sibling sites to update (from discovery): <bulleted list of file:line refs from the discovery report at <path>>.
Acceptance: cohesive:implement-cohesively dispatches cross-mirror-reviewer at end-of-run; it returns Covered (all sibling sites updated + diff stays within extension shape), Sites Missing (close the gaps and re-run), or Bigger than extension (the change went beyond extension; re-route).
```

The intent paragraph is the substrate-shape→TDD-shape seam. `writing-plans` reads the spec diff and produces the TDD-shape plan; the intent paragraph names what the plan must accomplish in substrate terms. Capture the plan path that `writing-plans` returns (`docs/cohesive/plans/<YYYY-MM-DD>-<slug>.md`); it is an input to the end-of-run reviewer dispatch.

### Step 2. Execute the plan

Invoke `superpowers:executing-plans` via the Skill tool with the persisted plan path. Superpowers owns TDD discipline inside this step: failing test first, minimal implementation, refactor. The skill does not interleave; it waits for the implementation commits to land on the branch.

Implementation commits cite the plan path they implement. The commit-message convention `executing-plans` produces should include that citation; if it does not, the skill body's Hard constraint #3 plus the named invariant `IMPLEMENTATION_COVERS_SPEC_DIFF` govern the citation requirement.

### Step 3. End-of-run reviewer dispatch

After the last implementation commit lands, dispatch the appropriate reviewer(s) for the mode.

**Standard mode — dual dispatch in parallel:**

- **`delta-coverage-reviewer`** (Task subprocess) with `subagent_type: delta-coverage-reviewer`. The dispatch prompt names: the spec-diff patch path (`.cohesive/tmp/<slug>-spec-diff.patch` captured at Step 1), the per-pass plan path, the branch name, and the rewrite-tip SHA (so the reviewer can compute the implementation diff = `git diff <rewrite-tip>..<branch-tip>`). The reviewer compares spec-diff vs implementation-diff and returns one of three verdicts: **Covered** / **Drift** / **Incomplete**. Persist the reviewer's output at `docs/cohesive/reviews/<YYYY-MM-DD>-<slug>-coverage-review.md`.

- **`cohesive:review-diff`** (Skill tool dispatch) scoped to the branch with the validation review path (carrying the rewrite-tip SHA) passed as additional context. The skill dispatches its own reviewer agents (substrate-alignment + structure) per its Process. The verdict is one of: **Pass** / **Pass with notes** / **Needs substrate** / **Risky** / **Block**. The persisted review lives at `docs/cohesive/reviews/<YYYY-MM-DD>-<slug>-final-substrate-review.md`.

Both dispatches happen in the same turn (the harness's parallel-tool-call pattern). Wait for both to complete before synthesizing the verdict.

**Extend mode — solo dispatch:**

- **`cross-mirror-reviewer`** (Task subprocess) with `subagent_type: cross-mirror-reviewer`. The dispatch prompt names: the spec-diff patch path (captured at Step 1), the per-pass plan path, the branch name, the rewrite-tip SHA (for computing the implementation diff), the substrate discovery report path (the sibling-site list from Step 0), and the change-surface description. The reviewer compares each sibling site to the implementation diff and checks whether the diff stays within extension shape. It returns one of three verdicts: **Covered** / **Sites Missing** / **Bigger than extension**. Persist the reviewer's output at `docs/cohesive/reviews/<YYYY-MM-DD>-<slug>-cross-mirror-review.md`.

The extend-mode dispatch is one Task call; the reviewer's verdict is the run's verdict directly (no AND-shape synthesis).

### Verdict synthesis

Internal verdict mapping differs by mode but the external vocabulary (`Implemented` / `Coverage Drift` / `Substrate Drift` / `Aborted`) is unified.

**Standard-mode synthesis (AND-shape from the dual reviewers):**

| `delta-coverage-reviewer` | `cohesive:review-diff` | Internal verdict |
|---|---|---|
| Covered | Pass / Pass with notes | **Implemented** |
| Drift / Incomplete | Pass / Pass with notes | **Coverage Drift** |
| Covered | Needs substrate / Risky / Block | **Substrate Drift** |
| Drift / Incomplete | Needs substrate / Risky / Block | **Substrate Drift** (wins on dual-fail; the rewrite was misformulated, which makes coverage gaps downstream) |
| (not dispatched) | (not dispatched) | **Aborted** (Step 3 did not run — the user paused before reviewers dispatched, e.g., declined the budget gate or stopped during Step 2) |

**Extend-mode synthesis (direct from cross-mirror-reviewer's verdict):**

| `cross-mirror-reviewer` | Internal verdict |
|---|---|
| Covered | **Implemented** |
| Sites Missing | **Coverage Drift** |
| Bigger than extension | **Substrate Drift** (the diff went beyond extension shape; the change should be re-routed through the heavy path with `cohesive:rewrite-specs` + `cohesive:validate-rewrite`) |
| (not dispatched) | **Aborted** (Step 3 did not run) |

The internal verdict translates to the user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"implement-cohesively". Render the chat trailer per §"Output format" below; persist the synthesis (which reviewer flagged what) in the trailer's `## End-of-run review` body block. Aborted does not run reviewers and does not fire Step 3.5.

### Step 3.5. Post-implementation cleanup

Fires **only on Implemented verdict**. On any other verdict, skip directly to Step 4 — ephemeral artifacts remain on the branch for the next attempt or post-mortem.

`git rm` (or `rm` for untracked files) the ephemeral paths for this slug — currently `docs/cohesive/plans/<YYYY-MM-DD>-<slug>.md`, `.cohesive/tmp/<slug>-spec-diff.patch`, and `docs/cohesive/discovery/<slug>.md` if present — and produce a single commit whose body lists the removed paths verbatim:

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

The skill renders the centralized chat trailer per `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md`. The chat render is the decision-rendering of what landed per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2a (with sub-rules 2b / 2c).

**Verdict translation.** The internal verdict (`Implemented` / `Coverage Drift` / `Substrate Drift` / `Aborted`) renders in the chat trailer as the user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"implement-cohesively". The user-facing label preserves the internal token so dispatch grep targets still resolve.

**Body block specification.** Per the §"Variants" `implement-cohesively` row of the centralized template: a `## Code matches locked design` slot leads (synthesized AND-shape from the dual reviewer dispatch — this is the **build→done verification** the user reads first), followed by `## End-of-run review` block surfacing both reviewer verdicts with paths to their persisted outputs, and `## Branch state` (branch + implementation commit count + plan path). Long-form review detail lives in the persisted reviewer output files, not chat. Render only non-empty sections per the chat-trailer template's §"Render-only-non-empty rule"; the per-section conditions are enumerated in the §"Render-conditional rules for the body block" subsection below.

**Render-conditional rules for the body block.** The render template below is the agent's literal output template; it does not carry meta-instructions or comments inline (instructions inside render templates leak into user-facing output). The render conditions live here, in prose, instead:

- **`## Code matches locked design`** — the spec-coverage slot. Render exactly one of three shapes, matching the internal verdict:
  - **Internal `Implemented`** (Covered + Pass / Pass with notes) — render `**Code matches locked design:** ✓` and omit the divergent-items list.
  - **Internal `Coverage Drift` or `Substrate Drift`** — render `**Drift detected:** ✗ <count> places` followed by a bulleted list of divergent items (file:line + what's divergent), aggregated from both reviewer outputs.
  - **Internal `Aborted`** (the user paused before Step 3 ran) — omit both lines and the divergent-items list; the slot collapses to its header. The Branch state section below carries the partial state.
- **`## End-of-run review`** — renders on Implemented / Coverage Drift / Substrate Drift only. Two bullets, one per reviewer, each naming the reviewer verdict and the path to its persisted output. Omitted on Aborted (Step 3 did not run).
- **`## Branch state`** — always renders. On Implemented verdict, includes the cleanup commit SHA on a `Cleanup commit:` line so the user can reference the pre-cleanup boundary for forensic recovery via `git log --all -- docs/cohesive/plans/<slug>.md`. On Coverage Drift / Substrate Drift / Aborted, the cleanup-commit line is omitted (Step 3.5 did not fire).
- **`### Next`** — renders one bullet, matching the internal verdict. The four `Internal <verdict>:` shapes below show the four possible renders; the chat trailer carries exactly one. This implements the per-verdict-branch recommendation rule in the chat-trailer template's §"How `### Next` carries payload" — the payload is the matching bullet, not the full set.

```md
# Implementation Complete — <topic>

**Verdict:** <user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"implement-cohesively" — e.g., **Implementation complete** / **Coverage gap — re-run to fill** / **Implementation went beyond the design** / **Implementation paused**>

**Thesis:** <one or two sentences — what landed and what it means, in decision-shape>

## Code matches locked design

<one of the three shapes per the prose rules above; omit the slot's content entirely on Aborted>

## End-of-run review

*(Standard mode renders both rows; extend mode renders only the cross-mirror row.)*

- Coverage: <Covered | Drift | Incomplete> — `docs/cohesive/reviews/<YYYY-MM-DD>-<slug>-coverage-review.md` *(standard mode only)*
- Substrate: <Pass | Pass with notes | Needs substrate | Risky | Block> — `docs/cohesive/reviews/<YYYY-MM-DD>-<slug>-final-substrate-review.md` *(standard mode only)*
- Cross-mirror: <Covered | Sites Missing | Bigger than extension> — `docs/cohesive/reviews/<YYYY-MM-DD>-<slug>-cross-mirror-review.md` *(extend mode only)*

## Branch state

- Branch: `design/<slug>`
- Implementation commits: <count>
- Plan: `docs/cohesive/plans/<YYYY-MM-DD>-<slug>.md` (committed during the run at `docs/cohesive/plans/`)
- Cleanup commit: `<SHA>` *(rendered only on Implemented verdict; SHA points at the Step 3.5 commit that stripped ephemeral artifacts)*

### Next

<one decision-shaped bullet, matching the internal verdict — the four shapes are enumerated below; the chat trailer renders exactly one>
```

The four `### Next` bullet shapes (one renders per invocation, matching the internal verdict):

- **Internal `Implemented`:** Substrate and code agree; ready to ship. *(`superpowers:finishing-a-development-branch`.)* **Scope:** the `design/<slug>` branch.
- **Internal `Coverage Drift`:** Repair the named coverage gaps, then re-invoke. *(`cohesive:implement-cohesively` resume.)* **Scope:** the spec-diff hunks the coverage reviewer flagged as Drift / Incomplete.
- **Internal `Substrate Drift`:** Extend the design to cover what the implementation introduced, or revert the divergent code. *(`cohesive:rewrite-specs`.)* **Files to edit:** <enumerate the docs the substrate review flagged as needing extension>. Slug: `<derived-from-original-slug>-extension`. *(Extend mode: this verdict means the change was misclassified as extension and went beyond extension shape. Re-route through `cohesive:cohesively` and pick "Introducing a new concept" at the change-type gate, OR revert the divergent code and keep the change as a pure extension.)*
- **Internal `Aborted`:** Implementation paused at user request. *(No follow-up skill required.)* The branch state is whatever the last implementation commit landed.

## Anti-patterns (Red Flags)

| Anti-pattern | Why it's wrong | Fix |
|---|---|---|
| Skipping `superpowers:writing-plans` to "save tokens" | Collapses the substrate-shape→TDD-shape seam; the end-of-run coverage reviewer cannot distinguish "plan didn't cover spec-diff promise" from "implementation didn't execute plan" | Always invoke `writing-plans`; the per-pass plan is the inspectable bridge artifact |
| Authoring TDD-shaped tasks directly from the spec diff | Reinvents `superpowers:writing-plans`; defeats the composition seam | Pass the thin intent paragraph (which references the spec-diff patch path) to `writing-plans`; let it produce TDD shape |
| Producing code from this skill body | The skill orchestrates; it never writes code itself | All code-writing happens inside `superpowers:executing-plans` |
| Skipping or sequencing the dual reviewer dispatch | The dual reviewer pair is the substrate-side enforcement of `IMPLEMENTATION_COVERS_SPEC_DIFF`; running only one or running them sequentially defeats the parallel-fresh-eyes design | Dispatch both reviewers in parallel per Hard constraint #4; wait for both before synthesizing |
| Substituting `cohesive:review-diff`'s coverage check for the dedicated `delta-coverage-reviewer` | Folds two distinct concerns (substrate alignment vs delta coverage) into one prompt; one lens crowds out the other under token pressure | Keep the reviewers separate; the AND-shape synthesis at §"Verdict synthesis" combines them |
| Ignoring the diff-size budget gate above threshold | The gate is the structural mitigation for mega-plan abandonment; bypassing it makes abandonment silent | Surface the changed-line count and pause for confirmation per Step 1; honor abort as `Aborted` verdict |
| Recomputing the spec diff at invocation time instead of using the rewrite-tip SHA | Diff drifts as implementation commits land; Coverage Drift retries become impossible | Step 1 anchors the spec diff to the SHA captured in the validation review file, not to HEAD |
| Auto-invoking `superpowers:finishing-a-development-branch` | Branch finishing is a user action per Cohesive↔Superpowers seam | Recommend; do not invoke |
| Pre-summarizing the design for the dispatched reviewers | Bypasses fresh-eyes | Pass paths only; never summarize the rewrite for the agent |
| Step 3.5 mishandling | Cleanup fires on a non-Implemented verdict (strips artifacts load-bearing for the next attempt), skips on Implemented (run scaffolding leaks into main), produces a commit without a verbatim removed-paths body (forensic breadcrumb is lost), or strips durable artifacts (decision records become unrecoverable) | Hard constraint #5 enumerates all four sub-conditions |

## Branch shape

The implementation lands on the same `design/<slug>` branch the rewrite produced. The rewrite commit and the implementation commits live on one branch, in commit order. This is what "land docs with implementation" means in practice: the merge brings spec and code together. If the rewrite commit was already merged separately, the implementation lands on a fresh `implement/<slug>` branch off the merge — but the default is one-branch-end-to-end.

## Composition

- **Preceded by (mode-conditional):**
  - *Standard mode:* `validate-rewrite` (Approved verdict required).
  - *Extend mode:* `rewrite-specs` (extension rewrite committed on `design/<slug>`); validate-rewrite is deliberately skipped per the `extend` route's design.
- **Composes with:**
  - `superpowers:writing-plans` — single per-pass plan authoring (both modes).
  - `superpowers:executing-plans` — single per-pass TDD execution (both modes).
  - `delta-coverage-reviewer` agent — end-of-run coverage verification (standard mode only).
  - `cohesive:review-diff` — end-of-run substrate alignment (standard mode only).
  - `cross-mirror-reviewer` agent — end-of-run sibling-site + extension-shape verification (extend mode only).
  - `cohesive:discover-substrate` — scoped sibling-site enumeration at Step 0 (extend mode only).
- **Followed by:** `superpowers:finishing-a-development-branch` (Implemented verdict) or repair via `cohesive:rewrite-specs` (Substrate Drift) or repair via re-invocation (Coverage Drift).

## Acceptance criteria

- Step 0 detects mode (standard if validation review path supplied; extend if change-surface description supplied; halts otherwise).
- *Standard mode:* an Approved validate-rewrite verdict path is in the inputs; Step 0 parses the `**Rewrite-tip:**` SHA from the validation review file and verifies it exists in branch history via `git cat-file -e`.
- *Extend mode:* a change-surface description is in the inputs; Step 0 dispatches `cohesive:discover-substrate` scoped to the change surface; Step 0 captures the rewrite-tip commit SHA from `git log main..HEAD --grep="^design: rewrite specs"`.
- Step 1 captures the spec diff at the rewrite-tip SHA into `.cohesive/tmp/<slug>-spec-diff.patch`; surfaces the changed-line count when above 1000 and pauses for user confirmation; below threshold the gate is invisible (both modes).
- Step 1's thin intent paragraph references the spec-diff patch path; the format is exactly the three lines specified per mode (standard: Make / Constraints / Acceptance; extend: Make / Sibling sites / Acceptance).
- Step 2 invokes `superpowers:executing-plans` against the persisted plan path; implementation commits cite the plan path (both modes).
- *Standard mode Step 3:* dispatches `delta-coverage-reviewer` and `cohesive:review-diff` in parallel; both reviewers receive only paths (spec-diff patch, branch name, rewrite-tip SHA); never a pre-summarized design narrative.
- *Extend mode Step 3:* dispatches `cross-mirror-reviewer` solo; the reviewer receives only paths (spec-diff patch, plan path, branch name, rewrite-tip SHA, discovery report path, change-surface description); never a pre-summarized design narrative.
- *Standard mode:* Step 3 synthesizes the verdict AND-shape per §"Verdict synthesis"; only `Covered + (Pass | Pass with notes)` synthesizes to Implemented.
- *Extend mode:* Step 3's verdict is the cross-mirror-reviewer's verdict directly (Covered → Implemented, Sites Missing → Coverage Drift, Bigger than extension → Substrate Drift).
- Step 3.5 fires on Implemented verdict only (both modes) and produces a single cleanup commit whose message body lists removed ephemeral paths verbatim. On Coverage Drift / Substrate Drift / Aborted, Step 3.5 does not fire.
- The trailer's `## Branch state` slot surfaces the cleanup commit SHA on Implemented verdict; on other verdicts, the cleanup-commit line is omitted.
- The skill never invokes `superpowers:finishing-a-development-branch` — handoff is a user action.

## What this skill is *not*

- Not a code generator. It writes no code; `superpowers:executing-plans` does that.
- Not a planner. It produces the thin intent paragraph (substrate-shape); `superpowers:writing-plans` produces the plan (TDD-shape).
- Not a substitute for `cohesive:review-diff`. The end-of-run substrate-alignment review is a delegation, not a built-in.
- Not a substitute for branch finishing. `superpowers:finishing-a-development-branch` owns merge mechanics.
- Not a substitute for `validate-rewrite`. The Approved verdict is a prereq, not produced here.
