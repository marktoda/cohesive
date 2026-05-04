# Design Delta Ledger — Skill Rename v0.1 Release Lexicon

**Date:** 2026-05-04
**Worktree / branch:** `.worktrees/cohesive-skill-rename` on `design/skill-rename-v0.1-lexicon`
**Approved direction:** Option A from `cohesive:brainstorm-design` (this conversation): targeted verb-noun alignment + split of `cohesive-review` into `review-codebase` and `review-diff`.

This ledger records the v0.1 release-lexicon rename pass: the user-facing skill set is reshaped to a learnable verb-noun chain `discover-substrate → brainstorm-design → rewrite-specs → validate-rewrite` (paralleling Superpowers' `brainstorm → plan → execute`) plus three standalone diagnostics `review-codebase`, `review-diff`, `audit-substrate`. The `cohesively` router and the four reviewer agent files are unchanged in name.

The companion brainstorm output is in conversation; the immediate predecessor is the v0.1 release-gate self-review at `docs/history/reviews/2026-05-04-self-review-v0.1-release-gate.md` (untracked on `main` at the time of this rewrite — pre-existing review artifact, separate concern).

## Files rewritten

- `skills/cohesively/SKILL.md`
  - **Before:** Six routes, `cohesive-review --scope codebase`/`--scope diff`/`substrate-audit` named in chains; route name `review (substrate audit)`; no dispatch-prompt-contract section.
  - **After:** Six routes with new chain skill names (`review-codebase`, `review-diff`, `audit-substrate`, `validate-rewrite`); route renamed `audit (substrate)`. New "Dispatch prompt contract" table closes finding #2 from the v0.1 self-review (the router→subskill prereq-state contract was claimed by four subskills and silent on the router side).
  - **Reason:** Lexicon parallelism + closing a self-review finding the brainstorm bundled with this rename.

- `skills/validate-rewrite/SKILL.md` (renamed from `skills/review-spec-cohesion/SKILL.md`)
  - **Before:** Frontmatter `name: review-spec-cohesion`; title "Review spec cohesion"; output report titled "Spec Cohesion Review".
  - **After:** Frontmatter `name: validate-rewrite`; title "Validate rewrite"; output report titled "Rewrite Validation Review". Body content (verdict shape, fresh-eyes property, Approved/Issues Found/Design Incoherent vocabulary, dispatched agent `spec-cohesion-reviewer`) unchanged.
  - **Reason:** "validate" is the verb users say at a whiteboard; the verdict shape is validation, not generic review; collision pressure with the new `review-*` family avoided.

- `skills/audit-substrate/SKILL.md` (renamed from `skills/substrate-audit/SKILL.md`)
  - **Before:** Frontmatter `name: substrate-audit`; noun-noun outlier in the lexicon.
  - **After:** Frontmatter `name: audit-substrate`; verb-noun parallel to `discover-substrate`. References to old composition skills (`cohesive-review` modes) updated to `review-codebase`/`review-diff`. Route name updated to `audit (substrate)`.
  - **Reason:** Verb-noun parallelism; the artifact (a "substrate audit" report) keeps its noun-phrase name in the report itself — only the *skill* renamed.

- `skills/review-codebase/SKILL.md` (new — extracted from `skills/cohesive-review/SKILL.md` codebase mode)
  - **Before:** Codebase mode embedded in 256-line two-mode `cohesive-review/SKILL.md`.
  - **After:** Standalone skill with frontmatter `name: review-codebase`; carries Phase 1 / Phase 1.5 / Phase 2 / Phase 3 / Phase 4 / Phase 5 of the architecture-review rubric; dispatches four reviewer agents in parallel; persists output to `docs/history/reviews/`.
  - **Reason:** Skill-quality finding #5 from v0.1 self-review (two skills in one body, substrate-audit precedent unfollowed); honoring the precedent finishes work the substrate already proposed.

- `skills/review-diff/SKILL.md` (new — extracted from `skills/cohesive-review/SKILL.md` diff mode)
  - **Before:** Diff mode embedded in 256-line two-mode `cohesive-review/SKILL.md`.
  - **After:** Standalone skill with frontmatter `name: review-diff`; locates diff via `gh pr diff` / `git diff main...HEAD`; dispatches two reviewer agents (`substrate-alignment-reviewer`, `structure-reviewer`); chat-only output by default; verdict vocabulary Pass / Pass with notes / Needs substrate / Risky / Block.
  - **Reason:** Same as above; diff mode is genuinely a different workflow from codebase mode.

- `skills/discover-substrate/SKILL.md`
  - **Before:** Cited `cohesive-review --scope codebase`, `cohesive-review --scope diff`, `substrate-audit` in "When to invoke" and elsewhere.
  - **After:** Citations updated to new names; `Empty-substrate verdict` downstream-skill list updated.

- `skills/brainstorm-design/SKILL.md`
  - **Before:** "What this skill is *not*" cited `cohesive-review --scope codebase` and `cohesive:substrate-audit`.
  - **After:** Updated to `cohesive:review-codebase` and `cohesive:audit-substrate`.

- `skills/rewrite-specs/SKILL.md`
  - **Before:** Cited `review-spec-cohesion` in handoff prose, frontmatter, and "What this skill is *not*"; cited `cohesive-review --scope codebase` for claimed-system-shape Phase 1.
  - **After:** All `review-spec-cohesion` mentions → `validate-rewrite`; `cohesive-review --scope codebase` → `cohesive:review-codebase`.

- `ARCHITECTURE.md`
  - **Before:** "Where to look first" pointed to `cohesive:cohesive-review --scope codebase`. v0.1 scope listed 7 skills.
  - **After:** Pointer updated to `cohesive:review-codebase`. v0.1 scope updated to 8 skills with the workflow-chain framing added.

- `README.md`
  - **Before:** "Main commands" listed 7 skills with a `cohesive:review-spec-cohesion`, `cohesive:cohesive-review`, `cohesive:substrate-audit` flat list. Workflow examples cited `cohesive:cohesive-review --scope codebase` etc. "What's in the box" tree listed `review-spec-cohesion/`, `cohesive-review/`, `substrate-audit/`.
  - **After:** Main commands grouped into "Workflow chain" (4 skills) + "Off-chain diagnostics" (3 skills) with the new verb-noun names. Workflow examples cite the new commands. "What's in the box" tree shows the new directory layout.

- `AGENTS.md`
  - **Before:** Source-of-truth section referenced `cohesive-review` runs; "Convention references" cited `cohesive-review` Phase 1; "When in doubt" instructed `cohesive:cohesive-review --scope diff`.
  - **After:** All updated to new names; preserves note that older artifacts under `docs/history/` may reference predecessor names.

- `docs/substrate/matrices/router.md`
  - **Before:** Cell R007's notes named `substrate-audit` and route `review (substrate audit)`. Cell R004 referenced `cohesive-review --scope codebase`. "Out of scope" §"Direct subskill invocation" used old name.
  - **After:** Cell R007 references `audit-substrate` and route `audit (substrate)`. Cell R004 references `review-codebase`. History entry added documenting the rename.

- `docs/substrate/matrices/reviewer-output-shape.md`
  - **Before:** "Purpose", "Rules", and "Related substrate" sections named `cohesive-review` Phase 4 and `review-spec-cohesion` as synthesizers.
  - **After:** Updated to `review-codebase` Phase 4, `review-diff`, `validate-rewrite`. The 5×6 cell grid is unchanged (agents not renamed).

- `docs/substrate/designs/agent-dispatch-protocol.md`
  - **Before:** Named `cohesive-review` Phase 3, `review-spec-cohesion`, `skills/cohesive-review/SKILL.md` as the dispatch sites.
  - **After:** Named `review-codebase` Phase 3, `review-diff`, `validate-rewrite` as dispatch sites; added `review-diff` as a third concrete site.

- `docs/substrate/designs/three-layer-architecture.md`
  - **Before:** "Concrete examples in v0.1" cited `skills/cohesive-review/SKILL.md` for both reference-citing and agent-dispatching examples; structure-reviewer-agent reference named `cohesive-review --scope codebase`.
  - **After:** Updated to `skills/review-codebase/SKILL.md` and `review-codebase`.

- `docs/substrate/designs/composition-with-superpowers.md`
  - **Before:** Recommendation pattern example named `review-spec-cohesion`'s "Approved" branch.
  - **After:** Updated to `validate-rewrite`'s "Approved" branch.

- `docs/substrate/gotchas/soft-prereqs.md`
  - **Before:** Symptom listed `cohesive-review`; implementation-outline step 1 named the subskill bodies as `cohesive-review/SKILL.md` and was framed as "for the V1 enforcement pass".
  - **After:** Symptom lists the five subskill names with new names; implementation-outline points at the now-existing skill bodies and notes each step is "Done in v0.1." (Closes the open-loop in this gotcha that the v0.1 self-review flagged.)

- `docs/substrate/gotchas/discovery-vs-superpowers.md`
  - **Before:** Multiple references to `cohesive-review`, `review-spec-cohesion`, plus the "before brainstorm-design / rewrite-specs / cohesive-review" enumeration.
  - **After:** Updated to the new lexicon and the full subskill list.

- `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md`
  - **Before:** "Current state" referenced `cohesive-review --scope diff`.
  - **After:** Updated to `review-diff`. (No change to the invariant rule itself or to its intended-vs-current enforcement story; the implementation gap that finding #1 of the self-review flagged is *not* closed in this PR — it remains a separate, named follow-up.)

- `references/skill-conventions.md`
  - **Before:** Multiple references to `cohesive-review`, `review-spec-cohesion`. "Process when adding a new skill" step 6 instructed `cohesive:cohesive-review --scope diff`.
  - **After:** Updated throughout. Subskill list under "Canonical prereq-detection question" expanded to include the five subskills now using the pattern; cross-references the new "Dispatch prompt contract" section in the router.

- `references/architecture-review-rubric.md`
  - **Before:** Header named `cohesive-review --scope codebase`; stop-conditions and "What this review is not" referenced old names.
  - **After:** Updated throughout.

- `references/reviewer-agent-template.md`
  - **Before:** "When adding a new reviewer agent" §step 4 cited `skills/cohesive-review/SKILL.md` as the canonical dispatch site.
  - **After:** Cites both `skills/review-codebase/SKILL.md` and `skills/review-diff/SKILL.md`.

- `references/design-pressure-testing.md`
  - **Before:** Multiple references to `review-spec-cohesion` as the rubric consumer.
  - **After:** All updated to `validate-rewrite`.

- `references/locality-over-centralization.md`
  - **Before:** Output integration named `cohesive-review`.
  - **After:** Names `review-codebase` and `review-diff`.

- `references/cohesion-rubric.md`
  - **Before:** "9-axis scorecard" framing and "Severity vocabulary" both referenced `cohesive-review`.
  - **After:** Updated to `review-codebase` for the scorecard and `review-codebase` / `review-diff` for the severity vocabulary.

- `references/substrate-layout.md`
  - **Before:** "Cohesive skills reading substrate" listed `discover-substrate` and `cohesive-review`.
  - **After:** Lists `discover-substrate`, `review-codebase`, `review-diff`, `audit-substrate`, `validate-rewrite`.

- `references/templates/architecture-review-report.md`
  - **Before:** Reviewer field named `cohesive-review --scope codebase`.
  - **After:** Reviewer field named `cohesive:review-codebase`.

- `references/templates/substrate-discovery-report.md`
  - **Before:** "Empty-substrate verdict" downstream halts and "Which sections each consumer reads" table used old names.
  - **After:** Both updated to new names.

- `references/templates/substrate-map.md`
  - **Before:** "How to use this map" said this map is read first during `cohesive-review`.
  - **After:** Names `review-codebase` and `review-diff`.

- `references/templates/claimed-system-shape.md`
  - **Before:** Description and "Consumers" section named `cohesive-review --scope codebase`.
  - **After:** Names `review-codebase` (Phase 1 producer + Phase 4 synthesizer).

- `scripts/validate_plugin.sh`
  - **Before:** Seven structural checks; no skill-set assertion; no description-trigger semantic check.
  - **After:** Two new checks added: (8) the eight expected skills are present at their new directory paths; (9) every Cohesive skill description contains at least one substrate-vocabulary token (`substrate|cohesion|cohesive|invariant|gotcha|behavior matrix|spec|rewrite`). Check (9) is the structural mitigation the brainstorm specified for the rename's main risk (loss of brand identity in skill names).

- `.claude-plugin/plugin.json`
  - **Before:** `description` enumerated old workflow names ("design, architecture review, change-cohesion review, and substrate audits").
  - **After:** `description` enumerates the new lexicon and names the workflow chain explicitly. Version unchanged at `0.1.0` (already a valid stable-name version per the brainstorm; no bump needed).

## Files added

- `skills/review-codebase/SKILL.md` — codebase-mode review (extracted from `cohesive-review`).
- `skills/review-diff/SKILL.md` — diff-mode review (extracted from `cohesive-review`).
- `docs/history/delta-ledgers/2026-05-04-skill-rename-v0.1-lexicon.md` — this ledger.

## Files removed or deprecated

- `skills/cohesive-review/SKILL.md` — replaced by the two split skills above. Removed via `git rm`; the old name is preserved in `docs/history/` artifacts as time-stamped record.
- `skills/review-spec-cohesion/` (directory) — renamed via `git mv` to `skills/validate-rewrite/`.
- `skills/substrate-audit/` (directory) — renamed via `git mv` to `skills/audit-substrate/`.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| Skill `cohesive-review` (two-mode) | Skills `review-codebase` and `review-diff` (split) | Replaced (precedent set by the substrate-audit extraction) |
| Skill `review-spec-cohesion` | Skill `validate-rewrite` | Renamed (verb-noun + lifecycle-role accuracy) |
| Skill `substrate-audit` | Skill `audit-substrate` | Renamed (verb-noun parallel to `discover-substrate`) |
| Route `review (substrate audit)` | Route `audit (substrate)` | Renamed (parallel verb-noun shape; cell R007 ID preserved per matrix immutability rule) |
| Implicit router→subskill state inheritance | Explicit "Dispatch prompt contract" section in `cohesively/SKILL.md` | New (closes self-review finding #2) |
| Skill-set framed as flat 7-skill list | Skill-set framed as 4-step workflow chain + 3 off-chain diagnostics + 1 router | Reframed (teachability — parallels Superpowers' `brainstorm → plan → execute`) |

## New or updated substrate

### Specs
- `ARCHITECTURE.md` — v0.1 scope updated to 8 skills + workflow-chain framing
- `README.md` — Main commands grouped; "What's in the box" tree updated
- `AGENTS.md` — Source-of-truth references and "When in doubt" updated
- `skills/cohesively/SKILL.md` — added "The user-facing skill set" table and "Dispatch prompt contract" section

### Behavior matrices
- `docs/substrate/matrices/router.md` — cell descriptions updated; route names refreshed; History entry added. Cell IDs preserved.
- `docs/substrate/matrices/reviewer-output-shape.md` — synthesizer-skill citations updated. Grid unchanged.

### Named invariants
- `PLUGIN_ROOT_PATHS` — unchanged (rule still holds; `${CLAUDE_PLUGIN_ROOT}/skills/<new-name>/SKILL.md` paths verified). The rule's "Current state" enforcement gap (named in self-review finding #1) is *not* closed in this PR — it remains the highest-leverage Phase-1 follow-up.

### Gotchas
- `docs/substrate/gotchas/soft-prereqs.md` — implementation-outline reframed from "for the V1 enforcement pass" (planned) to "Done in v0.1" (closes the loop). The five subskill names enumerated.
- `docs/substrate/gotchas/discovery-vs-superpowers.md` — chain prose updated to new names.

### Semantic linter specs
- `scripts/validate_plugin.sh` check (8): `expected_skills` array of 8 names asserts the lexicon is present.
- `scripts/validate_plugin.sh` check (9): each skill's `description:` field must contain a substrate-vocabulary token. This is the structural mitigation for the rename's main risk (loss of brand identity in skill names).

### Tests / checks proposed (not yet implemented)
- Per the brainstorm's Phase 1 list, the `PLUGIN_ROOT_PATHS` grep, canonical-question grep, fresh-eyes-preamble grep, recommended-next-footer grep, and skill-section-presence matrix all remain follow-up work for a separate PR. They are *not* in this rewrite's scope.

## What this rewrite *did not* do

- Implementation code: not changed.
- Reviewer agent files (`agents/*.md`): not renamed. The v0.1 brainstorm's non-goals list was explicit: agents are dispatched, not user-invoked, so their names are an internal contract.
- The broader `PLUGIN_ROOT_PATHS` enforcement gap (self-review finding #1): not addressed; named as Phase 1 follow-up.
- The external-repo artifact-directory wiring (self-review finding #3): not addressed; needs its own design pass.
- The skill-section-presence matrix (self-review finding #7): not added; should land *after* the rename so the matrix doesn't immediately need updating.
- Plugin major version: not bumped. Version remained `0.1.0` per the brainstorm.
- CI: not added (still out of scope per `ARCHITECTURE.md`).

## Remaining ambiguity

- **Output filename pattern for audits.** `audit-substrate` writes to `docs/history/reviews/YYYY-MM-DD-<slug>-substrate-audit.md` — the *artifact* keeps its noun-phrase filename even though the producing skill renamed. Reviewer should confirm this is the right call (vs renaming the filename pattern to match the new skill name).
- **The `artifact` route deferral wording.** The router's artifact route still references "dedicated artifact skills (`create-invariant`, `create-matrix`) ship in V1" — the future names match the verb-noun pattern this rename establishes, but they aren't load-bearing yet. A future contributor should re-validate the future names when V1 work begins.
- **Description triggers vs Superpowers competition.** The substrate-vocabulary grep (validator check 9) is the structural mitigation, but it doesn't audit Cohesive triggers *against* Superpowers' published descriptions. A separate (out-of-scope) PR could grep for overly broad triggers like "review the codebase" appearing in *any* Cohesive skill's description.

## Ready for fresh-eyes review?

**Yes.** The validator passes (0 errors, 0 warnings). All 22 affected files are committed in one logical PR. The remaining ambiguity items are flagged for the reviewer to confirm or reroute.

## How to read this ledger

1. The "Approved direction" line names the destination — Option A from this conversation's brainstorm output.
2. "Conceptual changes" surfaces the six things that are *different*; the rest is mechanical citation update.
3. "Files rewritten" with before/after entries lets the reviewer verify each rewrite without re-reading every file end-to-end.
4. "Remaining ambiguity" is the focused review punch list.
