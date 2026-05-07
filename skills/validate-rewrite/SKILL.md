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
3. **The review can block implementation.** Verdicts gate implementation per the verdict→severity-floor mapping in `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Verdict → severity-floor mapping (validate-rewrite)": `Issues Found` (highest severity High or Blocker) drives the internal repair loop (Hard constraint #4), and `Design Incoherent` exits the loop and routes to `brainstorm-design`. `Approved` (highest severity Medium, Low, or none) terminates the loop and unlocks the implementation route; the trailer leads with one default move (`cohesive:implement-cohesively`) and surfaces alternatives behind a `(other options)` disclosure per the chat-trailer template's §"Default-recommend rule". The disposition rule in the rubric specifies what (if anything) to close before merge.
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

Render shape for the **Approved** branch (which the rubric's verdict-floor mapping guarantees is merge-ready) — this is the **lock→build handoff**, the gate where the user decides whether to continue to Build:

1. **Architectural reflection** — at the top of the body block, render a `## Architectural reflection` section synthesizing the reviewer agent's locality / future-fit / enforcement findings into a "now that the design is locked, how does the architecture feel?" view. Format per `${CLAUDE_PLUGIN_ROOT}/references/templates/cohesion-review.md` §"Architectural reflection": one paragraph + three bullets (easier downstream / harder downstream / load-bearing on memory). The reflection is the substantive answer to "should we proceed to Build?" — the user reads it and either approves or stops.
2. **Body block** — render only non-empty review sections per the chat-trailer template's §"Render-only-non-empty rule". On a clean Approved verdict, most sections (Blocking issues, Important issues, Substrate gaps, etc.) are empty and disappear; the body block may be just the Architectural reflection + Delta at a glance.
3. **Disposition recommendation** — one phrase derived from the rubric table: `Merge as-is — no findings` (Approved + none), `Close inline (≤2 lines per finding) → merge` (Approved + Low), or `Close in same worktree → merge` (Approved + Medium).
4. **Implementation route** — render with the default-recommend rule per the chat-trailer template's §"Default-recommend rule". Lead with one default (`cohesive:implement-cohesively`); place conditional alternatives behind an `Other options` disclosure per §"Conditional alternatives" below. Render only alternatives whose triggering condition fires for this Approved verdict; omit the disclosure entirely when none fire. The verdict-floor mapping ensures `High` and `Blocker` findings produce `Issues Found`, not `Approved`, so an Approved verdict always reaches this slot. The lock→build handoff is a forced-choice gate (the default plus any triggered alternatives); render it through `AskUserQuestion` per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` §"Forced-choice questions" with the default option first — the form's options derive from the same triggering conditions as the markdown disclosure, and the form is omitted when no alternatives trigger (AskUserQuestion requires ≥2 options).

For **Design Incoherent**, the disposition rule's recommendation is the entire next step — no Architectural reflection, no Implementation route renders. `Return to brainstorm-design`. The reflection is meaningful only on Approved, where the lock has actually held; on Design Incoherent, the architecture has not been locked successfully.

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

The skill's chat output (the agent's report, surfaced) follows the centralized chat-trailer template at `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` per its §"Variants" `validate-rewrite` row: the cohesion-review body (per `${CLAUDE_PLUGIN_ROOT}/references/templates/cohesion-review.md`) renders as the body block with only non-empty review sections (per the chat-trailer template's §"Render-only-non-empty rule"), and the `### Next` footer renders the disposition phrase as a leading sentence (no "Disposition:" label) followed (on Approved verdicts only) by the Implementation route default plus conditional alternatives per the chat-trailer template's §"Default-recommend rule" — alternatives render behind an `Other options` disclosure only when their per-alternative triggering conditions fire, per §"Conditional alternatives" below. The chat render is the decision-rendering of the persisted body per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2a (with sub-rules 2b / 2c) and the audience seam in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`. The persisted file (each pass at `docs/history/reviews/YYYY-MM-DD-<slug>-rewrite-validation[-pass-N].md`) is canonical and carries the full review and the cross-pass audit trail (which findings closed in which pass, verdict trajectory across passes); the chat trailer renders this pass's findings in the canonical six-field shape, plus the disposition recommendation and (for Approved) the default + disclosure implementation route. Findings already satisfy rule 2b structurally because the six-field shape (Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact) is show-shape by construction; the failure mode to guard against is cross-pass bookkeeping creep — finding-ID continuity between passes, "the prior pass's deferred items" annotations, verdict-ratchet language. None of that appears in chat; pass-N's persisted file is where the audit trail lives.

**Verdict translation.** The internal verdict (`Approved` / `Issues Found` / `Design Incoherent`) renders in the chat trailer as the user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"validate-rewrite". The user-facing label preserves the internal token (e.g., `**Approved — ready to implement**`) so the dispatch logic and rubric grep targets still resolve.

**Render-conditional rules for the body block.** The render template below is the agent's literal output template; it does not carry meta-instructions or comments inline (per the failure mode in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` — instructions inside render templates leak into user-facing output). The render conditions live here, in prose, instead:

- **`## Architectural reflection`** — renders only when the verdict is `Approved` (the lock→build handoff). Omitted entirely on `Issues Found` and `Design Incoherent`. Format per `${CLAUDE_PLUGIN_ROOT}/references/templates/cohesion-review.md` §"Architectural reflection".
- **`## Executive judgment`** and **`## Delta at a glance`** — always render across all three verdicts. The Delta at a glance is verbatim-quoted from the ledger preamble per the consumer rendering rules in `${CLAUDE_PLUGIN_ROOT}/references/templates/design-delta-ledger.md` §"Delta at a glance".
- **`## Blocking issues`**, **`## Important issues`**, **`## Substrate gaps`**, **`## Vague language to tighten`**, **`## Recommended repairs (ranked)`** — render only when the section has at least one entry, per the chat-trailer template's §"Render-only-non-empty rule". A clean Approved verdict typically collapses all of these out.
- **`## Locality concerns`**, **`## Future-fit concerns`**, **`## Enforcement concerns`** — render only when non-empty AND the verdict is not `Approved`. On `Approved`, the Architectural reflection synthesizes these three into one decision-shaped block; rendering both surfaces would duplicate the same content in chat.
- **`## Behavior knowable outside implementation?`** — renders only when the answer is "no" or "partially". A "yes" answer is the modal Approved case and adds no information.
- **`## What looked right`** — persisted-file only (calibration for next reviewer); never renders in chat.

The persisted file keeps every section header as scaffolding for future review passes; the render-conditional rules above apply to chat only.

```md
# Rewrite Validation Review — <topic>

**Verdict:** <user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"validate-rewrite" — e.g., **Approved — ready to implement** / **Issues found — repair pass needed** / **Design needs revisiting** — the chosen direction is unsound>

## Architectural reflection

<one paragraph naming the architecture's overall shape after the lock — concrete to this design, not "looks good">

- **Easier downstream:** <what future change becomes cheaper or more predictable because of this lock>
- **Harder downstream:** <what becomes more expensive; what new context a future change requires>
- **Load-bearing on memory:** <rules that depend on reviewer attention rather than tests/types/linters/CI>

## Executive judgment

<one paragraph>

## Delta at a glance

<verbatim quote of the ledger's `## Delta at a glance` preamble>

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

<one paragraph: with the surfaces that fall short>

## Vague language to tighten

- <file>:<line> — "<phrase>"

## Recommended repairs (ranked)

1. ...

### Next

<disposition phrase per the rubric's `Canonical Disposition phrase` column, rendered as a leading sentence with a trailing period — e.g., "Merge as-is — no findings.", "Close inline (≤2 lines per finding) → merge.", "Close in same worktree → merge.">

**Implement now** — `cohesive:implement-cohesively`
Builds the locked design phase by phase against the delta ledger at `docs/history/delta-ledgers/<YYYY-MM-DD>-<slug>.md` on `design/<slug>`.

<details>
<summary>Other options</summary>

<one or more two-line cards from the Conditional alternatives table in §"Conditional alternatives" below — render only those whose triggering condition fires>

</details>
```

**Disposition derivation.** The disposition phrase above is the literal string in the `Canonical Disposition phrase` column of the rubric table at `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Disposition rule for validation-review findings", selected by matching the row whose `(Verdict, Highest severity present)` pair fits the review. The rubric table is the single source of truth for the phrase string; this skill cites rather than restates. The chat render drops the `Disposition:` label and renders the phrase as a leading sentence with a trailing period — the phrase is the directive, not metadata about it (methodology labels in chat are forbidden per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` §"Forbidden phrasings"). Substrate-noting is a user override of the Approved + Low default per the rubric §"Substrate-note as user override", not a separate disposition phrase the agent renders.

**Implementation route slot.** Render the implementation route slot iff the verdict is `Approved` (which by the verdict-floor mapping in the rubric §"Verdict → severity-floor mapping" guarantees the disposition is merge-ready). Omit the slot entirely for `Issues Found` and `Design Incoherent` — in those cases the disposition phrase is the complete next step.

**Conditional alternatives.** The `Other options` disclosure is rendered iff at least one alternative below has its triggering condition met for this Approved verdict. Each alternative renders as a two-line card: a bold title with the skill citation on the title line, followed by one short sentence describing when to pick it. If no alternative's triggering condition fires, the disclosure is omitted entirely — the trailer is just the disposition phrase plus the **Implement now** card.

The agent picks which alternatives fire by reading the persisted Approved review (the Architectural reflection bullets and the Delta at a glance) and the design delta ledger at `docs/history/delta-ledgers/<YYYY-MM-DD>-<slug>.md`. Triggering conditions are intent-based, not mechanical thresholds — the agent judges whether each alternative is genuinely live for this rewrite.

| Alternative | Render | Triggering condition |
|---|---|---|
| Land specs first | `**Land specs first** — merge `design/<slug>`; implement later.`<br>`Pick when the docs PR has independent review value, or when implementation has dependencies that aren't ready.` | The rewrite adds substantive new substrate (specs, invariants, behavior matrices, gotchas) that benefits from independent human review before code lands. |
| Implement with Superpowers directly | `**Implement with Superpowers directly** — `superpowers:writing-plans``<br>`Pick when the rewrite is small enough that Cohesive's phased loop with per-phase reviews would be ceremony. Verify with `cohesive:review-diff` after.` | The rewrite is small or polishing-only — few delta entries, no new invariants, no new behavior matrix rows. The phased loop's per-phase verification would be ceremony given the rewrite's size. |
| Re-decide | `**Re-decide** — `cohesive:brainstorm-design``<br>`Pick when the Architectural reflection's Harder-downstream or Load-bearing-on-memory bullets reveal a structural problem the brainstorm missed. Discard the worktree and capture the concern in brainstorm's "What we already tried" input.` | The Architectural reflection's Harder-downstream or Load-bearing-on-memory bullets identify a specific structural concern (not just an acceptable tradeoff). |

If multiple alternatives fire, render each as its own card in disclosure order (Land specs first → Implement with Superpowers directly → Re-decide). The default **Implement now** card always renders for Approved.

**Bypass acknowledgment.** When the user picks the **Implement with Superpowers directly** alternative (rendered when its triggering condition fires; invokes `superpowers:writing-plans` directly), the skill renders the literal acknowledgment line `Implementing with plain Superpowers — Cohesive's per-phase verification of the rewrite doesn't apply. Run cohesive:review-diff after implementation to catch any drift.` in chat *before* invoking `superpowers:writing-plans`. The acknowledgment lands in the conversation transcript, making the bypass legible and naming the post-implementation verification entry point (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` §"Post-implementation review entry point"). The acknowledgment line is user-facing per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2c — the `IMPLEMENTATION_PLAN_COVERS_DELTA` invariant name is substrate-shape vocabulary that lives in the persisted file and the invariant doc, not in chat. No file is written, no flag is required — the convention is the line itself, and skipping it is a substrate violation reviewed in `cohesive:review-codebase`.

**Re-decide acknowledgment.** When the user picks the **Re-decide** option (returns to `cohesive:brainstorm-design`), the skill renders the literal acknowledgment line `Discarding the locked design and returning to Decide. Capture the reflection's harder-downstream / load-bearing-on-memory bullets in brainstorm-design's "What we already tried" input.` in chat *before* the user (or Claude on the user's behalf) invokes `cohesive:brainstorm-design`. The Re-decide path is user-driven (parallel to the Bypass acknowledgment shape above): this skill renders the line as part of the Approved trailer when the user picks Re-decide; the subsequent `brainstorm-design` invocation is a fresh skill call (router-driven via `cohesively` or direct user invocation), with the "What we already tried" payload assembled from three named persisted artifacts — the discarded brainstorm at `docs/history/brainstorms/<date>-<slug>.md`, this Approved review's Architectural reflection bullets (Harder-downstream + Load-bearing-on-memory), and the cycle count derived from the `<slug>` lineage (the count of prior Re-decide acknowledgments in the branch's commit history). The acknowledgment names the substrate input that closes the loop on what was learned (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` §"validate-rewrite → brainstorm-design (Re-decide re-entry)"). The 2-3-cycle cap is the convention; if the re-decide chain reaches a fourth iteration, surface the pattern to the user and recommend cutting scope rather than continuing.

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
- Rendering all alternatives in the `Other options` disclosure regardless of whether their triggering conditions fire. Per §"Conditional alternatives," each alternative has an explicit triggering condition; only rendered alternatives appear in the disclosure, and the disclosure is omitted entirely when none trigger. Always-rendering produces a fixed menu the user has to scan past for options that don't apply to this rewrite — exactly the noise §"Conditional alternatives" exists to prevent.
- Including the `Disposition:` label as a markdown bold prefix in chat. The disposition phrase is rendered as a plain leading sentence with a trailing period; the `Disposition:` label is methodology vocabulary forbidden by `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` §"Forbidden phrasings".
- Rendering cross-pass bookkeeping in chat — finding-ID continuity between passes ("finding B1 from pass-2 is now closed"), verdict-ratchet language ("verdict ratcheted from Issues Found pass-2 to Approved pass-3"), or disposition tables tracking which findings closed in which pass. Violates rule 2c — pass-N's persisted file `## History` section carries the audit trail; chat trailer is per-pass substance. See [`docs/substrate/gotchas/naming-instead-of-showing.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/naming-instead-of-showing.md).

## Composition

- **Always preceded by:** `rewrite-specs` (forward chain) or invoked by the user against an existing `design/<slug>` worktree.
- **Internally dispatches:** `cohesive:rewrite-specs` (in repair mode) per pass of the Issues Found repair loop, until verdict converges or the loop terminates per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` §"validate-rewrite ↔ rewrite-specs (Issues Found internal repair loop)".
- **Followed by:** the disposition rule's recommendation per `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Disposition rule for validation-review findings". For Approved with merge-ready disposition, the default-recommend implementation route in §"Output format" leads with `cohesive:implement-cohesively` and surfaces conditional alternatives (Land specs first / Implement with Superpowers directly / Re-decide) behind an `Other options` disclosure — alternatives render only when their per-alternative triggering conditions fire (see §"Conditional alternatives"); the disclosure is omitted entirely when none fire. For Design Incoherent, `brainstorm-design`. For max-passes stall, `brainstorm-design` or manual repair.

## What this skill is *not*

- Not the spec rewrite itself. This skill validates the rewrite produced by `rewrite-specs`; it never produces or modifies docs.
- Not a code review. Specs-only by Hard Constraint #2 — implementation files are out of scope until verdict is `Approved`.
- Not a substrate audit. Audit asks "what memory is missing across the repo"; validation asks "is this rewrite internally coherent and aligned with its approved direction." Use `cohesive:audit-substrate` for the former.
- Not a synthesis of multiple agents. Single dispatched reviewer; the skill surfaces its report rather than merging across reviewers.
