# Rewrite Validation Review — Output substance tightening

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** Output-substance-tightening rewrite — voice-guide rule split (2a/2b/2c, 5a), five SKILL.md Output format blocks (review-codebase, review-diff, audit-substrate, discover-substrate, validate-rewrite), skill-shape convention, reviewer-output-shape matrix extension, architecture-review-report template, two gotchas. Delta ledger at `/home/toda/dev/cohesive/.worktrees/cohesive-output-substance-tightening/docs/history/delta-ledgers/2026-05-06-output-substance-tightening.md`.

**Verdict:** Issues Found

## Executive judgment

The rewrite is conceptually sound and largely implementable. Rule 2 cleanly splits into 2a/2b/2c, rule 5 grows 5a, the matrix extension tracks five skills × three columns, and four of the five SKILL.md Output format blocks carry the show-shape and payload-bearing handoff coherently. A future contributor reading these specs can name the failure mode (`naming-instead-of-showing.md` is excellent — symptom-quote, four contributing factors, three tempting-wrong-fixes, three-layer correct pattern) and reproduce the rule. The single biggest gap is a Delta-at-a-glance preamble that contradicts the body file count by one — a contract-violating preamble that the dispatching `validate-rewrite` skill quotes verbatim into the validation review at decision time, so the divergence is load-bearing rather than cosmetic. Two Medium findings flag internal inconsistencies inside `audit-substrate` (persisted-body vs chat-trailer shape) and the `validate-rewrite` density-budget descriptor.

## Delta at a glance

> - **Files:** 9 rewritten, 1 added, 0 removed/deprecated
> - **Conceptual changes:** rule 2 split into 2a (faithful subset) / 2b (findings shown not named) / 2c (bookkeeping displaced); rule 5 sharpened with sub-rule 5a (handoff carries payload); chat-render contract is "substance, not bookkeeping" rather than "faithful subset"; per-finding chat shape unified across review-codebase, review-diff, audit-substrate, discover-substrate, validate-rewrite as `title + Evidence + Change` (or its skill-specific analog for audit-substrate's artifact-additions); recommended-next-skill clauses carry payload by next-skill kind (files for rewrite-specs, design question for brainstorm-design, scope for review/audit, scope for superpowers handoffs); persisted-file `## History` section is the canonical home for cross-iteration audit content
> - **Named invariants:** none
> - **Behavior matrices:** `reviewer-output-shape` (extended — added §"Synthesizing-skill chat render shape" with three columns: Shows-not-names / Bookkeeping-displaced / Handoff-carries-payload, tracking five synthesizing skills)
> - **Gotchas:** `naming-instead-of-showing` (added — captures audit-log-shape and empty-handoff failure modes); `wordy-output` (cross-reference to the new sibling gotcha added)
> - **Semantic linters:** none (a render-template/chat-render diff lint is named as a future candidate but not specified or shipped this rewrite — the criterion for promotion mirrors the voice-imperative criterion)
> - **Tests proposed:** none (no executable tests; reviewer-output-shape matrix review is the enforcement surface)
> - **Deferred (out of scope this pass):** `cohesively` router's announcement template; `brainstorm-design` Output format

**Preamble divergence from body — see B1.**

## Blocking issues

### B1. Preamble file count contradicts the body

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** The dispatching `validate-rewrite` skill quotes `## Delta at a glance` verbatim into the validation review at decision time (per `validate-rewrite/SKILL.md` line 151 and `cohesion-review.md` §"Delta at a glance"). The preamble is the load-bearing scan a reviewer relies on. A preamble undercount of "9 rewritten" against a body of 10 means the verbatim quote a downstream consumer renders is materially wrong — a fresh reader checking "did the rewrite touch the file I'm worried about" gets a 1-file blind spot, and the substrate-first-discipline lens that asks "does the preamble match the body" fails its own first test on a rewrite about output substance.
- **Evidence:** `docs/history/delta-ledgers/2026-05-06-output-substance-tightening.md:11` — `**Files:** 9 rewritten, 1 added, 0 removed/deprecated`. Body §"Files rewritten" enumerates 10 entries (lines 22, 27, 32, 37, 42, 47, 52, 57, 62, 67): output-voice.md, review-codebase, review-diff, audit-substrate, discover-substrate, validate-rewrite, skill-shape.md, reviewer-output-shape.md, architecture-review-report.md, wordy-output.md.
- **Recommended fix:** Update the preamble bullet to `**Files:** 10 rewritten, 1 added, 0 removed/deprecated`.
- **Substrate artifact to add or update:** Spec — the delta ledger preamble.

## Important issues

### I1. Audit-substrate persisted body and chat trailer disagree on top-fix shape

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** Process Step 3 (the render template the skill writes to the persisted file) renders `## Highest-leverage fixes (ranked)` as a numbered list of `<substrate artifact to add; one-clause justification>` — exactly the bare-title-with-one-clause shape rule 2b is designed against. Output format (the chat trailer) renders the same content as `### 1. <Artifact name>` + Evidence + What the artifact would say + Where it lives. The skill's body line 124 says "persists the full audit report ... per step 3" — but the show-shape lives in Output format, not Step 3. A future contributor implementing the skill cannot tell which template is persisted: if they follow Step 3, the persisted file is bookkeeping-shape; if they follow Output format, it's show-shape. The matrix's "Shows-not-names" cell for audit-substrate reads ✓ post-rewrite, so the intended invariant is show-shape — but the Process step contradicts it.
- **Evidence:** `skills/audit-substrate/SKILL.md:107-110` (Process Step 3 — `## Highest-leverage fixes (ranked) / 1. <substrate artifact to add; one-clause justification>`); contrast with `skills/audit-substrate/SKILL.md:135-157` (Output format show-shape).
- **Recommended fix:** Replace Process Step 3's `## Highest-leverage fixes` block with the show-shape from Output format (or replace the bullet template with a pointer: "render per Output format §below"). Either makes Step 3 and Output format describe the same artifact.
- **Substrate artifact to add or update:** Spec — `skills/audit-substrate/SKILL.md` Process Step 3.

### I2. validate-rewrite density-budget descriptor mis-describes the field count

- **Severity:** Medium
- **Category:** Vague language / Spec drift
- **Why it matters:** The density-budget row for `validate-rewrite` says `Verdict + Delta-at-a-glance quote + show-shape findings (three fields per finding) + disposition + (Approved-only) implementation matrix; ½–¾ page`. But validate-rewrite findings use the **canonical six-field shape** (Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact) per `cohesion-review.md` and the SKILL.md's own Output format. "Three fields per finding" silently introduces a layout that does not exist. A skill author trying to size the budget reads "three fields" and authors a non-conformant render, or a reviewer flags the canonical six-field shape as over-budget.
- **Evidence:** `references/output-voice.md:90` — `\`validate-rewrite\` verdict | Verdict + Delta-at-a-glance quote + show-shape findings (three fields per finding) + disposition + (Approved-only) implementation matrix; ½–¾ page`. Compare `skills/validate-rewrite/SKILL.md:140` — "the six-field shape (Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact) is show-shape by construction."
- **Recommended fix:** Replace "three fields per finding" with "six-field shape per `reviewer-agent-shape.md`" (the per-skill-show-shape-variations subsection in the matrix already documents that validate-rewrite's show-shape IS the six-field canonical).
- **Substrate artifact to add or update:** Spec — `references/output-voice.md` §"Density budgets" table row.

## Substrate gaps

- The architecture-review-report.md template's opening blockquote (line 7) declares "Output starts with the TL;DR block ... verdict + 2-3 sentence thesis + top 3 findings (each in show-shape: title + Evidence + Change) + recommended next skill (with payload)." But the template body that follows opens with `## Verdict` and `## Executive thesis` as separate sections — no TL;DR block carrying the show-shape top findings appears in the template structure. A future contributor copying this template gets the long-form section structure without the chat-render trailer contract baked in. Low-Medium severity; flagged as a substrate gap because it's about a missing template section rather than incorrect content.

## Locality concerns

None. The rewrite preserves the existing seams: voice-guide is canonical for chat-render rules, skill-shape.md governs SKILL.md body structure, the reviewer-output-shape matrix is the per-skill compliance surface, and the gotcha records the failure mode. Each surface has one job and references the others by name.

## Future-fit concerns

- The render-template/captured-chat diff lint is named in three places (ledger §"Semantic linter specs", `naming-instead-of-showing.md` §"Related invariant", and matrix §"Why no validator grep here") with consistent promotion criteria (mirroring the voice-imperative criteria: wording stability + captured regression + worked transcript). Future pressure is acknowledged without being smuggled into normative scope. Good shape.

## Enforcement concerns

None of the new rules promote to invariant. The enforcement story is render-template surface (each SKILL.md Output format block) + matrix surface (reviewer-output-shape per-skill compliance grid) + reviewer judgment (`review-codebase` and `review-diff` of the skill pack itself). The gotcha names the criteria for promoting any of 2b/2c/5a — sound, conservative.

## Behavior knowable outside implementation?

Yes. The rule split, the per-skill render templates, the matrix's per-skill compliance grid, and the gotcha's symptom/correct-pattern together let a fresh reader reproduce the contract. The only gap a fresh reader hits is B1 (preamble undercount → "is file X part of this rewrite?" requires reading the body), and I1 (which template does the audit persist?).

## Vague language to tighten

None notable. The rewrite tightens "should" and "may" appropriately; the only soft language is in deferred-future sections (e.g., "candidate diff lint" in `naming-instead-of-showing.md`), which is correctly marked as future scope rather than normative.

## Recommended repairs (ranked)

1. Fix the preamble file count (B1) — one-character edit to the ledger preamble.
2. Resolve the audit-substrate Process Step 3 / Output format shape disagreement (I1) — point Step 3 at Output format or paste the show-shape into Step 3.
3. Correct the validate-rewrite density-budget descriptor (I2) — "six-field shape" not "three fields per finding."
4. Optional: align `architecture-review-report.md` opening structure with its blockquote claim (substrate gap) — either rename `## Verdict` + `## Executive thesis` as the TL;DR or insert a TL;DR show-shape findings block.

## What looked right

- The rule 2 split (2a/2b/2c) preserves the original test set as a strict subset, so the rewrite is additive at the contract surface — every pre-rewrite passing chat is still passing under 2a, and the new failure modes (2b, 2c) are independently testable. This is the right shape for a rule extension.
- `naming-instead-of-showing.md` is a textbook gotcha: a verbatim user quote, four contributing factors with surface-level evidence, three named-and-rejected tempting wrong fixes, a three-layer structural correct pattern. The sibling cross-reference with `wordy-output.md` plus the explicit non-overlap (ceremony vs substance) closes the conflation surface.
- The matrix's §"Per-skill show-shape variations accepted" subsection is load-bearing: it makes the "title + concrete evidence + the-thing-that-closes-it" contract explicit while permitting layout variation across skills (Evidence + Change for review skills; Evidence + Sketch + Path for audit; inlined for discover; six-field for validate). A reviewer checking the matrix won't over-flag layout differences.
- Pre-existing reviewer agent and `validate-rewrite` show-shape compliance is correctly recognized as already-six-field-show-shape, so the rewrite makes minimal edits to those surfaces and concentrates change where the actual offense lives (review-codebase, review-diff, audit-substrate, discover-substrate Output format blocks).

**Disposition:** Repair → re-validate
