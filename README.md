# Cohesive

> Substrate-first agentic engineering. Helps your codebase remember.

Cohesive is a Claude Code plugin for senior architects and engineers building codebases meant to last. When code is cheap, confidence is scarce — Cohesive helps Claude make changes that are not merely locally plausible, but globally coherent with the system's specs, behavior matrices, named invariants, semantic linters, gotchas, locality boundaries, and future product direction.

**Status:** v0.1 MVP. Architecture at [`ARCHITECTURE.md`](ARCHITECTURE.md); historical design vision at [`docs/history/initial-design.md`](docs/history/initial-design.md); the dated milestone plan at [`docs/history/plans/2026-05-04-mvp-implementation.md`](docs/history/plans/2026-05-04-mvp-implementation.md).

## Core idea

Code is cheap. Confidence is scarce. **Substrate is how the codebase remembers** — specs, tests, behavior matrices, invariants, semantic linters, CI checks, docs, gotchas, architectural seams. Cohesive moves senior-engineer judgment upstream and encodes it into the codebase, so future humans and agents can change the system without needing the original architect in the room.

A normal linter encodes generic engineering rules. A *semantic* linter encodes institutional knowledge — "every external mutation must produce an audit event," "this dependency may only be imported through wrapper Y," "every environment variable used in code must appear in the env spec." A convention without enforcement is just a hope. Cohesive's job is to turn judgment into enforcement.

## When to use Cohesive

Use Cohesive when you are about to:

- brainstorm a feature or refactor that touches behavior, architecture, or invariants
- rewrite design docs / specs to a chosen end state
- drive implementation of an approved spec rewrite phase-by-phase against a design delta ledger
- review a codebase or subsystem architecture
- review a PR / diff for behavior, spec, test, or invariant risks
- audit a repo for missing memory (specs, matrices, invariants, gotchas, linters)
- decide whether to centralize, duplicate, split, or abstract

## When to use Superpowers alongside Cohesive

Use [Superpowers](https://github.com/obra/superpowers) for disciplined plan-writing and TDD execution. Cohesive's `implement-cohesively` skill composes Superpowers per phase: Cohesive owns the delta-derived phase shape and the per-phase cross-review against the design delta ledger; Superpowers owns the per-phase plan and the TDD execution inside each phase.

The pattern: **Cohesive shapes the substrate and the implementation phases; Superpowers shapes the per-phase plan and code.** Cohesive's substrate-only workflows (review, audit, design, rewrite, validate) work without Superpowers; `implement-cohesively` requires Superpowers.

## Main commands

The flagship workflow chain reads as five imperatives — `discover → brainstorm → rewrite → validate → implement` — paralleling and extending Superpowers' `brainstorm → plan → execute`. Three diagnostics sit off-chain.

```text
/cohesive:cohesively <task>        # Router — picks the right workflow

# Workflow chain
/cohesive:discover-substrate       # What does the codebase already remember?
/cohesive:brainstorm-design        # Options + pressure-test, grounded in substrate
/cohesive:rewrite-specs            # Hard-rewrite docs to chosen end state (in worktree)
/cohesive:validate-rewrite         # Fresh-eyes review of rewritten specs
/cohesive:implement-cohesively     # Drive implementation phase-by-phase against the delta;
                                   # composes superpowers:writing-plans + executing-plans
                                   # per phase; per-phase delta-coverage cross-review.

# Off-chain diagnostics
/cohesive:review-codebase          # Full architecture review
/cohesive:review-diff              # PR / branch / working-changes review
/cohesive:audit-substrate          # What memory is missing?
```

## Workflows

### Design rewrite

The flagship Cohesive flow. For non-trivial features or refactors:

```text
/cohesive:cohesively brainstorm a refactor of intake classification
```

Behind the scenes: `discover-substrate` → `brainstorm-design` (with pressure-test) → user approves direction → `rewrite-specs` (in worktree) → `validate-rewrite`. After Approved, the user picks an implementation path from the decision matrix in the validate-rewrite footer (default: `implement-cohesively`).

### Implementation against an approved rewrite

After `validate-rewrite` returns Approved:

```text
/cohesive:cohesively implement the approved rewrite
```

Behind the scenes: `implement-cohesively` derives phases from the design delta ledger via the phase-derivation matrix, invokes `superpowers:writing-plans` and `superpowers:executing-plans` per phase, dispatches the `delta-coverage-reviewer` agent for per-phase cross-review, and runs `cohesive:review-diff` against the branch as the final substrate check before recommending `superpowers:finishing-a-development-branch`.

### Architecture review

For whole-repo or subsystem reviews:

```text
/cohesive:review-codebase
```

Four phases: read normative substrate → spec-prior gate (stops if specs are inconsistent) → dispatch four reviewer agents in parallel (substrate-alignment, structure, library-native, agent-readiness) → synthesize a thesis-led report. Output written to `docs/history/reviews/YYYY-MM-DD-*.md`.

### Change review

For PR / diff / working-changes review focused on substrate:

```text
/cohesive:review-diff
```

Lighter than codebase review. Two reviewer agents (substrate-alignment, structure). Output rendered in chat.

### Substrate audit

For finding what's missing:

```text
/cohesive:audit-substrate
```

Single-pass scan. Inventories missing memory: implicit rules, branchy behavior without matrices, invariants without enforcement, scars trapped in comments, stale docs.

## What's in the box

```
.claude-plugin/plugin.json          Plugin manifest
.claude-plugin/marketplace.json     Single-plugin marketplace

skills/
  using-cohesive/                   Session-start orientation — when does Cohesive apply?
  cohesively/                       Router — picks the right Cohesive workflow
  discover-substrate/               Substrate inventory
  brainstorm-design/                Options + pressure-test
  rewrite-specs/                    Hard spec rewrite (in worktree)
  validate-rewrite/                 Fresh-eyes review of the rewrite (dispatches agent)
  implement-cohesively/             Drive implementation phase-by-phase against the delta
                                    ledger; composes superpowers:writing-plans +
                                    executing-plans per phase
  review-codebase/                  Full architecture review
  review-diff/                      PR / branch / working-changes review
  audit-substrate/                  Substrate audit — what memory is missing

agents/
  spec-cohesion-reviewer            Fresh-eyes spec reviewer
  substrate-alignment-reviewer      Spec drift + invariants + tests
  structure-reviewer                Locality + concepts + complexity
  library-native-reviewer           Ecosystem alignment
  agent-readiness-reviewer          Could a future agent change this safely?
  delta-coverage-reviewer           Per-phase: did this phase cover its delta entries?

references/                         Runtime methodology cited by skills/agents
                                    when running on the user's codebase:
  substrate-model.md                The substrate thesis
  cohesion-rubric.md                9-axis scorecard
  design-pressure-testing.md        25-question battery for design options
  locality-over-centralization.md   When to centralize vs duplicate
  architecture-review-rubric.md     Four-phase review process
  output-voice.md                   Chat-render voice and density rules
  templates/                        Fillable forms: behavior matrix, invariant,
                                    gotcha, design delta ledger, cohesion review,
                                    architecture review report, substrate map,
                                    claimed system shape, substrate discovery report

docs/substrate/                     Contributor-facing rules about THIS repo:
  architecture/                     Cross-cutting architecture (read when changing system shape):
    three-tier-architecture.md      skills/agents/references separation
    composition-with-superpowers.md Plugin composition design (incl. implement-cohesively
                                    seam: tight composition with no fallback)
    fresh-eyes-review.md            The load-bearing review property
    skills.md                       Per-skill design layer (one section per skill)
    handoffs.md                     Chain transition contracts + re-entry edges
  conventions/                      Prescriptive component rules (read when authoring):
    skill-shape.md                  Canonical SKILL.md shape + when-to-edit-which-layer rule
    reviewer-agent-shape.md         Canonical reviewer-agent shape
    dispatch-protocol.md            Task-tool reviewer-agent dispatch-prompt contract
    skill-tool-dispatch.md          Skill-tool (skill→skill) dispatch contract
    substrate-layout.md             Where this repo's artifacts live
  invariants/                       Named global rules: PLUGIN_ROOT_PATHS,
                                    VERDICT_BEFORE_EVIDENCE,
                                    IMPLEMENTATION_PLAN_COVERS_DELTA,
                                    SKILL_DESIGN_DOC_SECTION
  gotchas/                          Documented scars: soft-prereqs,
                                    discovery-vs-superpowers,
                                    wordy-output, style-guide-rot,
                                    no-implementation-handoff,
                                    skipping-per-phase-plan
  matrices/                         Branchy behavior with stable IDs:
                                    router, reviewer-output-shape,
                                    skill-section-presence, artifact-placement,
                                    phase-derivation

docs/history/
  reviews/                          Persisted architecture / cohesion / validation reviews
  delta-ledgers/                    Spec-rewrite ledgers (dated)
  transcripts/                      Worked examples and dogfood captures
  plans/                            Dated milestone plans

scripts/
  scan_substrate.py                 Fast substrate inventory
  validate_plugin.sh                Plugin static validation (PLUGIN_ROOT_PATHS + structural shape)
```

## Installation

### From a marketplace

```bash
claude marketplace add marktoda/cohesive
claude plugin install cohesive
```

### Locally for development

```bash
git clone https://github.com/marktoda/cohesive
cd cohesive
bash scripts/validate_plugin.sh   # ensure structure is valid
# Then: in your project, claude --plugin-dir /path/to/cohesive
```

### Recommended companion

Install [`superpowers`](https://github.com/obra/superpowers) alongside Cohesive. The two plugins compose at known seams:

- `rewrite-specs` invokes `superpowers:using-git-worktrees` for worktree setup. Loose composition: a 5-line inline fallback exists when Superpowers is absent.
- `implement-cohesively` invokes `superpowers:writing-plans` and `superpowers:executing-plans` per phase. Tight composition: **Superpowers is required for the implementation phase**; there is no fallback. If Superpowers is absent, `implement-cohesively` stops with a hard error and recommends installation. (Plan-writing and TDD execution are not 5-line operations and reinventing them inside Cohesive is exactly the duplication the seam exists to prevent.)
- After `implement-cohesively` returns Implemented, hand off to `superpowers:finishing-a-development-branch` for branch finishing (user-invoked).
- Use `superpowers:code-reviewer` for the implementation-quality lens after Cohesive's substrate lens.

Cohesive's substrate-only workflows (review, audit, design, rewrite, validate) work without Superpowers. The implementation phase requires Superpowers.

## Philosophy

The valuable engineer in the agentic era is strategic. They don't merely ask "How do I complete this ticket?" They ask "What substrate would make the next ten changes in this product area easier, safer, and more obvious?"

That substrate includes specs that can regenerate behavior, tests that preserve user-visible contracts, semantic linters that encode institutional knowledge, architectural seams that reduce required context, and incident notes that prevent old bugs from being rediscovered.

The goal is not to make the original architect unnecessary. The goal is to make their judgment durable. A mature codebase should not depend on one person remembering every invariant, scar, absent abstraction, and product bet. Those things should live in the specs, tests, semantic linters, architecture, and feedback loops that shape future changes.

> Cohesive helps your codebase remember.

## License

MIT. See `LICENSE`.
