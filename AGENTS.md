# AGENTS.md — Cohesive contributor guide

Cohesive is a Claude Code plugin for substrate-first agentic engineering. If you are an agent (or a new human contributor) about to make a change here, read this file first. It points at everything else you need.

## Source-of-truth hierarchy

Four documents describe what Cohesive ships. They have an order:

1. **`docs/implementation_plan.md`** — **binding** for what ships in v0.1. If you are adding, removing, or modifying skills/agents/references/templates/scripts, this is the doc you update. §1 carries the delta ledger vs the original spec; §2 carries the canonical file structure.
2. **`docs/initial_design.md`** — the v0.1 design vision. Preserved as historical artifact and high-level reference. **Not updated for plan deltas.** It describes a more ambitious surface (17 skills, 8 agents) than what ships; the plan §1 reconciliation table is authoritative for what's actually in the box.
3. **`README.md`** §"What's in the box" — derived from plan §2; keep them in sync.
4. **The `skills/`, `agents/`, `references/`, `scripts/` directories on disk** — the implementation. Must match plan §2.

When these disagree, the plan wins. If your change creates a disagreement, update the plan in the same pass.

## Named invariants (read these before changing anything)

Every Cohesive-internal rule that matters is named, scoped, and lives under `docs/invariants/`. As of v0.1 there are five:

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

- **Add a new skill** → read `references/skill-conventions.md` and the closest existing skill in `skills/`. Update plan §2 in the same pass. Add the skill to README's "What's in the box."
- **Add a new reviewer agent** → read `references/reviewer-agent-template.md` and at least one existing agent in `agents/`. Confirm the dispatch site in the calling skill includes the `FRESH_EYES_DISPATCH` preamble.
- **Update a skill body** → confirm `PLUGIN_ROOT_PATHS` for any new path references. Confirm `SUBSKILL_RECOMMENDS_NEXT` is honored in the output schema.
- **Update the router (`cohesively`)** → confirm `ROUTER_ANNOUNCES_BEFORE_DISPATCH` and `ONE_PRECISE_QUESTION`. If you add a route, add a row to `docs/cohesive/router-matrix.md`.
- **Run cohesive against the cohesive repo itself** → save the transcript to `docs/transcripts/`. v0.1 release is gated on having two such transcripts.
- **Change `validate_plugin.sh`** → it should enforce a *named invariant*, not generic shape checks. Reference the invariant by name in the failure message.

## Default substrate locations

- Invariants: `docs/invariants/<INVARIANT_NAME>.md`
- Gotchas: `docs/cohesive/gotchas/<slug>.md`
- Behavior matrices: `docs/cohesive/<topic>/matrix.md` (or `<repo-convention>/matrix.md` if a convention exists)
- Reviews produced by Cohesive itself: `docs/cohesive/reviews/YYYY-MM-DD-<slug>.md`
- Design delta ledgers: `docs/cohesive/<topic>/design-delta.md`
- Transcripts (dogfood, manual scenario): `docs/transcripts/<date>-<slug>.md`

## When in doubt

Run `cohesive:discover-substrate` against the area you are changing. Then run `cohesive:cohesive-review --scope diff` on your change before opening the PR. The plugin reviews itself; that is the substrate's whole point.
