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
- `docs/history/reviews/` and `docs/history/design-changes/` — workflow products from prior `cohesive-review` and `rewrite-specs` runs.

## Named invariants (read these before changing anything)

Every Cohesive-internal rule that matters is named, scoped, and lives under `docs/substrate/invariants/`. As of v0.1 there are five:

- **`PLUGIN_ROOT_PATHS`** — every internal path reference uses `${CLAUDE_PLUGIN_ROOT}`. Never a hardcoded `/home/...` or other absolute path.
- **`FRESH_EYES_DISPATCH`** — every Task-tool dispatch from a Cohesive skill passes explicit input paths, forbids inheriting prior conversation context, and includes the canonical fresh-eyes preamble.
- **`ROUTER_ANNOUNCES_BEFORE_DISPATCH`** — `cohesively` announces the chosen workflow in chat before invoking any subskill. The form is canonical.
- **`ONE_PRECISE_QUESTION`** — any Cohesive skill turn asks at most one clarifying question, and that question is a specific forced choice (never "what do you want?" or "can you tell me more?").
- **`SUBSKILL_RECOMMENDS_NEXT`** — every terminal Cohesive skill output names exactly one recommended next Cohesive skill (one per verdict-branch where multiple verdicts apply).

These are not preferences. They are the rules a `cohesive-review --scope codebase` of this repo will check for. Violating one without updating the invariant doc and getting review is a regression.

## Convention references

Before writing or modifying components, read the relevant convention doc:

- **New or modified skill (SKILL.md)** → `references/skill-conventions.md`. Names the required body sections, frontmatter shape, output format, and red flags.
- **New or modified reviewer agent (`agents/*.md`)** → `references/reviewer-agent-template.md`. The canonical fresh-eyes review agent shape, including the load-bearing "What you must not do" preamble.
- **New "claimed system shape" produced by `cohesive-review` Phase 1** → `references/templates/claimed-system-shape.md`. Six-section template.
- **Other artifacts (invariants, gotchas, behavior matrices, design delta ledgers, etc.)** → `references/templates/<name>.md`.

## When you are about to...

- **Add a new skill** → read `references/skill-conventions.md` and the closest existing skill in `skills/`. Update `ARCHITECTURE.md` only if the new skill changes the broad shape (rare for a subskill); update README's "What's in the box."
- **Add a new reviewer agent** → read `references/reviewer-agent-template.md` and at least one existing agent in `agents/`. Confirm the dispatch site in the calling skill includes the `FRESH_EYES_DISPATCH` preamble.
- **Update a skill body** → confirm `PLUGIN_ROOT_PATHS` for any new path references. Confirm `SUBSKILL_RECOMMENDS_NEXT` is honored in the output schema.
- **Update the router (`cohesively`)** → confirm `ROUTER_ANNOUNCES_BEFORE_DISPATCH` and `ONE_PRECISE_QUESTION`. If you add a route, add a row to `docs/substrate/matrices/router.md`.
- **Make a cross-cutting design decision** → write or extend a doc in `docs/substrate/designs/`. Add a hook line to `ARCHITECTURE.md` if the decision is broad enough to belong on the map.
- **Run cohesive against the cohesive repo itself** → save the transcript to `docs/history/transcripts/`. v0.1 release is gated on having two such transcripts.
- **Change `validate_plugin.sh`** → it should enforce a *named invariant*, not generic shape checks. Reference the invariant by name in the failure message.

## Default substrate locations (in this repo)

- Invariants: `docs/substrate/invariants/<INVARIANT_NAME>.md`
- Gotchas: `docs/substrate/gotchas/<slug>.md`
- Behavior matrices: `docs/substrate/matrices/<name>.md`
- Cross-cutting design docs: `docs/substrate/designs/<name>.md`
- Reviews produced by Cohesive: `docs/history/reviews/YYYY-MM-DD-<slug>.md`
- Design delta ledgers: `docs/history/design-changes/YYYY-MM-DD-<slug>.md`
- Transcripts (dogfood, manual scenario): `docs/history/transcripts/<date>-<slug>.md`

When Cohesive runs against an *external* repo, the default-artifact directory is `docs/cohesive/<x>/` with detection of existing repo conventions (`docs/design/`, `docs/specs/`, `docs/adr/`, `docs/invariants/`, `docs/gotchas/`, `docs/substrate/`, `docs/history/`) preferring existing if present.

## When in doubt

Run `cohesive:discover-substrate` against the area you are changing. Then run `cohesive:cohesive-review --scope diff` on your change before opening the PR. The plugin reviews itself; that is the substrate's whole point.
