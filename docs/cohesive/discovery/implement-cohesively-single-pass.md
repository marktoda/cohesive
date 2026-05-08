# Substrate Discovery — implement-cohesively single-pass redesign

## Substrate discovered

### Target change surface
- Subsystem: `cohesive:implement-cohesively` skill and its substrate ripple
- Main files likely involved:
  - `skills/implement-cohesively/SKILL.md`
  - `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`
  - `docs/substrate/matrices/phase-derivation.md`
  - `docs/substrate/matrices/artifact-placement.md`
  - `docs/substrate/gotchas/skipping-per-phase-plan.md`
  - `docs/substrate/gotchas/plans-as-run-scaffolding.md`
  - `docs/substrate/architecture/handoffs.md`
  - `docs/substrate/architecture/composition-with-superpowers.md`
  - `agents/delta-coverage-reviewer.md`
  - `references/templates/chat-trailer.md`
  - `references/verdict-vocabulary.md`
  - `skills/cohesively/SKILL.md`
- Neighboring subsystems: `validate-rewrite` (upstream contract); `review-diff` (downstream end-reviewer)

### Relevant specs/docs
- `skills/implement-cohesively/SKILL.md` — current skill; encodes Phases 1/2/3/3.5 + Step 0/4. Phase 1 derives phases via `phase-derivation.md`. Phase 2c per-phase `delta-coverage-reviewer` dispatch. Escalation rule caps repair at one cycle → Phase Drift halt.
- `docs/substrate/architecture/composition-with-superpowers.md` — names the seam: Cohesive owns substrate-shape (delta-derived phase intent + per-phase cross-review + final substrate review); Superpowers owns TDD-shape (per-phase plan + execution). Composition table at line 9–17 lists `writing-plans` and `executing-plans` invoked **per phase** by `implement-cohesively`.
- `docs/substrate/architecture/handoffs.md` — multiple sections normatively name Phase 1/2/3/3.5 and the Phase Drift / Substrate Drift verdicts (lines 25–30 chain diagram, 127–137 Approved-branch contract, 197–242 chain exits).
- `docs/substrate/architecture/fresh-eyes-review.md` (not read this pass; cited from skill-body anti-patterns) — substrate principle requiring reviewer agents not inherit calling-skill conversation context.

### Behavior matrices
- Existing: `docs/substrate/matrices/phase-derivation.md` — 8 cells (P001–P008) mapping delta-ledger sections to phase intent shapes; this matrix is the substrate-shaped seam between rewrite-specs output and writing-plans input. Predecessor relationships ordering rules at lines 39–42.
- Existing: `docs/substrate/matrices/artifact-placement.md` §"Lifecycle by artifact category" (lines 50–60) — `Per-phase plan` row classifies plans as Ephemeral with cleanup target `git rm docs/history/plans/<YYYY-MM-DD>-<slug>-phase-*.md`. The wildcard form encodes the multi-plan-per-slug assumption.
- Missing but likely needed: a verdict-synthesis matrix combining two end-reviewer outputs (delta-coverage-reviewer + cohesive:review-diff) into a single user-facing verdict. Currently undefined; the chat-trailer's `implement-cohesively` row at `references/templates/chat-trailer.md:93` assumes a single Phase 3 review feeds the spec-coverage line.

### Named invariants
- Existing: `IMPLEMENTATION_PLAN_COVERS_DELTA` at `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`. Rule #1 maps every delta entry to ≥1 *phase*. Rule #2 mandates per-phase plan persistence at `docs/history/plans/<...>-phase-<N>.md`. Rule #4 mandates per-phase delta-coverage-reviewer Covered verdict. Rule #6 gates Phase 3.5 cleanup on Implemented verdict. The rule's predicate vocabulary is phase-shaped throughout — every reformulation under the new shape requires removing "phase" from the predicate.
- Candidate invariants: a new invariant `IMPLEMENTATION_END_REVIEWERS_DISPATCH_PARALLEL` could pin the dual-reviewer end-of-run contract, but probably overkill — the skill body's hard constraint is sufficient at v0.1.

### Existing enforcement
- Tests: none found in the repo (this is a skill-pack, not a code library); enforcement is via reviewer agent verdicts and `validate_plugin.sh` lint checks.
- Constraints: `skills/implement-cohesively/SKILL.md` Hard constraints #3 (per-phase cross-review mandatory), #4 (coverage structural), #5 (final substrate review mandatory), #6 (Phase 3.5 cleanup gated). All four reformulate or delete under the new shape.
- CI checks: `.github/workflows/validate.yml` runs `validate_plugin.sh`; the script doesn't grep for phase-shaped tokens specifically.
- Semantic linters: `delta-coverage-reviewer` agent at `agents/delta-coverage-reviewer.md` is the per-phase cross-review enforcement. Input contract (lines 32–48) names: delta-ledger excerpt, plan path, phase diff. The agent's "What you must not do" §"Read other phases' plans or diffs" (line 110) is a per-phase isolation rule that obsoletes under whole-branch dispatch.

### Known gotchas / scars
- `docs/substrate/gotchas/skipping-per-phase-plan.md` — entire gotcha is about why per-phase `writing-plans` + per-phase cross-review is structurally necessary. The "Tempting wrong fix" at lines 39–41 explicitly considers and rejects "produce one plan for the entire implementation pass" — the proposed redesign IS the rejected path. The gotcha's reasoning ("the cross-review is per-phase by design") was correct under the assumption that per-phase cross-review earned its keep; the user's empirical observation (slow + abandons halfway) is the new evidence reopening the question.
- `docs/substrate/gotchas/plans-as-run-scaffolding.md` — about plan ephemerality; survives the redesign in modified form (one plan instead of many).

### Locality boundaries
- Cohesive↔Superpowers seam at `docs/substrate/architecture/composition-with-superpowers.md` — the composition table currently couples to per-phase shape; redesign loosens this (one writing-plans + one executing-plans per implementation pass, not per phase).
- delta-ledger ↔ writing-plans seam at `docs/substrate/matrices/phase-derivation.md` — currently encoded as 8 cells. Redesign collapses this seam; the delta ledger is passed to writing-plans as intent directly without translation through the matrix.
- Suspected premature centralization: phase-derivation matrix as a translation layer. Under the redesign, writing-plans handles its own task ordering inside whatever scope it's given; the matrix becomes ceremony.

### Missing memory
- **No gotcha for mega-plan abandonment risk** — `skills/implement-cohesively/SKILL.md:80` documents a dispatch-budget surfacing at >8 phases, but the underlying concern (single writing-plans/executing-plans calls overflowing context on large deltas) has no gotcha. If the redesign collapses to one plan, this risk migrates from "many phases" to "one mega-plan" and warrants explicit substrate. The artifact that would close this: a new gotcha at `docs/substrate/gotchas/large-delta-mega-plan.md` documenting the abandonment cliff and the structural mitigation (delta-size-budget surfacing in the redesigned skill body).
- **No verdict-synthesis matrix** — `references/templates/chat-trailer.md:93` `implement-cohesively` row currently encodes a single Phase 3 verdict driving the `## Code matches locked design` slot. Redesign introduces two parallel reviewers; no substrate names how their verdicts combine. The artifact that would close this: a small matrix or §"Verdict synthesis" subsection in `skills/implement-cohesively/SKILL.md` enumerating the 2×N verdict combinations and the user-facing label for each.
- **No documented relationship between fresh-eyes per-phase and fresh-eyes end-of-run** — `docs/substrate/architecture/fresh-eyes-review.md` (not read this pass) presumably establishes fresh-eyes as a property of every reviewer dispatch. The redesign moves all fresh-eyes work to end-of-run; whether this satisfies the architecture doc's intent or weakens it needs a note. The artifact that would close this: a paragraph in either `fresh-eyes-review.md` or `composition-with-superpowers.md` clarifying that fresh-eyes applies *per dispatch* (preserved), not *per phase* (per-phase is a separable property).
- **Verdict vocabulary `Phase Drift` token** — `references/verdict-vocabulary.md:56` carries `Phase Drift` as an internal label. Under the redesign, "phase" disappears from the skill's vocabulary; the appropriate replacements are `Coverage Drift` (delta-coverage-reviewer flagged missing entries) and `Substrate Drift` (review-diff flagged substrate violations). Currently `Substrate Drift` exists at line 57; `Coverage Drift` does not. The artifact that would close this: an updated row in the `implement-cohesively` table with the new internal labels and their user-facing translations.

### Next
- Continue with `brainstorm-design` Phase 1 (ground the brainstorm) using this report as substrate. *(`cohesive:brainstorm-design` — already invoked, this discovery is its Step 0.)* **Scope:** option space for redesigning `implement-cohesively` from a per-phase loop to a single-pass shape, with attention to the three open concerns (intent translation, mega-plan risk, drift-late detection) and the missing-memory items above.
