# Design Delta Ledger — Output substance tightening

**Date:** 2026-05-06
**Worktree / branch:** `.worktrees/cohesive-output-substance-tightening` on `design/output-substance-tightening`
**Approved direction:** Tighten output substance across the synthesizing skills so per-finding chat shape is `title + Evidence + Change` and recommended-next-skill clauses carry concrete payload (files, scope, or design question), with bookkeeping (cross-iteration finding-IDs, disposition matrices, verdict-ratchet language) displaced from chat to the persisted file's `## History` section. Origin: user feedback on the iteration-2 architecture review of the skill pack itself, captured in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/naming-instead-of-showing.md` §"When this was discovered."

This rewrite is **Pure implementation** per `${CLAUDE_PLUGIN_ROOT}/skills/rewrite-specs/SKILL.md` Step 1a. It tightens the substance contract for chat-rendered output across five synthesizing skills and the convention/voice surfaces that govern them. No skill purpose, ownership, seam, verdict vocabulary, or chain transition changes; the design layer (`${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md` and `handoffs.md`) is untouched. Implementation changes: rule sharpening in `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`, render-template updates in five SKILL.md Output format blocks, a new gotcha doc, and matrix extension tracking the per-skill compliance the rewrite establishes.

## Delta at a glance

- **Files:** 9 rewritten, 1 added, 0 removed/deprecated
- **Conceptual changes:** rule 2 split into 2a (faithful subset) / 2b (findings shown not named) / 2c (bookkeeping displaced); rule 5 sharpened with sub-rule 5a (handoff carries payload); chat-render contract is "substance, not bookkeeping" rather than "faithful subset"; per-finding chat shape unified across review-codebase, review-diff, audit-substrate, discover-substrate, validate-rewrite as `title + Evidence + Change` (or its skill-specific analog for audit-substrate's artifact-additions); recommended-next-skill clauses carry payload by next-skill kind (files for rewrite-specs, design question for brainstorm-design, scope for review/audit, scope for superpowers handoffs); persisted-file `## History` section is the canonical home for cross-iteration audit content
- **Named invariants:** none
- **Behavior matrices:** `reviewer-output-shape` (extended — added §"Synthesizing-skill chat render shape" with three columns: Shows-not-names / Bookkeeping-displaced / Handoff-carries-payload, tracking five synthesizing skills)
- **Gotchas:** `naming-instead-of-showing` (added — captures audit-log-shape and empty-handoff failure modes); `wordy-output` (cross-reference to the new sibling gotcha added)
- **Semantic linters:** none (a render-template/chat-render diff lint is named as a future candidate but not specified or shipped this rewrite — the criterion for promotion mirrors the voice-imperative criterion)
- **Tests proposed:** none (no executable tests; reviewer-output-shape matrix review is the enforcement surface)
- **Deferred (out of scope this pass):** `cohesively` router's announcement template (the router is voice-exempt and renders 1–2 sentences only — substance rules apply to its dispatched subskills, not to the router itself); `brainstorm-design` Output format (option-shape rather than finding-shape; the show-shape rule applies but the existing Option A/B/C structure already requires Substrate / Locality / Future fit fields, which is its show-shape — no edits needed this pass)

## Files rewritten

- `references/output-voice.md`
  - **Before:** Five rules; rule 2 was "faithful subset" with three test fields (verdict matches; chat claims appear in persisted file; chat introduces no novel facts); rule 5 was "recommend exactly one next move," cardinality only.
  - **After:** Five rules; rule 2 is "the chat render is substance, not bookkeeping" with three sub-rules (2a faithful subset — original tests preserved as a strict subset; 2b findings shown not named — title + Evidence + Change minimum; 2c bookkeeping displaced — disposition matrices, finding-ID continuity, verdict-ratchet language belong in persisted file); rule 5 is "recommend exactly one next move, and carry the payload it needs" with sub-rule 5a (handoff payload by next-skill kind: files / scope / design question). Faithful-subset test set extends with two new tests (d) and (e). Do/Don't table extended with three new rows (show-don't-name; payload; bookkeeping-displaced). Forbidden phrasings extended with three new entries (bare finding-ID references; verdict-ratchet language; handoffs without payload). Density-budget prose adds: substance and density are independent failure modes.
  - **Reason:** The user's iteration-2 review chat trailer satisfied the original rule 2 ("every chat claim appears in the persisted file") while still failing the substance test the user actually cared about ("can a fresh chat reader name the defect and the fix?"). The faithful-subset test was load-bearing but underspecified for substance. The split into 2a/2b/2c keeps the original rule intact and adds the substance and bookkeeping rules as independently-testable sub-rules.

- `skills/review-codebase/SKILL.md`
  - **Before:** Output format Top findings rendered as a numbered list of `<title> — <one-clause why>`. Recommended next Cohesive skill rendered per-verdict as `cohesive:<skill> — <one-clause reason>` with no payload field. Phase 4 synthesis listed seven sections without distinguishing chat-rendered from persisted-only.
  - **After:** Output format Top findings render as three H3 blocks per finding, each carrying title + **Evidence** (file:line + excerpt or named artifact) + **Change** (the specific edit). Recommended next Cohesive skill renders per-verdict with a `**Files to edit:**` / `**Design question:**` / `**Scope:**` payload field per verdict-branch. Phase 4 synthesis splits into chat-rendered (TL;DR with show-shape findings + payload-bearing handoff) and persisted-only (cohesion scorecard, substrate improvements, phased roadmap, History section for iterative reviews). Output discipline section gains four new bullets (show-don't-name, bookkeeping-persists, handoff-payload, plus the existing concrete-references). Red flags gain four new entries.
  - **Reason:** This skill is the most acute offender — the iteration-2 chat trailer that triggered the rewrite was its own output. The render-template change is what flips the per-skill compliance cells in the matrix's synthesizing-skill section to ✓.

- `skills/review-diff/SKILL.md`
  - **Before:** Findings table had four columns: Severity / Area / Finding / Suggested substrate. The Finding column was free-text; no Evidence or Change column. Recommended next Cohesive skill rendered per-verdict with no payload.
  - **After:** Findings table has five columns: Severity / Area / Finding (with file:line + excerpt) / Change / Suggested substrate. Recommended next Cohesive skill renders per-verdict with a `**Scope:**` / `**Files to edit:**` / `**Design question:**` payload field. Output format prose calls out the new column requirements; Output discipline section gains three new bullets (shows-not-names, handoff-payload, no-bookkeeping-in-chat); Red flags gain two new entries.
  - **Reason:** Diff review's chat trailer is its only output (no persisted file by default), so substance discipline is even more critical than for codebase review. The Findings-table column extension is the structural fix; the Change column is what makes the table actionable rather than diagnostic-only.

- `skills/audit-substrate/SKILL.md`
  - **Before:** Top fixes rendered as a numbered list of `<substrate artifact to add; one-clause justification>`. Recommended next Cohesive skill named `cohesive:rewrite-specs` with a one-clause reason and no enumeration of artifact paths.
  - **After:** Top fixes render as three H3 blocks per fix, each carrying title (artifact name) + **Evidence the gap exists** (file:line or named pattern) + **What the artifact would say** (2-3 sentence sketch) + **Where it lives** (path). Recommended next Cohesive skill names rewrite-specs with `**Files to add:**` payload enumerating the artifact paths, plus a slug. Red flags gain two new entries.
  - **Reason:** The audit's top fixes are artifact-additions rather than findings, so the show-shape is title + Evidence + Sketch + Path rather than title + Evidence + Change. Same substance contract, different per-skill shape; matrix's "Shows-not-names" cell now reads as "every top item carries the show-shape appropriate to its kind."

- `skills/discover-substrate/SKILL.md`
  - **Before:** Missing memory section rendered as a numbered list of `<highest-leverage gap first>` with no shape requirement; cross-iteration finding-ID family references were a known offender pattern. Recommended next Cohesive skill named the skill plus a reason; no payload field.
  - **After:** Missing memory items each carry **bold concrete-gap-name** + `<path>:<line>` + quoted excerpt + the artifact-shape that would close it. Cross-iteration references are explicitly forbidden in the template (with a parenthetical pointer to the new gotcha). Recommended next Cohesive skill renders with a `**Payload:**` field naming the change surface / design question / audit scope. Acceptance criteria add two new bullets; Red flags add two new entries.
  - **Reason:** Discover-substrate's Missing memory section is what feeds downstream skills (review-codebase, brainstorm-design, audit-substrate) with the gap inventory. If the gap inventory is bookkeeping-shaped, every downstream skill inherits the failure mode. Tightening discover-substrate is the upstream fix.

- `skills/validate-rewrite/SKILL.md`
  - **Before:** Output format prose said "the agent's report, surfaced" without explicit substance-discipline language. Findings already used canonical six-field shape (Severity / Category / Why / Evidence / Recommended fix / Substrate artifact), which is show-shape by construction; no per-finding edits needed. Red flags listed nine items, none addressing cross-pass bookkeeping creep.
  - **After:** Output format prose declares the chat output is substance-not-bookkeeping per rules 2a/2b/2c; explains the persisted file is canonical and carries the cross-pass audit trail; reaffirms the six-field shape as already-show-shape; names the failure mode to guard against (cross-pass bookkeeping creep — finding-ID continuity between passes, "the prior pass's deferred items" annotations, verdict-ratchet language). Red flags add one new entry naming cross-pass bookkeeping in chat as a violation of rule 2c.
  - **Reason:** Validate-rewrite is fairly disciplined already (six-field findings, well-defined disposition phrase, conditional implementation matrix). The risk during the multi-pass repair loop is that pass-N's chat rendering picks up cross-pass continuity from the loop's conversation context — which the fresh-eyes architecture prevents structurally inside the dispatched agent, but could leak into the synthesizing skill's prose around the agent's report. Explicit prose closes the gap before it opens.

- `docs/substrate/conventions/skill-shape.md`
  - **Before:** §"Output format conventions" rule 3 was titled "The chat render is a faithful subset of the persisted file" and showed a render template with `## Top findings` numbered list of `<title> — <one clause>`. The Recommended-next-skill footer convention rendered as `cohesive:<skill-name> — <reason>` with no payload field. Anti-patterns table did not name the show-shape failure or the empty-handoff failure.
  - **After:** §"Output format conventions" rule 3 is titled "The chat render is substance, not bookkeeping" and shows a render template with `## Top findings` as three H3 blocks, each with Evidence + Change. Cites the new sub-rules 2a/2b/2c and 5a in the voice guide. The Recommended-next-skill footer convention shows a payload field with payload-kind labels by next-skill kind (Files to edit / Design question / Scope). Anti-patterns table gains four new rows (top-findings-without-Evidence-and-Change; recommended-next-bare; cross-iteration-finding-IDs; promote-defer-disposition-matrix).
  - **Reason:** This convention doc is the canonical SKILL.md shape spec, and the canonical chat-render template lives here. New skill authors copy from this doc; if the template renders title-only findings, new skills inherit the failure. The render-template update is the upstream fix that makes future skills compliant by default.

- `docs/substrate/matrices/reviewer-output-shape.md`
  - **Before:** §"Purpose" tracked only per-agent finding-shape compliance (5 agents × 8 fields). The matrix had a single section "Cells" with one table.
  - **After:** §"Purpose" describes the two-layer contract (per-agent finding shape + per-synthesizing-skill chat render shape). The matrix has two sections: §"Per-agent finding shape" (the original 5 agents × 8 fields, unchanged) and §"Synthesizing-skill chat render shape" (new — 5 skills × 3 columns: Shows-not-names / Bookkeeping-displaced / Handoff-carries-payload). Notes section calls out the two-layer structure; Related substrate gains pointers to the voice guide rules and the new gotcha; History section gains a 2026-05-06 entry.
  - **Reason:** The synthesizing-skill side of the contract was prose-only in the voice guide pre-rewrite. The matrix is where reviewers check per-skill compliance at a glance; without a row-level grid, drift in any one skill's Output format block is hard to catch during review. The new section is the per-skill compliance surface.

- `references/templates/architecture-review-report.md`
  - **Before:** Opened with a `> Output starts with the TL;DR block per skill-shape.md §"TL;DR convention"` blockquote. No History section.
  - **After:** Opening blockquote cites `skill-shape.md` §"Output format conventions" rule 3 (the renamed/updated section), declares show-shape required for top findings and payload required for next-step, and explicitly directs bookkeeping (finding-ID continuity, disposition matrices, verdict trajectory) to the new §"History" section. New §"History" section appended with sub-sections: Predecessor (review path, verdict, finding count); Disposition of predecessor findings (table mapping finding ID to current pass disposition + closing artifact); Verdict trajectory (per-pass verdict + observation table); New findings introduced this pass (anchor list pointing to the §"Highest-leverage findings" section); Notes for the next iteration.
  - **Reason:** The persisted file IS the canonical home for cross-iteration audit content per rule 2c. Pre-rewrite, the template had no §"History" section, so iterative reviews had no canonical place to record disposition — and the bookkeeping leaked into chat by default. The new §"History" gives the bookkeeping a home.

- `docs/substrate/gotchas/wordy-output.md`
  - **Before:** Notes-for-future-contributors section had four bullets covering rule-promotion, density-budget, and chain-question patterns.
  - **After:** Same four bullets plus a fifth bullet declaring this gotcha and `naming-instead-of-showing.md` siblings with explicit non-overlap (ceremony vs substance; renders can fail one without the other).
  - **Reason:** Two adjacent gotchas with similar-sounding names risk being conflated. Explicit sibling cross-reference in both directions (the new gotcha already cross-references this one; this update closes the back-link) prevents the next contributor from collapsing them or treating one as superseded.

## Files added

- `docs/substrate/gotchas/naming-instead-of-showing.md` — new gotcha capturing the audit-log-shape and empty-handoff failure modes. Symptom section quotes the user's 2026-05-06 feedback verbatim. Why-it-happened names four contributing factors (title-only findings render shape, bare next-skill-footer convention, presence-only faithful-subset test, no rule about which content goes where). Tempting-wrong-fix section rules out three near-misses. Correct-pattern section names three layers: voice-guide rule split, per-skill render template updates, matrix-tracking. Promotion to grep enforcement is gated on a captured chat regression and a worked transcript, mirroring the voice-imperative promotion criteria.

## Files removed or deprecated

none

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| Voice rule 2 ("the chat render is a faithful subset of the persisted file") | Voice rule 2 ("the chat render is substance, not bookkeeping") with sub-rules 2a (faithful subset, original test preserved) / 2b (shown not named) / 2c (bookkeeping displaced) | Tightened |
| Voice rule 5 ("recommend exactly one next move") | Voice rule 5 ("recommend exactly one next move, and carry the payload it needs") with sub-rule 5a (handoff payload by next-skill kind) | Tightened |
| Per-finding chat render: `<title> — <one-clause why>` | Per-finding chat render: H3 block carrying title + **Evidence** + **Change** | Replaced |
| Recommended-next-skill footer: `cohesive:<skill> — <reason>` | Recommended-next-skill footer: `cohesive:<skill> — <reason>. **<Payload-kind>:** <concrete payload>.` | Replaced |
| reviewer-output-shape matrix tracks per-agent finding-shape only | reviewer-output-shape matrix tracks per-agent finding-shape AND per-synthesizing-skill chat render shape | Extended |
| Persisted review template carries no §"History" section | Persisted review template carries §"History" with Predecessor / Disposition / Verdict trajectory / New findings / Notes-for-next-iteration sub-sections | Added |

## New or updated substrate

### Specs

- `references/output-voice.md` — rule 2 is now "the chat render is substance, not bookkeeping" with three sub-rules (2a/2b/2c) and an extended faithful-subset test set; rule 5 grows sub-rule 5a (handoff payload); Do/Don't and Forbidden phrasings tables extend with substance-failure entries; density-budget prose declares density and substance are independent failure modes.

- `docs/substrate/conventions/skill-shape.md` — §"Output format conventions" rule 3 renamed and updated; canonical chat-render template now requires Evidence + Change per finding and payload per recommended-next; recommended-next-skill footer subsection adds payload-kind label by next-skill kind; Anti-patterns table extended with four substance-failure rows.

- `references/templates/architecture-review-report.md` — opening blockquote updated to cite the new rule 3 and to direct bookkeeping into §"History"; new §"History" section appended for iterative reviews.

### Behavior matrices

- `docs/substrate/matrices/reviewer-output-shape.md` — extended with new §"Synthesizing-skill chat render shape" (5 skills × 3 columns: Shows-not-names / Bookkeeping-displaced / Handoff-carries-payload). All cells render as ✓ post-rewrite (the Output format updates above are what flips them to ✓; pre-rewrite they would have been ✗ on Shows-not-names and Handoff-carries-payload across the board, ✗ on Bookkeeping-displaced for review-codebase only). Header `Last reviewed` date updated to 2026-05-06; History gains 2026-05-06 entry.

### Named invariants

none — rule 2b/2c/5a remain conventions enforced at the render-template surface and reviewer-output-shape matrix surface; promotion to grep enforcement is gated on captured chat regression and a worked transcript per the criteria in `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` §"Why the voice imperative is convention-with-grep, not a named invariant."

### Gotchas

- `docs/substrate/gotchas/naming-instead-of-showing.md` — added; canonical home of the substance scar this rewrite addresses. Sibling cross-references with `wordy-output.md` (ceremony scar).
- `docs/substrate/gotchas/wordy-output.md` — Notes-for-future-contributors section gains a fifth bullet declaring sibling-not-duplicate relationship with `naming-instead-of-showing.md`.

### Semantic linter specs

- **Render-template/captured-chat diff lint** (proposed, not specified or shipped). Would diff a captured chat render against the source SKILL.md's Output format template and flag chat findings whose substance is absent from the persisted file's findings section. Promotion criteria mirror the voice-imperative criteria: wording stability across two release cycles + a captured regression + a worked transcript demonstrating the lint catches the right shape. Until then, reviewer-output-shape matrix review is the enforcement.

### Tests / checks proposed (not yet implemented)

none — no executable test substrate is added in this rewrite. The substance contract is enforced by render-template surface and matrix-review surface; the candidate diff lint above is named but not specified.

## What this rewrite *did not* do

- Implementation code: not changed.
- Tests: none proposed (the substance contract is structurally enforced at the render-template surface; reviewer-output-shape matrix review is the runtime enforcement).
- CI: not changed. `scripts/validate_plugin.sh` is unchanged — no new checks ship; `expected_skills` array unchanged at 10.
- Skill-section-presence matrix: unchanged. No skill sections were added or removed; only Output format and Red flags content was tightened within existing sections.
- Brainstorm-design Output format: deliberately untouched. Brainstorm-design renders option recommendations rather than findings; the show-shape rule applies, but the existing Option A/B/C structure (Summary / Substrate changes / Locality / Future fit / Initial risks) is already its show-shape — option recommendations are shown, not named, by the existing template.
- Cohesively router announcement: untouched. The router is voice-exempt (render budget too small to need the imperative); substance rules apply to the dispatched subskills.
- Implement-cohesively Output format: untouched. Its phase-loop output is sufficiently disciplined by the existing IMPLEMENTATION_PLAN_COVERS_DELTA invariant and per-phase delta-coverage review.
- Promotion of any of 2b/2c/5a to a named invariant: deliberately deferred. Wording is fresh; the promotion criteria (stability + captured regression + worked transcript) are not yet met. Until then, the rules live as convention enforced at the render-template and matrix surfaces.

## Remaining ambiguity

- **Audit-trail-section name in persisted files**: the new §"History" section in `architecture-review-report.md` is one canonical name; `validate-rewrite`'s repair-pass review template uses the existing `## Repair pass <N>` shape rather than `## History`. Both are dated, append-only audit-trail content but the section names differ. Unifying to a single name across all persisted Cohesive artifacts is deferred — the failure mode is small (a reader looking for history might check the wrong heading) and the cost of unifying is real (forces a coordinated rewrite of cohesion-review.md template and the validate-rewrite pass-N convention). Re-evaluate when adding the next persisted-output skill.
- **Discover-substrate Missing memory item shape vs. audit-substrate Top fixes shape**: discover-substrate items render as `**name** — path:line — excerpt + artifact-shape that would close it`; audit-substrate top fixes render as four labeled fields (title + Evidence + Sketch + Path). Both are show-shape compliant, but the formats differ. The user reading both side-by-side might find the inconsistency mildly disorienting. Unifying to one shape would force one of them to migrate; deferred until a captured user-experience report names the inconsistency as load-bearing.
- **Brainstorm-design's option-shape vs. the synthesizing-skills' finding-shape**: brainstorm-design renders option blocks (Summary / Substrate changes / Locality / Future fit / Initial risks). The substance contract is met by the existing template, but the matrix doesn't track brainstorm-design under the Synthesizing-skill shape because brainstorm renders options rather than findings. Whether to extend the matrix with a brainstorm-specific row, generalize the matrix's column meaning, or leave brainstorm out is deferred pending the next brainstorm-design rewrite.
- **Validator grep for synthesizing-skill substance**: a grep that lints SKILL.md Output format blocks for "Top findings" sections that lack `Evidence` and `Change` substrings is feasible (the SKILL.md is text), unlike the captured-chat diff lint. But the rendering surface is the model's output, not the SKILL.md, so the grep would catch render-template drift but miss the model-to-output gap. A SKILL.md-level grep is named as a future candidate (Check 13e or similar) and deferred until a captured render-template regression earns it.

## Ready for fresh-eyes review?

**Yes.** The rewrite is internally consistent — every chat-render rule references back to the voice guide; every Output format change matches a matrix cell flip; every substrate addition has a corresponding gotcha or matrix entry. The five SKILL.md Output format blocks all carry the show-shape and payload-bearing handoff; the convention doc (`skill-shape.md`) carries the same canonical template that the per-skill blocks instantiate; the matrix tracks per-skill compliance; the gotcha records the failure mode and the correct pattern. Validator passes (no expected-count or schema changes; no PLUGIN_ROOT_PATHS violations introduced).

## How to read this ledger

1. **Approved direction** names the destination: tighten output substance with show-shape and payload-bearing handoffs; displace bookkeeping to the persisted file.
2. **Delta at a glance** is the 8–15 line scan: 9 files rewritten, 1 added, 0 removed; rule 2 split, rule 5 sharpened; matrix extended; new gotcha; no new invariants or tests; deferred items named.
3. **Conceptual changes** lists the six concept shifts (rule 2 split, rule 5 sub-rule, per-finding shape, next-skill-footer shape, matrix extension, History section).
4. **Files rewritten** carries before/after for each of 9 files. The two highest-leverage entries are `references/output-voice.md` (the contract) and `skills/review-codebase/SKILL.md` (the most acute offender, the skill whose chat trailer triggered the rewrite).
5. **Remaining ambiguity** flags four items deferred to future passes (history-section-name unification, missing-memory vs top-fixes shape unification, brainstorm-design matrix coverage, SKILL.md grep). None block validation.

## Repair pass 2

**Source review:** `docs/history/reviews/2026-05-06-output-substance-tightening-rewrite-validation.md` (pass 1, Issues Found, 1 Blocker + 2 Mediums + 2 Lows)
**Disposition picked from rubric:** Close in same worktree → merge.

Closes findings B1, I1, I2, I3, I4 from the pass-1 review. Per `${CLAUDE_PLUGIN_ROOT}/skills/rewrite-specs/SKILL.md` Step 1b, the repair scope is the enumerated repairs in the cited review; the chosen direction is unchanged.

### B1 — closed

`skills/audit-substrate/SKILL.md` line 124 (Output format opening prose) and line 160 (Persisted-report pointer in chat render template) updated from `<slug>-substrate-audit.md` to `<slug>-audit-substrate.md`. The skill body now uses the same form throughout (lines 10, 118, 124, 160). Sibling references in `docs/history/delta-ledgers/2026-05-04-skill-rename-v0.1-lexicon.md` and `docs/history/delta-ledgers/2026-05-04-substrate-collapse.md` are untouched — those are append-only history files recording past state, not normative substrate.

### I1 — closed

`docs/substrate/matrices/reviewer-output-shape.md` gains a §"Per-skill show-shape variations accepted" subsection (between the synthesizing-skill table and §"Why no validator grep here"). The subsection enumerates the four skill-specific layouts (review-codebase + review-diff: title + Evidence + Change; audit-substrate: title + Evidence the gap exists + What the artifact would say + Where it lives; discover-substrate: inlined one-line compression; validate-rewrite: canonical six-field shape per reviewer-agent-shape.md) and declares the matrix tests substance-presence not layout-uniformity. The deferral that lived only in the ledger's "Remaining ambiguity" §2 now lives as substrate.

### I2 — closed

`references/output-voice.md` §"Density budgets (guideline, not invariant)" table updated — `review-diff`, `review-codebase`, `validate-rewrite`, and `audit-substrate` rows now describe the show-shape budgets (e.g., `review-codebase`: "TL;DR (verdict + thesis + 3 show-shape findings + payload-bearing handoff); full body in the persisted file"; `validate-rewrite`: "½–¾ page" rather than "~½ page"). New trailing paragraph clarifies the budgets reflect show-shape minimums, not targets — a render shorter than the budget that achieves substance is fine; a render longer with bookkeeping is the rule 2c failure.

### I3 — closed

`references/templates/architecture-review-report.md` §"History" subsections renamed and reshaped:
- `### Predecessor` (singular, one bullet) → `### Predecessors` (plural, one bullet per prior pass).
- `### Disposition of predecessor findings` → `### Disposition of prior findings`. The table grows an "Origin" column (Pass N) so a reader of pass-4 sees how each finding closed across passes 1→2→3 in one table.

### I4 — closed

`references/output-voice.md` §"How this guide is used" — the "At review time" bullet now points readers at `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` §"Synthesizing-skill chat render shape" as the per-skill compliance check; reviewers check the matrix's Shows-not-names / Bookkeeping-displaced / Handoff-carries-payload columns before flagging a regression.

### Files touched in pass 2

- `skills/audit-substrate/SKILL.md` (B1)
- `docs/substrate/matrices/reviewer-output-shape.md` (I1)
- `references/output-voice.md` (I2 + I4)
- `references/templates/architecture-review-report.md` (I3)
- `docs/history/delta-ledgers/2026-05-06-output-substance-tightening.md` (this section)
- `docs/history/reviews/2026-05-06-output-substance-tightening-rewrite-validation.md` (pass-1 persisted review, committed separately by `validate-rewrite` Step 3)

### Remaining ambiguity after pass 2

Item 1 (history-section-name unification across `architecture-review-report.md` and `validate-rewrite`'s pass-N file pattern) and Item 2 (discover-substrate Missing-memory shape vs audit-substrate Top-fixes shape unification — note: pass-1 finding I1 partially resolved this by adding a substrate-level note that the variation is intentional; the harder question of whether to converge them is still deferred) remain. Item 3 (brainstorm-design matrix coverage) and Item 4 (SKILL.md-level grep) remain unchanged. The pass-1 review surfaced no new ambiguities beyond what the forward rewrite recorded.
