# Scope: what Cohesive does and doesn't do

**Cohesive overbuilds simplicity and extensibility. We underbuild everywhere else.**

A feature lands when it makes Cohesive simpler to use OR easier to extend. If it doesn't, we don't add it — even when adjacent, even when tempting, even when it would help. This document is the explicit list. Read it before proposing a new skill, a new convention, a new validator check, or a new dependency.

The discipline this convention exists to encode: scope creep is the dominant failure mode of substrate-first methodologies. Without an explicit negative space, every new pressure surfaces as "we should add a skill for that." With one, the question becomes "does this make Cohesive simpler or extension easier — and if not, what does it earn that justifies the weight?"

## What Cohesive does

Substrate-first judgment work: making senior-engineer architectural choices structural so a future agent or contributor can change the system without holding the original architect's mental model.

| Surface | What it owns |
|---|---|
| **Decide gate** (`brainstorm-design`) | Pressure-testing 2–4 design options against accumulated substrate; recommending a direction with main risk + structural mitigation |
| **Lock gate** (`rewrite-specs` + `validate-rewrite`) | Hard-rewriting docs to a chosen end state; fresh-eyes review with internal repair loop; architectural reflection at lock→build handoff |
| **Build gate** (`implement-cohesively`) | Thin intent paragraph derived from delta ledger; delta-size budget gate; end-of-run dual reviewer dispatch (`delta-coverage-reviewer` + `cohesive:review-diff`) against the locked design with AND-shape verdict synthesis; spec-coverage verdict — code production composed via `superpowers:executing-plans` (the only code-producing surface in the entire stack) |
| **Diagnostics** (`review-codebase`, `review-diff`, `audit-substrate`) | Whole-architecture cohesion review; PR/branch substrate review; missing-memory inventory |
| **Adoption** (`init`) | First-time substrate from a zero-substrate codebase, with side-by-side translations that teach the vocabulary |
| **Router & orientation** (`cohesively`, `using-cohesive`) | Route selection; session-start framing |
| **Reviewer agents** | Fresh-eyes substrate alignment / structure / library-native / agent-readiness / spec-cohesion / delta-coverage |

The substrate primitives Cohesive operates on: specs, behavior matrices, named invariants, gotchas, semantic linters. Defined in [`references/substrate-vocabulary.md`](${CLAUDE_PLUGIN_ROOT}/references/substrate-vocabulary.md).

## What Cohesive deliberately doesn't do

### Implementation discipline

Superpowers' territory. The Cohesive↔Superpowers seam is documented at [`docs/substrate/architecture/composition-with-superpowers.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md); the principle is that Cohesive owns substrate and phase shape, Superpowers owns plan writing and TDD execution inside each phase.

- **Plan writing** — `superpowers:writing-plans` owns this. `implement-cohesively` invokes it once per phase.
- **TDD execution** — `superpowers:executing-plans` owns this. The only code-producing surface in the entire stack.
- **Branch finishing / merge mechanics** — `superpowers:finishing-a-development-branch` owns this. `implement-cohesively` recommends it on Implemented verdict; never auto-invokes.
- **Code review for implementation quality** — `superpowers:code-reviewer` owns this. Cohesive's `review-codebase` and `review-diff` review for *substrate cohesion* (does the code agree with the docs?), not for code quality, naming, formatting, or micro-design.
- **Bug debugging** — Superpowers' debugging skills. Cohesive doesn't reproduce, root-cause, or fix runtime bugs.
- **Test writing** — TDD inside `superpowers:executing-plans`. Cohesive specifies *what* to test (in specs and invariants) but doesn't write the tests.

### Tooling and ops

Out of scope entirely.

- **CI/CD configuration** — Cohesive's validator runs as a CI step but the validator itself is the only CI Cohesive ships. Build pipelines, deployment automation, environment management — not Cohesive.
- **Deployment, monitoring, observability** — Not Cohesive.
- **Performance profiling, optimization** — Not Cohesive. (A spec might say "this endpoint must respond within 100ms" — Cohesive can pin that as an invariant; Cohesive doesn't measure it.)
- **Dependency management / upgrades** — Not Cohesive.
- **Security audits beyond architectural cohesion** — Not Cohesive. Cohesive can review whether the design says "tokens are hashed" agrees with the implementation; Cohesive doesn't run static-analysis security scanners.
- **API doc generation** — Not Cohesive. Specs are hand-written; generating reference docs from code is downstream tooling.
- **Code translation between languages, framework migration** — Not Cohesive.
- **Database schema management** — Not Cohesive. (A schema constraint can be a named invariant; the migration tooling isn't.)

### Project management

Out of scope entirely.

- **Issue tracking** (Linear, Jira, GitHub issues) — Not Cohesive.
- **Ticket workflows, sprint planning, roadmaps** — Not Cohesive.
- **Estimation, capacity planning** — Not Cohesive.

### Code-style and aesthetics

Out of scope as a whole category.

- **ESLint / prettier / black / rustfmt rules** — Not Cohesive. Generic linters are a different layer.
- **Naming preferences, casing, file-organization conventions** — Not Cohesive unless they pin to a named invariant the substrate cares about (rare).
- **Refactor proposals at the line level** — Not Cohesive. Cohesive proposes substrate changes, not "rename this variable" or "extract this function."
- **Code-quality micro-decisions** — Not Cohesive. `let` vs `const`, async/await vs Promises, immutability defaults — these are project-style decisions the project owns; Cohesive doesn't ship opinions on them.

## What Cohesive can extend

Open extension surfaces. A new addition lands when it earns simplicity or extensibility *and* fits an existing seam.

- **New substrate types** — The substrate-vocabulary at [`references/substrate-vocabulary.md`](${CLAUDE_PLUGIN_ROOT}/references/substrate-vocabulary.md) defines six types. A seventh lands when it captures a distinct failure mode the existing six don't, with a clear distinction in the "What this earns" column.
- **New reviewer agents** — Fresh-eyes lenses (per [`docs/substrate/architecture/fresh-eyes-review.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/fresh-eyes-review.md)). A new agent lands when it has a distinct lens not covered by existing six, an output budget, and a Task-subprocess fresh-eyes property.
- **New diagnostic skills** — Off-chain lenses against existing substrate (parallel to `review-codebase`, `review-diff`, `audit-substrate`). A new diagnostic lands when its question is distinct enough that folding it into an existing diagnostic would over-broaden that skill's scope.
- **New convention docs** — Conventions promote from informal patterns to docs when N=3 instances exist. Conventions promote to named invariants per the criteria in this convention's row of substrate-vocabulary.md.
- **New routes in `cohesively`** — Route additions land when an existing route would force misclassification (e.g., `init` was added because `audit-substrate` was the closest pre-init route but didn't fit codebases with no substrate to audit).

The seams are documented in [`docs/substrate/architecture/`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/) and [`docs/substrate/conventions/`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/). The "Adding a new skill" sequence is in [`docs/substrate/architecture/skills.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md) §"Adding a new skill."

## Why these cuts

Three failure modes drove the negative-space discipline:

1. **Methodology bloat.** Substrate-first toolkits accumulate categories faster than they prune them — a "rules" category becomes "named invariants" + "behavior matrices" + "gotchas" + "semantic linters" + "specs" + "conventions" + "scars" + "footguns" + ... The substrate-vocabulary cap at six types is held against this pressure. A seventh substrate type ships only when it earns over the existing six.

2. **Identity drift.** Without an explicit "what we don't do" surface, every adjacent task creates pressure to add a skill — `cohesive:debug` because debugging touches substrate, `cohesive:refactor` because refactoring is substrate-shaped sometimes, `cohesive:deploy` because deployment is part of shipping. Each addition individually is defensible; the cumulative effect is a methodology that tries to do everything and excels at nothing.

3. **Composition vs replacement.** Cohesive's distinctive value is composition with Superpowers (and with whatever implementation-discipline toolkit the user prefers). Replacing Superpowers' surface area inside Cohesive would force users to choose; composing means users can use both. The "doesn't do" list pins what stays composable.

## Promotion criteria

A change promotes to substrate when:

- **For convention → named invariant:** wording stable ≥2 release cycles + caught regression + feasible mechanical enforcement. See `references/substrate-vocabulary.md` §"Convention" for the canonical criteria.
- **For new skill:** clear seam with ≥1 existing skill, named in `architecture/skills.md` §"Adding a new skill"; a row in the at-a-glance Skill set table; a per-skill section in skills.md; an inbound + outbound handoff contract in handoffs.md; validator skill-array updates.
- **For new convention doc:** N=3 informal instances + a real future-pressure question the convention answers.
- **For new validator check:** caught regression + wording stability + ≥2 enforcement targets (a single-file check is the validator-bloat failure mode named in `references/cohesion-rubric.md` §"Convention pin extension boundaries").

Below these criteria, the proposed change is convention-with-template (live in body prose) or rejected as scope creep.

## How this convention is enforced

Convention-with-grep is the standard pattern (per [`docs/substrate/gotchas/style-guide-rot.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md) §"Promotion criteria"); this convention is convention-only at v0.1 because its content is qualitative (categorical scope claims), not greppable. The structural mitigations:

- **Reviewer attention.** `cohesive:review-codebase`'s structure-reviewer agent reads this doc when judging whether a new addition fits the methodology. Scope creep is one of the failure modes structure review surfaces.
- **The adding-a-new-skill sequence.** `architecture/skills.md` §"Adding a new skill" steps 1–5 force five-surface coordination on every skill addition; if a proposal can't survive that overhead, it almost certainly doesn't earn its slot.
- **The simplification-pass cadence.** Periodic `review-codebase` reviews specifically check for "what should we cut" alongside "what's missing." Recent example: the 2026-05-06 simplification architecture review at `docs/history/reviews/2026-05-06-cohesive-pack-simplification-architecture-review.md`.

## Related substrate

- [`references/substrate-vocabulary.md`](${CLAUDE_PLUGIN_ROOT}/references/substrate-vocabulary.md) — the six substrate types Cohesive operates on; user-facing translations of each.
- [`docs/substrate/architecture/composition-with-superpowers.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md) — the seam between Cohesive's substrate work and Superpowers' implementation discipline.
- [`docs/substrate/architecture/skills.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md) §"Why these skills, not others" — the per-skill argument for why each existing skill earns its slot, paired with this doc's negative-space framing.
- [`docs/substrate/conventions/audience-separation.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md) — substrate vocabulary stays in persisted files; chat surfaces use the colloquial first-phrase from substrate-vocabulary.md per the surface-by-surface rule.
- [`docs/substrate/gotchas/style-guide-rot.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md) — the failure mode the convention-with-grep promotion criteria avoids.
