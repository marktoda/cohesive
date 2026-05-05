---
name: cohesively
description: Use when the user wants to plan, refactor, design, brainstorm, audit, or review code in a way that should preserve specs, behavior matrices, named invariants, semantic linters, gotchas, architectural seams, tests, and future product direction. The Cohesive router. Triggers on "cohesively", "cohesive design", "design substrate-first", "brainstorm a refactor of X", "review the architecture for cohesion", "review the codebase for cohesion", "audit substrate", "what memory is missing", "review my diff for cohesion", "name an invariant", "encode a behavior matrix", "is this the right place to centralize", "rewrite the specs", "validate the rewrite". Picks the right Cohesive workflow, announces it, and chains the relevant subskills.
---

# Cohesively — the Cohesive router

## What this skill does

Cohesive is a substrate-first methodology for senior engineers building durable codebases. Most user requests that touch behavior, architecture, invariants, tests, docs, or future product direction need more than one Cohesive subskill in sequence. This router classifies the request, picks the workflow, announces it, and dispatches.

Cohesive distinguishes itself from Superpowers: **Superpowers optimizes for disciplined implementation; Cohesive optimizes for durable judgment.** Both can run in the same session, and Cohesive composes with Superpowers' `using-git-worktrees`, `code-reviewer`, and `finishing-a-development-branch` skills.

## The user-facing skill set

The flagship workflow chain reads as five imperatives — **discover → brainstorm → rewrite → validate → implement** — paralleling and extending Superpowers' `brainstorm → plan → execute`. Three standalone diagnostics sit off-chain.

| | Skill | Role |
|---|---|---|
| 1 | `discover-substrate` | Inventory what the codebase already remembers |
| 2 | `brainstorm-design` | Propose 2–4 options grounded in substrate; pressure-test |
| 3 | `rewrite-specs` | Hard-rewrite docs to chosen end state in a worktree |
| 4 | `validate-rewrite` | Fresh-eyes review of the rewritten specs |
| 5 | `implement-cohesively` | Drive implementation phase-by-phase against the delta ledger; per-phase cross-review; final substrate review |
| | `review-codebase` | Full architecture review |
| | `review-diff` | PR / branch / working-changes review |
| | `audit-substrate` | What memory is missing? |

## Routes

Read the user's request and map to one of these workflows. Use the trigger phrases as primary signal; use the topic and verb tense as secondary signal.

### Route: design

**When:** Brainstorm or refactor a feature/subsystem. Forward-looking ("add", "refactor", "support", "build").

**Chain:**
1. `discover-substrate` — what does the codebase already remember about this area?
2. `brainstorm-design` — propose 2–4 options grounded in substrate; pressure-test each
3. (only if user approves a direction and the change is substantial enough to warrant a spec rewrite) `rewrite-specs` — hard-rewrite docs to chosen end state in a worktree
4. (only if step 3 ran) `validate-rewrite` — fresh-eyes review of the rewritten specs

**Default behavior:** Run steps 1–2. Pause for user approval before step 3. Many design conversations end at step 2 with a recommendation — don't escalate to spec rewrite unless the user wants it. Implementation is a separate route (`implement`); the design route does not auto-chain into implementation.

**Clarifying question (optional, max one):** "Which future pressure should this design optimize for most: <option A>, <option B>, <option C>?"

### Route: implement

**When:** A spec rewrite has been validated (Approved verdict from `validate-rewrite`) and the user wants to land code that makes the rewrite true. "Implement the approved rewrite", "land docs with implementation", "implement-cohesively", "drive implementation against the delta", "ship the rewrite".

**Chain:**
1. `implement-cohesively` — derive phases from the design delta ledger; per-phase invocation of `superpowers:writing-plans` and `superpowers:executing-plans`; per-phase `delta-coverage-reviewer` cross-review; final `cohesive:review-diff` against the branch.

**Clarifying question (required if the validation review path is not in the user's request):** "I see we're about to run implement. Has validate-rewrite returned **Approved** for a spec rewrite, or should I run the design route first?"

The user can decline the implement route in favor of `superpowers:writing-plans` directly — this bypasses delta-coverage discipline (an option named in the `validate-rewrite` Approved footer's decision matrix), and the user accepts that the implementation may drift from the rewrite.

### Route: review (codebase)

**When:** Whole codebase or subsystem architecture review. "Review the architecture", "review the codebase", "is this codebase healthy".

**Chain:**
1. `discover-substrate` — get the substrate inventory
2. `review-codebase` — four-phase architecture review

**No clarifying question** — read normative docs first; the answers come from there.

### Route: review (diff)

**When:** PR / branch / working-changes review. "Review my PR", "review this diff", "review the change".

**Chain:**
1. `discover-substrate` (scoped to changed files)
2. `review-diff`

**Clarifying question (only if needed):** "Which PR / branch / set of changes? I see <X> uncommitted changes; should I review those, or do you have a PR number?"

### Route: audit (substrate)

**When:** "What memory is missing", "audit substrate", "what specs/invariants/gotchas should we have but don't".

**Chain:**
1. `discover-substrate`
2. `audit-substrate` — single-pass scan of missing memory; not the same machinery as `review-codebase`.

### Route: rewrite-only

**When:** User has already chosen a direction (or has a brainstorm output from earlier) and wants the spec rewrite without re-brainstorming. "Rewrite the specs for X", "update the design docs to reflect Y".

**Chain:**
1. `rewrite-specs` (which sets up its own worktree; composes with `superpowers:using-git-worktrees` if installed)
2. `validate-rewrite`

**Clarifying question (required if no direction is named):** "Has a direction been chosen, or should we run brainstorm-design first?"

### Route: artifact (V1 — deferred)

**When:** "Name an invariant", "encode a behavior matrix", "create a gotcha doc".

**Current behavior (until V1):** Return the relevant template path and offer to fill it out inline based on user input. The dedicated artifact skills (`create-invariant`, `create-matrix`) ship in V1.

```
Cohesive v0.1 doesn't yet have a dedicated `<artifact>` skill. The template is at
${CLAUDE_PLUGIN_ROOT}/references/templates/<template>.md. I can fill it out with you now if you like.
```

## Dispatch prompt contract

Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md`, the router-driven case requires explicit prereq-state passing — without it, subskills ask the canonical clarifying question on top of an already-routed turn. The table below is the per-route content the dispatch prompt must include. The matrix-side mirror (with the `validate-rewrite` exception) lives at `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md` §"Dispatch prompt contract"; update both in the same pass. `scripts/validate_plugin.sh` Check 13i greps both surfaces and asserts route-name set equality plus prereq-state-string parity to catch the drift mechanically.

| Route | Prereq state to pass | Chosen-direction / artifact state to pass |
|---|---|---|
| `design` | n/a (discover-substrate has no prereq) | n/a until step 3; then "approved direction: <option name + summary>"; ledger path passed to step 4 |
| `review (codebase)` | "Discovery already complete; report at <path or 'inline above'>." | n/a |
| `review (diff)` | "Discovery already complete (scoped to <changed-files>); report at <path or 'inline above'>." | n/a |
| `audit (substrate)` | "Discovery already complete; report at <path or 'inline above'>." | n/a |
| `rewrite-only` | n/a | "Approved direction: <option name + summary>" (or, if user declined, route to `design` first); ledger path passed to step 2 once `rewrite-specs` has produced it |
| `implement` | "Validate-rewrite returned **Approved**; review at <path>." | "Design delta ledger at <path>. Branch: design/<slug>." Validation review path and ledger path are both required. |
| `artifact` | n/a | "Artifact requested: <invariant / matrix / gotcha>" |

Consumers:

- **Prereq-state consumers** (subskills with a `discover-substrate` prereq): `brainstorm-design`, `rewrite-specs`, `review-codebase`, `review-diff`, `audit-substrate`. Each Hard Constraint #1 in those skill bodies states that when the router passes the prereq fragment, the canonical clarifying question is skipped.
- **Chosen-direction / ledger-path consumers**: `rewrite-specs` (chosen direction), `validate-rewrite` (ledger path only — no prereq state; this is the documented exception), `implement-cohesively` (validation review path + ledger path; both required), V1 artifact skills.

Direct (non-router) invocation: the subskill asks its canonical question per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Clarifying questions". The contract is router-side only.

## Required behavior

1. **Announce the route.** One sentence in chat before dispatching, in the canonical form:
   > "I'm treating this as a Cohesive **<route>** workflow: <chain>. Reason: <one short clause>."

   The form is the convention named in [`docs/substrate/conventions/skill-shape.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md) §"Router conventions". `<route>` is one of: `design`, `review (codebase)`, `review (diff)`, `audit (substrate)`, `rewrite-only`, `implement`, `artifact`.

2. **Process skills run before implementation skills.** If behavior or architecture is changing, route through substrate discovery before any code. The `implement` route is the structural answer to "implement now" — it dispatches `implement-cohesively`, which drives implementation against the design delta ledger via the phase loop. Freeform code-writing from this skill body is forbidden.

3. **At most one clarifying question.** Per route (above). The question is a specific forced choice, never a vague "what do you want?" prompt — convention defined in [`docs/substrate/conventions/skill-shape.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md) §"Clarifying questions".

4. **Do not implement code from the router itself.** The router routes; subskills work. Implementation is delegated to the `implement` route, which dispatches `implement-cohesively`. That skill in turn composes `superpowers:writing-plans` and `superpowers:executing-plans` per phase — it does not write code itself either. Cohesive's only code-producing surface is `superpowers:executing-plans` invoked from inside `implement-cohesively`'s phase loop.

5. **Honor the dispatch prompt contract.** When invoking a subskill, include the relevant fragment from the table above. Subskills depend on this; omitting it produces a duplicate clarifying question on top of an already-routed turn.

6. **Compose with Superpowers when present.** Specifically:
   - Worktrees: `superpowers:using-git-worktrees` (used by `rewrite-specs`)
   - Implementation discipline: `superpowers:writing-plans` and `superpowers:executing-plans` (used per-phase by `implement-cohesively`); `superpowers:test-driven-development` is consumed indirectly via `executing-plans`
   - Branch finishing: `superpowers:finishing-a-development-branch` (recommended after `implement-cohesively` Implemented verdict; user-invoked, never auto-invoked from the router)

7. **Track progress with TodoWrite** when chaining 3+ subskills. The user should see the chain as it executes.

## Routing decision logic

When the request is ambiguous, prefer this resolution order:

1. **Explicit user instruction** ("review the codebase" → review/codebase). Always wins.
2. **Verb tense and implementation cue.** Imperative implementation verbs against an existing approved rewrite ("implement", "land", "ship") → implement. Other forward-looking verbs ("add", "refactor", "build", "design") → design. Retrospective ("review", "audit", "what's wrong with") → review.
3. **Scope hints.** Whole-repo / subsystem / "the codebase" → review (codebase). Diff / PR / branch / changes → review (diff). Missing / gaps / what's-not-there → audit (substrate).
4. **Default.** When truly stuck, default to `audit (substrate)` for retrospective requests and `design` for forward-looking ones — these are the two routes most likely to surface what's actually needed.

## Output

The router itself produces minimal output: a single-sentence announcement before the first subskill is invoked. Per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` §"Density budgets," the router's render budget is 1–2 sentences — it has no `#` title and is exempt from the voice-citation grep that applies to longer-rendered skills (documented in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` §"Convention pins enforced alongside this invariant").

The canonical announcement template:

```
I'm treating this as a Cohesive <route> workflow: <subskill-1> → <subskill-2> → <subskill-3>. Reason: <one short clause>.
```

Then the router invokes the first subskill. Each subskill produces its own output (carrying its own voice citation) and recommends the next. The user can stop the chain at any subskill boundary.

## Acceptance criteria

- The router classifies every Cohesive-relevant request to exactly one route.
- The route is announced before any subskill runs.
- At most one clarifying question is asked, and it is precise (not vague).
- Code is not produced from the router.
- Long chains (3+ subskills) are tracked with TodoWrite.
- The dispatch prompt contract is honored — subskills receive prereq/direction state explicitly.

## Red flags

- Asking "what do you want?" or "can you tell me more?" — both are too vague. If a question is needed, it must be a specific forced choice.
- Routing to multiple workflows in parallel ("I'll do both a design and a review"). Pick one. If the user really wants both, they can ask twice.
- Producing implementation suggestions or code in the router itself. The router routes; subskills do work.
- Dispatching subskills without the announcement. Users need to know which workflow they're in.
- Dispatching subskills without the prereq/direction context the dispatch contract requires. Subskills will then ask their canonical question on top of an already-routed turn.

## What this skill is *not*

- Not the workflow itself. The router picks; the subskills work.
- Not a general-purpose AI coding assistant. Cohesive is opinionated about what kinds of work it does.
- Not a replacement for Superpowers. Cohesive handles substrate; Superpowers handles implementation discipline. Use both.
