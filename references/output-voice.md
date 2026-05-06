# Output voice and density

Normative for chat-rendered output across every Cohesive skill and reviewer agent. Each non-router `skills/*/SKILL.md` and each `agents/*-reviewer.md` carries a body-level imperative — `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` — directing the model to load this guide via a Read tool call before generating user-facing output. The imperative is the load-bearing line; the Read call is the loading mechanism. The Output format / "How to structure your output" code block is a pure render template and contains no instructions to the model — instructions in render templates leak into user-facing output, the failure mode `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` documents.

*Note on this doc's own form:* this opening paragraph is plain prose, not a blockquote, even though it is normative. The convention is that **the imperative form skills and agents copy is a single line of plain prose**, never a multi-line blockquote. Earlier passes of this doc opened with a blockquote header; that shape was retired so contributors templating from this doc would not copy a blockquote into a skill body and create a render that, while not in a render template, still reads like a quote of guidance rather than an instruction the model executes. This note itself is rendered as plain prose for the same reason — the doc models the form it prescribes.

This doc is the **canonical home of the imperative literal**. The exact wording above (`Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.`) is the wording every skill body, every reviewer agent body, and every validator grep target must match byte-for-byte. If the wording needs to evolve, this doc is the single surface that updates first; the validator script and 12 enforcement targets follow in the same pass. See §"Why the voice imperative is convention-with-grep, not a named invariant" for promotion criteria that gate any rewording.

Cohesive's substrate work is rigorous. Cohesive's chat output is not the place to demonstrate that rigor. Users see the chat. They open the persisted file when they want depth. This guide describes the shape of the chat — terse, verdict-led, scannable, joyful to read.

## The five rules

1. **Verdict before evidence.** Every chat-rendered output that has a verdict opens with the verdict line. Pinned as the named invariant `VERDICT_BEFORE_EVIDENCE` (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`).

2. **The chat render is substance, not bookkeeping.** Persisted artifacts (architecture reviews, brainstorms, delta ledgers, audit reports) carry the full body, the audit trail, and the substrate-shape vocabulary the agent uses to do its work. Chat shows the verdict (in user-facing form), the thesis, the top findings, and the next step — and *shows* them, not just names them. The persisted file is canonical; the chat render is its decision-shaped trailer.

   This rule has three sub-rules, each independently testable.

   **2a. Decision-render of the persisted body.** The chat render is the decision-rendering of the persisted file, not a literal subset. Every claim in the chat render has a source line in the persisted file, but chat is rendered in user-facing vocabulary (decision-shape: architectural decisions, tradeoffs, risks, concrete next moves) while the persisted file is rendered in agent-facing vocabulary (substrate-shape: specs, named invariants, behavior matrices, gotchas, semantic linters, finding IDs, disposition history). The vocabulary seam between the two surfaces is canonicalized in [`docs/substrate/conventions/audience-separation.md`](../docs/substrate/conventions/audience-separation.md); the centralized chat-trailer template at [`references/templates/chat-trailer.md`](templates/chat-trailer.md) is what every verdict-led skill cites. Test set: (a) the verdict in chat matches the user-facing label per [`references/verdict-vocabulary.md`](verdict-vocabulary.md) for the internal verdict the persisted file records; (b) every claim in the chat render appears in the persisted file (possibly translated through verdict-vocabulary or rephrased in decision-shape); (c) the chat render does not introduce findings, recommendations, or facts absent from the persisted file.

   **2b. Findings are shown, not named.** Each finding rendered in chat carries three things together: a title, concrete evidence (a `path:line` reference, a quoted excerpt, or a named artifact), and the specific change that closes it. A bare title with a one-clause "why it matters" is not a finding; it is a label pointing at one. Cross-iteration references — "promote finding 7," "see finding N family," "the prior pass's deferred items," "review finding 6 family" — are bookkeeping shorthand that names process state; a fresh reader cannot act on them. The chat render quotes the substance afresh each invocation. Bookkeeping references stay in the persisted file, where a reader following the audit trail across iterations has the prior reviews open.

   **2c. Bookkeeping displaces to the persisted file.** Promote/defer disposition matrices, verdict-ratchet language ("verdict improved from X to Y," "ratchets to ⬆"), per-iteration finding-ID continuity, "deferral criterion still holds" annotations, and disposition tables ("Promote (5) / Defer (8)") are audit-trail content. They belong in the persisted file — exactly the surface a reader tracking progress across iterations reads. The chat render is per-invocation; it shows the architectural findings of *this* invocation in show-not-name form. If the synthesizer wants to record cross-iteration disposition, it does so in the persisted file's history section and not in the chat trailer.

   Decision-render test set extends accordingly: (d) every chat finding satisfies 2b (title + evidence + change); (e) the chat trailer carries no bookkeeping per 2c; (f) the chat trailer carries no substrate-shape vocabulary the audience seam in [`docs/substrate/conventions/audience-separation.md`](../docs/substrate/conventions/audience-separation.md) names — substrate concerns appear only in the persisted-file template each skill writes alongside.

3. **Cap header depth at `###` in chat-rendered output.** No `####`, no `#####`. If a section needs sub-structure, use a bulleted list or a small table. Header soup is the most common form of ceremony.

4. **Render branchy content as bullets or tables, not narrative phases.** "Phase 1: Read normative substrate. Phase 2: Spec-prior gate. Phase 3: Dispatch four reviewers..." reads like a procedure manual. A small table or bullet list says the same thing in a third the lines.

5. **Recommend exactly one next move, and carry the payload it needs.** The chat trailer renders one `### Next` entry per verdict-branch (the cardinality rule), and that entry names the concrete inputs the next skill operates on (the payload rule). Multiple recommendations means the reader has to re-derive *which*; an empty payload means the reader has to re-derive *what*. Do both derivations in the skill, not in the user's head. The methodology framing — "Recommended next Cohesive skill" as a section heading, "the Cohesive workflow" as a user-facing label — does not appear in chat per the audience seam in [`docs/substrate/conventions/audience-separation.md`](../docs/substrate/conventions/audience-separation.md); the skill citation appears parenthetically in code form (e.g. `cohesive:rewrite-specs`) after the decision-shaped sentence that leads.

   **5a. The recommendation carries actionable payload.** Three shapes apply by next-skill kind:

   - `cohesive:rewrite-specs` — name the files to edit and the specific change in each. "Rewrite-specs to close the 5 promoted findings" is empty. "Edit `references/output-voice.md` rule 2 to add show-not-name; edit `skills/review-codebase/SKILL.md` Output format to require Evidence per finding" is a payload.
   - `cohesive:brainstorm-design` — name the design question to revisit. "Brainstorm to reconsider the direction" is empty. "Should chat-render bookkeeping promote to a named invariant, or stay convention?" is a payload.
   - `cohesive:review-codebase` / `cohesive:review-diff` / `cohesive:audit-substrate` / `superpowers:writing-plans` / `superpowers:executing-plans` — name the scope. "Review the codebase" is empty. "Review the codebase scoped to the merged delta in `design/<slug>`" is a payload.

   The chat render of the recommendation appears as a `### Next` block under the canonical chat-trailer shell at [`references/templates/chat-trailer.md`](templates/chat-trailer.md): the decision-shaped sentence first, the skill citation parenthetically (in inline code), the payload last. Bare skill-name + reason without payload is a render failure tracked in the synthesizing-skill section of [`docs/substrate/matrices/reviewer-output-shape.md`](../docs/substrate/matrices/reviewer-output-shape.md).

## Do / Don't

| Do | Don't |
|---|---|
| Open with the verdict | Bury the verdict under a setup paragraph |
| State the thesis in 1–2 sentences | Restate the methodology before the finding |
| Use bullets and tables for branchy content | Number phases narratively in chat |
| Reference file:line for evidence | "There may be issues in some areas of the code" |
| Show each finding (title + evidence + change) | Name findings by ID ("promote finding 7"); list bare titles with one-clause why |
| Carry the next-skill payload (files, scope, or design question) | "Next: rewrite-specs to close 5 findings" |
| Persist bookkeeping (disposition matrices, verdict ratchets, cross-iteration IDs) to the file | Render promote/defer matrices, verdict ⬆ ratchet language, or deferral-criterion annotations in chat |
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
- "What do you want to focus on?" / "Tell me more about your goals." / "Anything else I should know?" (these violate the forced-choice clarifying-question rule in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Clarifying questions")
- "Promote finding N" / "Close finding N" / "Finding N from the prior pass" / "Review finding N family" / "the X deferred items" — bare ID references without showing the substance (violates rule 2b — see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/naming-instead-of-showing.md`)
- "Verdict ratchets to ⬆" / "verdict improved from X to Y" / "Disposition: Promote (N) / Defer (M)" — bookkeeping the chat does not need (violates rule 2c)
- "Next: rewrite-specs to close N findings" / "Recommended: brainstorm-design to revisit the direction" — handoffs without payload (violates rule 5a)
- "Recommended next Cohesive skill" (as a section heading in chat) / "Cohesive workflow" / "Cohesive route" / "substrate-shaped work" (as user-facing labels) — methodology framing the chat does not carry (violates rule 2a — see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`); the chat trailer renders `### Next` as the section heading, with the skill name appearing parenthetically in inline code
- "Required substrate before implementation" / "Substrate artifact to add or update" / "Suggested substrate" / "substrate gaps" / "substrate sound" (as user-facing chat labels uncited from `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md`) — substrate-shape vocabulary leaking into chat (violates rule 2a — substrate concerns belong in persisted-file templates, not the chat trailer)

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
| Router announcement (`cohesively`) | 1–2 sentences (decision-shape: leads with what the user gets, not the methodology name; see `${CLAUDE_PLUGIN_ROOT}/skills/cohesively/SKILL.md` §"Output") |
| `discover-substrate` report | One scannable page; sections under `###` |
| `brainstorm-design` recommendation | Pressure-test summary table (when ≥3 options) + 1-paragraph Recommendation (Direction + Main risk + Structural mitigation) per `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` §"Variants" |
| `review-diff` verdict | User-facing verdict + table (3 show-shape rows: file:line + excerpt + Change column + Doc-to-update column) + one-paragraph main concern |
| `review-codebase` chat render | User-facing verdict + thesis + 3 show-shape findings + payload-bearing `### Next`; full body in the persisted file |
| `validate-rewrite` verdict | User-facing verdict + Delta-at-a-glance quote + show-shape findings (six-field shape per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md` §"Output format conventions": Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact) + disposition + (Approved-only) implementation matrix; ½–¾ page |
| `audit-substrate` chat render | User-facing verdict + headline + 3 show-shape top-fixes with title + Evidence + Sketch + Path + payload-bearing `### Next`; full body in the persisted file |
| `implement-cohesively` chat render | User-facing verdict + thesis + Phases table + Delta coverage line + Final substrate review pointer + Branch state + payload-bearing `### Next` per verdict |
| Reviewer agent (any) | ≤500 lines hard cap (existing reviewer rule) |

The user-facing verdict labels in the rows above are translated from internal labels via `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md`; the persisted file keeps the internal label.

The budget rows above assume show-shape findings (title + Evidence + Change, or the skill-specific analog in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` §"Per-skill show-shape variations accepted"). A render that satisfies the substance contract is materially larger than the pre-rewrite title-only shape; the budgets reflect the show-shape minimum, not a target. A render shorter than the budget that achieves substance is fine; a render longer than the budget that adds bookkeeping is the failure mode rule 2c addresses.

If a chat render exceeds the budget, the right move is usually one of:
- Move detail into the persisted file; render only the trailer in chat.
- Replace narrative with bullets or a table.
- Drop the methodology recap (the user already invoked the skill; they know what it does).
- Drop bookkeeping (disposition tables, finding-ID continuity, verdict-ratchet language) from chat per rule 2c — that content belongs in the persisted file's history.

Density and substance are independent failure modes. A render under budget that catalogs finding IDs and disposition matrices fails rule 2b/2c just as a render over budget that re-narrates methodology fails rule 4. The substance test is: can a fresh reader, reading only the chat, name the architectural defect and the change that closes it? If not, the chat is naming, not showing.

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
- **At review time.** `cohesive:review-diff` flags chat-render bloat by reading this file and the persisted output side-by-side; `cohesive:review-codebase` flags drift across multiple skills. `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` §"Synthesizing-skill chat render shape" tracks per-skill compliance with rules 2b, 2c, and 5a; reviewers check the matrix's Shows-not-names / Bookkeeping-displaced / Handoff-carries-payload columns before flagging a regression.
- **At skill authorship time.** Anyone adding or revising a skill reads this guide and the worked transcript before editing the body or the Output format block.

If this guide changes, update the worked transcript in the same pass. Rules without examples are the failure mode of every style guide ever written (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md`).

## What this guide is *not*

- Not a guide for normative-doc prose (specs, invariants, gotchas, matrices). Those follow `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Tone" — imperative for instructions, declarative for descriptions, no hedging.
- Not a guide for review-finding shape. Reviewer findings follow the six-field canonical shape in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md` §"Output format conventions".
- Not a guide for what to *say* — what content goes into a review or a brainstorm — only how to render it in chat.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md` — the one rule from this guide promoted to invariant
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md` — the seam between chat-render (decision-shape) and persisted file (substrate-shape) that rule 2a structurally implements
- `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` — the centralized chat-render template every verdict-led skill cites
- `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` — internal-label → user-facing-label mapping consumed by the chat-trailer's `**Verdict:**` slot
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/wordy-output.md` — the ceremony scar; addressed by rules 3 and 4
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/naming-instead-of-showing.md` — the substance scar; addressed by rules 2b, 2c, and 5a
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` — the trap this guide must avoid
- `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/output-voice-worked-example.md` — the worked example for verdict-leads / show-shape / payload-carrying
- `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/2026-05-06-audience-seam.md` — the worked example pair for substrate-shape vs decision-shape rendering
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Output format conventions" — canonical Output format shape (cites this guide and the chat-trailer template)
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md` §"Output format conventions" — canonical reviewer-agent shape (cites this guide)
