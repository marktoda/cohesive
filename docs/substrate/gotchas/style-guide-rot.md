# Gotcha: Style guides written far from the point of generation are silently ignored

## Symptom

A style guide exists in `references/` (or its equivalent) describing tone, voice, density, or render conventions. The rules look correct. New skill bodies and reviewer agents are added without breaking the validator. Yet the rendered output drifts back toward whatever the model would have produced without the guide — wordier, less verdict-led, less scannable. The guide is technically present in the repo. Operationally, it has no effect.

The user-facing experience is paradoxical: the substrate documents a clear voice; the chat renders ignore it.

## Why it happened

A model's chat output is shaped by what's in its context window at the moment of generation. Skill bodies, dispatch prompts, and reviewer schemas are *always* in context because the harness loads them when the skill is invoked. A reference doc cited only from `CLAUDE.md` or `AGENTS.md` is *sometimes* in context — but when the skill is dispatched into a Task subprocess, or when a chained route compresses the leading conversation, the reference may not be re-read.

The result: the guide is read once at session start (if at all) and competes with much louder, much closer-to-generation content. Voice rules placed in a reference doc cited only from project README are operationally invisible at generation time.

The failure mode is silent: there is no error, no warning, no validator failure. The rendered output is "fine" — it's just not as tight as the guide would prescribe. Drift accumulates over many invocations because each individual render is plausible.

## Tempting wrong fix

Add more rules to the guide and trust that volume will overcome the locality problem.

Why it's wrong: more rules in the same far-away location have the same effect as fewer rules in that location: nearly none. The problem is not the rule's wording or count. The problem is the rule's distance from generation.

A second tempting wrong fix: copy the guide into every skill body verbatim. Why it's wrong: drift across copies. The point of a single source of truth is that it has *one* source. Verbatim copies in 8 skill files become 8 slightly different rule statements within a release cycle.

A third tempting wrong fix, and the v0.1 pre-pivot mistake: place a citation to the guide *inside the Output format render template* on the assumption that displaying the citation is equivalent to loading the file. Why it's wrong: markdown blockquotes are text, not file loads. The citation appears in user-facing output without triggering any read of the cited file. The mistake is doubly broken — ineffective at loading and visible to users — and is the specific failure the imperative-in-body pattern (above) replaces.

## Correct pattern

Direct the model to load the guide *from a place the model can act on at generation time* — not from the render template, where instructions leak verbatim into user-facing output.

Specifically, every non-router `skills/*/SKILL.md` and every `agents/*-reviewer.md` carries a body-level imperative in its prose:

```
Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.
```

The imperative lives in body prose (in skills, in a `## Voice` section between `## What this skill produces` and `## Hard constraints`; in agents, in a "Voice" subsection of the system prompt). The model is expected to invoke `Read` on `output-voice.md` before producing chat output — the Read tool call is the loading mechanism; the imperative is what triggers it.

The Output format / "How to structure your output" code block in each skill or agent is a render template the model reproduces in user-facing output. It contains no instructions to the model and no citation literal — anything inside the code block lands in the user's chat verbatim. Placing a `> Voice and density: …` line inside the render template (the v0.1 pre-pivot pattern) caused the citation to appear in user-facing chat output without any evidence that it actually triggered a file load. That was a doubly-broken design: ineffective at loading, and visible to users in a way the user objected to.

The imperative is enforced by `${CLAUDE_PLUGIN_ROOT}/scripts/validate_plugin.sh` Checks 13b (skills) and 13c (agents), which grep for the literal imperative outside fenced code blocks. The complementary anti-citation lint, Check 13d, fails if the citation literal appears inside any Output format / "How to structure your output" code block — the inverse check that catches half-migrations. Together the two checks pin the convention as substrate.

A second structural lever: pair the rules with a worked transcript. `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/output-voice-worked-example.md` carries a side-by-side wordy-vs-punchy render annotated with the cut-by-cut rationale. Style rules without examples decay; rules paired with examples are remembered.

The third structural lever, queued substrate that hardens this pattern further: a captured-not-authored worked transcript demonstrating the model actually invokes `Read` on `output-voice.md` during a real chat-render. The pattern's load-bearing assumption — that body-level imperatives trigger Read calls at render time — is empirically grounded once that transcript exists; until it does, the assumption is reasoned-but-unverified. See `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/output-voice-worked-example.md` §"Captured transcripts (queued)".

## Related invariant

- Invariant: `VERDICT_BEFORE_EVIDENCE` — the one rule from `references/output-voice.md` promoted to invariant because it has the cleanest grep and the highest-leverage failure mode. The other voice rules stay convention, defended by the citation pattern and the worked transcript. This gotcha is the trap those defenses must avoid.

## Tests / checks that preserve this

- `scripts/validate_plugin.sh` Check 13b: grep every non-router `skills/*/SKILL.md` body (outside fenced code blocks) for the literal imperative `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.`. A skill missing the imperative fails the validator with a message naming this gotcha.
- `scripts/validate_plugin.sh` Check 13c: same grep on every `agents/*-reviewer.md` body.
- `scripts/validate_plugin.sh` Check 13d: grep inside every Output format / "How to structure your output" code block for *absence* of the literal `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`. Citation literals in render templates leak verbatim to users; the check catches half-migrations (imperative added but citation not removed, or vice versa).
- `cohesive:review-codebase` and `cohesive:review-diff` flag missing or stale imperatives as substrate findings.
- `cohesive:review-diff` flags chat output that diverges from `references/output-voice.md` as a "substrate-alignment" finding when reviewing a diff that touches a skill body.

If Checks 13b/13c/13d are dropped or weakened, this gotcha returns immediately. The greps are small; deleting them for "simplicity" is the predictable failure mode.

## When this was discovered

- Date: 2026-05-04
- Source: Pressure-testing the "Voice + transcript" option (Option B) in the `cut-anchor-pin` brainstorm. Question 20 ("appears easy but isn't") surfaced that style guides without load hooks rot. The gotcha was authored alongside the rewrite that added the citation hook, so the trap was documented before it could be sprung.
- 2026-05-04 (later same day) — pivot: user pointed out the citation-hook design conflated "render the citation in user output" with "load the file into context at render time." Markdown blockquotes are text, not file loads — the citation appeared in user output without triggering any load. §"Correct pattern" rewritten to use a body-level imperative the model executes via Read tool call; v0.1 pre-pivot pattern documented as the third tempting wrong fix.
- One-line summary: a style guide is operationally only as effective as its load mechanism; rules far from generation drift silently, and "looks like a load" is not the same as "is a load."

## Notes for future contributors

- When adding a new reference doc that the model is expected to follow at generation time, ask: where does the model read this? If the answer is "via a chain of citations from a far-away README," the doc will rot. Add a body-level imperative in the closest skill or agent that produces output the doc governs.
- The pattern generalizes beyond voice. Any "rules at a distance from generation" doc — review heuristics, design conventions, naming rules — is at risk of the same rot. The fix is the same: imperative in body prose; never in render templates.
- **Imperatives go in body prose; never inside render templates.** The Output format / "How to structure your output" code block is reproduced in user-facing output verbatim. Anything inside it lands in the user's chat. This is the v0.1 pre-pivot mistake to not repeat.
- Resist the urge to summarize the guide back into the skill body. The whole point of a single source of truth is that it stays single. The imperative links; verbatim copies rot.
- If a future runtime feature lets skills declare "always pull file X into context when invoked" (a manifest-level dependency), this gotcha's correct pattern should be re-examined — the imperative-in-body pattern becomes redundant if the dependency is declarative. Checks 13b/13c retire; 13d remains useful (citations in render templates leak regardless of how loading happens).
- **Worked-example literal must match the validator grep.** When a worked example or transcript demonstrates a literal that a validator pins (the voice-imperative line is the post-pivot case), the demonstrated form MUST match the grep target byte-for-byte. Wrapping path components in backticks for readability, adding stray whitespace, or paraphrasing the prefix all produce a worked example that teaches a non-canonical form — and contributors copy what they see. Pass-5 of the `cut-anchor-pin` rewrite shipped this exact regression on the citation literal; the imperative pivot must check literal-form parity between spec, worked example, and validator grep as part of every future rewrite that touches any one of them.
