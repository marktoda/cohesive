# Gotcha: Cohesive's chat output drifts toward ceremony when the voice rules live as convention only

## Symptom

A user invokes a Cohesive skill — most often `cohesive:review-diff`, `cohesive:review-codebase`, or a `cohesive:cohesively`-routed chain — and the chat-rendered output is wordy, ceremonial, and hard to scan:

- Verdict appears below a methodology recap, an agent attribution, or a setup paragraph
- Header nesting reaches `####` or `#####` to organize what could be a small table
- Phrases like "It's worth noting that," "Hi!", "Let me know if you have any questions!" appear unprompted
- Two or three "next-step" recommendations are listed, each with hedged trade-offs, instead of one verdict-driven recommendation
- The chat output and the persisted file are nearly identical, defeating the purpose of having a chat trailer
- Reviewer-agent attribution leaks into the synthesized review ("The substrate-alignment-reviewer found...")

The user's experience: invoking Cohesive feels heavy. The substrate work is rigorous but the chat output buries the answer under ceremony, so the most valuable parts of each invocation (verdict, top finding, next step) take longer to reach than they should.

## Why it happened

Through v0.1, every UX rule that shapes chat output — TL;DR-first, recommended-next-skill footer, forced-choice clarifying questions, verdict vocabularies — lived as convention in `docs/substrate/designs/skill-conventions.md`. The conventions are correct in spec. They are not enforced where the model actually generates output (the per-skill Output format blocks), and several of them have no grep-pinable form.

Specific contributing factors:

- **No central voice guide.** `skill-conventions.md` §"Tone" was about the SKILL.md body's prose (imperative, declarative, no hedging) — not about the chat the skill renders to the user. There was no normative artifact saying "the chat render should look like X."
- **No worked example.** Style guides without examples decay (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md`). Cohesive had voice rules without a side-by-side wordy-vs-punchy example showing them in action.
- **Per-skill Output format blocks restated similar shapes inconsistently.** Each skill's Output format invented its own block instead of citing a shared one. Drift was the default.
- **No invariant on verdict-leads.** The most-regressed rule (chat opens with verdict) had no grep enforcement. It was repeated in skill bodies as "Output discipline: Verdict first, then evidence" — but missing from the router and inconsistently applied across reviewer outputs.
- **The three-tier model treats `references/` as runtime content the model reads.** That makes `references/` the right home for a voice guide — but only if every skill's Output format block actually cites it at the point of generation, which v0.1 did not require.

## Tempting wrong fix

Add "be more concise" to `CLAUDE.md` or to the system prompt, and trust the model to internalize it.

Why it's wrong: tone-level instructions placed far from the point of generation get ignored under the weight of skill-body prose, dispatch contracts, and reviewer schemas that the model loads each invocation. "Be more concise" is the wishful equivalent of "don't have bugs." The fix has to be structural: a guide cited where the model reads, a worked example that shows what the rule looks like, and a grep that catches the most-regressed rule.

A second tempting wrong fix: invent a "verbose mode" toggle so the default can be terse without losing rigor. Why it's wrong: bifurcation rots. Verbose mode receives no eyes; terse mode becomes the only render anyone ever tunes; the verbose render decays into a documentation graveyard.

## Correct pattern

Three layers, each handling what the others can't:

1. **Tighten the canonical shape itself.** `docs/substrate/designs/skill-conventions.md` §"Output format conventions" and `docs/substrate/designs/reviewer-agent-template.md` §"Output format conventions" cap header depth at `###`, declare that chat renders may be a faithful subset of persisted files, and require branchy content to render as bullets/tables rather than narrative phases. The shape is the rule; future skill authors copy a tight shape, not a wordy one.

2. **Anchor with a voice guide and a worked transcript.** `references/output-voice.md` carries the do/don't rules, density budgets, and forbidden phrasings. `docs/history/transcripts/output-voice-worked-example.md` carries the side-by-side wordy-vs-punchy render with each cut justified inline. Every non-router `skills/*/SKILL.md` and every `agents/*-reviewer.md` carries a body-level imperative — `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` — that directs the model to load the voice guide via a Read tool call before producing user-facing output. The Output format / "How to structure your output" code block stays a pure render template (no instructions, no citation literal). Examples teach voice; prose alone doesn't; instructions placed in render templates leak into user-facing output, so instructions live in body prose.

3. **Pin the most-regressed rule as an invariant.** `VERDICT_BEFORE_EVIDENCE` (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`) is the one UX rule promoted from convention to invariant. `validate_plugin.sh` greps verdict-led skills' Output format blocks for `**Verdict:**` in the first three non-blank lines (Check 13a), greps each non-router SKILL.md / reviewer-agent body for the voice imperative outside fenced code blocks (Checks 13b/13c), and lints render templates for absence of the citation literal (Check 13d). The other voice rules (header-depth cap, density budgets, forbidden phrasings) stay convention until their wording stabilizes and a real regression earns enforcement.

## Related invariant

- Invariant: `VERDICT_BEFORE_EVIDENCE` — the one rule from this gotcha's correct pattern promoted to enforced status. The remaining rules in `references/output-voice.md` are conventions held by skill-author memory and reviewed by `cohesive:review-diff` / `cohesive:review-codebase`.

## Tests / checks that preserve this

- `scripts/validate_plugin.sh`:
  - Check 13a — verdict-leads grep across `skills/review-codebase`, `skills/review-diff`, `skills/validate-rewrite`, `skills/audit-substrate`
  - Checks 13b/13c — voice-imperative grep across each non-router SKILL.md body and each reviewer-agent body (outside fenced code blocks)
  - Check 13d — anti-citation lint across each Output format / "How to structure your output" code block (the citation literal must not appear inside render templates)
- `cohesive:review-diff` reads `references/output-voice.md` and the persisted output side-by-side; flags chat-render bloat as a "substrate-alignment" finding.
- `cohesive:review-codebase` flags voice drift across skills as a "structure" finding (skills' Output format blocks should converge, not diverge).

Checks 13a–13d ship enforced in CI via `.github/workflows/validate.yml`. A red check blocks merge.

## When this was discovered

- Date: 2026-05-04
- Source: User feedback during the `cut-anchor-pin` UX-refactor brainstorm. Direct user quote: "sometimes it is a bit overly wordy in its responses, sometimes the it is unclear with what it is saying and what it wants me to do. I think we can do a better job architecting the skills and the response templates and prompts to make it more clear and punchy and joyous to use."
- One-line summary: v0.1 shipped voice rules as convention only; chat renders drifted toward ceremony with no structural counter-pressure.

## Notes for future contributors

- Resist adding more rules to `references/output-voice.md` instead of pinning existing ones. New rules without enforcement just compound the drift surface.
- The next candidate for invariant promotion is the voice-imperative requirement itself (currently a convention pinned by Checks 13b/13c/13d). If the imperative wording holds across two release cycles without drift and a captured-not-authored worked transcript demonstrates the model executes the Read at render time, consider promoting it to a named invariant. See `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` §"Why the voice imperative is convention-with-grep, not a named invariant" for the four promotion criteria.
- If a chat render exceeds the density budget in `references/output-voice.md` §"Density budgets," the right move is usually: move detail into the persisted file, replace narrative with bullets/tables, drop the methodology recap. Never the right move: ask the user to be more specific — that's pushing the synthesis problem onto the reader.
- `cohesive:cohesively`-routed chains can ask multiple clarifying questions across subskills (router asks, brainstorm asks, persistence prompt asks). The convention is one question *per turn*, not one *per chain*. Reducing chain-total questions is a related-but-deferred problem; track it as future substrate when it earns a doc.
