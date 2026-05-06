# Reviewer Output Shape Behavior Matrix

**Status:** Active
**Last reviewed:** 2026-05-06
**Owner:** Mark Toda

## Purpose

The five reviewer agents under `agents/` each produce findings, and the synthesizing skills (`review-codebase`, `review-diff`, `validate-rewrite`, `audit-substrate`, `discover-substrate`) render those findings to chat. Two shape contracts apply, in two layers:

- **Per-agent finding shape** — six fields per finding (Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact), defined in `docs/substrate/conventions/reviewer-agent-shape.md` §"Output format conventions". The §"Per-agent finding shape" section below tracks compliance.
- **Per-synthesizing-skill chat render shape** — substance-not-bookkeeping rules per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rules 2b, 2c, and 5a (findings shown not named; bookkeeping displaced to the persisted file; handoff carries payload). The §"Synthesizing-skill chat render shape" section below tracks compliance.

Both layers must hold for the user-facing chat to produce critique rather than an audit log of process. Drift in either layer reproduces the failure mode in [`docs/substrate/gotchas/naming-instead-of-showing.md`](../gotchas/naming-instead-of-showing.md). A cell of `✓` means compliant; `✗` means a tracked regression; `~` means renamed or partial (cell text names the deviation).

## Per-agent finding shape

Cell legend:
- `✓` — both spec required and agent file complies (the steady-state value)
- `✗` — spec required and agent file is non-compliant (regression; should not appear in a clean release)

| Agent | Severity | Category | Why it matters | Evidence | Recommended fix | Substrate artifact | Voice imperative in body | Citation absent from output template |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| substrate-alignment-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| structure-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| library-native-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| agent-readiness-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| spec-cohesion-reviewer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

The first six columns reflect the state *after* the 2026-05-04 skill-architecture repair pass. Prior state showed drift: `substrate-alignment-reviewer` dropped Evidence; `library-native-reviewer` and `agent-readiness-reviewer` dropped Category; `spec-cohesion-reviewer` used a different shape entirely (Risk / Substrate artifact / Suggested repair). That repair pass swept all five to canonical.

The last two columns track the voice-imperative convention. The "Voice imperative in body" column verifies each agent's system-prompt body carries the literal `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` outside fenced code blocks (validator Check 13c). The "Citation absent from output template" column verifies the literal `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` does **not** appear inside the agent's "How to structure your output" code block (validator Check 13d). Both columns landed `✓` after the 2026-05-04 voice-citation-imperative pivot (per `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-04-voice-citation-imperative.md`), which retargeted Check 13c from "citation present in output template" to "imperative present in body" and added the new anti-citation Check 13d. The pre-pivot single "Voice citation" column tracked a different artifact (citation in the output template) and is retired.

### Imperative placement (convention, not column)

The voice imperative lives in body prose at a specific place in each agent: as the opening prose paragraph of the "How to structure your output" section, immediately above the canonical six-field finding-shape code block. Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md` §"Output format conventions" rule 1, this is the agent-side analog of the skill-side `## Voice` section: skills carry the imperative in a top-level section between `## What this skill produces` and `## Hard constraints`; agents (which are system prompts, not SKILL.md files with the same section structure) carry it inside their render-shaping section.

Validator Check 13c greps each agent body (outside fenced code blocks) for the imperative literal — it does **not** verify the placement (above the code block, in the "How to structure your output" section). Placement is convention reinforced by this matrix and the reviewer-agent template; drift in placement passes Check 13c silently and is caught only at review time. All five reviewer agents currently place the imperative correctly per the template; if a future contributor places it elsewhere (a "Tone" subsection, a "What you check" section, frontmatter), the synthesizer's chat render still works but the placement convention has drifted and a `cohesive:review-codebase` or `cohesive:review-diff` finding should fix it.

### Verdict-leads is tracked elsewhere

Reviewer agents produce findings, not verdicts. The named invariant `VERDICT_BEFORE_EVIDENCE` (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`) applies to the *synthesizing skills* (`review-codebase`, `review-diff`, `validate-rewrite`, `audit-substrate`) that render the user-facing chat output. The truth-table of verdict-led skills lives in that invariant doc's "Applies to" / "Does not apply to" sections — not in the §"Per-agent finding shape" table above. Verdict shape is a skill-level concern; the §"Synthesizing-skill chat render shape" table below tracks render-time shape for the synthesizing skills directly.

## Synthesizing-skill chat render shape

Three columns, applied to each Cohesive skill that renders findings or fixes to chat. Each column corresponds to a sub-rule in `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`:

- **Shows-not-names** (rule 2b) — every finding rendered in the skill's Output format chat trailer carries title + concrete evidence (file:line, quoted excerpt, or named artifact) + the specific change that closes it. Bare title with one-clause "why it matters" fails this column.
- **Bookkeeping-displaced** (rule 2c) — the skill's Output format chat trailer carries no disposition matrix, no cross-iteration finding-ID continuity, no verdict-ratchet language. Bookkeeping content lives in the persisted file's history section.
- **Handoff-carries-payload** (rule 5a) — the skill's Output format chat trailer's `### Recommended next Cohesive skill` clause names the concrete inputs the next skill operates on (files for rewrite-specs, scope for review-codebase / review-diff / audit-substrate, design question for brainstorm-design). Bare skill name + reason without payload fails this column.

| Skill | Shows-not-names (2b) | Bookkeeping-displaced (2c) | Handoff-carries-payload (5a) |
|---|:-:|:-:|:-:|
| review-codebase | ✓ | ✓ | ✓ |
| review-diff | ✓ | ✓ | ✓ |
| validate-rewrite | ✓ | ✓ | ✓ |
| audit-substrate | ✓ | ✓ | ✓ |
| discover-substrate | ✓ | ✓ | ✓ |

The cells reflect the state *after* the 2026-05-06 output-substance-tightening rewrite (per `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-06-output-substance-tightening.md`). Pre-rewrite, all five skills failed Shows-not-names (Output format templates rendered top findings as title + one-clause why with no Evidence column or change column) and Handoff-carries-payload (the `### Recommended next Cohesive skill` convention was bare skill name + one-clause reason, with no payload-naming requirement). `review-codebase` additionally failed Bookkeeping-displaced for iterative reviews — its synthesis rendered promote/defer disposition tables and cross-iteration finding-ID references in chat. The rewrite swept the Output format render templates of all five skills to require the show-shape per finding and the payload per handoff, and explicitly forbids disposition-matrix rendering in chat.

The rule-grounding for each column lives in the voice guide; this matrix is the per-skill compliance surface a reviewer reads before flagging a regression. Drift in any cell is a substrate-alignment finding tracked here; the persisted file's `## History` section records the regression event and the recovery commit.

### Per-skill show-shape variations accepted

The Shows-not-names column tests for the substance contract — every chat finding or top-fix carries a title, concrete evidence, and the specific change (or artifact-content sketch) that closes it. The *field layout* expressing those three elements is allowed to differ across skills, by design:

- `review-codebase` and `review-diff` render finding-shape with **Evidence** + **Change** (two labeled fields under each H3 finding title, or two columns in a Findings table).
- `audit-substrate` renders artifact-addition-shape with **Evidence the gap exists** + **What the artifact would say** + **Where it lives** (three labeled fields, because the addition is a future artifact, not an edit to an existing one — the reader needs the path and the content sketch in addition to the gap evidence).
- `discover-substrate` renders missing-memory items as inlined bullets carrying the same three elements compressed onto one line: `**name** — path:line — excerpt + artifact-shape that would close it`.
- `validate-rewrite` renders the canonical six-field finding shape verbatim per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md` §"Output format conventions" (Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact to add or update); show-shape is a strict subset of this six-field shape.

The variation is intentional: each skill's chat output kind determines its field layout (findings → title + Evidence + Change; artifact-additions → title + Evidence + Sketch + Path; inlined missing-memory → one-line compression). The contract the matrix tests is "title + concrete evidence + the-thing-that-closes-it appear together," not "the four labeled fields appear in this exact form." A reviewer flagging a per-skill render as non-compliant for using a different field layout (rather than for missing the substance contract) is over-applying the matrix; the test is substance-presence, not layout-uniformity.

### Why no validator grep here

A grep for the failure modes is hard. "Output format template renders Top findings as title + one-clause why" is testable against the SKILL.md file directly (count Evidence references inside the Output format code block). But "the model produces a chat finding without an Evidence line" is testable only against captured chat — not against any file in the repo. The SKILL.md grep would catch render-template drift; it would not catch the model-to-render gap. As of v0.1, no captured-render lint ships; reviewer-output-shape matrix review is the enforcement, and `cohesive:review-codebase` of the skill pack itself is the periodic check. Promotion to grep enforcement is gated on a captured chat regression and a worked transcript, mirroring the criteria in `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` §"Why the voice imperative is convention-with-grep, not a named invariant."

## Rules

- The canonical six fields are mandatory in every reviewer agent's "How to structure your output" section, in the order shown above.
- When adding a new reviewer agent, copy the output-format block from `docs/substrate/conventions/reviewer-agent-shape.md` §"Output format conventions" verbatim. Do not invent new fields.
- When adding a new field (e.g., "Confidence" in some V1 setting), update this matrix and all five agent files in the same pass — partial drift breaks synthesis.
- `review-codebase` Phase 4, `review-diff`, and `validate-rewrite` synthesis can assume canonical shape from any reviewer agent dispatched. If a finding arrives in a different shape, that's a regression to be filed against this matrix.

## Severity vocabulary (also canonical)

For the Severity field, every agent uses one of:

- **Blocker** — would produce a defect or already has; substrate must be repaired before further work.
- **High** — high-leverage substrate gap; not yet a defect, but a predictable source of future defects.
- **Medium** — substrate improvement worth making in the next pass.
- **Low** — taste-level observation; useful context but not actionable on its own.

Per `references/cohesion-rubric.md`, agents do not mark every finding Blocker. If everything is Blocker, prioritization is failing.

## Removed cells

| Agent | Removed on | Reason |
|---|---|---|
| _none yet_ | | |

## Out of scope

- The agent's *internal* analysis structure (the "How to scope your reading" section, the "What you check" section). Different agents have different lenses; only the *output* must be uniform.
- The dispatch protocol shape (claimed-system-shape, normative-doc paths, scope, discovery report). That's defined in `docs/substrate/conventions/dispatch-protocol.md`.
- The canonical fresh-eyes preamble bullet. That's a convention in `docs/substrate/conventions/reviewer-agent-shape.md`; not a finding-shape concern.

## Notes

- The matrix has two sections: per-agent finding shape (5 rows × 8 columns) and per-synthesizing-skill chat render shape (5 rows × 3 columns). Both exist for the same reason every behavior matrix does: branchy agreement between independent files needs a single normative grid that a contributor can read at a glance.
- If agent count grows beyond ~8, consider grouping into review families (substrate-side / structure-side / quality-side) and producing per-family sub-matrices.
- If synthesizing-skill count grows (e.g., a future per-domain review skill), add the row at synthesis time. The three columns above should not need to expand — they cover the substance contract end-to-end.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md` §"Output format conventions" — the canonical agent-finding shape definition.
- `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rules 2b, 2c, 5a — the canonical chat-render shape definitions for the synthesizing-skill section.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/naming-instead-of-showing.md` — the failure mode this matrix's synthesizing-skill section structurally prevents.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/dispatch-protocol.md` — dispatch protocol the synthesizer relies on.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/fresh-eyes-review.md` — the load-bearing property the dispatch protocol enforces.
- `${CLAUDE_PLUGIN_ROOT}/skills/review-codebase/SKILL.md`, `${CLAUDE_PLUGIN_ROOT}/skills/review-diff/SKILL.md`, `${CLAUDE_PLUGIN_ROOT}/skills/audit-substrate/SKILL.md`, `${CLAUDE_PLUGIN_ROOT}/skills/discover-substrate/SKILL.md`, `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` — the five synthesizing skills tracked in §"Synthesizing-skill chat render shape."

## History

- 2026-05-04 — Created during the skill-architecture repair pass. Promoted from drift identified in `docs/history/reviews/2026-05-04-skill-architecture-review.md` Finding #9 to a tracked behavior matrix.
- 2026-05-04 — `cut-anchor-pin` substrate rewrite: added the "Voice citation" column tracking the new convention pin (each agent's output block opens with the voice citation line). Cells initially shipped as `pending` and were flipped to `✓` in the same branch's implementation pass. Cross-referenced `VERDICT_BEFORE_EVIDENCE` as the named invariant covering the synthesizing-skill side, which is out of scope for this matrix.
- 2026-05-04 — Polish pass (post review-diff): legend simplified to `✓` / `✗` (steady-state values only). The transient `pending` value used during the substrate-side rewrite has been removed since no cells are pending in a clean release; if a future rewrite needs to ship substrate ahead of implementation again, re-introduce `pending` in the same commit that uses it.
- 2026-05-06 — `output-substance-tightening` rewrite: added the §"Synthesizing-skill chat render shape" section with three columns (Shows-not-names / Bookkeeping-displaced / Handoff-carries-payload). Pre-rewrite, the synthesizing-skill side of the contract was prose-only in `references/output-voice.md` rule 2 ("faithful subset"); the rewrite split rule 2 into 2a/2b/2c, added rule 5a for handoff payload, and tracks per-skill compliance here. Pre-rewrite cells would have been ✗ across the board for Shows-not-names and Handoff-carries-payload; the Output format render templates of all five skills were swept in the same rewrite to flip the cells to ✓.
