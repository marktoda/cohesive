# Substrate Map — [repo or subsystem]

**Last updated:** YYYY-MM-DD
**Owner:** <team or person>

The substrate map is a repo-level (or subsystem-level) index of how the codebase remembers. It is the answer to "where do I look to learn what this codebase claims about itself?" It is also a checkpoint: gaps in the substrate map are gaps in the codebase's memory.

Keep this short and current. A 3-page substrate map nobody updates is worse than a 1-page one that's accurate.

## Specs

The normative documents that describe what the system is supposed to do. List the canonical entry points only — not every doc.

| Subsystem | Spec | Notes |
|---|---|---|
| <name> | `docs/...` | <one line> |

## Behavior matrices

Where branchy behavior is enumerated as cells.

| Subsystem | Matrix | Notes |
|---|---|---|
| <name> | `docs/.../matrix.md` | <one line> |

## Named invariants

Global rules with stable names.

| Invariant | Scope | Enforcement (summary) | Spec |
|---|---|---|---|
| `INVARIANT_NAME` | <where it applies> | <test / type / constraint / linter / runtime wrapper / CI> | `docs/substrate/invariants/INVARIANT_NAME.md` |

## Semantic linters

Custom checks that encode institutional knowledge.

| Linter | What it enforces | Where it lives |
|---|---|---|
| <name> | <rule> | <path> |

## Gotchas

Documented scars. Reference by name; the doc has the symptom/cause/correct-pattern detail.

| Gotcha | Subsystem | Doc |
|---|---|---|
| <name> | <subsystem> | `docs/substrate/gotchas/<name>.md` |

## Tests of record

The high-level tests that *pin* user-visible behavior. Not every test — only the ones whose failure means the system is broken.

| Test | What it pins | Path |
|---|---|---|
| <name> | <behavior> | `tests/...` |

## CI gates

Checks that gate merge beyond unit tests passing.

| Gate | What it checks | Workflow file |
|---|---|---|
| <name> | <rule> | `.github/workflows/...` |

## Local commands

The team-blessed way to run, build, test, lint, and develop locally.

| Task | Command |
|---|---|
| Run | `...` |
| Test | `...` |
| Lint | `...` |
| Type-check | `...` |
| Format | `...` |
| Database setup | `...` |

## Review gates

Human-review processes the codebase depends on (e.g., "all migrations require schema-team review," "all changes to AuditService require security-team review"). These are the rules that aren't yet executable.

- <subsystem>: <gate>

## Missing memory

Substrate the team knows is missing. Keeping this list visible makes the gaps fixable.

- <gap>
- ...

## How to use this map

- Before changing a subsystem, read the spec(s) and any related matrix/invariant/gotcha docs linked here.
- After adding new substrate, update this map (or it didn't really happen).
- During `cohesive-review`, this map is read first.
