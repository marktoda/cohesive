# Design Delta Ledger — Decide-Lock-Build framing tightenings

**Date:** 2026-05-06
**Worktree / branch:** `.claude/worktrees/decide-lock-build-tightening` on `design/decide-lock-build-tightening`
**Approved direction:** Close the seven gaps surfaced by the post-merge self-review (`docs/history/reviews/` from review-diff session): tighten Re-decide producer documentation, pin gates-as-nodes vs reversals-as-edges terminology, extend Check 13g for the post-impl imperative, add Check 13l for chain-rendering anti-pattern, name the post-impl review pattern in `review-diff/SKILL.md` Composition, drop the now-stale "today's canonical case" parenthetical in chat-trailer.md, align ARCHITECTURE.md with the gate framing.

## Delta at a glance

This rewrite is **Mixed** — design-layer change to convention vocabulary (gates-as-nodes vs reversals-as-edges in `audience-separation.md`) plus implementation-layer changes across one SKILL.md, one architecture doc reference, two template clarifications, and two validator checks.

**Design-layer changes:**
- `docs/substrate/conventions/audience-separation.md` §"Gates and reversals" — pinned three-gates-as-nodes (Decide / Lock / Build) distinct from reversals-as-edges (Substrate Drift, Re-decide). Closes the structure-reviewer's Medium concern that "Re-decide named as gate-vocabulary" smuggled a fourth gate.

**Implementation changes:**
- `skills/validate-rewrite/SKILL.md` §"Re-decide acknowledgment" — added explicit producer step: the path is user-driven (parallel to Bypass acknowledgment); names the three persisted artifacts the "What we already tried" payload assembles from (discarded brainstorm + this Approved review's reflection bullets + cycle count from `<slug>` lineage).
- `skills/review-diff/SKILL.md` §"Composition" — added a fourth invocation context (post-implementation review against a Cohesive-locked design) citing `handoffs.md` §"Post-implementation review entry point".
- `references/templates/chat-trailer.md` §"Default-recommend rule" — replaced the stale "today's canonical case" parenthetical with an updated version naming all four current alternatives + an explicit non-applicability rule (flat enumerations don't apply default-recommend).
- `ARCHITECTURE.md` — replaced "5-skill flagship chain" with "5 subskills underneath the user-facing **Decide → Lock → Build** flagship gates"; updated the §"User-facing skill set" pointer paragraph to name the gate framing and the audience-separation pin.
- `scripts/validate_plugin.sh` — Check 13g extended to verify the full bypass-acknowledgment string (including the post-impl `cohesive:review-diff` imperative); new Check 13l added grepping `skills/cohesively/SKILL.md` for the `→ <subskill-id>` chain-rendering anti-pattern.

- **Files:** 6 rewritten, 1 added (this ledger), 0 removed
- **Conceptual changes:** Three-gates-as-nodes vs reversals-as-edges terminology pinned; Re-decide producer-side documentation made explicit; post-implementation review pattern surfaced in `review-diff` itself (not just `handoffs.md`); two deferred validator checks promoted (13g extended; 13l added)
- **Named invariants:** none added / removed / changed; `IMPLEMENTATION_PLAN_COVERS_DELTA` and `VERDICT_BEFORE_EVIDENCE` continue to hold
- **Behavior matrices:** `docs/substrate/matrices/router.md` unchanged
- **Gotchas:** none added / retired
- **Semantic linters:** Check 13g extended (full bypass string + post-impl imperative); Check 13l added (chain-rendering anti-pattern grep). Both promote previously-deferred candidates from the prior two delta ledgers
- **Tests proposed:** none
- **Deferred (out of scope this pass):** Cap-on-re-decide-cycles validator (still convention-only); render-conditional-pattern centralization at N=3 (still N=2); verdict-vocabulary alignment with gate vocabulary (e.g., "Implementation complete" → "Build complete")

## Files rewritten

- `skills/validate-rewrite/SKILL.md`
  - **Before:** Re-decide acknowledgment line said `before invoking brainstorm-design` without naming who invokes or how the "What we already tried" payload is assembled. The substrate-alignment-reviewer's High finding: consumer (brainstorm-design) documented; producer not.
  - **After:** Acknowledgment paragraph extended: "before the user (or Claude on the user's behalf) invokes `cohesive:brainstorm-design`. The Re-decide path is user-driven (parallel to the Bypass acknowledgment shape above): this skill renders the line as part of the Approved trailer when the user picks Re-decide; the subsequent `brainstorm-design` invocation is a fresh skill call (router-driven via `cohesively` or direct user invocation), with the 'What we already tried' payload assembled from three named persisted artifacts — the discarded brainstorm at `docs/history/brainstorms/<date>-<slug>.md`, this Approved review's Architectural reflection bullets (Harder-downstream + Load-bearing-on-memory), and the cycle count derived from the `<slug>` lineage (the count of prior Re-decide acknowledgments in the branch's commit history)."
  - **Reason:** Closes self-review finding 1 (substrate-alignment Medium): consumer/producer wiring is now explicit; the convention parallels Bypass acknowledgment exactly.

- `docs/substrate/conventions/audience-separation.md`
  - **Before:** "Gate-level reversal: Re-decide" paragraph framed Re-decide as gate-vocabulary; structure-reviewer flagged this as smuggling a fourth gate (the substrate insists on three).
  - **After:** Replaced with §"Gates and reversals" paragraph pinning three-gates-as-nodes (Decide / Lock / Build) distinct from reversals-as-edges. Two reversals named (Substrate Drift Build → Lock; Re-decide Lock → Decide) with their handoff contracts cited. The count of *gates* stays at three; reversals are escape edges.
  - **Reason:** Closes self-review finding 2 (structure Medium): a future contributor authoring a third reversal adds an edge, not a gate; gate vocabulary's structural meaning is preserved.

- `skills/review-diff/SKILL.md`
  - **Before:** §"Composition" did not name the post-implementation review pattern as one of `review-diff`'s invocation contexts; the pattern existed in `handoffs.md` only.
  - **After:** §"Composition" grows an "Invocation contexts (four)" bullet enumerating PR / branch / working-changes / post-implementation review against a Cohesive-locked design. The fourth context cites `handoffs.md` §"Post-implementation review entry point" and names the substrate-alignment-reviewer's expected primary input (the design delta ledger).
  - **Reason:** Closes self-review finding 5 (structure Low): a user landing in `review-diff` directly now sees the post-implementation pattern from inside the skill body, not only by reading `handoffs.md`.

- `references/templates/chat-trailer.md`
  - **Before:** §"Default-recommend rule" closed with "today's `validate-rewrite` Approved Implementation route is the canonical case" — written when the trailer had three alternatives; drifted when the post-lock-escape rewrite added a fourth (Re-decide). Substrate-alignment-reviewer flagged the drift.
  - **After:** Updated to name all four current alternatives explicitly and to call out flat enumerations (audit-substrate Top fixes, review-codebase Top findings, review-diff Findings table) as deliberately non-applicable: the rule applies when there's a default to recommend, not when each item is independent evidence.
  - **Reason:** Closes self-review finding 4 (substrate Low) and the structure-reviewer's premature-centralization concern: the rule's scope is now explicit, future contributors can tell when to apply it.

- `ARCHITECTURE.md`
  - **Before:** Line 86 said "the 5-skill flagship chain"; line 88 referenced "chain shape" and "Chain transitions" as the reading targets.
  - **After:** Line 86 says "5 subskills underneath the user-facing **Decide → Lock → Build** flagship gates"; line 88 names "gate framing", "Gate transitions, off-chain re-entry edges, and reversals (Substrate Drift, Re-decide)", and adds a pointer to `audience-separation.md` §"Gates and reversals".
  - **Reason:** Closes self-review finding 5 (substrate Low): a user clicking from README to ARCHITECTURE.md now lands in the gate framing, not the retired chain framing. Contributor reading surface.

- `scripts/validate_plugin.sh`
  - **Before:** Check 13g grepped only the original bypass-acknowledgment string; the post-lock-escape rewrite added the post-impl `cohesive:review-diff` imperative without extending the check (Check 13m candidate was deferred). No Check 13l for chain-rendering anti-pattern (Check 13l candidate was deferred).
  - **After:** Check 13g extended — `bypass_string` literal now includes the full extended sentence (bypass clause + post-impl imperative); the failure message cites both invariants. New Check 13l added — greps `skills/cohesively/SKILL.md` for `→ <subskill-id>` patterns where subskill-id is one of the eight Cohesive subskills; the Red flag's generic placeholders (`skill-1` / `skill-2`) don't match, so the Red flag survives without false-positive.
  - **Reason:** Closes self-review findings 3 (substrate Medium, two of them): two convention-with-grep promotions land in this pass; no more reviewer-attention-only enforcement on the bypass-acknowledgment imperative or the chain-rendering retirement.

## Files added

- `docs/history/delta-ledgers/2026-05-06-decide-lock-build-tightening.md` — this file.

## Files removed or deprecated

None.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| "Gate-level reversal: Re-decide" framing (gate vocabulary applied to a transition) | Three gates (nodes) + named reversals (edges); Substrate Drift and Re-decide are reversals, not gates | Reframed |
| Re-decide producer step is implicit (parallel to Bypass acknowledgment but not stated) | Re-decide producer step is explicit: user-driven, payload assembled from three named persisted artifacts | Made explicit |
| Post-implementation review pattern lives only in `handoffs.md` | Pattern named in both `handoffs.md` and `skills/review-diff/SKILL.md` §"Composition" — the user-discoverable surface | Cross-surfaced |
| Check 13g grepped the older bypass string only; Check 13l deferred | Check 13g extended; Check 13l added; both deferred-promotion candidates from the prior two ledgers now landed | Promoted |
| Default-recommend rule's "today's canonical case" parenthetical drifted on count + lacked non-applicability scope | Rule names all four current alternatives + explicit non-applicability for flat enumerations | Tightened |
| ARCHITECTURE.md described the user-facing flow as "5-skill flagship chain" | ARCHITECTURE.md describes the user-facing flow as Decide → Lock → Build gates with subskills underneath | Aligned |

## New or updated substrate

### Specs

- `skills/validate-rewrite/SKILL.md` — Re-decide acknowledgment producer step explicit.
- `skills/review-diff/SKILL.md` — fourth invocation context.
- `references/templates/chat-trailer.md` — default-recommend rule scope tightened.
- `docs/substrate/conventions/audience-separation.md` — gates-as-nodes vs reversals-as-edges pinned.
- `ARCHITECTURE.md` — gate-framing alignment.

### Behavior matrices

None changed.

### Named invariants

None added, removed, strengthened, or weakened.

### Gotchas

None added or retired.

### Semantic linter specs

- Check 13g (existing) extended to verify the full bypass-acknowledgment string including the post-implementation `cohesive:review-diff` imperative.
- Check 13l (new) — chain-rendering anti-pattern grep against `skills/cohesively/SKILL.md`. Greps for `→ <subskill-id>` patterns; subskill IDs enumerated explicitly.

### Tests / checks proposed (not yet implemented)

- None this pass.

## What this rewrite *did not* do

- **Implementation code:** not changed (docs-only, plus two validator checks which are themselves docs-of-substrate).
- **Verdict-vocabulary alignment with gate vocabulary:** still deferred (e.g., "Implementation complete" → "Build complete"). Self-review noted this as Low; defer-pattern intact.
- **Render-conditional pattern centralization:** still N=2 instances (`validate-rewrite/SKILL.md`, `implement-cohesively/SKILL.md`); promote when a third skill picks up the pattern per the structure-reviewer's locality-over-centralization recommendation.
- **Cap-on-re-decide-cycles validator:** still convention-only. The cycle-count derivation is now explicit (commit-history-based) but no validator enforces the 2-3 cap; promotion deferred until a real Re-decide chain runs in production and surfaces the failure mode.
- **Brainstorm-design Phase 1 substep 4 promotion to "required when Re-decide pass-count > 0":** the structure-reviewer recommended this; deferred because it would require validate-rewrite to halt with a directive error if the dispatch payload is missing on a Re-decide invocation, and that requires the cycle-count tracking to be structural (not just commit-history-derived). When the cap promotes to validator, this promotes alongside.

## Remaining ambiguity

- **Cycle-count derivation reliability.** The Re-decide acknowledgment paragraph says cycle count is "derived from the `<slug>` lineage (the count of prior Re-decide acknowledgments in the branch's commit history)." This works when the lineage is contiguous (all Re-decide passes land on related branches). It's brittle if the user discards a worktree without committing or works across non-linked branches. The convention is good enough for v0.1; promotion to a structural mechanism (e.g., a sidecar metadata file at `docs/history/re-decide-lineage/<slug>.md` tracking the chain) is deferred until a real Re-decide chain runs.
- **Self-review's three remaining Lows.** Findings 3 (default-recommend overfit on N=1 — partially closed by adding scope but no structural change), 4 (render-conditional duplication at N=2 — deferred per locality-over-centralization), and 6 (verdict-vocabulary ↔ gate-vocabulary mismatch — explicitly deferred). All consciously deferred per the structure-reviewer's own recommendation.
