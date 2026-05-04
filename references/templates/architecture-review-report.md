# Cohesive Architecture Review — [repo or subsystem]

**Date:** YYYY-MM-DD
**Scope:** <whole repo / subsystem name>
**Reviewer:** `cohesive-review --scope codebase`

## Verdict

**Healthy / Mostly healthy / Cohesive but under-enforced / Spec drift risk / Architecture risk**

## Executive thesis

One paragraph. The codebase's overall shape, the highest-leverage risk, and whether the system can scale development without founder memory. Concrete and specific to this codebase — not generic.

## Spec-prior review

### Docs read
- `path/to/CLAUDE.md`
- `path/to/architecture.md`
- ...

### Claimed architectural priors
- <one bullet per prior, in the system's own words>

### Spec inconsistencies
- <inconsistency> — <where>

### Recommended spec changes (independent of code review)
- <change>

## System cohesion scorecard

| Area | Rating | Summary |
|---|---:|---|
| Spec coherence |   |   |
| Code/spec alignment |   |   |
| Domain model clarity |   |   |
| Invariant enforcement |   |   |
| Test guarantees |   |   |
| Locality and seams |   |   |
| Library-native alignment |   |   |
| Agent-readiness |   |   |
| Future extensibility |   |   |

Ratings: **Healthy / Mostly healthy / Under-enforced / Drifting / At risk**

## Highest-leverage findings

### 1. <Finding title>

**Severity:** Blocker / High / Medium / Low
**Category:** Spec drift / Invariant / Locality / Tests / Domain model / Library alignment / Substrate / Agent-readiness
**Why it matters:**
<concrete consequence>

**Evidence:**
- `path/to/file.ts:line` — <one-line excerpt or summary>

**Recommended fix:**
<specific next step>

**Substrate artifact to add or update:**
Spec / behavior matrix / invariant / gotcha / semantic linter / test / type boundary

(repeat — ranked by leverage × severity)

## Confusing or weak concepts

| Concept | Issue | Recommendation |
|---|---|---|
|   |   |   |

## Invariants that should be named

| Invariant | Current enforcement | Recommended enforcement |
|---|---|---|
|   |   |   |

## Test guarantee gaps

| Behavior | Current coverage | Risk | Recommended test |
|---|---|---|---|
|   |   |   |   |

## Locality and abstraction review

- <subsystem> — <observation>
- ...

## Library-native alignment opportunities

- <where the code fights its tools>
- ...

## Agent-readiness

- <subsystem> — what context a future agent would need; whether it's bounded
- ...

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
2. ...

### Then: simplify architecture
1. ...

### Then: strengthen enforcement
1. ...

## Appendices (linked)

- Substrate discovery report: `path/to/discovery.md`
- Per-reviewer raw findings:
  - substrate-alignment: `path/to/...`
  - structure: `path/to/...`
  - library-native: `path/to/...`
  - agent-readiness: `path/to/...`
