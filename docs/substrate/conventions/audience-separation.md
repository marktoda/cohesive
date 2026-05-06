# Audience separation

The chat-render surface and the persisted-file surface have different audiences. Chat goes to the user; persisted files carry the agent-facing audit trail. The two surfaces use different vocabularies.

## The seam

| Surface | Audience | Vocabulary | Where it lives |
|---|---|---|---|
| Chat trailer | The user — peer engineer who invoked Cohesive on purpose | Decision-shape: architectural decisions, tradeoffs, risks, concrete next moves | `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` (the centralized template every verdict-led skill cites) |
| Persisted files | The agent — future readers, reviewers, audit-trail consumers | Substrate-shape: specs, named invariants, behavior matrices, gotchas, semantic linters, finding IDs, disposition matrices, verdict-ratchet history | Per-skill persisted-file templates in `${CLAUDE_PLUGIN_ROOT}/references/templates/<skill>-report.md`; cross-iteration history in each persisted file's `## History` section |

The seam is structural — it lives in two distinct render templates, not in a rule the model must remember. Substrate vocabulary cannot leak into chat unless someone deliberately edits the centralized chat-trailer template.

## What each surface does and does not carry

**Chat trailer carries:**
- The user-facing verdict label (translated from the internal label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md`).
- The thesis or main concern in decision-shape (one or two sentences naming what was found and what to do).
- A body block in show-shape — every finding, top fix, or recommended action carries title + concrete evidence + the specific change that closes it (rule 2b).
- Exactly one `### Next` recommendation per verdict branch, carrying decision-shaped action plus concrete payload (rule 5a).

**Chat trailer does NOT carry:**
- Internal verdict labels (`Substrate gaps`, `Cohesive but under-enforced`, etc.) uncited from the translation table.
- Substrate-shape vocabulary tokens: `**Required substrate before implementation:**`, `**Substrate artifact to add or update:**`, `**Suggested substrate:**`, `**Recommended next Cohesive skill:**`.
- The methodology's name as a user-facing label (`Cohesive workflow`, `Cohesive route`, `substrate-shaped work`). The skill citation in `### Next` appears parenthetically; the methodology framing does not lead.
- Cross-iteration bookkeeping (finding-ID continuity across passes, disposition matrices, verdict-ratchet language).

**Persisted file carries:**
- The full review/audit/brainstorm body in canonical shape (six-field finding shape for reviewer-agent outputs, brainstorm options + pressure-test detail, audit body, etc.).
- Internal verdict labels — these are agent-facing dispatch keys.
- Substrate-shape vocabulary as load-bearing content (the artifacts this iteration adds, names, promotes, demotes).
- Cross-iteration audit trail in `## History` sections (per-pass review-finding closure tracking, verdict trajectory, disposition history) per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2c.
- The methodology's framing where it carries reading value for the audit-trail consumer.

## How the seam is enforced

Five forcing functions, in order of structural strength:

1. **The chat-trailer template literal contains no substrate-vocabulary tokens.** The model reproduces what's in the template; tokens that are not there cannot appear without creative deviation. Templates teach voice more reliably than rules.
2. **Centralization collapses the surface.** Six verdict-led skills' chat-render shells were duplicated pre-rewrite; post-rewrite they cite a single centralized template (`${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md`). Drift surface is `O(1)`, not `O(n_skills)`.
3. **Per-skill SKILL.md `## Output format` blocks specify only the body block, not the shell.** A contributor authoring a new skill or revising an existing one edits the body-block specification; the shell vocabulary discipline is the centralized template's concern.
4. **Persisted-file templates remain substrate-shaped.** Skills that persist (`review-codebase`, `audit-substrate`, `validate-rewrite`, `implement-cohesively`, optionally `review-diff`) write to `${CLAUDE_PLUGIN_ROOT}/references/templates/<skill>-report.md` shapes that carry substrate vocabulary as load-bearing audit-trail content. The audience seam preserves the persisted-file layer rather than collapsing it.
5. **Validator Check 13k path documented (deferred).** The eventual grep target is the centralized chat-trailer template literal: forbidden internal-vocabulary tokens (`Substrate gaps`, `Cohesive but under-enforced`, `Recommended next Cohesive skill`, etc.) inside `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` and inside any SKILL.md `## Output format` block. Lands when wording stabilizes per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` promotion criteria. Until then, single-file reviewer-judged compliance is the enforcement.

## What about frontmatter, body prose, and AGENTS.md?

The audience seam applies to **chat-render surfaces** only. Three other surfaces deliberately keep substrate vocabulary:

- **Frontmatter `description` strings.** The skill's frontmatter is the trigger surface (used by the harness for skill dispatch and trigger competition with adjacent plugins). `validate_plugin.sh` Check 9a/9b enforces substrate-vocabulary tokens in frontmatter to keep Cohesive's triggers narrow against generic-research alternatives. Frontmatter is *not* a render surface — the user does not see it in chat output.
- **Skill body prose.** SKILL.md body sections (`## What this skill produces`, `## Hard constraints`, `## Process`, etc.) are read by the model at dispatch time and by contributors editing the substrate. They carry full methodology vocabulary because that is the discipline the model implements and the contributor maintains.
- **AGENTS.md, README, contributor docs.** These are contributor-facing reading surfaces. Methodology naming carries reading value here (a contributor explicitly learning Cohesive's substrate-first practice).

The seam is render-surface-specific. Pre-render content (triggers, body prose, contributor docs) keeps substrate vocabulary; render content (chat trailer) does not.

## Promotion path to validator enforcement

The convention lives as convention-with-template (the structural property) and reviewer-judgment (the per-pass check) until promotion criteria are met:

1. **Wording stability.** The chat-trailer template literal and the verdict-vocabulary mapping are unchanged across two release cycles, dated by their last-edit timestamps.
2. **Caught regression.** A real regression has occurred — a SKILL.md edit or chat-trailer edit reintroduced substrate vocabulary into a chat-render surface, the regression was caught (in review or in production), and the catch was judged valuable enough to motivate validator backing.
3. **Captured worked-transcript pair.** The dated transcript at `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/2026-05-06-audience-seam.md` (and any subsequent transcripts) provides a real-session demonstration of substrate-shape vs decision-shape rendering side-by-side.

When all three hold, promote: add `validate_plugin.sh` Check 13k that greps the centralized chat-trailer template literal (and optionally the per-skill `## Output format` blocks) for the forbidden token list above. Promote the convention to a named invariant `CHAT_TRAILER_VOCABULARY` per the `style-guide-rot.md` pattern.

Until then: reviewer attention during `cohesive:review-codebase` and `cohesive:review-diff` is the enforcement, with `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` §"Synthesizing-skill chat render shape" as the per-skill compliance grid.

## Why no rule 6 in `output-voice.md`

The audience seam was originally designed as a sixth voice rule. Pressure-testing surfaced three structural problems with the rule-6 approach:

1. **The rule set was already strained.** Rule 2 has three sub-rules (2a/2b/2c); rule 5 has 5a; rule 2c was added because rule 2a wasn't enough. A sixth top-level rule on a substance-vs-bookkeeping axis already covered by rule 2 layered, rather than architected.
2. **Templates teach voice more reliably than rules.** `output-voice.md` §"How this guide is used" already names the Output format block as "the render template the model reproduces in user-facing output." Substrate vocabulary inside the chat-render template literal leaks the same way the voice-citation literal leaks (the failure mode `style-guide-rot.md` documents post-rewrite). No rule prevents that; only template content does.
3. **Rule 2a's "subset" framing already broke under the audience seam.** Adding rule 6 layered on top of a now-incoherent rule. The cheaper move was to fix rule 2a in place ("the chat trailer is the decision-render of the persisted body") and stop.

Option D (this convention) replaces rule 6 with structural removals — substrate vocabulary out of the centralized chat-trailer template, methodology-name out of chat-render surfaces, six duplicated render templates collapsed to one. The rule set in `output-voice.md` stays at five.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` — the centralized template that structurally implements the seam
- `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` — internal-label → user-facing-label mapping
- `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` — the five voice rules; rule 2a amended in place to recognize the seam (chat is the decision-render, not the literal subset, of the persisted body)
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` §"Synthesizing-skill chat render shape" — per-skill compliance grid for chat-trailer template usage
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` — the failure mode the template-as-rule structural choice avoids; promotion criteria for `CHAT_TRAILER_VOCABULARY` invariant
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/naming-instead-of-showing.md` — the substance scar; rule 2b (show-shape findings) survives in the centralized template
