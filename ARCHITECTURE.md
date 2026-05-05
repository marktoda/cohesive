# Architecture

> Substrate-first agentic engineering, delivered as a Claude Code plugin. Helps a codebase remember.

This is the binding architectural map. Hook lines point at the design docs, invariants, and conventions that carry the detail. Update this file when the broad shape changes or a hook needs adjusting; let the deeper docs absorb the rest.

## Three-tier architecture

Cohesive is a Claude Code plugin organized in three implementation tiers under `${CLAUDE_PLUGIN_ROOT}`. Implementation is what *plugin users get*; substrate is contributor-facing rules about *this repo itself*.

- **`skills/`** — workflow orchestration. The router (`cohesively`) and seven subskills are the user-facing surface. Each skill is a process; skills do not run reviews directly.
- **`agents/`** — fresh-context reviewer agents. Dispatched via the Task tool with explicit input paths. They do not inherit conversation context; each review runs in a clean subprocess.
- **`references/`** — runtime methodology cited by skills and agents during the workflow: the rubrics (`cohesion-rubric.md`, `architecture-review-rubric.md`), the design pressure-test battery, the locality-over-centralization principle, the substrate model, the chat-render voice guide (`output-voice.md`), and `templates/` — fillable forms skills consume to produce artifacts. All shipped to plugin users.

The fourth layer — substrate at `docs/substrate/**` — governs *this codebase*. Contributor-facing: rules for writing skills here (`skill-conventions.md`), the canonical reviewer-agent shape (`reviewer-agent-template.md`), where this repo's artifacts live (`substrate-layout.md`), this repo's named invariants, gotchas, and matrices, plus cross-cutting design docs. History at `docs/history/**` carries workflow products, plans, and transcripts.

The split (contributor-facing substrate vs user-facing implementation) is the load-bearing structural decision. → see [`docs/substrate/designs/three-layer-architecture.md`](docs/substrate/designs/three-layer-architecture.md).

## Composition over reinvention

Cohesive composes with [Superpowers](https://github.com/obra/superpowers) rather than reinventing implementation discipline:

- Worktrees come from `superpowers:using-git-worktrees` (with a 5-line inline fallback when not installed)
- Plan execution from `superpowers:executing-plans`
- Branch finishing from `superpowers:finishing-a-development-branch`

Cohesive owns substrate; Superpowers owns implementation. The seam between the two is documented and intentional. → see [`docs/substrate/designs/composition-with-superpowers.md`](docs/substrate/designs/composition-with-superpowers.md).

## Fresh-eyes review

Reviewer agents run in isolated subprocesses with no conversation-context inheritance. The dispatching skill passes inputs as explicit file paths; the agent system prompt forbids reading prior conversation. This is the load-bearing safety property of every Cohesive review — without it, reviews degrade to performance. The harness's Task-tool isolation provides the structural fence; the agent-file preamble is convention reinforcement. → see [`docs/substrate/designs/agent-dispatch-protocol.md`](docs/substrate/designs/agent-dispatch-protocol.md).

## Substrate

Current canonical substrate lives under `docs/substrate/`:

- **[`invariants/`](docs/substrate/invariants/)** — named global rules with structural enforcement. v0.1 ships two: `PLUGIN_ROOT_PATHS` (every internal path uses `${CLAUDE_PLUGIN_ROOT}`) and `VERDICT_BEFORE_EVIDENCE` (every verdict-led skill's Output format block opens with `**Verdict:**` within the first three non-blank lines). Both enforced by `scripts/validate_plugin.sh`. These are the rules with concrete failure modes that justify mechanical enforcement; other rules live as conventions until their wording stabilizes and a real failure mode justifies promotion.
- **[`gotchas/`](docs/substrate/gotchas/)** — documented scars. Each names a symptom, a tempting wrong fix, and the correct pattern.
- **[`matrices/`](docs/substrate/matrices/)** — branchy behavior written down as cells with stable IDs. The router behavior matrix lives here.
- **[`designs/`](docs/substrate/designs/)** — cross-cutting design docs that span multiple components.

Workflow products (reviews, design delta ledgers, transcripts) and retired historical docs live under [`docs/history/`](docs/history/).

## Conventions

- **Skill conventions** — required body sections, frontmatter shape, output format, router announcement form, clarifying-question discipline, recommended-next-skill output blocks, anti-patterns: [`docs/substrate/designs/skill-conventions.md`](docs/substrate/designs/skill-conventions.md).
- **Reviewer agent conventions** — required sections, the canonical fresh-eyes preamble: [`docs/substrate/designs/reviewer-agent-template.md`](docs/substrate/designs/reviewer-agent-template.md).
- **Output voice and density** — chat-render rules (verdict-leads, header-depth cap, density budgets, forbidden phrasings, faithful-subset-of-persisted-file): [`references/output-voice.md`](references/output-voice.md). Runtime methodology cited from every Output format block; companion worked transcript at [`docs/history/transcripts/output-voice-worked-example.md`](docs/history/transcripts/output-voice-worked-example.md).
- **Path discipline** — every internal reference uses `${CLAUDE_PLUGIN_ROOT}/...`. Enforced by [`PLUGIN_ROOT_PATHS`](docs/substrate/invariants/PLUGIN_ROOT_PATHS.md).
- **Verdict discipline** — every verdict-led skill leads with the verdict. Enforced by [`VERDICT_BEFORE_EVIDENCE`](docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md).
- **Source-of-truth hierarchy** — this doc is binding for current architecture. The README §"What's in the box" is derived from this doc and from on-disk reality. The historical plan at [`docs/history/plans/2026-05-04-mvp-implementation.md`](docs/history/plans/2026-05-04-mvp-implementation.md) is preserved as the dated artifact that drove v0.1; not authoritative for current state.
- **Default artifact dir for Cohesive run against external repos:** `docs/cohesive/<x>/` with detection of existing repo conventions (`docs/design/`, `docs/specs/`, `docs/adr/`, `docs/invariants/`, `docs/gotchas/`, `docs/substrate/`, `docs/history/`) — prefer existing if present.
- **Local validation only.** `scripts/validate_plugin.sh` runs locally. CI is out of scope for v0.1.

## Where to look first

| If you're about to... | Start here |
|---|---|
| Add or modify a skill | [`docs/substrate/designs/skill-conventions.md`](docs/substrate/designs/skill-conventions.md) and the closest existing skill |
| Add or modify a reviewer agent | [`docs/substrate/designs/reviewer-agent-template.md`](docs/substrate/designs/reviewer-agent-template.md) |
| Modify the router | [`docs/substrate/matrices/router.md`](docs/substrate/matrices/router.md) and [`docs/substrate/designs/skill-conventions.md`](docs/substrate/designs/skill-conventions.md) §"Router conventions" |
| Touch any path reference | [`PLUGIN_ROOT_PATHS`](docs/substrate/invariants/PLUGIN_ROOT_PATHS.md) |
| Author or revise an Output format block (or any chat-rendered output) | [`references/output-voice.md`](references/output-voice.md) and the worked transcript |
| Add or change a skill's verdict | [`VERDICT_BEFORE_EVIDENCE`](docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md) |
| Dispatch a reviewer agent | [`docs/substrate/designs/agent-dispatch-protocol.md`](docs/substrate/designs/agent-dispatch-protocol.md) |
| Run Cohesive against this repo | `cohesive:review-codebase` — output lands in [`docs/history/reviews/`](docs/history/reviews/) |

## Risks the design accepts

- **Discovery competition with Superpowers.** Both plugins have skills that look like discovery; the seam is documented in [`discovery-vs-superpowers.md`](docs/substrate/gotchas/discovery-vs-superpowers.md).
- **Soft prereqs may produce mediocre output.** When subskills are invoked without prior substrate discovery, output quality degrades. Detection pattern in [`soft-prereqs.md`](docs/substrate/gotchas/soft-prereqs.md).
- **Reviewer token budgets.** Token discipline is part of every reviewer agent's contract but is enforced by reviewer judgment, not structurally.
- **Behavior matrix template is unproven** until real-world matrices are produced from external repos.
- **Conventions over invariants.** Most v0.1 rules (chat-render header-depth cap, density budgets, forbidden phrasings, fresh-eyes preamble, router announcement, clarifying questions) live as convention, not enforced invariant. Two rules graduated to invariant — `PLUGIN_ROOT_PATHS` (a runtime correctness rule) and `VERDICT_BEFORE_EVIDENCE` (the most-regressed UX rule with the cleanest grep). Promotion is deliberate; convention status is intentional where wording is still settling.

## v0.1 scope

The plugin ships 8 skills, 5 reviewer agents, 6 runtime references under `references/` (cohesion-rubric, design-pressure-testing, locality-over-centralization, architecture-review-rubric, substrate-model, output-voice), 9 fillable templates under `references/templates/`, 6 contributor-facing substrate design docs under `docs/substrate/designs/` (skill-conventions, reviewer-agent-template, substrate-layout, three-layer-architecture, composition-with-superpowers, agent-dispatch-protocol), and 2 scripts. The 2026-05-04 `cut-anchor-pin` rewrite hard-cut the contributor-vs-user-facing split: rules about *this repo* live in `docs/substrate/`; the workflow methodology shipped to plugin users lives in `references/` and is cited by skills/agents at runtime. The dated milestone plan that drove v0.1 is preserved at [`docs/history/plans/2026-05-04-mvp-implementation.md`](docs/history/plans/2026-05-04-mvp-implementation.md). The original design vision (more ambitious surface, since trimmed) is at [`docs/history/initial-design.md`](docs/history/initial-design.md).

The user-facing skill set is the four-step workflow chain `discover-substrate → brainstorm-design → rewrite-specs → validate-rewrite` (plus the `cohesively` router) and the three off-chain diagnostics `review-codebase`, `review-diff`, `audit-substrate`.
