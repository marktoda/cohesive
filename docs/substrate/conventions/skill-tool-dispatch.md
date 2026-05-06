# Skill-tool dispatch

The prescriptive shape of every Cohesive **Skill-tool (skill→skill) dispatch**. Read this when authoring a new skill that composes another Cohesive skill via the Skill tool — currently `validate-rewrite`'s repair loop and `implement-cohesively`'s phase loop, and any future internal-loop or composition seam that follows the same shape.

This convention complements `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/dispatch-protocol.md`, which covers **Task-tool reviewer-agent dispatches**. The two contracts are deliberately separate: a Task-tool dispatch runs in an isolated subprocess with no inherited conversation context (the fresh-eyes property documented in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/fresh-eyes-review.md`), while a Skill-tool dispatch is a subroutine call that runs in the *same* conversation context. Conflating the two contracts is the failure mode this separation exists to prevent — a contributor who treats a Skill-tool dispatch as if it carried the Task-tool fence will assume isolation that does not exist; a contributor who treats a Task-tool dispatch as if it ran in shared context will write a prompt that smuggles the calling skill's mental model past the harness fence.

## What a Skill-tool dispatch is

When a Cohesive skill invokes another Cohesive skill via the Skill tool (e.g., `validate-rewrite` invoking `cohesive:rewrite-specs` in repair mode, or `implement-cohesively` invoking `superpowers:writing-plans` per phase), the harness loads the dispatched skill's body and presents its instructions to the same conversation. The dispatched skill executes in the calling skill's context — it sees the same conversation history, the same prior tool calls, the same system reminders. There is no subprocess and no prompt-only fence.

The contract is therefore *prompt-as-handoff*: the dispatching skill's invocation prompt is the structured input the dispatched skill consumes. The dispatched skill is expected to honor only what the prompt names; everything else is conversation context the dispatched skill could read but should not act on.

## The four-constraint contract

Every Skill-tool dispatch in Cohesive honors four constraints, named at the dispatch site in the dispatching SKILL.md body:

### 1. Repair scope (or composition scope)

The dispatched skill operates on the scope the dispatch prompt names — not on a wider re-litigation of upstream decisions.

For `validate-rewrite` ↔ `rewrite-specs` repair-loop dispatches: the scope is the enumerated repairs in the cited per-pass validation review. The dispatched `rewrite-specs` rewrites those specific surfaces; it does not re-scan the whole doc surface or expand into a fresh design pass.

For `implement-cohesively` per-phase dispatches: the scope is the phase intent (delta entries the phase covers + phase plan if available). The dispatched skill does not re-derive phases or expand into adjacent delta entries.

The constraint is named in the dispatch prompt explicitly, not by reference. A future agent reading the dispatching skill body can verify the scope is bounded without consulting another file.

### 2. No re-derivation of upstream decisions

The dispatched skill does not re-litigate decisions the upstream chain made.

For `rewrite-specs` in repair mode: the brainstormed direction is fixed; if the direction itself is unsound, that is a Design Incoherent signal the *next* pass's reviewer surfaces, not a verdict the dispatched `rewrite-specs` renders directly.

For `superpowers:writing-plans` per phase: the design delta ledger is fixed; the plan covers the named delta entries against the named invariants, not a re-questioning of whether the rewrite was the right call.

The constraint exists because Skill-tool dispatches share conversation context — without explicit scope discipline, the dispatched skill could read upstream context and propose changes the upstream chain has already finished pressuring.

### 3. Commit shape (when the dispatched skill commits)

When the dispatched skill produces commits (as `rewrite-specs` does on the `design/<slug>` branch), the commit message follows the dispatching skill's commit template — not the dispatched skill's default forward-rewrite shape.

For `validate-rewrite`'s repair loop, `rewrite-specs/SKILL.md` Step 6 prescribes the repair-mode commit shape:

```
design: repair pass-<N> — closes <finding IDs>
Pass: <N>
Closes: <comma-separated finding IDs>
Source review: docs/history/reviews/<...>.md
See: docs/history/delta-ledgers/<...>.md
```

The repair-mode commit message is the auditing surface for repair sequences. A `git log --grep "pass-"` over the `design/<slug>` branch yields the per-pass repair history; without the commit-shape constraint, the audit grep returns nothing.

### 4. Per-pass paths-only when re-dispatching reviewers

If the dispatching skill's loop re-dispatches a reviewer agent for the next pass (as `validate-rewrite` does after each repair), the new dispatch is a fresh Task subprocess with paths-only input — never the prior pass's review or the loop's accumulated conversation context.

This constraint preserves the Task-tool fresh-eyes property *per pass*. The Skill-tool dispatch shares conversation context (constraint 1–3 manage the resulting risks); the per-pass Task-tool dispatch must not, and must be set up explicitly fresh each iteration.

For `validate-rewrite`'s repair loop, the constraint lives in `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` Step 4 substeps 2–3. For `implement-cohesively`'s phase loop, the per-phase Task-tool `delta-coverage-reviewer` dispatch is independent per phase per `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md` Phase 2c.

## What the dispatch prompt must contain

A correct Skill-tool dispatch prompt has this shape (compare the parallel structure with `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/dispatch-protocol.md` §"The dispatch contract"):

```
You are <dispatched skill role> in <calling skill's loop or composition>. <One-sentence framing.>

## Scope

<The repair scope, the phase scope, or the composition scope. Specific. Bounded. Named as a list of entries (finding IDs, delta entries, phase intent bullets) — not "this whole rewrite" or "the next phase.">

## Inputs (paths)

<The artifact paths the dispatched skill reads. Per-pass review path; delta-ledger path; plan path; rewritten spec paths.>

## Constraints (per the four-constraint contract)

1. Repair / composition scope is the entries above.
2. Do not re-derive <named upstream decision the dispatched skill must not re-litigate>.
3. Commits follow <dispatching skill's template; cite the template by reference>.
4. (If the loop re-dispatches reviewers) Per-pass paths-only on the next reviewer dispatch; do not pass this loop's conversation context.

## Output (persisted)

<The persisted artifact the dispatched skill returns. For `rewrite-specs` in repair mode: repair commits on `design/<slug>` following the repair-mode commit template (per the Skill-tool four-constraint contract, constraint 3). For `superpowers:writing-plans` per phase: the plan persisted at `docs/history/plans/<YYYY-MM-DD>-<slug>-phase-<N>.md`. For `superpowers:executing-plans` per phase: the implementation commits + test artifacts on the same branch.>

## Output (chat trailer)

<Optional. The dispatched skill's chat-rendered output, if any. For `rewrite-specs` repair mode: the standard pass-N announcement (one-line summary; the calling skill's loop renders the full pass-by-pass progress). For `superpowers:writing-plans` and `superpowers:executing-plans`: typically none, since the dispatching skill's loop owns the user-facing render.>
```

The persisted output is the load-bearing return surface: it is what the calling skill consumes structurally (paths to artifacts; commit history). The chat trailer is advisory; the calling skill typically owns the user-facing render and the dispatched skill's chat output is structured for the loop's progress display, not for the user. When in doubt, omit the chat trailer field — the loop renders progress, not the dispatched skill.

What the dispatch prompt **must not** contain:

- A pre-summary of upstream decisions the dispatched skill would re-derive ("the design we approved was X; here's why")
- A list of conclusions the dispatched skill should reach ("expect to find Y; close with verdict Z")
- Implicit references to prior conversation ("as we established earlier...", "given the discussion above...")
- Files to "consider" or "skim" without explicit paths
- Requests for the dispatched skill to render its full Output format block in chat — typically the dispatching skill's loop renders the user-facing output and the dispatched skill's chat output is structured for the loop's consumption

## Skill-tool vs Task-tool dispatch (when to use which)

| Property | Skill-tool dispatch | Task-tool dispatch |
|---|---|---|
| Conversation context | Shared with calling skill | Isolated subprocess; no inheritance |
| Fresh-eyes property | None (caller and callee in same context) | Load-bearing structural property (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/fresh-eyes-review.md`) |
| Use case | Subroutine composition; repair loops; per-phase plan/execute composition | Reviewer-agent dispatch; any case where the callee must judge without the caller's mental model |
| Convention doc | This file | `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/dispatch-protocol.md` |
| Concrete sites in v0.1 | `validate-rewrite` ↔ `rewrite-specs` repair loop; `implement-cohesively` Phase 2a/2b composition with `superpowers:writing-plans` and `superpowers:executing-plans` | `review-codebase` Phase 3 (4 agents); `review-diff` (2 agents); `validate-rewrite` Step 2 per-pass `spec-cohesion-reviewer`; `implement-cohesively` Phase 2c per-phase `delta-coverage-reviewer` |

When a future composition seam needs both shapes — a Skill-tool subroutine call that *also* needs a fresh-eyes review of its output — the right shape is two dispatches: a Skill-tool call to do the subroutine work, then a Task-tool call to review the work in a fresh subprocess. `validate-rewrite`'s repair loop is the worked example: each pass dispatches `rewrite-specs` via Skill tool (subroutine), then re-dispatches `spec-cohesion-reviewer` via Task tool (fresh-eyes review of the repair).

## Concrete dispatch sites in v0.1

- **`skills/validate-rewrite/SKILL.md` Step 4 substep 2** — Skill-tool dispatch to `cohesive:rewrite-specs` in repair mode. The dispatch prompt names the per-pass validation review path as the source, instructs repair-mode operation per `${CLAUDE_PLUGIN_ROOT}/skills/rewrite-specs/SKILL.md` §"Process Step 1b. Repair-pass mode", and states the four-constraint contract inline.
- **`skills/implement-cohesively/SKILL.md` Phase 2a** — Skill-tool dispatch to `superpowers:writing-plans` with the phase intent as input. The plan persists at `docs/history/plans/<YYYY-MM-DD>-<slug>-phase-<N>.md`.
- **`skills/implement-cohesively/SKILL.md` Phase 2b** — Skill-tool dispatch to `superpowers:executing-plans` with the persisted plan path as input. Superpowers owns TDD discipline inside this dispatch.

All three sites honor the four-constraint contract. New Skill-tool dispatches should match the shape; deviations require an entry in this doc before adoption.

## Failure modes this contract prevents

- **Scope creep across loop iterations.** Without constraint 1, a repair-loop `rewrite-specs` dispatch widens beyond the named findings and re-litigates the rewrite as a whole — caught by the next pass's reviewer flagging scope creep, but the catch is post-hoc.
- **Upstream-decision re-litigation.** Without constraint 2, the dispatched skill reads the calling skill's conversation context and proposes changes that reopen design decisions the chain has already pressured. The result: the loop never converges because each pass re-questions the chosen direction.
- **Audit grep failure.** Without constraint 3, repair commits land with `git commit -m "design: rewrite specs for X"` (the forward-rewrite template) instead of the repair-mode template. `git log --grep "pass-"` returns nothing; the per-pass repair history is invisible.
- **Cross-pass fresh-eyes contamination.** Without constraint 4, the next pass's reviewer agent receives the prior pass's review (or the loop's accumulated context) as input. The Task-tool fence cannot prevent prompt contamination — it can only prevent conversation inheritance — so contaminated prompts defeat the per-pass fresh-eyes property.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/dispatch-protocol.md` — the Task-tool dispatch contract; consulted instead when authoring a reviewer-agent dispatch.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/fresh-eyes-review.md` — the load-bearing property the Task-tool contract protects; consulted when judging whether a new dispatch needs Skill-tool or Task-tool shape.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` §"validate-rewrite ↔ rewrite-specs (Issues Found internal repair loop)" — the per-handoff contract for the v0.1 internal repair loop, referencing this doc.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md` — the Cohesive↔Superpowers seam, referencing this doc for the per-phase Skill-tool dispatches.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Code-producing skills" — the rule that Cohesive's only code-producing surface is `superpowers:executing-plans` invoked via this dispatch shape.
