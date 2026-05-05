# AGENTS.md — Cohesive contributor guide

Cohesive is a Claude Code plugin for substrate-first agentic engineering. If you are an agent (or a new human contributor) about to make a change here, read this file first. It points at everything else you need.

## Source-of-truth hierarchy

Three sources describe what Cohesive currently is. They have an order:

1. **`/ARCHITECTURE.md`** — **binding** for current architecture. Top-level map; hook lines point at design docs in `docs/substrate/designs/` and substrate artifacts in `docs/substrate/`. If a structural decision changes, update this file (or the design doc it hooks).
2. **`README.md`** §"What's in the box" — derived from `ARCHITECTURE.md` and on-disk reality; keep them in sync.
3. **The `skills/`, `agents/`, `references/`, `scripts/` directories on disk** — the implementation. Must match what `ARCHITECTURE.md` claims.

When these disagree, `ARCHITECTURE.md` wins. If your change creates a disagreement, update `ARCHITECTURE.md` in the same pass.

Historical context lives separately under `docs/history/`:
- `docs/history/initial-design.md` — the v0.1 design vision (preserved; not authoritative for current state).
- `docs/history/plans/2026-05-04-mvp-implementation.md` — the dated milestone plan that drove v0.1 (preserved; not authoritative).
- `docs/history/reviews/` and `docs/history/delta-ledgers/` — workflow products from prior `review-codebase` / `review-diff` / `audit-substrate` and `rewrite-specs` runs (older artifacts may reference predecessor names like `cohesive-review` and `substrate-audit`; preserved as time-stamped record).

## Substrate vs implementation

Files in this repo split into two roles:

- **Substrate** — what the system *claims* about itself. Lives in `docs/substrate/**`, `docs/history/**`, `ARCHITECTURE.md`, `AGENTS.md`, `README.md`. Normative content: invariants, behavior matrices, gotchas, designs, conventions, rubrics — anything that names a rule, a shape, or a judgment framework. A change here changes the rules.
- **Implementation** — the runtime artifacts that *do* the work. Lives in `skills/**`, `agents/**`, `references/**`, `scripts/**`, `.claude-plugin/**`. Skill prompts Claude reads at invocation, reviewer-agent system prompts, fillable templates, the validator script, the plugin manifest. A change here changes behavior.

`references/` is implementation: it ships runtime content that skills and agents cite, nothing else. It carries no normative claims of its own. Anything substrate-shaped (a rule, a rubric, a convention, a design principle) belongs under `docs/substrate/`, even when skills cite it at runtime. A skill body citing `${CLAUDE_PLUGIN_ROOT}/docs/substrate/...` is fine — what matters is where the rule *lives*, not whether it's cited.

This distinction matters most for `cohesive:rewrite-specs`. Per its Hard Constraint #3, rewrite-specs touches *substrate only*. If a substrate change implies an implementation change (a new behavior matrix downstream skills must honor; a new validator check; citation updates following a substrate file move), the implementation update is a separate phase — typically `superpowers:writing-plans` → `superpowers:executing-plans`, with `cohesive:review-diff` on the result. Doing both in one rewrite-specs pass conflates "what we claim" with "what we do" and loses the fresh-eyes review power that comes from validating the substrate alone.

The same line applies to `cohesive:review-codebase` and `cohesive:review-diff`: substrate findings recommend substrate repairs (a new invariant, a missing matrix, a gotcha to write); implementation findings recommend `superpowers:writing-plans` to bring runtime artifacts into alignment.

## The named invariants

Cohesive ships v0.1 with two named invariants:

- **`PLUGIN_ROOT_PATHS`** — every internal path reference uses `${CLAUDE_PLUGIN_ROOT}`. Never a hardcoded `/home/...` or other absolute path. Doc: [`docs/substrate/invariants/PLUGIN_ROOT_PATHS.md`](docs/substrate/invariants/PLUGIN_ROOT_PATHS.md). Enforced by `scripts/validate_plugin.sh`. Failure mode: the plugin breaks for users who aren't the author.
- **`VERDICT_BEFORE_EVIDENCE`** — every verdict-led skill (`review-codebase`, `review-diff`, `validate-rewrite`, `audit-substrate`) opens its Output format block with `**Verdict:**` within the first three non-blank lines after the section header. Doc: [`docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`](docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md). Enforced by `scripts/validate_plugin.sh`. Failure mode: chat outputs bury the verdict, the user-reported wordiness scar — see [`docs/substrate/gotchas/wordy-output.md`](docs/substrate/gotchas/wordy-output.md).

These two are the rules with concrete failure modes that justify mechanical enforcement. Other v0.1 rules — chat-render header-depth cap, density budgets, forbidden phrasings, voice-citation pin, fresh-eyes preamble, router announcement form, clarifying-question discipline — live as conventions in [`references/skill-conventions.md`](references/skill-conventions.md), [`references/reviewer-agent-template.md`](references/reviewer-agent-template.md), and [`references/output-voice.md`](references/output-voice.md). Several of those conventions are still grep-pinned by `validate_plugin.sh` (the voice citation, the recommended-next footer, the fresh-eyes preamble, the canonical prereq question) — pin status is convention-with-enforcement, distinct from named-invariant status. Promoting a convention to a named invariant is a deliberate act, not a reflex; it requires both a clean grep and a real failure mode.

## Convention references

Before writing or modifying components, read the relevant convention doc:

- **New or modified skill (SKILL.md)** → [`references/skill-conventions.md`](references/skill-conventions.md). Names the required body sections, frontmatter shape, output format conventions (which now include the voice-citation pin and the verdict-leads invariant), and red flags. Carries the v0.1 conventions for clarifying questions, router announcements, and recommended-next-skill output blocks.
- **Authoring or revising any chat-rendered output (Output format block, reviewer-agent finding shape, router announcement)** → [`references/output-voice.md`](references/output-voice.md) and the worked transcript at [`docs/history/transcripts/output-voice-worked-example.md`](docs/history/transcripts/output-voice-worked-example.md). Voice rules without a worked example decay; read both before editing.
- **New or modified reviewer agent (`agents/*.md`)** → [`references/reviewer-agent-template.md`](references/reviewer-agent-template.md). The canonical fresh-eyes review agent shape, including the load-bearing "What you must not do" preamble.
- **New "claimed system shape" produced by `review-codebase` Phase 1** → [`references/templates/claimed-system-shape.md`](references/templates/claimed-system-shape.md).
- **Other artifacts (invariants, gotchas, behavior matrices, design delta ledgers, etc.)** → `references/templates/<name>.md`.

## When you are about to...

- **Add a new skill** → read [`references/skill-conventions.md`](references/skill-conventions.md) and the closest existing skill in `skills/`. Update `ARCHITECTURE.md` only if the new skill changes the broad shape (rare for a subskill); update README's "What's in the box."
- **Add a new reviewer agent** → read [`references/reviewer-agent-template.md`](references/reviewer-agent-template.md) and at least one existing agent in `agents/`. The fresh-eyes preamble is convention, not invariant: each agent file says, in some form, that the agent does not inherit conversation context. Verbatim copy from the template is the safest default.
- **Update a skill body** → confirm `PLUGIN_ROOT_PATHS` for any new path references. Confirm conventions in `references/skill-conventions.md` are honored.
- **Update the router (`cohesively`)** → read [`references/skill-conventions.md`](references/skill-conventions.md) §"Router conventions" for the announcement form and clarifying-question rule. If you add a route, add a row to [`docs/substrate/matrices/router.md`](docs/substrate/matrices/router.md).
- **Make a cross-cutting design decision** → write or extend a doc in [`docs/substrate/designs/`](docs/substrate/designs/). Add a hook line to `ARCHITECTURE.md` if the decision is broad enough to belong on the map.
- **Run cohesive against the cohesive repo itself** → save the artifact (review or transcript) under `docs/history/reviews/` or `docs/history/transcripts/`. v0.1 ships one architecture-review artifact; further dogfood is welcome but not gating.
- **Change `validate_plugin.sh`** → it should enforce a *named invariant* (currently `PLUGIN_ROOT_PATHS` or `VERDICT_BEFORE_EVIDENCE`) or a structural shape check. Reference the rule by name in any failure message.

## Default substrate locations (in this repo)

- Invariants: `docs/substrate/invariants/<INVARIANT_NAME>.md`
- Gotchas: `docs/substrate/gotchas/<slug>.md`
- Behavior matrices: `docs/substrate/matrices/<name>.md`
- Cross-cutting design docs: `docs/substrate/designs/<name>.md`
- Reviews produced by Cohesive: `docs/history/reviews/YYYY-MM-DD-<slug>.md`
- Design delta ledgers: `docs/history/delta-ledgers/YYYY-MM-DD-<slug>.md`
- Transcripts (dogfood, manual scenario): `docs/history/transcripts/<date>-<slug>.md`

When Cohesive runs against an *external* repo, the default-artifact directory is `docs/cohesive/<x>/` with detection of existing repo conventions (`docs/design/`, `docs/specs/`, `docs/adr/`, `docs/invariants/`, `docs/gotchas/`, `docs/substrate/`, `docs/history/`) preferring existing if present.

## When in doubt

Run `cohesive:discover-substrate` against the area you are changing. Then run `cohesive:review-diff` on your change before opening the PR. The plugin reviews itself; that is the substrate's whole point.
