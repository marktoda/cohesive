# Cohesive

> Substrate-first agentic engineering. Helps your codebase remember.

Cohesive is a Claude Code plugin for building codebases meant to last. When code is cheap, confidence is scarce — Cohesive helps Claude make changes that aren't merely locally plausible, but globally coherent with the system's specs, behavior matrices, named invariants, semantic linters, gotchas, locality boundaries, and future product direction.

**Status:** v0.1 MVP. Architecture map: [`ARCHITECTURE.md`](ARCHITECTURE.md).

## The core idea

Code is cheap. Confidence is scarce. **Substrate is how the codebase remembers** — specs, tests, behavior matrices, invariants, semantic linters, CI checks, docs, gotchas, architectural seams. Cohesive moves judgment upstream and encodes it into the codebase, so future humans and agents can change the system without needing the original author in the room.

A normal linter encodes generic engineering rules. A *semantic* linter encodes institutional knowledge — "every external mutation must produce an audit event," "this dependency may only be imported through wrapper Y," "every environment variable used in code must appear in the env spec." A convention without enforcement is just a hope. Cohesive's job is to turn judgment into enforcement.

## When to reach for Cohesive

- brainstorming a feature, refactor, or architecture change that touches behavior or invariants
- rewriting design docs / specs to a chosen end state
- driving implementation of an approved rewrite phase-by-phase against a design delta ledger
- reviewing a codebase, subsystem, or PR for cohesion
- auditing a repo for missing memory — implicit rules, branchy code without matrices, invariants without enforcement
- deciding whether to centralize, duplicate, split, or abstract

## Commands

The user-facing model is **three gates: Decide → Lock → Build**, paralleling Superpowers' `brainstorm → plan → execute`. Subskills are agent-internal dispatch keys; users see gates and outcomes.

```text
/cohesive:cohesively <task>      # Router — picks the right workflow

# First-time adoption (one-shot)
/cohesive:init                   # Scan a zero-substrate codebase, draft initial substrate
                                 # with side-by-side translations of each Cohesive type

# Subskills (skip the router)
/cohesive:discover-substrate     # Inventory existing substrate
/cohesive:brainstorm-design      # Options + 25-question pressure-test
/cohesive:rewrite-specs          # Hard-rewrite docs to chosen end state (in worktree)
/cohesive:validate-rewrite       # Fresh-eyes review of the rewrite
/cohesive:implement-cohesively   # Drive implementation against the design delta ledger

# Off-chain diagnostics
/cohesive:review-codebase        # Full architecture cohesion review
/cohesive:review-diff            # PR / branch / working-changes review
/cohesive:audit-substrate        # What memory is missing
```

## Decide → Lock → Build

For a non-trivial feature or refactor:

```text
/cohesive:cohesively brainstorm a refactor of intake classification
```

- **Decide** — recommended direction with main risk + structural mitigation. Many design conversations end here. *(Under the hood: `discover-substrate` + `brainstorm-design`.)*
- **Lock** — chosen direction pinned into specs in a worktree, then fresh-eyes-validated. You get an architectural reflection on what's easier downstream, what's harder, what's load-bearing on memory rather than structure. *(Under: `rewrite-specs` + `validate-rewrite`, with an internal repair loop.)*
- **Build** — locked design becomes code with spec-coverage verified. Phases derived from the design delta ledger; each phase is plan-then-TDD, then cross-reviewed against the delta. Final verdict: `Code matches locked design ✓` / `Drift detected ✗`. *(Under: `implement-cohesively`, composing `superpowers:writing-plans` + `executing-plans` per phase, plus `delta-coverage-reviewer` per phase.)*

You can stop at any gate.

## Installation

```bash
claude marketplace add marktoda/cohesive
claude plugin install cohesive
```

Local development:

```bash
git clone https://github.com/marktoda/cohesive
cd cohesive
bash scripts/validate_plugin.sh
```

## Pairs with Superpowers

Install [Superpowers](https://github.com/obra/superpowers) alongside Cohesive. The two plugins compose at known seams:

- `rewrite-specs` invokes `superpowers:using-git-worktrees` for worktree setup. *Loose composition: a 5-line fallback exists if Superpowers is absent.*
- `implement-cohesively` invokes `superpowers:writing-plans` and `superpowers:executing-plans` once per implementation pass. *Tight composition: Superpowers is required; there is no fallback.* Plan-writing and TDD execution are not 5-line operations and reinventing them inside Cohesive is exactly the duplication the seam exists to prevent.
- After `implement-cohesively` returns Implemented, hand off to `superpowers:finishing-a-development-branch`.

**Cohesive shapes substrate and the implementation pass; Superpowers shapes per-pass plans and code.** Cohesive's substrate-only workflows (review, audit, design, rewrite, validate) work without Superpowers.

## Layout

```
skills/        Workflow orchestration — the user-facing surface (11 skills)
agents/        Fresh-context reviewer agents (dispatched in clean subprocesses)
references/    Runtime methodology shipped to plugin users — rubrics, templates, voice
docs/          Contributor-facing substrate + history (rules about THIS repo)
scripts/       Plugin validation and substrate inventory
```

Detail in [`ARCHITECTURE.md`](ARCHITECTURE.md); contributor rules in [`docs/substrate/`](docs/substrate/).

## Philosophy

The valuable contribution in the agentic era is strategic. Don't merely ask "How do I complete this ticket?" — ask "What substrate would make the next ten changes in this product area easier, safer, and more obvious?"

That substrate is specs that can regenerate behavior, tests that preserve user-visible contracts, semantic linters that encode institutional knowledge, architectural seams that reduce required context, and incident notes that prevent old bugs from being rediscovered.

The goal is not to make the original author unnecessary. The goal is to make their judgment durable. A mature codebase shouldn't depend on one person remembering every invariant, scar, absent abstraction, and product bet. Those things should live in the specs, tests, linters, architecture, and feedback loops that shape future changes.

> Cohesive helps your codebase remember.

## License

MIT. See [`LICENSE`](LICENSE).
