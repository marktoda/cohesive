# Verdict vocabulary

The chat trailer renders user-facing verdict labels; the substrate (cohesion rubric, dispatch logic, handoffs.md edge contracts, agent verdict vocabularies) keeps the internal labels. Translation happens once, in `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md`'s `**Verdict:**` slot. This file is the single source of truth for the mapping.

## How translation works

Each Cohesive verdict-led skill returns an internal verdict label (the row in its skill's verdict vocabulary). The chat-trailer template renders the user-facing label from the table below. Internal labels stay agent-facing — they are what `cohesion-rubric.md`'s severity-floor mapping, `handoffs.md`'s verdict gates, and `spec-cohesion-reviewer`'s lens-14 checks operate on. User-facing labels are decision-shaped: a fresh reader who has not learned Cohesive's vocabulary can act on them.

Authoring rule: when a skill's internal verdict vocabulary changes, update the corresponding row here in the same pass.

## review-codebase

| Internal label | User-facing label |
|---|---|
| Healthy | **Healthy** — substrate and code agree; safe to proceed |
| Mostly healthy | **Mostly healthy** — minor gaps; proceed with notes |
| Cohesive but under-enforced | **Sound but missing guardrails** — important rules depend on reviewer memory; promote a few to structural enforcement |
| Spec drift risk | **Docs and code are diverging** — repair before further work in this area |
| Architecture risk | **Architecture risk** — the structural shape itself needs revisiting |

## review-diff

| Internal label | User-facing label |
|---|---|
| Pass | **Ready to merge** — substrate is preserved |
| Pass with notes | **Ready to merge — notes inline** — advisory observations, not gating |
| Needs substrate | **Docs need updating before merge** — the change implies updates the docs don't yet carry |
| Risky | **Risk crosses the change boundary** — broader review warranted |
| Block | **Direction conflicts with the design** — revisit before merge |

## validate-rewrite

| Internal label | User-facing label |
|---|---|
| Approved | **Approved — ready to implement** |
| Issues Found | **Issues found — repair pass needed** |
| Design Incoherent | **Design needs revisiting** — the chosen direction is unsound |

## audit-substrate

| Internal label | User-facing label |
|---|---|
| Substrate sound | **Memory is in good shape** — no high-leverage gaps |
| Substrate gaps | **Memory gaps — top fixes below** — add the named artifacts before the next change |
| Substrate sparse | **Repo lacks the memory to audit** — add foundational docs first |

## discover-substrate

`discover-substrate` does not lead with a verdict; the empty-substrate verdict is a structural signal consumed by downstream skills. The chat trailer renders no `**Verdict:**` line for this skill (per the §"Variants" table in `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md`).

## implement-cohesively

| Internal label | User-facing label |
|---|---|
| Implemented | **Implementation complete** — substrate and code agree; ready to merge |
| Coverage Drift | **Coverage gap — re-run to fill** — the implementation missed spec-diff promises; repair the named gaps, then re-run |
| Substrate Drift | **Implementation went beyond the design** — extend the docs to cover it, or revert the divergent code |
| Aborted | **Implementation paused** — branch state is whatever the last implementation commit landed |

## brainstorm-design

`brainstorm-design` does not lead with a verdict; its Recommendation block is the equivalent decision-rendering surface. The chat trailer renders no `**Verdict:**` line for this skill (per the §"Variants" table in `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md`); the body block carries `**Direction:**`, `**Main risk:**`, `**Structural mitigation:**` instead.

## Why translate at the chat trailer, not earlier

Translation lives in the chat-trailer render template — not in `cohesion-rubric.md`, not in agent verdict choice. Three reasons:

1. **Internal labels gate dispatch.** `cohesion-rubric.md` §"Verdict → severity-floor mapping (validate-rewrite)" and §"Disposition rule for validation-review findings" use `Approved` / `Issues Found` / `Design Incoherent` as keys. Translating those at the rubric level would either (a) require updating the dispatching skills' branch logic, or (b) silently break the dispatch contract.
2. **Reviewer agents return internal labels.** Each reviewer agent's "How to structure your output" carries the agent's verdict vocabulary in the canonical six-field finding shape. Translating at the agent would propagate user-facing-vocabulary into the persisted review files, which are agent-facing audit-trail content.
3. **One translation point is reviewable.** A grep for forbidden internal-vocabulary tokens in `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` tests one file, not many. The seam between agent-facing and user-facing rendering lives in one place.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` — the centralized chat shell that consumes this table
- `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` — agent-facing rubric using internal verdict labels
