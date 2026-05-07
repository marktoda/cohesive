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

1. **Substrate discovery is internal to this skill.** Step 0 of the Process dispatches `cohesive:discover-substrate` via the Skill tool with the audit scope (whole repo, or a named subsystem). discover-substrate runs as a sub-step, persists its report, and returns a path this skill consumes. The user does not see discovery output as a separate render. **Optional override:** if the dispatch prompt names a discovery report path that's already been produced, this skill reuses that path instead of re-running discovery.

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

### 1. Dispatch substrate discovery internally and consume the report

Per Hard constraint #1, dispatch `cohesive:discover-substrate` via the Skill tool with the audit scope (whole repo or a named subsystem extracted from the user's request). discover-substrate runs as a sub-step, persists its full report to disk, and returns the path. Read the path; consume the report as input to Step 2.

**Skip condition:** if the dispatch prompt to this skill includes "Discovery already complete; report at <path>", do not re-dispatch — read the named report directly. This handles three cases: (a) the user explicitly invoked `cohesive:discover-substrate` before audit-substrate; (b) another consumer skill ran discovery earlier in the same session; (c) the router (in legacy invocation patterns) passed the prereq state explicitly.

**Scope clarification:** if the audit scope is unclear (e.g., "audit substrate" without naming whole-repo vs subsystem), ask one precise clarifying question naming the candidate scopes from the repo's directory structure: "Which scope should I audit: the whole repo, or a specific subsystem (<option A>, <option B>, ...)?"

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

Render each fix in show-shape per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2b — the persisted body uses the same shape as the chat trailer rendered by §"Output format" below (title + Evidence the gap exists + What the artifact would say + Where it lives). The render template lives once in §"Output format"; this section of the audit body reproduces that render verbatim, not a different shape.

### 1. <Artifact name to add>

**Evidence the gap exists:** <path>:<line> — <quoted excerpt or named pattern>

**What the artifact would say:** <2-3 sentence sketch>

**Where it lives:** <path>

### 2. <Artifact name to add>

(same fields)

### 3. <Artifact name to add>

(same fields)

### Next
Turn the highest-leverage missing-memory entries into actual artifacts. *(`cohesive:rewrite-specs`.)* **Files to add:** <enumerate the artifact paths from the Highest-leverage fixes above>. Slug: `<derived-from-audit-scope>`.
```

### 4. Persist

Write the report to `docs/history/reviews/YYYY-MM-DD-<slug>-audit-substrate.md`. Reviews and audits are append-only history per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md` — commit them.

If the user passes `--no-write`, render in chat only.

## Output format

The skill renders the centralized chat trailer per `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` and persists the full audit report to `docs/history/reviews/YYYY-MM-DD-<slug>-audit-substrate.md` per step 3. The chat render is the decision-rendering of the persisted body per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2a (with sub-rules 2b / 2c) and the audience seam in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`. The persisted file is canonical and carries the full audit body, the substrate-shape vocabulary (specs, named invariants, behavior matrices, gotchas, semantic linters proposed for addition), and the cross-iteration history if this is a re-audit; the chat trailer renders this iteration's top fixes in user-facing decision-shape.

**Verdict translation.** The internal verdict (`Substrate sound` / `Substrate gaps` / `Substrate sparse`) renders in the chat trailer as the user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"audit-substrate".

**Body block specification.** Per the §"Variants" `audit-substrate` row of the centralized template: a `## Top fixes` section with three show-shape fixes, each: `### N. <artifact-to-add title>` + `**Evidence the gap exists:**` `<path>:<line>` + excerpt + `**What the artifact would say:**` <2-3 sentence sketch> + `**Where it lives:**` `<path>`. The "Headline" slot in the chat-trailer shell is filled with one or two sentences naming the highest-leverage missing memory and why the codebase is at risk because of it.

**Sample chat-trailer render** (canonical shape; the centralized template is the single source of truth):

```md
# Substrate Audit — <scope>

**Verdict:** <user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"audit-substrate">

**Headline:** <one or two sentences — highest-leverage missing memory and why the codebase is at risk because of it>

## Top fixes

### 1. <Artifact name to add — e.g., "Named invariant: USER_AUTH_SESSION_TOKEN_TTL">

**Evidence the gap exists:** `<path>:<line>` — <quoted excerpt or named pattern>

**What the artifact would say:** <2-3 sentences sketching the artifact's core claim>

**Where it lives:** `<path>`

### 2. <Artifact name to add>
...

### 3. <Artifact name to add>
...

### Persisted record
`docs/history/reviews/YYYY-MM-DD-<slug>-audit-substrate.md`

### Next

<decision-shaped sentence per the verdict>. *(`cohesive:rewrite-specs`.)* **Files to add:** <enumerate the artifact paths>. Slug: `<derived-from-audit-scope>`.
```

**`### Next` block.** Audit-substrate has a single primary recommendation regardless of verdict (the audit identifies missing memory; turning the entries into artifacts is what closes them):

- **Internal `Substrate sound`:** No artifacts needed; substrate is well-shaped. *(No follow-up skill required.)*
- **Internal `Substrate gaps`:** Turn the highest-leverage missing-memory entries into actual artifacts. *(`cohesive:rewrite-specs`.)* **Files to add:** <enumerate the artifact paths from the Top fixes above; rewrite-specs creates them as new artifacts under `docs/substrate/<category>/` or the repo's native equivalent>. Slug: `<derived-from-audit-scope>`.
- **Internal `Substrate sparse`:** Author the foundational docs the audit named as missing. *(`cohesive:rewrite-specs`.)* **Files to add:** <foundational doc paths — usually CLAUDE.md, ARCHITECTURE.md, or the substrate skeleton>. Slug: `<derived-from-audit-scope>`.

The decision-shaped sentence leads each entry; the skill citation appears parenthetically in inline code; the payload follows.

Three rules apply:

1. **Top fixes render show-shape** (rule 2b). Each fix carries a title (the artifact to add), Evidence the gap exists (file:line + excerpt or named pattern), What the artifact would say (a 2-3 sentence sketch concrete enough to seed drafting), and Where it lives (the path the rewrite would create). Bare "artifact to add; one-clause justification" is a render failure tracked in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` §"Synthesizing-skill chat render shape."
2. **Bookkeeping is displaced to the persisted file** (rule 2c). If this is a re-audit, the persisted file carries a `## History` section with the prior audit's recommendations, which are now real artifacts vs. still-missing, and any deferral criteria. Chat trailer is per-invocation.
3. **`### Next` carries payload** (rule 5a + the audience seam). The clause names the artifact paths to create with the decision-shaped sentence leading; methodology framing ("Recommended next Cohesive skill") does not appear in chat per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.

The "Top fixes" body block uses substrate-shape vocabulary in the *content* of each fix (artifact name, what-it-would-say sketch, where-it-lives path). This is the audience seam's recognized exception: artifact-addition skills name the artifacts they want added, and the artifacts themselves are substrate-shape — that's what an audit produces. The methodology framing around them stays decision-shape (the user-facing verdict, the headline, the `### Next`).

## Acceptance criteria

- `discover-substrate` ran (or its output was reused) before the audit.
- Findings are inventories of *missing* substrate, not code defects.
- Every finding maps to a substrate artifact to add or update.
- Findings are ranked by leverage (what would prevent the most predictable future bug), not alphabetical.
- Output is persisted to `docs/history/reviews/` unless `--no-write` is passed.
- Output ends with a `### Next` footer rendered per the centralized chat-trailer template.

## Red flags

- Findings about defective code rather than missing memory. Wrong skill — that's `cohesive:review-diff`.
- Inventorying *every* missing substrate without prioritizing. The point of an audit is to surface the few highest-leverage gaps, not to enumerate the long tail.
- Recommending more substrate where the codebase clearly has not earned the rules yet. Premature substrate is its own form of debt.
- Skipping `discover-substrate` because "I can read the directory listing myself." The script's bucketing is the audit's baseline.
- Dispatching reviewer agents. This skill does not dispatch.
- Top fixes render as `<artifact to add; one-clause justification>` with no Evidence, no artifact-content sketch, no path. Violates rule 2b — see [`docs/substrate/gotchas/naming-instead-of-showing.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/naming-instead-of-showing.md).
- Chat trailer's `### Next` names `rewrite-specs` without enumerating the artifact paths. Violates rule 5a.
- Chat trailer renders methodology framing ("Recommended next Cohesive skill") instead of `### Next` with the skill citation parenthetical. Violates the audience seam — see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.

## Composition

- **Most often invoked by:** `cohesive:cohesively` route `audit (substrate)` (cell R007 in [`docs/substrate/matrices/router.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md)). The router passes "discovery already complete; report at <path>" so this skill skips its own discovery prompt.
- **Always preceded by:** `cohesive:discover-substrate`
- **Often followed by:** `cohesive:rewrite-specs` (the highest-leverage entries become real artifacts) or no Cohesive follow-up (the audit is the deliverable).
- **Adjacent skill:** `cohesive:review-codebase` — for "what's wrong with the architecture given the substrate that exists"; this skill is for "what substrate doesn't yet exist."

## What this skill is *not*

- Not a code review. No defect hunt. No style enforcement.
- Not an architecture review. The judgment about whether the substrate is *good* belongs in `cohesive:review-codebase`.
- Not a planning skill. Findings recommend artifacts; turning them into a sequenced plan is `superpowers:writing-plans` or `cohesive:rewrite-specs`.
