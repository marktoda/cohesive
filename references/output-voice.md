# Output voice and density

Normative for chat-rendered output across every Cohesive skill and reviewer agent. Each non-router `skills/*/SKILL.md` and each `agents/*-reviewer.md` carries a body-level imperative — `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` — directing the model to load this guide via a Read tool call before generating user-facing output. The imperative is the load-bearing line; the Read call is the loading mechanism. The Output format / "How to structure your output" code block is a pure render template and contains no instructions to the model — instructions in render templates leak into user-facing output, the failure mode `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` documents.

> *Note on this doc's own form:* this opening paragraph is plain prose, not a blockquote, even though it is normative. The convention is that **the imperative form skills and agents copy is a single line of plain prose**, never a multi-line blockquote. Earlier passes of this doc opened with a blockquote header; that shape was retired so contributors templating from this doc would not copy a blockquote into a skill body and create a render that, while not in a render template, still reads like a quote of guidance rather than an instruction the model executes.

This doc is the **canonical home of the imperative literal**. The exact wording above (`Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.`) is the wording every skill body, every reviewer agent body, and every validator grep target must match byte-for-byte. If the wording needs to evolve, this doc is the single surface that updates first; the validator script and 12 enforcement targets follow in the same pass. See §"Why the voice imperative is convention-with-grep, not a named invariant" for promotion criteria that gate any rewording.

Cohesive's substrate work is rigorous. Cohesive's chat output is not the place to demonstrate that rigor. Users see the chat. They open the persisted file when they want depth. This guide describes the shape of the chat — terse, verdict-led, scannable, joyful to read.

## The five rules

1. **Verdict before evidence.** Every chat-rendered output that has a verdict opens with the verdict line. Pinned as the named invariant `VERDICT_BEFORE_EVIDENCE` (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`).

2. **The chat render is a faithful subset of the persisted file.** Persisted artifacts (architecture reviews, brainstorms, delta ledgers) carry the full body. Chat shows the verdict, the thesis, the top findings, and the next step. The persisted file is canonical; the chat render is its trailer.

   "Faithful subset" is testable: (a) the verdict matches; (b) every claim in the chat render appears in the persisted file; (c) the chat render does not introduce findings, recommendations, or facts absent from the persisted file. A reviewer applying these three tests can answer "is this a faithful subset?" without judgment calls.

3. **Cap header depth at `###` in chat-rendered output.** No `####`, no `#####`. If a section needs sub-structure, use a bulleted list or a small table. Header soup is the most common form of ceremony.

4. **Render branchy content as bullets or tables, not narrative phases.** "Phase 1: Read normative substrate. Phase 2: Spec-prior gate. Phase 3: Dispatch four reviewers..." reads like a procedure manual. A small table or bullet list says the same thing in a third the lines.

5. **Recommend exactly one next move.** "Recommended next Cohesive skill" is one entry per verdict-branch. Multiple recommendations means the reader has to re-derive what to do; do that derivation in the skill, not in the user's head.

## Do / Don't

| Do | Don't |
|---|---|
| Open with the verdict | Bury the verdict under a setup paragraph |
| State the thesis in 1–2 sentences | Restate the methodology before the finding |
| Use bullets and tables for branchy content | Number phases narratively in chat |
| Reference file:line for evidence | "There may be issues in some areas of the code" |
| One forced-choice question per turn | "Anything else I should know?" |
| Say what you're about to do in one sentence | Narrate every tool call as you make it |
| Recommend one next skill per verdict | "You could also try..." with three more |
| Cap header depth at `###` | Stack `####` and `#####` to organize |

## Forbidden phrasings

These produce wordiness without information:

- "Let me explain what I'm about to do..."
- "Before I proceed, I want to make sure I understand..."
- "There are several things to consider here..."
- "It's worth noting that..." / "It's important to mention that..."
- "I hope this helps!" / "Let me know if you have any questions!"
- "What do you want to focus on?" / "Tell me more about your goals." / "Anything else I should know?" (these violate the forced-choice clarifying-question rule in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/skill-conventions.md` §"Clarifying questions")

## Tone

- Direct, not deferential. The user invoked Cohesive on purpose; treat them as a peer.
- Specific, not hedged. "The recommended fix is X" beats "you might want to consider X."
- Confident about uncertainty. "I don't know whether X holds; the way to find out is Y" beats hand-waving.
- No emojis. No exclamation points except in pull quotes from sources.
- Short sentences over long ones. A clear one-clause sentence beats a clause-clause-clause sentence.

## Density budgets (guideline, not invariant)

These are guidelines, not enforced limits. A density invariant would require a chosen proxy (word count, paragraph count, header count, line count) and every proxy is flawed individually. `wordy-output.md` discusses why density stays convention rather than promoting to a named invariant. Use the budgets below as a sanity check on chat output:

| Skill / output type | Chat-render budget (rough) |
|---|---|
| Router announcement (`cohesively`) | 1–2 sentences |
| `discover-substrate` report | One scannable page; sections under `###` |
| `brainstorm-design` recommendation | Verdict + table + 1-paragraph recommendation |
| `review-diff` verdict | Verdict + table + one-paragraph main concern |
| `review-codebase` chat render | TL;DR only; full body in the persisted file |
| `validate-rewrite` verdict | Verdict + ledger-aligned findings; ~½ page |
| `audit-substrate` chat render | TL;DR only; full body in the persisted file |
| Reviewer agent (any) | ≤500 lines hard cap (existing reviewer rule) |

If a chat render exceeds the budget, the right move is usually one of:
- Move detail into the persisted file; render only the trailer in chat.
- Replace narrative with bullets or a table.
- Drop the methodology recap (the user already invoked the skill; they know what it does).

## The worked transcript

The load-bearing artifact for this guide is the side-by-side wordy-vs-punchy worked example at `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/output-voice-worked-example.md`. Read it before authoring or revising any skill's Output format block. The transcript is dated, append-only — when voice evolves, add a new dated transcript rather than editing the old one.

## Why the voice imperative is convention-with-grep, not a named invariant

The voice-imperative requirement is grep-pinned by `validate_plugin.sh` (Checks 13b/13c retargeted from citation-in-output to imperative-in-body, plus new Check 13d that lints for absence of the citation literal inside Output format code blocks). It has a real failure mode (`style-guide-rot.md`). On those criteria it meets the bar that promoted `VERDICT_BEFORE_EVIDENCE` to a named invariant. It is deliberately *not* promoted, for two reasons:

1. **Wording is the youngest part of this rewrite.** Named-invariant promotion freezes the imperative literal (`Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output`) into the substrate's most-load-bearing layer. The wording was authored in the imperative-pivot rewrite; it has not been dogfooded across multiple skill additions yet. Promoting too early makes the next contributor's small wording change ("read before rendering" instead of "before rendering, Read") into an invariant violation rather than a convention update.
2. **The verdict-leads invariant earns more from promotion.** `VERDICT_BEFORE_EVIDENCE` defines a *behavior* (lead with the verdict) that has many surface forms; only a few of them satisfy the grep, and the grep ratifies a behavior the substrate already cared about. The voice-imperative requirement defines a *literal string*; pinning it as invariant ratifies the string itself, which is a thinner promotion.

Promotion criteria (per [`docs/substrate/gotchas/style-guide-rot.md`](../gotchas/style-guide-rot.md)):

- **Wording stability.** The imperative wording in this doc and in `validate_plugin.sh` Checks 13b/13c is unchanged across two release cycles, dated by the imperative literal's last edit in this file.
- **Caught regression.** A real regression has occurred — a skill or agent shipped without the imperative (or with the citation literal in a render template), the validator caught it via Check 13b/13c/13d, and the catch was judged valuable.
- **Captured-not-authored worked transcript.** A real-session transcript meeting the four acceptance criteria in [`docs/history/transcripts/output-voice-worked-example.md`](../docs/history/transcripts/output-voice-worked-example.md) §"Acceptance criteria for the captured transcript" demonstrates the model executes the Read call at render time.

When all three hold, promote. Until then, the rule lives as convention-with-grep — the grep enforces *current* wording while the substrate retains the option to evolve it. This is the pattern AGENTS.md §"The named invariants" describes as "convention-with-enforcement, distinct from named-invariant status."

## How this guide is used

- **At skill generation time.** Each non-router skill and reviewer agent body carries an imperative directing the model to Read this file before rendering chat output. The Read tool call is the loading mechanism; the imperative is what triggers it. The Output format / "How to structure your output" code block in each skill/agent is the render template the model reproduces in user-facing output — it does not carry the imperative, because instructions placed in render templates appear in user-facing output verbatim.
- **At review time.** `cohesive:review-diff` flags chat-render bloat by reading this file and the persisted output side-by-side; `cohesive:review-codebase` flags drift across multiple skills.
- **At skill authorship time.** Anyone adding or revising a skill reads this guide and the worked transcript before editing the body or the Output format block.

If this guide changes, update the worked transcript in the same pass. Rules without examples are the failure mode of every style guide ever written (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md`).

## What this guide is *not*

- Not a guide for normative-doc prose (specs, invariants, gotchas, matrices). Those follow `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/skill-conventions.md` §"Tone" — imperative for instructions, declarative for descriptions, no hedging.
- Not a guide for review-finding shape. Reviewer findings follow the six-field canonical shape in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/reviewer-agent-template.md` §"Output format conventions".
- Not a guide for what to *say* — what content goes into a review or a brainstorm — only how to render it in chat.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md` — the one rule from this guide promoted to invariant
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/wordy-output.md` — the scar this guide retires
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` — the trap this guide must avoid
- `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/output-voice-worked-example.md` — the worked example
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/skill-conventions.md` §"Output format conventions" — canonical Output format shape (cites this guide)
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/reviewer-agent-template.md` §"Output format conventions" — canonical reviewer-agent shape (cites this guide)
