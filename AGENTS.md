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

## The one named invariant

Cohesive ships v0.1 with a single named invariant:

- **`PLUGIN_ROOT_PATHS`** — every internal path reference uses `${CLAUDE_PLUGIN_ROOT}`. Never a hardcoded `/home/...` or other absolute path. Doc: [`docs/substrate/invariants/PLUGIN_ROOT_PATHS.md`](docs/substrate/invariants/PLUGIN_ROOT_PATHS.md). Enforced by `scripts/validate_plugin.sh`.

This is the one rule with a real runtime failure mode (a violation breaks the plugin for users who aren't the author). Other v0.1 rules — skill-output shape, fresh-eyes preamble, router announcement form, clarifying-question discipline — live as conventions in [`references/skill-conventions.md`](references/skill-conventions.md) and [`references/reviewer-agent-template.md`](references/reviewer-agent-template.md). They are real rules, but they are not yet structurally enforced and may shift as the methodology accumulates real institutional knowledge from running on real codebases. Promoting one to a named invariant is a deliberate act, not a reflex.

## Convention references

Before writing or modifying components, read the relevant convention doc:

- **New or modified skill (SKILL.md)** → [`references/skill-conventions.md`](references/skill-conventions.md). Names the required body sections, frontmatter shape, output format conventions, and red flags. Carries the v0.1 conventions for clarifying questions, router announcements, and recommended-next-skill output blocks.
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
- **Change `validate_plugin.sh`** → it should enforce a *named invariant* (currently `PLUGIN_ROOT_PATHS`) or a structural shape check. Reference the rule by name in any failure message.

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
