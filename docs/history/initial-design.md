# Cohesive Plugin Specification

**Working name:** Cohesive  
**Plugin namespace:** `cohesive`  
**Primary router skill:** `cohesively`  
**Primary plugin command:** `/cohesive:cohesively`  
**Optional standalone alias:** `/cohesive`  
**Spec version:** 0.1  
**Date:** 2026-05-04

> **Note (preserved historical artifact):** This document is the v0.1 design vision. **It is not authoritative for current state.** The binding architectural map is `/ARCHITECTURE.md`. The dated implementation plan that drove v0.1 (with the §1 delta table reconciling vision vs ship) is preserved at `docs/history/plans/2026-05-04-mvp-implementation.md`. Read this spec for design intent and historical context; read `ARCHITECTURE.md` for what the system currently is.

---

## 1. Executive summary

Cohesive is a Claude Code plugin / skill pack for substrate-first agentic software engineering.

Its purpose is to help an agent make, plan, or review changes in a way that preserves the codebase's behavior, invariants, architectural intent, product direction, and accumulated scars. It is inspired by the workflow discipline of Superpowers, but its center of gravity is different.

Superpowers optimizes for disciplined implementation. Cohesive optimizes for durable judgment.

Cohesive should help the codebase remember.

The plugin should make Claude ask, before editing code:

> What should this codebase remember so the next human or agent can safely change this area without needing the original architect in the room?

The initial product should be a composable skill pack with one router skill and multiple subskills. Users can invoke the router when they want Cohesive to choose the workflow, or invoke subskills directly when they already know what they want.

Example commands:

```text
/cohesive:cohesively brainstorm a refactor of intake classification
/cohesive:brainstorm-design add retry behavior for webhook delivery
/cohesive:architecture-review review the Cornbot codebase
/cohesive:invariant every external mutation emits an audit event
/cohesive:review-change-cohesion review my current diff
```

If the optional standalone alias is installed, users can also run:

```text
/cohesive brainstorm a refactor of intake classification
```

The core user promise:

> Cohesive helps Claude make changes that are not merely locally plausible, but globally coherent with the system's specs, tests, invariants, gotchas, and future direction.

---

## 2. Background and motivating theory

Agentic coding makes implementation cheaper. The scarce resource becomes confidence.

Agents are good at preserving local style and making plausible edits. They are much worse at preserving global rules that are not made visible in the codebase: audit rules, product-specific invariants, abstraction boundaries, incident scars, and subtle architectural priors.

The plugin is based on the following substrate model:

```text
The substrate is everything around the implementation that helps future contributors make correct changes:

- specs
- tests
- behavior matrices
- type boundaries
- semantic linters
- CI checks
- docs
- incident notes
- architectural seams
- naming conventions
- examples
- local development commands
```

The substrate is how the codebase remembers.

Cohesive should repeatedly turn implicit senior-engineer judgment into durable artifacts:

```text
Prompt once         -> useful once
Review comment     -> useful for one PR
Spec               -> useful for future reasoning
Behavior matrix    -> useful for branchy behavior
Named invariant    -> useful for global rules
Test               -> useful forever
Semantic linter    -> changes the shape of every future PR
Architecture seam  -> reduces required context for future changes
Gotcha note        -> prevents rediscovering old bugs
```

---

## 3. Product goals

### 3.1 Primary goals

1. **Make substrate-first work easy.** Before planning or implementing behavior changes, Claude should discover and update the relevant substrate.
2. **Make the router useful.** `/cohesive:cohesively` should infer which subskills are needed from the user's request.
3. **Support direct subskill invocation.** Users should be able to call `/cohesive:architecture-review`, `/cohesive:invariant`, `/cohesive:review-change-cohesion`, etc. directly.
4. **Pressure-test designs before implementation.** For feature/refactor brainstorming, Claude should read existing docs, propose options, evaluate them against the current substrate and future product direction, and only then rewrite specs or plan code.
5. **Rewrite specs to the chosen end state.** Once a direction is chosen, Claude should be able to cut a design worktree and hard-rewrite docs/specs as if the new design were already true.
6. **Use fresh-eyes review.** Important design rewrites and architecture reviews should use subagents or forked contexts to review without inheriting all of the main agent's assumptions.
7. **Review architecture against the system's own priors.** Deep reviews should begin by reading normative docs, then stop if the docs are inconsistent or wrong before reviewing code.
8. **Turn findings into substrate artifacts.** Critiques should map to specs, tests, invariants, matrices, semantic linters, gotchas, locality decisions, or CI checks.

### 3.2 Non-goals

1. Cohesive is not a generic code style reviewer.
2. Cohesive is not a replacement for Superpowers-style implementation workflows.
3. Cohesive should not force all changes into heavyweight process.
4. Cohesive should not recommend centralization merely because code is duplicated.
5. Cohesive should not implement future features just because they are anticipated.
6. Cohesive should not treat stale docs as ground truth.
7. Cohesive should not bury architectural judgment under a long list of minor issues.

---

## 4. Naming recommendation

Use **Cohesive** as the plugin/product name and **substrate** as the central concept inside the methodology.

```text
Plugin/package: cohesive
Router skill: cohesively
Primary plugin command: /cohesive:cohesively
Optional bare alias: /cohesive
Core concept: substrate
```

Rationale:

- `cohesive` names the desired quality of the whole system.
- `substrate` names the mechanism that produces that quality.
- The language composes well: cohesion review, cohesive architecture, cohesive implementation, substrate audit, substrate map, substrate debt.

Avoid naming the pack `substrate`; it is a strong internal concept but sounds too narrow and infrastructural as the public product name.

---

## 5. Distribution and command model

### 5.1 Plugin-native structure

> **See `docs/implementation_plan.md` §2 for the binding v0.1 file structure.** The structure below describes the design vision (17 skills, 8 agents); the plan collapses to 6 skills + 5 agents + 9 templates as the MVP surface. Use the plan §1 reconciliation table as the authoritative mapping.

Claude Code plugins are namespaced. A plugin named `cohesive` with a skill named `architecture-review` creates:

```text
/cohesive:architecture-review
```

Recommended plugin structure:

```text
cohesive/
├── .claude-plugin/
│   └── plugin.json
├── README.md
├── skills/
│   ├── cohesively/
│   │   └── SKILL.md
│   ├── discover-substrate/
│   │   └── SKILL.md
│   ├── brainstorm-design/
│   │   └── SKILL.md
│   ├── pressure-test-design/
│   │   └── SKILL.md
│   ├── using-worktrees/
│   │   └── SKILL.md
│   ├── rewrite-specs/
│   │   └── SKILL.md
│   ├── review-spec-cohesion/
│   │   └── SKILL.md
│   ├── architecture-review/
│   │   └── SKILL.md
│   ├── review-change-cohesion/
│   │   └── SKILL.md
│   ├── plan-implementation/
│   │   └── SKILL.md
│   ├── implement-cohesively/
│   │   └── SKILL.md
│   ├── invariant/
│   │   └── SKILL.md
│   ├── matrix/
│   │   └── SKILL.md
│   ├── semantic-linter/
│   │   └── SKILL.md
│   ├── gotcha/
│   │   └── SKILL.md
│   ├── locality/
│   │   └── SKILL.md
│   ├── substrate-audit/
│   │   └── SKILL.md
│   └── substrate-map/
│       └── SKILL.md
├── agents/
│   ├── spec-cohesion-reviewer.md
│   ├── architecture-spec-drift-reviewer.md
│   ├── domain-model-reviewer.md
│   ├── invariant-enforcement-reviewer.md
│   ├── locality-abstraction-reviewer.md
│   ├── test-guarantee-reviewer.md
│   ├── library-native-reviewer.md
│   └── agent-readiness-reviewer.md
├── references/
│   ├── substrate-model.md
│   ├── cohesion-rubric.md
│   ├── design-pressure-testing.md
│   ├── locality-over-centralization.md
│   ├── future-fit.md
│   └── architecture-review-rubric.md
├── templates/
│   ├── substrate-map.md
│   ├── behavior-matrix.md
│   ├── invariant.md
│   ├── semantic-linter-spec.md
│   ├── gotcha.md
│   ├── design-delta-ledger.md
│   ├── cohesion-review.md
│   ├── architecture-review-report.md
│   └── implementation-plan.md
└── scripts/
    ├── scan_substrate.py
    ├── new_artifact.py
    └── summarize_git_context.py
```

### 5.2 Optional standalone alias

For users who want `/cohesive` as a bare command, provide an optional standalone skill:

```text
.claude/skills/cohesive/SKILL.md
```

This skill should be a thin alias that delegates to the plugin router:

```md
---
description: Entry point for the Cohesive methodology. Use when planning, implementing, or reviewing code changes where behavior contracts, invariants, semantic linters, specs, gotchas, architecture locality, or future product direction may matter.
---

# Cohesive

Delegate this task to the Cohesive plugin router.

REQUIRED SUB-SKILL: Use `cohesive:cohesively`.

Pass through the user's arguments:

$ARGUMENTS
```

---

## 6. Core principles

Every skill should reinforce these principles.

### 6.1 Substrate before implementation

Before implementing a behavior change, identify where that behavior is specified and enforced. If the behavior is not specified or enforced, update or propose the substrate first.

### 6.2 Specs are a design surface

Docs are not merely retrospective explanations. For architecture work, the spec is the cheapest place to discover a bad idea. Cohesive should encourage agents to update docs before code when behavior or architecture changes.

### 6.3 Make judgment executable

If a rule matters, make it structural:

```text
- test
- type
- database constraint
- architectural boundary
- semantic linter
- CI check
- runtime assertion
```

A convention without enforcement is just a hope.

### 6.4 Name invariants

Important global rules should have stable names. Example:

```text
AUDIT_EXTERNAL_MUTATION
```

Named invariants give agents, tests, and reviewers a shared handle.

### 6.5 Behavior matrices for branchy behavior

When behavior has cases, write the cases down. Each case should have a stable ID. Tests should be named after matrix cells where practical.

### 6.6 Locality over premature centralization

Shared abstractions are valuable when the shared contract is real. Premature centralization increases the context required to make safe changes. Local duplication may be preferable when it preserves subsystem clarity.

### 6.7 Future fit without overbuilding

Cohesive should capture future product pressure without turning every possible future into current scope. The target is affordance, not speculative implementation.

### 6.8 Fresh-eyes review

Important specs and architecture decisions should be reviewed by a fresh context that did not participate in the original design discussion.

### 6.9 Findings must become durable

Architecture review findings should map to a substrate improvement:

```text
Spec update
Matrix cell
Named invariant
Semantic linter
Gotcha note
Test guarantee
Type boundary
CI check
Locality decision
```

---

## 7. MVP scope

Build the MVP as a useful design and review pack before building every artifact-specific skill.

### 7.1 MVP skills

```text
cohesively
 discover-substrate
 brainstorm-design
 pressure-test-design
 using-worktrees
 rewrite-specs
 review-spec-cohesion
 architecture-review
 review-change-cohesion
 substrate-audit
```

### 7.2 MVP references/templates

```text
docs/substrate/designs/substrate-model.md
docs/substrate/designs/cohesion-rubric.md
docs/substrate/designs/design-pressure-testing.md
docs/substrate/designs/locality-over-centralization.md
docs/substrate/designs/architecture-review-rubric.md

templates/substrate-map.md
templates/behavior-matrix.md
templates/invariant.md
templates/semantic-linter-spec.md
templates/gotcha.md
templates/design-delta-ledger.md
templates/cohesion-review.md
templates/architecture-review-report.md
```

### 7.3 V1 expansion skills

```text
plan-implementation
implement-cohesively
invariant
matrix
semantic-linter
gotcha
locality
substrate-map
future-fit
finish-branch
```

---

## 8. Router skill: `cohesively`

### 8.1 Purpose

`cohesively` is the main entrypoint. It classifies the user's request and invokes the relevant workflow skills.

It should be usable both directly:

```text
/cohesive:cohesively refactor intake classification
```

and through the standalone alias:

```text
/cohesive refactor intake classification
```

### 8.2 Frontmatter draft

```yaml
---
name: cohesively
description: Main Cohesive router. Use when the user wants to plan, implement, review, refactor, brainstorm, audit, or improve code in a way that preserves specs, behavior matrices, named invariants, semantic linters, gotchas, architecture locality, tests, and future product direction.
---
```

### 8.3 Router decision table

| User intent | Invoke |
|---|---|
| Brainstorm feature/refactor | `discover-substrate` -> `brainstorm-design` -> `pressure-test-design` |
| User wants design-doc-first workflow | `discover-substrate` -> `brainstorm-design` -> `pressure-test-design` -> `using-worktrees` -> `rewrite-specs` -> `review-spec-cohesion` |
| User says “review the architecture/codebase” | `architecture-review` |
| User says “audit missing docs/specs/tests/invariants” | `substrate-audit` |
| User says “review my PR/diff/change” | `review-change-cohesion` |
| User names a must-hold rule | `invariant` and possibly `semantic-linter` |
| User describes branchy behavior | `matrix` |
| User describes repeated agent mistakes/conventions | `semantic-linter` |
| User mentions old bugs/incidents/scars | `gotcha` |
| User asks whether to centralize/split/abstract | `locality` |
| User has approved spec and wants implementation plan | `plan-implementation` |
| User has approved plan and wants code | `implement-cohesively` |

### 8.4 Router required behavior

1. Determine whether the user is asking for design, implementation, review, audit, or artifact creation.
2. Prefer process skills before implementation skills.
3. If behavior or architecture is changing, route through substrate discovery before code.
4. If the request is ambiguous, make a best-effort route rather than asking for a broad clarification.
5. When useful, ask one precise clarifying question about future pressure or scope.
6. Do not implement code until either:
   - relevant substrate has been reviewed/updated, or
   - the user explicitly asks to skip substrate work.
7. Report which Cohesive workflow is being used and why.

### 8.5 Router output

The router should begin with a short workflow statement:

```md
I'm going to treat this as a Cohesive design workflow: discover substrate, brainstorm options, pressure-test them, then prepare a spec rewrite if we choose a direction.
```

It should then invoke or follow the appropriate subskills.

---

## 9. Skill: `discover-substrate`

### 9.1 Purpose

Build a map of what the codebase already remembers before proposing or reviewing changes.

### 9.2 Frontmatter draft

```yaml
---
name: discover-substrate
description: Discover relevant specs, tests, behavior matrices, invariants, semantic linters, gotchas, architectural seams, local commands, and CI checks before planning, reviewing, or implementing a change.
---
```

### 9.3 Inputs

- User request or change description
- Repository root
- Optional subsystem name
- Optional target files

### 9.4 Files to inspect

Prefer these if present:

```text
CLAUDE.md
AGENTS.md
README.md
architecture.md
docs/design/**
docs/specs/**
docs/adr/**
docs/invariants/**
docs/gotchas/**
docs/testing/**
tests/**
.github/workflows/**
package.json / pyproject.toml / Cargo.toml / go.mod
scripts/**
```

Also inspect code-adjacent substrate:

```text
comments that explain why
custom linters/check scripts
schema files
migration files
database constraints
type definitions
contract tests
e2e tests
live tests
```

### 9.5 Process

1. Identify the likely subsystem or change surface.
2. Read normative docs before implementation files.
3. Search for relevant behavior tests and test commands.
4. Search for existing matrices, invariants, gotchas, and linters.
5. Identify locality boundaries and architectural seams.
6. Identify missing substrate.
7. Produce a substrate discovery report.

### 9.6 Output format

```md
## Substrate discovered

### Target change surface
- Subsystem:
- Main files likely involved:
- Neighboring subsystems:

### Relevant specs/docs
- ...

### Behavior matrices
- Existing:
- Missing but likely needed:

### Named invariants
- Existing:
- Candidate invariants:

### Existing enforcement
- Tests:
- Types:
- Constraints:
- CI checks:
- Semantic linters:

### Known gotchas/scars
- ...

### Locality boundaries
- ...

### Missing memory
- ...

### Recommended next Cohesive skill
- ...
```

### 9.7 Acceptance criteria

- The output names concrete files when available.
- The output separates “found” from “missing.”
- The output does not treat comments/docs/tests as interchangeable enforcement.
- The output recommends the next skill.

---

## 10. Skill: `brainstorm-design`

### 10.1 Purpose

Turn a rough product, feature, or refactor idea into coherent design options grounded in existing substrate and future product pressure.

### 10.2 Frontmatter draft

```yaml
---
name: brainstorm-design
description: Use before code when brainstorming a feature, refactor, or architecture change. Reads existing substrate, asks targeted questions, proposes options, and prepares designs for pressure testing.
---
```

### 10.3 Process

1. Require or perform `discover-substrate` first.
2. Clarify the current problem and near-term scope.
3. Capture future pressure separately from current requirements.
4. Identify non-goals.
5. Identify relevant invariants and gotchas.
6. Propose 2-4 design options.
7. For each option, describe substrate changes, locality impact, future fit, and risks.
8. Recommend one option or a hybrid.

### 10.4 Clarifying question style

Ask targeted questions one at a time when needed. Prefer questions like:

```text
Which future pressure should this design optimize for most: adding more connectors, supporting agent-originated messages, or making policy configurable?
```

Avoid vague questions like:

```text
What do you want?
```

### 10.5 Output format

```md
## Current scope
- ...

## Future pressure, not current scope
- ...

## Non-goals
- ...

## Design options

### Option A: [name]
**Summary:**
**Why it fits:**
**Substrate changes required:**
**Locality impact:**
**Future fit:**
**Risks:**

### Option B: [name]
...

## Initial recommendation
...

## Ready for pressure test
Yes / No
```

### 10.6 Acceptance criteria

- At least two credible options are presented for non-trivial changes.
- Future ideas are captured without being turned into mandatory current implementation.
- Options discuss substrate changes, not just code changes.
- The recommendation explicitly discusses locality and invariants.

---

## 11. Skill: `pressure-test-design`

### 11.1 Purpose

Attack each proposed design against existing specs, behavior matrices, invariants, tests, gotchas, architecture seams, and future product direction.

### 11.2 Frontmatter draft

```yaml
---
name: pressure-test-design
description: Stress-test design options against current docs, behavior matrices, invariants, tests, gotchas, locality boundaries, and future product direction before choosing an architecture.
---
```

### 11.3 Questions to answer for each option

```text
What docs would need to change?
What behavior matrix cells would be added, removed, or invalidated?
Which invariants get stronger, weaker, or newly required?
Which existing tests become misleading?
Which semantic linter would prevent future mistakes?
Which gotcha does this rediscover?
Which subsystem now needs more context to change?
Does this centralize too early?
Does this duplicate locally for clarity?
What future idea does this make easy?
What future idea does this make hard?
What invalid change remains too easy to ship?
```

### 11.4 Output format

```md
## Pressure test summary

| Option | Cohesion | Substrate delta | Future fit | Locality | Main risk |
|---|---:|---|---|---|---|
| A | High/Medium/Low | Small/Medium/Large | ... | ... | ... |

## Breakage analysis

### Docs that would need to change
- ...

### Existing assumptions that break
- ...

### Behavior matrix impact
- ...

### Invariant impact
- ...

### Test guarantee impact
- ...

### Gotchas triggered
- ...

### Locality/centralization concerns
- ...

## Recommendation after pressure test
...

## Required substrate before implementation
- Specs:
- Matrices:
- Invariants:
- Tests/checks:
- Gotchas:
- Semantic linters:
```

### 11.5 Acceptance criteria

- The recommendation is based on system-specific substrate, not generic taste.
- Each meaningful option has a clear failure mode.
- The output identifies what must be updated before code.

---

## 12. Skill: `using-worktrees`

### 12.1 Purpose

Create an isolated git worktree for design rewrites, implementation, architecture review experiments, or substrate audits.

This skill can be thinner than Superpowers's worktree skill, but should preserve the same safety principles: isolated workspace, clear branch, ignored worktree directory, and baseline verification.

### 12.2 Frontmatter draft

```yaml
---
name: using-worktrees
description: Use when starting Cohesive design rewrite, implementation, or audit work that should be isolated from the current workspace. Creates a git worktree and verifies safety.
allowed-tools: Bash(git *) Bash(ls *) Bash(grep *) Bash(pwd)
---
```

### 12.3 Worktree modes

```text
design: for hard-rewriting specs/docs to chosen end state
implementation: for code changes from an approved plan
audit: for exploration and reports without touching main workspace
```

### 12.4 Process

1. Determine mode: design, implementation, or audit.
2. Choose worktree directory:
   - Prefer `.worktrees/` if present or ignored.
   - Then `worktrees/`.
   - Then project/user preference in `CLAUDE.md`.
   - If no safe option exists, use a conservative default and explain.
3. Verify worktree directory is ignored or add it to `.gitignore` only with user approval or explicit skill rule.
4. Create branch name:
   - `design/<slug>` for design work
   - `impl/<slug>` for implementation work
   - `audit/<slug>` for audit work
5. Create worktree.
6. Verify `git status`.
7. Run baseline checks if obvious and cheap.

### 12.5 Output format

```md
## Cohesive worktree ready

Mode: design / implementation / audit
Path: `.worktrees/cohesive-<slug>`
Branch: `<mode>/<slug>`

Baseline:
- Git status:
- Tests:
- Doc checks:

Next skill:
- ...
```

---

## 13. Skill: `rewrite-specs`

### 13.1 Purpose

Hard-rewrite docs and specs to describe the chosen design end state as if it were already true.

This is a flagship Cohesive skill.

### 13.2 Frontmatter draft

```yaml
---
name: rewrite-specs
description: Rewrite design docs, specs, behavior matrices, invariants, gotchas, and substrate maps to describe an approved design end state. Use after brainstorming and pressure testing, before implementation.
---
```

### 13.3 Required behavior

1. Require a chosen design direction.
2. Prefer running in a design worktree.
3. Read existing specs and related docs.
4. Rewrite obsolete docs rather than appending contradictory notes.
5. Add or update behavior matrices for branchy behavior.
6. Add or update named invariants for global rules.
7. Add or update gotchas for known scars.
8. Add or update semantic linter specs when enforcement is needed.
9. Update substrate map if present.
10. Produce a design delta ledger.

### 13.4 Anti-patterns

Do not:

```text
- Add a vague “future plan” section while leaving old normative behavior intact.
- Describe the chosen end state as “maybe” or “proposal” unless it truly is still speculative.
- Preserve obsolete concepts for politeness.
- Leave contradictory docs in place.
- Make implementation the only place where behavior is knowable.
- Treat all future pressure as current scope.
```

### 13.5 Output format

```md
## Spec rewrite complete

### Files rewritten
- ...

### Files added
- ...

### Conceptual changes
| Old concept | New concept | Status |
|---|---|---|
| ... | ... | Replaced / Merged / Removed / Tightened |

### New or updated substrate
- Specs:
- Behavior matrices:
- Invariants:
- Gotchas:
- Semantic linter specs:
- Tests/checks proposed:

### Remaining ambiguity
- ...

### Ready for fresh-eyes review?
Yes / No
```

---

## 14. Skill: `review-spec-cohesion`

### 14.1 Purpose

Run a fresh-eyes review of rewritten specs to judge whether the new design is coherent, implementable, enforceable, and aligned with the system's future direction.

### 14.2 Frontmatter draft

```yaml
---
name: review-spec-cohesion
description: Fresh-eyes review of design docs/specs after a Cohesive rewrite. Checks internal coherence, behavior coverage, invariants, enforcement paths, gotchas, future fit, and locality.
context: fork
agent: general-purpose
---
```

### 14.3 Reviewer prompt

```md
You are a fresh-eyes cohesion reviewer.

You did not participate in the design discussion. Judge only the rewritten specs, the discovered substrate, and the stated current/future scope.

Your job is to determine whether the new design is internally coherent and whether a future human or agent could implement it without needing the original architect's memory.

Review for:
- behavior knowable outside implementation
- specs that contradict each other
- branchy behavior without matrix coverage
- unnamed invariants
- invariants without enforcement paths
- missing gotchas/scars
- future pressure acknowledged but not overbuilt
- locality boundaries clear
- shared abstractions justified
- obsolete concepts left behind
- vague TODO/TBD behavior
- “we will” language in end-state normative sections

Return:
- Approved
- Issues Found
- Design Incoherent

For each issue, explain the risk and the substrate artifact that should be repaired.
```

### 14.4 Output format

```md
# Spec Cohesion Review

**Status:** Approved / Issues Found / Design Incoherent

## Executive judgment
...

## Blocking issues
- ...

## Important issues
- ...

## Substrate gaps
- ...

## Locality concerns
- ...

## Future-fit concerns
- ...

## Enforcement concerns
- ...

## Recommended repairs
1. ...
```

### 14.5 Acceptance criteria

- The review can block implementation.
- The review is grounded in rewritten docs, not the prior conversation.
- Every issue names the substrate artifact to repair.

---

## 15. Skill: `architecture-review`

### 15.1 Purpose

Perform a deep, principled architecture and codebase review through the Cohesive lens.

This is the refined version of the user's architecture review prompt.

The goal is not merely to find bugs or style issues. The goal is to determine whether the codebase has a coherent, durable substrate: clear specs, aligned implementation, principled domain concepts, enforceable invariants, appropriate locality, strong tests, and enough encoded judgment that future humans and agents can safely extend the system without relying on the original architect's memory.

### 15.2 Frontmatter draft

```yaml
---
name: architecture-review
description: Deep repo-wide or subsystem architecture review. Reads normative docs first, stops on broken specs, then uses focused subagents to review code/spec alignment, domain model clarity, locality, invariants, tests, library-native alignment, complexity, and agent-readiness.
---
```

### 15.3 Required workflow

#### Phase 1: Read normative substrate

Read, if present:

```text
CLAUDE.md
AGENTS.md
README.md
architecture.md
docs/design/**
docs/specs/**
docs/adr/**
docs/invariants/**
docs/gotchas/**
docs/testing/**
```

Output a summary:

```md
## Claimed system shape

### Product goal
...

### Architectural priors
...

### Intended seams
...

### Named invariants
...

### Testing philosophy
...

### Future direction implied by docs
...
```

#### Phase 2: Spec-prior review

Before reviewing implementation, determine whether the docs themselves are coherent.

Ask:

```text
Are the docs internally consistent?
Are architectural priors still good?
Are there contradictions between design docs?
Are old concepts still present?
Are important rules underspecified?
Are invariants named and enforced?
```

If the substrate is seriously inconsistent, stop and return:

```md
## Spec-prior issues found

I should not do a full implementation review yet because the substrate itself is inconsistent.

### Blocking spec issues
1. ...

### Recommended substrate repairs
1. ...

### Why this matters
...
```

#### Phase 3: Focused subagent exploration

If the docs are coherent enough to continue, use focused reviewers.

Recommended reviewers:

1. **Spec-drift reviewer**
   - Finds implementation that disagrees with docs/specs/invariants.
2. **Domain-model reviewer**
   - Finds confusing, overlapping, unnecessary, weakly named, or poorly typed concepts.
3. **Locality and abstraction reviewer**
   - Finds premature centralization, wrong shared abstractions, and context-heavy seams.
4. **Invariant and enforcement reviewer**
   - Finds rules the system depends on and checks whether they are enforced.
5. **Test-guarantee reviewer**
   - Evaluates e2e, live, contract, regression, and behavior-matrix coverage.
6. **Library-native alignment reviewer**
   - Finds places where the code fights frameworks/libraries/type systems.
7. **Complexity and elegance reviewer**
   - Finds unnecessary indirection, confusing control flow, and over-complication.
8. **Agent-readiness reviewer**
   - Judges whether future agents can safely modify the system with bounded context.

#### Phase 4: Synthesis

The final report should not be a laundry list. It should start with a thesis.

Example thesis:

```md
Cornbot is broadly moving toward the right architecture: connector-local adapters, shared decision kernels, and explicit workflow state. The main risk is that several company-defining invariants are still enforced by convention rather than structure. The code is locally competent, but the substrate is not yet strong enough for the company to scale development without founder memory.
```

### 15.4 Output format

```md
# Cohesive Architecture Review

## Verdict
Healthy / Mostly healthy / Cohesive but under-enforced / Spec drift risk / Architecture risk

## Executive thesis
...

## Spec-prior review

### Docs read
- ...

### Claimed architectural priors
- ...

### Spec inconsistencies
- ...

### Recommended spec changes
- ...

## System cohesion scorecard

| Area | Rating | Summary |
|---|---:|---|
| Spec coherence |  |  |
| Code/spec alignment |  |  |
| Domain model clarity |  |  |
| Invariant enforcement |  |  |
| Test guarantees |  |  |
| Locality and seams |  |  |
| Library-native alignment |  |  |
| Agent-readiness |  |  |
| Future extensibility |  |  |

## Highest-leverage findings

### 1. [Finding title]

**Severity:** Blocker / High / Medium / Low  
**Category:** Spec drift / Invariant / Locality / Tests / Domain model / Library alignment / Substrate  
**Why it matters:**  
...

**Evidence:**  
...

**Recommended fix:**  
...

**Substrate artifact to add or update:**  
Spec / behavior matrix / invariant / gotcha / semantic linter / test / type boundary

## Confusing or weak concepts

| Concept | Issue | Recommendation |
|---|---|---|
| ... | ... | ... |

## Invariants that should be named

| Invariant | Current enforcement | Recommended enforcement |
|---|---|---|
| ... | ... | ... |

## Test guarantee gaps

| Behavior | Current coverage | Risk | Recommended test |
|---|---|---|---|
| ... | ... | ... | ... |

## Locality and abstraction review
...

## Library-native alignment opportunities
...

## Substrate improvements

### Specs to rewrite
- ...

### Behavior matrices to add
- ...

### Semantic linters to add
- ...

### Gotchas to document
- ...

## Recommended roadmap

### First: repair substrate
1. ...

### Then: simplify architecture
1. ...

### Then: strengthen enforcement
1. ...
```

### 15.5 Cleaned-up seed prompt

Include this in `docs/substrate/designs/architecture-review-rubric.md` or directly in the skill.

```md
You are an expert software architect performing a Cohesive architecture review.

Your goal is not merely to find bugs or style issues. Your goal is to determine whether this codebase has a coherent, durable substrate: clear specs, aligned implementation, principled domain concepts, enforceable invariants, appropriate locality, strong tests, and enough encoded judgment that future humans and agents can safely extend the system without relying on the original architect's memory.

Begin by reading the normative substrate:
- CLAUDE.md / AGENTS.md
- architecture.md
- README.md
- docs/design/**
- docs/specs/**
- docs/invariants/**
- docs/gotchas/**
- test strategy docs, if present

First summarize the system's stated goals, architectural priors, intended seams, invariants, testing philosophy, and implied future direction.

Before reviewing code, perform a spec-prior review. If the docs are internally inconsistent, stale, underspecified, or based on architectural priors you believe are wrong, stop and propose improvements to the substrate itself. Do not review code against a broken spec.

If the substrate is coherent enough to continue, use focused subagents to explore the codebase. Assign reviewers for:
1. Code/spec alignment
2. Domain model clarity
3. Locality and abstraction boundaries
4. Invariant enforcement
5. Test guarantees, especially e2e/live/contract tests
6. Library-native and type-system alignment
7. Complexity, elegance, and maintainability
8. Agent-readiness and missing substrate

Review whether the implementation agrees with the stated design. Look for code that is overly complicated, confusing, over-abstracted, under-abstracted, poorly aligned with external libraries, weakly typed, or dependent on implicit knowledge. Identify concepts that can be removed, merged, renamed, tightened, or made more principled.

Treat tests as part of the substrate. Determine whether important behavior is actually guaranteed by tests, types, constraints, semantic linters, or CI checks. Pay special attention to high-level e2e tests, live tests, behavior matrices, and regression tests for known gotchas.

Evaluate whether the architecture makes common future changes easy, dangerous changes visible, and invalid changes hard to ship. Prefer locality over premature centralization unless the shared contract is real and enforceable.

Return a principled architecture review with:
- A clear executive thesis
- Spec-prior issues, if any
- Ranked findings by leverage and severity
- Evidence for each finding
- Recommended fixes
- Substrate artifacts to add or update
- Named invariants that should exist
- Behavior matrices that should exist
- Semantic linter opportunities
- Test guarantee gaps
- Concepts to merge, remove, rename, or tighten
- A phased roadmap for making the system more elegant, powerful, robust, and maintainable

Optimize for a system the company can build on for years without the original architect's help.
```

---

## 16. Skill: `review-change-cohesion`

### 16.1 Purpose

Review a PR, branch, diff, or uncommitted change for system cohesion, not just code cleanliness.

### 16.2 Frontmatter draft

```yaml
---
name: review-change-cohesion
description: Review a PR, branch, or current diff for code/spec alignment, invariant preservation, test guarantees, semantic linter opportunities, gotchas, and locality/abstraction risks.
---
```

### 16.3 Process

1. Load the current diff or PR diff.
2. Identify behavior changes.
3. Discover related substrate.
4. Check whether specs/matrices/invariants/tests changed with behavior.
5. Identify hidden global rules the change may violate.
6. Check if the change centralizes too early or increases required context.
7. Recommend substrate improvements.
8. Return a severity-ranked report.

### 16.4 Questions to answer

```text
What behavior changed?
Where is that behavior specified?
What invariant might this violate?
What rule is being left to reviewer memory?
What tests encode the behavior?
What semantic linter should exist if this mistake is likely to recur?
Did this change centralize too early?
Did this localize appropriately?
Did this delete or obscure a scar?
Did this create a new gotcha?
```

### 16.5 Output format

```md
# Change Cohesion Review

**Verdict:** Pass / Pass with notes / Needs substrate / Risky / Block

## Main concern
...

## Findings

| Severity | Area | Finding | Suggested substrate |
|---|---|---|---|
| Blocking | Invariant | ... | ... |

## Behavior/spec alignment
...

## Invariant preservation
...

## Test guarantee gaps
...

## Locality and abstraction concerns
...

## Highest-leverage fix
...
```

---

## 17. Skill: `substrate-audit`

### 17.1 Purpose

Find what the codebase fails to remember.

This is narrower than `architecture-review`. It does not need to judge the whole architecture. It inventories missing memory.

### 17.2 Frontmatter draft

```yaml
---
name: substrate-audit
description: Scan a repo or subsystem for missing substrate: absent specs, branchy behavior without matrices, unnamed invariants, unencoded gotchas, weak test guarantees, missing semantic linters, and unclear local commands.
---
```

### 17.3 Output format

```md
# Substrate Audit

## High-risk implicit rules
- ...

## Branchy behavior without matrix
- ...

## Invariants without enforcement
- ...

## Gotchas trapped in comments/issues
- ...

## Docs that describe old reality
- ...

## Premature centralization risks
- ...

## Missing local commands
- ...

## Highest-leverage fixes
1. ...
2. ...
3. ...
```

---

## 18. Skill: `plan-implementation`

### 18.1 Purpose

Turn approved substrate into an implementation plan.

This should be compatible with Superpowers-style planning, but it adds substrate requirements and confidence gates.

### 18.2 Frontmatter draft

```yaml
---
name: plan-implementation
description: Create an implementation plan from approved specs and substrate. Includes exact files, task breakdown, tests, confidence gates, invariant preservation, and substrate artifacts.
---
```

### 18.3 Output format

```md
# [Feature Name] Cohesive Implementation Plan

> For agentic workers: preserve the listed substrate. Do not implement behavior that contradicts the approved specs, behavior matrices, or named invariants.

## Goal
...

## Approved substrate
- Spec:
- Behavior matrix:
- Named invariants:
- Gotchas:
- Semantic linter specs:

## Architecture
...

## Files to create or modify
| File | Responsibility | Why this file |
|---|---|---|
| ... | ... | ... |

## Confidence gates
- Failing tests to write first:
- Tests that must pass:
- Semantic checks:
- CI checks:
- Manual review questions:

## Tasks

### Task 1: [name]

**Invariant preserved:** ...  
**Matrix cells:** ...  
**Gotcha:** ...

- [ ] Write failing test.
- [ ] Verify it fails for the right reason.
- [ ] Implement minimal change.
- [ ] Run targeted tests.
- [ ] Update substrate if needed.
- [ ] Commit.
```

---

## 19. Skill: `implement-cohesively`

### 19.1 Purpose

Execute an approved implementation plan while preserving substrate.

### 19.2 Required behavior

1. Require an implementation plan or approved spec.
2. Work in an implementation worktree.
3. Execute task-by-task.
4. Prefer TDD for behavior changes.
5. After each meaningful task, review:
   - spec compliance
   - substrate compliance
   - code quality
6. Do not create implementation that contradicts approved specs.
7. If the plan reveals a substrate problem, stop and revise substrate.

### 19.3 Substrate compliance review questions

```text
Did the implementation preserve named invariants?
Did it update behavior matrix cells?
Did it add the promised tests/checks?
Did it create a bypass around semantic enforcement?
Did it increase required context unnecessarily?
Did it violate locality?
```

---

## 20. Artifact-specific skills

These can be implemented in V1 if not in MVP.

### 20.1 `invariant`

Purpose: create or update a named invariant.

Template:

```md
# [INVARIANT_NAME]

## Rule
...

## Scope
Applies to:
- ...

Does not apply to:
- ...

## Why this matters
...

## Runtime paths
- API endpoints:
- Background jobs:
- Agent workflows:
- Future runtime paths:

## Enforcement
- Tests:
- Types:
- Constraints:
- Semantic linters:
- Runtime wrappers:
- CI checks:

## Known bypass risks
- ...

## Review checklist
- ...
```

Example:

```text
AUDIT_EXTERNAL_MUTATION: Every external mutation must emit an audit event.
```

### 20.2 `matrix`

Purpose: create or update a behavior matrix for branchy behavior.

Template:

```md
# [Subsystem] Behavior Matrix

| Cell | Scenario | Input/context | Expected decision/behavior | Notes | Tests |
|---|---|---|---|---|---|
| C001 | ... | ... | ... | ... | test_C001... |
```

Rules:

```text
- Every cell gets a stable ID.
- Tests should be named after matrix cells where practical.
- New branchy behavior means adding or updating cells.
- Matrix cells should be referenced by implementation plans and reviews.
```

### 20.3 `semantic-linter`

Purpose: specify or implement a codebase-specific check that encodes institutional knowledge.

Template:

```md
# Semantic Linter: [name]

## Rule
...

## Why this matters
...

## Detection strategy
...

## Allowed exceptions
...

## False positive risks
...

## Implementation sketch
...

## CI integration
...
```

Examples:

```text
- every environment variable referenced in code must appear in the env spec
- every external mutation path must have audit coverage
- dependency X may only be imported through wrapper Y
- every design hook in the index must point to a real spec
```

### 20.4 `gotcha`

Purpose: document an incident, scar, tempting wrong fix, or dangerous helper.

Template:

```md
# Gotcha: [name]

## Symptom
...

## Why it happened
...

## Tempting wrong fix
...

## Correct pattern
...

## Related invariant
...

## Tests/checks that preserve this
...
```

### 20.5 `locality`

Purpose: decide whether to centralize, duplicate, split, or abstract.

Template:

```md
# Locality Analysis

## Change being considered
...

## Subsystems affected
- ...

## Shared contract
Is the shared contract real yet?
Yes / No / Partially

## Context required before change
Before:
After:

## Options
- Keep local duplication
- Centralize through narrow interface
- Split abstraction
- Delete abstraction

## Recommendation
...

## Why
...
```

### 20.6 `substrate-map`

Purpose: create or update a repo-level map of how the codebase remembers.

Template:

```md
# Substrate Map

## Specs
...

## Behavior matrices
...

## Invariants
...

## Semantic linters
...

## Gotchas
...

## Local commands
...

## Review gates
...

## Missing memory
...
```

---

## 21. Flagship workflow: Cohesive Design Rewrite

This is the key flow described by the user.

### 21.1 User story

As a senior engineer, when brainstorming or planning a feature/refactor, I want Claude to thoroughly read the documentation, propose design options, pressure-test them against current design docs and future product ideas, then rewrite the specs in a design worktree and get a fresh-eyes cohesion review before implementation.

### 21.2 Command example

```text
/cohesive brainstorm a refactor of intake classification so it can support future Slack, Telegram, and agent-originated messages without prematurely centralizing everything
```

### 21.3 Router-selected skills

```text
1. discover-substrate
2. brainstorm-design
3. pressure-test-design
4. using-worktrees
5. rewrite-specs
6. review-spec-cohesion
```

### 21.4 Detailed flow

#### Step 1: Discover substrate

The agent reads docs/specs/tests and reports:

```md
## Relevant substrate

I found:
- `docs/intake/classification.md`
- `docs/connectors/slack.md`
- `docs/connectors/telegram.md`
- `tests/intake/classifier.test.ts`

Potential substrate gaps:
- Branchy classifier behavior is mostly implicit in tests.
- Future agent-originated messages are not represented in docs.
- Slack thread behavior appears special-cased but not named.
```

#### Step 2: Capture current scope and future pressure

Output:

```md
## Current scope
- Refactor intake classification design docs.
- Preserve current behavior.
- Define seams for Slack, Telegram, and agent-originated messages.

## Future pressure, not current scope
- More connectors likely.
- Agent workflows likely.
- Per-tenant policy possible but not immediate.

## Non-goals
- Do not build plugin runtime.
- Do not centralize all connector behavior yet.
```

#### Step 3: Propose options

Example options:

```md
### Option A: Connector-local classification
Each connector owns classification. Shared code only provides primitives.

### Option B: Central classifier with connector adapters
Connectors normalize into a shared intake event. Central classifier handles all channels.

### Option C: Local normalization, shared pure decision kernel
Each connector normalizes locally into a minimal common event. A pure decision function handles only stable cross-channel decisions. Connector-specific cases remain local.
```

#### Step 4: Pressure test

Output:

```md
| Option | Locality | Future fit | Matrix fit | Risk |
|---|---|---|---|---|
| A | Strong | Medium | Weak | Behavior drift |
| B | Weak | High | Strong | Premature centralization |
| C | Strong | High | Strong | Boundary must be enforced |

Recommended direction: Option C.
```

#### Step 5: Cut design worktree

```text
.worktrees/cohesive-intake-classification-design
design/intake-classification-cohesion
```

#### Step 6: Hard rewrite specs

The agent rewrites docs as if Option C is the new end state.

It should not write:

```text
We should consider moving toward a shared kernel.
```

It should write:

```text
Intake classification is organized around connector-local normalization and a shared pure decision kernel.
```

#### Step 7: Fresh-eyes review

Subagent returns:

```md
## Cohesion Review

**Status:** Issues Found

### Blocking
- The spec says connector-specific thread semantics remain local, but matrix cell C014 describes Slack thread behavior inside the shared kernel.

### Important
- Agent-originated messages are listed as future pressure, but there is no example normalized event shape showing whether actor identity is human, agent, or system.

### Recommended fixes
- Move C014 to the Slack connector matrix or redefine it as a channel-neutral thread-continuation case.
- Add an actor-origin field to the normalized event spec, but mark agent-specific behavior as out of current scope.
```

#### Step 8: Repair and handoff

The main agent repairs the specs and reruns review. Once approved:

```md
Spec rewrite approved.

Ready next steps:
1. Create implementation plan from rewritten substrate.
2. Keep this as design-only branch for human review.
3. Open PR with docs-only substrate rewrite.
```

---

## 22. Workflow: Audit invariant from essay

### 22.1 Command

```text
/cohesive:invariant every external mutation emits an audit event
```

### 22.2 Expected behavior

1. Name the invariant:

```text
AUDIT_EXTERNAL_MUTATION
```

2. Define external mutation.
3. Enumerate runtime paths:

```text
API endpoint
background job
agent workflow
future runtime path
```

4. Find current mutation paths.
5. Find audit enforcement.
6. Identify bypasses.
7. Propose tests/checks/semantic linter.
8. Create or update invariant artifact.

### 22.3 Example output

```md
# AUDIT_EXTERNAL_MUTATION

## Rule
Every external mutation must emit an audit event.

## Scope
Applies to:
- API endpoints that mutate external state
- Background jobs that mutate external state
- Agent workflows that mutate external state
- Future runtime paths that mutate external state

## Enforcement
- API mutation wrapper emits audit event.
- Background job mutation helper must route through audited mutation service.
- Agent workflow mutations must use audited tools.
- Semantic linter should flag direct calls to external mutation clients outside approved wrappers.

## Known bypass risks
- Background jobs can bypass API-layer wrappers.
- Tests can mock mutation clients without asserting audit event.
```

---

## 23. Workflow: Deep architecture review

### 23.1 Command

```text
/cohesive:architecture-review review the Cornbot codebase
```

### 23.2 Flow

```text
1. Read normative docs.
2. Summarize claimed system shape.
3. Stop if specs are inconsistent.
4. Dispatch focused subagents.
5. Synthesize thesis.
6. Produce ranked findings.
7. Convert findings into substrate improvements.
8. Recommend phased roadmap.
```

### 23.3 Required review dimensions

```text
Spec coherence
Code/spec alignment
Domain model clarity
Invariant enforcement
Test guarantees
Locality and seams
Library-native alignment
Agent-readiness
Future extensibility
```

---

## 24. Implementation notes for engineer

### 24.1 Skill file size

Keep each `SKILL.md` focused. Put long rubrics, examples, and templates into `references/` and `templates/`.

### 24.2 Subagents and forked context

Use `context: fork` for skills that should perform isolated review, especially:

```text
review-spec-cohesion
architecture-review subreviews
substrate-audit subreviews
```

Alternatively, define custom agents in `agents/` and have main skills dispatch work to them.

### 24.3 Dynamic context injection

Use dynamic context injection sparingly for safe read-only commands, such as:

```md
!`git status --short`
!`find docs -maxdepth 3 -type f | sort`
!`find . -maxdepth 3 -name 'CLAUDE.md' -o -name 'architecture.md'`
```

Avoid heavy shell commands in skill bodies. Prefer scripts for repeatable scanning.

### 24.4 Scripts

#### `scan_substrate.py`

Purpose: produce a fast inventory of candidate substrate files.

Output JSON or Markdown with:

```text
- docs files
- test files
- CI files
- config files
- known skill files
- likely invariant docs
- likely gotcha docs
- likely behavior matrices
```

#### `new_artifact.py`

Purpose: create an artifact from a template.

Example:

```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/new_artifact.py invariant AUDIT_EXTERNAL_MUTATION
```

#### `summarize_git_context.py`

Purpose: summarize branch, worktree, status, and recent commits for review workflows.

---

## 25. Testing plan

### 25.1 Static tests

Write a small validation script that checks:

```text
- plugin.json exists
- every skill directory has SKILL.md
- each SKILL.md has frontmatter
- each skill has a description
- referenced templates exist
- referenced references exist
- no commands/skills/hooks are incorrectly placed inside .claude-plugin/
```

### 25.2 Manual scenario tests

Test these scenarios in a sample repo.

#### Scenario A: Feature brainstorming

Input:

```text
/cohesive:cohesively brainstorm adding webhook retries
```

Expected:

```text
- Router chooses discover-substrate, brainstorm-design, pressure-test-design.
- Does not edit code.
- Produces options and substrate requirements.
```

#### Scenario B: Design rewrite

Input:

```text
/cohesive:cohesively rewrite specs for chosen Option C
```

Expected:

```text
- Creates design worktree.
- Rewrites docs to end state.
- Produces design delta ledger.
- Runs fresh-eyes spec cohesion review.
```

#### Scenario C: Architecture review

Input:

```text
/cohesive:architecture-review
```

Expected:

```text
- Reads docs first.
- Stops if docs contradict.
- Otherwise dispatches focused reviewers.
- Produces thesis and ranked findings.
```

#### Scenario D: PR review

Input:

```text
/cohesive:review-change-cohesion
```

Expected:

```text
- Reviews current diff.
- Identifies behavior/spec/test/invariant/locality gaps.
- Produces verdict.
```

#### Scenario E: Invariant artifact

Input:

```text
/cohesive:invariant every external mutation emits an audit event
```

Expected:

```text
- Names invariant.
- Defines scope.
- Enumerates runtime paths.
- Proposes enforcement and semantic linter opportunities.
```

---

## 26. Acceptance criteria for MVP

The MVP is acceptable when:

1. The plugin loads in Claude Code with namespace `cohesive`.
2. `/cohesive:cohesively` can route between design, review, audit, and implementation planning tasks.
3. `/cohesive:architecture-review` performs the docs-first, spec-prior architecture review flow.
4. `/cohesive:review-spec-cohesion` can perform a fresh-eyes review of rewritten specs.
5. `/cohesive:review-change-cohesion` reviews a diff for substrate/cohesion risks.
6. `/cohesive:discover-substrate` produces a useful inventory of specs, tests, invariants, matrices, gotchas, CI checks, and missing memory.
7. `/cohesive:rewrite-specs` can rewrite docs to a chosen end state and produce a design delta ledger.
8. The pack includes templates for behavior matrices, invariants, semantic linters, gotchas, substrate maps, and cohesion reviews.
9. The README explains when to use Cohesive vs Superpowers.
10. Manual scenario tests pass in at least one real repo.

---

## 27. Relationship to Superpowers

Cohesive should be compatible with Superpowers but should not require it.

Superpowers-like patterns to emulate:

```text
- composable skills
- mandatory workflow discipline
- process skills before implementation skills
- brainstorming before code
- git worktrees for isolation
- implementation plans
- fresh subagents for review
- finishing branch workflow
```

Cohesive-specific differences:

```text
- substrate before implementation
- docs as design surface
- behavior matrices as first-class artifacts
- named invariants
- semantic linters for institutional knowledge
- gotchas/scars as durable substrate
- locality over premature centralization
- fresh-eyes spec cohesion review
- architecture review that stops on broken specs
```

Suggested README phrasing:

```md
Superpowers helps Claude execute disciplined software development workflows.
Cohesive helps Claude make sure the target of that execution is coherent, durable, and remembered by the codebase.

Use Superpowers when you need disciplined implementation.
Use Cohesive when the change touches behavior, architecture, invariants, tests, docs, or future product direction.
Use both when you want substrate-first design followed by disciplined execution.
```

---

## 28. Example README outline

```md
# Cohesive

Cohesive is a Claude Code plugin for substrate-first agentic software engineering.

It helps your codebase remember.

## When to use

Use Cohesive when:
- brainstorming a feature or refactor
- rewriting design docs/specs
- reviewing architecture
- reviewing a PR for behavior/spec/test risks
- naming invariants
- creating behavior matrices
- turning institutional knowledge into semantic linters
- documenting gotchas
- deciding whether to centralize or keep logic local

## Main commands

/cohesive:cohesively
/cohesive:architecture-review
/cohesive:review-change-cohesion
/cohesive:review-spec-cohesion
/cohesive:substrate-audit

## Core idea

Code is cheap. Confidence is scarce. Substrate is how the codebase remembers.

## Installation
...

## Workflows
...
```

---

## 29. Open decisions

1. Should the MVP include direct artifact skills (`invariant`, `matrix`, etc.) or only templates used by router workflows?
2. Should `architecture-review` use custom agents in `agents/` or forked skills with `context: fork`?
3. Should the optional bare `/cohesive` alias be shipped in the plugin repo as an installable convenience directory?
4. Should Cohesive include hooks, or stay purely skill-based for v0?
5. Should `using-worktrees` depend on Superpowers if installed, or always use Cohesive's own worktree logic?
6. What default directory should design/spec outputs use?
   - `docs/cohesive/`
   - `docs/design/`
   - existing repo convention
7. Should architecture reviews write reports to disk by default, or only when explicitly requested?
8. Should semantic-linter specs be implemented as code in v1, or only specified for human review?

---

## 30. Recommended implementation sequence

### Milestone 1: Skeleton

- Create plugin structure.
- Add `plugin.json`.
- Add router skill.
- Add README.
- Add references and templates.
- Add validation script.

### Milestone 2: Design workflow MVP

- Implement `discover-substrate`.
- Implement `brainstorm-design`.
- Implement `pressure-test-design`.
- Implement `using-worktrees`.
- Implement `rewrite-specs`.
- Implement `review-spec-cohesion`.
- Test design rewrite workflow in a real repo.

### Milestone 3: Review workflow MVP

- Implement `architecture-review`.
- Implement `review-change-cohesion`.
- Implement `substrate-audit`.
- Add reviewer agents.
- Test on Cornbot or another substantial repo.

### Milestone 4: Artifact skills

- Implement `invariant`.
- Implement `matrix`.
- Implement `semantic-linter`.
- Implement `gotcha`.
- Implement `locality`.
- Implement `substrate-map`.

### Milestone 5: Implementation handoff

- Implement `plan-implementation`.
- Implement `implement-cohesively`.
- Add compatibility notes for Superpowers.
- Add finishing branch guidance.

---

## 31. Engineer handoff checklist

Before considering the first version complete, the engineer should deliver:

- [ ] Plugin repo with `cohesive` namespace.
- [ ] `README.md` with installation, commands, and workflows.
- [ ] MVP skills implemented.
- [ ] Architecture review skill based on the refined prompt.
- [ ] Fresh-eyes spec cohesion reviewer.
- [ ] Templates for substrate artifacts.
- [ ] At least one validation script.
- [ ] Manual test transcript for design rewrite workflow.
- [ ] Manual test transcript for architecture review workflow.
- [ ] Example output reports.
- [ ] Optional standalone `/cohesive` alias.

---

## 32. Final product positioning

Cohesive is not a general-purpose AI coding plugin.

It is a methodology for making agentic coding safer by moving senior engineering judgment upstream and encoding it into the codebase.

The short positioning line:

> Cohesive helps your codebase remember.

The long positioning line:

> Cohesive is a Claude Code skill pack for substrate-first engineering. It helps agents discover specs, tests, invariants, matrices, semantic linters, gotchas, and locality boundaries before they plan, implement, or review changes, so correct code becomes the path of least resistance.

