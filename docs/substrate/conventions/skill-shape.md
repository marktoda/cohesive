# Skill shape

The canonical shape for a Cohesive `SKILL.md`. Read this before adding a new skill or modifying an existing one. The `validate_plugin.sh` semantic linter enforces the named invariants — `PLUGIN_ROOT_PATHS`, `VERDICT_BEFORE_EVIDENCE`, `IMPLEMENTATION_PLAN_COVERS_DELTA`, and `SKILL_DESIGN_DOC_SECTION` (see [`docs/substrate/invariants/`](../invariants/)) — structural plugin shape, and a small set of convention pins. The canonical enumeration of pinned conventions (currently enforced versus planned) lives in [`PLUGIN_ROOT_PATHS.md`](../invariants/PLUGIN_ROOT_PATHS.md) §"Convention pins enforced alongside this invariant"; this doc cites that list rather than restating it. The rest of the rules below — section order, body prose tone, anti-pattern table shape — remain convention, reviewed in `review-codebase` / `review-diff` rather than mechanically enforced. Convention status is deliberate where wording is still settling; promotion to enforcement happens when a rule earns it.

This document specifies the SKILL.md *shape*. The substrate above the SKILL.md — what the skill is *for*, what it owns, what crosses its seams — lives in [`docs/substrate/architecture/skills.md`](../architecture/skills.md) (per-skill design layer) and [`docs/substrate/architecture/handoffs.md`](../architecture/handoffs.md) (chain transition contracts). The §"When to edit SKILL.md alone, and when to edit the design layer first" section below distinguishes implementation-shape edits (this doc governs) from design-shape edits (the design layer governs). Chat-rendered output follows [`output-voice.md`](../../../references/output-voice.md), which is normative for every user-facing render — verdict-leads, header-depth cap, density budgets, forbidden phrasings, the worked transcript at [`docs/history/transcripts/output-voice-worked-example.md`](../../history/transcripts/output-voice-worked-example.md). Every non-router skill body and every reviewer-agent body carries a one-line imperative directing the model to Read that guide before rendering chat output; the imperative is the load-bearing line, and the Output format / "How to structure your output" code block is a pure render template that contains no instructions to the model.

## When to edit SKILL.md alone, and when to edit the design layer first

A SKILL.md change is **implementation** if it:

- Refines the wording of an existing process step.
- Adds or tightens a Hard constraint that's already in scope per the skill's section in [`docs/substrate/architecture/skills.md`](../architecture/skills.md).
- Updates the Output format block to match [`output-voice.md`](../../../references/output-voice.md).
- Tightens an anti-pattern.
- Adds a path discipline citation.

A SKILL.md change is **design** if it:

- Changes what the skill is for (Purpose paragraph in skills.md).
- Changes what the skill owns or doesn't own (Owns / Does not own bullets).
- Changes what artifact the skill consumes or produces (Inputs / Outputs).
- Changes which skill produces the input or consumes the output (a seam change).
- Adds or removes a verdict from the skill's vocabulary.
- Adds, removes, or renames the skill itself.

Design changes update [`docs/substrate/architecture/skills.md`](../architecture/skills.md) (purpose, ownership, seams) and/or [`docs/substrate/architecture/handoffs.md`](../architecture/handoffs.md) (artifact contracts, verdict gates) **before** the SKILL.md body changes. The substrate-first discipline is structural here: the SKILL.md is the implementation prompt; the design layer is what the prompt is implementing. `cohesive:rewrite-specs` Process Step 1a classifies every rewrite as Pure implementation / Design / Mixed and records the classification in the delta ledger's `## Delta at a glance` preamble; `spec-cohesion-reviewer` reads the classification during `validate-rewrite` to verify the rewrite touched the right layer first.

Default to **Mixed** when the classification is ambiguous. The cost of over-classifying is one additional doc edit; the cost of under-classifying is a substrate-implementation collapse. The `SKILL_DESIGN_DOC_SECTION` named invariant (see [`docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md`](../invariants/SKILL_DESIGN_DOC_SECTION.md)) ensures the design layer exists for every skill; this rule is what keeps it load-bearing rather than aspirational.

**Design layer is canonical for ownership text.** When the same ownership claim could appear in both `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md` (a per-skill section's Owns/Does-not-own bullets) and the SKILL.md body (Hard constraints, "What this skill is *not*" bullets, frontmatter description), the design layer is canonical. The SKILL.md body should reference rather than duplicate ("see `architecture/skills.md` §`<name>` Owns") — verbatim copies in two places drift across release cycles. `spec-cohesion-reviewer` lens 13 checks both directions: design-layer claims must appear in SKILL.md (or be referenced); SKILL.md ownership claims must appear in the design layer (or be removed as duplication).

## Frontmatter

Every `skills/<name>/SKILL.md` opens with YAML frontmatter:

```yaml
---
name: <skill-name>
description: Use when <one-sentence trigger>. <One-sentence what-it-does>. Triggers on "<phrase>", "<phrase>", "<phrase>".
---
```

Rules:

- `name` matches the directory name exactly.
- `description` is one paragraph (typically 2–4 sentences). Third-person. Begins with "Use when". Ends with explicit trigger phrases in quotes.
- No additional frontmatter fields (no `allowed-tools` unless the skill genuinely needs to scope its tool surface).

## Required body sections (in order)

```md
# <Skill name in human form>

## What this skill produces

## Hard constraints
(Numbered list. Each constraint is a one-sentence rule + one-sentence rationale.)

## Process
(Numbered steps. Steps may be subdivided.)

## Output format
(A markdown code block showing the canonical chat output the skill produces.)

## Acceptance criteria
(Bulleted list. Each criterion is testable in principle.)

## What this skill is *not*
(Bulleted list. Names adjacent skills/concepts the skill does not cover.)
```

## Optional sections

Use these when relevant; omit the heading when not:

- **`## Worktree handling`** — only for skills that should run in an isolated worktree (currently `rewrite-specs`).
- **`## Anti-patterns (Red Flags)`** — a markdown table with three columns (Anti-pattern / Why it's wrong / Fix). Use the table form, not a bulleted list.
- **`## Composition`** — names skills that typically run before or after this one, plus Superpowers compositions.
- **`## Routes`** — only for the router (`cohesively`).
- **`## Token discipline`** — only when the skill's outputs can grow large (currently `review-codebase` and `review-diff`).

## Output format conventions

The "Output format" section shows the canonical chat output the skill produces. Five rules apply, in priority order.

### 1. The voice imperative lives in the skill body; the Output format block is a pure render template

Every non-router `skills/*/SKILL.md` carries, in its body prose, a single-line imperative directing the model to load the voice guide before rendering chat output:

```
Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.
```

The imperative appears in a `## Voice` section placed between `## What this skill produces` and `## Hard constraints` (or between `## What this skill produces` and `## When to invoke` for `discover-substrate`). The Output format block immediately below stays a pure render template — title, verdict, content — and contains **no instructions to the model** and **no citation literal**. Instructions placed inside an Output format block leak verbatim into user-facing output (the failure mode `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` documents post-rewrite). The imperative is what triggers the model to invoke `Read` on `output-voice.md`; the Read tool call is the loading mechanism. `validate_plugin.sh` Check 13b greps every non-router SKILL.md body for the imperative literal; Check 13d greps every Output format code block to confirm the citation literal does **not** appear there. Reviewer agents follow the same shape — Check 13c greps each `agents/*-reviewer.md` body for the imperative.

The router (`cohesively`) is exempt from the imperative requirement: its render budget is 1–2 sentences with no `#` title, and its dispatched subskills carry the voice load on its behalf.

### 2. Verdict-led skills lead with the verdict

For skills whose output names a verdict (`review-codebase`, `review-diff`, `validate-rewrite`, `audit-substrate`, plus future verdict-led skills), the Output format block opens — within the first three non-blank lines after the outermost header — with the literal string `**Verdict:**` followed by a value from the skill's verdict vocabulary. This is the named invariant `VERDICT_BEFORE_EVIDENCE` (see [`docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`](../invariants/VERDICT_BEFORE_EVIDENCE.md)).

Skills without a controlled-vocabulary verdict (`cohesively`, `discover-substrate`, `brainstorm-design`, `rewrite-specs`) are out of scope for this rule but still carry the voice imperative in their body (the router is exempt per rule 1).

### 3. The chat render is a faithful subset of the persisted file

Skills that write a persisted artifact (architecture review, brainstorm, audit report, change cohesion review) render only the trailer in chat: verdict, thesis, top findings, next step. The persisted file is canonical and carries the full body. The chat render does not duplicate the persisted body — it points at it.

"Faithful subset" is defined in [`output-voice.md`](../../../references/output-voice.md) §"The five rules" rule 2: the verdict matches; every claim in chat appears in the persisted file; the chat render does not introduce findings, recommendations, or facts absent from the persisted file.

The canonical chat-render shape for verdict-led, persisted-output skills:

```md
# <Skill output title>

**Verdict:** <value from vocabulary>

**Thesis:** <one or two sentences — headline finding + highest-leverage move>

## Top findings
1. <title> — <one clause: why it matters>
2. <title> — <one clause>
3. <title> — <one clause>

## <Persisted file pointer>
`<persisted-path>`

### Recommended next Cohesive skill
`cohesive:<skill-name>` — <one-clause reason>
```

The render opens with the outermost `#` title, then `**Verdict:**` on the next non-blank line — matching the worked transcript at [`docs/history/transcripts/output-voice-worked-example.md`](../../history/transcripts/output-voice-worked-example.md). The `VERDICT_BEFORE_EVIDENCE` grep verifies the verdict appears within the first three non-blank lines after the `#` title (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md` §"Enforcement"). The voice-citation literal does not appear in the template — it would render to the user. The voice guide is loaded via the body-level imperative (rule 1).

Skills with chat-only output (`review-diff`) render this shape as their entire output, with no separate persisted file.

### 4. Cap header depth at `###` in chat-rendered output

No `####`, no `#####`. If a section needs sub-structure, use a bulleted list or a small table. Header soup is the most common form of ceremony. The persisted file may use deeper nesting; the chat render does not.

### 5. Branchy content renders as bullets or tables, not narrative phases

Multi-step processes, multi-option comparisons, multi-finding lists, and multi-cell matrices render as bullets or tables. Narrative-phase rendering ("Phase 1... Phase 2... Phase 3...") is for the SKILL.md Process section — not for the chat render. The chat render of a four-phase review is a four-row table or a four-bullet list, not four prose paragraphs.

### Recommended-next-skill footer

The skill's "Output format" section ends with:

```md
### Recommended next Cohesive skill
`cohesive:<skill-name>` — <reason>
```

If the skill has multiple verdict-branches (e.g. `validate-rewrite` returns Approved / Issues Found / Design Incoherent), provide one recommended-next per branch. When the appropriate next step is outside Cohesive, the entry names the non-Cohesive action explicitly:

```md
`<next non-Cohesive action>` — <reason>
```

The router (`cohesively`) is exempt: its output is a one-sentence announcement, not a workflow output. It is also exempt from the voice imperative per rule 1 — its dispatched subskills carry the voice load.

## Path discipline

Every reference to another skill, agent, reference, template, or script in the body uses `${CLAUDE_PLUGIN_ROOT}/<path>`. Examples:

- `${CLAUDE_PLUGIN_ROOT}/references/templates/invariant.md`
- `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/discover-substrate/SKILL.md`

This is one of four named invariants (`PLUGIN_ROOT_PATHS`, `VERDICT_BEFORE_EVIDENCE`, `IMPLEMENTATION_PLAN_COVERS_DELTA`, `SKILL_DESIGN_DOC_SECTION`). Three are mechanically enforced by `scripts/validate_plugin.sh` (`PLUGIN_ROOT_PATHS` Check 14; `VERDICT_BEFORE_EVIDENCE` Check 13a; `SKILL_DESIGN_DOC_SECTION` Check 15); `IMPLEMENTATION_PLAN_COVERS_DELTA` is enforced by `implement-cohesively`'s acceptance criteria plus `delta-coverage-reviewer`'s verdict.

## Dispatch discipline

Skills that dispatch to reviewer agents via the Task tool include a fresh-eyes preamble in the dispatch prompt. The preamble's job is to state — in some compatible form — that the agent does not inherit conversation context, reads only the paths passed to it, and does not pre-summarize or pre-rank findings. The canonical wording is in [`reviewer-agent-shape.md`](reviewer-agent-shape.md); copying it verbatim is the safest default.

The dispatching skill body explicitly states, in prose, that the reviewer reads only paths passed to it, not the conversation. The structural fence is the harness's Task-subprocess isolation; the prose preamble is convention reinforcement.

## Clarifying questions

A skill turn asks **at most one** clarifying question. The question is a specific forced choice (e.g., "Should I review the codebase or the diff?"), never a vague open prompt. Forbidden phrasings include "What do you want?", "Can you tell me more?", "What are you trying to accomplish?", "Anything else I should know?".

### Canonical prereq-detection question

When a skill has `discover-substrate` or `brainstorm-design` as a prereq, it cannot reliably detect prior-skill output from session memory — the heuristic produces false positives. Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md`, ask the user. The canonical form:

```
"I see we're about to run [subskill]. Has [prereq] already happened for this change surface,
or should I run [prereq-skill] first?"
```

This is a compliant forced-choice question (two specific options) and counts toward the at-most-one budget. The user answers in one or two words ("yes" / "run it"); the subskill proceeds with explicit knowledge. Subskills using this pattern as of v0.1: `brainstorm-design`, `rewrite-specs`, `review-codebase`, `review-diff`, `audit-substrate`. When the `cohesively` router invokes any of these, the router passes the prereq state explicitly in the dispatch prompt per the "Dispatch prompt contract" in `${CLAUDE_PLUGIN_ROOT}/skills/cohesively/SKILL.md`, and the subskill skips the question.

### Path prereqs use directive errors, not the canonical question

The canonical question above applies only when the prereq is **substrate discovery in the current conversation** — there is no canonical artifact to point at, so the correct fallback is to ask. When a skill's prereq is a **file path** (an Approved validation review for `implement-cohesively`; a delta ledger for `validate-rewrite`), the skill declares the input explicitly in its body (typically in a `## Process` Step 0 or a dedicated `## Inputs` section) and produces a **directive error** when the input is missing. The directive error names the missing input and the upstream skill that produces it:

```
Missing validation review for slug `<slug>`. Run `cohesive:validate-rewrite` first;
expected output at `docs/history/reviews/<date>-<slug>-rewrite-validation.md`.
```

This shape is correct because (a) the prereq is materially a file, not a session-memory claim, so a directive is actionable in one read; (b) the upstream skill is unambiguous (validate-rewrite produces the validation review; rewrite-specs produces the delta ledger), so naming it in the error is more useful than asking the user to choose; (c) the failure mode the canonical-question convention closes (silent degradation from session-memory introspection) does not arise, because the skill is checking whether a path was passed, not whether a discussion happened.

Skills using this pattern as of v0.1: `validate-rewrite` (delta ledger path), `implement-cohesively` (validation review path + delta ledger path). The per-handoff input contract for each is in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md`.

Most skills have a pre-canned clarifying question per route or per ambiguity class. Document these in the skill body so reviewers can verify.

## Router conventions

The router (`cohesively`) follows two extra rules:

1. **Announcement before dispatch.** Whenever the router selects a route and is about to invoke the first subskill, it emits one sentence in this form, before any tool call:

   ```
   I'm treating this as a Cohesive <route> workflow: <subskill-1> → <subskill-2> → <subskill-3>. Reason: <one short clause>.
   ```

   `<route>` is one of the canonical route names (`design`, `review (codebase)`, `review (diff)`, `audit (substrate)`, `rewrite-only`, `implement`, `artifact`). The reason clause is one sentence, not a paragraph. The announcement is plain text, not a comment, not buried in a tool call.

2. **One pre-canned clarifying question per route.** Per the rule above, vague phrasing forbidden. The matrix at [`docs/substrate/matrices/router.md`](../matrices/router.md) names which routes ask which question.

## Tone

This section governs the SKILL.md *body prose* — the instructions, descriptions, and rules in the skill file itself. The skill's user-facing chat output follows [`output-voice.md`](../../../references/output-voice.md), which is normative for every render.

For SKILL.md body prose:

- Imperative for instructions to Claude ("Read X. Output Y. Do not Z.").
- Declarative for descriptions of behavior ("This skill produces W.").
- Avoid hedge words ("usually", "typically", "perhaps") in normative sections. If a rule has exceptions, name them; don't soften the rule.
- No emojis in skill bodies.

For chat-rendered output: read [`output-voice.md`](../../../references/output-voice.md). Read [`docs/history/transcripts/output-voice-worked-example.md`](../../history/transcripts/output-voice-worked-example.md) before authoring or revising an Output format block. Examples teach voice; rules alone don't.

## When sections may differ

These deviations are observed and accepted in v0.1:

- The router (`cohesively`) replaces "Process" with "Routes" and adds a "Routing decision logic" section. Routers route; they don't have a single linear process. The router may also use "Required behavior" instead of "Hard constraints" given its different shape.
- The router (`cohesively`) omits the `## Voice` section. Its render budget is 1–2 sentences and its dispatched subskills carry the voice load on its behalf — see §"Output format conventions" rule 1. The matrix at [`docs/substrate/matrices/skill-section-presence.md`](../matrices/skill-section-presence.md) records this exemption with a `~` cell in the `Voice` column.
- The substrate-discovery skill (`discover-substrate`) uses "When to invoke" + "Inputs" + "Process" instead of "Hard constraints" + "Process." It is a no-dispatch utility skill that has prereq-shaped guidance to give rather than process-internal constraints to enforce. The "When to invoke" section is the load-bearing one for callers.
- A skill may add a "## Token discipline" section if its outputs can grow large.
- The `implement-cohesively` skill adds a "## Branch shape" section because its branch model — implementation lands on the rewrite's `design/<slug>` branch by default, with an alternative `implement/<slug>` shape for split-merge cases — is normative behavior the skill body must specify.
- The `validate-rewrite` skill places the canonical `### Recommended next Cohesive skill` heading inside its Output format's rendered review template (after the review body, where the verdict-branch recommendation lives) rather than as a standalone trailing heading. This is acceptable because `validate-rewrite`'s output *is* a review document with its own internal structure, not the skill's own chat trailer; the recommended-next branching is per-verdict and lives where the verdict is rendered. Under the heading, `validate-rewrite` renders a **Disposition** phrase (derived from the disposition rule in `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Disposition rule for validation-review findings", which maps `(verdict, highest-severity-present)` to a single recommendation) followed conditionally by an **Implementation route** matrix (rendered iff verdict is `Approved` — the verdict-floor mapping in `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Verdict → severity-floor mapping (validate-rewrite)" guarantees `Approved` is merge-ready, so no further disposition gate is needed). The footer convention is satisfied because the canonical heading is present and per-verdict recommendations follow it; no other skill should adopt this shape without an entry here.

These deviations are documented; new deviations require explicit discussion and an entry in this section before adoption.

## Code-producing skills

A general convention reads "Cohesive skills do not produce code." That convention is true for every Cohesive skill *body*. The exception is `implement-cohesively`, which orchestrates a phase loop where `superpowers:executing-plans` produces code inside each phase. The skill body itself never writes code; it dispatches `superpowers:executing-plans` (which writes code with TDD discipline) per phase.

The distinction matters for skill authors: a future Cohesive skill that wants to write code directly (without going through `superpowers:executing-plans`) crosses a seam the v0.1 design rejected. See `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md` §"What Cohesive deliberately does not do." If a future skill genuinely needs to write substrate-shaped code (e.g., a behavior-matrix-to-test-stub generator), the seam needs explicit revisiting in the composition design doc.

## Anti-patterns to avoid

| Anti-pattern | Why it's wrong | Fix |
|---|---|---|
| Hardcoded paths in the body (`/home/...`, `references/...` without `${CLAUDE_PLUGIN_ROOT}`) | Breaks portability; `validate_plugin.sh` fails | Always prefix with `${CLAUDE_PLUGIN_ROOT}/` |
| Missing "Recommended next Cohesive skill" footer | Workflow legibility breaks; user has to re-derive next step | Add the footer; if multiple verdicts, one per verdict |
| Vague clarifying question | Wastes a turn; reroutes design responsibility back to the user | Pre-can the question as a forced choice |
| "Hard constraints" as a bulleted list of vibes | Constraints must be enforceable | Each constraint is a one-sentence rule + rationale |
| "Anti-patterns" as a bulleted list | Conventionally a table in this repo | Use the three-column Anti-pattern / Why / Fix table |
| Frontmatter `description` written in first person ("I help you...") | Breaks the third-person plugin-dev convention | Rewrite in third person beginning with "Use when" |
| New skill not mentioned in `ARCHITECTURE.md` §"v0.1 scope" or README "What's in the box" | Source-of-truth disagreement | Update both in the same pass |
| Router omits the canonical announcement before dispatching | User can't tell which workflow is running | Use the canonical opening sentence; name the route |
| Skill body missing the voice imperative | Voice guide is not loaded at render time; voice rules drift silently — see [`docs/substrate/gotchas/style-guide-rot.md`](../gotchas/style-guide-rot.md) | Add `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` to a `## Voice` section in the skill body |
| Voice citation literal placed inside the Output format code block | Instructions in render templates leak into user-facing output; users see `> Voice and density: ...` rendered verbatim | Remove the citation from the Output format block; the imperative belongs in the body, not the template |
| Verdict-led skill buries the verdict under a setup paragraph | Violates `VERDICT_BEFORE_EVIDENCE`; reader can't scan the answer | Lead the Output format block with `**Verdict:**` within the first three non-blank lines |
| Chat render duplicates the full persisted body | Defeats the chat-trailer model; ceremony without information | Render verdict + thesis + top findings + next step in chat; point at the persisted file |
| Header nesting reaches `####` or `#####` in chat output | Header soup is the most common form of ceremony | Cap at `###`; use a bullet list or table for sub-structure |
| Multiple "Recommended next Cohesive skill" entries without verdict-branching | Pushes the choice back to the user | One entry per verdict-branch; if the skill has one verdict, one recommendation |

## Process when adding a new skill

1. Read the closest existing skill in `skills/` — choose the one whose role most resembles yours.
2. Copy its top-level structure; do not invent new section names.
3. Update `/ARCHITECTURE.md` only if the new skill changes the broad architectural shape (rare for an additional subskill).
4. Update `README.md` §"What's in the box" to reflect the new on-disk reality.
5. Run `bash scripts/validate_plugin.sh`. The validator must pass.
6. Run `cohesive:review-diff` on your branch.
