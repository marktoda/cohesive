---
name: cohesive-review
description: Use when reviewing a codebase, subsystem, or PR/diff for cohesion. Has two modes — codebase (full architecture review) and diff (PR/branch/working changes). Reads normative docs first; in codebase mode stops if specs are seriously inconsistent; otherwise dispatches focused reviewer agents in parallel and synthesizes a thesis-led report. Triggers on "review the architecture", "architecture review of X", "review my PR for cohesion", "review this diff", "is this codebase healthy". For substrate audits ("what memory is this codebase missing", "audit the substrate"), use `cohesive:substrate-audit` instead.
---

# Cohesive review

## What this skill produces

One of two reports depending on `--scope`:

- **`--scope codebase`** — full architecture review per `${CLAUDE_PLUGIN_ROOT}/references/architecture-review-rubric.md`. Output written to `docs/history/reviews/YYYY-MM-DD-<slug>-architecture-review.md` and rendered in chat.
- **`--scope diff`** — PR / branch / working-changes review focused on whether the change preserves substrate. Rendered in chat; not written to disk by default.

For substrate audits (what memory is missing across the repo), invoke [`cohesive:substrate-audit`](${CLAUDE_PLUGIN_ROOT}/skills/substrate-audit/SKILL.md) instead. That skill shares no machinery with codebase/diff modes — its previous existence as `--scope substrate` here was a category error.

## How to choose the mode

If the user passes `--scope`, honor it. If not, infer:

- "review the architecture", "architecture review", "review the codebase" → `codebase`
- "review my diff", "review my PR", "review this branch" → `diff`
- ambiguous "review X" with X being a small change set → `diff`
- ambiguous "review X" with X being a whole repo or subsystem → `codebase`
- "what's missing", "audit substrate" → route to `cohesive:substrate-audit` (different skill)

If you can't decide after a short read of the user's request, ask: "Is this a full architecture review (`--scope codebase`) or a PR/diff review (`--scope diff`)?"

## Hard constraints

1. **Always run `discover-substrate` first.** Or re-use its output from earlier in this session. The reviewer agents read what discovery surfaced; without it, they glob the world.
2. **Reviewers receive paths, not summaries.** Pass the agents file paths; let them read. Pre-summarizing biases the review.
3. **Reviewers run in parallel.** Use a single message with multiple Task tool calls. Sequential is wasted wall-clock time and burns more tokens because each agent re-loads context.
4. **Synthesize, don't concatenate.** The final report is a thesis-led synthesis. Stitching together four agent outputs is the failure mode — not the goal.

## Process by mode

### Mode: `codebase`

Implements the four-phase architecture review from `${CLAUDE_PLUGIN_ROOT}/references/architecture-review-rubric.md`.

#### Phase 1: Read normative substrate

Use `discover-substrate` (or its output) to get the list. Read in priority order:
1. `CLAUDE.md`, `AGENTS.md`
2. `ARCHITECTURE.md`, `architecture.md`
3. `README.md`
4. `docs/design/**`, `docs/specs/**`, `docs/adr/**`, `docs/substrate/**`
5. `docs/substrate/invariants/**`, `docs/substrate/gotchas/**`, `docs/substrate/matrices/**`, `docs/testing/**` (or repo-native equivalents — see `${CLAUDE_PLUGIN_ROOT}/references/substrate-layout.md`)

Produce the **claimed system shape** summary (sections from the rubric: Product goal / Architectural priors / Intended seams / Named invariants / Testing philosophy / Future direction implied by docs).

#### Phase 2: Spec-prior gate

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

#### Phase 3: Dispatch focused reviewers in parallel

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

Token discipline: instruct each agent to keep its output bounded; long discussion goes in linked appendix files if needed.

#### Phase 4: Synthesize

Don't concatenate. Synthesize:

1. **Thesis** — one paragraph naming the codebase's overall shape, the highest-leverage risk, and whether the system can scale development without founder memory. Concrete; specific to this codebase.
2. **Verdict** — one of: Healthy / Mostly healthy / Cohesive but under-enforced / Spec drift risk / Architecture risk
3. **Cohesion scorecard** — 9-axis ratings from `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md`
4. **Highest-leverage findings** — ranked by leverage × severity, format from rubric
5. **Substrate improvements** — specs to rewrite, matrices to add, semantic linters to add, gotchas to document
6. **Phased roadmap** — first repair substrate, then simplify architecture, then strengthen enforcement

Use the template at `${CLAUDE_PLUGIN_ROOT}/references/templates/architecture-review-report.md`.

#### Phase 5: Persist

Write the report to `docs/history/reviews/YYYY-MM-DD-<slug>-architecture-review.md` (where `<slug>` is derived from the scope). Render the same content in chat.

If `docs/history/reviews/` doesn't exist, create it. Reviews are append-only history (per `${CLAUDE_PLUGIN_ROOT}/references/substrate-layout.md`) — commit them. User can suppress persistence with `--no-write` if they want it transient.

### Mode: `diff`

Lighter-weight. Skip Phase 1's normative read except for files touched by the diff.

1. **Locate the diff.** Try in order:
   - If user named a PR: `gh pr diff <number>`
   - If on a feature branch: `git diff main...HEAD` (or detect default branch)
   - Else: `git diff HEAD` (working changes) and `git diff --cached` (staged)
   - If empty: refuse — "No diff to review. Specify a PR number or commit your changes first."

2. **Substrate discovery, scoped to changed files.** Run `discover-substrate` with the changed file paths as the change surface.

3. **Dispatch two reviewers in parallel** (lighter than codebase scope):
   - `substrate-alignment-reviewer` — does this diff preserve documented behavior and invariants?
   - `structure-reviewer` — does this diff improve or degrade the change surface?

   Skip `library-native-reviewer` and `agent-readiness-reviewer` for diff scope unless the diff is large (>500 lines changed) or restructures architecture. The dispatch prompt includes the same fresh-eyes prose as in codebase mode.

4. **Render verdict in chat.** Use this format:

```md
# Change Cohesion Review

**Verdict:** Pass / Pass with notes / Needs substrate / Risky / Block

## Main concern
<one sentence>

## Findings

| Severity | Area | Finding | Suggested substrate |
|---|---|---|---|
| Blocking | Invariant | <name> | <artifact> |

## Behavior/spec alignment
...

## Invariant preservation
...

## Test guarantee gaps
...

## Locality and abstraction concerns
...

## Highest-leverage fix
<one specific recommendation>

### Recommended next Cohesive skill
- **Pass:** `superpowers:writing-plans` — substrate is preserved; ready for implementation discipline.
- **Pass with notes:** `superpowers:writing-plans` — proceed; the notes are advisory, not gating.
- **Needs substrate:** `cohesive:rewrite-specs` — the change implies substrate updates that should land before merge.
- **Risky:** `cohesive:cohesive-review --scope codebase` — risk straddles the diff boundary; broader review is warranted before a fix.
- **Block:** `cohesive:brainstorm-design` — the change conflicts with the substrate at a level that requires re-deciding direction, not just rewriting docs.
```

5. **Don't persist by default.** Diff reviews are usually conversation-scoped. User can `--persist` if needed.

## Output format

The skill's chat output for `--scope codebase` matches the template at `${CLAUDE_PLUGIN_ROOT}/references/templates/architecture-review-report.md`. The output ends with:

```md
### Recommended next Cohesive skill

Per verdict:
- **Healthy / Mostly healthy:** `superpowers:writing-plans` — substrate is sound; implementation work can proceed.
- **Cohesive but under-enforced:** `cohesive:rewrite-specs` — promote convention to enforcement where leverage is highest.
- **Spec drift risk:** `cohesive:rewrite-specs` — repair the substrate before further code changes.
- **Architecture risk:** `cohesive:brainstorm-design` — the structural shape itself needs revisiting.
```

`--scope diff` chat output ends with the per-verdict footer shown in step 4 above.

## Output discipline

For both modes:

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

- The mode is explicit (passed by user or inferred and announced).
- `discover-substrate` ran (or its output was reused) before reviewers were dispatched.
- For codebase mode: Phase 2 spec-prior gate is honored — if substrate is broken, the review stops early.
- Reviewers run in parallel via a single message with multiple Task tool calls.
- Synthesis produces a thesis, not a stitched concatenation.
- Codebase reviews persist to `docs/history/reviews/`.
- Every finding names the substrate artifact to add or update.
- Output ends with a per-verdict "Recommended next Cohesive skill" footer.

## Red flags

- Skipping `discover-substrate` because "I can just read the docs myself."
- Dispatching reviewers sequentially instead of in parallel.
- Producing a finding list with no thesis.
- Codebase review with no spec-prior gate check (Phase 2 must run before Phase 3).
- More than 100 findings. If you have that many, ranking is failing.
- Findings without substrate artifacts. Either add the artifact or drop the finding.

## Composition

- **Always preceded by:** `discover-substrate` (or reuse of its output)
- **Often followed by:** `rewrite-specs` (if the review found spec drift requiring repair) or `superpowers:writing-plans` (if the review approved the change)
- **Compatible with:** Superpowers' `code-reviewer` for the implementation-quality lens, after Cohesive's substrate lens. Run both for a high-stakes review.
- **Adjacent skill:** `cohesive:substrate-audit` — for "what's missing" rather than "what's wrong."

## What this skill is *not*

- Not a substrate audit. That's `cohesive:substrate-audit`.
- Not a code-style review. Naming, formatting, and micro-naming preferences are out of scope.
- Not a defect hunt. Implementation bugs that aren't substrate gaps belong in normal code review.
- Not a refactor proposal. Findings recommend substrate changes, not large code rewrites.
