---
name: review-codebase
description: Use when reviewing a whole codebase or named subsystem for cohesion — does the implementation agree with the docs, are invariants enforced, are seams in the right places, can a future agent change this safely. Reads normative docs first; stops if specs are seriously inconsistent; otherwise dispatches four reviewer agents in parallel and synthesizes a thesis-led report. Triggers on "review the architecture for cohesion", "review the codebase for cohesion", "cohesion review of X", "is this codebase cohesion-healthy". For PR/diff reviews use `cohesive:review-diff`. For substrate audits use `cohesive:audit-substrate`.
---

# Review codebase

## What this skill produces

A full architecture review per `${CLAUDE_PLUGIN_ROOT}/references/architecture-review-rubric.md`. Output written to `docs/history/reviews/YYYY-MM-DD-<slug>-architecture-review.md` and rendered in chat.

For PR/branch/working-changes reviews, use [`cohesive:review-diff`](${CLAUDE_PLUGIN_ROOT}/skills/review-diff/SKILL.md). For "what memory is missing" inventories, use [`cohesive:audit-substrate`](${CLAUDE_PLUGIN_ROOT}/skills/audit-substrate/SKILL.md). Each of those skills produces a different output shape and uses different machinery.

## Voice

Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output. The voice guide is the load-bearing source for verdict-leads, header-depth cap, density budgets, and forbidden phrasings; the imperative above is what triggers the model to load it via a Read tool call. Do not reproduce the imperative or any citation to the voice guide inside the Output format render template — instructions placed inside render templates leak verbatim into user-facing output (the failure mode `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` documents).

## Hard constraints

1. **Substrate discovery is internal to this skill.** Phase 1's first sub-step dispatches `cohesive:discover-substrate` via the Skill tool with the review scope. discover-substrate runs as a sub-step, persists its report, and returns a path this skill consumes as the substrate inventory before reading normative docs. The user does not see discovery output as a separate render. **Optional override:** if the dispatch prompt names a discovery report path that's already been produced, this skill reuses that path instead of re-running discovery.

2. **Reviewers receive paths, not summaries.** Pass the agents file paths; let them read. Pre-summarizing biases the review.
3. **Reviewers run in parallel.** Use a single message with multiple Task tool calls. Sequential is wasted wall-clock time and burns more tokens because each agent re-loads context.
4. **Synthesize, don't concatenate.** The final report is a thesis-led synthesis. Stitching together four agent outputs is the failure mode — not the goal.

## Process

Implements the four-phase architecture review from `${CLAUDE_PLUGIN_ROOT}/references/architecture-review-rubric.md`. Phase 0 below resolves where the output is written before any reading begins; Phases 1-5 are the rubric.

### Phase 0: Resolve the artifact directory

Before any reading or dispatch, resolve where the output review will be written. Apply the four-rule resolution from `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md` §"Artifact directory resolution" with artifact category `reviews/`:

1. If `docs/history/reviews/` exists, write there.
2. Else if the repo carries `docs/adr/`, `docs/specs/`, `docs/design/`, `docs/decisions/`, or `docs/architecture/`, write to a `reviews/` subdir alongside it (e.g., `docs/adr/reviews/`).
3. Else default to `docs/cohesive/reviews/`.
4. If `docs/` does not exist, still default to `docs/cohesive/reviews/`.

Announce the resolved path in chat before reading begins. Don't hardcode `docs/history/reviews/` — that is only correct for repos that already use the Cohesive layout.

### Phase 1: Read normative substrate

**Phase 1.0: Dispatch substrate discovery internally.** Per Hard constraint #1, dispatch `cohesive:discover-substrate` via the Skill tool with the review scope (whole repo or named subsystem). Consume the persisted report. Skip if the dispatch prompt names an existing report path.

**Phase 1.1: Read in priority order.** Use the discovery report's listing. Read:
1. `CLAUDE.md`, `AGENTS.md`
2. `ARCHITECTURE.md`, `architecture.md`
3. `README.md`
4. `docs/design/**`, `docs/specs/**`, `docs/adr/**`, `docs/substrate/**`
5. `docs/substrate/invariants/**`, `docs/substrate/gotchas/**`, `docs/substrate/matrices/**`, `docs/testing/**` (or repo-native equivalents — see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md`)

Produce the **claimed system shape** summary (sections from the rubric: Product goal / Architectural priors / Intended seams / Named invariants / Testing philosophy / Future direction implied by docs).

### Phase 1.5: Sparse-substrate gate

Before judging coherence, check whether there is enough substrate to review at all. If the discovery report carries `**Empty-substrate verdict: yes**` (per `${CLAUDE_PLUGIN_ROOT}/skills/discover-substrate/SKILL.md` step 7, which is the single canonical source for this signal), **stop** and return:

```md
## Substrate too sparse for architecture review

This codebase fell below the empty-substrate threshold in `discover-substrate` step 7 (fewer than 5 normative documents in total, or no `CLAUDE.md`/`AGENTS.md`/`ARCHITECTURE.md`/`docs/` at all). An architecture review against near-empty substrate would hallucinate findings rather than judge alignment.

### Next
Inventory what memory the codebase is missing; the audit is the right tool for "what substrate doesn't yet exist." Once the highest-leverage entries become real artifacts and the doc surface has substantive normative content, re-run `cohesive:review-codebase`. *(`cohesive:audit-substrate`.)* **Scope:** the same scope as this review.
```

If substrate is rich enough to review, proceed to Phase 2.

### Phase 2: Spec-prior gate

Judge whether the substrate itself is coherent. If you find ≥3 blocking spec-level issues (contradictions between docs, foundational docs that are stale, important rules underspecified), **stop**. Return a spec-prior report only:

```md
## Spec-prior issues found

I should not do a full implementation review yet because the substrate itself is inconsistent.

### Blocking spec issues
1. ...

### Recommended substrate repairs
1. ...
```

If the substrate is coherent enough to continue, proceed to Phase 3.

### Phase 3: Dispatch focused reviewers in parallel

Send a single message with **four** Task tool calls, one each for:

- `subagent_type: substrate-alignment-reviewer`
- `subagent_type: structure-reviewer`
- `subagent_type: library-native-reviewer`
- `subagent_type: agent-readiness-reviewer`

Each Task prompt includes:
- The Phase 1 claimed-system-shape summary
- The list of normative doc paths
- The substrate discovery report path
- The scope ("whole repo" or "subsystem X")
- An instruction to read **only paths surfaced by discovery**, not to glob

The dispatch prompt also explicitly states, in prose: "The reviewer reads only paths passed to it, not the conversation." This is convention, not invariant — the structural fence is the harness's Task-subprocess isolation, but the prose preamble reinforces it. See [`reviewer-agent-shape.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md) §"The fresh-eyes preamble" for the canonical form.

Token discipline: each reviewer agent already declares its own output budget (≤500 words / ≤8 ranked findings per agent file's "Token discipline" section). The dispatching prompt reinforces by passing the scope and reminding the agent that pre-finding observation sections are optional. Long discussion goes in linked appendix files if explicitly requested.

### Phase 4: Synthesize

Don't concatenate. Synthesize:

1. **TL;DR** — verdict + 3-line thesis + top 3 findings (each in show-shape per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2b: title + Evidence + Change) + recommended next skill (with payload per rule 5a), in this order, as the very first content in chat. The TL;DR convention is in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"TL;DR convention" and applies to every persisted skill output.
2. **Thesis** — one paragraph naming the codebase's overall shape, the highest-leverage risk, and whether the system can scale development without founder memory. Concrete; specific to this codebase.
3. **Verdict** — one of: Healthy / Mostly healthy / Cohesive but under-enforced / Spec drift risk / Architecture risk
4. **Cohesion scorecard** — 9-axis ratings from `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` (persisted-file only)
5. **Highest-leverage findings** — ranked by leverage × severity, format from rubric (canonical six-field shape per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` §"Per-agent finding shape"). Persisted-file uses six-field full shape; chat trailer renders the top-3 in title + Evidence + Change (the show-shape compression of the six fields).
6. **Substrate improvements** — specs to rewrite, matrices to add, semantic linters to add, gotchas to document (persisted-file only)
7. **Phased roadmap** — first repair substrate, then simplify architecture, then strengthen enforcement (persisted-file only)
8. **History** — when this is an iterative review (a prior architecture review of the same scope exists), the persisted file carries a `## History` section recording: which prior findings closed in the interval, which deferrals still hold and on which criterion, verdict trajectory across passes, and disposition tables. Chat trailer does not render this section per rule 2c — it is bookkeeping content, important to preserve in the audit trail but absent from the per-invocation substance render.

Use the template at `${CLAUDE_PLUGIN_ROOT}/references/templates/architecture-review-report.md`.

### Phase 5: Persist

Write the report to `docs/history/reviews/YYYY-MM-DD-<slug>-architecture-review.md` (where `<slug>` is derived from the scope). Render the same content in chat.

If `docs/history/reviews/` doesn't exist, create it. Reviews are append-only history (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md`) — commit them. User can suppress persistence with `--no-write` if they want it transient.

## Output format

The skill renders the centralized chat trailer per `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` and persists the full report to `docs/history/reviews/YYYY-MM-DD-<slug>-architecture-review.md` using the template at `${CLAUDE_PLUGIN_ROOT}/references/templates/architecture-review-report.md`. The chat render is the decision-rendering of the persisted body per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2a (with its sub-rules 2b / 2c) and the audience seam in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`. The persisted file is canonical and carries the full body, the cross-iteration audit trail (disposition history, finding-ID continuity across review passes, verdict trajectory), the cohesion scorecard, the substrate-shape vocabulary (specs, named invariants, behavior matrices, gotchas, semantic linters flagged for promotion), the appendices, and the per-reviewer raw findings. The chat trailer carries this iteration's findings in user-facing decision-shape, plus a payload-bearing `### Next` handoff.

**Body block specification.** Per `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` §"Variants" `review-codebase` row: a `## Top findings` section with three show-shape findings, each: `### N. <title>` + `**Evidence:**` `<path>:<line>` + excerpt + `**Change:**` <specific edit>.

**Sample chat-trailer render** (canonical shape; the centralized template is the single source of truth):

```md
# Architecture Review — <scope>

**Verdict:** <user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"review-codebase">

**Thesis:** <one or two sentences — the codebase's overall shape, the highest-leverage risk, whether the system can scale development without founder memory>

## Top findings

### 1. <Finding title>

**Evidence:** `<path>:<line>` — <quoted excerpt or named artifact>

**Change:** <the specific edit, file rename, invariant promotion, matrix cell, or test that closes this finding>

### 2. <Finding title>
...

### 3. <Finding title>
...

### Persisted record
`docs/history/reviews/YYYY-MM-DD-<slug>-architecture-review.md`

### Next

<decision-shaped sentence per the verdict>. *(`cohesive:<skill>` or `superpowers:<skill>`.)* **<Payload-kind>:** <concrete payload>.
```

**Verdict translation.** The internal verdict (`Healthy` / `Mostly healthy` / `Cohesive but under-enforced` / `Spec drift risk` / `Architecture risk`) renders in the chat trailer as the user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"review-codebase". The internal label stays in the persisted file's body (the cohesion scorecard and the verdict gate are agent-facing).

**`### Next` per verdict.** The chat-trailer `### Next` block renders one entry for the verdict the review returned, with payload per rule 5a. The decision-shaped sentence leads each entry; the skill citation appears parenthetically in inline code; the payload follows:

- **Internal `Healthy` or `Mostly healthy`:** Substrate is sound; implementation can proceed. *(`superpowers:writing-plans`.)* **Scope:** the change surface in §"Target change surface" of the substrate discovery report.
- **Internal `Cohesive but under-enforced`:** Promote a few rules from convention to structural enforcement. *(`cohesive:rewrite-specs`.)* **Files to edit:** <enumerate the specific docs/matrices/invariants the review flagged for promotion, with the specific change in each>. Slug: `<derived-from-scope>`.
- **Internal `Spec drift risk`:** Repair the docs to match what the code actually does. *(`cohesive:rewrite-specs`.)* **Files to edit:** <enumerate the specs flagged as drifting, with the specific repair in each>. Slug: `<derived-from-scope>`.
- **Internal `Architecture risk`:** The structural shape itself needs revisiting. *(`cohesive:brainstorm-design`.)* **Design question:** <name the specific architectural question the review surfaced as load-bearing, e.g. "should X be one concept or two?">.

Three rules apply at render time:

1. **Top findings render show-shape** (rule 2b). Each finding carries a title, Evidence (file:line + quoted excerpt or named artifact), and Change (the specific edit, not "promote convention to enforcement"). Bare title with one-clause "why" is a render failure tracked in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` §"Synthesizing-skill chat render shape."
2. **Bookkeeping is displaced to the persisted file** (rule 2c). Cross-iteration finding-ID references ("promote finding 7 from the prior pass"), promote/defer disposition matrices, verdict-ratchet language ("verdict ratchets to ⬆"), and "deferral criterion still holds" annotations belong in the persisted file's `## History` section, not in the chat trailer. The chat trailer renders this iteration's findings only, with no cross-iteration ID continuity.
3. **`### Next` carries payload and leads with the decision** (rule 5a + the audience seam). Each verdict-branch names the architectural action first, then cites the skill in inline code parenthetically, then the payload. Methodology framing ("Recommended next Cohesive skill") does not appear in chat per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.

## Output discipline

- **Verdict first, then evidence.** Don't bury the lede. The verdict line renders the user-facing label (translated from the internal label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md`).
- **Findings ranked by leverage.** Not alphabetical, not by file location.
- **Every finding shows, not names.** Title + Evidence + Change is the minimum chat-render shape per rule 2b. Bare title with a one-clause why is a regression.
- **Bookkeeping persists, doesn't render.** Promote/defer disposition tables, cross-iteration finding-ID references, and verdict-ratchet language live in the persisted file's `## History` section. Chat trailer is per-invocation substance.
- **`### Next` carries payload.** The clause names the files / scope / design question, not just the skill name and a count. The decision-shaped sentence leads; the skill citation is parenthetical.
- **No substrate vocabulary in chat.** "Required substrate before implementation", "Substrate artifact to add or update", "Cohesive workflow", "Recommended next Cohesive skill" are persisted-file vocabulary; the chat trailer renders decision-shape per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.
- **Every finding maps to a substrate artifact in the persisted file.** If a finding has no substrate target, ask whether it's preference rather than a real cohesion issue.
- **Concrete file:line references.** Vague findings ("the architecture is unclear") get rejected.

## Token discipline

Architecture reviews can burn a lot of tokens. Constraints:

- Reviewers read paths surfaced by `discover-substrate` only
- Each reviewer's output is bounded; long discussion goes in linked appendix files
- Implementation files are read selectively, anchored to the substrate
- The synthesis step merges; it does not re-read

## Acceptance criteria

- `discover-substrate` ran (or its output was reused) before reviewers were dispatched.
- Phase 2 spec-prior gate is honored — if substrate is broken, the review stops early.
- Reviewers run in parallel via a single message with multiple Task tool calls.
- Synthesis produces a thesis, not a stitched concatenation.
- The review persists to `docs/history/reviews/`.
- Every finding names the substrate artifact to add or update.
- Output ends with a per-verdict `### Next` footer rendered per the centralized chat-trailer template.

## Red flags

- Skipping `discover-substrate` because "I can just read the docs myself."
- Dispatching reviewers sequentially instead of in parallel.
- Producing a finding list with no thesis.
- Skipping the spec-prior gate (Phase 2 must run before Phase 3).
- More than 100 findings. If you have that many, ranking is failing.
- Findings without substrate artifacts. Either add the artifact or drop the finding.
- Chat trailer renders Top findings as title + one-clause why (no Evidence, no Change). Violates rule 2b — see [`docs/substrate/gotchas/naming-instead-of-showing.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/naming-instead-of-showing.md).
- Chat trailer carries a promote/defer disposition matrix or cross-iteration finding-ID continuity ("finding 7 from the prior pass"). Violates rule 2c — disposition history belongs in the persisted file's `## History` section.
- Chat trailer's `### Next` names a skill plus a count ("rewrite-specs to close 5 findings") without enumerating the files or design question. Violates rule 5a.
- Chat trailer renders substrate-vocabulary tokens ("Required substrate", "Substrate artifact to add or update", "Cohesive workflow") instead of decision-shape. Violates the audience seam — see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.
- Chat trailer renders verdict-ratchet language ("Mostly healthy ⬆ from Cohesive but under-enforced"). The trajectory is bookkeeping; the persisted file's `## History` carries it.

## Composition

- **Always preceded by:** `discover-substrate` (or reuse of its output)
- **Often followed by:** `rewrite-specs` (if the review found spec drift requiring repair) or `superpowers:writing-plans` (if the review approved the change)
- **Compatible with:** Superpowers' `code-reviewer` for the implementation-quality lens, after Cohesive's substrate lens. Run both for a high-stakes review.
- **Adjacent skills:** `cohesive:review-diff` (PR/diff review) and `cohesive:audit-substrate` ("what's missing" rather than "what's wrong").

## What this skill is *not*

- Not a substrate audit. That's `cohesive:audit-substrate`.
- Not a PR/diff review. That's `cohesive:review-diff`.
- Not a code-style review. Naming, formatting, and micro-naming preferences are out of scope.
- Not a defect hunt. Implementation bugs that aren't substrate gaps belong in normal code review.
- Not a refactor proposal. Findings recommend substrate changes, not large code rewrites.
