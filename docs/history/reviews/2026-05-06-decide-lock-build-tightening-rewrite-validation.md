# Rewrite Validation Review — Decide-Lock-Build framing tightenings

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** Decide-Lock-Build framing tightenings on branch `design/decide-lock-build-tightening`; design delta ledger at `docs/history/delta-ledgers/2026-05-06-decide-lock-build-tightening.md`

**Status:** Approved

## Architectural reflection

How it feels now: small, precise repairs landing on top of a recently-merged design. The seven gaps were each named with file:line evidence in the source self-review, and each lands with a one-to-one repair in this pass — gates-as-nodes vs reversals-as-edges is now structurally pinned in `audience-separation.md` §"Gates and reversals"; the Re-decide producer step is documented in parallel form to the Bypass acknowledgment; two convention-with-grep promotions (Check 13g extension, Check 13l) close the reviewer-attention-only enforcement gap on the bypass imperative and the chain-rendering retirement.

- **Easier downstream:** a future contributor authoring a third reversal adds a named edge (not a fourth gate); the user-facing flow's three-gate count is now a structural shape, not a count contributors have to remember.
- **Harder downstream:** Re-decide cycle-count derivation is convention (commit-history-based) — brittle if the user discards a worktree without committing or works across non-linked branches; the ledger flags this in §"Remaining ambiguity" and proposes a sidecar metadata file when a real Re-decide chain runs.
- **Load-bearing on memory:** the 2-3-cycle Re-decide cap is convention, not validator-enforced; the verdict-vocabulary ↔ gate-vocabulary alignment ("Implementation complete" → "Build complete") is explicitly deferred. Both depend on reviewer attention until promoted.

## Executive judgment

The rewrite is implementable as-is. It is a tight, surgical pass: six files rewritten, one ledger added, every change traceable to a numbered self-review finding with file:line evidence. Internal coherence is high — the gates-as-nodes pin in `audience-separation.md` §"Gates and reversals" agrees with `ARCHITECTURE.md` line 88's "Gate transitions, off-chain re-entry edges, and reversals (Substrate Drift, Re-decide)"; `validate-rewrite/SKILL.md` Re-decide acknowledgment names the same three persisted artifacts the chat-trailer's Default-recommend rule documents; the two new validator checks (13g extension, 13l) match the conceptual-change row that promotes them. No contradictions between rewritten files and no stale concept references.

## Delta at a glance

This rewrite is **Mixed** — design-layer change to convention vocabulary (gates-as-nodes vs reversals-as-edges in `audience-separation.md`) plus implementation-layer changes across one SKILL.md, one architecture doc reference, two template clarifications, and two validator checks.

(Full preamble matches `docs/history/delta-ledgers/2026-05-06-decide-lock-build-tightening.md` lines 9-30.)

## Important issues

### I1. Check 13l comment cites a path the reviewer could not verify *(false positive on resolution)*

- **Severity:** Low
- **Category:** Enforcement
- **Resolved:** The cited path `docs/history/delta-ledgers/2026-05-06-decide-lock-build.md` exists in the repo (verified via `ls`). The Check 13l comment correctly references the *prior* merged decide-lock-build ledger where the chain-rendering retirement was introduced. The reviewer's fresh-eyes context only included the files dispatched (the tightening ledger), so they couldn't see the prior ledger to verify the citation. The reviewer correctly flagged this as something to verify; on verification it's correct.
- **Action this pass:** None. The comment stays as-is.

### I2. Re-decide cycle-count derivation reliability — reviewer's own recommendation is non-action

- **Severity:** Low
- **Category:** Future-fit
- **Resolved:** The reviewer's recommendation is "the latter is cheaper and keeps deferral discipline visible only in the ledger; close inline. ... None this pass." The ledger's §"Remaining ambiguity" entry is sufficient.
- **Action this pass:** None.

## What looked right

- **Self-review traceability.** Every change ships with a numbered finding citation in `## Files rewritten` (e.g., "Closes self-review finding 1", "Closes self-review finding 5"). A future reviewer reading the delta can cross-reference each repair to the source review without guessing.
- **Convention-with-grep promotions are paired with their conceptual-change rows.** Check 13g extension and Check 13l show up both in `## New or updated substrate` §"Semantic linter specs" and in `## Conceptual changes` row 4 ("Promoted"). The substrate-shape vocabulary is consistent across the ledger.
- **Re-decide acknowledgment is parallel-shaped to Bypass acknowledgment.** A future contributor authoring a third user-driven reversal acknowledgment has a clear pattern to follow.
- **Default-recommend rule scope tightened with a non-applicability clause.** The rule names which flat enumerations deliberately don't apply (audit-substrate Top fixes, review-codebase Top findings, review-diff Findings table) — pre-empting the "should this list also use a default" question.

### Next

**Disposition:** Close inline (≤2 lines per finding) → merge

**Implementation route — default:** Build the locked design and verify the code matches it. *(`cohesive:implement-cohesively`.)* **Scope:** the design delta ledger at `docs/history/delta-ledgers/2026-05-06-decide-lock-build-tightening.md` and branch `design/decide-lock-build-tightening`.

Note: This rewrite is docs-only — Build is N/A; the rewrite is the implementation. Both Lows are no-action (I1 false positive on resolution; I2 reviewer's own non-action recommendation). Ready to merge.
