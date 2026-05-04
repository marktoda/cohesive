# Substrate Discovery Report — [change surface]

The canonical shape `discover-substrate` produces. Five downstream skills consume this artifact, each emphasizing a different cut. This template defines the canonical fields so the consumers don't drift independently.

## Frontmatter

```md
**Date:** YYYY-MM-DD
**Change surface:** <subsystem name or "(repo-wide)">
**Repo root:** <path>
**Discovery script:** scripts/scan_substrate.py output (or n/a if invoked inline)
```

## Required sections (in order)

```md
## Substrate discovered

### Target change surface
- Subsystem: <name or "(repo-wide)">
- Main files likely involved: <paths>
- Neighboring subsystems: <names>

### Relevant specs/docs
- <path> — <one-line summary of what it normatively claims>
- ...

### Behavior matrices
- Existing: <path or "none">
- Missing but likely needed: <description>

### Named invariants
- Existing: <name(s) and where they live>
- Candidate invariants: <new candidates surfaced by this change>

### Existing enforcement
- Tests: <which tests pin which behavior>
- Types: <where the type system enforces something load-bearing>
- Constraints: <DB / schema / runtime>
- CI checks: <workflow files that gate on more than just tests>
- Semantic linters: <custom checks, comment-as-rule, lint plugins>

### Known gotchas / scars
- <name or symptom> — <one line>

### Locality boundaries
- Subsystem A seam at <path>; coupling to B via <interface>
- Suspected premature centralization at <path>
- Suspected duplication-that-wants-abstraction at <paths>

### Package files (for library-native review)
- <path> — <type: package.json / pyproject.toml / Cargo.toml / go.mod / etc.>
- ...

### Missing memory
- <highest-leverage gap first>
- ...

### Recommended next Cohesive skill
- `cohesive:<skill-name>` — <reason>
```

## Empty-substrate verdict

When the inventory is trivially empty (no normative docs, no tests, no CI files, no `docs/substrate/` content), `discover-substrate` returns the verdict line `**Empty-substrate verdict: yes**` near the top of the report, before §"Target change surface". Downstream skills check for this line and adapt:

- `cohesive-review --scope codebase` halts with a "this codebase is too sparse for architecture review; run `cohesive:substrate-audit` first" message.
- `brainstorm-design` broadens its option-generation rather than grounding in nothing.
- `substrate-audit` is the natural home for an empty-substrate codebase; it produces a "missing memory inventory" without needing prior substrate.

## Which sections each consumer reads

A reader of this template should know which downstream skill cares about which section, so the format can evolve without surprising any one consumer:

| Consumer | Primary sections | Secondary | Ignored |
|---|---|---|---|
| `brainstorm-design` | Relevant specs, Named invariants, Locality boundaries, Future direction (read from "Missing memory") | Behavior matrices, Known gotchas | Existing enforcement, Package files |
| `rewrite-specs` | Relevant specs, Behavior matrices, Named invariants, Known gotchas | Locality boundaries | Package files |
| `cohesive-review --scope codebase` | All sections — passed verbatim to all 4 reviewer agents | — | — |
| `cohesive-review --scope diff` | Relevant specs (scoped to changed files), Existing enforcement, Locality boundaries | Behavior matrices, Known gotchas | Package files (unless library-native triggered by diff size) |
| `substrate-audit` | Missing memory, Locality boundaries (premature-centralization risks) | All other sections | — |

When adding a new field to the report, name which consumer needs it and add a row above.

## Anti-patterns

| Anti-pattern | Why it's wrong | Fix |
|---|---|---|
| Adding section without naming the consumer | Format drifts toward irrelevance for every consumer | Add row to "Which sections each consumer reads" |
| Renaming a section in `discover-substrate/SKILL.md` without updating this template | Implicit-contract drift | Edit both in the same change; the consumers also reference this template |
| Filling "Existing enforcement" with "none" entries everywhere | Equivalent to saying "no enforcement exists"; misleading on a repo with informal scars | Use empty bullet (omit the line) when truly nothing exists; use "Reviewer judgment / convention" when informal enforcement does exist |
| Missing-memory section ranked alphabetically | Substrate audit downstream consumes ranked-by-leverage | Always rank by "what would prevent the most predictable future bug" |
