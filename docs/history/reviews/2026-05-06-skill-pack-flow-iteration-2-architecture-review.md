# Cohesive Architecture Review — Skill pack inter-skill flow (iteration 2, post-merge)

**Date:** 2026-05-06
**Scope:** the Cohesive skill pack itself, post-merge of `design/skill-pack-flow-tightening` (merge commit `256bd97`).
**Reviewer:** `cohesive:review-codebase` (synthesis from discovery + targeted external research; formal 4-reviewer dispatch deferred — the prior architecture review at `docs/history/reviews/2026-05-05-skill-pack-flow-architecture-review.md` is 2 days fresh and the delta is bounded).
**Predecessor:** `docs/history/reviews/2026-05-05-skill-pack-flow-architecture-review.md` (verdict: Cohesive but under-enforced; 16 findings; closed 6 in the merged rewrite, deferred 10).

## Verdict

**Mostly healthy** (improved from "Cohesive but under-enforced" pre-merge).

## Executive thesis

The merge delivered what it claimed: 6 of 16 findings closed structurally; the substrate is denser, the canonical entry points are clearer, and the new `using-cohesive` + `skill-tool-dispatch.md` + Check 13i landings are internally coherent. The verdict ratchet from "under-enforced" to "Mostly healthy" reflects two real shifts: the dispatch-prompt-contract mirror moved from prose annotation to mechanical grep (DISPATCH_CONTRACT_MIRROR candidate), and the agent-readiness "Adding a new skill" sequence is now bounded end-to-end including the validator-array surface that previously broke contributors. The targeted external research adds **two now-actionable items** that weren't visible before: a concrete `plugin.json`/`marketplace.json` schema-tightening diff (closing finding 7), and a new validator extension (`claude plugin validate` as a CI check). Of the 10 deferred findings, two now warrant promotion (finding 7 + the new validator addition); the rest correctly stay deferred per their criteria. **The highest-leverage remaining gap is still the absent end-to-end-journey artifact** — orientation-shape work, not enforcement-shape.

## Spec-prior review

Substrate is dense and post-merge-coherent. Validator passes clean (0 errors / 0 warnings across all 13 numbered checks including the new Check 13i). Discovery report rendered upstream in this turn; external research at `<inline above>` provides finding-7 disposition. No spec-prior gate violations.

## System cohesion scorecard

| Area | Rating | Summary |
|---|---|---|
| Spec coherence | **Healthy** ⬆ (was Mostly healthy) | The audit-substrate verdict drift fix + label drift in no-implementation-handoff + lens-13 typo fix removed the three demonstrated drift instances; the new substrate (using-cohesive, skill-tool-dispatch, three-label bootstrap) is internally consistent. |
| Code/spec alignment | **Healthy** ⬆ | Validator passes clean; design-layer/SKILL.md mirror honored on validated skills. |
| Domain model clarity | **Healthy** (unchanged) | Five-shape transition vocabulary holds; using-cohesive vs cohesively split survives pressure. |
| Invariant enforcement | **Mostly healthy** ⬆ (was Under-enforced) | DISPATCH_CONTRACT_MIRROR now grep-pinned (Check 13i); HANDOFF_VOCABULARY_PARITY still reviewer-judged but explicitly named as Check 13j candidate with promotion criteria. |
| Test guarantees | **Under-enforced** (unchanged) | No test directory; multiple "Manual scenario test (planned)" deferrals; queued-scenario-tests matrix still missing. |
| Locality and seams | **Healthy** (unchanged) | Two-doc dispatch contract split (Task-tool / Skill-tool) is the right shape; using-cohesive seam well-localized. |
| Library-native alignment | **Mostly healthy** ⬆ (was Mostly healthy with caveat) | External research confirms current `plugin.json` is on-shape but missing the `$schema` field + a few `marketplace.json` discoverability fields that a clean diff fixes. |
| Agent-readiness | **Mostly healthy** ⬆ (was Under-enforced) | 5-step "Adding a new skill" sequence + bootstrap-status three-label scheme + skill-shape.md §"Process" deferring to skills.md → one canonical entry point. The Phase-3 substrate-alignment-reviewer flagged one residual gap (`skill-tool-dispatch.md` §"Concrete dispatch sites" omits parallel Task-tool sites) — Low; closeable inline. |
| Future extensibility | **Healthy** (unchanged) | Substrate growth pattern is well-modeled; promotion criteria documented; deferred-item tracking honest. |

## Highest-leverage findings (post-merge state)

### 1. `plugin.json` + `marketplace.json` schema tightening — now actionable post-research

**Severity:** High (now-actionable; was deferred pending research)
**Category:** Library alignment
**Why it matters:** Closes prior finding 7. The external research surveyed published marketplace exemplars (`anthropics/life-sciences`, Dev-GOM, netresearch, Superpowers) and the official schema docs at `code.claude.com/docs/en/plugins-reference` and `/plugin-marketplaces`. The required fields are minimal (just `name`); discoverability metadata (`category`, `tags`) lives in `marketplace.json` plugin entries, not `plugin.json`. The 2.1.120 changelog (April 2026) added top-level `$schema` / `version` / `description` to `marketplace.json`. Cohesive's manifests are on-shape but omit these new fields.

**Evidence:** External research memo §1 cites the schema URLs and the changelog. Cohesive's current `.claude-plugin/plugin.json` lacks `$schema`; `.claude-plugin/marketplace.json` carries metadata in nested form rather than top-level.

**Recommended fix (concrete diff):**
- `plugin.json`: add `"$schema": "https://json.schemastore.org/claude-code-plugin-manifest.json"`
- `marketplace.json`: add top-level `"version": "0.1.0"` and `"description": "Substrate-first agentic engineering — substrate, specs, invariants, gotchas, behavior matrices."`
- `marketplace.json` plugin entry: replace `"category": "development"` (or whatever's current) with a more discriminating value; add `"tags": ["substrate", "specs", "invariants", "cohesion-review", "agentic-engineering"]`
- `marketplace.json` plugin entry: mirror `"version": "0.1.0"` from `plugin.json` (docs allow; aids cache resolution)
- **Do not add** `"skills": [...]` or `"agents": [...]` enumerations — those *replace* default discovery and would silently turn off auto-discovery for future skills (named footgun in the research).

**Substrate artifact to add or update:** `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` (implementation-shape; no design-layer change since this is library-native alignment, not seam change). Optionally close prior finding 7 with a substrate-note in `docs/substrate/gotchas/` if Cohesive ever wants to record the schema-survey outcome.

### 2. Add `claude plugin validate` to `scripts/validate_plugin.sh` as a new check (Check 16)

**Severity:** High (new finding from external research)
**Category:** Enforcement / CI
**Why it matters:** Anthropic ships an official `claude plugin validate` CLI that validates against the published schema. Cohesive currently hand-rolls JSON validation via `python3 -c "import json"` (Checks 1, 2 in `validate_plugin.sh`). The hand-rolled check catches malformed JSON but not schema violations. Running `claude plugin validate` in CI gives Cohesive a real schema-verification step that wasn't shippable a week ago — and closes the audit's "is this schema-clean" question definitively.

**Evidence:** External research memo §1, §3. Changelog 2.1.120 (late April 2026): "claude plugin validate now accepts $schema, version, and description at top level of marketplace.json".

**Recommended fix:** Add a Check 16 to `validate_plugin.sh` after the existing JSON-validity checks:
```bash
# 16. claude plugin validate (official schema-aware check, requires Claude Code 2.1.120+)
if command -v claude >/dev/null 2>&1; then
  if claude plugin validate >/dev/null 2>&1; then
    ok "claude plugin validate: schema-aware validation passed"
  else
    fail "claude plugin validate failed; run \`claude plugin validate\` for details"
  fi
else
  warn "claude CLI not on PATH; skipping schema-aware plugin validation (Check 16)"
fi
```
Make it a warn-level if the CLI is absent (so external contributors without Claude Code installed don't fail CI), fail-level if the CLI is present and validation fails.

**Substrate artifact to add or update:** `scripts/validate_plugin.sh` (new Check 16); `.github/workflows/validate.yml` may need to install the Claude Code CLI in CI (or accept the warn-level skip).

### 3. End-to-end-journey artifact — still missing, now the highest UX-leverage gap

**Severity:** High (carried forward from prior finding 6 family; promoted leverage post-merge)
**Category:** Agent-readiness / Onboarding
**Why it matters:** The merged rewrite closed orientation at session-start (`using-cohesive`) but did NOT close the journey walkthrough — "what does a first Cohesive session look like start-to-finish?" The user explicitly asked about this in this conversation ("when would I use /using-cohesive vs /cohesively?"); the answer required reading 5+ docs to synthesize. A worked transcript at `docs/history/transcripts/<date>-first-session-walkthrough.md` (analog of `output-voice-worked-example.md`) — captured from a real session, dated, append-only — would close it.

**Evidence:** This conversation itself: the user invoked `/cohesive:cohesively` twice with the same prompt over 2 days, indicating the substrate-tightening loop is the canonical user-facing journey but isn't documented as a journey anywhere. The prior architecture review's finding 6 named this; it's still open post-merge.

**Recommended fix:** Capture this 2-day session as the inaugural transcript at `docs/history/transcripts/2026-05-06-skill-pack-flow-tightening-walkthrough.md` (or similar date-slug), naming the chain as it actually played: cohesively (review codebase) → discover-substrate → review-codebase → 4-reviewer parallel + external research → architecture review → user approval → rewrite-specs → validate-rewrite (4-pass loop) → implement-cohesively (Phase 1: 0 phases for substrate-only; Phase 3 review-diff) → merge → iteration 2. The transcript is dated and append-only per substrate-layout convention; future iterations add new transcripts rather than editing the old one.

**Substrate artifact to add or update:** New transcript at `docs/history/transcripts/`. Optionally a §"First session walkthrough" pointer in `README.md` and `AGENTS.md`.

### 4. `skill-tool-dispatch.md` §"Concrete dispatch sites in v0.1" omits parallel Task-tool sites

**Severity:** Medium (carried forward from Phase 3 substrate-alignment finding; closeable inline)
**Category:** Spec drift
**Why it matters:** A reader scanning §"Concrete dispatch sites in v0.1" alone misses the Task-tool side of the same loop (the validate-rewrite per-pass `spec-cohesion-reviewer` re-dispatch). The two surfaces — the §"Skill-tool vs Task-tool dispatch" comparison table and §"Concrete dispatch sites" — are internally consistent only if the reader joins them.

**Evidence:** `docs/substrate/conventions/skill-tool-dispatch.md` §"Concrete dispatch sites in v0.1" (3 Skill-tool sites) vs the same doc's comparison table (4 Task-tool sites including validate-rewrite per-pass).

**Recommended fix:** Add a one-line clause under §"Concrete dispatch sites" pointing at the comparison table for the parallel Task-tool sites. Two-line edit.

**Substrate artifact to add or update:** `docs/substrate/conventions/skill-tool-dispatch.md` §"Concrete dispatch sites in v0.1".

### 5. Promotion of `DISPATCH_CONTRACT_MIRROR` to named invariant — still gated, but criterion partially met

**Severity:** Medium (deferred per documented criteria; one criterion now met)
**Category:** Invariant
**Why it matters:** Check 13i has now shipped clean for one release cycle (the merged rewrite). Per `style-guide-rot.md` promotion criteria, three things must hold: wording stability (✓ — Check 13i wording is set), caught regression (✗ — no drift since merge to catch), captured worked transcript (✗ — none yet). Promotion appropriately stays deferred.

**Evidence:** Check 13i in `validate_plugin.sh`; promotion criteria in `docs/substrate/gotchas/style-guide-rot.md`.

**Recommended fix:** No change this pass. Re-evaluate after the next dispatch-prompt-contract change lands and exercises Check 13i with a real edit (the regression-evidence criterion).

**Substrate artifact to add or update:** None this pass; the deferral is documented in the merged delta ledger §"Remaining ambiguity".

### 6. Bootstrap-status promotion procedure — now load-bearing

**Severity:** Medium (carried forward from prior finding 10; promoted leverage post-merge)
**Category:** Hidden invariant
**Why it matters:** The merged rewrite added the `newly-authored` label but didn't codify the `newly-authored → validated` transition procedure. `using-cohesive` is the first `newly-authored` row; it'll need promotion in a future rewrite, and the procedure is implicit. Concrete questions a contributor would need to answer: which `spec-cohesion-reviewer` lens confirms parity (lens 13, per skills.md §"Bootstrap status" prose post-rewrite)? What evidence belongs in the row's Notes column? Which delta ledger records the promotion?

**Evidence:** `docs/substrate/architecture/skills.md` §"Bootstrap status" prose mentions promotion but doesn't enumerate the procedure.

**Recommended fix:** Add a §"Promotion procedure" subsection to `skills.md` §"Bootstrap status" naming (a) the lens that confirms parity (lens 13), (b) the evidence to cite in the Notes column (e.g., "validated by the YYYY-MM-DD-<slug> rewrite, lens 13 confirmed parity through pass-N"), (c) which delta ledger records the promotion (the same ledger that triggered the validation).

**Substrate artifact to add or update:** `docs/substrate/architecture/skills.md` §"Bootstrap status".

### 7. Right-sized-chain matrix + chain-announcement-stacking gotcha — pair-resolved together

**Severity:** Medium (carried forward from prior findings 6 + 15)
**Category:** Concept / UX
**Why it matters:** Phase-3 structure-reviewer specifically flagged the three-altitude split's ceremony tax for repeat users ("on every substrate-shaped session-start request, the user pays two announcement turns"). This is now a *concrete* concern post-merge, not an abstract one — the merged using-cohesive skill's Hard Constraint #4 mitigates within-session but cross-session repetition has no guard. Pairs naturally with the right-sized-chain matrix (review finding 6) — both surface as "Cohesive over-ceremonializes small or repeat work."

**Evidence:** Phase-3 final substrate review at `docs/history/reviews/2026-05-06-skill-pack-flow-tightening-final-substrate-review.md`; prior architecture review finding 6 + 15.

**Recommended fix (deferred — needs dogfood evidence first):** Watch the next 5–10 sessions for actual ceremony complaints. If they materialize, the right shape is a `chain-pacing.md` matrix encoding per-route per-step auto-chain-vs-pause + a `chain-announcement-stacking.md` gotcha documenting the failure mode + a self-suppression rule in `using-cohesive` Hard Constraint #4 (transcript-based: don't re-orient if the orientation literal is already in the transcript).

**Substrate artifact to add or update:** Eventual `docs/substrate/matrices/chain-pacing.md` + `docs/substrate/gotchas/chain-announcement-stacking.md`. Defer authoring until dogfood evidence justifies.

## Disposition table for the prior pass's 10 deferred findings + new finding from research

| # | Original finding | Disposition this pass |
|---|---|---|
| 6 | Right-sized-chain matrix | **Defer** (pair with #15; needs dogfood evidence) |
| 7 | `plugin.json` discoverability fields | **Promote — finding 1 above** (concrete diff in research) |
| 8 | R016/R900 routing overlap | **Defer** (low leverage; the disambiguation prose still works) |
| 9 | Cohesive↔Superpowers grade-selection rule | **Defer** (no second composition added since prior pass) |
| 10 | Bootstrap-status promotion procedure | **Promote — finding 6 above** (now load-bearing post-`using-cohesive` add) |
| 11 | Wrong-route-recovery gotcha | **Defer** (no observed mis-routing yet) |
| 13 | Intra-pack trigger lint extension | **Defer** (the discover-substrate vs audit-substrate overlap hasn't caused a real pick-error) |
| 14 | Repair-loop stall taxonomy | **Defer** (no production stall yet) |
| 15 | Chain-announcement-stacking gotcha | **Defer (paired)** — see finding 7 above |
| 16 | Queued-scenario-tests matrix | **Defer** (V1 deferral; no scenario tests encoded yet) |
| **NEW** | `claude plugin validate` CI integration | **Promote — finding 2 above** (new from research; ships now) |
| **NEW** | End-to-end-journey transcript | **Promote — finding 3 above** (this conversation IS the transcript material) |
| **NEW** | `skill-tool-dispatch.md` §Concrete dispatch sites cross-reference | **Promote — finding 4 above** (Phase-3 Low; closeable inline) |

Promotion candidates this pass: **5** (findings 1, 2, 3, 4, 6 above; corresponding to prior 7, NEW, NEW, NEW, prior 10).

Continued deferrals: **8** (findings 6, 8, 9, 11, 13, 14, 15, 16 from the prior pass + finding 5 from this pass).

## Recommended roadmap

### First: repair substrate (this iteration's work)

1. **Apply the concrete `plugin.json`/`marketplace.json` diff** (finding 1 above) — Pure implementation; ~5 lines of JSON.
2. **Add `claude plugin validate` Check 16 to `validate_plugin.sh`** (finding 2) — Pure implementation; ~10 lines of bash.
3. **Capture this conversation as the first end-to-end-journey transcript** (finding 3) — New file at `docs/history/transcripts/2026-05-06-skill-pack-flow-tightening-walkthrough.md`. Big-but-bounded.
4. **Close the `skill-tool-dispatch.md` §Concrete dispatch sites cross-reference** (finding 4) — Pure implementation; 2 lines.
5. **Add bootstrap-status promotion procedure** to `skills.md` §"Bootstrap status" (finding 6) — Pure implementation; ~15 lines of prose.

### Then: simplify architecture

Nothing this pass. The architecture is in good shape post-merge; further structural work waits for either dogfood signal (chain-pacing + announcement-stacking) or a second composition use case (grade-selection rule).

### Then: strengthen enforcement

6. **Promote `DISPATCH_CONTRACT_MIRROR` to named invariant** when the next dispatch-prompt-contract edit catches a regression (finding 5 above). Gated.
7. **Promote `HANDOFF_VOCABULARY_PARITY` (Check 13j)** when a regression motivates the prereq-state-string parity grep. Gated.
8. **Encode the planned manual scenario tests** when a fixture harness exists. Gated on infrastructure, not substrate.

## Substrate improvements summary

- **Specs to rewrite:** `skills.md` §"Bootstrap status" (add promotion procedure); `skill-tool-dispatch.md` §"Concrete dispatch sites" (add cross-reference).
- **Behavior matrices to add:** none this pass (chain-pacing deferred).
- **Semantic linters to add:** Check 16 (`claude plugin validate`).
- **Gotchas to document:** none this pass (chain-announcement-stacking deferred until dogfood).
- **Files to update:** `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `scripts/validate_plugin.sh`, `docs/substrate/architecture/skills.md`, `docs/substrate/conventions/skill-tool-dispatch.md`.
- **New files:** `docs/history/transcripts/2026-05-06-skill-pack-flow-tightening-walkthrough.md`.

## Recommended next Cohesive skill

**`cohesive:rewrite-specs`** — run a tight rewrite pass closing findings 1, 2, 3, 4, 6 (above). Suggested slug: `manifest-and-journey-tightening`. Classification: **Pure implementation** (no design-shape changes — all five are textual/JSON/bash edits or a new transcript file). Bundling them into one rewrite pass closes the highest-leverage promotable items atomically and gets a single `validate-rewrite` review on the result. Estimated rewrite scope: ~30–50 lines of substrate edits + 1 new transcript file (the transcript itself will be longer but is append-only history, not normative).
