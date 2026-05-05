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

Files in this repo split into two roles, on a **contributor vs user** axis:

- **Substrate** — rules that govern *this codebase itself*. Contributor-facing. About how to maintain Cohesive: the conventions for writing skills here, the canonical reviewer-agent shape, where this repo's artifacts live, the invariants this repo's contributors must honor, the scars this repo has earned, the design decisions that shape this codebase's structure. Lives in `docs/substrate/**`, `docs/history/**`, `ARCHITECTURE.md`, `AGENTS.md`, `README.md`. Plugin users *receive* these files when they install Cohesive (they ship as part of the repo) but the files don't run at runtime; they're documentation about how the plugin itself is built.
- **Implementation** — the workflow methodology Cohesive *ships to plugin users*. User-facing. The skills, agents, fillable templates, and runtime references (rubrics, models, voice guide) that get cited at generation time to do the actual workflow's work. Lives in `skills/**`, `agents/**`, `references/**`, `scripts/**`, `.claude-plugin/**`. A change here changes what plugin users experience when they invoke Cohesive on their codebase.

The test for which side a file belongs to: **who reads it, and when?**

- A file read by a *contributor* writing or reviewing this repo (skill-conventions, reviewer-agent-template, substrate-layout, the invariants, the gotchas) → substrate.
- A file read by a *skill or agent* at runtime as part of doing the workflow on the user's codebase (cohesion-rubric, design-pressure-testing, locality-over-centralization, architecture-review-rubric, substrate-model, output-voice) → implementation.

A file can be cited *from both sides* — `output-voice.md` is cited by skills at runtime (implementation use) and read by contributors authoring new Output format blocks (contributor use). When that happens, the file's home is determined by its *primary* runtime role: cited at generation time → implementation.

Per the 2026-05-04 `cut-anchor-pin` rewrite (repair passes 2–3), `references/` contains the runtime methodology that ships to users (the rubrics, model, voice guide, plus `templates/`); `docs/substrate/designs/` contains contributor-facing conventions (`skill-conventions.md`, `reviewer-agent-template.md`, `substrate-layout.md`) plus pre-existing cross-cutting design docs (`three-layer-architecture.md`, `composition-with-superpowers.md`, `agent-dispatch-protocol.md`).

This distinction matters most for `cohesive:rewrite-specs`. Per its Hard Constraint #3, rewrite-specs touches *substrate only*. If a substrate change implies an implementation change (a new behavior matrix downstream skills must honor; a new validator check; citation updates following a substrate file move), the implementation update is a separate phase — typically `superpowers:writing-plans` → `superpowers:executing-plans`, with `cohesive:review-diff` on the result. Doing both in one rewrite-specs pass conflates "what we claim" with "what we do" and loses the fresh-eyes review power that comes from validating the substrate alone.

The same line applies to `cohesive:review-codebase` and `cohesive:review-diff`: substrate findings recommend substrate repairs (a new invariant, a missing matrix, a gotcha to write); implementation findings recommend `superpowers:writing-plans` to bring runtime artifacts into alignment.

## The named invariants

Cohesive ships v0.1 with two named invariants:

- **`PLUGIN_ROOT_PATHS`** — every internal path reference uses `${CLAUDE_PLUGIN_ROOT}`. Never a hardcoded `/home/...` or other absolute path. Doc: [`docs/substrate/invariants/PLUGIN_ROOT_PATHS.md`](docs/substrate/invariants/PLUGIN_ROOT_PATHS.md). Enforced by `scripts/validate_plugin.sh`. Failure mode: the plugin breaks for users who aren't the author.
- **`VERDICT_BEFORE_EVIDENCE`** — every verdict-led skill (`review-codebase`, `review-diff`, `validate-rewrite`, `audit-substrate`) opens its Output format block with `**Verdict:**` within the first three non-blank lines after the section header. Doc: [`docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`](docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md). Enforced by `scripts/validate_plugin.sh`. Failure mode: chat outputs bury the verdict, the user-reported wordiness scar — see [`docs/substrate/gotchas/wordy-output.md`](docs/substrate/gotchas/wordy-output.md).

These two are the rules with concrete failure modes that justify mechanical enforcement. Other v0.1 rules — chat-render header-depth cap, density budgets, forbidden phrasings, voice-citation pin, fresh-eyes preamble, router announcement form, clarifying-question discipline — live as conventions in [`docs/substrate/designs/skill-conventions.md`](docs/substrate/designs/skill-conventions.md), [`docs/substrate/designs/reviewer-agent-template.md`](docs/substrate/designs/reviewer-agent-template.md), and [`references/output-voice.md`](references/output-voice.md). Several of those conventions are still grep-pinned by `validate_plugin.sh` (the voice citation, the recommended-next footer, the fresh-eyes preamble, the canonical prereq question) — pin status is convention-with-enforcement, distinct from named-invariant status. Promoting a convention to a named invariant is a deliberate act, not a reflex; it requires both a clean grep and a real failure mode.

## Convention references

Before writing or modifying components, read the relevant convention doc:

- **New or modified skill (SKILL.md)** → [`docs/substrate/designs/skill-conventions.md`](docs/substrate/designs/skill-conventions.md). Names the required body sections, frontmatter shape, output format conventions (which now include the voice-citation pin and the verdict-leads invariant), and red flags. Carries the v0.1 conventions for clarifying questions, router announcements, and recommended-next-skill output blocks.
- **Authoring or revising any chat-rendered output (Output format block, reviewer-agent finding shape, router announcement)** → [`references/output-voice.md`](references/output-voice.md) and the worked transcript at [`docs/history/transcripts/output-voice-worked-example.md`](docs/history/transcripts/output-voice-worked-example.md). Voice rules without a worked example decay; read both before editing.
- **New or modified reviewer agent (`agents/*.md`)** → [`docs/substrate/designs/reviewer-agent-template.md`](docs/substrate/designs/reviewer-agent-template.md). The canonical fresh-eyes review agent shape, including the load-bearing "What you must not do" preamble.
- **New "claimed system shape" produced by `review-codebase` Phase 1** → [`references/templates/claimed-system-shape.md`](references/templates/claimed-system-shape.md).
- **Other artifacts (invariants, gotchas, behavior matrices, design delta ledgers, etc.)** → `references/templates/<name>.md`.

## When you are about to...

- **Add a new skill** → read [`docs/substrate/designs/skill-conventions.md`](docs/substrate/designs/skill-conventions.md) and the closest existing skill in `skills/`. Update `ARCHITECTURE.md` only if the new skill changes the broad shape (rare for a subskill); update README's "What's in the box."
- **Add a new reviewer agent** → read [`docs/substrate/designs/reviewer-agent-template.md`](docs/substrate/designs/reviewer-agent-template.md) and at least one existing agent in `agents/`. The fresh-eyes preamble is convention, not invariant: each agent file says, in some form, that the agent does not inherit conversation context. Verbatim copy from the template is the safest default.
- **Update a skill body** → confirm `PLUGIN_ROOT_PATHS` for any new path references. Confirm conventions in `docs/substrate/designs/skill-conventions.md` are honored.
- **Update the router (`cohesively`)** → read [`docs/substrate/designs/skill-conventions.md`](docs/substrate/designs/skill-conventions.md) §"Router conventions" for the announcement form and clarifying-question rule. If you add a route, add a row to [`docs/substrate/matrices/router.md`](docs/substrate/matrices/router.md).
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
