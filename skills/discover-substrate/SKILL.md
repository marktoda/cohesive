---
name: discover-substrate
description: Use when starting Cohesive work on a feature, refactor, review, or audit, before brainstorming or implementing. Discovers what the codebase already remembers — specs, tests, behavior matrices, named invariants, semantic linters, gotchas, architectural seams, CI checks, and local commands — and identifies what is missing. Triggers on "discover substrate", "what does this codebase remember", "what specs/tests/invariants exist for X", "audit substrate before changing X", and is invoked by every Cohesive workflow as its first step.
---

# Discover substrate

## What this skill produces

A structured **substrate discovery report** that names the docs, tests, invariants, matrices, gotchas, semantic linters, and CI checks the codebase already has — and explicitly calls out what is *missing* in the area the user is about to change. Every other Cohesive skill leans on this output. Run it once per session per change surface; later skills can re-use the report rather than re-scanning.

## When to invoke

Always invoke this skill (or compose its output) before:
- `brainstorm-design` — so options are grounded in what the system already says about itself
- `rewrite-specs` — so the rewrite knows what it's overwriting
- `cohesive-review --scope codebase` — so the review knows where the normative docs live
- `cohesive-review --scope diff` — so the review can connect changed files to their substrate
- `cohesive-review --scope substrate` — same scan, but emphasizes missing-memory findings

Skip only when the user has *already* run discovery in this session and named the change surface. In that case, re-use the prior report.

## Inputs

- **Change surface description.** What subsystem, file, or behavior is the user about to touch? Ask one short question if unclear ("which subsystem is this about?") rather than scanning the world.
- **Repository root.** Default to current working directory.
- **Optional subsystem name.** Used to bias which docs/tests are surfaced as "relevant."

## Process

### 1. Run the inventory script

Use `${CLAUDE_PLUGIN_ROOT}/scripts/scan_substrate.py` to get a fast structured inventory. Markdown output by default, JSON if you need to filter programmatically.

```bash
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/scan_substrate.py .
```

The script categorizes files into 16 buckets (normative_docs, design_docs, invariant_docs, gotcha_docs, behavior_matrices, test_strategy, tests, ci_files, package_files, schema_files, migration_files, type_defs, config, custom_linters, local_commands, cohesive_artifacts). It skips `.git`, `node_modules`, `.venv`, `.worktrees`, and similar.

Do **not** glob the whole repo with Read or Grep before running this. The script is bounded; ad-hoc reads are not.

### 2. Read normative docs first

In this order, if present:
1. `CLAUDE.md` and `AGENTS.md` (highest priority — these often contain rules the codebase depends on)
2. `architecture.md` and `README.md`
3. `docs/design/**`, `docs/specs/**`, `docs/adr/**`
4. `docs/invariants/**`, `docs/gotchas/**`, `docs/testing/**`

If the user named a subsystem, prefer docs whose path or title contains the subsystem name. Read normative docs *before* reading implementation files — they tell you what the system is supposed to do, which is more important than what it currently does.

### 3. Locate behavior tests, not just unit tests

For the change surface, find:
- e2e / integration / contract / live tests that exercise user-visible behavior
- regression tests linked to known incidents (often named after a bug ID or scar)
- behavior-matrix-cell tests if the codebase uses that pattern

These are the tests that *guarantee* behavior. Lower-level unit tests are useful but secondary for substrate purposes.

### 4. Search for existing matrices, invariants, gotchas, linters

Even if the codebase doesn't have dedicated docs/invariants directories, the equivalents may exist informally:
- comments containing words like "INVARIANT", "MUST", "NEVER", "WARNING", "DO NOT"
- custom check scripts under `scripts/`, `bin/`, `tools/`
- pre-commit hooks
- CI workflow files that fail on conditions beyond test pass
- ESLint/ruff/etc plugins that enforce custom rules

Surface these as **existing substrate**, even if they're not in the canonical location.

### 5. Identify locality boundaries

Where are the seams? Look for:
- module/package directory structure
- internal API surfaces (`index.ts`, `__init__.py` exports, `pub` declarations)
- type boundaries between subsystems
- existing decisions about what's shared vs. local

Note any place where the existing locality looks suspicious (suspected premature centralization, cross-subsystem reach-around, or oddly duplicated logic that may want abstraction).

### 6. Identify missing substrate

For the change surface, name the substrate that *doesn't* exist but probably should:
- behavior the change touches that has no spec
- branchy behavior with no matrix
- global rules implied by the change with no named invariant
- regressions that would be easy to introduce with no test
- conventions that depend on reviewer memory with no semantic linter
- known scars relevant to the change with no gotcha doc

This is the highest-value section of the report. The point of substrate discovery is not to celebrate what exists but to find what's missing before code is written.

### 7. Recommend the next Cohesive skill

Based on what you found and what the user asked for, recommend exactly one next skill to invoke (or hand back to `cohesively` if the route is unclear).

## Output format

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

### Missing memory
- <highest-leverage gap first>
- ...

### Recommended next Cohesive skill
- `cohesive:<skill-name>` — <reason>
```

## Acceptance criteria

- The "Target change surface" section names concrete files, not abstractions.
- "Existing" and "Missing memory" are clearly separated.
- The output does not treat docs, tests, comments, and linters as interchangeable enforcement — each has its own line.
- "Missing memory" is ranked by leverage (what would prevent the most predictable future bug), not by alphabetical order.
- Exactly one "Recommended next Cohesive skill" is named.

## What this skill is *not*

- Not a full architecture review. Discovery surfaces; review judges. Use `cohesive-review --scope codebase` for judgment.
- Not a substrate audit. Audit emphasizes *missing* memory across the whole repo. Discovery is scoped to a change surface.
- Not a search for code defects. Findings about defective code belong in `cohesive-review --scope diff` or `--scope codebase`, not here.

## Red flags

- Reading more than ~15 files during discovery. If you're reading this much, you're doing review, not discovery. Stop and recommend `cohesive-review --scope codebase`.
- Producing a report with "Existing" full and "Missing memory" empty. That means you searched for what's there and not for what isn't. Re-read step 6.
- Recommending more than one next skill. Pick one. The router can route again later.
- Mentioning the implementation files before the spec/test files. Substrate discovery reads normative docs first.
