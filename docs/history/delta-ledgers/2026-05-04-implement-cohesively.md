# Design Delta Ledger — implement-cohesively

**Date:** 2026-05-04
**Worktree / branch:** `.claude/worktrees/design+implement-cohesively` on `design/implement-cohesively`
**Approved direction:** Ship `cohesive:implement-cohesively` as a v0.1 skill (Option B: orchestrate, composing with Superpowers, plus per-phase `superpowers:writing-plans` step). Cohesive owns delta-derived phase shape and per-phase cross-review against the design delta ledger; Superpowers owns plan writing and TDD execution inside each phase.

This ledger records what changed in the substrate during the rewrite that produced the new implementation phase. The fresh-eyes reviewer reads this ledger to see the rewrite as a delta.

## Files rewritten

- `skills/cohesively/SKILL.md`
  - **Before:** four-imperative chain (discover → brainstorm → rewrite → validate); six routes (design, review codebase, review diff, audit, rewrite-only, artifact); router did not auto-invoke Superpowers and explicitly forbade producing implementation code.
  - **After:** five-imperative chain (discover → brainstorm → rewrite → validate → implement); seven routes (adds `implement`); design route's "Default behavior" clarifies that implementation is a separate route and design does not auto-chain into implementation; `implement` route dispatches `cohesive:implement-cohesively` (which composes Superpowers per phase) — the router still does not dispatch Superpowers directly. Required behavior #4 rewritten to permit code-producing surface only via `superpowers:executing-plans` invoked from inside `implement-cohesively`'s phase loop. Required behavior #6 names `writing-plans` and `executing-plans` as per-phase consumers in `implement-cohesively`. Routing decision logic updated to recognize implementation cues ("implement", "land", "ship") against an existing approved rewrite. Dispatch contract table updated with the `implement` route's prereq state ("Validate-rewrite returned Approved; review at <path>") and ledger path.
  - **Reason:** the user reported a scar — Cohesive started writing code with no task breakdown when asked to implement immediately. The `implement` route is the structural answer; freeform code-writing from the router is now forbidden by Required behavior #2.

- `skills/validate-rewrite/SKILL.md`
  - **Before:** Approved verdict's "Recommended next" footer was a single line: "`superpowers:writing-plans` (or `plan-implementation` in V1)". Hard constraint #3 mentioned `plan-implementation` (a V1-deferred name) as the alternative target.
  - **After:** Approved verdict renders an explicit decision matrix with four rows: implement-now via `cohesive:implement-cohesively` (default for substantial rewrites), land specs first then implement separately, hand off to `superpowers:writing-plans` directly without delta-coverage discipline (documented bypass), or schedule for later. Hard constraint #3 names `implement-cohesively` as the gated target, with the bypass-via-direct-Superpowers option named explicitly. Composition section updated.
  - **Reason:** the user picks the implementation path; Cohesive does not improvise. The decision matrix names every legitimate option, including the documented bypass.

- `skills/rewrite-specs/SKILL.md`
  - **Before:** Step 7 hand-off prose mentioned only `cohesive:validate-rewrite` as the next step.
  - **After:** Step 7 hand-off prose mentions both `cohesive:validate-rewrite` and (after Approved verdict) the implementation route via `cohesive:implement-cohesively`, pointing the reader to the validate-rewrite Approved decision matrix.
  - **Reason:** chain legibility — readers of `rewrite-specs` see the full chain through implementation.

- `skills/brainstorm-design/SKILL.md`
  - **Before:** "What this skill is *not*" line: "Not an implementation planner. That's V1's `plan-implementation` (Superpowers' `writing-plans` works for now)." Composition's "Often followed by" line mentioned "directly to implementation planning" as the small-change path.
  - **After:** "What this skill is *not*" line names `cohesive:implement-cohesively` as the implementation orchestrator (with `superpowers:writing-plans` as the bypass option for non-substrate-shaped implementation). Composition's "Often followed by" names the full chain through `implement-cohesively`.
  - **Reason:** retire references to V1-deferred `plan-implementation`; describe the v0.1 reality.

- `docs/substrate/designs/composition-with-superpowers.md`
  - **Before:** described Cohesive↔Superpowers seam where Cohesive owned substrate and Superpowers owned implementation; "Cohesive ends at 'approved spec, ready for implementation'"; `plan-implementation` and `implement-cohesively` named as V1-deferred. Three forms of composition: skill invocation with fallback, recommendation in skill output, documentation of phase boundary.
  - **After:** the Cohesive↔Superpowers seam is redrawn at "delta-derived phase shape" vs "per-phase plan + TDD execution." Cohesive's `implement-cohesively` orchestrates a phase loop where Superpowers is consumed per phase. Four forms of composition: loose (skill invocation with fallback — `rewrite-specs`/`using-git-worktrees`), tight (skill invocation without fallback — `implement-cohesively`/`writing-plans`+`executing-plans`), recommendation in skill output (validate-rewrite decision matrix), and documentation of phase boundary (router's `implement` route dispatches Cohesive's skill, not Superpowers directly). "What Cohesive deliberately does not do" updated: no Cohesive plan-writing, no Cohesive plan-execution, no TDD or branch-finishing; the deferred `plan-implementation` and `implement-cohesively` lines retired (the latter now ships in v0.1, with `plan-implementation`'s function folded into the phase loop). "Failure modes this composition does not prevent" updated: a user with only Cohesive who asks for implementation gets a hard error from `implement-cohesively` rather than a recommendation. "Alternatives considered" expanded with the rejected v0.1 pre-implement-cohesively shape that produced the no-implementation-handoff scar. "When to revisit" updated.
  - **Reason:** the composition seam shifted; the doc is the canonical description of where the two plugins meet.

- `docs/substrate/matrices/router.md`
  - **Before:** 14 cells (R001–R014) covering six routes; dispatch contract table did not include `implement`; one documented exception (`validate-rewrite` does not consume prereq state).
  - **After:** 16 cells (R001–R016) covering seven routes (adds R015 explicit-implement and R016 implement-without-prerequisites); dispatch contract table includes the `implement` row with both prereq-state and ledger-path passing; second documented exception added (`implement-cohesively` consumes a workflow-prereq — Approved verdict — rather than a discovery-prereq, paralleling the `validate-rewrite` exception structurally). History entry added.
  - **Reason:** router behavior matrix is the test artifact for the router skill body; both surfaces must move together.

- `docs/substrate/designs/agent-dispatch-protocol.md`
  - **Before:** named four reviewer dispatch sites (Phase 3 of `review-codebase`, two reviewers in `review-diff`, `spec-cohesion-reviewer` in `validate-rewrite`).
  - **After:** adds a fifth dispatch site: `delta-coverage-reviewer` dispatched per phase by `implement-cohesively`. Drift-from-canonical-preamble note clarifies that `delta-coverage-reviewer` ships with the canonical preamble verbatim from day one.
  - **Reason:** the new agent participates in the dispatch protocol; the protocol doc is the source of truth.

- `docs/substrate/designs/skill-conventions.md`
  - **Before:** "When sections may differ" listed three accepted deviations (router; discover-substrate; token-discipline-bearing skills).
  - **After:** adds a fourth accepted deviation (`implement-cohesively` adds `## Branch shape`). New section "Code-producing skills" documents the exception that `implement-cohesively`'s body never writes code itself but composes `superpowers:executing-plans` per phase. The general convention "Cohesive skills do not produce code" is preserved with one named exception.
  - **Reason:** future skill authors must know the exception exists and where to look in the composition design doc before crossing the seam again.

- `README.md`
  - **Before:** described the four-step chain plus three diagnostics; "What's in the box" listed 8 skills, 5 reviewer agents, 4 named gotchas, 4 named matrices, 2 named invariants. "Recommended companion" said Superpowers integration was optional with a fallback path.
  - **After:** describes the five-step chain plus three diagnostics; adds "Implementation against an approved rewrite" workflow; "What's in the box" lists 9 skills (adds `implement-cohesively`), 6 reviewer agents (adds `delta-coverage-reviewer`), 6 named gotchas (adds `no-implementation-handoff` and `skipping-per-phase-plan`), 5 named matrices (adds `phase-derivation`), 3 named invariants (adds `IMPLEMENTATION_PLAN_COVERS_DELTA`). "Recommended companion" describes both the loose seam (worktree, with fallback) and the tight seam (`implement-cohesively`, no fallback; Superpowers required for implementation phase).
  - **Reason:** user-facing source of truth.

- `ARCHITECTURE.md`
  - **Before:** "8 skills, 5 reviewer agents, 6 references" in v0.1 scope; two named invariants; four-step workflow chain in the user-facing summary.
  - **After:** "9 skills, 6 reviewer agents, 6 references"; three named invariants; five-step workflow chain. New row in "Where to look first" for the implementation phase loop. New row in "Risks the design accepts" for Superpowers version drift in `implement-cohesively` and per-phase reviewer cost.
  - **Reason:** binding architectural map.

## Files added

- `skills/implement-cohesively/SKILL.md` — drives the implementation phase loop. Hard constraints: Approved verdict required; Superpowers required (no fallback); per-phase cross-review mandatory; coverage of delta entries structural; final substrate review mandatory. Process: derive phases via phase-derivation matrix, then for each phase invoke `superpowers:writing-plans` → `superpowers:executing-plans` → dispatch `delta-coverage-reviewer` → commit with citations. After last phase, dispatch `cohesive:review-diff`. Verdict-led output (Implemented / Phase Drift / Substrate Drift / Aborted).
- `agents/delta-coverage-reviewer.md` — fresh-eyes per-phase reviewer. Inputs: delta-ledger excerpt, plan path, phase diff. Verdicts: Covered / Drift / Incomplete. Carries the canonical fresh-eyes preamble verbatim. Token-disciplined output (≤400 words / ≤5 ranked findings).
- `docs/substrate/matrices/phase-derivation.md` — substrate-shape seam between design delta ledger and `superpowers:writing-plans`. Cells P001–P008 cover the eight ledger-section-to-phase-intent mappings (Files rewritten, Files added, Conceptual changes, Behavior matrices, Named invariants, Gotchas, Tests proposed, Semantic linter specs). Default cells P900–P902 expand the default rules for testability.
- `docs/substrate/gotchas/skipping-per-phase-plan.md` — the failure mode where skipping `superpowers:writing-plans` per phase collapses the cross-review's two failure modes (planning gap, execution gap) into one indistinguishable verdict. Tempting wrong fix: collapse plan-writing into Cohesive. Correct pattern: per-phase plan persistence is mandatory; the reviewer compares diff ↔ plan ↔ delta entry.
- `docs/substrate/gotchas/no-implementation-handoff.md` — the user-reported scar where Cohesive started writing code with no task breakdown when asked to implement immediately. Tempting wrong fix: stronger prose in the validate-rewrite footer. Correct pattern: ship `implement-cohesively`, the `implement` router route, and the sharpened decision matrix.
- `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` — named invariant pinning every delta entry to ≥1 phase, every phase to a persisted plan, every phase commit to plan + delta-entry citations, every phase to a Covered cross-review verdict, and the implementation pass to a final `cohesive:review-diff`. Earned invariant status from day one because the rule has a concrete structural failure mode (silent substrate drift), an explicit enforcement path (Phase 1 coverage table; reviewer verdict; final substrate review), and a real cost on regression.

## Files removed or deprecated

- `plan-implementation` references retired wherever they appeared as V1-deferred (composition-with-superpowers.md, validate-rewrite/SKILL.md, brainstorm-design/SKILL.md). The function (delta-derived plan shape) is now folded into `implement-cohesively`'s phase loop and `superpowers:writing-plans`. No file removed; references replaced or rewritten.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| "Cohesive ends at approved spec, ready for implementation" | "Cohesive owns the delta-derived phase shape and per-phase cross-review; Superpowers owns the per-phase plan and TDD execution inside the phase loop" | Replaced |
| `plan-implementation` (V1-deferred) | folded into `implement-cohesively`'s phase loop (substrate-shape) plus `superpowers:writing-plans` (TDD-shape) | Removed/folded |
| `implement-cohesively` (V1-deferred) | shipped in v0.1 with the orchestrate-not-drive shape (Option B) plus per-phase `superpowers:writing-plans` step | Promoted to v0.1 |
| Workflow chain "discover → brainstorm → rewrite → validate" | Workflow chain "discover → brainstorm → rewrite → validate → implement" | Extended |
| Six routes (design, review-codebase, review-diff, audit, rewrite-only, artifact) | Seven routes (adds `implement`) | Extended |
| Two named invariants (PLUGIN_ROOT_PATHS, VERDICT_BEFORE_EVIDENCE) | Three named invariants (adds IMPLEMENTATION_PLAN_COVERS_DELTA) | Extended |
| Five reviewer agents (substrate-alignment, structure, library-native, agent-readiness, spec-cohesion) | Six reviewer agents (adds delta-coverage) | Extended |
| Cohesive↔Superpowers composition: substrate vs implementation | Cohesive↔Superpowers composition: delta-derived phase shape vs per-phase plan + TDD | Refined |

## New or updated substrate

### Specs

- `skills/implement-cohesively/SKILL.md` — drives the phase loop; new
- `skills/cohesively/SKILL.md` — adds `implement` route and updated dispatch contract table
- `skills/validate-rewrite/SKILL.md` — Approved verdict footer renders the implementation decision matrix
- `skills/rewrite-specs/SKILL.md` — handoff prose mentions the implementation chain
- `skills/brainstorm-design/SKILL.md` — replaces V1-deferred references with v0.1 reality
- `docs/substrate/designs/composition-with-superpowers.md` — seam redrawn for the phase loop
- `docs/substrate/designs/skill-conventions.md` — code-producing-skill exception named
- `docs/substrate/designs/agent-dispatch-protocol.md` — adds the fifth dispatch site
- `README.md`, `ARCHITECTURE.md` — counts and chain updated

### Behavior matrices

- `docs/substrate/matrices/phase-derivation.md` — new; cells P001–P008 plus P900–P902 default cells
- `docs/substrate/matrices/router.md` — cells R015 (explicit-implement) and R016 (implement-without-prereqs) added; dispatch contract grid extended with `implement` row; second documented exception added

### Named invariants

- `IMPLEMENTATION_PLAN_COVERS_DELTA` — added; structural pin behind the implementation phase loop. Enforcement: skill-body acceptance criteria + reviewer verdict + final substrate review + deferred CI grep for commit-message citations.

### Gotchas

- `no-implementation-handoff` — added; records the user-reported scar that motivated the `implement` route and `implement-cohesively`.
- `skipping-per-phase-plan` — added; pre-emptively documents the failure mode the per-phase `superpowers:writing-plans` step prevents.

### Semantic linter specs

- Commits on `design/<slug>` branches (or child `implement/<slug>` branches) produced by `implement-cohesively` must cite the delta ledger path and the implementation plan path. Proposed (deferred to V1).
- `validate-rewrite`'s Approved footer must contain the four-row decision matrix table. Proposed lint check (deferred to V1).
- `implement-cohesively/SKILL.md` must cite the phase-derivation matrix and the `IMPLEMENTATION_PLAN_COVERS_DELTA` invariant. Proposed lint check (deferred to V1).

### Tests / checks proposed (not yet implemented)

- Manual scenario test: with both Cohesive and Superpowers installed, after a `validate-rewrite` Approved verdict, type "implement now and land docs with implementation"; verify the router selects `implement` (cell R015) and `implement-cohesively` runs, not freeform code-writing.
- Manual scenario test: invoke `implement-cohesively` with a delta-ledger that has 3 entries; verify three plans are persisted at `docs/history/plans/` and three cross-review dispatches happen.
- Manual scenario test: invoke `implement-cohesively` without Superpowers installed; verify the skill stops with a hard error and recommends installation.
- `validate_plugin.sh` updates (deferred to implementation pass): add `implement-cohesively` to `expected_skills`; add `delta-coverage-reviewer` to the agent set; add `implement-cohesively` to `verdict_led_skills` (verdict-leads check 13a) and the `prereq_subskills` list (canonical prereq-question check 10) — adapting the latter for the workflow-prereq form rather than the discovery-prereq form.

## What this rewrite *did not* do

- Implementation code: not changed. The new SKILL body, agent body, matrix cells, gotchas, and invariant are all docs.
- Tests: not changed (specifications proposed for follow-up).
- CI: not changed. `scripts/validate_plugin.sh` and `.github/workflows/validate.yml` are unmodified; the validator's hardcoded skill set still names the original 8 skills, which means the validator currently does not check `implement-cohesively`'s frontmatter, voice citation, prereq-question shape, or verdict-leads compliance. The implementation pass updates the validator.
- The deferred `plan-implementation` skill was not created. Its function lives in the phase loop (substrate-shape) plus `superpowers:writing-plans` (TDD-shape).

## Remaining ambiguity

Things the rewrite couldn't fully resolve and that the fresh-eyes reviewer should flag:

- **Phase ordering when multiple delta entries are mutually independent.** The phase-derivation matrix specifies predecessor relationships for cross-cell dependencies (P003 before P001 that uses the renamed concept; P005 before phases touching the invariant's runtime path). It does not specify a global ordering when two phases have no inter-dependency. The matrix's "Rules" section says the implementer may interleave or order by code-locality concerns. This is intentional flexibility; whether the reviewer agrees is a fresh-eyes question.
- **Branch shape default.** `implement-cohesively`'s "Branch shape" section says implementation lands on the rewrite's `design/<slug>` branch by default, with `implement/<slug>` as the alternative for split-merge cases. The default is "one-branch-end-to-end"; this is a real design decision but only documented in one place. The reviewer should verify it does not contradict any composition-with-superpowers prose.
- **Coverage table format.** The `implement-cohesively` Output format names a coverage table but doesn't fully specify the table's column order or how Phase 1's pre-execution coverage table relates to the post-execution coverage status reported in the final output. The implementation pass will resolve this; the spec leaves the door open.
- **Bypass legitimacy boundary.** The validate-rewrite decision matrix's third row ("Hand off to Superpowers without delta-coverage discipline") is a documented bypass of `IMPLEMENTATION_PLAN_COVERS_DELTA`. The bypass is named in the invariant doc and in the gotcha doc. Whether the bypass should require explicit user opt-in (a verbose acknowledgment) or whether the docstring footer is enough is a fresh-eyes question.
- **Token cost at scale.** `delta-coverage-reviewer` runs once per phase. A 10-phase implementation pass dispatches 10 reviewer agents on top of the 10 `writing-plans` and 10 `executing-plans` invocations. The cost is acknowledged in the ARCHITECTURE.md "Risks the design accepts" section but no concrete budget is set. The reviewer should flag whether v0.1 should ship with a pre-flight phase-count estimate.

## Ready for fresh-eyes review?

**Yes** — proceeding to `cohesive:validate-rewrite`.

## How to read this ledger

1. Read the "Approved direction" line and know the destination: ship `implement-cohesively` as v0.1; orchestrate-not-drive; per-phase `writing-plans`.
2. Skim "Conceptual changes" to know what's *different*.
3. Read "Files rewritten" with before/after summaries to verify each rewrite hits the right thing.
4. Use "Remaining ambiguity" as the focused fresh-eyes punch list.
5. After the first `validate-rewrite` pass, see "Repair pass 1" below for the tightening that closed three blockers and five important issues from the first review.

## Repair pass 1 — 2026-05-04

The first `cohesive:validate-rewrite` returned **Issues Found** with three blockers and five important issues. Repair pass 1 closes all eight in the same worktree, in place. Validation review at `docs/history/reviews/2026-05-04-implement-cohesively-rewrite-validation.md`.

### Files rewritten in repair pass 1

- `skills/implement-cohesively/SKILL.md`
  - **B1 (numbering schism).** `## Process` body sections renamed: `### 0. Resolve inputs` and `### 4. Hand off` are now `### Step 0` and `### Step 4` (preflight and handoff bookends, not phases). `### 1. Derive phases`, `### 2. For each phase, run the loop`, and `### 3. Final substrate review` are now `### Phase 1`, `### Phase 2`, `### Phase 3`. Hard constraint #5 updated to reference Phase 3 (was implicit "the last phase / the final substrate review" in mixed vocabulary). A short paragraph at the top of `## Process` makes the Step/Phase distinction explicit and pins the phase labels for citation by the invariant. Anti-patterns table updated: "Skipping the final substrate review" → "Skipping the final substrate review (Phase 3)"; new row added for the auto-loop-past-first anti-pattern (cross-references the new Phase 2c escalation rule).
  - **I2 (escalation rule).** Phase 2c gains an explicit **Escalation rule** paragraph: each phase gets at most one repair cycle; if the post-repair re-dispatch still returns Drift or Incomplete, the skill stops with verdict `Phase Drift`, surfaces findings to the user, and refuses to advance. The skill does not auto-loop a third time. Acceptance criteria gains a corresponding line.
  - **I4 (coverage table relation).** Phase 1's coverage-table description specifies the column shape explicitly and states that the Phase 1 coverage table and the final Phases table are the same table at two points in time, with `Plan` and `Cross-review` columns initialized to `pending`. Acceptance criteria updated to match.

- `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`
  - **B1 (numbering schism).** §Runtime paths and §Enforcement updated: "Phase 4" → "Phase 3" (the final substrate review). Inline references to Phase 1, Phase 2, Phase 3 now match the SKILL body's labels. §Enforcement's commit-citation line names the SKILL section by its new label ("Phase 2d. Commit the phase").
  - **I1 (invariant scope undercount).** §Scope §Applies-to extends to the alternative `implement/<slug>` child branch. §Runtime paths' branch-commit row now reads "`design/<slug>` or `implement/<slug>` branch commit messages." §Enforcement's deferred CI grep description names both branch shapes.
  - **I3 (bypass handshake).** §Known bypass risks specifies the convention: when the user picks the bypass row in the validate-rewrite decision matrix, `validate-rewrite` renders the literal acknowledgment line `Implementation may drift from the rewrite; the IMPLEMENTATION_PLAN_COVERS_DELTA invariant does not apply.` before invoking `superpowers:writing-plans`. The acknowledgment lands in the conversation transcript; v0.1 does not require it in commit history.
  - History entry appended for repair pass 1.

- `skills/validate-rewrite/SKILL.md`
  - **I3 (bypass handshake).** Output format's Approved-verdict block gains a **Bypass acknowledgment** paragraph immediately after the decision matrix table. The literal acknowledgment line is named verbatim. The convention is enforced by reviewer judgment in `cohesive:review-codebase` (no automated check in v0.1).

- `docs/substrate/matrices/router.md`
  - **B2 (six-routes drift).** §Purpose updated: "selects one of six routes" → "selects one of seven routes." The branchy-dimensions clause now names the third dimension explicitly (verb tense including implementation-imperative; scope hint including approved-rewrite-present). The dispatch contract grid was already correct in the original rewrite — it lists seven rows; only the prose summary was stale.

- `docs/substrate/designs/skill-conventions.md`
  - **B2 (six-routes drift).** §Router conventions §1 canonical route enumeration now includes `implement` between `rewrite-only` and `artifact`.
  - **I5 (validate-rewrite footer placement).** §"When sections may differ" gains a fourth accepted deviation: `validate-rewrite` places `### Recommended next Cohesive skill` inside its rendered review template (where the verdict-branch decision matrix lives) rather than as a standalone trailing heading. Documented as acceptable because `validate-rewrite`'s output *is* a review document with its own internal structure; per-verdict recommendations follow the canonical heading and the convention is satisfied. No other skill should adopt this shape without an entry here.

- `ARCHITECTURE.md`
  - **B3 (skill count drift).** §Three-tier architecture line previously read "the router (`cohesively`) and eight subskills"; now reads "the router (`cohesively`) plus eight subskills make nine skills total." Aligns with §"v0.1 scope" which already said "9 skills."

### Files added in repair pass 1

None. All repairs are edits to files already in the worktree.

### Files removed or deprecated in repair pass 1

None.

### Conceptual changes in repair pass 1

| Old concept | New concept | Status |
|---|---|---|
| `Step 1..4` in `implement-cohesively` Process body | `Step 0` (preflight), `Phase 1`, `Phase 2`, `Phase 3`, `Step 4` (handoff) | Renamed |
| "Phase 4" referring to the final substrate review | "Phase 3" referring to the final substrate review | Renumbered |
| Phase 1 coverage table and final Phases table as separate artifacts | Same table at two points in time | Clarified |
| Implicit "loop until covered" in Phase 2c | Explicit "one repair cycle, then `Phase Drift`" escalation rule | Tightened |
| Invariant scope: `design/<slug>` branches | Invariant scope: `design/<slug>` or `implement/<slug>` branches | Extended |
| Bypass row in validate-rewrite decision matrix without specified handshake | Bypass row with literal acknowledgment-line convention | Tightened |

### Substrate updated in repair pass 1

- Specs: 5 (`implement-cohesively/SKILL.md`, `validate-rewrite/SKILL.md`, `skill-conventions.md`, `router.md`, `ARCHITECTURE.md`)
- Behavior matrices: 1 (`router.md` — prose only, no cell changes)
- Named invariants: 1 (`IMPLEMENTATION_PLAN_COVERS_DELTA` — scope and rule-citation tightened)
- Gotchas: 0
- Semantic linter specs (proposed): 0 new (the existing branch-citation lint description in the invariant now names both branch shapes)

### Tests / checks proposed (not yet implemented) in repair pass 1

- Lint check (deferred V1): `validate-rewrite/SKILL.md` Output format must contain the literal bypass-acknowledgment line. A grep on the SKILL body verifies presence; runtime enforcement is reviewer-judged.

### Remaining ambiguity after repair pass 1

The original "Remaining ambiguity" punch list is reduced:

- **Phase ordering when delta entries are mutually independent.** Unchanged — still intentional flexibility for the implementer; a fresh-eyes question about whether to tighten further.
- **Branch shape default.** Closed by I1 — the invariant's scope and the SKILL's "Branch shape" section now agree explicitly that both `design/<slug>` and `implement/<slug>` are in scope.
- **Coverage table format.** Closed by I4 — column shape and lifecycle pinned in the SKILL body.
- **Bypass legitimacy boundary.** Closed by I3 — convention is the literal acknowledgment line, named verbatim in both the SKILL body and the invariant's bypass-risks section.
- **Token cost at scale.** Unchanged — risk acknowledged in ARCHITECTURE.md, no concrete budget set; a fresh-eyes question about whether to ship a pre-flight phase-count estimate.

### Ready for second fresh-eyes review?

**Yes** — proceeding to `cohesive:validate-rewrite` (pass 2).

## Repair pass 2 — 2026-05-05

The second `cohesive:validate-rewrite` returned **Approved** with four non-blocking notes (I1–I4 from validation pass 2 at `docs/history/reviews/2026-05-05-implement-cohesively-rewrite-validation-pass2.md`). Repair pass 2 closes all four in place before the implementation pass begins, so the implementation pass's coverage table reflects only code work and the substrate is internally consistent before any code lands.

### Files rewritten in repair pass 2

- `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`
  - **I1 (bypass-acknowledgment surface contradiction).** §Review checklist's bypass row rewritten to ask whether the literal acknowledgment line was rendered in the conversation transcript before `superpowers:writing-plans` was invoked. The line explicitly notes that commit-history landing of the acknowledgment is a future tightening, not a v0.1 expectation. The contradiction with §Known bypass risks is removed; both surfaces now agree that v0.1 enforcement is transcript-only.

- `docs/substrate/matrices/phase-derivation.md`
  - **I2 (cross-run reproducibility).** §Rules' "the implementer may interleave" line extends to name the consequence: within each predecessor-respecting tier, phase order is stable per run but not guaranteed identical across runs. Reviewers comparing two runs compare by delta-entry stable IDs, not phase numbers. Cites `delta-coverage-reviewer` for the parallel rule.

- `agents/delta-coverage-reviewer.md`
  - **I2 (cross-run reproducibility).** §"What you must not do" gains a new rule: do not identify phases by phase number across runs. Phase numbers are run-local because of the matrix's non-determinism rule; the delta-entry stable IDs are the cross-run-invariant identifiers.

- `skills/implement-cohesively/SKILL.md`
  - **I3 (dispatch budget surfacing).** Phase 1 gains a new paragraph after the coverage-table description: surface the phase count and `delta-coverage-reviewer` dispatch count to the user; pause for confirmation when the count exceeds 8. The threshold is a tunable v0.1 default. New acceptance criterion mirrors the rule.

- `docs/substrate/gotchas/no-implementation-handoff.md`
  - **I4 (bypass-acknowledgment pin missing from gotcha).** §"Tests / checks that preserve this" gains a fourth bullet naming the bypass-acknowledgment pin: the literal acknowledgment string must render in the transcript before `superpowers:writing-plans` is invoked from the validate-rewrite decision matrix's bypass row. Cross-references the SKILL.md and invariant doc that carry the rule. Deferred V1 lint check: grep `validate-rewrite/SKILL.md` for the literal string.

### Files added in repair pass 2

None.

### Files removed or deprecated in repair pass 2

None.

### Conceptual changes in repair pass 2

| Old concept | New concept | Status |
|---|---|---|
| §Review checklist asks for commit-history evidence of bypass; §Known bypass risks says transcript-only | Both surfaces agree: transcript-only in v0.1; commit-history is a future tightening | Reconciled |
| Cross-run phase ordering is "intentional flexibility" with no consequence named | Cross-run phase numbers are run-local; delta-entry stable IDs are the cross-run-invariant identifiers (matrix + reviewer agent agree) | Tightened |
| `implement-cohesively` Phase 1 has no dispatch-budget surface | Phase 1 announces phase count + `delta-coverage-reviewer` dispatch count; pauses past the v0.1 default threshold of 8 phases | Added |
| `no-implementation-handoff` gotcha's pin list omits the bypass-acknowledgment pin | Pin list includes the bypass-acknowledgment pin with literal-string reference and deferred lint check | Tightened |

### Substrate updated in repair pass 2

- Specs: 2 (`implement-cohesively/SKILL.md`, `delta-coverage-reviewer.md`)
- Behavior matrices: 1 (`phase-derivation.md`)
- Named invariants: 1 (`IMPLEMENTATION_PLAN_COVERS_DELTA.md`)
- Gotchas: 1 (`no-implementation-handoff.md`)
- Semantic linter specs (proposed): 1 new (deferred V1 grep for literal bypass-acknowledgment string)

### Tests / checks proposed (not yet implemented) in repair pass 2

- `validate_plugin.sh` (deferred to implementation pass): grep `skills/validate-rewrite/SKILL.md` for the literal bypass-acknowledgment string.

### Remaining ambiguity after repair pass 2

None. All five pass-1 ambiguities and all four pass-2 notes are now closed in substrate.

### Ready for implementation?

**Yes** — proceeding to `superpowers:writing-plans` against the polished delta. The implementation pass's surface is small (validator updates + manual scenarios + branch finishing) because the substrate-shaped artifacts (SKILLs, agent, matrices, gotchas, invariant) are read by Claude at invocation time and are already in place on this branch.
