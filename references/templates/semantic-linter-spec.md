# Semantic Linter Spec: [name]

> A spec for a codebase-specific check that encodes institutional knowledge. This template captures the rule's intent precisely enough that an engineer (or agent) can implement the check in the codebase's preferred linting framework. Cohesive v1 produces specs only; implementation is per-codebase.

## Rule

One sentence. What the linter forbids or requires, in the most specific form possible.

Example: "Every environment variable referenced in code must appear in `env.spec.ts`."

## Why this matters

The institutional knowledge this rule encodes. Ideally references a past incident, a class of bugs the team has seen, or a contract the codebase depends on. Generic "best practice" rationales are weak — strong rationales are codebase-specific.

## Detection strategy

How the linter would detect violations. Be concrete enough that an implementer can choose tooling.

Examples:
- AST pattern: "any call to `process.env.X` where `X` is not present in the array exported from `env.spec.ts`"
- Regex on imports: "any file under `src/decision-kernel/` that imports from `src/connectors/` is a violation"
- File-level invariant: "every file matching `routes/**/*.ts` must export a function named `handler`"
- Cross-file consistency: "every column in a Prisma schema declared as union must have a corresponding TypeScript discriminated union"

## Allowed exceptions

Cases the rule deliberately does not cover. List explicitly — un-enumerated exceptions become drift.

- <exception> — <why allowed>

If exceptions are allowed via inline comments (e.g., `// cohesive-linter-ignore: <reason>`), specify the comment format and require a reason.

## False positive risks

Patterns the rule might flag that aren't actually violations. Be honest about these — they affect whether the rule will be turned off in practice.

- <pattern> — <why it might trigger; how to handle>

## Implementation sketch

Pseudocode or framework-specific notes for the implementer:

```text
For each file in <scope>:
  Parse AST
  Find <pattern>
  For each match:
    Check <condition>
    If violated, emit <message>
```

Include the **error message** the linter should produce. The message is part of the substrate — it teaches contributors why the rule exists at the moment it triggers.

Example error message:
> "ENV_SPEC_DIVERGENCE: `process.env.SLACK_TOKEN` referenced here but not declared in `env.spec.ts`. Every environment variable used in code must be declared in the spec so deployment validation works. See `docs/substrate/invariants/ENV_SPEC_COVERAGE.md`."

## CI integration

Where the check runs:

- <pre-commit hook / lint script / CI workflow path>
- Failure mode: <warning / error / blocking>

## Related substrate

- Invariant this enforces: `<INVARIANT_NAME>` (if applicable)
- Gotcha this prevents: <name>
- Specs that depend on this rule: <paths>

## Maintenance

- Owner: <team or person>
- Last updated: YYYY-MM-DD
- Known false positive rate: <estimate>
