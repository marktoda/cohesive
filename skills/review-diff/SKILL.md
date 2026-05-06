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

The dispatch prompt includes the same fresh-eyes prose as in codebase mode: "The reviewer reads only paths passed to it, not the conversation." See [`reviewer-agent-shape.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md) §"The fresh-eyes preamble" for the canonical form.

### 4. Render the chat trailer

Use the centralized chat-trailer template at `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md`. The shell (Verdict / Main concern / body block / `### Next`) is shared with every other verdict-led skill; this skill specifies only the body block per the §"Variants" `review-diff` row. The chat render is the decision-rendering of the diff per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2a (with sub-rules 2b / 2c) and the audience seam in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.

**Verdict translation.** The internal verdict (`Pass` / `Pass with notes` / `Needs substrate` / `Risky` / `Block`) renders in the chat trailer as the user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"review-diff".

**Body block specification.** Per the §"Variants" `review-diff` row of the centralized template: a `## Findings` table, ordered by leverage, with columns `Severity | Area | Evidence (file:line + excerpt) | Change | Doc to update`. Every row carries concrete Evidence (file:line + quoted excerpt) and a specific Change column per rule 2b. The "Doc to update" column names the file in the user's repo the change touches (a spec, a behavior matrix, a named-invariant doc); naming the file is decision-shape — telling the user where the change lands. Optional secondary sections (`## Behavior/spec alignment`, `## Invariant preservation`, `## Test guarantee gaps`, `## Locality and abstraction concerns`) may render below the Findings table if they earn their place. A `## Highest-leverage fix` paragraph may render at the end of the body block when a single change closes the most leverage.

**Sample chat-trailer render** (canonical shape; the centralized template is the single source of truth):

```md
# Change Cohesion Review

**Verdict:** <user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"review-diff">

## Main concern
<one sentence>

## Findings

| Severity | Area | Evidence (file:line + excerpt) | Change | Doc to update |
|---|---|---|---|---|
| Blocker | Invariant | `<path>:<line>` — "<excerpt>" | <specific edit that closes it> | `<doc path>` |

## Highest-leverage fix
<one specific recommendation — file:line + the specific change>

### Next

<decision-shaped sentence per the verdict>. *(`cohesive:<skill>` or `superpowers:<skill>`.)* **<Payload-kind>:** <concrete payload>.
```

**`### Next` per verdict.** The chat-trailer `### Next` block renders one entry for the verdict the diff returned, with payload per rule 5a. The decision-shaped sentence leads each entry; the skill citation appears parenthetically in inline code; the payload follows:

- **Internal `Pass` or `Pass with notes`:** Docs and code agree; ready for implementation. *(`superpowers:writing-plans`.)* **Scope:** the change surface in the diff (`<branch>` or `<PR-URL>`).
- **Internal `Needs substrate`:** The docs need updating before this merges. *(`cohesive:rewrite-specs`.)* **Files to edit:** <enumerate the specific docs/matrices/invariants the diff implies should be added or updated, with the specific change in each>. Slug: `<derived-from-diff>`.
- **Internal `Risky`:** Risk crosses the change boundary; broader review warranted. *(`cohesive:review-codebase`.)* **Scope:** <name the subsystem or set of files where the diff's risk leaks beyond the changed-files boundary>.
- **Internal `Block`:** Direction conflicts with the design — revisit before merge. *(`cohesive:brainstorm-design`.)* **Design question:** <name the specific architectural question the diff surfaced, e.g. "should X be one concept or two?">.

### 5. Don't persist by default

Diff reviews are usually conversation-scoped. User can `--persist` if needed; the persisted form lands at `docs/history/reviews/YYYY-MM-DD-<slug>-diff-review.md`.

## Output format

The canonical render produced in step 4 follows `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` shell + the §"Variants" `review-diff` body block. The chat render is the decision-rendering of the diff per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2a (with its sub-rules 2b / 2c). Diff reviews don't produce a persisted file by default, so all substance lives in the chat — but bookkeeping content (cross-iteration finding-ID continuity, disposition matrices, verdict-ratchet language) does not appear here either; diff review is per-invocation by design. The skill citations in `### Next` appear parenthetically in inline code per the centralized template; methodology framing ("Recommended next Cohesive skill") does not appear in chat per the audience seam.

The verdict line renders the user-facing label (translated via `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md`); findings are ranked by leverage; every Findings row carries Evidence (file:line + quoted excerpt) and Change (the specific edit) per rule 2b — bare title + Severity + Area is a render failure.

## Output discipline

- **Verdict first, then evidence.** Don't bury the lede. The verdict line renders the user-facing label (translated from the internal label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md`).
- **Findings ranked by leverage.** Not alphabetical.
- **Every Findings row shows, not names.** File:line + quoted excerpt + the specific change is the minimum row shape per rule 2b.
- **`### Next` carries payload.** The clause names the files / scope / design question, not just the skill name and a count. The decision-shaped sentence leads; the skill citation is parenthetical.
- **No bookkeeping in chat.** Cross-iteration finding-ID continuity, disposition matrices, verdict-ratchet language don't appear here. Diff review is per-invocation.
- **No substrate vocabulary in chat.** "Required substrate", "Recommended next Cohesive skill", "Cohesive workflow" are persisted-file vocabulary; the chat trailer renders decision-shape per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`. The Findings table's `Doc to update` column is the user-facing analog of the prior "Suggested substrate" column — naming the file the change touches in the user's repo, not Cohesive's internal vocabulary.
- **Every finding has a substrate target.** If a finding has no doc to point at, ask whether it's preference rather than a real cohesion issue.
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
- Output ends with a per-verdict `### Next` footer rendered per the centralized chat-trailer template.

## Red flags

- Skipping `discover-substrate` because "I can just read the diff myself."
- Dispatching reviewers sequentially instead of in parallel.
- Producing a finding list with no verdict.
- Findings without substrate artifacts.
- Findings table row carries only Severity + Area + a bare title — no file:line, no excerpt, no Change column. Violates rule 2b — see [`docs/substrate/gotchas/naming-instead-of-showing.md`](${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/naming-instead-of-showing.md).
- Chat trailer's `### Next` names a skill plus a count or a clause without the file list / scope / design question. Violates rule 5a.
- Chat trailer renders substrate-vocabulary tokens ("Required substrate", "Recommended next Cohesive skill", "Cohesive workflow") instead of decision-shape. Violates the audience seam — see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.

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
