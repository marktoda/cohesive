# Brainstorm — voice-citation: loading vs. rendering

**Date:** 2026-05-04
**Status:** Approved — proceed to `rewrite-specs`
**Approved direction:** Option A (Imperative load in skill body)
**Predecessor:** Substrate discovery report (inline, conversation-only — captured in this brainstorm's "Substrate touched" appendix)

## Problem statement

The line `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` currently appears at the top of every non-router skill's chat-rendered output and every reviewer agent's finding output. The convention's stated purpose (per `references/output-voice.md` top-of-file and `docs/substrate/gotchas/style-guide-rot.md` §"Correct pattern") is to *load* `output-voice.md` into the rendering model's context at generation time. A markdown blockquote is text, not a file load — placing the citation in the rendered output template causes it to appear in user-facing output without any evidence that it triggers a file load.

The user's claim, accepted as the premise of this brainstorm: voice rules must be in context at render time, but the citation literal must not appear in user-facing output. The two requirements were conflated by v0.1's design.

## Current scope

- Eliminate the rendered citation literal from user-facing chat output across all 7 non-router skills and all 5 reviewer agents.
- Preserve a structural mechanism that loads `output-voice.md` into the rendering model's context at chat-render time.
- Preserve grep-based enforcement that fails loudly when a future contributor breaks the mechanism — the bar `style-guide-rot.md` requires.

## Future pressure (not current scope)

- Claude Code may eventually add a manifest-level "always load this file when this skill runs" frontmatter field. Whatever ships now should migrate cleanly.
- Promotion of the voice-citation convention from convention-with-grep to named invariant (criteria in `output-voice.md` §"Why voice-citation is convention-with-grep").
- Captured-not-authored worked transcript (queued substrate per `output-voice-worked-example.md` §"Captured transcripts (queued)") becomes the load-bearing artifact for proving the new mechanism works.

## Non-goals

- Not changing the voice guide's content.
- Not changing the `VERDICT_BEFORE_EVIDENCE` named invariant (verdict-leads rule unchanged; only the co-resident voice-citation grep is in scope).
- Not changing `PLUGIN_ROOT_PATHS`.
- Not eliminating the grep — only changing what it greps for.

## Design options

### Option A: Imperative load in skill body

**Summary:** Move the load directive from the Output format code block into SKILL.md prose. Each non-router skill carries a one-line imperative ("Before rendering chat output, Read `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`") in a dedicated `## Voice` section or appended to `## Hard constraints`. The Output format code block becomes pure render template — title, verdict, content, no citation line. Reviewer agents get the same treatment. Validator Checks 13b/13c retarget: grep the SKILL.md/agent body prose for the imperative; new Check 13d greps the Output format code block for *absence* of the citation literal (anti-pattern lint).

**Substrate changes required:** `skill-conventions.md` §"Output format conventions" rule 1 rewrite; `style-guide-rot.md` §"Correct pattern" rewrite; `output-voice.md` top-of-file load-bearing claim and §"How this guide is used" rewrite; `VERDICT_BEFORE_EVIDENCE.md:10` (rule, citation-as-line-2) and §"Enforcement" Checks 13b/13c rewrite; `PLUGIN_ROOT_PATHS.md` pin #6 rewrite; `reviewer-output-shape.md` "Voice citation" column reinterpreted; 7 SKILL.md bodies + 5 agent bodies edited; 7 Output format blocks + 5 agent output blocks stripped of citation; `output-voice-worked-example.md` punchy-render section edited (line 73); validator Checks 13b/13c rewritten; new anti-pattern Check 13d.

**Locality impact:** Consolidates the rule in skill bodies (the artifact the model loads on invocation). Removes the cross-layer coupling between "what's in the template" and "what loads at render time."

**Future fit:** Migrates cleanly to manifest dependency — the imperative becomes a frontmatter field, the body section is dropped. No body-level remnants to clean up.

**Initial risks:** Imperative-loading depends on the model actually executing the Read call. If models treat SKILL.md instructions as setup-only and skip "BEFORE rendering, Read X" directives at render time, we replace a known-leaky mechanism with an assumed-working one.

### Option B: Skill-local condensed rules

**Summary:** Inline a short voice-rules block directly in each SKILL.md body (5–10 lines summarizing verdict-leads, header cap, density budgets, forbidden phrasings). Drop the citation entirely. Drop the load step. The voice guide becomes documentation only.

**Substrate changes required:** Same scope as A *plus* per-skill copies; `output-voice.md` demoted from runtime substrate to documentation; new gotcha for "skill-local copies will drift."

**Locality impact:** Negative — voice rules now live in 12 places (7 skills + 5 agents).

**Future fit:** Hostile to manifest dependency.

**Initial risks:** Already shot down by `style-guide-rot.md` §"Tempting wrong fix": "verbatim copies in 8 skill files become 8 slightly different rule statements within a release cycle." Listed for completeness; not a real candidate.

### Option C: Defer until manifest support

**Summary:** Status quo (citation rendered) until Claude Code adds frontmatter-level "always load this file." Live with the leak in v0.1; revisit at platform support.

**Substrate changes required:** None.

**Locality impact:** None.

**Future fit:** By definition.

**Initial risks:** Indefinite ship date for the leak. The user already objects to the rendered citation; "wait for the platform" is not an answer.

## Pressure test summary

| Option | Cohesion | Substrate delta | Future fit | Locality | Main risk |
|---|---|---|---|---|---|
| A | High | Medium (~14 files) | Migrates cleanly to manifest | Consolidates | Imperative may not actually trigger Read at render time |
| B | Low | Large (rules duplicated 12 ways) | Hostile | Fragments | Drift across copies — already a known wrong fix |
| C | n/a | None | Trivial | None | The leak persists indefinitely; user already rejects |

## Breakage analysis (Option A)

- **Docs that change:** `skill-conventions.md` (rule 1), `style-guide-rot.md` (Correct pattern + Tests/checks), `output-voice.md` (top-of-file claim, §"How this guide is used", §"Why voice-citation is convention-with-grep"), `VERDICT_BEFORE_EVIDENCE.md` (§"Rule" line 10, §"Enforcement" 13b/13c, §"Review checklist" line 74), `PLUGIN_ROOT_PATHS.md` (pin #6), `reviewer-output-shape.md` (column rename + cell reinterpretation), `output-voice-worked-example.md` (line 73 — punchy render), `wordy-output.md` (Correct pattern point 2), every SKILL.md and every agent file (12 total).
- **Existing assumptions that break:** The load-bearing claim that markdown blockquote citation = file-loaded-into-context. The "title-then-citation-then-verdict" canonical layout (becomes "title-then-verdict"). The shared-ownership note in `PLUGIN_ROOT_PATHS.md:51` (still applies, but to a different grep target).
- **Behavior matrix impact:** `reviewer-output-shape.md` "Voice citation" column either splits into two columns ("voice imperative present in body" + "citation absent from output") or is renamed to "Voice imperative present in body."
- **Invariant impact:** `VERDICT_BEFORE_EVIDENCE` named invariant unchanged in spirit. Its enforcement section currently bundles voice-citation greps; the bundling stays — just retargeted. Voice-citation convention itself stays at convention-with-grep tier; promotion criteria in `output-voice.md` §"Why voice-citation…" need a reword (criterion #1 was "wording is the youngest part" — applies to the new wording too).
- **Test guarantee impact:** No tests today. The captured-transcript queued task becomes load-bearing — the only way to verify the new load mechanism actually loads. Promote from queued to required-before-merge.
- **Gotchas triggered:** `style-guide-rot.md` Correct pattern is partially wrong today; rewrite to: "Cite the guide from a place the model can act on at generation time. The skill body's `## Voice` section carries a `Read X` imperative the model executes when invoking the skill. The Output format block is a render template — placing instructions there is wrong because it leaks to the user." The underlying scar (rules far from generation rot) holds.
- **Locality / centralization concerns:** Option A *improves* locality. Today the rule lives across 5 substrate places + 12 skill/agent copies of the citation literal; after, the literal lives in one place (the imperative wording in skill bodies, still 12 copies, but they're imperatives not output templates — distinct concerns).
- **Easy invalid change still possible:** A future skill author who copies an existing skill but forgets to include the imperative — caught by retargeted Check 13b. A skill author who *also* leaves the citation in the Output format block — caught by the new anti-pattern Check 13d. A skill author who renders something else from the Output format block but forgets to load — only caught by the captured transcript proof. That last gap is the residual.
- **New gotcha candidate:** "Citation-shaped instructions in render templates leak to users" — the meta-lesson. May be subsumed by the rewritten `style-guide-rot.md` rather than spun out.

## Recommendation

**Direction:** Option A — Imperative load in skill body.

**Main risk:** No empirical proof today that a `Read X` imperative in SKILL.md body actually triggers a Read tool call at chat-render time. If models read SKILL.md as setup-only context and skip the imperative at render time, we replace a leaky-but-real mechanism with an invisible mechanism that may quietly fail.

**Structural mitigation:** Promote the queued captured-transcript task from "track in the next dogfood pass" to "required before merging the rewrite." A dogfood run of `cohesive:review-diff` on a real PR, captured to disk, must show (a) the model actually invoked Read on `output-voice.md` during render, and (b) the rendered output reflects the voice rules. Without that capture, the rewrite does not ship. The mitigation is structural: a dated, persisted transcript file gates the merge.

**Required substrate before implementation:**

- **Specs:** rewrite `skill-conventions.md` §"Output format conventions" rule 1; rewrite `output-voice.md` §"How this guide is used" + top-of-file load-bearing claim + §"Why voice-citation is convention-with-grep" criteria; rewrite `style-guide-rot.md` §"Correct pattern" + §"Tests/checks"; revise `wordy-output.md` Correct pattern point 2.
- **Matrices:** `reviewer-output-shape.md` — split or rename "Voice citation" column to reflect "imperative-in-body" instead of "citation-in-output."
- **Named invariants:** revise `VERDICT_BEFORE_EVIDENCE.md` §"Rule" line 10 (drop citation-as-line-2 layout) and §"Enforcement" Checks 13b/13c (retarget greps); revise §"Review checklist" line 74; revise `PLUGIN_ROOT_PATHS.md` pin #6 wording.
- **Tests / checks:** captured-transcript proof-of-load (the gating artifact); validator Check 13b retargeted to grep skill-body imperative; validator Check 13c retargeted to grep agent-body imperative; **new** anti-pattern Check 13d greps for absence of the citation literal inside Output format code blocks (catches half-migrations).
- **Gotchas:** rewrite `style-guide-rot.md` §"Correct pattern" + §"Tests/checks" + §"Notes for future contributors"; consider new gotcha "Instructions placed in render templates leak to users" (judgment call — may be subsumed).
- **Semantic linters (proposed):** Check 13d (anti-citation-in-template) is the new lint. Existing Checks 13b/13c are retargeted, not retired.

## Substrate touched (discovery appendix)

The discovery scan that grounded this brainstorm surfaced the following load-bearing files. `rewrite-specs` will need to touch the specs/invariants/matrices/gotchas/validator and produce per-file edits for the skill bodies and agent bodies.

- `references/output-voice.md`
- `docs/substrate/designs/skill-conventions.md` §"Output format conventions" rule 1
- `docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md` §"Rule" line 10, §"Enforcement" 13b/13c, §"Review checklist" line 74
- `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` §"Convention pins enforced alongside this invariant" pin #6
- `docs/substrate/gotchas/style-guide-rot.md` §"Correct pattern", §"Tests/checks", §"Notes for future contributors"
- `docs/substrate/gotchas/wordy-output.md` §"Correct pattern" point 2
- `docs/substrate/matrices/reviewer-output-shape.md` "Voice citation" column
- `docs/history/transcripts/output-voice-worked-example.md:73` (punchy render canonical example)
- `scripts/validate_plugin.sh` Checks 13b/13c (retarget) + new 13d (anti-citation-in-template)
- `skills/{review-diff,review-codebase,validate-rewrite,audit-substrate,brainstorm-design,rewrite-specs,discover-substrate}/SKILL.md` (Output format blocks: drop citation; bodies: add imperative)
- `agents/{structure,substrate-alignment,library-native,agent-readiness,spec-cohesion}-reviewer.md` (output blocks: drop citation; bodies: add imperative)

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — proceed to spec rewrite in a design worktree.
