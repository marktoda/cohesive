# Design Delta Ledger — Phase 1 Substrate

**Date:** 2026-05-04
**Worktree / branch:** main (no prior commits; rewrite happens in main tree)
**Approved direction:** Implement Phase 1 of the self-review's phased roadmap — name the five locked-in invariants, add an AGENTS.md + plan §0 source-of-truth hierarchy, add convention references for skills and reviewer agents, document two known-risk gotchas, encode the router behavior matrix, drop a stale "until V1" template hedge.

This ledger records *what changed* in the substrate during the `rewrite-specs` pass that followed the 2026-05-04 self-review (`docs/cohesive/reviews/2026-05-04-cohesive-self-review.md`). The pass turns Cohesive's own folklore into structural substrate so that the methodology pack can pass its own `cohesive-review --scope codebase` after Phase 2/3 enforcement lands.

## Files rewritten

- `docs/implementation_plan.md`
  - **Before:** Plan opened directly with §1 simplifications. No statement of which document was binding when spec/plan/README disagreed.
  - **After:** New §0 "Source-of-truth hierarchy" added before §1, naming the plan as binding for v0.1, the spec as preserved-vision-only, the README as derived from §2, and on-disk structure as the implementation. `validate_plugin.sh` named as the structural enforcer of plan §2 ↔ on-disk parity.
  - **Reason:** Self-review finding 6 — agents and contributors couldn't tell which doc to update when the four sources of truth disagreed. Plan §0 now answers the question.

- `docs/initial_design.md`
  - **Before:** Spec opened with version metadata and proceeded directly to §1, describing 17 skills and 8 agents normatively, without flagging that the implementation collapsed to 6 + 5.
  - **After:** A "Note (2026-05-04)" banner added near the top stating the spec is preserved-vision-only, with `docs/implementation_plan.md` as binding. §5.1's "Plugin-native structure" section gets a short pointer to plan §2 for the actual v0.1 file structure.
  - **Reason:** Self-review spec-prior issue — readers landing on the spec without reading the plan formed an incorrect mental model. The notes don't rewrite the spec; they re-frame it in place.

- `skills/rewrite-specs/SKILL.md`
  - **Before:** Step 3 named the invariant template as `(V1 template — until then, use the spec format from references/cohesion-rubric.md)`.
  - **After:** Hedge dropped. The invariant template is authoritative and complete; the hedge sent readers to a non-existent fallback (cohesion-rubric.md doesn't define an invariant *format*, only an axis description). Also added a pointer to the new `claimed-system-shape.md` template.
  - **Reason:** Self-review finding 10 — stale hedge would mislead a future agent rewriting specs.

## Files added

- `AGENTS.md` — repo-root contributor guide for agents and humans. Names the source-of-truth hierarchy, the five named invariants, the convention references, and the "when you are about to..." action map.
- `references/skill-conventions.md` — canonical SKILL.md body shape: required vs optional sections, frontmatter format, output schema convention, dispatch discipline, anti-pattern table format.
- `references/reviewer-agent-template.md` — canonical reviewer agent shape: frontmatter with `<example>` blocks, required body sections, the load-bearing fresh-eyes preamble, severity rules, token discipline.
- `references/templates/claimed-system-shape.md` — six-section template for `cohesive-review` Phase 1 output (Product goal / Architectural priors / Intended seams / Named invariants / Testing philosophy / Future direction). Consumed by all four reviewer agents.
- `docs/invariants/PLUGIN_ROOT_PATHS.md` — every internal path uses `${CLAUDE_PLUGIN_ROOT}`.
- `docs/invariants/FRESH_EYES_DISPATCH.md` — Task-tool dispatches to reviewer agents pass paths only and forbid context inheritance.
- `docs/invariants/ROUTER_ANNOUNCES_BEFORE_DISPATCH.md` — `cohesively` emits the canonical workflow announcement before dispatching subskills.
- `docs/invariants/ONE_PRECISE_QUESTION.md` — at most one clarifying question per skill turn; never a vague open prompt.
- `docs/invariants/SUBSKILL_RECOMMENDS_NEXT.md` — every terminal Cohesive skill output names exactly one recommended next skill (one per verdict-branch).
- `docs/cohesive/gotchas/soft-prereqs.md` — symptom + tempting wrong fix + correct pattern for the "subskill produces mediocre output without prior discovery" failure mode.
- `docs/cohesive/gotchas/discovery-vs-superpowers.md` — symptom + correct pattern for the trigger-competition between Cohesive's `discover-substrate` and Superpowers' research/exploration skills.
- `docs/cohesive/router-matrix.md` — behavior matrix for `cohesively`. R001..R014 + R900-series defaults. Replaces prose-only routing decision logic.

## Files removed or deprecated

None this pass. The implementation-plan template (`references/templates/implementation-plan.md`) is flagged in "Remaining ambiguity" — its delete-or-commit decision deferred to user.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| "Plan locks five cross-cutting rules in prose" | Five named invariants under `docs/invariants/` | Tightened (prose → structural artifact) |
| "Soft prereqs may produce mediocre output" (prose risk) | `soft-prereqs.md` gotcha with canonical detection question | Tightened (risk → encoded prevention) |
| "Discovery competition with superpowers" (prose risk) | `discovery-vs-superpowers.md` gotcha with canonical seam pattern | Tightened (risk → encoded prevention) |
| "Routing decision logic" prose in `cohesively/SKILL.md` | `router-matrix.md` with stable cell IDs (R001..R014) | Tightened (prose → matrix) |
| Spec is binding (implicit) | Plan is binding; spec is preserved vision (explicit) | Replaced |
| "(V1 template — until then…)" hedge in rewrite-specs | Authoritative reference to `references/templates/invariant.md` | Removed |
| Skill conventions discoverable only by sibling-imitation | `references/skill-conventions.md` as canonical reference | Tightened |
| Reviewer agent conventions discoverable only by sibling-imitation | `references/reviewer-agent-template.md` as canonical reference | Tightened |
| "Claimed system shape" inline in 5 files | Single template at `references/templates/claimed-system-shape.md` | Tightened (inline duplication → shared template) |

## New or updated substrate

### Specs
- `docs/implementation_plan.md` §0 — source-of-truth hierarchy added.
- `docs/initial_design.md` — preserved-vision banner + §5.1 pointer to plan §2.

### Behavior matrices
- `docs/cohesive/router-matrix.md` — R001..R014 cells for the six router routes plus four ambiguous-default cells; R900-series for fall-through behavior.

### Named invariants
- `PLUGIN_ROOT_PATHS` — added; current scope: every internal path reference in skills/agents/references/scripts/generated outputs.
- `FRESH_EYES_DISPATCH` — added; current scope: every Task-tool dispatch from a Cohesive skill + every reviewer agent's "What you must not do" section.
- `ROUTER_ANNOUNCES_BEFORE_DISPATCH` — added; current scope: `cohesively` invocations.
- `ONE_PRECISE_QUESTION` — added; current scope: every Cohesive skill turn that asks a clarifying question.
- `SUBSKILL_RECOMMENDS_NEXT` — added; current scope: every terminal Cohesive skill output (one recommendation per verdict-branch).

### Gotchas
- `soft-prereqs` — added; documents the "mediocre output when prior discovery is assumed" failure mode and the canonical "ask the user" detection pattern.
- `discovery-vs-superpowers` — added; documents the trigger-competition between Cohesive and Superpowers and the canonical seam (router as canonical entry, descriptions narrowed to substrate-specific work).

### Semantic linter specs (proposed, not implemented)

The five invariants name their semantic linters. None are implemented in v0.1; all live in `scripts/validate_plugin.sh` as Phase 3 work:

- `PLUGIN_ROOT_PATHS` → grep for `/home/`, `/Users/`, `/usr/`, `~/` outside anti-pattern blocks.
- `FRESH_EYES_DISPATCH` → grep each `agents/*.md` for the canonical "Inherit conversation context" bullet; grep skill bodies for Task dispatches and assert nearby fresh-eyes prose.
- `ROUTER_ANNOUNCES_BEFORE_DISPATCH` → grep `cohesively/SKILL.md` for the canonical announcement template (regex anchored on "I'm treating this as a Cohesive").
- `ONE_PRECISE_QUESTION` → grep each SKILL.md for forbidden phrases ("what do you want", "tell me more", "anything else") outside anti-pattern blocks.
- `SUBSKILL_RECOMMENDS_NEXT` → parse each SKILL.md's "Output format" code block for `### Recommended next Cohesive skill`.

### Tests / checks proposed (not yet implemented)

All deferred to Phase 3 of the self-review's phased roadmap:

- `tests/output_schema/` — one canned output per skill plus a header-presence parser.
- `.github/workflows/validate.yml` — runs `validate_plugin.sh` on every PR.
- `scripts/check_worktree_fallback.sh` — exercises the inline worktree fallback in a tmp git repo.
- Manual scenario test: `cohesive:brainstorm-design` invoked without prior discovery should ask the canonical question (per `soft-prereqs` gotcha).
- Manual scenario test: with both Cohesive and Superpowers installed, "audit substrate" picks Cohesive; "explore the auth flow" picks Superpowers.
- Manual scenario test: every router invocation produces an announcement matching the canonical form (per `ROUTER_ANNOUNCES_BEFORE_DISPATCH`).

## What this rewrite *did not* do

- Implementation code: not changed.
- Tests: not changed (specifications proposed for Phase 3 follow-up).
- CI: not changed (`.github/workflows/` still does not exist).
- `scripts/validate_plugin.sh` semantic linters: not extended (Phase 3).
- The `references/templates/implementation-plan.md` delete-or-commit decision: not made (deferred to user; see Remaining ambiguity).
- `cohesive-review --scope substrate` mode split: not made (Phase 2 of the roadmap).
- `scripts/scan_substrate.py:82` precedence bug: not fixed (Phase 2).
- Second dogfood transcript against an external repo: not produced (a release-blocker for v0.1 but outside this rewrite's scope).
- README.md update: not modified (the new substrate doesn't change README §"What's in the box," but a future pass should cite AGENTS.md and the invariants in the README's installation section).

## Remaining ambiguity

- **`references/templates/implementation-plan.md` decision.** The self-review flagged this as Phase 1 work: delete the template (no MVP consumer) or commit by introducing the V1 `plan-implementation` skill. Both are valid; the user owns this call. The template currently sits unused.
- **Where `docs/invariants/` lives.** `AGENTS.md` and the rewritten plan use `docs/invariants/`. The original spec §5.1 implied a different location (some artifacts under `docs/`, some under `docs/cohesive/`). v0.1 settles on `docs/invariants/` for repo-level invariants and `docs/cohesive/<topic>/` for topic-specific artifacts (gotchas, matrices, design deltas). If the user prefers `docs/cohesive/invariants/` for symmetry, the five files plus the references that cite them need to move.
- **README §"What's in the box" sync.** The new files (AGENTS.md, the five invariants, two gotchas, router matrix, two convention references, claimed-system-shape template) are not yet listed in the README. They should be added in the next pass to keep README ↔ plan §2 ↔ on-disk parity, and a small section noting "Cohesive's own substrate" should be added.
- **No commit yet.** The repo currently has zero commits; every file is untracked. The rewrite-specs convention is a single atomic commit per pass, but creating the initial commit on `main` is a destructive-shaped action the user should approve. After approval: `git add -A && git commit -m "design: rewrite specs for phase-1-substrate"` per the skill's step 6.
- **Spec-cohesion review.** The handoff to `cohesive:review-spec-cohesion` is the next Cohesive workflow. The reviewer should read this ledger plus all listed added/rewritten files and judge whether the rewrite is implementable and internally coherent.

## Ready for fresh-eyes review?

**Yes** — for the rewrite content. The remaining ambiguity items above are user decisions, not unresolved design questions. The reviewer should evaluate whether the five named invariants are precise, scoped correctly, and enforceable; whether the two gotchas correctly capture symptom + tempting wrong fix + correct pattern; whether the router matrix covers the route space without contradiction; and whether the convention references match the existing skill/agent shapes.

## How to read this ledger

1. Read the "Approved direction" line: Phase 1 of the 2026-05-04 self-review's phased roadmap.
2. Skim "Conceptual changes" for the prose-to-substrate moves.
3. Read the five invariant docs in `docs/invariants/` — that's the highest-leverage substrate this pass produced.
4. Use "Remaining ambiguity" as the focused review punch list.
