---
name: substrate-audit
description: Use when auditing a repo for missing memory — implicit rules, branchy behavior without matrices, invariants without enforcement, scars trapped in comments, stale docs. Single-pass scan, no reviewer-agent dispatch. Triggers on "what memory is missing", "audit substrate", "what specs/invariants/gotchas should we have but don't", "what's not yet substrate". For "what's wrong with the architecture" use `cohesive:cohesive-review --scope codebase`; for "review my PR" use `--scope diff`.
---

# Substrate audit

## What this skill produces

A **substrate audit report** at `docs/history/reviews/YYYY-MM-DD-<slug>-substrate-audit.md`, also rendered in chat. The report inventories what *isn't* yet substrate: implicit rules the codebase depends on, branchy behavior with no matrix, invariants without enforcement, scars trapped in comments or PR descriptions, stale docs that no longer describe reality, premature centralizations that haven't earned their abstraction, missing local commands.

This skill is intentionally separate from `cohesive-review`. The codebase and diff reviews of `cohesive-review` dispatch four reviewer agents and synthesize a thesis-led report; substrate audit is a single-pass scan that produces a missing-memory inventory. They share neither machinery nor output shape.

## Hard constraints

1. **Always run `discover-substrate` first.** Or re-use its output from earlier in this session. The audit's job is to compare what exists to what *should* exist; without discovery, you don't know what exists.
2. **No reviewer-agent dispatch.** A substrate audit is a single-pass scan. Don't burn 4× tokens for a missing-memory inventory.
3. **Score "does the substrate exist," not "is the code good."** A missing-memory finding is about an absent artifact, not a code defect. Code defects belong in `cohesive-review --scope diff` or in normal review.
4. **Every finding names the artifact to add.** If a finding has no clear substrate target (named invariant / behavior matrix / gotcha / semantic linter / spec / test), it's preference, not a substrate gap. Drop it or restate.

## Process

### 1. Re-use or run substrate discovery

If `discover-substrate` has already run for the repo (or named subsystem) in this session, reuse its report. Otherwise run it.

When invoked from the `cohesively` router with the substrate-audit route, the router passes "discovery already complete; report at <path>" explicitly.

### 2. Apply the cohesion rubric to the substrate, not the code

Walk each axis from `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md`. For each axis, ask: *does the substrate that should exist for this axis actually exist?* — not *is the code well-shaped on this axis*.

- **Spec coherence:** are there docs at all? Are they internally consistent?
- **Code/spec alignment:** the question here is whether the docs have something to *be aligned with*, not whether they currently are.
- **Domain model clarity:** are concepts named anywhere?
- **Invariant enforcement:** named invariants without enforcement, or implicit rules that should be named.
- **Test guarantees:** behavior with no test pinning, regressions with no test.
- **Locality and seams:** premature centralizations; absent abstractions where duplication is signaling a missing concept.
- **Library-native alignment:** mostly out of scope for substrate audit unless an idiom mismatch is *itself* hiding a missing rule.
- **Agent-readiness:** undocumented conventions that future contributors would predictably violate.
- **Future extensibility:** likely future changes that have no shaped change surface.

### 3. Render the audit report

```md
# Substrate Audit

**Date:** YYYY-MM-DD
**Scope:** <repo-wide or subsystem name>
**Substrate discovery:** <path or "inline below">

## Headline

<One paragraph naming the highest-leverage missing memory and why this codebase is at risk because of it.>

## High-risk implicit rules

- <rule the codebase depends on but hasn't named>

## Branchy behavior without matrix

- <subsystem and the cases that aren't enumerated>

## Invariants without enforcement

- <rule in docs but not structurally enforced>

## Gotchas trapped in comments / issues / PRs

- <scar that should be a doc>

## Docs that describe old reality

- <stale normative doc and how it misleads>

## Premature centralization risks

- <abstraction that may not earn its slot>

## Missing local commands

- <task the team does but hasn't scripted>

## Highest-leverage fixes (ranked)

1. <substrate artifact to add; one-clause justification>
2. ...
3. ...

### Recommended next Cohesive skill
`cohesive:rewrite-specs` — most audit findings are substrate-shaped; the rewrite skill is the right vehicle to turn the highest-leverage entries into actual artifacts (named invariants, gotcha docs, behavior matrices).
```

### 4. Persist

Write the report to `docs/history/reviews/YYYY-MM-DD-<slug>-substrate-audit.md`. Reviews and audits are append-only history per `${CLAUDE_PLUGIN_ROOT}/references/substrate-layout.md` — commit them.

If the user passes `--no-write`, render in chat only.

## Output format

The chat output is the audit report shown in step 3, ending with the canonical "Recommended next Cohesive skill" block.

## Acceptance criteria

- `discover-substrate` ran (or its output was reused) before the audit.
- Findings are inventories of *missing* substrate, not code defects.
- Every finding maps to a substrate artifact to add or update.
- Findings are ranked by leverage (what would prevent the most predictable future bug), not alphabetical.
- Output is persisted to `docs/history/reviews/` unless `--no-write` is passed.
- Output ends with a `### Recommended next Cohesive skill` footer.

## Red flags

- Findings about defective code rather than missing memory. Wrong skill — that's `cohesive-review --scope diff`.
- Inventorying *every* missing substrate without prioritizing. The point of an audit is to surface the few highest-leverage gaps, not to enumerate the long tail.
- Recommending more substrate where the codebase clearly has not earned the rules yet. Premature substrate is its own form of debt.
- Skipping `discover-substrate` because "I can read the directory listing myself." The script's bucketing is the audit's baseline.
- Dispatching reviewer agents. This skill does not dispatch.

## Composition

- **Most often invoked by:** `cohesive:cohesively` route `review (substrate audit)` (cell R007 in [`docs/substrate/matrices/router.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md)). The router passes "discovery already complete; report at <path>" so this skill skips its own discovery prompt.
- **Always preceded by:** `cohesive:discover-substrate`
- **Often followed by:** `cohesive:rewrite-specs` (the highest-leverage entries become real artifacts) or no Cohesive follow-up (the audit is the deliverable).
- **Adjacent skill:** `cohesive:cohesive-review --scope codebase` — for "what's wrong with the architecture given the substrate that exists"; this skill is for "what substrate doesn't yet exist."

## What this skill is *not*

- Not a code review. No defect hunt. No style enforcement.
- Not an architecture review. The judgment about whether the substrate is *good* belongs in `cohesive-review --scope codebase`.
- Not a planning skill. Findings recommend artifacts; turning them into a sequenced plan is `superpowers:writing-plans` or `cohesive:rewrite-specs`.
