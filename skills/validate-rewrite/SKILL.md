---
name: validate-rewrite
description: Use after rewrite-specs has produced a spec rewrite and a design delta ledger, before implementation. Runs a fresh-eyes review of rewritten docs/specs in a separate agent context that did not participate in the design discussion. Judges whether the new design is internally coherent, behaviorally complete, enforceable, and aligned with the system's stated future direction. Triggers on "validate the rewrite", "review the spec rewrite", "fresh-eyes review of the new design docs", "is the rewrite ready for implementation", "check the spec cohesion". Returns Approved / Issues Found / Design Incoherent.
---

# Validate rewrite

## What this skill produces

A **rewrite validation report** in chat, written by default to `docs/history/reviews/YYYY-MM-DD-<slug>-rewrite-validation[-pass-N].md` (use `--no-write` to suppress persistence). The verdict vocabulary is {**Approved**, **Issues Found**, **Design Incoherent**} — the same three verdicts each pass's reviewer returns. On `Issues Found`, the skill drives an internal repair loop with `cohesive:rewrite-specs` and re-dispatches the reviewer until verdict converges (Approved), exits to design (Design Incoherent), or hits a **max-passes stall** — a *loop-exit shape* that surfaces the latest pass's Issues Found verdict to the user with a stall banner, after `MAX_REPAIR_PASSES` iterations without convergence. The stall is not a fourth verdict; it is the only legible surface through which Issues Found reaches the user, since the loop normally drives Issues Found internally. The user does not invoke `rewrite-specs` themselves during the loop. Each pass's review is persisted independently for audit trail.

The review's defining property is **fresh eyes**: this skill always dispatches the `spec-cohesion-reviewer` agent via the Task tool, which runs in an isolated subprocess with no inherited conversation context. The structural fence is the harness's Task-subprocess isolation — that's what gives the review the power to flag things the original designer can no longer see, regardless of whether this skill is invoked from the same conversation that produced the rewrite. The fresh-eyes property holds **per pass** of the repair loop; pass-N's reviewer is dispatched with paths only and never inherits pass-(N-1)'s review or the loop's conversation context.

## Voice

Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output. The voice guide is the load-bearing source for verdict-leads, header-depth cap, density budgets, and forbidden phrasings; the imperative above is what triggers the model to load it via a Read tool call. Do not reproduce the imperative or any citation to the voice guide inside the Output format render template — instructions placed inside render templates leak verbatim into user-facing output (the failure mode `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` documents).

## Hard constraints

1. **Always dispatch the `spec-cohesion-reviewer` agent via Task tool.** The skill itself never renders the verdict from in-conversation reading — it dispatches and surfaces the agent's report. The Task subprocess provides the structural fresh-eyes fence; this skill's job is the dispatch and the synthesis. This applies **per pass** of the repair loop, not just on the first pass.
2. **Inputs must be paths, not summaries.** Pass the agent file paths to read; don't pre-summarize the design for it. The dispatch prompt's content is the entire context the agent has, so any summary the dispatching skill writes into it bypasses fresh-eyes — the harness fence prevents conversation inheritance, but it can't prevent prompt contamination. This applies per pass: the pass-N reviewer is dispatched with paths only, never with the pass-(N-1) review as context.
3. **The review can block implementation.** Verdicts gate implementation per the verdict→severity-floor mapping in `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Verdict → severity-floor mapping (validate-rewrite)": `Issues Found` (highest severity High or Blocker) drives the internal repair loop (Hard constraint #4), and `Design Incoherent` exits the loop and routes to `brainstorm-design`. `Approved` (highest severity Medium, Low, or none) terminates the loop and unlocks the implementation route; the user picks among the rows of the implementation decision matrix in the Output format block, and the disposition rule in the rubric specifies what (if anything) to close before merge.
4. **The Issues Found repair loop runs internally.** When the reviewer returns `Issues Found`, the skill dispatches `cohesive:rewrite-specs` in repair mode via the Skill tool, then re-dispatches `spec-cohesion-reviewer` for the next pass — up to `MAX_REPAIR_PASSES` (default 5). The user does not invoke `rewrite-specs` themselves except after a max-passes stall or a Design Incoherent exit. Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` §"validate-rewrite ↔ rewrite-specs (Issues Found internal repair loop)", the loop terminates on Approved, Design Incoherent, or max-passes; do not loop past the ceiling, and do not auto-pivot to `brainstorm-design` on max-passes (that is a user decision).

## Process

### 0. Resolve the artifact directory

Before dispatching the reviewer agent, resolve where the validation report will be persisted. Apply the four-rule resolution from `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md` §"Artifact directory resolution" with artifact category `reviews/`:

1. If `docs/history/reviews/` exists, write there.
2. Else if the repo carries `docs/adr/`, `docs/specs/`, `docs/design/`, `docs/decisions/`, or `docs/architecture/`, write to a `reviews/` subdir alongside it.
3. Else default to `docs/cohesive/reviews/`.
4. If `docs/` does not exist, still default to `docs/cohesive/reviews/`.

Announce the resolved path in chat before the dispatch. If `--no-write` is set, skip resolution and render the report in chat only.

### 1. Locate the inputs

Required inputs the calling user or skill must provide:

- **Design delta ledger path** — usually `docs/history/delta-ledgers/YYYY-MM-DD-<slug>.md`. **Required path prereq.**
- **Rewritten spec paths** — derived from the delta ledger's "Files rewritten" / "Files added" sections. Not a separate input; the ledger is the source.
- **Approved direction summary** — one or two sentences carried in the dispatch prompt (router or repair-loop) or in the user's invocation. Optional in repair-loop dispatches, where the source review's `## Delta at a glance` preamble carries the equivalent.
- **Substrate discovery report path** (optional) — if `discover-substrate` ran earlier, pass its output path so the reviewer can compare what existed before to what now exists.

This skill's required prereq is a file path (the delta ledger), not session state — the canonical clarifying question per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md` does not apply. If the delta ledger path is missing, **stop with a directive error** per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Path prereqs use directive errors, not the canonical question":

```
Missing design delta ledger for slug `<slug>`. Run cohesive:rewrite-specs first;
expected output at docs/history/delta-ledgers/<date>-<slug>.md.
```

Do not invent paths and do not ask the canonical question. The per-handoff input contract is in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` §"rewrite-specs → validate-rewrite".

### 2. Dispatch the spec-cohesion-reviewer agent

Use the Task tool with `subagent_type: spec-cohesion-reviewer`. Pass a prompt with this shape:

```
You are reviewing a spec rewrite. Your inputs are file paths only — do not assume any prior conversation context exists.

**Approved direction:** <one or two sentences>

**Design delta ledger:** <path>

**Rewritten specs to review:**
- <path>
- <path>
- ...

**New specs added:**
- <path>
- ...

**Substrate discovery (for context):** <path or "n/a">

Read all of the above. Return a Rewrite Validation Review using the format in
${CLAUDE_PLUGIN_ROOT}/references/templates/cohesion-review.md.

Verdicts: Approved | Issues Found | Design Incoherent.

Do not read any file not listed above unless the design delta ledger explicitly references it. Do not run code, tests, or git commands. Your job is judgment of the rewritten specs.
```

Run the agent in the foreground — its result is what this skill returns.

### 3. Persist the per-pass review and branch on verdict

When the agent returns, persist its report at `docs/history/reviews/YYYY-MM-DD-<slug>-rewrite-validation[-pass-N].md` (omit `-pass-N` for pass 1; subsequent passes carry `-pass-2`, `-pass-3`, etc.). Reviews are append-only history per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md` — commit each pass with a message of the form `review: persist pass-N review (<verdict>)`.

If the user passed `--no-write`, render in chat only and skip persistence. The router's dispatch prompt for the `design` route step 4 and the `rewrite-only` route step 2 includes the ledger path; persistence is the default in both router-driven and direct-invocation cases.

Then branch on verdict:

- **Approved** → proceed to Step 5 (terminal render). The loop terminates here.
- **Issues Found** → proceed to Step 4 (repair loop). Do not render the terminal disposition yet.
- **Design Incoherent** → proceed to Step 5 (terminal render). The loop terminates here; the design itself needs to be reconsidered.

### 4. Repair loop (Issues Found only)

The repair loop runs internally per Hard constraint #4. Default ceiling: `MAX_REPAIR_PASSES = 5` (override via `--max-passes=N`). The loop body:

1. **Render pass progress in chat.** One sentence: `Pass <N>/<MAX>: Issues Found — <count> findings (Blocker: <b>, High: <h>, Medium: <m>). Dispatching repair…`. This is the only progress line per pass; the user can interrupt at any point and the worktree state is whatever the last completed pass committed.
2. **Dispatch `cohesive:rewrite-specs` in repair mode** via the Skill tool. The dispatch prompt names the just-persisted pass-N review path as the repair source and instructs repair-mode operation per `${CLAUDE_PLUGIN_ROOT}/skills/rewrite-specs/SKILL.md` §"Process Step 1b. Repair-pass mode". The dispatch prompt **must** state, explicitly: (a) the repair scope is the enumerated repairs in the cited review, not a fresh design pass; (b) the chosen direction must not be re-derived — if the dispatched skill concludes the design itself is unsound, that is a Design Incoherent signal that the next pass's reviewer should surface, not a verdict the dispatched `rewrite-specs` renders directly; (c) repair commits land on the same `design/<slug>` branch and follow the repair-mode commit template in `${CLAUDE_PLUGIN_ROOT}/skills/rewrite-specs/SKILL.md` §"Step 6. Commit the rewrite". The reviewer-agent dispatch protocol in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/dispatch-protocol.md` covers skill→agent dispatches; it does not cover the skill→skill dispatch this substep performs, so the constraints above are stated inline. Wait for `rewrite-specs` to return — it will land repair commits on the `design/<slug>` branch.
3. **Increment the pass counter and re-dispatch `spec-cohesion-reviewer`** per Step 2. The dispatch is a fresh Task subprocess with paths-only input — never pass the prior pass's review or the loop's conversation context to the new reviewer (Hard constraints #1 and #2 apply per pass).
4. **Persist the new pass's review** per Step 3 and re-branch on verdict:
   - Approved → exit loop; proceed to Step 5.
   - Design Incoherent → exit loop; proceed to Step 5.
   - Issues Found and pass count `< MAX_REPAIR_PASSES` → return to substep 1 (next pass).
   - Issues Found and pass count `== MAX_REPAIR_PASSES` → exit loop with **max-passes stall**; proceed to Step 5 with the stall banner.

The loop never auto-pivots from Issues Found to `brainstorm-design`. That decision is the user's, surfaced after a max-passes stall.

### 5. Render the terminal verdict and recommend the next step

Render the latest persisted review in chat per the Output format below. The recommendation is determined by the **disposition rule** in `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Disposition rule for validation-review findings", which is the canonical home — this skill cites it rather than restate the table. The rule maps `(verdict, highest-severity-present)` to a single recommendation; the skill does not render a menu of options for the user to pick from.

Two-step render for the **Approved** branch (which the rubric's verdict-floor mapping guarantees is merge-ready):

1. **Disposition recommendation** — one phrase derived from the rubric table: `Merge as-is — no findings` (Approved + none), `Close inline (≤2 lines per finding) → merge` (Approved + Low), or `Close in same worktree → merge` (Approved + Medium).
2. **Implementation decision matrix** — render unconditionally for Approved. The verdict-floor mapping ensures `High` and `Blocker` findings produce `Issues Found`, not `Approved`, so an Approved verdict always reaches the matrix.

For **Design Incoherent**, the disposition rule's recommendation is the entire next step — no implementation matrix renders. `Return to brainstorm-design`.

For **max-passes stall** (terminal verdict is still Issues Found), render the latest pass's findings followed by a stall banner:

```
Reached max repair passes (<N>); latest verdict: Issues Found.
Latest pass review: <path>
The rewrite has not converged — the underlying design may be unsound.
Recommended next: cohesive:brainstorm-design (revisit the chosen direction),
or manual repair followed by re-invocation of cohesive:validate-rewrite.
```

The stall banner is the only verdict-output shape that surfaces `Issues Found` to the user, because the loop normally drives Issues Found internally to convergence.

## Output format

The skill's chat output (the agent's report, surfaced):

```md
# Rewrite Validation Review — <topic>

**Verdict:** Approved / Issues Found / Design Incoherent

## Executive judgment
<one paragraph>

## Delta at a glance
<verbatim quote of the ledger's `## Delta at a glance` preamble per the consumer rendering rules in `${CLAUDE_PLUGIN_ROOT}/references/templates/design-delta-ledger.md` §"Delta at a glance" (which is the canonical home of the category list, authoring rules, and consumer rendering rules including missing-preamble and divergence handling). This section appears across all three verdicts (Approved / Issues Found / Design Incoherent), not just Approved — Issues Found and Design Incoherent readers also need decision-time context for whether to repair the rewrite or revisit `brainstorm-design`.>

## Blocking issues
### B1. <title>
<canonical six-field finding shape per `${CLAUDE_PLUGIN_ROOT}/references/templates/cohesion-review.md` §"Blocking issues" and `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md` §"Output format conventions": Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact to add or update>

## Important issues
...

## Substrate gaps
...

## Locality concerns
...

## Future-fit concerns
...

## Enforcement concerns
...

## Behavior knowable outside implementation?
<one paragraph: yes / partially / no, with the surfaces that fall short>

## Vague language to tighten
- <file>:<line> — "<phrase>"

## Recommended repairs (ranked)
1. ...

## What looked right
- <calibration bullet — what the reviewer found load-bearing and well-shaped>
- ...

### Recommended next Cohesive skill

**Disposition:** <one phrase>

**Implementation route** — pick one:

| Option | Skill | When to pick |
|---|---|---|
| Implement now with delta-coverage discipline (default) | `cohesive:implement-cohesively` | Substantial rewrites; the rewrite added named invariants, behavior matrices, or cross-cutting conceptual changes. Phase loop with per-phase cross-review against the delta. |
| Land specs first; implement separately later | merge the `design/<slug>` branch first; later run `cohesive:implement-cohesively` against the merged delta ledger | Spec rewrite is independently valuable (e.g., for review by humans before code lands); the implementation has dependencies that aren't yet ready. |
| Hand off to Superpowers without delta-coverage discipline | `superpowers:writing-plans` | Small rewrites where the delta is mostly cosmetic; user accepts that the implementation may drift from the rewrite. The bypass is documented per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` §"Known bypass risks." |
| Schedule for later | (no immediate action) | The rewrite is approved; implementation is not currently in scope. Re-invoke `cohesive:implement-cohesively` or `superpowers:writing-plans` when ready. |
```

**Disposition derivation.** The Disposition phrase above is the literal string in the `Canonical Disposition phrase` column of the rubric table at `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Disposition rule for validation-review findings", selected by matching the row whose `(Verdict, Highest severity present)` pair fits the review. The rubric table is the single source of truth for the phrase string; this skill cites rather than restates. Substrate-noting is a user override of the Approved + Low default per the rubric §"Substrate-note as user override", not a separate Disposition phrase the agent renders.

**Conditional implementation route.** Render the implementation decision matrix iff the verdict is `Approved` (which by the verdict-floor mapping in the rubric §"Verdict → severity-floor mapping" guarantees the disposition is merge-ready). Omit the matrix entirely for `Issues Found` and `Design Incoherent` — in those cases the Disposition phrase is the complete next step.

**Bypass acknowledgment.** When the user picks the third row (`superpowers:writing-plans` directly), the skill renders the literal acknowledgment line `Implementation may drift from the rewrite; the IMPLEMENTATION_PLAN_COVERS_DELTA invariant does not apply.` in chat *before* invoking `superpowers:writing-plans`. The acknowledgment lands in the conversation transcript, making the bypass legible. No file is written, no flag is required — the convention is the line itself, and skipping it is a substrate violation reviewed in `cohesive:review-codebase`.

## Why fresh eyes matter here

The original architect can no longer see what's underspecified, because they remember the design discussion. They know that "the kernel is pure" implies certain constraints — but a future reader (human or agent) does not have that conversation in their head. Only the docs do.

The dispatched `spec-cohesion-reviewer` agent simulates the future reader. It runs in a Task subprocess with no inherited context and reads only the file paths the dispatch prompt names. If the reviewer (who has read only the rewritten docs) can't tell whether some behavior is intentional or accidental, then no future contributor will be able to either. That's the gap the rewrite needs to close before implementation.

## Acceptance criteria

- Each pass's dispatched agent receives only file paths, not pre-digested summaries.
- The pass-N agent's input does not include the pass-(N-1) review, the brainstorm output, or the loop's conversation history.
- The verdict vocabulary is {Approved, Issues Found, Design Incoherent}. The max-passes stall is a *loop-exit shape* that surfaces the latest pass's Issues Found verdict to the user with a stall banner; Issues Found does not surface to the user except via that banner (the loop normally drives it internally to convergence).
- The Issues Found repair loop terminates within `MAX_REPAIR_PASSES` iterations (default 5; configurable via `--max-passes=N`) regardless of repair convergence.
- The loop never auto-pivots from Issues Found to `brainstorm-design`; that decision is the user's, surfaced after a max-passes stall or a Design Incoherent verdict.
- Every issue in each pass's report names the **substrate artifact** to repair (spec, matrix, invariant, gotcha, linter, test, type boundary).
- Vague language ("should," "may," "TBD") in normative sections is enumerated with file:line references.

## Red flags

- Calling the agent with a long contextual preamble that summarizes the design. That bypasses fresh-eyes by smuggling the calling skill's mental model into the agent's prompt — the harness fence can't prevent prompt contamination, only conversation inheritance.
- Passing the prior pass's review (or the loop's conversation context) to the next pass's reviewer. Each pass is fresh eyes; contaminating across passes defeats the property the loop relies on.
- Rendering the verdict from in-conversation reading instead of dispatching the agent. The skill always dispatches; that's the structural fence.
- Auto-looping past `MAX_REPAIR_PASSES` because "the next pass might converge." The ceiling exists because non-convergent designs are usually structural; surface and let the user decide.
- Auto-pivoting to `brainstorm-design` on max-passes stall instead of recommending it. The user owns the decision to revisit the chosen direction.
- Verdict of "Approved" with no positive observations about what looked right. Calibration matters.
- Verdict of "Issues Found" with all issues marked blocking. If everything is blocking, the prioritization is failing.
- The reviewer reading implementation files. Specs only.
- Rendering an options menu (e.g., "Three options: repair pass / substrate-note / persist-and-pause") in place of the disposition recommendation. The disposition rule in `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Disposition rule for validation-review findings" picks; the agent does not. Forcing the user to choose between dispositions violates `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule #5 ("Recommend exactly one next move") and reproduces the failure mode this skill's substrate is designed against.

## Composition

- **Always preceded by:** `rewrite-specs` (forward chain) or invoked by the user against an existing `design/<slug>` worktree.
- **Internally dispatches:** `cohesive:rewrite-specs` (in repair mode) per pass of the Issues Found repair loop, until verdict converges or the loop terminates per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` §"validate-rewrite ↔ rewrite-specs (Issues Found internal repair loop)".
- **Followed by:** the disposition rule's recommendation per `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Disposition rule for validation-review findings". For Approved with merge-ready disposition, the implementation decision matrix in §"Output format" picks among `cohesive:implement-cohesively` / `superpowers:writing-plans` / land-specs-first / schedule-for-later. For Design Incoherent, `brainstorm-design`. For max-passes stall, `brainstorm-design` or manual repair.

## What this skill is *not*

- Not the spec rewrite itself. This skill validates the rewrite produced by `rewrite-specs`; it never produces or modifies docs.
- Not a code review. Specs-only by Hard Constraint #2 — implementation files are out of scope until verdict is `Approved`.
- Not a substrate audit. Audit asks "what memory is missing across the repo"; validation asks "is this rewrite internally coherent and aligned with its approved direction." Use `cohesive:audit-substrate` for the former.
- Not a synthesis of multiple agents. Single dispatched reviewer; the skill surfaces its report rather than merging across reviewers.
