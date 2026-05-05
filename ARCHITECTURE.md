# Architecture

> Substrate-first agentic engineering, delivered as a Claude Code plugin. Helps a codebase remember.

This is the binding architectural map. Hook lines point at the design docs, invariants, and conventions that carry the detail. Update this file when the broad shape changes or a hook needs adjusting; let the deeper docs absorb the rest.

## Three-tier architecture

Cohesive is a Claude Code plugin organized in three implementation tiers under `${CLAUDE_PLUGIN_ROOT}`. Implementation is what *plugin users get*; substrate is contributor-facing rules about *this repo itself*.

- **`skills/`** — workflow orchestration. The router (`cohesively`) plus eight subskills make nine skills total; this is the user-facing surface. Each skill is a process; skills do not run reviews directly. The `implement-cohesively` skill is the only one that produces code, and it does so by composing `superpowers:executing-plans` per phase rather than writing code directly.
- **`agents/`** — fresh-context reviewer agents. Dispatched via the Task tool with explicit input paths. They do not inherit conversation context; each review runs in a clean subprocess.
- **`references/`** — runtime methodology cited by skills and agents during the workflow: the rubrics (`cohesion-rubric.md`, `architecture-review-rubric.md`), the design pressure-test battery, the locality-over-centralization principle, the substrate model, the chat-render voice guide (`output-voice.md`), and `templates/` — fillable forms skills consume to produce artifacts. All shipped to plugin users.

The fourth layer — substrate at `docs/substrate/**` — governs *this codebase*. Contributor-facing: rules for writing skills here (`skill-conventions.md`), the canonical reviewer-agent shape (`reviewer-agent-template.md`), where this repo's artifacts live (`substrate-layout.md`), this repo's named invariants, gotchas, and matrices, plus cross-cutting design docs. History at `docs/history/**` carries workflow products, plans, and transcripts.

The split (contributor-facing substrate vs user-facing implementation) is the load-bearing structural decision. → see [`docs/substrate/designs/three-layer-architecture.md`](docs/substrate/designs/three-layer-architecture.md).

## Composition over reinvention

Cohesive composes with [Superpowers](https://github.com/obra/superpowers) rather than reinventing implementation discipline:

- Worktrees come from `superpowers:using-git-worktrees` (loose composition with a 5-line inline fallback when Superpowers is absent).
- Per-phase plan-writing comes from `superpowers:writing-plans` and per-phase TDD execution comes from `superpowers:executing-plans`, both invoked from inside `implement-cohesively`'s phase loop (tight composition with no fallback; Superpowers is required for the implementation phase).
- Branch finishing comes from `superpowers:finishing-a-development-branch` (user-invoked after `implement-cohesively` Implemented verdict).

Cohesive owns substrate and delta-derived phase shape; Superpowers owns per-phase plan writing and TDD execution. The seam between the two is documented and intentional. → see [`docs/substrate/designs/composition-with-superpowers.md`](docs/substrate/designs/composition-with-superpowers.md).

## Fresh-eyes review

Reviewer agents run in isolated subprocesses with no conversation-context inheritance. The dispatching skill passes inputs as explicit file paths; the agent system prompt forbids reading prior conversation. This is the load-bearing safety property of every Cohesive review — without it, reviews degrade to performance. The harness's Task-tool isolation provides the structural fence; the agent-file preamble is convention reinforcement. → see [`docs/substrate/designs/agent-dispatch-protocol.md`](docs/substrate/designs/agent-dispatch-protocol.md).

## Substrate

Current canonical substrate lives under `docs/substrate/`:

- **[`invariants/`](docs/substrate/invariants/)** — named global rules with structural enforcement. v0.1 ships three: `PLUGIN_ROOT_PATHS` (every internal path uses `${CLAUDE_PLUGIN_ROOT}`), `VERDICT_BEFORE_EVIDENCE` (every verdict-led skill's Output format block opens with `**Verdict:**` within the first three non-blank lines), and `IMPLEMENTATION_PLAN_COVERS_DELTA` (every entry in a design delta ledger maps to ≥1 phase in the implementation pass; per-phase plan persisted; `delta-coverage-reviewer` Covered verdict required). The first two are mechanically enforced by `scripts/validate_plugin.sh`; the third is enforced by `implement-cohesively`'s skill-body acceptance criteria and `delta-coverage-reviewer`'s verdict, with a deferred CI grep for commit-message citations.
- **[`gotchas/`](docs/substrate/gotchas/)** — documented scars. Each names a symptom, a tempting wrong fix, and the correct pattern.
- **[`matrices/`](docs/substrate/matrices/)** — branchy behavior written down as cells with stable IDs. The router behavior matrix and the phase-derivation matrix (delta-ledger sections → phase intent shapes) live here.
- **[`designs/`](docs/substrate/designs/)** — cross-cutting design docs that span multiple components.

Workflow products (reviews, design delta ledgers, transcripts) and retired historical docs live under [`docs/history/`](docs/history/).

## Conventions

- **Skill conventions** — required body sections, frontmatter shape, output format, router announcement form, clarifying-question discipline, recommended-next-skill output blocks, anti-patterns: [`docs/substrate/designs/skill-conventions.md`](docs/substrate/designs/skill-conventions.md).
- **Reviewer agent conventions** — required sections, the canonical fresh-eyes preamble: [`docs/substrate/designs/reviewer-agent-template.md`](docs/substrate/designs/reviewer-agent-template.md).
- **Output voice and density** — chat-render rules (verdict-leads, header-depth cap, density budgets, forbidden phrasings, faithful-subset-of-persisted-file): [`references/output-voice.md`](references/output-voice.md). Loaded at chat-render time via a body-level imperative in each non-router skill and reviewer agent (the imperative literal lives in body prose, never in render templates — see [`docs/substrate/gotchas/style-guide-rot.md`](docs/substrate/gotchas/style-guide-rot.md) §"Correct pattern"). Companion worked transcript at [`docs/history/transcripts/output-voice-worked-example.md`](docs/history/transcripts/output-voice-worked-example.md).
- **Path discipline** — every internal reference uses `${CLAUDE_PLUGIN_ROOT}/...`. Enforced by [`PLUGIN_ROOT_PATHS`](docs/substrate/invariants/PLUGIN_ROOT_PATHS.md).
- **Verdict discipline** — every verdict-led skill leads with the verdict. Enforced by [`VERDICT_BEFORE_EVIDENCE`](docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md).
- **Source-of-truth hierarchy** — this doc is binding for current architecture. The README §"What's in the box" is derived from this doc and from on-disk reality. The historical plan at [`docs/history/plans/2026-05-04-mvp-implementation.md`](docs/history/plans/2026-05-04-mvp-implementation.md) is preserved as the dated artifact that drove v0.1; not authoritative for current state.
- **Default artifact dir for Cohesive run against external repos:** `docs/cohesive/<x>/` with detection of existing repo conventions (`docs/design/`, `docs/specs/`, `docs/adr/`, `docs/invariants/`, `docs/gotchas/`, `docs/substrate/`, `docs/history/`) — prefer existing if present.
- **Validation enforcement.** `scripts/validate_plugin.sh` runs locally and in CI on push/PR via [`.github/workflows/validate.yml`](.github/workflows/validate.yml). A red check blocks merge — this is the structural fence that promotes the validator's checks (frontmatter shape, expected skill set, vocabulary tokens, fresh-eyes preamble, recommended-next footer, `PLUGIN_ROOT_PATHS`, `VERDICT_BEFORE_EVIDENCE`, voice-imperative pin in body prose, anti-citation lint on render templates) from "convention-with-script" to "convention-with-CI-enforcement." Canonical pin enumeration in [`PLUGIN_ROOT_PATHS.md`](docs/substrate/invariants/PLUGIN_ROOT_PATHS.md) §"Convention pins enforced alongside this invariant."

## Where to look first

| If you're about to... | Start here |
|---|---|
| Add or modify a skill | [`docs/substrate/designs/skill-conventions.md`](docs/substrate/designs/skill-conventions.md) and the closest existing skill |
| Add or modify a reviewer agent | [`docs/substrate/designs/reviewer-agent-template.md`](docs/substrate/designs/reviewer-agent-template.md) |
| Modify the router | [`docs/substrate/matrices/router.md`](docs/substrate/matrices/router.md) and [`docs/substrate/designs/skill-conventions.md`](docs/substrate/designs/skill-conventions.md) §"Router conventions" |
| Modify the implementation phase loop | [`skills/implement-cohesively/SKILL.md`](skills/implement-cohesively/SKILL.md), [`docs/substrate/matrices/phase-derivation.md`](docs/substrate/matrices/phase-derivation.md), [`docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`](docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md) |
| Touch any path reference | [`PLUGIN_ROOT_PATHS`](docs/substrate/invariants/PLUGIN_ROOT_PATHS.md) |
| Author or revise an Output format block (or any chat-rendered output) | [`references/output-voice.md`](references/output-voice.md) and the worked transcript |
| Add or change a skill's verdict | [`VERDICT_BEFORE_EVIDENCE`](docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md) |
| Dispatch a reviewer agent | [`docs/substrate/designs/agent-dispatch-protocol.md`](docs/substrate/designs/agent-dispatch-protocol.md) |
| Run Cohesive against this repo | `cohesive:review-codebase` — output lands in [`docs/history/reviews/`](docs/history/reviews/) |
| Implement an approved spec rewrite | `cohesive:implement-cohesively` — phase-by-phase against the design delta ledger; requires Superpowers |

## Risks the design accepts

- **Discovery competition with Superpowers.** Both plugins have skills that look like discovery; the seam is documented in [`discovery-vs-superpowers.md`](docs/substrate/gotchas/discovery-vs-superpowers.md).
- **Soft prereqs may produce mediocre output.** When subskills are invoked without prior substrate discovery, output quality degrades. Detection pattern in [`soft-prereqs.md`](docs/substrate/gotchas/soft-prereqs.md).
- **Reviewer token budgets.** Token discipline is part of every reviewer agent's contract but is enforced by reviewer judgment, not structurally.
- **Behavior matrix template is unproven** until real-world matrices are produced from external repos.
- **Superpowers version drift in `implement-cohesively`.** The phase loop names `superpowers:writing-plans` and `superpowers:executing-plans` explicitly. A future Superpowers rename or restructure breaks the loop. Mitigation is reviewer-judged compatibility checks during release.
- **Per-phase reviewer cost.** `delta-coverage-reviewer` runs once per phase. A 10-phase implementation pass dispatches 10 reviewer agents. The cost is the price of the per-phase fence; it is not optional per [`IMPLEMENTATION_PLAN_COVERS_DELTA`](docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md).
- **Conventions over invariants.** Most v0.1 rules (chat-render header-depth cap, density budgets, forbidden phrasings, fresh-eyes preamble, router announcement, clarifying questions) live as convention, not enforced invariant. Three rules graduated to invariant — `PLUGIN_ROOT_PATHS` (a runtime correctness rule), `VERDICT_BEFORE_EVIDENCE` (the most-regressed UX rule with the cleanest grep), and `IMPLEMENTATION_PLAN_COVERS_DELTA` (the structural pin behind the implementation phase loop). Promotion is deliberate; convention status is intentional where wording is still settling.

## v0.1 scope

The plugin ships 9 skills, 6 reviewer agents, 6 runtime references under `references/` (cohesion-rubric, design-pressure-testing, locality-over-centralization, architecture-review-rubric, substrate-model, output-voice), 9 fillable templates under `references/templates/`, 6 contributor-facing substrate design docs under `docs/substrate/designs/` (skill-conventions, reviewer-agent-template, substrate-layout, three-layer-architecture, composition-with-superpowers, agent-dispatch-protocol), and 2 scripts. The 2026-05-04 `cut-anchor-pin` rewrite hard-cut the contributor-vs-user-facing split: rules about *this repo* live in `docs/substrate/`; the workflow methodology shipped to plugin users lives in `references/` and is cited by skills/agents at runtime. The dated milestone plan that drove v0.1 is preserved at [`docs/history/plans/2026-05-04-mvp-implementation.md`](docs/history/plans/2026-05-04-mvp-implementation.md). The original design vision is at [`docs/history/initial-design.md`](docs/history/initial-design.md).

The user-facing skill set is the five-step workflow chain `discover-substrate → brainstorm-design → rewrite-specs → validate-rewrite → implement-cohesively` (plus the `cohesively` router) and the three off-chain diagnostics `review-codebase`, `review-diff`, `audit-substrate`. The `implement-cohesively` skill closes the spec→implementation handoff: it derives phases from the design delta ledger, composes `superpowers:writing-plans` and `superpowers:executing-plans` per phase, dispatches the `delta-coverage-reviewer` agent for per-phase cross-review, and runs `cohesive:review-diff` against the branch as the final substrate check.
