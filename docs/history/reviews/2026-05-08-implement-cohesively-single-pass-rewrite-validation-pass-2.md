# Rewrite Validation Review — implement-cohesively single-pass redesign (pass 2)

**Verdict:** Issues found — repair pass needed

## Executive judgment

The single-pass redesign is internally coherent and the pass-1 repairs hit cleanly across the Hard-constraint surfaces, the named invariant, the dual-reviewer dispatch contract, the chain-exit verdicts in `handoffs.md`, the verdict-vocabulary translation, the artifact-placement lifecycle, and the validator's Check 13f/13g. A careful future contributor reading the delta ledger plus `IMPLEMENTATION_PLAN_COVERS_DELTA.md` plus the `implement-cohesively` SKILL body alone could reproduce the new behavior. One Blocker survives the sweep, however: the **default Implementation-route card literal that `validate-rewrite` renders on every Approved verdict** still says "phase by phase against the delta ledger." That card is the chat-rendered hand-off into Build — the most-rendered surface in the entire chain — and its current literal contradicts every other normative claim the rewrite makes about single-pass shape. This is the same shape of finding the pass-1 review's B4 sweep closed elsewhere (it explicitly fixed `cohesion-review.md:121` "phase-by-phase"); the symmetric line in `validate-rewrite/SKILL.md:220` was missed.

## Delta at a glance

- **Files:** 13 rewritten, 2 added, 2 removed/deprecated
- **Conceptual changes:** per-phase loop → single-pass implementation; per-phase plan → per-pass plan; per-phase cross-review → end-of-run dual reviewer dispatch; AND-shape verdict synthesis introduced; `Phase Drift` verdict → `Coverage Drift` verdict
- **Named invariants:** `IMPLEMENTATION_PLAN_COVERS_DELTA` (rules #1–#6 reformulated to single-pass shape; rules #4 and #5 collapsed)
- **Behavior matrices:** `phase-derivation.md` (removed); `artifact-placement.md` (lifecycle row `Per-phase plan` → `Per-pass plan`)
- **Gotchas:** `large-delta-mega-plan.md` (added); `skipping-per-phase-plan.md` (retired); `plans-as-run-scaffolding.md` (modified)
- **Semantic linters:** `validate_plugin.sh` Check 13f rewritten
- **Tests proposed:** none

## Blocking issues

### B1. `validate-rewrite` Approved trailer's default Implementation-route card still describes phase-shaped Build

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** This is the literal render template that `validate-rewrite` emits on every Approved verdict in the §"Output format" code block. It is the gate where the user decides whether to proceed to Build, and the card's why-line is the user's last description of what `cohesive:implement-cohesively` will do. The repair-pass-1 B4 sweep explicitly closed `cohesion-review.md:121` ("phase-by-phase against the delta ledger" → "in a single pass against the delta ledger with end-of-run dual reviewer dispatch"); the symmetric line at `skills/validate-rewrite/SKILL.md:220` was missed. As long as it stands, the Approved chat trailer contradicts (a) the SKILL body's Hard constraint #4 ("end-of-run dual reviewer dispatch"), (b) `IMPLEMENTATION_PLAN_COVERS_DELTA` Rule #4 (single-pass + AND-shape synthesis), (c) `handoffs.md` §"validate-rewrite → implement-cohesively (Approved branch)" ("Step 1 composes the thin intent paragraph"), (d) `composition-with-superpowers.md` §1 ("once per implementation pass"), (e) the README "single-pass against the delta ledger" line. lens 14 (handoff-contract consistency) reads exactly this kind of cross-site verdict-gate-and-card divergence as a Blocker.
- **Evidence:** `skills/validate-rewrite/SKILL.md:220` — `Builds the locked design phase by phase against the delta ledger at docs/history/delta-ledgers/<YYYY-MM-DD>-<slug>.md on design/<slug>.`
- **Recommended fix:** Replace line 220 with: `Builds the locked design in a single pass against the delta ledger at docs/history/delta-ledgers/<YYYY-MM-DD>-<slug>.md on design/<slug>, with end-of-run dual reviewer dispatch.` Add a `phase by phase` / `phase-by-phase` forbidden-literal grep to `scripts/validate_plugin.sh` (deferred Check 13l candidate) — same convention-with-grep promotion as `bypass_string`.
- **Substrate artifact:** spec — `skills/validate-rewrite/SKILL.md:220` (literal); add forbidden-literal grep to `scripts/validate_plugin.sh`.

## Important issues

### I1. `IMPLEMENTATION_PLAN_COVERS_DELTA.md` History line 96 mis-states day-one rule shape

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** The 2026-05-04 history entry says invariant earned status "from day one" because the rule had `(per-phase coverage + per-phase reviewer + final substrate review)`. That description is now historically incorrect about why the rule earned status today — its current rule set is single-pass + dual-reviewer + AND-shape. History entries are append-only and can keep their original wording; the entry as written frames *why-it-earned-invariant-status* in terms of the *day-one* enforcement story, which is fine for the entry's date. But a future contributor reading "earned because per-phase coverage" against the current rule set will momentarily disbelieve the doc. The 2026-05-08 entry below it correctly narrates the reformulation, so the audit trail is intact; only the phrasing in the day-one entry is awkward.
- **Evidence:** `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md:96`.
- **Recommended fix:** Either keep the line verbatim (preferred — append-only history), or annotate inline: `(per-phase at the time; reformulated to single-pass dual-reviewer dispatch on 2026-05-08; see entry below)`. Don't rewrite the day-one entry.
- **Substrate artifact:** spec — `IMPLEMENTATION_PLAN_COVERS_DELTA.md` History §.

### I2. Resume-mechanic ambiguity remains substrate-noted but the SKILL body is silent

- **Severity:** Low
- **Category:** Vague language
- **Why it matters:** The ledger §"Remaining ambiguity" carries forward pass-1 I2 as substrate-noted: `handoffs.md:219-220` says Coverage Drift resume must not re-derive the thin intent paragraph, but `implement-cohesively/SKILL.md` Step 1 unconditionally enumerates non-Deferred entries. The substrate-note is the right disposition (user override of close-inline), and the deferred-finding format is correctly recorded — but the SKILL body still has no resume sub-clause. This is known-deferred and is not a Blocker; calling it out for the next pass.
- **Evidence:** `handoffs.md:219`; `implement-cohesively/SKILL.md:63-84`.
- **Recommended fix:** Defer per the substrate-note; revisit on the next IMPLEMENTATION_PLAN_COVERS_DELTA-touching pass.
- **Substrate artifact:** spec — `implement-cohesively/SKILL.md` Step 1 (deferred).

## Substrate gaps

- **Forbidden-literal grep for `phase by phase` / `phase-by-phase` across the SKILL/template surface.** B4 closed every instance via reviewer attention; B1 above shows reviewer attention missed one. A `grep -F 'phase by phase'` returning zero is a one-line check (parallel to Check 13g's `bypass_string` pattern); promote it as Check 13l in the same pass that closes B1.
- **Verdict-synthesis matrix promotion.** The 4-row table in `implement-cohesively/SKILL.md` §"Verdict synthesis" covers 2×2 of the actual 3×5 reviewer-output combinations. The deferral note in the ledger names this; the gap is real but explicitly substrate-noted as "skill-body subsection suffices for v0.1".

## What looked right

- **Rule #4 collapse in the named invariant is clean.** Reformulating Rule #4 per-phase reviewer + Rule #5 final substrate review into a single dual-reviewer rule with AND-shape synthesis (with Substrate Drift winning on dual-fail) is the highest-leverage move of the rewrite.
- **`large-delta-mega-plan.md` names the relocation, not just the cliff.** The gotcha's §"Why it happened" explicitly walks the abandonment-cliff *relocation* from per-phase escalation to single-pass context overflow.
- **Verdict-vocabulary parity is tight.** `Phase Drift` → `Coverage Drift` propagates cleanly across `verdict-vocabulary.md`, `handoffs.md` chain-exit contracts, the SKILL body's verdict-synthesis table, the chat-trailer template's `## End-of-run review` body block, and user-facing label translation.

## Recommended repairs (ranked)

1. **Close B1.** Single-line edit at `validate-rewrite/SKILL.md:220` plus a forbidden-literal grep target in `validate_plugin.sh` (Check 13l). Both in the same pass.
2. **Annotate or leave I1.** Inline annotation acceptable; preferred is leaving verbatim per append-only history convention.
3. **I2 stays substrate-noted.** Already recorded correctly per the disposition rule.

### Next

Disposition: Repair → re-validate.
