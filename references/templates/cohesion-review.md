# Spec Cohesion Review — [topic]

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** YYYY-MM-DD
**Subject:** <which rewritten specs were reviewed; cite the rewrite branch and the rewrite-tip SHA>

**Status:** Approved / Issues Found / Design Incoherent

## Architectural reflection

**Render context:** This section is the lock→build handoff slot — the synthesis of the reviewer's locality, future-fit, and enforcement findings into a "now that the design is locked, how does the architecture feel?" view. It renders at the top of the chat trailer's body block on **Approved** verdicts (the gate where the user decides whether to proceed to Build). It is omitted on Issues Found and Design Incoherent verdicts — there the disposition is the architectural answer.

The reflection is short — one paragraph followed by three bullets — and is structured as:

- **One paragraph: How it feels now.** The architecture's overall shape after the lock. Specific to this design; not "looks good" or "well-structured."

Then three bullets, each answering one question:

- **Easier downstream:** what future change becomes cheaper or more predictable because of this lock. (Drawn from the reviewer's future-fit positives.)
- **Harder downstream:** what becomes more expensive, or what new context a future change in this area requires. (Drawn from the reviewer's locality concerns and future-fit negatives.)
- **Load-bearing on memory:** which rules in the locked design depend on reviewer attention rather than tests/types/linters/CI. (Drawn from the reviewer's enforcement concerns.) Omit when enforcement is fully structural.

The render-only-non-empty rule applies per-bullet: drop a bullet entirely if there's nothing concrete to say. The "How it feels now" paragraph always renders (a reflection without it has no thesis). The persisted file keeps the section header + paragraph + bullet scaffolding for future review passes; chat renders only what's load-bearing this pass.

**Persisted file format:**

```md
## Architectural reflection

How it feels now: <one paragraph — concrete to this design>

- **Easier downstream:** <what future change becomes cheaper>
- **Harder downstream:** <what becomes more expensive; what context a future change requires>
- **Load-bearing on memory:** <rules that depend on reviewer attention rather than structure>  *(omit when fully enforced)*
```

## Executive judgment

One paragraph. Could a future contributor — human or agent — read these rewritten specs and implement the system without needing the original architect's memory? If not, what's the single biggest gap?

## Delta at a glance

This section is a **render slot** in the validation review document. The dispatching `validate-rewrite` skill computes the spec diff (`git diff $(merge-base main HEAD)..HEAD`) and renders an auto-generated 5-bullet summary here:

- `N files rewritten / M files added / K files removed`
- `Named invariants touched:` <comma-separated names from `### …`-style headings in the diff> — or `none`
- `Behavior matrix rows changed:` <count + matrix names> — or `none`
- `Gotchas added or retired:` <names> — or `none`
- `Classification:` <Pure implementation | Design | Mixed> (read from the rewrite commit's `Classification:` trailer)

This is render-time orientation; no parallel persisted artifact backs it. The reviewer reads the diff itself as the authoritative source — this summary just helps the reader of the validation review scan what's in the rewrite at decision time.

## Blocking issues

Findings with severity `High` or `Blocker` (severity vocabulary: see `references/cohesion-rubric.md` §"Severity vocabulary for findings"; the verdict-floor mapping in the same file requires `High` or `Blocker` findings to land in this section under an `Issues Found` verdict). The section heading uses the historic word "Blocking" as a category label; the severity-vocabulary terms (`Blocker` for produced-defect findings, `High` for predictable-defect findings) live in the **Severity** field of each finding below. Each finding uses the canonical six-field shape — the same shape every Cohesive reviewer agent produces — so the synthesizing skill (`validate-rewrite`, `cohesive:review-codebase`, `cohesive:review-diff`) can merge findings uniformly.

### B1. <short title>
- **Severity:** Blocker / High / Medium / Low
- **Category:** Spec drift / Locality / Invariant / Test / Domain model / Vague language / Future-fit / Enforcement
- **Why it matters:** <concrete consequence; not "may cause confusion">
- **Evidence:** <file:line references; quoted snippets when illustrative>
- **Recommended fix:** <concrete next step the rewriter can act on>
- **Substrate artifact to add or update:** spec / behavior matrix / named invariant / gotcha / semantic linter / test / type boundary

(repeat for B2, B3...)

## Important issues

Findings with severity `Medium` or `Low` (severity vocabulary: see `references/cohesion-rubric.md` §"Severity vocabulary for findings"). These do not block implementation; the disposition rule in the rubric specifies what to do with them per `(verdict, highest-severity-present)`. Use the same six-field shape as Blocking issues.

### I1. <short title>
- **Severity:** ...
- **Category:** ...
- **Why it matters:** ...
- **Evidence:** ...
- **Recommended fix:** ...
- **Substrate artifact to add or update:** ...

## Substrate gaps

Substrate the rewrite *didn't* add but should have. Distinct from issues with what was added.

- <gap>: <why it matters>
- ...

## Locality concerns

Does the rewrite increase the context required to make a future change in this area? Are seams clear?

- ...

## Future-fit concerns

Does the rewrite acknowledge future pressure without smuggling it into current scope?

- ...

## Enforcement concerns

Are named invariants accompanied by an enforcement story (test/type/constraint/linter/runtime wrapper/CI)?

- ...

## Behavior knowable outside implementation?

- Are matrix cells complete enough that an agent could reproduce the decision function?
- Are test names traceable to spec sections or matrix cells?
- Is any normatively-important behavior knowable *only* by reading code?

## Vague language to tighten

Look for "should," "probably," "we will," "TODO," "TBD" in normative sections of the rewrite. List them here:

- <file>:<line> — "<offending phrase>"
- ...

## Recommended repairs (ranked)

1. <highest leverage>
2. <next>
3. ...

### Next

This `### Next` block is the `validate-rewrite` variant per `references/templates/chat-trailer.md` §"Variants" — the **Disposition** phrase + (Approved-only) **Implementation route** with the default-recommend rule applied per the centralized chat-trailer template's §"Default-recommend rule". The `###` heading depth matches the centralized chat-trailer template's footer convention per `references/templates/chat-trailer.md` §"The shell". The disposition phrase is determined by the rule in `references/cohesion-rubric.md` §"Disposition rule for validation-review findings"; it is single-phrase by design.

**Disposition:** <the literal string in the `Canonical Disposition phrase` column of the rubric table at `references/cohesion-rubric.md` §"Disposition rule for validation-review findings", for the row whose `(Verdict, Highest severity present)` pair matches this review. The rubric is the single source of truth for the phrase string; this template cites rather than restates. Substrate-noting is a user override of the Approved + Low default per the rubric §"Substrate-note as user override", **not a separate Disposition phrase the agent renders**; the agent renders the rule's default and the user's override (if any) is a post-render move that lands in the validation review file's `## Deferred findings (substrate-note overrides)` section.>

**Implementation route:** [render iff verdict is `Approved`; otherwise omit]. The verdict-floor mapping in `references/cohesion-rubric.md` §"Verdict → severity-floor mapping (validate-rewrite)" guarantees `Approved` is merge-ready. The route is rendered with the default-recommend rule per the chat-trailer template's §"Default-recommend rule": one default move (`cohesive:implement-cohesively` — drive code in a single pass against the spec diff anchored at the rewrite-tip SHA, with end-of-run dual reviewer dispatch) leads, with the alternatives behind a `(other options)` disclosure. The full alternatives list is in `skills/validate-rewrite/SKILL.md` §"Output format". Omit the entire route slot for `Issues Found` and `Design Incoherent`.

## What looked right

Brief — the few highest-quality moves in this rewrite. Not flattery; calibration for the next reviewer.

- ...
