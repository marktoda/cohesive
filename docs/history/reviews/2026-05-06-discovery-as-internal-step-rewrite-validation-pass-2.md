# Rewrite Validation Review — discovery-as-internal-step (pass 2)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** Pass-2 rewrite making `cohesive:discover-substrate` an internal sub-step dispatched by consumer skills. Reviewed against the design delta ledger at `docs/history/delta-ledgers/2026-05-06-discovery-as-internal-step.md`.

**Status:** Approved

## Architectural reflection

Discovery is now plumbing the consumer dispatches via the Skill tool internally, with a uniform optional-override path for cross-skill report reuse. Lens-13 (design ↔ implementation agreement) and lens-14 (handoff contract consistency) both hold for the four consumers.

- **Easier downstream:** A user invoking `/cohesive:cohesively brainstorm a refactor of X` now gets the brainstorm output directly, not a substrate-discovery dump first. Decide gate is a single-skill operation.
- **Harder downstream:** Discovery report staleness is reviewer-judged today; the optional-override path trusts the dispatch prompt's claim that a report covers the same change surface. A future delta could add freshness checks.
- **Load-bearing on memory:** The four consumer skills each carry a near-identical Hard constraint #1 + Composition "Internally dispatches" tuple. Reviewer attention keeps these aligned until a future structural fence (e.g., a validator check that asserts each consumer's Hard constraint #1 names a Step number).

## Executive judgment

A future contributor with no memory of the design discussion can read these specs and implement the system. Two Medium/Low findings — both inline closures.

## Delta at a glance

(Full preamble matches `docs/history/delta-ledgers/2026-05-06-discovery-as-internal-step.md` lines 9-30 with the pass-2 update to "8 rewritten".)

## Important issues

### I1. discover-substrate SKILL.md body §"When to invoke" frames discovery as user-invoked upstream

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** Design layer says primary invocation is internal-by-consumer; SKILL.md body still says "Always invoke this skill (or compose its output) before: brainstorm-design / rewrite-specs / …" — old framing.
- **Recommended fix:** Rewrite §"When to invoke" to lead with internal-dispatch as primary; direct invocation gets a secondary paragraph as the rare case.

### I2. brainstorm-design clarifying-question precedence ambiguous

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** Two clarifying questions exist (Step 0 change-surface; Phase 1 future-pressure / re-decide). When both could apply, no precedence is stated.
- **Recommended fix:** One sentence in Phase 1 saying Step 0's change-surface clarification takes precedence.

## What looked right

- Lens-14 chain-edge consistency holds across all four consumers: dispatch-contract grids, matrix mirror, per-handoff contract, and Composition bullets all name the same step number per consumer.
- B5 was the right structural move: collapsed four near-identical handoff entries into one §"discover-substrate ↔ consumer skills (internal-dispatch transition)" section; updated §"The five transition shapes" #4 to acknowledge the two sub-shapes.
- Promoting `### discover-substrate`'s bootstrap status from `inherited` to `validated` is correct — this *is* the forward rewrite.
- "Why this shape" prose names the user-reported pain ("shit ton of substrate info in chat") as the motivation. That's the substrate scar future readers need to understand why.

### Next

**Disposition:** Close inline (≤2 lines per finding) → merge

**Implementation route — default:** Build the locked design and verify the code matches it. *(`cohesive:implement-cohesively`.)* Note: docs-only rewrite — closing I1-I2 inline before merge; the rewrite IS the implementation.
