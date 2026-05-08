---
name: cohesively
description: Use when the user wants to plan, refactor, design, brainstorm, audit, or review code in a way that should preserve specs, behavior matrices, named invariants, semantic linters, gotchas, architectural seams, tests, and future product direction. The Cohesive router. Triggers on "cohesively", "cohesive design", "design substrate-first", "brainstorm a refactor of X", "review the architecture for cohesion", "review the codebase for cohesion", "audit substrate", "what memory is missing", "review my diff for cohesion", "name an invariant", "encode a behavior matrix", "is this the right place to centralize", "rewrite the specs", "validate the rewrite". Picks the right Cohesive workflow, announces it, and chains the relevant subskills.
---

# Cohesively — the Cohesive router

## What this skill does

Classifies a Cohesive-shaped request, picks one workflow, announces it in one sentence, and dispatches. Cohesive distinguishes itself from Superpowers: **Superpowers optimizes for disciplined implementation; Cohesive optimizes for durable judgment.** Both can run in the same session, and Cohesive composes with Superpowers' `using-git-worktrees`, `code-reviewer`, and `finishing-a-development-branch` skills.

## The three gates (flagship workflow)

The user-facing model is three gates, not five subskills. Substrate plumbing is agent-internal.

| Gate | What the user gets | What runs underneath |
|---|---|---|
| **Decide** | A recommended direction with main risk + structural mitigation | `brainstorm-design` (which dispatches `discover-substrate` internally as Step 0) |
| **Lock** | The direction pinned into specs + an architectural reflection on how the system feels after | `rewrite-specs` + `validate-rewrite` (repair loop internal) |
| **Build** | Code that matches the locked design, with spec-coverage verified | `implement-cohesively` |

The gate vocabulary is the load-bearing chat-surface vocabulary per [`docs/substrate/conventions/audience-separation.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md). Subskill IDs stay the dispatch keys; the user sees gates.

## The three diagnostics (standalone)

| Diagnostic | Use for |
|---|---|
| `cohesive:review-codebase` | Whole-architecture cohesion review |
| `cohesive:review-diff` | PR / branch / working-changes review |
| `cohesive:audit-substrate` | What's missing from the docs and tests |

## Adoption (one-shot)

| Skill | Use for |
|---|---|
| `cohesive:init` | First-time adoption on a codebase with no Cohesive substrate. Scans for proto-substrate (rules in comments, scars in test names, branchy code) and produces a draft substrate with side-by-side translations explaining each Cohesive type in plain terms. The user reviews and keeps what fits. Runs once; refuses if substrate already exists. |

## Routes

Read the user's request and map to one of the routes below. Trigger phrases are primary; topic and verb tense are secondary.

### Route: design (Decide gate)

**When:** Brainstorm or refactor a feature/subsystem. Forward-looking ("add", "refactor", "support", "build").

**Stops at:** A recommended direction with main risk + structural mitigation. The user approves before the Lock gate runs; design conversations often end here.

**Clarifying question (optional, max one):** "Which future pressure should this design optimize for most: <option A>, <option B>, <option C>?"

### Route: rewrite-only (Lock gate)

**When:** A direction has been chosen (from a prior brainstorm, a review, or named by the user) and the user wants the design pinned into specs. "Rewrite the specs for X", "lock in the design for Y", "update the design docs to reflect Z".

**Stops at:** Approved verdict + an Architectural reflection — synthesizing how the architecture feels after the lock and what it makes harder downstream. The user approves before the Build gate runs.

**Clarifying question (required if no direction is named):** "Has a direction been chosen, or should we run brainstorm-design first?"

### Route: implement (Build gate)

**When:** A spec rewrite has been validated (Approved verdict from `validate-rewrite`) and the user wants code that matches it. "Implement the approved rewrite", "build it", "land docs with implementation", "ship the rewrite".

**Stops at:** Code on the branch + a spec-coverage verdict (✓ code matches locked design / ✗ drift in N places).

**Clarifying question (required if the validation review path is not in the user's request):** "Has validate-rewrite returned **Approved** for a spec rewrite, or should I run the design route first?"

The user can decline the Build gate in favor of `superpowers:writing-plans` directly — this skips Cohesive's end-of-run dual reviewer verification of the rewrite, with the user accepting that implementation may drift. Surfaced as the Lock gate's `Implement with Superpowers directly` alternative — conditionally rendered when the rewrite is small enough that the implement-cohesively flow would be ceremony, per `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Conditional alternatives".

### Route: review (codebase)

**When:** Whole codebase or subsystem architecture review. "Review the architecture", "review the codebase", "is this codebase healthy".

**Stops at:** A verdict with thesis + top findings + recommended next step.

### Route: review (diff)

**When:** PR / branch / working-changes review. "Review my PR", "review this diff", "review the change".

**Clarifying question (only if needed):** "Which PR / branch / set of changes? I see <X> uncommitted changes; should I review those, or do you have a PR number?"

### Route: audit (substrate)

**When:** "What memory is missing", "audit substrate", "what specs/invariants/gotchas should we have but don't".

**Stops at:** A ranked list of artifacts to add (specs, invariants, matrices, gotchas) with file:line evidence and a sketch of what each artifact would say.

### Route: init

**When:** First-time adoption on a codebase with no Cohesive substrate. "Initialize cohesive", "set up substrate", "bootstrap cohesive", "we're new to cohesive", "first time using cohesive on this codebase", "init".

**Stops at:** A draft substrate directory at `docs/substrate/init-draft/` containing proposed artifacts with side-by-side translations explaining each Cohesive type in plain terms. The user reviews each draft, edits or deletes, and `git mv`s kept drafts to canonical locations.

The init route is one-shot — `init`'s Hard constraint #1 refuses if substrate already exists. For codebases with existing substrate, the right route is `audit (substrate)`.

### Route: artifact (V1 — deferred)

**When:** "Name an invariant", "encode a behavior matrix", "create a gotcha doc".

**Current behavior (until V1):** Return the relevant template path and offer to fill it out inline. Dedicated artifact skills (`create-invariant`, `create-matrix`) ship in V1.

```
Cohesive v0.1 doesn't yet have a dedicated `<artifact>` skill. The template is at
${CLAUDE_PLUGIN_ROOT}/references/templates/<template>.md. I can fill it out with you now if you like.
```

## Dispatch prompt contract

Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md`, the router-driven case requires explicit prereq-state passing — without it, subskills ask the canonical clarifying question on top of an already-routed turn. The table below is the per-route content the dispatch prompt must include. The matrix-side mirror (with the `validate-rewrite` exception) lives at `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md` §"Dispatch prompt contract"; update both in the same pass. `scripts/validate_plugin.sh` Check 13i greps both surfaces and asserts route-name set equality (the route names — column 1 of each grid — must match across the two surfaces). Prereq-state-string parity across the two surfaces is a HANDOFF_VOCABULARY_PARITY-class check tracked as a deferred Check 13j candidate; for now, that parity is reviewer-judged.

| Route | Prereq state to pass | Chosen-direction / artifact state to pass |
|---|---|---|
| `design` | n/a (discover-substrate is dispatched internally by `brainstorm-design` per its Hard constraint #1) | n/a until step 3; then "approved direction: <option name + summary>"; ledger path passed to step 4 |
| `review (codebase)` | n/a (discover-substrate is dispatched internally by `review-codebase` Phase 1) | n/a |
| `review (diff)` | n/a (discover-substrate is dispatched internally by `review-diff` Step 2, scoped to changed files) | n/a |
| `audit (substrate)` | n/a (discover-substrate is dispatched internally by `audit-substrate` Step 1) | n/a |
| `rewrite-only` | n/a | "Approved direction: <option name + summary>" (or, if user declined, route to `design` first); ledger path passed to step 2 once `rewrite-specs` has produced it |
| `implement` | "Validate-rewrite returned **Approved**; review at <path>." | "Design delta ledger at <path>. Branch: design/<slug>." Validation review path and ledger path are both required. |
| `init` | n/a (init has no prereq; refuses if substrate exists per its Hard constraint #1) | n/a — optional `--brief` flag is the only argument |
| `artifact` | n/a | "Artifact requested: <invariant / matrix / gotcha>" |

Consumers:

- **Internal-discovery consumers** (subskills that dispatch `cohesive:discover-substrate` themselves as Step 0 / Phase 1.0 of their Process): `brainstorm-design`, `audit-substrate`, `review-codebase`, `review-diff`. The router passes no discovery prereq; each consumer skill owns the dispatch internally. The `Optional override` clause in each consumer's Hard constraint #1 lets the router (or a prior session step) supply a pre-existing discovery report path to skip re-running discovery; absent that, the consumer dispatches discovery itself.
- **Chosen-direction / ledger-path consumers**: `rewrite-specs` (chosen direction), `validate-rewrite` (ledger path only — no prereq state; this is the documented exception), `implement-cohesively` (validation review path + ledger path; both required), V1 artifact skills.

Direct (non-router) invocation: the subskill asks its canonical question (about change surface or scope, not about discovery state — discovery is always internal now) per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Clarifying questions". The contract is router-side only.

## Required behavior

1. **Announce the route in one sentence.** The form is just the outcome — no chain rendering, no methodology framing:

   > "<one-sentence outcome the user gets>."

   The outcome leads with what the user receives, per the audience seam in [`docs/substrate/conventions/audience-separation.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md). The form is also documented in [`docs/substrate/conventions/skill-shape.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md) §"Router conventions". The **internal route name** (one of: `design`, `review (codebase)`, `review (diff)`, `audit (substrate)`, `rewrite-only`, `implement`, `init`, `artifact`) is the dispatch key the router uses to pick its chain — it is agent-internal and does not appear in the announcement string. The chain (which subskills run underneath) is internal too; users see gates and outcomes, not subskill IDs. Per-route outcome sentences:

   | Internal route | Announcement outcome sentence |
   |---|---|
   | `design` | I'll explore design tradeoffs and recommend a direction. |
   | `review (codebase)` | I'll review the architecture for cohesion. |
   | `review (diff)` | I'll review the change against the docs. |
   | `audit (substrate)` | I'll find what's missing from the docs and tests. |
   | `rewrite-only` | I'll lock the chosen direction into specs and pressure-test the architecture. |
   | `implement` | I'll build the locked design and verify the code matches it. |
   | `init` | I'll scan your codebase for proto-substrate and produce drafts you can review. |
   | `artifact` | I'll draft the artifact you asked for. |

2. **Process before implementation.** If behavior or architecture is changing, route through the Decide gate before any code. The `implement` route is the structural answer to "implement now" — it dispatches `implement-cohesively`, which drives code against the design delta ledger via single-pass writing-plans + executing-plans + end-of-run dual reviewer dispatch. Freeform code-writing from this skill body is forbidden.

3. **At most one clarifying question per turn.** The router's announcement turn asks at most one forced-choice question per route (forms above) before dispatching the subskill. Per [`docs/substrate/conventions/skill-shape.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md) §"Clarifying questions" → §"Per turn, not per invocation": subskills with multi-turn dialogs (e.g., `brainstorm-design` conversational mode) carry their own per-turn budget after dispatch. Question form is always a specific forced choice, never a vague "what do you want?" prompt. Render forced-choice questions through `AskUserQuestion` per [`references/output-voice.md`](${CLAUDE_PLUGIN_ROOT}/references/output-voice.md) §"Forced-choice questions".

4. **Do not implement code from the router itself.** The router routes; subskills work. Implementation is delegated to the `implement` route, which dispatches `implement-cohesively`. That skill in turn composes `superpowers:writing-plans` and `superpowers:executing-plans` once per implementation pass — it does not write code itself either. Cohesive's only code-producing surface is `superpowers:executing-plans` invoked from inside `implement-cohesively`.

5. **Honor the dispatch prompt contract.** When invoking a subskill, include the relevant fragment from the table above. Subskills depend on this; omitting it produces a duplicate clarifying question on top of an already-routed turn.

6. **Compose with Superpowers when present.** Specifically:
   - Worktrees: `superpowers:using-git-worktrees` (used by `rewrite-specs`)
   - Implementation discipline: `superpowers:writing-plans` and `superpowers:executing-plans` (used per-pass by `implement-cohesively`); `superpowers:test-driven-development` is consumed indirectly via `executing-plans`
   - Branch finishing: `superpowers:finishing-a-development-branch` (recommended after `implement-cohesively` Implemented verdict; user-invoked, never auto-invoked from the router)

7. **Track progress with TodoWrite when chaining 3+ subskills.** The user should see the gates as they execute (Decide / Lock / Build), not the underlying subskill IDs.

## Routing decision logic

When the request is ambiguous, prefer this resolution order:

1. **Explicit user instruction** ("review the codebase" → review/codebase; "init" / "set up substrate" → init). Always wins.
2. **Adoption signal.** "First time using cohesive", "we have no substrate", or running against a codebase where `discover-substrate` would return Empty-substrate verdict → init. The init route is one-shot at adoption time; do not route a returning user with existing substrate to init.
3. **Verb tense and implementation cue.** Imperative implementation verbs against an existing approved rewrite ("implement", "land", "ship", "build it") → implement. Other forward-looking verbs ("add", "refactor", "build", "design") → design. Retrospective ("review", "audit", "what's wrong with") → review.
4. **Scope hints.** Whole-repo / subsystem / "the codebase" → review (codebase). Diff / PR / branch / changes → review (diff). Missing / gaps / what's-not-there → audit (substrate).
5. **Default.** When truly stuck, default to `audit (substrate)` for retrospective requests and `design` for forward-looking ones — these are the two routes most likely to surface what's actually needed.

## Output

The router produces a single-sentence announcement before the first subskill is invoked. Per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` §"Density budgets," the router's render budget is 1 sentence — it has no `#` title and is exempt from the voice-citation grep that applies to longer-rendered skills. The announcement leads with what the user gets — not the methodology framing, not the subskill chain — per the audience seam in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.

The canonical announcement template:

```
<one-sentence outcome from the per-route table in §"Required behavior" #1>
```

Concrete examples:

- design route: `I'll explore design tradeoffs and recommend a direction.`
- review (codebase) route: `I'll review the architecture for cohesion.`
- rewrite-only route: `I'll lock the chosen direction into specs and pressure-test the architecture.`
- implement route: `I'll build the locked design and verify the code matches it.`

Then the router invokes the first subskill. Each subskill produces its own output and recommends the next. The user can stop at any gate boundary.

## Acceptance criteria

- The router classifies every Cohesive-relevant request to exactly one route.
- The route is announced before any subskill runs, in one sentence, with no chain rendering or methodology framing.
- At most one clarifying question is asked per turn, and each is precise (not vague). Subskills with multi-turn conversational modes carry the per-turn budget through the dispatched dialog.
- Code is not produced from the router.
- The user-facing chat-surface vocabulary is the gate vocabulary (Decide / Lock / Build); subskill IDs are agent-internal.
- Long chains (3+ subskills) are tracked with TodoWrite using gate names.
- The dispatch prompt contract is honored — subskills receive prereq/direction state explicitly.

## Red flags

- Rendering the subskill chain (`: skill-1 → skill-2 → skill-3`) in the announcement. Users see gates and outcomes, not subskill IDs.
- Asking "what do you want?" or "can you tell me more?" — both are too vague. If a question is needed, it must be a specific forced choice.
- Routing to multiple workflows in parallel ("I'll do both a design and a review"). Pick one. If the user really wants both, they can ask twice.
- Producing implementation suggestions or code in the router itself. The router routes; subskills do work.
- Dispatching subskills without the announcement. Users need to know which gate they're in.
- Dispatching subskills without the prereq/direction context the dispatch contract requires. Subskills will then ask their canonical question on top of an already-routed turn.
- Using "substrate" as a user-facing chat-surface term in announcements or trailers. Substrate is agent-internal vocabulary; the user-facing surface is the gate vocabulary.

## What this skill is *not*

- Not the workflow itself. The router picks; the subskills work.
- Not a general-purpose AI coding assistant. Cohesive is opinionated about what kinds of work it does.
- Not a replacement for Superpowers. Cohesive handles substrate; Superpowers handles implementation discipline. Use both.
