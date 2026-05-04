# Composition with Superpowers

> Cohesive composes with Superpowers rather than reinventing implementation discipline. Cohesive owns substrate (specs, invariants, gotchas, matrices, reviews); Superpowers owns implementation (worktrees, plans, TDD, branch finishing). The seam between the two is documented and intentional.

## What

When Superpowers is installed alongside Cohesive, specific Cohesive workflows delegate to Superpowers skills:

| Need | Cohesive component | Superpowers skill it calls |
|---|---|---|
| Worktree creation for design rewrites | `skills/rewrite-specs/SKILL.md` | `superpowers:using-git-worktrees` |
| Implementation plan execution | (out of scope for Cohesive) | `superpowers:executing-plans` |
| TDD discipline during implementation | (out of scope for Cohesive) | `superpowers:test-driven-development` |
| Branch finishing | (out of scope for Cohesive) | `superpowers:finishing-a-development-branch` |
| Code review for implementation quality | (after Cohesive's substrate review) | `superpowers:code-reviewer` |

Cohesive does not require Superpowers. When Superpowers is absent, Cohesive provides minimal inline fallbacks for the operations it needs (e.g., a 5-line worktree-creation snippet in `rewrite-specs/SKILL.md`).

## Why composition rather than reinvention

Two arguments justify the choice:

**Substrate vs implementation are different lenses.** Cohesive optimizes for *durable judgment*: would a future contributor make the right architectural choice, given the codebase's substrate? Superpowers optimizes for *disciplined implementation*: when the plan is clear, does the work happen in the right order with verification at each step? Both lenses are real; both have legitimate skills shipping today. Cohesive recreating Superpowers' worktree discipline would not improve substrate work and would duplicate logic that already has battle-tested behavior in Anthropic's official marketplace.

**Locality over centralization, applied between plugins.** The same principle Cohesive teaches inside a codebase ([`references/locality-over-centralization.md`](../../../references/locality-over-centralization.md)) applies to plugin design. Two plugins doing similar things for similar reasons can compose. Cohesive embedding worktree discipline (different reasons — substrate-rewrite isolation vs implementation isolation) would couple two concerns that should evolve independently.

## The seam

Three forms of composition, in order of looseness:

### 1. Skill invocation with fallback

`skills/rewrite-specs/SKILL.md` says, in prose: "If `superpowers:using-git-worktrees` is available, invoke it. Otherwise use this 5-line bash fallback." The skill body presents both paths; Claude chooses based on availability.

The fallback is not a feature-equivalent reimplementation. It does the bare minimum (mkdir, gitignore, worktree add) — no baseline test run, no project-setup integration, no directory-selection heuristics. Users who need the fuller behavior install Superpowers.

### 2. Recommendation in skill output

Subskills' "Recommended next Cohesive skill" footer can recommend a Superpowers skill when the appropriate next step is implementation rather than more substrate work. Example: `validate-rewrite`'s "Approved" branch ends with a hand-off to `superpowers:writing-plans` rather than an internal Cohesive skill.

This is the common case for any Cohesive workflow that ends in "go implement now."

### 3. Documentation of phase boundary

The README (§"Recommended companion") and this design doc state the phase boundary: Cohesive shapes the target; Superpowers shapes the path. Users running both plugins are expected to invoke Cohesive first (substrate / design / spec rewrite / fresh-eyes review), then Superpowers (planning / TDD / execution / branch finishing). The router (`cohesively`) does not auto-invoke Superpowers — phase transitions are user actions.

## Risks the seam accepts

**Trigger competition.** Both plugins ship skills with discovery-shaped descriptions. A user asking "what's in this codebase" can get either Cohesive's `discover-substrate` or Superpowers' research/exploration. The competition is documented in [`docs/substrate/gotchas/discovery-vs-superpowers.md`](../gotchas/discovery-vs-superpowers.md). The defense is descriptive narrowing (Cohesive's discovery is *substrate-specific*; Superpowers' is general) plus the canonical-router pattern (Cohesive workflows go through `cohesively`; users wanting Superpowers framing invoke Superpowers directly).

**Detection logic.** "If Superpowers is available" is currently an LLM-judgment, not a deterministic check. A future contributor copying `rewrite-specs`' fallback shape may always use the fallback, defeating composition. Mitigation: a future `references/composing-with-superpowers.md` reference doc, plus the pattern of consulting the harness's skill-availability listing as the detection rule.

**Version drift.** Superpowers ships independently. A Cohesive skill assuming a particular Superpowers skill name (e.g., `superpowers:using-git-worktrees`) will fail silently if Superpowers renames it. v0.1 accepts this risk; mitigation is to keep the surface narrow (only `using-git-worktrees` is consumed by Cohesive directly) and to maintain compatibility-checking via README installation notes.

## What Cohesive deliberately does not do

- **No Cohesive `using-worktrees` skill.** Plan §3 was explicit: own neither the worktree skill nor a parallel reimplementation. The 5-line fallback is the only Cohesive-side worktree code.
- **No Cohesive plan-execution skill in v0.1.** `plan-implementation` and `implement-cohesively` are V1-deferred. Until they exist, Superpowers' planning + execution is the recommended path. Cohesive ends at "approved spec, ready for implementation."
- **No Cohesive code-reviewer skill.** Superpowers' `code-reviewer` is the implementation-quality lens; Cohesive's reviewer agents (substrate-alignment, structure, library-native, agent-readiness) are the substrate lens. Both are useful for high-stakes review; both are intentionally distinct.
- **No Cohesive TDD or branch-finishing skill.** Superpowers owns these.

## Failure modes this composition prevents

- **Reviewer-rule drift.** If Cohesive recreated worktree creation, two plugins would have two ways to create worktrees and a contributor would have to choose. Composition keeps one canonical path.
- **Substrate-vs-implementation conflation.** If Cohesive owned implementation skills, the substrate framing would dilute. The clear seam keeps each lens focused on its lens.
- **User confusion about what Cohesive is.** Cohesive's pitch is substrate-first design and review. Owning implementation skills would muddy that pitch.

## Failure modes this composition does not prevent (and why)

- **A user installs only Cohesive and asks for implementation.** Cohesive's recommended-next-step footer points at Superpowers. If the user doesn't install Superpowers, they get a recommendation rather than a working tool. This is acceptable: the alternative (Cohesive shipping a parallel implementation tool tier) was rejected as out of scope.
- **A user installs only Superpowers and asks for substrate review.** Out of Cohesive's hands; same reasoning.

## Alternatives considered

**Hard dependency on Superpowers.** Rejected: makes Cohesive un-installable for users who want only substrate work. The fallback shape preserves optionality.

**Cohesive ships its own implementation skills.** Rejected: doubles the surface area, duplicates Superpowers' work, dilutes the substrate framing.

**Tighter coupling — auto-invoking Superpowers from the router.** Rejected: would make phase transitions invisible to the user. The current model (user-driven phase transitions) is more legible and respects the user's control.

## When to revisit

- If Superpowers ships a new discovery-shaped skill that conflicts more directly with `discover-substrate`. Update [`discovery-vs-superpowers.md`](../gotchas/discovery-vs-superpowers.md) and consider whether the seam needs strengthening.
- If a Cohesive V1 skill genuinely needs to drive implementation (e.g., `implement-cohesively`). At that point, the seam may shift — Cohesive may own *substrate-shaped implementation tasks* (e.g., generating tests from a behavior matrix) while Superpowers retains generic implementation discipline.
- If the harness gains a deterministic "is plugin X installed?" mechanism, the LLM-judgment detection in `rewrite-specs/SKILL.md` should be replaced with the deterministic check.

## Related substrate

- [`docs/substrate/gotchas/discovery-vs-superpowers.md`](../gotchas/discovery-vs-superpowers.md) — the trigger-competition gotcha.
- [`references/locality-over-centralization.md`](../../../references/locality-over-centralization.md) — the principle this composition operationalizes.
- [`skills/rewrite-specs/SKILL.md`](../../../skills/rewrite-specs/SKILL.md) §"Worktree handling" — the only skill currently consuming Superpowers.
- [`README.md`](../../../README.md) §"Recommended companion" — the user-facing version of this seam.
