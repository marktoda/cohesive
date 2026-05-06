# Design Delta Ledger — cohesive:init + substrate-vocabulary

**Date:** 2026-05-06
**Worktree / branch:** `.claude/worktrees/init-and-substrate-vocabulary` on `design/init-and-substrate-vocabulary`
**Approved direction:** Phase 1 pass A of the accessibility roadmap. Adds a new `cohesive:init` skill (Option B "Translate-existing / Rosetta Stone") for first-time adoption on codebases with no Cohesive substrate, and a new `references/substrate-vocabulary.md` translation table that init renders inline and that future chat surfaces will use to translate substrate-shape internal labels into user-facing decision-shape vocabulary. Solves the day-1 chicken-and-egg surfaced in the simplification architecture review, and turns adoption into a pedagogical moment: users learn the substrate vocabulary by watching their own code get translated into it.

## Delta at a glance

This rewrite is **Mixed** — primarily Design (new skill + new route + new architecture/skills.md per-skill section + new audience-seam-extension reference) with implementation seams in the validator's six skill-set arrays, the router-matrix mirror, README/ARCHITECTURE.md skill counts, and the cohesively router body.

**Design-layer changes:**
- `docs/substrate/architecture/skills.md` — new `### init` per-skill section (Purpose / Owns / Does not own / Inputs / Outputs / Why this shape); new row in the at-a-glance Skill set table (Gate column = `_adoption_`); new row in the Bootstrap status table (`newly-authored`); top-of-file lead updated from "ten skills" to "eleven skills" with init named.
- `docs/substrate/matrices/router.md` — new cell R017 (first-time adoption trigger phrases → `init` route); new row in the Dispatch prompt contract grid (`init` route, no prereq, no chosen-direction state).

**Implementation changes:**
- `skills/init/SKILL.md` — new skill body. Hard constraints: refuses if substrate exists; never auto-commits; renders translation inline by default; bounded proposal count (≤5 per type, ≤20 total); `--brief` flag opts out of translation paragraphs.
- `references/substrate-vocabulary.md` — new translation table. 6 substrate types (named invariant / behavior matrix / gotcha / semantic linter / spec / convention) with agent-internal name + user-facing translation + "what it earns over a 'rule'" + example signal + canonical location + template path.
- `skills/cohesively/SKILL.md` — new "Adoption (one-shot)" section in the user-facing skill set; new `init` route with trigger phrases + stops-at; new row in the Dispatch prompt contract; new `init` outcome sentence in the Required behavior #1 announcement table; routing decision logic gets a new "Adoption signal" rule between rules 1 and 2.
- `README.md` — new "Adoption (one-shot at day 1)" section in Main commands listing init.
- `ARCHITECTURE.md` — skill count updated from 10 to 11; init named with its purpose.
- `scripts/validate_plugin.sh` — `expected_skills` array gains `init`; `persisting_skills` and `voice_imperative_skills` arrays gain `init`. Comment block updated to "11 expected skills" and to name init's role.

- **Files:** 5 rewritten, 3 added (init/SKILL.md, substrate-vocabulary.md, this ledger), 0 removed
- **Conceptual changes:** new "adoption" skill category (alongside chain / diagnostic / router / orientation); Rosetta Stone pedagogical pattern explicit in init's body (translation alongside generation); substrate vocabulary now has its own translation table parallel to verdict-vocabulary.md, completing the audience seam at the substrate-type layer.
- **Named invariants:** none added / removed / changed; `IMPLEMENTATION_PLAN_COVERS_DELTA`, `VERDICT_BEFORE_EVIDENCE`, `PLUGIN_ROOT_PATHS`, `SKILL_DESIGN_DOC_SECTION` continue to hold (the latter is mechanically enforced and now passes for the new `init` section).
- **Behavior matrices:** `docs/substrate/matrices/router.md` extended with cell R017 + new dispatch-prompt-contract row; cell IDs preserved per the immutability rule.
- **Gotchas:** none added / retired
- **Semantic linters:** Check 8 (v0.1 skill set) updated to expect 11 skills; Check 12 (### Next footer) and Check 13b (voice imperative) updated to include init in their respective skill arrays. No new check added; existing checks generalize.
- **Tests proposed:** A `cohesive:init` worked-transcript demonstration on a fresh repo with proto-substrate signals — capture the side-by-side translation output as the canonical pedagogical artifact. Deferred until init runs against a real codebase.
- **Deferred (out of scope this pass):** Phase 1 sub-pass B (verb-first subskill rename with aliases + the negative-space "What Cohesive does and doesn't do" doc + extending the audience seam to translate substrate types in chat trailers). Phase 2 (validator Python port). Phase 3 (worked examples, taste cookbook, extensibility seam doc).

## Files rewritten

- `skills/cohesively/SKILL.md`
  - **Before:** User-facing skill set listed 3 gates + 3 diagnostics. Routes section enumerated 7 routes (design / rewrite-only / implement / review codebase / review diff / audit / artifact). Required behavior #1 outcome table had 7 rows. Routing decision logic was 4 rules.
  - **After:** User-facing skill set adds an "Adoption (one-shot)" row with `init`. Routes section adds an 8th `init` route (with trigger phrases, stops-at semantics, refusal-on-existing-substrate noted). Dispatch prompt contract grid adds `init` row. Required behavior #1 outcome table adds an 8th row (`init` → "I'll scan your codebase for proto-substrate and produce drafts you can review."). Routing decision logic gains a new rule 2 ("Adoption signal") between explicit-instruction (rule 1) and verb-tense-cue (now rule 3).
  - **Reason:** init needs router-side legibility so the router selects it on first-time-adoption signals without falling back to an irrelevant `audit (substrate)` (which would find nothing). The new routing rule explicitly handles the "Empty-substrate verdict" case.

- `docs/substrate/matrices/router.md`
  - **Before:** Cells R001-R016. Dispatch prompt contract had 7 rows (one per route).
  - **After:** Cells R001-R017 (new R017 for first-time adoption). Dispatch prompt contract has 8 rows (new `init` row). Cell IDs preserved per immutability rule; the new R017 carries trigger phrases + the route-name + a notes column citing init's Hard constraint #1 and the simplification architecture review that surfaced the day-1 problem.
  - **Reason:** Check 13i (DISPATCH_CONTRACT_MIRROR) requires both surfaces to enumerate the same set of routes; the matrix mirror updates in lockstep with the router skill body.

- `docs/substrate/architecture/skills.md`
  - **Before:** Lead said "ten skills." Skill set table had 10 rows. Bootstrap status table had 10 rows.
  - **After:** Lead says "eleven skills" and names init explicitly as the adoption skill. Skill set table has 11 rows with init at row 9 (Gate column = `_adoption_`). Bootstrap status table has 11 rows with init marked `newly-authored` (per the convention for skills authored forward alongside their SKILL.md body). New `### init` per-skill section between `### audit-substrate` and `### using-cohesive`, following the canonical Purpose / Owns / Does not own / Inputs / Outputs / Why this shape shape.
  - **Reason:** SKILL_DESIGN_DOC_SECTION named invariant requires every directory under `skills/` to have a `### <name>` section in this doc; the validator's mechanical grep would fail without the new section.

- `scripts/validate_plugin.sh`
  - **Before:** `expected_skills` listed 10 skills. `persisting_skills` listed 8. `voice_imperative_skills` listed 8.
  - **After:** `expected_skills` adds `init` (11 total). `persisting_skills` adds `init` (9 total — init writes the draft directory and carries `### Next` footer). `voice_imperative_skills` adds `init` (9 total — init has a `## Voice` section). Comment block on Check 8 updated from "the 10 expected skills" to "the 11 expected skills" with init named as the 2026-05-06 adoption-skill addition.
  - **Reason:** Six lockstep skill arrays in the validator (per the simplification review's F2 finding); init must be added to each that applies. This pass adds to three; the other three (`discovery_prereq_subskills`, `path_prereq_subskills`, `verdict_led_skills`) don't apply because init has no Cohesive prereq, no path prereq, and no verdict.

- `README.md`
  - **Before:** Main commands listed router + 5 chain subskills + 3 diagnostics.
  - **After:** Main commands gain a new "Adoption (one-shot at day 1)" section above the gates listing init with its purpose, scan targets, and refusal-on-existing-substrate behavior.
  - **Reason:** README is the user's first-touch surface; init has to be discoverable here for the day-1 use case to land.

- `ARCHITECTURE.md`
  - **Before:** "10 skills" with the 5+3+1+1 enumeration.
  - **After:** "11 skills" with the 5+3+1+1+1 enumeration; init named with its purpose summarized in one phrase.
  - **Reason:** Contributor-facing inventory; the count and the enumeration must agree with skills.md and the validator.

## Files added

- `skills/init/SKILL.md` — the new skill body (described in §"Files rewritten" — implementation changes).
- `references/substrate-vocabulary.md` — the translation table (described above).
- `docs/history/delta-ledgers/2026-05-06-init-and-substrate-vocabulary.md` — this file.

## Files removed or deprecated

None.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| 10 skills (3 gates + 3 diagnostics + router + orientation) | 11 skills (3 gates + 3 diagnostics + 1 adoption + router + orientation) | Extended |
| Substrate vocabulary lives in skill body prose, scattered across 11 SKILL.md files and ~6 convention docs | Substrate vocabulary has a single canonical translation table at `references/substrate-vocabulary.md` parallel to `references/verdict-vocabulary.md` | Centralized |
| Day-1 adoption: user lands in `discover-substrate` → "Empty-substrate verdict: yes" → `audit-substrate` finds nothing | Day-1 adoption: user runs `cohesive:init` → drafts produced with side-by-side translations → user reviews and keeps what fits → `audit-substrate` runs as the second-pass inventory | Promoted to substrate |
| Routing decision logic had 4 rules | Routing decision logic has 5 rules (new rule 2 "Adoption signal" handles the empty-substrate case) | Tightened |
| Pedagogical move: read the conventions, then author substrate | Pedagogical move (the Rosetta Stone): init translates the user's *own* code into Cohesive substrate types, with definitions inline | Added |

## New or updated substrate

### Specs

- `skills/init/SKILL.md` — new skill body.
- `references/substrate-vocabulary.md` — new translation table.
- `skills/cohesively/SKILL.md` — extended with `init` route, dispatch contract row, outcome sentence, and routing-decision-logic adoption signal.
- `docs/substrate/matrices/router.md` — extended with cell R017 + dispatch contract row.
- `docs/substrate/architecture/skills.md` — extended with the per-skill section + table rows.

### Behavior matrices

- `docs/substrate/matrices/router.md` extended (cell R017 + new dispatch contract row). Cell IDs preserved per immutability rule.

### Named invariants

None added, removed, strengthened, or weakened. SKILL_DESIGN_DOC_SECTION is mechanically satisfied for the new `init` section.

### Gotchas

None added or retired.

### Semantic linter specs

- Check 8 (v0.1 skill set), Check 12 (`### Next` footer), Check 13b (voice imperative) all generalize to include init via their existing skill arrays. No new check added this pass.
- A future Check 13o candidate (deferred): grep `references/substrate-vocabulary.md` for the 6 canonical substrate types and verify each carries the four required fields (agent-internal name + user-facing translation + "what it earns over a 'rule'" + example signal). Promotion criterion: the table has been used by at least one Cohesive skill (init renders it; chat-trailer translation in Phase 1 sub-pass B will be the second consumer); after sub-pass B lands the check has two consumers worth grepping.

## What this rewrite *did not* do

- **Verb-first subskill rename.** Phase 1 sub-pass B work; deferred to a follow-up rewrite. Init itself is verb-first by design (the skill ID is `init`, not `init-substrate` or `bootstrap-substrate`); the broader rename is a sweep that's better landed in one focused pass with aliases.
- **Negative-space "What Cohesive does and doesn't do" doc.** Phase 1 sub-pass B; deferred.
- **Audience-seam extension to translate substrate types in chat trailers.** The translation table now exists at `references/substrate-vocabulary.md`, but no chat trailer surface currently consumes it for substrate-type translation (verdicts already translate via verdict-vocabulary.md). Chat-trailer extension lands in Phase 1 sub-pass B.
- **scan_substrate.py extension.** Init's skill body describes proto-substrate signal patterns; the scan_substrate.py script does not yet implement the pattern-matching portion. v0.1 init runs on top of scan_substrate.py's existing categorization plus inline grep patterns; the dedicated extraction logic lands when init runs against a real codebase and the pattern set stabilizes.
- **scripts/validate_plugin.sh Check 13o for the substrate-vocabulary table.** Deferred per §"Semantic linter specs" above; the convention is convention-with-template until two real consumers exist.
- **Worked-transcript demonstration of init.** Deferred until init runs against a real codebase. The pedagogical artifact is most valuable when captured from a real run, not from a synthetic example.

## Remaining ambiguity

- **Init's interaction with partially-bootstrapped codebases.** Init refuses on any existing substrate signal (CLAUDE.md, AGENTS.md, docs/substrate/, docs/specs/, docs/adr/, docs/design/, docs/decisions/). This is intentionally strict for v0.1 — overlapping with existing substrate is a class of bug we don't want to ship. But there's a real case the strict refusal forecloses: a codebase with a CLAUDE.md but no Cohesive substrate. Today such a codebase can't run init. The fix would be to relax the refusal to "no docs/substrate/" only, which is plausible but defers to v0.2 once init has run against enough real codebases to surface the relaxation criterion.
- **Pattern-matching specificity for proto-substrate signals.** Init's body describes signal patterns (`MUST` / `NEVER` / `FIXME` / `*regression*` test names / branchy enum dispatches). Real codebases have local conventions that won't match these patterns — a Java codebase's `assert` statements are proto-invariants but don't say "MUST"; a Rust codebase's `unsafe` blocks are proto-gotchas but don't say "FIXME"; a Python codebase's `match` statements are proto-matrices but the script doesn't yet detect them. The pattern set will need extension as init runs against more languages and codebases. v0.1 ships with the English-comment-and-test-name baseline and explicitly defers the multi-language extension.
- **Bounded proposal count's interaction with the user's expectation.** Init caps at ≤20 drafts. A codebase with 200 proto-invariants will leave 180 unsurfaced; the user has no signal that init was bounded. The chat trailer's "what to do next" pointer recommends `audit-substrate` for the deeper inventory, but a stronger structural mitigation would be to surface "init found N total proto-signals; produced top 20 drafts; run audit-substrate for the rest" in the chat output. Deferred for v0.1.
