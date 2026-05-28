# Cohesive Architecture Review — [repo or subsystem]

**Date:** YYYY-MM-DD
**Scope:** <whole repo / subsystem name>
**Reviewer:** `cohesive:review-codebase`

> The persisted body opens with the TL;DR section — verdict + 2-3 sentence thesis + top 3 findings (each in show-shape: title + Evidence + Change) + recommended next skill (with payload). The TL;DR is what `cohesive:review-codebase` quotes verbatim into chat as the substantive trailer; the rest of the persisted body carries the full audit content including the cohesion scorecard, the per-reviewer raw findings, and the cross-iteration `## History` section. Bookkeeping content (finding-ID continuity across passes, disposition matrices, verdict trajectory) lives in §"History" of this persisted file, not in the chat TL;DR — see `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2c.

## TL;DR

**Verdict:** Healthy / Mostly healthy / Cohesive but under-enforced / Spec drift risk / Architecture risk

**Thesis:** <one or two sentences — the codebase's overall shape, the highest-leverage risk, whether the system can scale development without founder memory>

**Top findings**

### 1. <Finding title>

**Evidence:** `<path>:<line>` — <quoted excerpt or named artifact>

**Change:** <the specific edit that closes this finding>

### 2. <Finding title>

**Evidence:** `<path>:<line>` — <quoted excerpt or named artifact>

**Change:** <the specific edit>

### 3. <Finding title>

**Evidence:** `<path>:<line>` — <quoted excerpt or named artifact>

**Change:** <the specific edit>

### Recommended next Cohesive skill

`cohesive:<skill-name>` — <one-clause reason>. **<Payload-kind>:** <files / scope / design question>.

## Executive thesis

One paragraph (longer form than the TL;DR `**Thesis:**` line). The codebase's overall shape, the highest-leverage risk, and whether the system can scale development without founder memory. Concrete and specific to this codebase — not generic.

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

## Phased roadmap

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

## History

> Iterative-review bookkeeping. This section is the canonical home for cross-pass audit content (per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2c — bookkeeping displaces from chat to persisted file). Omit the section entirely on the first review of a scope; populate it on the second and subsequent reviews.

### Predecessors

One bullet per prior review of this scope, oldest first. The current review references the entire chain, not just the immediate predecessor — a reader of pass-4 needs to see how findings closed across passes 1→2→3 without leaving this section.

- Pass 1 review: `docs/cohesive/reviews/<earlier-date>-<slug>-architecture-review.md` — verdict: <value>; finding count: <N total; B blockers / H highs / M mediums / L lows>
- Pass 2 review: `docs/cohesive/reviews/<later-date>-<slug>-architecture-review.md` — verdict: <value>; finding count: <breakdown>
- ...

### Disposition of prior findings

One row per finding from any prior pass that has not been closed by an even-earlier pass's disposition row. The Origin column anchors the finding to its source pass; the Disposition column records this pass's action.

The vocabulary in this Disposition column is the **review-pass vocabulary** {`Closed`, `Promoted`, `Deferred`, `Superseded`} — about whether a prior review's finding remains open across iterative architecture reviews of the same scope. It is distinct from the **validation-review disposition phrase** vocabulary in `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Disposition rule for validation-review findings" ({`Merge as-is — no findings`, `Close inline → merge`, `Close in same worktree → merge`, `Repair → re-validate`, `Return to brainstorm-design`}), which lives in `validate-rewrite` review trailers and answers a different question (per-review next-step). The two vocabularies operate on different artifacts and never appear in the same column.

| Origin | Finding | Severity | Disposition this pass | Closing artifact / rationale |
|---|---|---|---|---|
| Pass 1 | <ID. Title> | Blocker / High / Medium / Low | Closed / Promoted / Deferred (criterion: <name>) / Superseded | <commit, doc edit, or new finding ID that closes or replaces it> |
| Pass 2 | <ID. Title> | <severity> | <disposition> | <closing artifact> |

### Verdict trajectory

| Pass | Date | Verdict | Highest-leverage observation |
|---|---|---|---|
| 1 | <YYYY-MM-DD> | <verdict> | <one-clause> |
| 2 | <YYYY-MM-DD> | <verdict> | <one-clause> |

### New findings introduced this pass

A short list of finding IDs added this pass (not present in the predecessor) with their severity. The full finding bodies live in §"Highest-leverage findings" above; this list is the audit-trail anchor pointing to them.

- Finding <ID> (<Severity>) — <title>
- ...

### Notes for the next iteration

Anything the next reviewer needs to know that doesn't fit elsewhere — e.g., a deferral whose criterion is close to satisfied, an external dependency the next pass should re-check, a planned rewrite that should land before the next review.
