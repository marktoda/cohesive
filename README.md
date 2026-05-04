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
- review a codebase or subsystem architecture
- review a PR / diff for behavior, spec, test, or invariant risks
- audit a repo for missing memory (specs, matrices, invariants, gotchas, linters)
- decide whether to centralize, duplicate, split, or abstract

## When to use Superpowers instead

Use [Superpowers](https://github.com/obra/superpowers) when you need disciplined implementation: TDD, debugging methodology, plan execution, verification-before-completion. Cohesive doesn't replace these — it complements them.

The pattern: **Cohesive shapes the substrate; Superpowers shapes the implementation.** Use both when you want substrate-first design followed by disciplined execution.

## Main commands

```text
/cohesive:cohesively <task>        # Router — picks the right workflow
/cohesive:discover-substrate       # What does the codebase already remember?
/cohesive:brainstorm-design        # Options + pressure-test, grounded in substrate
/cohesive:rewrite-specs            # Hard-rewrite docs to chosen end state (in worktree)
/cohesive:review-spec-cohesion     # Fresh-eyes review of rewritten specs
/cohesive:cohesive-review          # Codebase | diff | substrate modes
```

## Workflows

### Design rewrite

The flagship Cohesive flow. For non-trivial features or refactors:

```text
/cohesive:cohesively brainstorm a refactor of intake classification
```

Behind the scenes: `discover-substrate` → `brainstorm-design` (with pressure-test) → user approves direction → `rewrite-specs` (in worktree) → `review-spec-cohesion`. Implementation happens in a separate session, ideally with Superpowers.

### Architecture review

For whole-repo or subsystem reviews:

```text
/cohesive:cohesive-review --scope codebase
```

Four phases: read normative substrate → spec-prior gate (stops if specs are inconsistent) → dispatch four reviewer agents in parallel (substrate-alignment, structure, library-native, agent-readiness) → synthesize a thesis-led report. Output written to `docs/cohesive/reviews/YYYY-MM-DD-*.md`.

### Change review

For PR / diff / working-changes review focused on substrate:

```text
/cohesive:cohesive-review --scope diff
```

Lighter than codebase review. Two reviewer agents (substrate-alignment, structure). Output rendered in chat.

### Substrate audit

For finding what's missing:

```text
/cohesive:cohesive-review --scope substrate
```

Single-pass scan. Inventories missing memory: implicit rules, branchy behavior without matrices, invariants without enforcement, scars trapped in comments, stale docs.

## What's in the box

```
.claude-plugin/plugin.json          Plugin manifest
.claude-plugin/marketplace.json     Single-plugin marketplace

skills/
  cohesively/                       Router
  discover-substrate/               Substrate inventory
  brainstorm-design/                Options + pressure-test
  rewrite-specs/                    Hard spec rewrite (in worktree)
  review-spec-cohesion/             Fresh-eyes spec review (dispatches agent)
  cohesive-review/                  Codebase | diff | substrate review

agents/
  spec-cohesion-reviewer            Fresh-eyes spec reviewer
  substrate-alignment-reviewer      Spec drift + invariants + tests
  structure-reviewer                Locality + concepts + complexity
  library-native-reviewer           Ecosystem alignment
  agent-readiness-reviewer          Could a future agent change this safely?

references/
  substrate-model.md                The substrate thesis
  cohesion-rubric.md                9-axis scorecard
  design-pressure-testing.md        25-question battery for design options
  locality-over-centralization.md   When to centralize vs duplicate
  architecture-review-rubric.md     Four-phase review process
  templates/                        Behavior matrix, invariant, gotcha,
                                    semantic linter, design delta ledger,
                                    cohesion review, architecture review report,
                                    substrate map, implementation plan

scripts/
  scan_substrate.py                 Fast substrate inventory
  validate_plugin.sh                Plugin static validation
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

Install [`superpowers`](https://github.com/obra/superpowers) alongside Cohesive. When superpowers is present:

- `rewrite-specs` invokes `superpowers:using-git-worktrees` for worktree setup
- After Cohesive design/review, hand off to Superpowers' `writing-plans` and `executing-plans` for implementation
- Use `superpowers:code-reviewer` for the implementation-quality lens after Cohesive's substrate lens

Cohesive works without superpowers — it includes inline fallbacks for worktree creation — but the combination is stronger than either alone.

## Philosophy

The valuable engineer in the agentic era is strategic. They don't merely ask "How do I complete this ticket?" They ask "What substrate would make the next ten changes in this product area easier, safer, and more obvious?"

That substrate includes specs that can regenerate behavior, tests that preserve user-visible contracts, semantic linters that encode institutional knowledge, architectural seams that reduce required context, and incident notes that prevent old bugs from being rediscovered.

The goal is not to make the original architect unnecessary. The goal is to make their judgment durable. A mature codebase should not depend on one person remembering every invariant, scar, absent abstraction, and product bet. Those things should live in the specs, tests, semantic linters, architecture, and feedback loops that shape future changes.

> Cohesive helps your codebase remember.

## License

MIT. See `LICENSE`.
