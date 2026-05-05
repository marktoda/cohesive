# Rewrite Validation Review — implement-cohesively

> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md

**Verdict:** Issues Found

## Executive judgment

The rewrite is implementable in shape but carries several internal-coherence drifts that a future contributor would predictably trip over. The largest is a numbering schism: the `implement-cohesively` skill body labels its sections "Step 0–4" (with no "Phase 4"), while Hard constraint #4, the Anti-pattern table, and the `IMPLEMENTATION_PLAN_COVERS_DELTA` invariant all reference "Phase 1," "Phase 2," "Phase 4" of that same skill — so the invariant's enforcement story points at section IDs the skill doesn't have. Pair that with two route-count drifts (router matrix still says "six routes," skill-conventions enumerates only six canonical route names), one ARCHITECTURE.md count drift (line 11 says "eight subskills," line 82 says "9 skills"), and one invariant scope hole around `implement/<slug>` child branches, and you have a rewrite that is approvable after a tightening pass — not before.

## Blocking issues

### B1. Numbering schism between skill body and invariant/anti-patterns

- **Severity:** Blocker
- **Category:** Spec drift / Enforcement
- **Why it matters:** The invariant `IMPLEMENTATION_PLAN_COVERS_DELTA` is the structural pin behind the whole route. Its "Runtime paths" section names "`implement-cohesively` Phase 1" and "`implement-cohesively` Phase 2 per-phase loop"; its "Enforcement" section says Hard constraint #4 enforces "Phase 1 acceptance" and #5 requires "final substrate review (Phase 4)." The skill body itself labels its sections `### 0. Resolve inputs`, `### 1. Derive phases`, `### 2. For each phase, run the loop`, `### 3. Final substrate review`, `### 4. Hand off` — there is no "Phase 4," and "Step 1 produces the coverage table," not "Phase 1." A reviewer cross-checking the invariant against the skill cannot match the citations. Future contributors editing either side will not know whether to renumber or to rename.
- **Evidence:** `skills/implement-cohesively/SKILL.md` Process section uses Steps 0–4; Hard constraint #4 and Anti-patterns table use "Phase 1," "Phase 2"; `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` Runtime paths and Enforcement use "Phase 1 / Phase 2 / Phase 4."
- **Recommended fix:** Pick one vocabulary. Either rename the skill's `### 1..4` to `### Phase 1..N` (cleaner because the matrix and invariant already use "phase"), or rewrite invariant + anti-patterns + acceptance criteria to say "Step 1" / "Step 3 final review."
- **Substrate artifact to add or update:** spec (`skills/implement-cohesively/SKILL.md`) + named invariant (`IMPLEMENTATION_PLAN_COVERS_DELTA.md`).

### B2. Router-matrix and skill-conventions still claim "six routes"

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** A new contributor reading `docs/substrate/matrices/router.md` ("selects one of six routes") will believe the router has six routes; the dispatch contract grid below it lists seven, including `implement`. Skill-conventions §"Router conventions" enumerates the canonical route names and omits `implement` entirely, so a reviewer using that list as the reference set will flag valid `implement` announcements as nonconforming. Router and conventions are the test artifacts for the router skill body; both must move with the SKILL.
- **Evidence:** `docs/substrate/matrices/router.md` Purpose section ("six routes"); `docs/substrate/designs/skill-conventions.md` Router conventions §1 (canonical route names omit `implement`); `skills/cohesively/SKILL.md` Required behavior #1 correctly enumerates seven including `implement`.
- **Recommended fix:** In router.md change "six routes" → "seven routes." In skill-conventions.md add `implement` to the canonical-route enumeration.
- **Substrate artifact to add or update:** matrix (`router.md`) + spec (`skill-conventions.md`).

### B3. ARCHITECTURE.md inconsistent skill counts

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** Line 11 says "The router (`cohesively`) and eight subskills"; v0.1 scope line says "9 skills." Line 11 is wrong post-rewrite — eight subskills + the router would be nine total skills, but the v0.1 scope line counts the router *in* the nine, so "eight subskills" describes the pre-rewrite reality. ARCHITECTURE.md is named in skill-conventions as the binding architectural map. Self-contradiction here forces every reader to pick.
- **Evidence:** `ARCHITECTURE.md` line 11 ("eight subskills") vs §"v0.1 scope" ("9 skills"); README "What's in the box" lists 9 skill directories; delta ledger says "9 skills."
- **Recommended fix:** Change line 11 to use a phrasing consistent with §"v0.1 scope" — e.g. "The router (`cohesively`) plus eight subskills (nine skills total)." Pick a phrasing and use it consistently.
- **Substrate artifact to add or update:** spec (`ARCHITECTURE.md`).

## Important issues

### I1. Invariant scope undercounts the implement/<slug> child branch

- **Severity:** High
- **Category:** Invariant / Locality
- **Why it matters:** `IMPLEMENTATION_PLAN_COVERS_DELTA.md` §Scope says the invariant applies to "every per-phase commit on a `design/<slug>` (or child) branch." The skill body's "Branch shape" section names `implement/<slug>` as the alternative branch. The invariant's "Runtime paths" and the deferred CI-grep description name only `design/<slug>` branches — "every commit on a `design/<slug>` branch produced by `implement-cohesively`." If a user picks the split-merge `implement/<slug>` shape, the deferred lint as currently scoped won't grep those commits, so the enforcement story has a hole.
- **Evidence:** `IMPLEMENTATION_PLAN_COVERS_DELTA.md` §Scope, §Runtime paths, §Enforcement; `skills/implement-cohesively/SKILL.md` §Branch shape.
- **Recommended fix:** Replace "design/<slug> branch" with "design/<slug> or implement/<slug> branch produced by implement-cohesively" everywhere in §Runtime paths and §Enforcement. Add an explicit row to the §Review checklist for the alt-branch case.
- **Substrate artifact to add or update:** named invariant (`IMPLEMENTATION_PLAN_COVERS_DELTA.md`).

### I2. "After one repair cycle" escalation rule is underspecified

- **Severity:** High
- **Category:** Vague language / Test
- **Why it matters:** Step 2c says "Loop until Covered or escalate to user after one repair cycle" — the only guard against infinite repair loops. But "escalate" is undefined: does the skill stop, prompt, surface a verdict, or recurse? The output-format verdict vocabulary (`Implemented / Phase Drift / Substrate Drift / Aborted`) suggests "Phase Drift" with a halt; the skill body never says so. A future contributor will improvise.
- **Evidence:** `skills/implement-cohesively/SKILL.md` Step 2c last sentence.
- **Recommended fix:** Tighten 2c: "After one repair cycle that still returns Drift/Incomplete, stop with verdict `Phase Drift` and surface the reviewer's findings to the user; do not auto-loop a third time." Add the rule to acceptance criteria.
- **Substrate artifact to add or update:** spec (`implement-cohesively/SKILL.md`) + acceptance criteria entry.

### I3. Bypass legitimacy boundary unresolved

- **Severity:** High
- **Category:** Enforcement
- **Why it matters:** The validate-rewrite Approved decision matrix's third row ("Hand off to Superpowers without delta-coverage discipline") bypasses `IMPLEMENTATION_PLAN_COVERS_DELTA`. The invariant's §Known bypass risks documents this. But the user-opt-in mechanic is not specified anywhere: does the user have to type a verbose acknowledgment? Type a flag? Click through? The decision matrix lists it as a column choice without describing the handshake. A future Claude consuming the matrix has no rule to follow.
- **Evidence:** `skills/validate-rewrite/SKILL.md` Output format §"Recommended next Cohesive skill" Approved table row 3; `IMPLEMENTATION_PLAN_COVERS_DELTA.md` §Known bypass risks.
- **Recommended fix:** Add to validate-rewrite §Output format: "If the user picks row 3, surface the bypass acknowledgment line `'Implementation may drift from the rewrite; the IMPLEMENTATION_PLAN_COVERS_DELTA invariant does not apply.'` before invoking writing-plans, so the bypass is recorded in transcript." Cite the rule from the invariant doc.
- **Substrate artifact to add or update:** spec (`validate-rewrite/SKILL.md`) + invariant cross-link.

### I4. Coverage table format unspecified across pre/post execution

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** Step 1 says Phase 1 (Step 1) renders a coverage table; the Output format block also renders a "Phases" table after execution. The relationship between the pre-execution and post-execution tables — same shape? union? — is left to the implementer. The ledger acknowledged this (§Remaining ambiguity #3) but the spec rewrite did not close it.
- **Evidence:** `skills/implement-cohesively/SKILL.md` Step 1 (Phase 1 coverage table) vs §Output format (Phases table).
- **Recommended fix:** Specify column order and identity in one place, then have the other reference it. E.g. "The Phase 1 coverage table uses the same column shape as the final Phases table; Phase 1 leaves the `Cross-review` column as `pending`."
- **Substrate artifact to add or update:** spec (`implement-cohesively/SKILL.md`).

### I5. validate-rewrite Output format misplaces the Recommended-next footer

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** Skill-conventions §"Recommended-next-skill footer" requires every skill to end its Output format with `### Recommended next Cohesive skill`. `validate-rewrite/SKILL.md` Output format puts "Recommended next" *inside* the rendered review body, with the decision-matrix table appearing under that heading — but the heading is now nested in the review template rather than serving as the canonical footer. A future skill author copy-pasting the convention's exemplar will not match this skill's actual shape.
- **Evidence:** `skills/validate-rewrite/SKILL.md` Output format block; `docs/substrate/designs/skill-conventions.md` §"Recommended-next-skill footer."
- **Recommended fix:** Restructure validate-rewrite's Output format to put the decision matrix under the canonical `### Recommended next Cohesive skill` heading, or document this as an accepted deviation in skill-conventions §"When sections may differ."
- **Substrate artifact to add or update:** spec (`validate-rewrite/SKILL.md`) or convention deviation entry.

## Substrate gaps

(Covered under Blocking and Important — no additional gaps surfaced.)

## Locality concerns

(Covered under I1 — invariant scope and skill body's Branch shape section drift; the rest of the rewrite preserves locality cleanly.)

## Future-fit concerns

(None blocking. The composition-with-superpowers.md "When to revisit" section names the next forecasted shifts; that is correct future-fit work.)

## Enforcement concerns

- The deferred CI grep in `IMPLEMENTATION_PLAN_COVERS_DELTA` covers `design/<slug>` branches only (see I1). Tighten before promotion.
- The bypass handshake (I3) is not enforced anywhere. Decide whether it's a runtime check or transcript convention; either way, name it.

## Vague language to tighten

- `skills/implement-cohesively/SKILL.md` Step 2c — "escalate to user after one repair cycle" (see I2).
- `skills/implement-cohesively/SKILL.md` Step 2 phase ordering rules — "may interinleave or order by code-locality concerns; the matrix does not enforce a single global order" (this is intentional flexibility per the ledger; flag for the implementer to confirm during the implementation pass).

## Recommended repairs (ranked)

1. Reconcile Step/Phase numbering across `implement-cohesively/SKILL.md` and `IMPLEMENTATION_PLAN_COVERS_DELTA.md` (B1).
2. Update router.md "six routes" and skill-conventions canonical-route enumeration to include `implement` (B2).
3. Reconcile ARCHITECTURE.md skill count phrasings (B3).
4. Extend invariant scope to cover `implement/<slug>` child branches (I1).
5. Specify the "after one repair cycle, escalate" mechanic concretely (I2).
6. Specify the bypass acknowledgment handshake (I3).
7. Clarify pre vs post-execution coverage table relation (I4).
8. Reconcile validate-rewrite Output format with the recommended-next footer convention (I5).

## What looked right

- The seam redrawing in `composition-with-superpowers.md` is unusually clear: the four-tier composition ladder (loose / tight / recommendation / phase-boundary doc) names exactly what the previous "three forms" surface lacked. The "Alternatives considered" §"No `cohesive:implement-cohesively`" entry preserves the rejected v0.1 shape with its scar pointer — a future contributor will not re-litigate.
- `delta-coverage-reviewer.md` is well-disciplined: the "What you must not do" forbids cross-phase reading explicitly (a non-obvious risk), keeps token discipline tight (≤400 words / ≤5 findings), and pre-empts the "absence of negative findings = good" trap. Per-phase review is a new dispatch site and the agent file lands clean.
- `phase-derivation.md` cells P001–P008 plus P900–P902 cover the eight ledger sections with predecessor relationships named explicitly and with one explicit-no-phase case (P008 default = Deferred). The matrix is the substrate-shaped seam the ledger names; it does the job.
- The `no-implementation-handoff.md` gotcha names both tempting wrong fixes (stronger prose; router auto-invoking Superpowers) and rejects them with structural reasons. This is the shape gotchas should take.

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — repair the blocking issues in the same worktree, then re-run `cohesive:validate-rewrite`. The rewrite is approvable after a tightening pass; the design itself is sound.
