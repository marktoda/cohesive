# Output voice and density

> Normative for chat-rendered output across every Cohesive skill and reviewer agent. Every `skills/*/SKILL.md` "Output format" block opens with the citation:
> `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`
> The citation is the load-bearing line — it pulls this guide into context at generation time, which is the only moment the rules can take effect.

Cohesive's substrate work is rigorous. Cohesive's chat output is not the place to demonstrate that rigor. Users see the chat. They open the persisted file when they want depth. This guide describes the shape of the chat — terse, verdict-led, scannable, joyful to read.

## The five rules

1. **Verdict before evidence.** Every chat-rendered output that has a verdict opens with the verdict line. Pinned as the named invariant `VERDICT_BEFORE_EVIDENCE` (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`).

2. **The chat render may be a faithful subset of the persisted file.** Persisted artifacts (architecture reviews, brainstorms, delta ledgers) carry the full body. Chat shows the verdict, the thesis, the top findings, and the next step. The persisted file is canonical; the chat render is its trailer.

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
- "What do you want to focus on?" / "Tell me more about your goals." / "Anything else I should know?" (these violate the forced-choice clarifying-question rule in `${CLAUDE_PLUGIN_ROOT}/references/skill-conventions.md` §"Clarifying questions")

## Tone

- Direct, not deferential. The user invoked Cohesive on purpose; treat them as a peer.
- Specific, not hedged. "The recommended fix is X" beats "you might want to consider X."
- Confident about uncertainty. "I don't know whether X holds; the way to find out is Y" beats hand-waving.
- No emojis. No exclamation points except in pull quotes from sources.
- Short sentences over long ones. A clear one-clause sentence beats a clause-clause-clause sentence.

## Density budgets (guideline, not invariant)

These are guidelines, not enforced limits — `OUTPUT_DENSITY` is intentionally not promoted to invariant in v0.1 (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/wordy-output.md`). Use them as a sanity check on chat output:

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

## How this guide is used

- **At skill generation time.** The voice citation in each skill's Output format block pulls this file into the model's context as it generates the user-facing output.
- **At review time.** `cohesive:review-diff` flags chat-render bloat by reading this file and the persisted output side-by-side; `cohesive:review-codebase` flags drift across multiple skills.
- **At skill authorship time.** Anyone adding or revising a skill reads this guide and the worked transcript before editing the Output format block.

If this guide changes, update the worked transcript in the same pass. Rules without examples are the failure mode of every style guide ever written (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md`).

## What this guide is *not*

- Not a guide for normative-doc prose (specs, invariants, gotchas, matrices). Those follow `${CLAUDE_PLUGIN_ROOT}/references/skill-conventions.md` §"Tone" — imperative for instructions, declarative for descriptions, no hedging.
- Not a guide for review-finding shape. Reviewer findings follow the six-field canonical shape in `${CLAUDE_PLUGIN_ROOT}/references/reviewer-agent-template.md` §"Output format conventions".
- Not a guide for what to *say* — what content goes into a review or a brainstorm — only how to render it in chat.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md` — the one rule from this guide promoted to invariant
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/wordy-output.md` — the scar this guide retires
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` — the trap this guide must avoid
- `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/output-voice-worked-example.md` — the worked example
- `${CLAUDE_PLUGIN_ROOT}/references/skill-conventions.md` §"Output format conventions" — canonical Output format shape (cites this guide)
- `${CLAUDE_PLUGIN_ROOT}/references/reviewer-agent-template.md` §"Output format conventions" — canonical reviewer-agent shape (cites this guide)
