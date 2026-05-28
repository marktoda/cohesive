---
name: discover-substrate
description: Use when starting substrate-first Cohesive work — before brainstorming a refactor, rewriting specs, or running a cohesion review — to inventory what specs, behavior matrices, named invariants, gotchas, semantic linters, CI checks, and local commands the codebase already carries, and to surface what's missing in the change surface. Substrate-first scope only; for general codebase exploration use Superpowers' research/exploration skills instead. Triggers on "discover substrate", "what specs/invariants/gotchas exist for X", "audit substrate before changing X", "what does Cohesive find in this repo".
---

# Discover substrate

## What this skill produces

A structured **substrate discovery report** that names the docs, tests, invariants, matrices, gotchas, semantic linters, and CI checks the codebase already has — and explicitly calls out what is *missing* in the area the user is about to change. Every other Cohesive skill leans on this output. Run it once per session per change surface; later skills can re-use the report rather than re-scanning.

## Voice

Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output. The voice guide is the load-bearing source for verdict-leads, header-depth cap, density budgets, and forbidden phrasings; the imperative above is what triggers the model to load it via a Read tool call. Do not reproduce the imperative or any citation to the voice guide inside the Output format render template — instructions placed inside render templates leak verbatim into user-facing output.

## When to invoke

**Primary invocation: dispatched internally by a consumer skill.** As of the 2026-05-06 discovery-as-internal-step rewrite, four consumer skills dispatch `cohesive:discover-substrate` themselves via the Skill tool as a sub-step of their own Process:

- `brainstorm-design` — Step 0 (per its Hard constraint #2)
- `audit-substrate` — Step 1 (per its Hard constraint #1)
- `review-codebase` — Phase 1.0 (per its Hard constraint #1)
- `review-diff` — Step 2 (per its Hard constraint #1)

In these cases, the user does not invoke this skill directly — it runs as plumbing inside the consumer's chat trailer. The consumer reads the persisted report from disk and produces the user-visible output. (Note: `rewrite-specs` is *not* an internal-discovery consumer — its prereq is a chosen direction, not a discovery report.)

**Direct invocation (the rare case).** A user can invoke `/cohesive:discover-substrate` directly when they want a raw substrate inventory without a brainstorm / audit / review on top of it. Direct invocation produces the full inventory render in chat per the §"Output format" template below; this is the only path that surfaces discovery's chat output to the user.

**Cross-skill reuse via the optional-override path.** When a discovery report from an earlier session step covers the same change surface, a consumer skill's "optional override" clause (Hard constraint #1, all four consumers) lets the dispatch prompt name the existing report path; the consumer skips re-running discovery and reads the named report directly.

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
4. `docs/testing/**` (or repo-native equivalents)

If the user named a subsystem, prefer docs whose path or title contains the subsystem name. Read normative docs *before* reading implementation files — they tell you what the system is supposed to do, which is more important than what it currently does.

### 3. Locate behavior tests, not just unit tests

For the change surface, find:
- e2e / integration / contract / live tests that exercise user-visible behavior
- regression tests linked to known incidents (often named after a bug ID or scar)
- behavior-matrix-cell tests if the codebase uses that pattern

These are the tests that *guarantee* behavior. Lower-level unit tests are useful but secondary for substrate purposes.

### 4. Search for existing matrices, invariants, gotchas, linters

Even if the codebase doesn't have dedicated invariants directories, the equivalents may exist informally:
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

### 7. Detect empty-substrate codebases

Emit `**Empty-substrate verdict: yes**` near the top of the report (before §"Target change surface") when *either* of these holds:

- **Trivially empty:** no `CLAUDE.md`, no `AGENTS.md`, no `ARCHITECTURE.md`, no `docs/` content, no tests, no CI files.
- **Below the substrate-review threshold:** the inventory surfaces fewer than 5 normative documents in total. "Normative documents" means anything in the `Normative docs`, `Design docs / specs / ADRs`, `Invariant docs`, `Gotcha / scar docs`, or `Behavior matrices` buckets of `scan_substrate.py`.

Either condition is sufficient. The single signal lets every downstream consumer make the same decision from one source of truth — don't replicate the threshold logic in `review-codebase`'s Phase 1.5 or anywhere else.

Downstream skills check for the verdict line and adapt:

- `review-codebase` halts at Phase 1.5 and recommends `audit-substrate` instead
- `brainstorm-design` broadens its option-generation rather than grounding in nothing
- `audit-substrate` proceeds normally — it's the right home for empty-substrate codebases

If the verdict applies, the report's "Missing memory" section should note the high-level absence rather than enumerating per-area gaps — there's not enough substrate yet to scope what's missing.

### 8. Recommend the next Cohesive skill

Based on what you found and what the user asked for, recommend exactly one next skill to invoke (or hand back to `cohesively` if the route is unclear).

## Output format

The canonical shape lives at `${CLAUDE_PLUGIN_ROOT}/references/templates/substrate-discovery-report.md`. That template carries the field definitions and a "Which sections each consumer reads" map; this section reproduces the chat-rendered shape. The chat render is substance, not bookkeeping (per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2): every Missing memory item is a concrete defect (a named implicit rule, a specific unmatricized branch, a comment-as-rule with file:line), never a finding-ID family reference back to a prior review.

```md
# Substrate Discovery — <scope>

## Substrate discovered

### Empty-substrate verdict

**Empty-substrate verdict: yes**  <!-- only when applicable per Step 7; consumed structurally by review-codebase Phase 1.5 and brainstorm-design Phase 1. The bold-line form is the literal string downstream skills grep for; do not change it. Omit the line entirely when the verdict is "no". -->

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
- **<concrete-gap-name>** — `<path>:<line>` — <quoted excerpt of the implicit rule, the unmatricized branch, the comment-as-rule, or the stale doc>. The substrate that would close this: <named invariant / behavior matrix / gotcha / spec / linter — concrete enough that a reader could begin drafting it>.
- ...

(Each Missing memory item is a concrete defect with file:line evidence and the artifact-shape that would close it. Cross-iteration references like "review finding 6 family" or "the X deferred items" are bookkeeping shorthand; if a prior review identified a gap that still holds, restate the gap concretely with current evidence — do not reference its ID.)

### Next
- <decision-shaped sentence — what the user gets next>. *(`cohesive:<skill-name>`.)* **<Payload-kind>:** <payload — substitute the appropriate kind from `references/templates/chat-trailer.md` §"How `### Next` carries payload": `**Files to edit:**` for `cohesive:rewrite-specs`, `**Design question:**` for `cohesive:brainstorm-design`, `**Scope:**` for `cohesive:review-codebase` / `cohesive:review-diff` / `cohesive:audit-substrate` / `superpowers:writing-plans`>.
```

## Acceptance criteria

- The "Target change surface" section names concrete files, not abstractions.
- "Existing" and "Missing memory" are clearly separated.
- The output does not treat docs, tests, comments, and linters as interchangeable enforcement — each has its own line.
- "Missing memory" is ranked by leverage (what would prevent the most predictable future bug), not by alphabetical order.
- Every Missing memory item carries `<path>:<line>` (or a named pattern when no single line carries the gap) plus the artifact-shape that would close it. Bare "<highest-leverage gap first>" or finding-ID family references are render failures per rule 2b.
- The "Next" footer carries payload (change surface, design question, or audit scope) per rule 5a — not just a skill name and reason.
- Exactly one next-skill recommendation is named in the `### Next` footer.

## What this skill is *not*

- Not a full architecture review. Discovery surfaces; review judges. Use `review-codebase` for judgment.
- Not a substrate audit. Audit emphasizes *missing* memory across the whole repo. Discovery is scoped to a change surface.
- Not a search for code defects. Findings about defective code belong in `review-diff` or `review-codebase`, not here.

## Red flags

- Reading more than ~15 files during discovery. If you're reading this much, you're doing review, not discovery. Stop and recommend `review-codebase`.
- Producing a report with "Existing" full and "Missing memory" empty. That means you searched for what's there and not for what isn't. Re-read step 6.
- Recommending more than one next skill. Pick one. The router can route again later.
- Mentioning the implementation files before the spec/test files. Substrate discovery reads normative docs first.
- Missing memory items rendered as bare phrases without file:line evidence ("invariant for token TTL is missing") or as cross-iteration finding-ID references ("review finding 6 family"). Violates rule 2b.
- `### Next` names a skill plus a reason without naming the change surface, design question, or scope. Violates rule 5a.
