# Cohesively Router Behavior Matrix

**Status:** Draft
**Last reviewed:** 2026-05-04
**Owner:** Mark Toda

## Purpose

The router (`cohesively`) selects one of seven routes based on the user's request. Each route is branchy in three dimensions: verb tense (forward-looking vs retrospective vs implementation-imperative), scope hint (whole-repo vs subsystem vs diff vs missing-memory vs approved-rewrite-present), and explicitness (explicit instruction vs ambiguous request). This matrix enumerates the (input shape × selected route) cells with stable IDs so future contributors can reason about routing without reading prose.

The matrix is normative. When a user request matches a row, the router must select that row's route. When a request matches no row, the router falls through to the default rule (R900-series) and emits the canonical announcement plus a one-precise-question if needed.

## Cells

| Cell ID | Scenario | Input shape | Expected route | Notes | Tests |
|---|---|---|---|---|---|
| R001 | Forward-looking on a subsystem | "add retry behavior for webhook delivery" | `design` | Verb tense + subsystem name; substrate-first design flow | _none_ |
| R002 | Forward-looking on whole repo | "refactor the intake classifier" | `design` (whole-repo) | Same chain; broader change surface | _none_ |
| R003 | Explicit "review the architecture" | "review the architecture" / "review the codebase" / "is this codebase healthy" | `review (codebase)` | Always wins per resolution rule 1 | _none_ |
| R004 | Architecture review of named subsystem | "architecture review of the intake module" | `review (codebase)` scoped | Pass subsystem hint to `review-codebase` | _none_ |
| R005 | Explicit PR review with PR number | "review PR 1234" | `review (diff)` | Skill fetches diff via `gh pr diff 1234` | _none_ |
| R006 | Branch / working-changes review | "review my diff" / "review this branch" / "review my changes" | `review (diff)` | Skill detects diff via `git diff main...HEAD` | _none_ |
| R007 | Substrate audit explicit | "what memory is missing" / "audit substrate" / "what specs/invariants should we have" | `audit (substrate)` | Invokes the standalone `audit-substrate` skill (single-pass scan, no reviewer-agent dispatch) | _none_ |
| R008 | Rewrite-only with named direction | "rewrite the specs for [chosen Option C]" / "update design docs to reflect Y" | `rewrite-only` | User has chosen direction; skip brainstorm | _none_ |
| R009 | Rewrite-only without named direction | "rewrite the specs for X" (no direction in input) | `rewrite-only` (with question) | Asks the canonical clarifying question per the clarifying-question convention in `docs/substrate/conventions/skill-shape.md`; user can answer "run brainstorm first" | _none_ |
| R010 | Artifact request (V1 deferred) | "name an invariant" / "encode a behavior matrix" / "create a gotcha doc" | `artifact` | Returns template path + offers inline fill; dedicated artifact skills ship in V1 | _none_ |
| R011 | Ambiguous "review X" with X being a small change set | "review the changes I just made" with <500 line diff | `review (diff)` | Default per resolution rule 3 (diff-shaped scope) | _none_ |
| R012 | Ambiguous "review X" with X being whole repo | "review the project" / "review the system" | `review (codebase)` | Default per resolution rule 3 (whole-repo scope) | _none_ |
| R013 | Ambiguous retrospective | "look at the auth code" with no scope hint | `audit (substrate)` | Default per resolution rule 4 (retrospective + ambiguous) | _none_ |
| R014 | Ambiguous forward-looking | "thinking about how to handle Slack" | `design` | Default per resolution rule 4 (forward-looking + ambiguous) | _none_ |
| R015 | Implement after approved rewrite | "implement the approved rewrite" / "land docs with implementation" / "implement-cohesively" / "drive implementation against the delta" / "ship the rewrite" | `implement` | Requires existing `validate-rewrite` Approved verdict + design delta ledger; dispatches `cohesive:implement-cohesively` (which composes `superpowers:writing-plans` + `superpowers:executing-plans` per phase). Closes the failure mode in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/no-implementation-handoff.md`. | _none_ |
| R016 | Implement-shaped request without approved rewrite | "implement now" / "let's ship this" / "land it" with no recent `validate-rewrite` Approved verdict | `implement` (with question) | Asks the canonical clarifying question per the clarifying-question convention in `docs/substrate/conventions/skill-shape.md` (route-classification level only; `implement-cohesively` itself uses directive errors per `docs/substrate/conventions/skill-shape.md` §"Path prereqs use directive errors, not the canonical question"); user can answer "run the design route first" or pass an Approved verdict path. | _none_ |
| R017 | First-time adoption on a codebase with no Cohesive substrate | "initialize cohesive" / "set up substrate" / "bootstrap cohesive" / "we're new to cohesive" / "first time using cohesive on this codebase" / "init" | `init` | Dispatches `cohesive:init`. Refuses if substrate already exists (init's Hard constraint #1) — for codebases with existing substrate, route is `audit (substrate)`. Closes the day-1 chicken-and-egg problem named in `${CLAUDE_PLUGIN_ROOT}/docs/history/reviews/2026-05-06-cohesive-pack-simplification-architecture-review.md`. | _none_ |

## Default cells (used when no specific row matches)

| Cell ID | Scenario | Selected route | Why |
|---|---|---|---|
| R900 | Verb tense + scope hint both unclear | Ask the canonical clarifying question | Per the clarifying-question convention in `docs/substrate/conventions/skill-shape.md`; never default-route silently |
| R901 | User asks for two routes simultaneously ("design AND review X") | Pick one; user can ask twice | Per `cohesively/SKILL.md` Red flags |

## Rules

- Every cell has a stable ID (R001..R0NN). Once assigned, an ID is never reused even if the cell is removed.
- Tests should be named after matrix cells where practical (`test_R007_substrate_audit_trigger`).
- New routes added to the router require new cells *before* implementation.
- The router's announcement (per the router-announcement convention in `docs/substrate/conventions/skill-shape.md`) names the selected cell ID for transcript-traceability when in doubt.
- When two cells could both apply, the resolution order from `cohesively/SKILL.md`'s "Routing decision logic" wins: explicit instruction → verb tense → scope hint → default.

## Dispatch prompt contract (per route)

When the router dispatches a subskill, the dispatch prompt carries explicit prereq state and chosen-direction state so the subskill skips its canonical clarifying question (closes the soft-prereqs gotcha's "router-driven case" exemption). This grid mirrors the table in `${CLAUDE_PLUGIN_ROOT}/skills/cohesively/SKILL.md` §"Dispatch prompt contract" and is the matrix-side pin for that contract.

| Route | First subskill | Prereq state passed | Chosen-direction state passed | Notes |
|---|---|---|---|---|
| `design` | `discover-substrate` | _none (no prereq)_ | _none (not yet chosen)_ | Step 1; brainstorm-design step receives discovery report path; rewrite-specs step (only if reached) receives chosen direction; validate-rewrite step (only if reached) receives ledger path. |
| `review (codebase)` | `discover-substrate` (or skip if reused) | "Discovery already complete; report at <path>" passed to `review-codebase` | n/a | Discovery prereq closes the soft-prereqs gotcha. |
| `review (diff)` | `discover-substrate` (scoped to changed files) | "Discovery already complete (scoped to <changed-files>); report at <path>" passed to `review-diff` | n/a | Same shape, narrower scope. |
| `audit (substrate)` | `discover-substrate` (or skip if reused) | "Discovery already complete; report at <path>" passed to `audit-substrate` | n/a | Single subskill consumer; no synthesis. |
| `rewrite-only` | `rewrite-specs` | n/a (no discovery prereq for rewrite-specs) | "Approved direction: <option name + summary>" passed to `rewrite-specs`; ledger path passed to `validate-rewrite` once rewrite produces it | If user has not chosen a direction, route to `design` first. |
| `implement` | `implement-cohesively` | "Validate-rewrite returned **Approved**; review at <path>." passed to `implement-cohesively` | "Design delta ledger at <path>. Branch: design/<slug>." passed to `implement-cohesively` | Both prereq state and ledger path are required. If either is missing, the router asks cell R016's clarifying question. |
| `init` | `init` | n/a (init has no Cohesive prereq; refuses if substrate already exists per its Hard constraint #1) | n/a — optional `--brief` flag is the only argument | One-shot at adoption time. The substrate-vocabulary translation init renders comes from `${CLAUDE_PLUGIN_ROOT}/references/substrate-vocabulary.md`, not from the dispatch prompt. |
| `artifact` (V1) | template return + offer | n/a | "Artifact requested: <invariant / matrix / gotcha>" | V1: dedicated artifact skills will replace the template-return shape. |

### Dispatch contract exceptions

- **`validate-rewrite` does not consume prereq state.** It has no `discover-substrate` prereq. Its router-passed input is always the design delta ledger path produced by an earlier `rewrite-specs` step (in the `design` or `rewrite-only` route). Treating `validate-rewrite` as a prereq-state consumer is the predictable extension footgun this row exists to prevent.
- **`implement-cohesively` consumes a non-discovery prereq state: a validate-rewrite Approved verdict.** This is the second documented exception to the "prereq = discover-substrate" pattern. The structural reason is the same in both cases — the prereq is a *workflow* prereq, not a *substrate-discovery* prereq. Because the prereq is materially a file path (not session state), `implement-cohesively` does not have a canonical clarifying question; it produces a **directive error** when paths are missing, per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Path prereqs use directive errors, not the canonical question". The router's own canonical question (cell R016) still applies at the route-classification level — it's the router asking which route to dispatch, not the subskill asking whether discovery happened.

This grid is normative. Adding a route or subskill requires updating this section *and* `${CLAUDE_PLUGIN_ROOT}/skills/cohesively/SKILL.md` §"Dispatch prompt contract" in the same pass. Drift between the two surfaces produces the exact "soft-prereqs" failure mode the contract closes; `scripts/validate_plugin.sh` Check 13i greps both surfaces and asserts route-name set equality (the route names — column 1 of each grid — must match across the two surfaces) to catch route-set drift mechanically. Prereq-state-string parity across the two surfaces is a HANDOFF_VOCABULARY_PARITY-class check tracked as a deferred Check 13j candidate; for now, that parity is reviewer-judged.

## Removed cells

| Cell ID | Removed on | Reason |
|---|---|---|
| _none yet_ | | |

## Out of scope

- **Behavior of the subskills themselves.** This matrix encodes route selection only. What `discover-substrate` does in route `design` is the subskill's behavior, not the router's, and lives in the subskill's own SKILL.md.
- **Multi-step workflow chaining within a route.** Each route has a chain (`discover-substrate → brainstorm-design`), and the chain is part of the route definition in `cohesively/SKILL.md`. The matrix encodes the (input → route) mapping, not the (route → chain) mapping.
- **Direct subskill invocation.** A user invoking `/cohesive:review-codebase` skips the router entirely. This matrix governs only the router's behavior.

## Notes

- If a new contributor would need to read implementation files to know which route fires for some user input, add a cell for that input.
- If a cell description begins with "should" or "probably," the cell isn't ready — tighten the language before considering the matrix complete.
- Cells R011, R012, R013, R014 are the default rules expanded into matrix cells. They exist so default behavior is testable, not just inferable.

## Related substrate

- **`docs/substrate/conventions/skill-shape.md`** §"Router conventions" — the router-announcement and clarifying-question conventions every cell selection complies with.
- **`skills/cohesively/SKILL.md`** — the router skill body. This matrix is the test artifact for that skill.

## History

- 2026-05-04 — Created. Promoted from prose-only routing decision logic in `cohesively/SKILL.md:99-106` to a behavior matrix with stable cell IDs.
- 2026-05-04 — Substrate collapse: cell R007's chain switched from `cohesive-review --scope substrate` to the standalone `substrate-audit` skill. References to demoted invariants (`ROUTER_ANNOUNCES_BEFORE_DISPATCH`, `ONE_PRECISE_QUESTION`) replaced with pointers to the conventions doc that now carries those rules.
- 2026-05-04 — v0.1 release-lexicon rename: route `review (substrate audit)` renamed to `audit (substrate)` for parallel verb-noun shape; cell R007's standalone skill renamed `substrate-audit` → `audit-substrate`; `cohesive-review` split into `review-codebase` and `review-diff`; `review-spec-cohesion` renamed `validate-rewrite`. Cell IDs preserved per immutability rule.
- 2026-05-04 — `implement` route added: cells R015 (explicit "implement the approved rewrite") and R016 (implement-shaped request without prerequisites) added. Dispatch contract row added for `implement` with both prereq-state and ledger-path passing. Second documented exception added to dispatch-contract exceptions section: `implement-cohesively` consumes a workflow-prereq (Approved verdict) rather than a discovery-prereq.
