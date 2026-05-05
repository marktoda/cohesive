---
name: review-codebase
description: Use when reviewing a whole codebase or named subsystem for cohesion — does the implementation agree with the docs, are invariants enforced, are seams in the right places, can a future agent change this safely. Reads normative docs first; stops if specs are seriously inconsistent; otherwise dispatches four reviewer agents in parallel and synthesizes a thesis-led report. Triggers on "review the architecture for cohesion", "review the codebase for cohesion", "cohesion review of X", "is this codebase cohesion-healthy". For PR/diff reviews use `cohesive:review-diff`. For substrate audits use `cohesive:audit-substrate`.
---

# Review codebase

## What this skill produces

A full architecture review per `${CLAUDE_PLUGIN_ROOT}/references/architecture-review-rubric.md`. Output written to `docs/history/reviews/YYYY-MM-DD-<slug>-architecture-review.md` and rendered in chat.

For PR/branch/working-changes reviews, use [`cohesive:review-diff`](${CLAUDE_PLUGIN_ROOT}/skills/review-diff/SKILL.md). For "what memory is missing" inventories, use [`cohesive:audit-substrate`](${CLAUDE_PLUGIN_ROOT}/skills/audit-substrate/SKILL.md). Each of those skills produces a different output shape and uses different machinery.

## Hard constraints

1. **Substrate discovery is a prereq; ask the user, don't guess.** Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md`, detecting prior discovery from session memory silently degrades. Open the turn with the canonical forced-choice question:

   > "I see we're about to run review-codebase. Has substrate discovery already happened for this scope, or should I run `discover-substrate` first?"

   When the `cohesively` router invokes this skill, it passes "discovery already complete; report at <path>" in the dispatch prompt and this skill skips the question.

2. **Reviewers receive paths, not summaries.** Pass the agents file paths; let them read. Pre-summarizing biases the review.
3. **Reviewers run in parallel.** Use a single message with multiple Task tool calls. Sequential is wasted wall-clock time and burns more tokens because each agent re-loads context.
4. **Synthesize, don't concatenate.** The final report is a thesis-led synthesis. Stitching together four agent outputs is the failure mode — not the goal.

## Process

Implements the four-phase architecture review from `${CLAUDE_PLUGIN_ROOT}/references/architecture-review-rubric.md`. Phase 0 below resolves where the output is written before any reading begins; Phases 1-5 are the rubric.

### Phase 0: Resolve the artifact directory

Before any reading or dispatch, resolve where the output review will be written. Apply the four-rule resolution from `${CLAUDE_PLUGIN_ROOT}/references/substrate-layout.md` §"Artifact directory resolution" with artifact category `reviews/`:

1. If `docs/history/reviews/` exists, write there.
2. Else if the repo carries `docs/adr/`, `docs/specs/`, `docs/design/`, `docs/decisions/`, or `docs/architecture/`, write to a `reviews/` subdir alongside it (e.g., `docs/adr/reviews/`).
3. Else default to `docs/cohesive/reviews/`.
4. If `docs/` does not exist, still default to `docs/cohesive/reviews/`.

Announce the resolved path in chat before reading begins. Don't hardcode `docs/history/reviews/` — that is only correct for repos that already use the Cohesive layout.

### Phase 1: Read normative substrate

Use `discover-substrate` (or its output) to get the list. Read in priority order:
1. `CLAUDE.md`, `AGENTS.md`
2. `ARCHITECTURE.md`, `architecture.md`
3. `README.md`
4. `docs/design/**`, `docs/specs/**`, `docs/adr/**`, `docs/substrate/**`
5. `docs/substrate/invariants/**`, `docs/substrate/gotchas/**`, `docs/substrate/matrices/**`, `docs/testing/**` (or repo-native equivalents — see `${CLAUDE_PLUGIN_ROOT}/references/substrate-layout.md`)

Produce the **claimed system shape** summary (sections from the rubric: Product goal / Architectural priors / Intended seams / Named invariants / Testing philosophy / Future direction implied by docs).

### Phase 1.5: Sparse-substrate gate

Before judging coherence, check whether there is enough substrate to review at all. If the discovery report carries `**Empty-substrate verdict: yes**` (per `${CLAUDE_PLUGIN_ROOT}/skills/discover-substrate/SKILL.md` step 7, which is the single canonical source for this signal), **stop** and return:

```md
## Substrate too sparse for architecture review

This codebase fell below the empty-substrate threshold in `discover-substrate` step 7 (fewer than 5 normative documents in total, or no `CLAUDE.md`/`AGENTS.md`/`ARCHITECTURE.md`/`docs/` at all). An architecture review against near-empty substrate would hallucinate findings rather than judge alignment.

### Recommended next Cohesive skill
`cohesive:audit-substrate` — produce a missing-memory inventory; the audit is the right tool for "what substrate doesn't yet exist." Once the highest-leverage entries become real artifacts (named invariants, gotcha docs, behavior matrices) and the doc surface has substantive normative content, re-run `cohesive:review-codebase`.
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

The dispatch prompt also explicitly states, in prose: "The reviewer reads only paths passed to it, not the conversation." This is convention, not invariant — the structural fence is the harness's Task-subprocess isolation, but the prose preamble reinforces it. See [`reviewer-agent-template.md`](${CLAUDE_PLUGIN_ROOT}/references/reviewer-agent-template.md) §"The fresh-eyes preamble" for the canonical form.

Token discipline: each reviewer agent already declares its own output budget (≤500 words / ≤8 ranked findings per agent file's "Token discipline" section). The dispatching prompt reinforces by passing the scope and reminding the agent that pre-finding observation sections are optional. Long discussion goes in linked appendix files if explicitly requested.

### Phase 4: Synthesize

Don't concatenate. Synthesize:

1. **TL;DR** — verdict + 3-line thesis + top 3 findings + recommended next skill, in this order, as the very first content in chat. The TL;DR convention is in `${CLAUDE_PLUGIN_ROOT}/references/skill-conventions.md` §"TL;DR convention" and applies to every persisted skill output.
2. **Thesis** — one paragraph naming the codebase's overall shape, the highest-leverage risk, and whether the system can scale development without founder memory. Concrete; specific to this codebase.
3. **Verdict** — one of: Healthy / Mostly healthy / Cohesive but under-enforced / Spec drift risk / Architecture risk
4. **Cohesion scorecard** — 9-axis ratings from `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md`
5. **Highest-leverage findings** — ranked by leverage × severity, format from rubric (canonical six-field shape per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md`)
6. **Substrate improvements** — specs to rewrite, matrices to add, semantic linters to add, gotchas to document
7. **Phased roadmap** — first repair substrate, then simplify architecture, then strengthen enforcement

Use the template at `${CLAUDE_PLUGIN_ROOT}/references/templates/architecture-review-report.md`.

### Phase 5: Persist

Write the report to `docs/history/reviews/YYYY-MM-DD-<slug>-architecture-review.md` (where `<slug>` is derived from the scope). Render the same content in chat.

If `docs/history/reviews/` doesn't exist, create it. Reviews are append-only history (per `${CLAUDE_PLUGIN_ROOT}/references/substrate-layout.md`) — commit them. User can suppress persistence with `--no-write` if they want it transient.

## Output format

The skill's chat output matches the template at `${CLAUDE_PLUGIN_ROOT}/references/templates/architecture-review-report.md`. The output ends with:

```md
### Recommended next Cohesive skill

Per verdict:
- **Healthy / Mostly healthy:** `superpowers:writing-plans` — substrate is sound; implementation work can proceed.
- **Cohesive but under-enforced:** `cohesive:rewrite-specs` — promote convention to enforcement where leverage is highest.
- **Spec drift risk:** `cohesive:rewrite-specs` — repair the substrate before further code changes.
- **Architecture risk:** `cohesive:brainstorm-design` — the structural shape itself needs revisiting.
```

## Output discipline

- **Verdict first, then evidence.** Don't bury the lede.
- **Findings ranked by leverage.** Not alphabetical, not by file location.
- **Every finding maps to a substrate artifact.** If a finding has no substrate target, ask whether it's preference rather than a real cohesion issue.
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
- Output ends with a per-verdict "Recommended next Cohesive skill" footer.

## Red flags

- Skipping `discover-substrate` because "I can just read the docs myself."
- Dispatching reviewers sequentially instead of in parallel.
- Producing a finding list with no thesis.
- Skipping the spec-prior gate (Phase 2 must run before Phase 3).
- More than 100 findings. If you have that many, ranking is failing.
- Findings without substrate artifacts. Either add the artifact or drop the finding.

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
