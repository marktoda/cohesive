# Composition with Superpowers

> Cohesive composes with Superpowers rather than reinventing implementation discipline. Cohesive owns substrate (specs, invariants, gotchas, matrices, reviews) and the delta-derived phase shape that drives implementation; Superpowers owns the per-phase plan and TDD execution inside each phase, plus worktrees and branch finishing. The seam between the two is documented and intentional.

## What

When Superpowers is installed alongside Cohesive, specific Cohesive workflows delegate to Superpowers skills:

| Need | Cohesive component | Superpowers skill it calls |
|---|---|---|
| Worktree creation for design rewrites | `skills/rewrite-specs/SKILL.md` | `superpowers:using-git-worktrees` |
| Per-phase plan authoring (delta-derived intent → TDD plan) | `skills/implement-cohesively/SKILL.md` | `superpowers:writing-plans` |
| Per-phase TDD execution (plan → code) | `skills/implement-cohesively/SKILL.md` | `superpowers:executing-plans` |
| TDD discipline inside `executing-plans` | (consumed indirectly via Superpowers) | `superpowers:test-driven-development` |
| Branch finishing | (recommended after `implement-cohesively` Implemented verdict; user-invoked) | `superpowers:finishing-a-development-branch` |
| Code review for implementation quality | (after Cohesive's substrate review) | `superpowers:code-reviewer` |

Cohesive's worktree path has an inline fallback when Superpowers is absent (a 5-line snippet in `rewrite-specs/SKILL.md`). Cohesive's per-phase plan + execution path **does not** have a fallback — `implement-cohesively`'s Hard constraint #2 requires Superpowers. When Superpowers is not installed, `implement-cohesively` stops with a hard error and recommends installation; plan-writing and TDD execution are not 5-line operations and reinventing them inside Cohesive is exactly the duplication the seam exists to prevent.

## Why composition rather than reinvention

Two arguments justify the choice:

**Substrate vs implementation are different lenses.** Cohesive optimizes for *durable judgment*: would a future contributor make the right architectural choice, given the codebase's substrate? Superpowers optimizes for *disciplined implementation*: when the plan is clear, does the work happen in the right order with verification at each step? Both lenses are real; both have legitimate skills shipping today. Cohesive recreating Superpowers' worktree discipline, plan-writing, or TDD discipline would not improve substrate work and would duplicate logic that already has battle-tested behavior in Anthropic's official marketplace.

**Locality over centralization, applied between plugins.** The same principle Cohesive teaches inside a codebase ([`references/locality-over-centralization.md`](locality-over-centralization.md)) applies to plugin design. Two plugins doing similar things for similar reasons can compose. Cohesive embedding worktree discipline (different reasons — substrate-rewrite isolation vs implementation isolation) would couple two concerns that should evolve independently.

The same logic applies, more sharply, at the implementation seam. `implement-cohesively` orchestrates a phase loop where Cohesive owns *substrate-shape* (delta-derived phase intent; per-phase cross-review against the design delta ledger; final substrate review) and Superpowers owns *TDD-shape* (per-phase plan; TDD execution inside each phase; branch finishing). Collapsing those two shapes into one Cohesive skill would make Cohesive responsible for a category Superpowers already owns and would lose Cohesive's substrate-shape distinction in the resulting prose-only plan.

## The seam

Four forms of composition, in order of tightness:

### 1. Skill invocation with fallback (loose)

`skills/rewrite-specs/SKILL.md` says, in prose: "If `superpowers:using-git-worktrees` is available, invoke it. Otherwise use this 5-line bash fallback." The skill body presents both paths; Claude chooses based on availability.

The fallback is not a feature-equivalent reimplementation. It does the bare minimum (mkdir, gitignore, worktree add) — no baseline test run, no project-setup integration, no directory-selection heuristics. Users who need the fuller behavior install Superpowers.

### 2. Skill invocation without fallback (tight)

`skills/implement-cohesively/SKILL.md` invokes `superpowers:writing-plans` and `superpowers:executing-plans` per phase. There is no fallback. If Superpowers is not installed, the skill stops with a hard error.

The reason this seam is tighter than the worktree seam: plan-writing and TDD execution are not 5-line operations. A Cohesive-side fallback would either be a toy (defeating the whole purpose of substrate-shaped implementation) or a full reimplementation (duplicating Superpowers). Neither serves users. The hard-error path is honest: Cohesive's `implement-cohesively` requires Superpowers; the README's §"Recommended companion" reflects this.

### 3. Recommendation in skill output

Subskills' "Recommended next Cohesive skill" footer can recommend a Superpowers skill when the appropriate next step is outside Cohesive's substrate scope. Example: `validate-rewrite`'s "Approved" branch renders a decision matrix where one conditionally-rendered alternative is "Implement with Superpowers directly" via `superpowers:writing-plans` (the user accepts that implementation may drift from the rewrite; rendered when the rewrite is small enough that Cohesive's phased loop would be ceremony, per `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Conditional alternatives"). The default option, however, is `cohesive:implement-cohesively` — the substrate-shaped path that composes both plugins.

`superpowers:finishing-a-development-branch` is recommended (not invoked) after `implement-cohesively` Implemented verdict.

### 4. Documentation of phase boundary

The README (§"Recommended companion") and this design doc state the phase boundary: Cohesive shapes the target *and the substrate-shape of how to get there*; Superpowers shapes the per-phase plan and TDD execution path. Users running both plugins are expected to invoke Cohesive first (substrate / design / spec rewrite / fresh-eyes review / implementation-orchestration), with Superpowers consumed inside `implement-cohesively`'s phase loop and after `implement-cohesively`'s Implemented verdict (branch finishing). The router (`cohesively`) does not auto-invoke Superpowers directly — the `implement` route dispatches `cohesive:implement-cohesively`, which is the Cohesive skill that internally composes Superpowers per phase. Phase transitions remain user actions: the user picks the implementation route via the `validate-rewrite` Approved decision matrix, not by router auto-routing.

## Risks the seam accepts

**Trigger competition.** Both plugins ship skills with discovery-shaped descriptions. A user asking "what's in this codebase" can get either Cohesive's `discover-substrate` or Superpowers' research/exploration. The competition is documented in [`docs/substrate/gotchas/discovery-vs-superpowers.md`](../gotchas/discovery-vs-superpowers.md). The defense is descriptive narrowing (Cohesive's discovery is *substrate-specific*; Superpowers' is general) plus the canonical-router pattern (Cohesive workflows go through `cohesively`; users wanting Superpowers framing invoke Superpowers directly).

**Detection logic.** "If Superpowers is available" is currently an LLM-judgment, not a deterministic check. A future contributor copying `rewrite-specs`' fallback shape may always use the fallback, defeating composition. Mitigation: a future `references/composing-with-superpowers.md` reference doc, plus the pattern of consulting the harness's skill-availability listing as the detection rule.

**Version drift.** Superpowers ships independently. A Cohesive skill assuming a particular Superpowers skill name (e.g., `superpowers:using-git-worktrees`) will fail silently if Superpowers renames it. v0.1 accepts this risk; mitigation is to keep the surface narrow (only `using-git-worktrees` is consumed by Cohesive directly) and to maintain compatibility-checking via README installation notes.

## What Cohesive deliberately does not do

- **No Cohesive `using-worktrees` skill.** Plan §3 was explicit: own neither the worktree skill nor a parallel reimplementation. The 5-line fallback is the only Cohesive-side worktree code.
- **No Cohesive plan-writing skill.** `superpowers:writing-plans` produces the per-phase TDD plan inside `implement-cohesively`'s phase loop. Cohesive does not author TDD-shaped tasks itself; the phase intent passed to `writing-plans` is substrate-shape, and the translation to TDD-shape is Superpowers' job. See [`docs/substrate/gotchas/skipping-per-phase-plan.md`](../gotchas/skipping-per-phase-plan.md) for the failure mode that motivates this seam.
- **No Cohesive plan-execution skill.** `superpowers:executing-plans` consumes the per-phase plan and writes code with TDD discipline. Cohesive's `implement-cohesively` orchestrates the phase loop but never writes code itself.
- **No Cohesive code-reviewer skill.** Superpowers' `code-reviewer` is the implementation-quality lens; Cohesive's reviewer agents (substrate-alignment, structure, library-native, agent-readiness, delta-coverage, spec-cohesion) are the substrate lens. Both are useful for high-stakes review; both are intentionally distinct.
- **No Cohesive TDD or branch-finishing skill.** Superpowers owns these. `superpowers:finishing-a-development-branch` is recommended (not invoked) after `implement-cohesively` Implemented verdict.

## Failure modes this composition prevents

- **Reviewer-rule drift.** If Cohesive recreated worktree creation, two plugins would have two ways to create worktrees and a contributor would have to choose. Composition keeps one canonical path.
- **Substrate-vs-implementation conflation.** If Cohesive owned implementation skills, the substrate framing would dilute. The clear seam keeps each lens focused on its lens.
- **User confusion about what Cohesive is.** Cohesive's pitch is substrate-first design and review. Owning implementation skills would muddy that pitch.

## Failure modes this composition does not prevent (and why)

- **A user installs only Cohesive and asks for implementation.** `cohesive:implement-cohesively` stops with a hard error and recommends installing Superpowers. The `validate-rewrite` Approved decision matrix's "Implement with Superpowers directly" alternative also requires Superpowers. The "Land specs first" alternative is available without Superpowers but defers the implementation question to a future session. The user-facing message is honest: Cohesive's substrate-shaped implementation needs Superpowers' per-phase plan and execution skills; without them, only the spec rewrite lands.
- **A user installs only Superpowers and asks for substrate review.** Out of Cohesive's hands; same reasoning.

## Alternatives considered

**Hard dependency on Superpowers across the entire plugin.** Rejected: makes Cohesive un-installable for users who want only substrate work (review, audit, design, rewrite). The chosen shape — Superpowers required for `implement-cohesively`'s phase loop, optional for everything else — preserves optionality where the cost is bearable and accepts the dependency where the alternative is reinvention.

**Cohesive ships its own plan-writing and TDD execution skills.** Rejected: doubles the surface area, duplicates Superpowers' work, dilutes the substrate framing. The lighter Cohesive shape — owning *substrate-shaped phase intent* and *delta-coverage cross-review* — is what the substrate framing actually demands.

**Tighter coupling — `cohesively` router auto-invoking Superpowers directly.** Rejected: would make phase transitions invisible to the user. The current model (user-driven phase transitions; the `implement` route dispatches `cohesive:implement-cohesively`, not Superpowers directly) is more legible. Superpowers is consumed inside `implement-cohesively`'s phase loop, where the per-phase composition is structured and inspectable, rather than from the router where it would be hidden.

**No `cohesive:implement-cohesively`; users go straight to `superpowers:writing-plans` after `validate-rewrite` Approved.** This was the v0.1 pre-implement-cohesively shape. Rejected because it produced the failure mode documented in [`docs/substrate/gotchas/no-implementation-handoff.md`](../gotchas/no-implementation-handoff.md): Cohesive had no structural answer for "implement now," and freeform code-writing followed by default, bypassing the substrate the rewrite established. The `implement-cohesively` skill plus the `implement` route plus the sharpened `validate-rewrite` Approved decision matrix together close that gap.

## When to revisit

- If Superpowers ships a new discovery-shaped skill that conflicts more directly with `discover-substrate`. Update [`discovery-vs-superpowers.md`](../gotchas/discovery-vs-superpowers.md) and consider whether the seam needs strengthening.
- If Superpowers renames or restructures `writing-plans` or `executing-plans`. `implement-cohesively`'s Hard constraint #2 names these skills explicitly; a rename without a Cohesive-side update breaks the phase loop. Mitigation: Cohesive's CI does not currently grep Superpowers' skill set for compatibility; this is reviewer-judged.
- If the harness gains a deterministic "is plugin X installed?" mechanism, the LLM-judgment detection in `rewrite-specs/SKILL.md` and `implement-cohesively/SKILL.md` should be replaced with the deterministic check.
- If a future Cohesive skill genuinely needs to write code without going through `superpowers:executing-plans` (e.g., a substrate-shaped code generator that produces test stubs from behavior matrices). At that point, the seam shifts further — Cohesive owns substrate-shaped code generation, Superpowers retains generic plan execution. v0.1 has no such case; the phase loop's `superpowers:executing-plans` step covers the implementation surface for now.

## Related substrate

- [`docs/substrate/gotchas/discovery-vs-superpowers.md`](../gotchas/discovery-vs-superpowers.md) — the trigger-competition gotcha (front of the workflow).
- [`docs/substrate/gotchas/no-implementation-handoff.md`](../gotchas/no-implementation-handoff.md) — the reported scar this composition retires (back of the workflow).
- [`docs/substrate/gotchas/skipping-per-phase-plan.md`](../gotchas/skipping-per-phase-plan.md) — the failure mode that breaks the substrate↔TDD seam if `writing-plans` is skipped.
- [`docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`](../invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md) — the named invariant that pins delta coverage across the phase loop.
- [`docs/substrate/matrices/phase-derivation.md`](../matrices/phase-derivation.md) — the substrate-shape seam between design delta ledger and `superpowers:writing-plans`.
- [`references/locality-over-centralization.md`](../../../references/locality-over-centralization.md) — the principle this composition operationalizes.
- [`skills/rewrite-specs/SKILL.md`](../../../skills/rewrite-specs/SKILL.md) §"Worktree handling" — the loose composition (with fallback).
- [`skills/implement-cohesively/SKILL.md`](../../../skills/implement-cohesively/SKILL.md) §"Hard constraints" — the tight composition (no fallback).
- [`README.md`](../../../README.md) §"Recommended companion" — the user-facing version of this seam.
