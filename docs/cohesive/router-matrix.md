# Cohesively Router Behavior Matrix

**Status:** Draft
**Last reviewed:** 2026-05-04
**Owner:** Mark Toda

## Purpose

The router (`cohesively`) selects one of six routes based on the user's request. Each route is branchy in three dimensions: verb tense (forward-looking vs retrospective), scope hint (whole-repo vs subsystem vs diff vs missing-memory), and explicitness (explicit instruction vs ambiguous request). This matrix enumerates the (input shape × selected route) cells with stable IDs so future contributors can reason about routing without reading prose.

The matrix is normative. When a user request matches a row, the router must select that row's route. When a request matches no row, the router falls through to the default rule (R900-series) and emits the canonical announcement plus a one-precise-question if needed.

## Cells

| Cell ID | Scenario | Input shape | Expected route | Notes | Tests |
|---|---|---|---|---|---|
| R001 | Forward-looking on a subsystem | "add retry behavior for webhook delivery" | `design` | Verb tense + subsystem name; substrate-first design flow | _none_ |
| R002 | Forward-looking on whole repo | "refactor the intake classifier" | `design` (whole-repo) | Same chain; broader change surface | _none_ |
| R003 | Explicit "review the architecture" | "review the architecture" / "review the codebase" / "is this codebase healthy" | `review (codebase)` | Always wins per resolution rule 1 | _none_ |
| R004 | Architecture review of named subsystem | "architecture review of the intake module" | `review (codebase)` scoped | Pass subsystem hint to `cohesive-review --scope codebase` | _none_ |
| R005 | Explicit PR review with PR number | "review PR 1234" | `review (diff)` | Skill fetches diff via `gh pr diff 1234` | _none_ |
| R006 | Branch / working-changes review | "review my diff" / "review this branch" / "review my changes" | `review (diff)` | Skill detects diff via `git diff main...HEAD` | _none_ |
| R007 | Substrate audit explicit | "what memory is missing" / "audit substrate" / "what specs/invariants should we have" | `review (substrate audit)` | No subagent dispatch; single-pass scan | _none_ |
| R008 | Rewrite-only with named direction | "rewrite the specs for [chosen Option C]" / "update design docs to reflect Y" | `rewrite-only` | User has chosen direction; skip brainstorm | _none_ |
| R009 | Rewrite-only without named direction | "rewrite the specs for X" (no direction in input) | `rewrite-only` (with question) | Asks the canonical clarifying question per `ONE_PRECISE_QUESTION`; user can answer "run brainstorm first" | _none_ |
| R010 | Artifact request (V1 deferred) | "name an invariant" / "encode a behavior matrix" / "create a gotcha doc" | `artifact` | Returns template path + offers inline fill; dedicated artifact skills ship in V1 | _none_ |
| R011 | Ambiguous "review X" with X being a small change set | "review the changes I just made" with <500 line diff | `review (diff)` | Default per resolution rule 3 (diff-shaped scope) | _none_ |
| R012 | Ambiguous "review X" with X being whole repo | "review the project" / "review the system" | `review (codebase)` | Default per resolution rule 3 (whole-repo scope) | _none_ |
| R013 | Ambiguous retrospective | "look at the auth code" with no scope hint | `review (substrate audit)` | Default per resolution rule 4 (retrospective + ambiguous) | _none_ |
| R014 | Ambiguous forward-looking | "thinking about how to handle Slack" | `design` | Default per resolution rule 4 (forward-looking + ambiguous) | _none_ |

## Default cells (used when no specific row matches)

| Cell ID | Scenario | Selected route | Why |
|---|---|---|---|
| R900 | Verb tense + scope hint both unclear | Ask the canonical clarifying question | Per `ONE_PRECISE_QUESTION`; never default-route silently |
| R901 | User asks for two routes simultaneously ("design AND review X") | Pick one; user can ask twice | Per `cohesively/SKILL.md` Red flags |

## Rules

- Every cell has a stable ID (R001..R0NN). Once assigned, an ID is never reused even if the cell is removed.
- Tests should be named after matrix cells where practical (`test_R007_substrate_audit_trigger`).
- New routes added to the router require new cells *before* implementation.
- The router's announcement (per `ROUTER_ANNOUNCES_BEFORE_DISPATCH`) names the selected cell ID for transcript-traceability when in doubt.
- When two cells could both apply, the resolution order from `cohesively/SKILL.md`'s "Routing decision logic" wins: explicit instruction → verb tense → scope hint → default.

## Removed cells

| Cell ID | Removed on | Reason |
|---|---|---|
| _none yet_ | | |

## Out of scope

- **Behavior of the subskills themselves.** This matrix encodes route selection only. What `discover-substrate` does in route `design` is the subskill's behavior, not the router's, and lives in the subskill's own SKILL.md.
- **Multi-step workflow chaining within a route.** Each route has a chain (`discover-substrate → brainstorm-design`), and the chain is part of the route definition in `cohesively/SKILL.md`. The matrix encodes the (input → route) mapping, not the (route → chain) mapping.
- **Direct subskill invocation.** A user invoking `/cohesive:cohesive-review --scope codebase` skips the router entirely. This matrix governs only the router's behavior.

## Notes

- If a new contributor would need to read implementation files to know which route fires for some user input, add a cell for that input.
- If a cell description begins with "should" or "probably," the cell isn't ready — tighten the language before considering the matrix complete.
- Cells R011, R012, R013, R014 are the default rules expanded into matrix cells. They exist so default behavior is testable, not just inferable.

## Related substrate

- **`docs/invariants/ROUTER_ANNOUNCES_BEFORE_DISPATCH.md`** — every cell's selection produces an announcement.
- **`docs/invariants/ONE_PRECISE_QUESTION.md`** — cells that ask a clarifying question (R009, R900) must comply.
- **`skills/cohesively/SKILL.md`** — the router skill body. This matrix is the test artifact for that skill.

## History

- 2026-05-04 — Created. Promoted from prose-only routing decision logic in `cohesively/SKILL.md:99-106` to a behavior matrix with stable cell IDs.
