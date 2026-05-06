# Substrate vocabulary

The agent-internal vocabulary Cohesive uses precisely (named invariants, behavior matrices, gotchas, semantic linters, specs, conventions) and the user-facing translation that explains each in plain terms a non-Cohesive-native engineer can act on.

This file is the canonical translation table. It feeds three surfaces:

1. **`cohesive:init`** renders the per-row translation inline when proposing a draft artifact, so users learn the vocabulary by watching their own code get translated into it.
2. **Chat trailers** translate substrate-shape internal labels to user-facing labels per the audience seam in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.
3. **The negative-space doc** (`${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/scope.md` — what Cohesive does and doesn't do) cites the user-facing definitions when explaining what each artifact type is for.

The audience seam this file implements: persisted-file vocabulary keeps the precise term (so agent reasoning stays sharp); chat-render vocabulary uses the translation (so non-Cohesive-natives don't bounce on jargon).

## How to read this table

Each row carries:

- **Agent-internal name** — the precise term used in skill bodies, persisted files, agent dispatch prompts, and substrate docs.
- **User-facing translation** — the 1-paragraph plain-English definition rendered in chat surfaces and in `init`'s output.
- **What it earns over a "rule"** — what specifically distinguishes this substrate type from a generic rule or convention. Without this column, contributors won't know when to use which type.
- **Example signal** — the file:line shape `init` looks for to propose a draft of this type.

## Substrate types

### Named invariant

- **Agent-internal name:** Named invariant.
- **User-facing translation:** A rule the code is *guaranteed* to follow because the system would refuse to build, deploy, or pass review if it didn't. Distinct from a rule we agree on by convention — a named invariant has a structural enforcement (a test, a type constraint, a CI check, a runtime assertion, or a custom validator). The "named" part means it has a name that other docs cite: when a future change touches behavior the invariant pins, the citation makes the dependency legible.
- **What it earns over a "rule":** Mechanical enforcement. A rule says "we should X"; an invariant says "the system refuses to ship without X." The promotion criterion is when the rule has fired enough times for a bug to be worth structurally fencing.
- **Example signal:** A comment containing `MUST`, `NEVER`, `INVARIANT`, or `WARNING` next to a function whose violation would be hard to catch in review (e.g., `// NEVER store tokens unhashed` in an auth module).
- **Where it lives:** `docs/substrate/invariants/<INVARIANT_NAME>.md`.
- **Template:** `${CLAUDE_PLUGIN_ROOT}/references/templates/invariant.md`.

### Behavior matrix

- **Agent-internal name:** Behavior matrix.
- **User-facing translation:** A decision table — when input X is this AND case Y is that, the system does Z. Captures branchy behavior so an agent (or future engineer) can read off the decision function without reading the code that implements it. Especially valuable for code that branches over enums, feature flags, user-roles, or tenant configurations.
- **What it earns over a "rule":** Completeness. A matrix says "for *all* combinations of (X, Y), here's the outcome" — an exhaustive table catches the cell nobody wrote a test for. A scattered set of `if/elif` branches doesn't.
- **Example signal:** A switch statement or chain of `if/elif` over an enum or string literal with 4+ branches; a feature-flag dispatch with multiple flag combinations; a function whose docstring lists "cases."
- **Where it lives:** `docs/substrate/matrices/<matrix-name>.md`.
- **Template:** `${CLAUDE_PLUGIN_ROOT}/references/templates/behavior-matrix.md`.

### Gotcha

- **Agent-internal name:** Gotcha.
- **User-facing translation:** A scar — a thing that's easy to get wrong because the reason it's done this way isn't obvious from the code. Captures the *why* behind a non-obvious choice so a future contributor doesn't innocently undo it. Different from a comment because gotchas are findable across the codebase as a category, not buried in a single file.
- **What it earns over a "rule":** History. A gotcha records what happened when someone *did* get it wrong — which makes the reason for the rule durable. A naked rule says "don't do X"; a gotcha says "don't do X because incident #47 happened when we did."
- **Example signal:** A comment containing `FIXME`, `HACK`, `WORKAROUND`, `// because`, or a reference to a bug ID; a regression test named after an incident; a code path with comments substantially longer than the code.
- **Where it lives:** `docs/substrate/gotchas/<gotcha-name>.md`.
- **Template:** `${CLAUDE_PLUGIN_ROOT}/references/templates/gotcha.md`.

### Semantic linter (custom check)

- **Agent-internal name:** Semantic linter.
- **User-facing translation:** A custom check that fails CI when a specific pattern shows up — like a grep that says "this string can never appear in this file" or "every file matching X must contain Y." Distinct from generic linters (eslint, ruff) because semantic linters enforce *project-specific* rules, not language-wide style. This is how a named invariant grows mechanical teeth.
- **What it earns over a "rule":** Cheap mechanical enforcement. A semantic linter is a small grep/awk script in CI; cheaper than authoring tests, more reliable than reviewer attention. Used for rules that are easy to grep but hard to test.
- **Example signal:** Existing `scripts/check_*.sh` or `scripts/validate_*.sh` files; CI workflow steps that grep source code; pre-commit hooks beyond standard formatters.
- **Where it lives:** `scripts/<check-name>.{sh,py}` (or repo-native location); spec at `docs/substrate/conventions/<convention-name>.md` §"How this is enforced."
- **Template:** None yet; spec lives inline in the convention doc that names the rule.

### Spec

- **Agent-internal name:** Spec.
- **User-facing translation:** A doc that says what the system does — not how, not why, just what. Specs are the docs an agent reads to understand intended behavior without reading code. Distinct from a README (which positions for users) and from architecture docs (which describe shape). A spec is the answer to "what does this subsystem promise."
- **What it earns over a "rule":** Behavioral coverage. A spec describes *what the code claims to do*; an invariant or matrix describes *one rule the code follows*. Specs are bigger; they sit above invariants and matrices.
- **Example signal:** Files named `*.spec.md`, `SPEC.md`, or `docs/specs/`; long docstrings on public APIs that read as behavioral promises; documented commitments in CHANGELOG entries that describe new behavior.
- **Where it lives:** `docs/specs/<subsystem>.md` or repo-native equivalent.
- **Template:** None canonical; specs are repo-shaped.

### Convention (vs invariant)

- **Agent-internal name:** Convention.
- **User-facing translation:** A rule we agree on but don't enforce structurally — easy to get wrong if you're tired. Conventions are the rules that haven't (or shouldn't) graduated to invariants because the wording is still settling, the scope is unclear, or the cost of mechanical enforcement isn't yet justified. Honest about depending on reviewer attention.
- **What it earns over an invariant:** Lightness. Conventions are cheap to write and easy to change; invariants are expensive to land and harder to evolve. A team accumulates conventions first, then promotes the load-bearing ones.
- **Promotion criteria:** A convention promotes to a named invariant when (a) the wording stabilizes for ≥2 release cycles, (b) a real regression has occurred that the convention was meant to prevent, and (c) a structural enforcement (test/linter/CI check) is feasible. See `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` for the reference pattern.
- **Where it lives:** `docs/substrate/conventions/<convention-name>.md`.
- **Template:** None canonical; convention docs are prose.

## Why this distinction matters

The single highest-leverage thing this table does: **pin the convention/invariant boundary**. Most non-Cohesive-native teams use "rule" and "convention" interchangeably; Cohesive's distinctive value is in saying "this rule has earned mechanical enforcement; that one hasn't yet." The table makes that distinction legible without requiring the user to read 5 conventions to discover it.

When `cohesive:init` runs against a codebase, it doesn't just propose artifacts — it surfaces this distinction by saying, for each finding: "this comment looks like an invariant, but it has no enforcement structure. Promote to a named invariant *and* add a check, or document it as a convention with a known promotion path." The user learns the distinction by deciding it, on their own code.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md` — the seam this table implements at the substrate-type layer (parallel to verdict-vocabulary.md at the verdict layer).
- `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` — the analogous table for verdict labels.
- `${CLAUDE_PLUGIN_ROOT}/skills/init/SKILL.md` — the skill that consumes this table to render translated drafts.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` — promotion criteria for convention → invariant.
