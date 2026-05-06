---
name: audit-substrate
description: Use when auditing a repo for missing memory — implicit rules, branchy behavior without matrices, invariants without enforcement, scars trapped in comments, stale docs. Single-pass scan, no reviewer-agent dispatch. Triggers on "audit substrate", "what memory is missing", "what specs/invariants/gotchas should we have but don't", "what's not yet substrate". For "what's wrong with the architecture" use `cohesive:review-codebase`; for "review my PR" use `cohesive:review-diff`.
---

# Audit substrate

## What this skill produces

A **substrate audit report** at `docs/history/reviews/YYYY-MM-DD-<slug>-audit-substrate.md`, also rendered in chat. The report inventories what *isn't* yet substrate: implicit rules the codebase depends on, branchy behavior with no matrix, invariants without enforcement, scars trapped in comments or PR descriptions, stale docs that no longer describe reality, premature centralizations that haven't earned their abstraction, missing local commands.

This skill is intentionally separate from `review-codebase` and `review-diff`. Those reviews dispatch reviewer agents and synthesize a thesis-led report; substrate audit is a single-pass scan that produces a missing-memory inventory. They share neither machinery nor output shape.

## Voice

Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output. The voice guide is the load-bearing source for verdict-leads, header-depth cap, density budgets, and forbidden phrasings; the imperative above is what triggers the model to load it via a Read tool call. Do not reproduce the imperative or any citation to the voice guide inside the Output format render template — instructions placed inside render templates leak verbatim into user-facing output (the failure mode `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` documents).

## Hard constraints

1. **Substrate discovery is a prereq; ask the user, don't guess.** Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md`, detecting prior discovery from session memory silently degrades. Open the turn with the canonical forced-choice question:

   > "I see we're about to run audit-substrate. Has substrate discovery already happened for this scope, or should I run `discover-substrate` first?"

   When the `cohesively` router invokes this skill, it passes "discovery already complete; report at <path>" in the dispatch prompt and this skill skips the question.

2. **No reviewer-agent dispatch.** A substrate audit is a single-pass scan. Don't burn 4× tokens for a missing-memory inventory.
3. **Score "does the substrate exist," not "is the code good."** A missing-memory finding is about an absent artifact, not a code defect. Code defects belong in `cohesive:review-diff` or in normal review.
4. **Every finding names the artifact to add.** If a finding has no clear substrate target (named invariant / behavior matrix / gotcha / semantic linter / spec / test), it's preference, not a substrate gap. Drop it or restate.

## Process

### 0. Resolve the artifact directory

Before scanning, resolve where the audit report will be written. Apply the four-rule resolution from `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md` §"Artifact directory resolution" with artifact category `reviews/`:

1. If `docs/history/reviews/` exists, write there.
2. Else if the repo carries `docs/adr/`, `docs/specs/`, `docs/design/`, `docs/decisions/`, or `docs/architecture/`, write to a `reviews/` subdir alongside it.
3. Else default to `docs/cohesive/reviews/`.
4. If `docs/` does not exist, still default to `docs/cohesive/reviews/`.

Announce the resolved path in chat before the scan begins.

### 1. Re-use the substrate discovery report

The user's answer to the prereq question (or the router's dispatch prompt) names the report path. Use it. If the user said to run `discover-substrate` first, do that and use its output.

When invoked from the `cohesively` router with the `audit (substrate)` route, the router passes "discovery already complete; report at <path>" explicitly per the dispatch prompt contract in `${CLAUDE_PLUGIN_ROOT}/skills/cohesively/SKILL.md`.

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

**Verdict:** Substrate sound / Substrate gaps / Substrate sparse

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

Write the report to `docs/history/reviews/YYYY-MM-DD-<slug>-audit-substrate.md`. Reviews and audits are append-only history per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md` — commit them.

If the user passes `--no-write`, render in chat only.

## Output format

The skill renders a chat trailer (canonical verdict-led shape below) and persists the full audit report to `docs/history/reviews/YYYY-MM-DD-<slug>-audit-substrate.md` per step 3. The chat render is substance, not bookkeeping (per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2 and its sub-rules 2a / 2b / 2c). The persisted file is canonical and carries the full audit body and the cross-iteration history if this is a re-audit; the chat trailer renders this iteration's top fixes shown afresh, plus a payload-bearing handoff.

```md
# Substrate Audit — <scope>

**Verdict:** Substrate sound / Substrate gaps / Substrate sparse

**Headline:** <one or two sentences — highest-leverage missing memory and why the codebase is at risk because of it>

## Top fixes

### 1. <Artifact name to add — e.g., "Named invariant: USER_AUTH_SESSION_TOKEN_TTL">

**Evidence the gap exists:** `<path>:<line>` — <quoted excerpt of the implicit rule, the unmatricized branch, the comment-as-rule, or the stale doc; or a named pattern observation if no single line carries it>

**What the artifact would say:** <2-3 sentences sketching the artifact's core claim — concrete enough that a reader could begin drafting it. For an invariant: the rule and the proxy. For a matrix: the columns and ~3 sample rows. For a gotcha: symptom and correct pattern.>

**Where it lives:** `docs/substrate/<category>/<filename>.md` — <category: invariants / matrices / gotchas / specs / tests / linters>

### 2. <Artifact name to add>

**Evidence the gap exists:** `<path>:<line>` — <excerpt>

**What the artifact would say:** <sketch>

**Where it lives:** `<path>`

### 3. <Artifact name to add>

**Evidence the gap exists:** `<path>:<line>` — <excerpt>

**What the artifact would say:** <sketch>

**Where it lives:** `<path>`

## Persisted report
`docs/history/reviews/YYYY-MM-DD-<slug>-audit-substrate.md`

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — turn the highest-leverage missing-memory entries into actual artifacts. **Files to add:** <enumerate the artifact paths from the Top fixes above; rewrite-specs creates them as new artifacts under `docs/substrate/<category>/`>. Slug: `<scope>-substrate-additions`.
```

The render template above is the canonical chat trailer. Three rules apply:

1. **Top fixes render show-shape** (rule 2b). Each fix carries a title (the artifact to add), Evidence the gap exists (file:line + excerpt or named pattern), What the artifact would say (a 2-3 sentence sketch concrete enough to seed drafting), and Where it lives (the path the rewrite would create). Bare "substrate artifact to add; one-clause justification" is a render failure tracked in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` §"Synthesizing-skill chat render shape."
2. **Bookkeeping is displaced to the persisted file** (rule 2c). If this is a re-audit, the persisted file carries a `## History` section with the prior audit's recommendations, which are now real artifacts vs. still-missing, and any deferral criteria. Chat trailer is per-invocation.
3. **Recommended next Cohesive skill carries payload** (rule 5a). The clause names the artifact paths to create, not just "rewrite-specs to turn audit entries into artifacts."

## Acceptance criteria

- `discover-substrate` ran (or its output was reused) before the audit.
- Findings are inventories of *missing* substrate, not code defects.
- Every finding maps to a substrate artifact to add or update.
- Findings are ranked by leverage (what would prevent the most predictable future bug), not alphabetical.
- Output is persisted to `docs/history/reviews/` unless `--no-write` is passed.
- Output ends with a `### Recommended next Cohesive skill` footer.

## Red flags

- Findings about defective code rather than missing memory. Wrong skill — that's `cohesive:review-diff`.
- Inventorying *every* missing substrate without prioritizing. The point of an audit is to surface the few highest-leverage gaps, not to enumerate the long tail.
- Recommending more substrate where the codebase clearly has not earned the rules yet. Premature substrate is its own form of debt.
- Skipping `discover-substrate` because "I can read the directory listing myself." The script's bucketing is the audit's baseline.
- Dispatching reviewer agents. This skill does not dispatch.
- Top fixes render as `<artifact to add; one-clause justification>` with no Evidence, no artifact-content sketch, no path. Violates rule 2b — see [`docs/substrate/gotchas/naming-instead-of-showing.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/naming-instead-of-showing.md).
- Recommended next Cohesive skill names `rewrite-specs` without enumerating the artifact paths. Violates rule 5a.

## Composition

- **Most often invoked by:** `cohesive:cohesively` route `audit (substrate)` (cell R007 in [`docs/substrate/matrices/router.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md)). The router passes "discovery already complete; report at <path>" so this skill skips its own discovery prompt.
- **Always preceded by:** `cohesive:discover-substrate`
- **Often followed by:** `cohesive:rewrite-specs` (the highest-leverage entries become real artifacts) or no Cohesive follow-up (the audit is the deliverable).
- **Adjacent skill:** `cohesive:review-codebase` — for "what's wrong with the architecture given the substrate that exists"; this skill is for "what substrate doesn't yet exist."

## What this skill is *not*

- Not a code review. No defect hunt. No style enforcement.
- Not an architecture review. The judgment about whether the substrate is *good* belongs in `cohesive:review-codebase`.
- Not a planning skill. Findings recommend artifacts; turning them into a sequenced plan is `superpowers:writing-plans` or `cohesive:rewrite-specs`.
