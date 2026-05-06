# Rewrite Validation Review — Output substance tightening

**Verdict:** Approved

## Executive judgment

The rewrite is implementable as it stands. A future contributor can read `references/output-voice.md`, `docs/substrate/conventions/skill-shape.md` §"Output format conventions" rule 3, and any of the five synthesizing skills' Output format blocks side-by-side and produce a chat render that satisfies the show-shape (title + Evidence + Change) and the payload-bearing handoff. The voice-guide rule split (2 → 2a/2b/2c, 5 → 5/5a) is internally consistent across all surfaces; per-skill render templates instantiate the convention's canonical template; the matrix tracks per-skill compliance; the new gotcha (`naming-instead-of-showing.md`) and its sibling cross-reference to `wordy-output.md` are both load-bearing and well-bounded. Three pre-existing repair passes plus pass-3 closures are visible in the ledger; remaining ambiguity is enumerated and bounded. The findings below are taste-level on a clean rewrite.

## Delta at a glance

> - **Files:** 10 rewritten, 1 added, 0 removed/deprecated
> - **Conceptual changes:** rule 2 split into 2a (faithful subset) / 2b (findings shown not named) / 2c (bookkeeping displaced); rule 5 sharpened with sub-rule 5a (handoff carries payload); chat-render contract is "substance, not bookkeeping" rather than "faithful subset"; per-finding chat shape unified across review-codebase, review-diff, audit-substrate, discover-substrate, validate-rewrite as `title + Evidence + Change` (or its skill-specific analog for audit-substrate's artifact-additions); recommended-next-skill clauses carry payload by next-skill kind (files for rewrite-specs, design question for brainstorm-design, scope for review/audit, scope for superpowers handoffs); persisted-file `## History` section is the canonical home for cross-iteration audit content
> - **Named invariants:** none
> - **Behavior matrices:** `reviewer-output-shape` (extended — added §"Synthesizing-skill chat render shape" with three columns: Shows-not-names / Bookkeeping-displaced / Handoff-carries-payload, tracking five synthesizing skills)
> - **Gotchas:** `naming-instead-of-showing` (added — captures audit-log-shape and empty-handoff failure modes); `wordy-output` (cross-reference to the new sibling gotcha added)
> - **Semantic linters:** none (a render-template/chat-render diff lint is named as a future candidate but not specified or shipped this rewrite — the criterion for promotion mirrors the voice-imperative criterion)
> - **Tests proposed:** none (no executable tests; reviewer-output-shape matrix review is the enforcement surface)
> - **Deferred (out of scope this pass):** `cohesively` router's announcement template; `brainstorm-design` Output format

## Blocking issues

None.

## Important issues

### I1. `audit-substrate` slug payload contradicts the path-discipline rule

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** `audit-substrate/SKILL.md` line 127 (Process Step 3 render) and line 178 (Output format render) both terminate the recommended-next-skill payload with `Slug: \`<scope>-substrate-additions\``. The literal `substrate-additions` is hard-coded; the rest of the rewrite consistently uses `<scope>-<purpose>` slugs but the rest of the synthesizing skills name their slugs as `<derived-from-scope>` or `<derived-from-diff>` (placeholders). A reader of the recommended-next clause cannot tell whether the slug is meant as a literal or a pattern.
- **Evidence:** `skills/audit-substrate/SKILL.md:127` "Slug: `<scope>-substrate-additions`"; `skills/audit-substrate/SKILL.md:178` same; compare `skills/review-codebase/SKILL.md:169` "Slug: `<derived-from-scope>`" and `skills/review-diff/SKILL.md:96` "Slug: `<derived-from-diff>`."
- **Recommended fix:** Replace `<scope>-substrate-additions` with `<derived-from-audit-scope>` (placeholder, like the other skills) in both lines, or document in `skill-shape.md` §"Recommended-next-skill footer" that audit-substrate's downstream rewrite-specs slug is conventionally `<scope>-substrate-additions` and cite that convention from the skill body.
- **Substrate artifact to add or update:** spec (`audit-substrate/SKILL.md` Output format) or convention (`skill-shape.md` §"Recommended-next-skill footer")

### I2. `wordy-output.md` "Correct pattern" still cites the pre-rewrite faithful-subset rule shape

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** `wordy-output.md:40` (Correct pattern, layer 1) reads: "`docs/substrate/conventions/skill-shape.md` §"Output format conventions" and `docs/substrate/conventions/reviewer-agent-shape.md` §"Output format conventions" cap header depth at `###`, declare that **chat renders may be a faithful subset of persisted files**, and require branchy content to render as bullets/tables…" The bolded clause is the *pre-rewrite* phrasing of rule 2 ("faithful subset"); the rewrite renamed rule 2 to "the chat render is substance, not bookkeeping" (with 2a as the faithful-subset sub-rule). A reader of `wordy-output.md` looking for the canonical phrasing of the contract sees a stale name.
- **Evidence:** `docs/substrate/gotchas/wordy-output.md:40` "declare that chat renders may be a faithful subset of persisted files"; compare `references/output-voice.md` rule 2 "the chat render is substance, not bookkeeping" with sub-rule 2a as "faithful subset."
- **Recommended fix:** Update `wordy-output.md:40` to "declare that the chat render is substance, not bookkeeping (the faithful-subset test is sub-rule 2a)" — matches the rewrite's primary surface and preserves the original rule reference.
- **Substrate artifact to add or update:** gotcha (`wordy-output.md` §"Correct pattern")

### I3. `architecture-review-report.md` blockquote uses `####` headers in the persisted file's TL;DR while voice rule caps at `###`

- **Severity:** Low
- **Category:** Vague language / Domain model
- **Why it matters:** `architecture-review-report.md` lines 17–33 render the TL;DR's "Top findings" with `#### 1.`, `#### 2.`, `#### 3.` headers. The blockquote at line 7 declares "the TL;DR is what `cohesive:review-codebase` quotes verbatim into chat as the substantive trailer" — which means the chat render *would* inherit `####` from the verbatim quote, violating the `###` cap. The skill-shape canonical render template at `skill-shape.md:121-137` uses `### 1.` / `### 2.` / `### 3.` (the chat-compliant shape), and `review-codebase/SKILL.md:143-159` also uses `### 1.` — the inconsistency is only in this template.
- **Evidence:** `references/templates/architecture-review-report.md:17` `#### 1. <Finding title>`; compare `docs/substrate/conventions/skill-shape.md:121` `### 1. <Finding title>` and `skills/review-codebase/SKILL.md:143` `### 1. <Finding title>`.
- **Recommended fix:** Demote the TL;DR's `#### 1./2./3.` to `### 1./2./3.` (and demote the surrounding `### Top findings` to plain bold prose `**Top findings**`, since `###` would now be reserved for finding titles); alternatively, change the blockquote to clarify that the chat render demotes headers when quoting.
- **Substrate artifact to add or update:** template (`references/templates/architecture-review-report.md`)

## Substrate gaps

- The `Phased roadmap` and `Cohesion scorecard` sections of `review-codebase` Phase 4 are listed as "persisted-file only" but the persisted template at `architecture-review-report.md` does not have a `## Phased roadmap` section header — it has `## Recommended roadmap`. Section-name drift between skill body and template is small but visible.
- The persisted-file `## History` section's "Disposition" column accepts values "Closed / Promoted / Deferred / Superseded" but the rubric's disposition rule produces phrases like "Close inline (≤2 lines per finding) → merge" — two different disposition vocabularies coexist (review-pass disposition vs. validation-review disposition). Not a contradiction (different artifacts), but a future contributor reading both might conflate them.

## Locality concerns

None. The rewrite respects the substrate-first/SKILL.md split per `skill-shape.md` §"When to edit SKILL.md alone" — the `Pure implementation` classification in the ledger preamble is correct (no skill purposes, ownership, or seams changed; the design layer is untouched).

## Future-fit concerns

The rewrite explicitly defers the "promotion to named invariant" question for rules 2b/2c/5a, citing the same criteria already used for the voice-imperative convention. This is correctly handled — future pressure is acknowledged but not smuggled into normative sections.

## Enforcement concerns

The rewrite's primary enforcement story is "render-template surface + matrix review" — no validator grep ships. This is consistent with the rewrite's own statement that grep is hard for this failure mode. The candidate diff lint is named with promotion criteria. Acceptable for this pass.

## Behavior knowable outside implementation?

Yes. A future contributor reading `references/output-voice.md` rules 2a/2b/2c/5a, the canonical render template in `skill-shape.md` §"Output format conventions" rule 3, and any of the five synthesizing skills' Output format blocks can reproduce the chat-render shape without consulting prior conversation context. The matrix at `reviewer-output-shape.md` §"Synthesizing-skill chat render shape" is the per-skill compliance surface, and §"Per-skill show-shape variations accepted" justifies the four field-layout variants.

## Vague language to tighten

- `skills/discover-substrate/SKILL.md:170` — "concrete enough that a reader could begin drafting it" (acceptable in spec prose but borderline for a render template).
- None of the surfaced specs use "should/may/TBD/TODO" in normative sections. The rewrite is tight.

## Recommended repairs (ranked)

1. Resolve I1 (audit-substrate slug literal vs. placeholder). One-line edit.
2. Resolve I2 (wordy-output.md stale rule-2 phrasing). One-line edit.
3. Resolve I3 (architecture-review-report.md TL;DR header depth). Two-line edit.

## What looked right

- **Rule 2 split into 2a/2b/2c is independently testable.** The original "faithful subset" test is preserved as 2a; 2b and 2c add new tests at separate surfaces.
- **The ledger's "Pure implementation" classification is correct and explicitly justified.** The §"Delta at a glance" preamble names design-layer files as untouched, eliminating the lens-12 trigger.
- **`naming-instead-of-showing.md` ↔ `wordy-output.md` sibling cross-reference closes a real risk.** The bidirectional cross-reference with explicit non-overlap criteria preserves both scars as load-bearing.
- **Per-skill show-shape variations are explicitly accepted in the matrix.** Four different field-layouts are documented with their reason-for-variation. A future reviewer applying the matrix won't over-reject for layout.

**Disposition:** Close in same worktree → merge

**Implementation route** — pick one:

| Option | Skill | When to pick |
|---|---|---|
| Implement now with delta-coverage discipline (default) | `cohesive:implement-cohesively` | Substantial rewrites; the rewrite added named invariants, behavior matrices, or cross-cutting conceptual changes. Phase loop with per-phase cross-review against the delta. |
| Land specs first; implement separately later | merge the `design/<slug>` branch first; later run `cohesive:implement-cohesively` against the merged delta ledger | Spec rewrite is independently valuable (e.g., for review by humans before code lands); the implementation has dependencies that aren't yet ready. |
| Hand off to Superpowers without delta-coverage discipline | `superpowers:writing-plans` | Small rewrites where the delta is mostly cosmetic; user accepts that the implementation may drift from the rewrite. The bypass is documented per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` §"Known bypass risks." |
| Schedule for later | (no immediate action) | The rewrite is approved; implementation is not currently in scope. Re-invoke `cohesive:implement-cohesively` or `superpowers:writing-plans` when ready. |
