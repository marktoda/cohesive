# Rewrite Validation Review — Voice-citation imperative pivot

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-04
**Subject:** 21 rewritten/added files per the design delta ledger at `docs/history/delta-ledgers/2026-05-04-voice-citation-imperative.md`
**Brainstorm:** `docs/history/brainstorms/2026-05-04-voice-citation-loading-vs-rendering.md`

**Verdict:** Issues Found

## Executive judgment

The pivot is internally coherent across the files in the rewrite list and the validator now models the new convention faithfully (Checks 13b/13c imperative-present, 13d anti-citation). Empirical evidence from the rewritten files: imperative is present in all 7 non-router skills + 5 reviewer agents; no citation literal remains in any render template sampled; the anti-pattern table, matrix columns, and gotchas all migrate together. The single biggest gap is **a peer normative doc the rewrite did not touch**: `docs/substrate/designs/reviewer-agent-template.md` still teaches the citation-in-render-template as canonical (lines 89–93, 154) and is the doc the matrix and skill-conventions both link to as the canonical reviewer-agent shape. A future contributor who follows the link from `output-voice.md:104`, `skill-conventions.md:147`, or `reviewer-output-shape.md:9` will copy the pre-pivot pattern verbatim. That alone earns Issues Found rather than Approved.

## Blocking issues

### B1. Canonical reviewer-agent template still prescribes the pre-pivot citation pattern

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** `docs/substrate/designs/reviewer-agent-template.md` is cited as canonical from `references/output-voice.md:104` (`§"What this guide is *not*"`), `docs/substrate/designs/skill-conventions.md:147`, and `docs/substrate/matrices/reviewer-output-shape.md:9` (the matrix the rewrite *did* update). At lines 89–93 it still says "Voice citation. The first non-blank line of the agent's 'How to structure your output' code block is: `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`" and at line 154 the anti-pattern table tells contributors to *add* the citation literal. A future contributor adding a sixth reviewer agent will copy this template verbatim, ship the citation in the render template, and the validator's Check 13d will fail — but only after the contributor has done the work, and the substrate they read first told them to do exactly the wrong thing. This is the largest single piece of substrate the rewrite needs to migrate and didn't.
- **Evidence:** `docs/substrate/designs/reviewer-agent-template.md:89–93`, `:154`. Discovered because it's still indexed by the in-scope citation-literal grep.
- **Recommended fix:** Add `reviewer-agent-template.md` to the rewrite. Mirror the skill-conventions §"Output format conventions" rule 1 rewrite: imperative goes in body prose ("Voice" subsection of system prompt — the asymmetry the ledger §"Remaining ambiguity" already flags); render template stays clean. Swap the anti-pattern table row from "missing the voice citation → add citation" to two rows mirroring `skill-conventions.md` lines 217–218.
- **Substrate artifact to update:** Spec (`reviewer-agent-template.md`).

### B2. AGENTS.md and ARCHITECTURE.md retain "voice-citation pin" / "title then voice citation then **Verdict:**" prose that contradicts the pivot

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** `AGENTS.md:47` still says "voice-citation pin" as a v0.1 grep-pinned convention; `AGENTS.md:53` says skill-conventions "now include the voice-citation pin"; `AGENTS.md:64` instructs contributors that "The Output format block must open with the `# <title>` then the voice citation then `**Verdict:**`"; `ARCHITECTURE.md:48` says output-voice is "cited from every Output format block"; `ARCHITECTURE.md:53` lists "voice-citation pin" as the validated convention. These are the contributor-orientation entry points that AGENTS.md and ARCHITECTURE.md exist to be — the docs §"Where to look first" lists send new contributors to. Reading them post-pivot teaches the broken pattern. A new contributor will follow the pre-pivot recipe ("title, citation, verdict") and produce drift the validator catches only after the work is done.
- **Evidence:** `AGENTS.md:47`, `:53`, `:64`; `ARCHITECTURE.md:48`, `:53`. The delta ledger §"What this rewrite *did not* do" does not mention either file.
- **Recommended fix:** Add both to the rewrite. Replace "voice-citation pin" with "voice-imperative pin"; rewrite the "Output format block must open with… voice citation… Verdict" sentence to "title then `**Verdict:**` (verdict-led skills); the voice imperative lives in the skill body, not in the render template."
- **Substrate artifact to update:** Specs (AGENTS.md, ARCHITECTURE.md).

### B3. Verdict line-position prose is now self-contradictory across three files

- **Severity:** Blocker
- **Category:** Vague language / Domain model
- **Why it matters:** Post-pivot, the canonical layout is `# title` / blank / `**Verdict:**`. The worked transcript (`output-voice-worked-example.md:97`) correctly says "Verdict appears on line 3 (after the title and a blank)." But `VERDICT_BEFORE_EVIDENCE.md:12` says verdict "lands on line 1 after the title (or line 2 after a blank)" *and* `:19` says "the same line-2 verdict rule applies" *and* `:58` says "places title on line 1 and `**Verdict:**` on line 2 (after a blank)." Three different line numbers (1, 2, 3) for the same render in three docs. A reader trying to verify "is this output compliant?" cannot answer from the spec alone — they have to count by hand and pick which doc to trust. This is the exact rot the rewrite was supposed to retire ("the worked transcript and the spec must agree byte-for-byte" per `style-guide-rot.md:75`).
- **Evidence:** `VERDICT_BEFORE_EVIDENCE.md:12`, `:19`, `:58` vs `output-voice-worked-example.md:97`.
- **Recommended fix:** Pick one frame ("verdict appears in the first three non-blank lines after the outermost `#` title" — what the validator actually checks) and use it consistently. The "line 3" framing in the worked transcript is correct and matches what readers see. The "line 2 (after a blank)" and "line 1 after the title" phrasings are pre-pivot artifacts; rewrite them to count *non-blank* lines so the spec, transcript, and validator agree.
- **Substrate artifact to update:** Named invariant (`VERDICT_BEFORE_EVIDENCE.md`).

## Important issues

### I1. `## Voice` section is mandatory in 7 of 8 skills but not tracked in `skill-section-presence.md`

- **Severity:** High
- **Category:** Spec drift / Enforcement
- **Why it matters:** `skill-conventions.md:69` mandates a `## Voice` section between `## What this skill produces` and `## Hard constraints` (or before `## When to invoke` for `discover-substrate`). The matrix that exists *for the purpose of* tracking required-section presence (`docs/substrate/matrices/skill-section-presence.md`, referenced from the delta ledger §"Remaining ambiguity") was not updated. The validator pins the *imperative literal* (Check 13b) but not the section heading or its placement; if a contributor moves the imperative into the description frontmatter or buries it in `## Hard constraints`, Check 13b passes silently and the section-placement rule is unenforced. The ledger flags this as ambiguity to resolve; resolving it in the same pass is the lower-rot path.
- **Evidence:** `skill-conventions.md:65–69`; absence in matrix referenced by ledger §"Remaining ambiguity" item 2.
- **Recommended fix:** Add `Voice` as a tracked section in `skill-section-presence.md` for the 7 non-router skills, or explicitly downgrade the `skill-conventions.md` placement rule to "the imperative lives in body prose; placement is convention" so the spec doesn't promise more than the validator delivers.
- **Substrate artifact to update:** Behavior matrix (`skill-section-presence.md`).

### I2. Reviewer-agent imperative placement is asymmetric and unmodeled

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** Skills place the imperative in a `## Voice` section between specific neighbors. Reviewer agents place it inside their "How to structure your output" prose paragraph (sampled: `agents/structure-reviewer.md:107`, `:111`, `:65`, `:87`, `:135`). The structural asymmetry is documented only in the delta ledger §"Remaining ambiguity" item 3; no spec or matrix encodes the agent placement. Two failure modes follow: (a) a contributor adding a sixth reviewer drops the imperative in a different section (Check 13c still passes), and the synthesizer's chat render drifts because the load doesn't reliably trigger; (b) the placement asymmetry suggests a missing per-agent column in `reviewer-output-shape.md` (the matrix grew two columns in this pass; "imperative placement" is the column it didn't grow).
- **Evidence:** Imperatives in agents are always inside the "How to structure your output" section, not a top-level `## Voice` section, but no spec says they must be. Ledger §"Remaining ambiguity" item 3 acknowledges this is unenforced.
- **Recommended fix:** Either (a) say in `reviewer-agent-template.md` (after B1's rewrite) that the agent imperative lives in a "Voice" subsection of "How to structure your output," and add a column to `reviewer-output-shape.md` tracking placement; or (b) accept that placement is convention and note it explicitly in the matrix's Notes section so the asymmetry isn't a hidden contract.
- **Substrate artifact to update:** Spec (`reviewer-agent-template.md`) + matrix (`reviewer-output-shape.md`).

### I3. Empirical-load assumption is named but the gating mechanism for it has no definition of "done"

- **Severity:** High
- **Category:** Future-fit / Test
- **Why it matters:** The pivot's load-bearing claim — that a body-level `Read X` imperative actually triggers a Read at chat-render time — is acknowledged as reasoned-but-unverified in `output-voice.md:88`, `style-guide-rot.md:45`, `output-voice-worked-example.md:124`, and the ledger §"Remaining ambiguity" item 1. All four converge on "captured-not-authored worked transcript demonstrating the model executes the Read at render time" as the gating artifact. None of them define what constitutes a valid capture: which skill must be run, which verifications count (does seeing a Read tool call in the transcript suffice, or must the rendered output reflect specific voice rules?), what counts as "two release cycles" before promotion. Without acceptance criteria, the gate is wishful — when someone has a transcript in hand, four readers will disagree about whether it counts.
- **Evidence:** `output-voice.md:84–89` lists four promotion criteria but only criterion 3 specifies an artifact, not its acceptance criteria. `output-voice-worked-example.md:128–134` describes the capture's pedagogical and empirical value but not what "shows the Read call happening" requires (the transcript would presumably need a tool-call log, which is not normally what `output-voice-worked-example.md` style files contain).
- **Recommended fix:** Add a §"Acceptance criteria for the captured transcript" to either `output-voice-worked-example.md` or `style-guide-rot.md`: name the skill that must produce it (e.g. a real `cohesive:review-diff` or `cohesive:review-codebase` invocation), name what the capture must contain (tool-call log showing `Read` invoked on `output-voice.md`, plus a sampled chat render reflecting at least N voice rules from the guide), and name where it lives. Without this, the pivot ships with an "I'll know it when I see it" gate.
- **Substrate artifact to update:** Test/check spec (queued in the ledger but not specified).

### I4. `references/output-voice.md` top-of-file blockquote may itself violate the pivot's own rule

- **Severity:** Medium
- **Category:** Locality / Domain model
- **Why it matters:** The top-of-file blockquote in `output-voice.md:3` is a long normative paragraph describing the imperative-in-body mechanism. It's not in a render template, so it doesn't trip Check 13d, and the doc itself is what gets loaded — so the user never sees it. But the blockquote shape closely resembles the pre-pivot citation literal, and the new style-guide-rot.md rule "imperatives in body, never in render templates" turns on the meta-distinction "is this in a render template or not?" `output-voice.md:3` is the *first thing* a model loading the file reads; if a future contributor templating from this doc copies the blockquote shape into a skill body or agent prose, the blockquote will look authoritative even though the imperative is supposed to live as plain prose, not blockquote. Worth asking whether the doc should model the same form it prescribes.
- **Evidence:** `output-voice.md:3` is a 5-sentence blockquote; the imperative the doc prescribes is a single line of prose without blockquote framing.
- **Recommended fix:** Either downgrade the blockquote to plain paragraph prose, or add a sentence in §"How this guide is used" noting that this doc's own header blockquote is a doc-introduction convention and is *not* the imperative form skills/agents should copy.
- **Substrate artifact to update:** Spec (`output-voice.md`).

## Substrate gaps

- No semantic-linter spec for "the imperative wording itself is the sanctioned literal." Check 13b/13c grep `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` byte-for-byte, but no doc names the wording authoritative. The wording exists only in the validator script and in body prose it's enforcing. If the wording needs to evolve (the very risk `output-voice.md:81` flags), a contributor changing it will have to update the validator and 12 files atomically with no spec to guide them.
- No gotcha for "instructions placed in render templates leak to users" as the meta-lesson — the ledger §"What this rewrite *did not* do" acknowledges this and defers it. Acceptable for this pass, but the meta-lesson is broader than voice (any future feature that makes the same mistake is unprotected). Worth tracking as an explicit deferred-substrate item rather than a footnote.

## Locality concerns

- The voice-imperative convention now lives in 5 substrate files (`skill-conventions.md`, `VERDICT_BEFORE_EVIDENCE.md`, `PLUGIN_ROOT_PATHS.md`, `style-guide-rot.md`, `wordy-output.md`) plus 2 referenced files (`output-voice.md`, `output-voice-worked-example.md`) plus the validator plus 12 enforcement targets — and three of the five substrate files describe Checks 13b/13c/13d separately. The `PLUGIN_ROOT_PATHS.md` "Shared ownership" note (line 52) names this drift risk explicitly: "if `VERDICT_BEFORE_EVIDENCE`'s scope changes…update its own §Enforcement *and* this canonical list together." But the same note doesn't say which doc is canonical for the voice-imperative literal. After the pivot, three docs each restate the four-check enforcement story; pick one canonical home and have the others link.
- B1 above is the locality boundary failure: a peer doc (`reviewer-agent-template.md`) sits inside the rewrite's surface but outside the rewrite's edit list.

## Future-fit concerns

- `output-voice.md:88` lists "no further rewording of the imperative line is anticipated" as promotion criterion 4. This is unfalsifiable as written — there's no observation that proves "no further rewording is anticipated." Consider rewording to "the imperative line has not been reworded in the past two release cycles" so it becomes a checkable claim rather than a forward prediction.
- `style-guide-rot.md:74` correctly notes that if a future runtime "always pull file X" feature lands, Checks 13b/13c retire but 13d remains useful. This is well-thought-out future-fit framing.

## Enforcement concerns

- Check 13d's enforcement is ergonomic only inside fenced code blocks; the awk pattern in `validate_plugin.sh:354–356` greps `in_block && index($0, lit)` — meaning a citation literal placed *outside* a fenced block (e.g., in a contributor-facing comment in a SKILL.md body) wouldn't trip 13d but also isn't in a render template, so it's fine. The asymmetry between 13b/13c (greps *outside* code blocks) and 13d (greps *inside* code blocks) is intentional and correctly described in `VERDICT_BEFORE_EVIDENCE.md:58` ("the inverse of the pre-pivot 13b/13c"). No issue with the script; flag it for clarity in the spec.

## Vague language to tighten

- `output-voice.md:88` — "No further rewording of the imperative line is anticipated" (unfalsifiable as written; see Future-fit above).
- `VERDICT_BEFORE_EVIDENCE.md:19` — "the same line-2 verdict rule applies" (stale phrasing carried from pre-pivot title-citation-verdict layout; B3 above).
- `VERDICT_BEFORE_EVIDENCE.md:12` — "lands on line 1 after the title (or line 2 after a blank)" (counts blank lines inconsistently with `:58` and the worked transcript; B3 above).
- `output-voice.md:3` — "directing the model to load this guide via a Read tool call before generating user-facing output" — "before generating" is the load-bearing phrase the ledger §"Remaining ambiguity" item 1 worries about. If the imperative needs strengthening to compel the Read at render time (as the ledger suggests), the spec doc itself is where the wording should be tightened first. Consider whether "Step 1: Read X. Step 2: Render output." (the procedural form the ledger names) belongs in the doc.

## Recommended repairs (ranked)

1. **Rewrite `docs/substrate/designs/reviewer-agent-template.md`** to mirror the skill-conventions pivot (B1). Without this, the pivot is half-migrated.
2. **Update AGENTS.md and ARCHITECTURE.md** to match the new substrate (B2). These are the contributor-orientation entry points; leaving them stale poisons every future contribution.
3. **Reconcile the verdict-line-position prose across the three docs** (B3). The worked transcript is right; the invariant doc is internally inconsistent.
4. **Specify acceptance criteria for the captured-transcript gate** (I3). Without them, the promotion gate is wishful.
5. **Decide on `## Voice` section enforcement** — either matrix-track it or downgrade the placement rule to convention (I1).
6. **Define the imperative wording's authoritative home** so future rewordings have a canonical surface to update (Substrate gaps, Locality).

## What looked right

- The four-check enforcement story (13a/13b/13c/13d) is structurally clean: the imperative-present check and the anti-citation check are inverses scoped to opposite sides of the code-block boundary, which is the right shape for catching half-migrations. The validator script implements exactly what the substrate prescribes.
- The matrix split (single "Voice citation" column → "Voice imperative in body" + "Citation absent from output template") is a textbook substrate move: the convention's *meaning* changed, so the column tracking it changed. The `reviewer-output-shape.md:31` cell-rationale paragraph explicitly retires the pre-pivot single column rather than leaving it as a deprecated note.
- `style-guide-rot.md` makes itself the canonical home of the meta-lesson cleanly: §"Tempting wrong fix" gains a third entry naming the v0.1 pre-pivot pattern; §"Notes for future contributors" adds the explicit byte-for-byte parity rule (line 75) that names the pass-5 cut-anchor-pin regression as the precedent. The doc that prescribed the broken pattern now documents why it was broken and what replaces it — exactly the substrate-update pattern Cohesive prescribes.
- The delta ledger is unusually honest about what it didn't verify: §"Remaining ambiguity" names three specific reviewer-attention items, and three of these findings (I1, I2, I3) are direct extensions of those flagged items. The ledger itself didn't bury the residual risk.

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — repair the three blocking issues (reviewer-agent-template migration, AGENTS.md/ARCHITECTURE.md alignment, verdict-line reconciliation) in the same worktree, then re-run `cohesive:validate-rewrite`. Many repairs can be made without going back to `brainstorm-design`.
