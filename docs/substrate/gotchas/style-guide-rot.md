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

## Correct pattern

Cite the guide *from where the model reads at generation time*. Specifically, every `skills/*/SKILL.md` Output format block opens with a single-line citation:

```
> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md
```

The skill body's Output format block is what the model loads when rendering chat output for that skill. The citation is what triggers the model to load the voice guide alongside it. The guide stays canonical (one file), the citation stays minimal (one line per skill), and the locality problem is solved structurally.

The citation requirement is enforced by `validate_plugin.sh` (planned per `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-04-cut-anchor-pin.md`). It is currently convention reinforcement on top of skill-author memory; it earns invariant status if it survives two release cycles without drift.

A second structural lever: pair the rules with a worked transcript. `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/output-voice-worked-example.md` carries a side-by-side wordy-vs-punchy render annotated with the cut-by-cut rationale. Style rules without examples decay; rules paired with examples are remembered.

## Related invariant

- Invariant: `VERDICT_BEFORE_EVIDENCE` — the one rule from `references/output-voice.md` promoted to invariant because it has the cleanest grep and the highest-leverage failure mode. The other voice rules stay convention, defended by the citation pattern and the worked transcript. This gotcha is the trap those defenses must avoid.

## Tests / checks that preserve this

- `scripts/validate_plugin.sh` (planned): grep every `skills/*/SKILL.md` Output format block for the literal voice-citation line. A skill missing the citation fails the validator with a message naming this gotcha.
- `cohesive:review-codebase` and `cohesive:review-diff` flag missing or stale citations as substrate findings.
- `cohesive:review-diff` flags chat output that diverges from `references/output-voice.md` as a "substrate-alignment" finding when reviewing a diff that touches a skill body.

If the citation grep is dropped or weakened, this gotcha returns immediately. The grep is small; deleting it for "simplicity" is the predictable failure mode.

## When this was discovered

- Date: 2026-05-04
- Source: Pressure-testing the "Voice + transcript" option (Option B) in the `cut-anchor-pin` brainstorm. Question 20 ("appears easy but isn't") surfaced that style guides without citation hooks rot. The gotcha was authored alongside the rewrite that adds the citation hook, so the trap is documented before it can be sprung.
- One-line summary: a style guide is operationally only as effective as its citation discipline; rules far from generation drift silently.

## Notes for future contributors

- When adding a new reference doc that the model is expected to follow at generation time, ask: where does the model read this? If the answer is "via a chain of citations from a far-away README," the doc will rot. Add a citation hook in the closest place the model reads at the relevant moment.
- The pattern generalizes beyond voice. Any "rules at a distance from generation" doc — review heuristics, design conventions, naming rules — is at risk of the same rot. The fix is the same: cite from the point of generation.
- Resist the urge to summarize the guide back into the skill body. The whole point of a single source of truth is that it stays single. The citation links; verbatim copies rot.
- If a future runtime feature lets skills declare "always pull file X into context when invoked" (a manifest-level dependency), this gotcha's correct pattern should be re-examined — the citation hook becomes redundant if the dependency is declarative.
- **Worked-example literal must match the validator grep.** When a worked example or transcript demonstrates a literal that a validator pins (the voice-citation line is the v0.1 case), the demonstrated form MUST match the grep target byte-for-byte. Wrapping the path in backticks for readability, adding stray whitespace, or paraphrasing the prefix all produce a worked example that teaches a non-canonical form — and contributors copy what they see. Pass-5 of the `cut-anchor-pin` rewrite shipped this exact regression: the worked transcript wrapped `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` in backticks while every spec doc kept it bare. The fix is mechanical (drop the backticks); the substrate lesson is to check literal-form parity between spec and worked example as part of every rewrite that touches either.
