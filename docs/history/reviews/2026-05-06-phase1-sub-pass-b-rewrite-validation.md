# Rewrite Validation Review — Phase 1 sub-pass B (scope.md + audience seam extension)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** scope.md (added), audience-separation.md §"Surface-by-surface translation: substrate types" (added section), substrate-vocabulary.md (consumer enumeration), ARCHITECTURE.md (convention count). Per delta ledger at `docs/history/delta-ledgers/2026-05-06-phase1-sub-pass-b.md`.

**Status:** Approved

## Architectural reflection

The rewrite closes both targets cleanly. scope.md draws cuts that map to real adjacent-skill pressure (debug, refactor, deploy) rather than abstract categories, and the four "doesn't do" buckets are mutually exclusive without obvious gaps. The audience-separation extension is load-bearing structure (parallel-translation-surfaces table + colloquial first-phrase rule + named exemption), not restatement.

- **Easier downstream:** A future contributor authoring a new chat-render surface that mentions a substrate type now has one canonical place to look up the translation rule. Scope creep has an explicit negative space the next reviewer can point at.
- **Harder downstream:** scope.md is convention-only at v0.1 (qualitative content; no greppable structure). Reviewer attention is the realistic enforcement until Check 13o or a parallel scope-coverage check lands.
- **Load-bearing on memory:** The "overbuild simplicity and extensibility; underbuild everywhere else" principle is stated in scope.md but no validator asserts it. The promotion criteria for new substrate types depend on reviewer judgment of the "What this earns" discriminator, not a mechanical check.

## Executive judgment

A future contributor can read these surfaces and learn (a) what Cohesive does and doesn't ship; (b) what's open for extension and on what criteria; (c) how chat-render surfaces translate substrate-type tokens; (d) where the canonical translation table lives. None of this requires reading code. Three Lows surfaced — all sweep tightenings, no Blocker or High issues.

## Delta at a glance

(Full preamble matches `docs/history/delta-ledgers/2026-05-06-phase1-sub-pass-b.md` lines 9-22.)

## Important issues

### I1. ARCHITECTURE.md §"Conventions" bullet list undercounts

- **Severity:** Low — Spec drift
- **Why it matters:** §"v0.1 scope" prose enumerates 7 conventions; §"Conventions" bulleted list at lines 47-55 references only 3 (skill-shape, reviewer-agent-shape, dispatch-protocol). audience-separation, scope, skill-tool-dispatch, substrate-layout missing as bullets.
- **Fix:** Add bullet rows for the missing four conventions.

### I2. scope.md Build-gate row omits Superpowers code-production composition

- **Severity:** Low — Domain model
- **Why it matters:** Build-gate row says implement-cohesively owns "Phase derivation … per-phase cross-review … spec-coverage verdict" but doesn't name the composition-via-superpowers fact. Reader could infer Cohesive owns code-production.
- **Fix:** Add "code production composed via `superpowers:executing-plans`" to the row.

### I3. Reverse citation from substrate-vocabulary.md to scope.md missing

- **Severity:** Low — Future-fit
- **Why it matters:** scope.md pins six-type cap and seventh-type promotion criterion; substrate-vocabulary.md doesn't cite scope.md as the cap's authoritative home.
- **Fix:** Add scope.md citation in §"Related substrate".

## What looked right

- "Overbuild simplicity and extensibility; underbuild everywhere else" headline is the right discipline statement — concrete enough to apply, abstract enough to survive.
- The four "doesn't do" buckets draw cuts that map to real adjacent-skill pressure (debug, refactor, deploy, formatter).
- §"Why these cuts" naming three concrete failure modes (methodology bloat, identity drift, composition vs replacement) is exactly the substrate the next reviewer needs.
- The colloquial first-phrase rule with six worked mappings is load-bearing structure.
- The artifact-naming exemption (init drafts + audit Top fixes) names a concrete citation so future contributors won't re-derive whether init's pedagogical move violates the rule.

### Next

**Disposition:** Close inline (≤2 lines per finding) → merge

**Implementation route — default:** Build the locked design and verify the code matches it. *(`cohesive:implement-cohesively`.)* Note: docs-only rewrite — closing I1-I3 inline before merge; the rewrite IS the implementation.
