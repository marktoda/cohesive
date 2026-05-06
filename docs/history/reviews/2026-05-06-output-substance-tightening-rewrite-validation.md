# Rewrite Validation Review — output substance tightening

**Verdict:** Issues Found

## Executive judgment

The rewrite delivers what its ledger promises: rule 2 split into 2a/2b/2c, rule 5 grown by 5a, five SKILL.md Output format blocks swept to require show-shape and payload-bearing handoffs, a new `naming-instead-of-showing` gotcha that records the failure mode and cross-references its `wordy-output` sibling, and a per-synthesizing-skill compliance section in `reviewer-output-shape.md`. The voice guide, convention doc, matrix, and gotcha tell a coherent story; a fresh contributor can read just `references/output-voice.md` rule 2 and `docs/substrate/conventions/skill-shape.md` rule 3 and reproduce the show-shape from memory. The architecture-review-report template gains a clean `## History` section that gives bookkeeping a canonical home. Pure-implementation classification (lenses 12-14 skipped) is correct: the design layer is untouched. One internal contradiction in `skills/audit-substrate/SKILL.md` is a Blocker — the Output format renders a different filename than the rest of the skill body, which would produce inconsistent persisted-file paths in production. The rewrite is otherwise merge-ready once that single fix lands.

## Delta at a glance

> - **Files:** 9 rewritten, 1 added, 0 removed/deprecated
> - **Conceptual changes:** rule 2 split into 2a (faithful subset) / 2b (findings shown not named) / 2c (bookkeeping displaced); rule 5 sharpened with sub-rule 5a (handoff carries payload); chat-render contract is "substance, not bookkeeping" rather than "faithful subset"; per-finding chat shape unified across review-codebase, review-diff, audit-substrate, discover-substrate, validate-rewrite as `title + Evidence + Change` (or its skill-specific analog for audit-substrate's artifact-additions); recommended-next-skill clauses carry payload by next-skill kind (files for rewrite-specs, design question for brainstorm-design, scope for review/audit, scope for superpowers handoffs); persisted-file `## History` section is the canonical home for cross-iteration audit content
> - **Named invariants:** none
> - **Behavior matrices:** `reviewer-output-shape` (extended — added §"Synthesizing-skill chat render shape" with three columns: Shows-not-names / Bookkeeping-displaced / Handoff-carries-payload, tracking five synthesizing skills)
> - **Gotchas:** `naming-instead-of-showing` (added — captures audit-log-shape and empty-handoff failure modes); `wordy-output` (cross-reference to the new sibling gotcha added)
> - **Semantic linters:** none (a render-template/chat-render diff lint is named as a future candidate but not specified or shipped this rewrite — the criterion for promotion mirrors the voice-imperative criterion)
> - **Tests proposed:** none (no executable tests; reviewer-output-shape matrix review is the enforcement surface)
> - **Deferred (out of scope this pass):** `cohesively` router's announcement template (the router is voice-exempt and renders 1–2 sentences only — substance rules apply to its dispatched subskills, not to the router itself); `brainstorm-design` Output format (option-shape rather than finding-shape; the show-shape rule applies but the existing Option A/B/C structure already requires Substrate / Locality / Future fit fields, which is its show-shape — no edits needed this pass)

## Blocking issues

### B1. Audit-substrate persisted-file path contradicts itself

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** A future reader following the skill body cannot tell whether the persisted file lands at `<slug>-audit-substrate.md` or `<slug>-substrate-audit.md`. Whichever the model picks at render time will diverge from the other surface, and downstream skills that expect to find the audit (e.g., re-audits reading prior history; the router's dispatch contract; any future grep) will look at the wrong path. The contradiction is internal to a single SKILL.md, so the fresh reader has no way to pick the right one.
- **Evidence:** `skills/audit-substrate/SKILL.md:10` and `:118` say `docs/history/reviews/YYYY-MM-DD-<slug>-audit-substrate.md`. `skills/audit-substrate/SKILL.md:124` says `docs/history/reviews/YYYY-MM-DD-<slug>-substrate-audit.md`, and `:160` (inside the chat render template) shows `docs/history/reviews/YYYY-MM-DD-<slug>-substrate-audit.md` as the persisted-report pointer the chat trailer renders.
- **Recommended fix:** Pick `<slug>-audit-substrate.md` (the form already used in §"What this skill produces" and the §"4. Persist" step — and consistent with the skill name `audit-substrate`) and replace lines 124 and 160. Audit any sibling references in the router matrix or handoffs.md (the ledger claims design-layer is untouched, but a router/matrix entry referencing `substrate-audit.md` would also need to flip).
- **Substrate artifact to add or update:** `skills/audit-substrate/SKILL.md` (lines 124 and 160). After the fix, consider a single canonical `### Persisted artifact` paragraph the Output format references, so the path appears once.

## Important issues

### I1. `discover-substrate` Missing-memory shape and `audit-substrate` Top-fixes shape diverge without a doc note

- **Severity:** Medium
- **Category:** Domain model
- **Why it matters:** Two adjacent synthesizing skills render show-shape items with different field structures. `discover-substrate` Missing-memory bullets are `**name** — path:line — excerpt + artifact-shape that would close it` (one-line, four fields inlined). `audit-substrate` Top-fixes are H3 blocks with four labeled fields (title + Evidence the gap exists + What the artifact would say + Where it lives). A reader who reads both side-by-side will look for the inconsistency and try to decide which is canonical; neither is wrong, but neither doc tells the reader the difference is intentional. The ledger's "Remaining ambiguity" §2 acknowledges this divergence as deferred, but the deferral lives only in the ledger — a fresh reader of the skills doesn't see it.
- **Evidence:** `skills/discover-substrate/SKILL.md:170-173` (Missing-memory bullet shape) versus `skills/audit-substrate/SKILL.md:135-157` (Top-fixes H3 block shape). `docs/history/delta-ledgers/2026-05-06-output-substance-tightening.md:136` ("Remaining ambiguity" §2) names this as deferred.
- **Recommended fix:** Add a one-line note to `docs/substrate/matrices/reviewer-output-shape.md` §"Synthesizing-skill chat render shape" Notes section saying the show-shape per skill is allowed to differ in field layout as long as title + evidence + the-thing-that-closes-it are all present. That preserves the deferral as substrate, not just ledger memory.
- **Substrate artifact to add or update:** `docs/substrate/matrices/reviewer-output-shape.md` §"Notes" or a new "Per-skill show-shape variations accepted" subsection.

### I2. Chat-output budget for verdict-led skills doesn't account for the new H3-block findings

- **Severity:** Medium
- **Category:** Vague language / Future-fit
- **Why it matters:** The voice guide's density-budget table (`references/output-voice.md:83-92`) was authored for the pre-rewrite render shape (numbered list of `<title> — <one-clause why>`). Three H3 blocks with Evidence and Change per finding is materially larger than three numbered-list lines. `review-codebase` budget says "TL;DR only; full body in the persisted file"; `validate-rewrite` budget says "Verdict + ledger-aligned findings; ~½ page." A render that satisfies rule 2b's show-shape will, at three findings, blow past "~½ page" easily — the budget and the new template are in soft tension. The budget is "guideline, not invariant," but a guideline that the canonical template structurally exceeds is misleading.
- **Evidence:** `references/output-voice.md:83-92` (density budgets, unchanged in this rewrite). `skills/review-codebase/SKILL.md:141-159` (three H3 blocks with two labeled fields each) versus `references/output-voice.md:90` ("Verdict + ledger-aligned findings; ~½ page"). The new §"Density and substance are independent failure modes" prose at line 100 acknowledges the tension but does not adjust the budget table.
- **Recommended fix:** Update the budget rows for `review-codebase`, `validate-rewrite`, and `audit-substrate` to reflect the show-shape minimum: e.g., "TL;DR + 3 show-shape findings (≈½–¾ page); persisted file canonical." Or add a one-line note under the table that the ½-page guideline assumes show-shape findings, not bare titles.
- **Substrate artifact to add or update:** `references/output-voice.md` §"Density budgets (guideline, not invariant)".

### I3. `architecture-review-report.md` History section uses `Predecessor` singular but iterative reviews can have N-deep chains

- **Severity:** Low
- **Category:** Domain model
- **Why it matters:** The new History section names a single `### Predecessor` (path/verdict/finding-count), then a `### Verdict trajectory` table that allows multiple passes. The Predecessor block is shaped for a 1-deep chain (review N references review N-1). On a 3rd or 4th iteration, the reader cares about all prior reviews, not just the immediate predecessor; the trajectory table partly covers this, but the Disposition-of-predecessor-findings table is still scoped to the immediate predecessor by name. A reader of pass-4 won't see how findings closed across passes 1→2→3.
- **Evidence:** `references/templates/architecture-review-report.md:141-152` (Predecessor + Disposition tables, both singular). `:154-158` (Verdict trajectory table, multi-pass).
- **Recommended fix:** Rename `### Predecessor` to `### Predecessors` (plural; one bullet per prior pass) and let the Disposition table either span all passes or scope to the immediate predecessor with a note that earlier-pass findings can be looked up via the chain. Validate-rewrite's per-pass review file pattern (`...-rewrite-validation-pass-N.md`) has the same multi-pass shape and could inform the convention; the ledger's "Remaining ambiguity" §1 already names history-section-name unification as deferred — this is a related sub-problem.
- **Substrate artifact to add or update:** `references/templates/architecture-review-report.md` §"History" subsections.

### I4. Voice guide's "How this guide is used" still describes the pre-rewrite test set

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** Section "How this guide is used" at lines 96-100 names review-diff and review-codebase as the review-time enforcement surfaces but doesn't mention the new `### Synthesizing-skill chat render shape` matrix section, which the rewrite establishes as the per-skill compliance surface. A future contributor reading just §"How this guide is used" won't know to check the matrix.
- **Evidence:** `references/output-voice.md:96-100` (How this guide is used) versus `docs/substrate/matrices/reviewer-output-shape.md:44-62` (the new section).
- **Recommended fix:** Add one bullet under "At review time": "`reviewer-output-shape.md` §'Synthesizing-skill chat render shape' tracks per-skill compliance with rules 2b, 2c, 5a; reviewers check the matrix before flagging a regression."
- **Substrate artifact to add or update:** `references/output-voice.md` §"How this guide is used".

## What looked right

- The rule 2 split into 2a/2b/2c is the architectural move that was needed. 2a preserves the original test set verbatim (so existing reviewer logic doesn't break); 2b and 2c are independently testable; the prose at `references/output-voice.md:100` ("density and substance are independent failure modes") names the failure mode crisply.
- The `naming-instead-of-showing.md` gotcha is the strongest piece of the rewrite. The Symptom section quotes the user's words, the Why-it-happened names four contributing factors with grounded evidence, and the Tempting-wrong-fix section rules out three concrete near-misses ("be more specific," dividers, two-block render). The sibling cross-reference to `wordy-output.md` (with the explicit non-overlap claim) closes the right confusion.
- Per-skill render templates are cleanly differentiated by what each skill produces: review-codebase renders findings (title + Evidence + Change), audit-substrate renders artifact-additions (title + Evidence-the-gap-exists + What-the-artifact-would-say + Where-it-lives), discover-substrate renders missing-memory items inline. Each is show-shape, but adapted to the skill's output kind rather than forced into a single mold.
- The matrix's per-synthesizing-skill section is the right substrate move: it gives reviewers a single grid to check at review time, and the §"Why no validator grep here" subsection honestly names what cannot yet be enforced and what would earn promotion.

## Recommended repairs (ranked)

1. **B1 first.** Single-string fix in `skills/audit-substrate/SKILL.md` lines 124 and 160; mechanical and merge-blocking.
2. **I2** — adjust the density-budget table to reflect show-shape sizes; one-paragraph edit to `references/output-voice.md`.
3. **I1** — add the per-skill show-shape variation note to `reviewer-output-shape.md`; one-line edit.
4. **I3** — pluralize `### Predecessor` in `architecture-review-report.md`; small template edit.
5. **I4** — add the matrix-pointer bullet to voice guide §"How this guide is used"; one-line edit.

**Disposition:** Close in same worktree → merge.
