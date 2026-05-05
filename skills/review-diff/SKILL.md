---
name: review-diff
description: Use when reviewing a PR, branch, or working changes for cohesion — does the diff preserve documented behavior, named invariants, and substrate? Lighter than codebase review; dispatches two reviewer agents in parallel and renders verdict in chat. Triggers on "review my PR", "review this diff", "review my branch", "review my changes", "is this PR cohesion-safe". For full architecture review use `cohesive:review-codebase`.
---

# Review diff

## What this skill produces

A change-cohesion review focused on whether the change preserves substrate. Rendered in chat; not written to disk by default. The output is verdict-led (Pass / Pass with notes / Needs substrate / Risky / Block) with ranked findings.

For full architecture review use [`cohesive:review-codebase`](${CLAUDE_PLUGIN_ROOT}/skills/review-codebase/SKILL.md). For "what memory is missing" inventories, use [`cohesive:audit-substrate`](${CLAUDE_PLUGIN_ROOT}/skills/audit-substrate/SKILL.md).

## Voice

Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output. The voice guide is the load-bearing source for verdict-leads, header-depth cap, density budgets, and forbidden phrasings; the imperative above is what triggers the model to load it via a Read tool call. Do not reproduce the imperative or any citation to the voice guide inside the Output format render template — instructions placed inside render templates leak verbatim into user-facing output (the failure mode `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` documents).

## Hard constraints

1. **Substrate discovery is a prereq; ask the user, don't guess.** Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md`, detecting prior discovery from session memory silently degrades. Open the turn with the canonical forced-choice question:

   > "I see we're about to run review-diff. Has substrate discovery already happened for the changed files, or should I run `discover-substrate` first?"

   When the `cohesively` router invokes this skill, it passes "discovery already complete; report at <path>" in the dispatch prompt and this skill skips the question.

2. **Reviewers receive paths, not summaries.** Pass the agents file paths; let them read.
3. **Reviewers run in parallel.** Single message, multiple Task tool calls.
4. **Substrate-discovery is scoped to the diff.** Don't read the whole repo's normative substrate; only what the changed files touch.

## Process

Skip Phase 1's normative read except for files touched by the diff.

### 1. Locate the diff

Try in order:
- If user named a PR: `gh pr diff <number>`
- If on a feature branch: `git diff main...HEAD` (or detect default branch)
- Else: `git diff HEAD` (working changes) and `git diff --cached` (staged)
- If empty: refuse — "No diff to review. Specify a PR number or commit your changes first."

### 2. Substrate discovery, scoped to changed files

Run `discover-substrate` with the changed file paths as the change surface (or reuse its output if the router already ran it).

### 3. Dispatch two reviewers in parallel

Lighter than codebase scope:

- `substrate-alignment-reviewer` — does this diff preserve documented behavior and invariants?
- `structure-reviewer` — does this diff improve or degrade the change surface?

Skip `library-native-reviewer` and `agent-readiness-reviewer` for diff scope unless the diff is large (>500 lines changed) or restructures architecture.

The dispatch prompt includes the same fresh-eyes prose as in codebase mode: "The reviewer reads only paths passed to it, not the conversation." See [`reviewer-agent-template.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/reviewer-agent-template.md) §"The fresh-eyes preamble" for the canonical form.

### 4. Render verdict in chat

Use this format:

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
- **Risky:** `cohesive:review-codebase` — risk straddles the diff boundary; broader review is warranted before a fix.
- **Block:** `cohesive:brainstorm-design` — the change conflicts with the substrate at a level that requires re-deciding direction, not just rewriting docs.
```

### 5. Don't persist by default

Diff reviews are usually conversation-scoped. User can `--persist` if needed; the persisted form lands at `docs/history/reviews/YYYY-MM-DD-<slug>-diff-review.md`.

## Output format

The canonical render produced in step 4:

```md
# Change Cohesion Review

**Verdict:** Pass / Pass with notes / Needs substrate / Risky / Block

## Main concern
<one sentence>

## Findings

| Severity | Area | Finding | Suggested substrate |
|---|---|---|---|
| Blocking | Invariant | <name> | <artifact> |

## Highest-leverage fix
<one specific recommendation>

### Recommended next Cohesive skill
- **Pass / Pass with notes:** `superpowers:writing-plans` — substrate is preserved; ready for implementation discipline.
- **Needs substrate:** `cohesive:rewrite-specs` — the change implies substrate updates that should land before merge.
- **Risky:** `cohesive:review-codebase` — risk straddles the diff boundary; broader review is warranted.
- **Block:** `cohesive:brainstorm-design` — the change conflicts with the substrate at a level that requires re-deciding direction.
```

Don't bury the verdict. Findings are ranked by leverage. Optional sections from step 4 (`## Behavior/spec alignment`, `## Invariant preservation`, `## Test guarantee gaps`, `## Locality and abstraction concerns`) may be added under `## Findings` if they earn their place; omit any that don't.

## Output discipline

- **Verdict first, then evidence.** Don't bury the lede.
- **Findings ranked by leverage.** Not alphabetical.
- **Every finding maps to a substrate artifact.** If a finding has no substrate target, ask whether it's preference rather than a real cohesion issue.
- **Concrete file:line references.** Vague findings get rejected.

## Token discipline

- Reviewers read paths surfaced by `discover-substrate` only
- Each reviewer's output is bounded
- Synthesis merges; it does not re-read

## Acceptance criteria

- `discover-substrate` ran (or its output was reused) before reviewers were dispatched.
- Reviewers run in parallel via a single message with multiple Task tool calls.
- Verdict is one of: Pass / Pass with notes / Needs substrate / Risky / Block.
- Every finding names the substrate artifact to add or update.
- Output ends with a per-verdict "Recommended next Cohesive skill" footer.

## Red flags

- Skipping `discover-substrate` because "I can just read the diff myself."
- Dispatching reviewers sequentially instead of in parallel.
- Producing a finding list with no verdict.
- Findings without substrate artifacts.

## Composition

- **Always preceded by:** `discover-substrate` (scoped to changed files, or reuse of its output)
- **Often followed by:** `rewrite-specs` (Needs substrate verdict), `cohesive:review-codebase` (Risky verdict), `brainstorm-design` (Block verdict), or `superpowers:writing-plans` (Pass / Pass with notes)
- **Compatible with:** Superpowers' `code-reviewer` for the implementation-quality lens after this skill's substrate lens. Run both for a high-stakes PR.
- **Adjacent skills:** `cohesive:review-codebase` (full architecture) and `cohesive:audit-substrate` (missing memory inventory)

## What this skill is *not*

- Not a full architecture review. That's `cohesive:review-codebase`.
- Not a substrate audit. That's `cohesive:audit-substrate`.
- Not a code-style review. Naming, formatting, and micro-naming preferences are out of scope.
- Not a defect hunt. Implementation bugs that aren't substrate gaps belong in normal code review.
