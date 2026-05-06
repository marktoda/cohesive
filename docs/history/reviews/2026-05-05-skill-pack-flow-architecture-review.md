# Cohesive Architecture Review — Skill pack inter-skill flow

**Date:** 2026-05-05
**Scope:** the Cohesive plugin's own skill pack — `skills/`, `agents/`, `references/`, and the substrate at `docs/substrate/` that governs how the 9 skills hand off to each other.
**Reviewer:** `cohesive:review-codebase`
**Triggered by:** user request to "validate and tighten the flow between skills … as easy and helpful as possible," with parallel external skill-pack research as input.

## Verdict

**Cohesive but under-enforced.**

## Executive thesis

The Cohesive skill pack is unusually well-substrated for a project of this size: a 70+-document normative surface that splits cleanly across `architecture/` (read when changing shape), `conventions/` (read when authoring), `matrices/` (branchy behavior with stable IDs), `gotchas/` (named scars), and `invariants/` (4 named, 3 mechanically enforced). The chain shape (5-skill flagship + 3 diagnostics + 1 router) is *load-bearing at every split* — `skills.md` §"Why these skills, not others" survives pressure-testing — and the Cohesive↔Superpowers composition is deliberate, two-grade, and honest about its risks. **The highest-leverage risk is not architectural; it is enforcement gradient.** Several of the most load-bearing inter-skill properties — verdict-vocabulary parity across SKILL.md / handoffs.md / router.md, the dispatch-prompt-contract mirror between `cohesively/SKILL.md` and `matrices/router.md`, the skill-tool dispatch contract distinct from the task-tool one, the design-layer-canonical ownership-text rule — are pinned by reviewer judgment or prose annotation rather than mechanical greps. The discovered drift is small (one verdict label on the `audit-substrate` re-entry edge) but it is *exactly* the drift class an unenforced parity rule predicts, and it landed in the highest-stakes file in the substrate. The system can scale development without founder memory in most directions; the directions where it cannot are the directions where convention masquerades as invariant.

## Spec-prior review

### Docs read (top normative surface)
- `ARCHITECTURE.md`, `AGENTS.md`, `README.md`
- `docs/substrate/architecture/{three-tier-architecture, composition-with-superpowers, fresh-eyes-review, skills, handoffs}.md`
- `docs/substrate/conventions/{skill-shape, dispatch-protocol, reviewer-agent-shape, substrate-layout}.md`
- `docs/substrate/matrices/{router, phase-derivation, skill-section-presence, reviewer-output-shape, artifact-placement}.md`
- `docs/substrate/invariants/{PLUGIN_ROOT_PATHS, VERDICT_BEFORE_EVIDENCE, IMPLEMENTATION_PLAN_COVERS_DELTA, SKILL_DESIGN_DOC_SECTION}.md`
- 7 `docs/substrate/gotchas/` (soft-prereqs, no-implementation-handoff, discovery-vs-superpowers, skipping-per-phase-plan, style-guide-rot, wordy-output, invariant-claimed-before-enforced)
- All 9 SKILL.md bodies; 6 reviewer agent files; `scripts/validate_plugin.sh`

### Claimed architectural priors (in the system's own words)
- "Cohesive optimizes for *durable judgment*; Superpowers optimizes for *disciplined implementation*" (`composition-with-superpowers.md:23`)
- "Skills work against specs, behavior matrices, named invariants, gotchas, and design docs. The only skill that produces code is `implement-cohesively`, which composes `superpowers:executing-plans` per phase" (`architecture/skills.md:26`)
- "Fresh-eyes review is structurally load-bearing — collapsing review into the rewriting skill defeats the property" (`architecture/skills.md:152`)
- "The router routes; subskills work" (`cohesively/SKILL.md`)
- "Substrate-first discipline at the per-skill layer: design changes update the design layer *before* SKILL.md bodies" (`skill-shape.md:26`)

### Spec inconsistencies (one demonstrated; two implicit)
- **Demonstrated:** `handoffs.md:112` says "When `audit-substrate` returns **Gaps Found** …"; the actual verdict vocabulary is `Substrate gaps` (per `audit-substrate/SKILL.md:68`, `architecture/skills.md:18,234`). Single-line drift on a re-entry edge; exactly the class HANDOFF_VOCABULARY_PARITY would catch.
- **Implicit (label drift):** `gotchas/no-implementation-handoff.md:68-70` lists three lint checks as "deferred V1," but Checks 13e/13f/13g have shipped and pass clean (`scripts/validate_plugin.sh:427-460`). Substrate undersells its current enforcement coverage.
- **Implicit (planned-vs-real ratio):** Multiple gotchas list "Manual scenario test (planned)"; nothing tracks the deferral as a roadmap. Discovery flagged this; substrate-alignment reviewer confirmed.

### Recommended spec changes (independent of code review)
1. Fix `handoffs.md:112` `Gaps Found` → `Substrate gaps`. One-line `Pure implementation` rewrite.
2. Update `no-implementation-handoff.md` §"Tests / checks that preserve this" to reflect shipped Check 13e/13f/13g; leave the planned manual scenario test as the remaining gap.
3. Author `docs/substrate/matrices/queued-scenario-tests.md` enumerating planned manual scenarios by source gotcha.

## System cohesion scorecard

| Area | Rating | Summary |
|---|---|---|
| Spec coherence | **Mostly healthy** | One demonstrated label drift (audit-substrate edge); otherwise dense, dated, internally consistent. Bootstrap-status table is honest. |
| Code/spec alignment | **Mostly healthy** | Validator passes clean (Checks 13a-h, 14, 15). Design-layer/SKILL.md ownership-text mirror honored on validated skills (rewrite-specs, validate-rewrite, implement-cohesively). |
| Domain model clarity | **Healthy** | `skills.md` §"Why these skills, not others" is exemplary. Each chain split has load-bearing justification that survives pressure-testing. Verdict vocabularies across the four chain edges are coherent. |
| Invariant enforcement | **Under-enforced** | 4 named invariants are well-enforced. Two strong promotion candidates (HANDOFF_VOCABULARY_PARITY, DISPATCH_CONTRACT_MIRROR) and one structural rule (design-layer ownership-canonical) are pinned by reviewer judgment or prose annotation only. |
| Test guarantees | **Under-enforced** | No test directory. Structural greps cover the validator surface; behavior is reviewer-judged. Multiple gotchas list manual scenario tests as deferred without tracked promotion path. |
| Locality and seams | **Healthy** | Router/subskill seam clean. Subskill/reviewer-agent seam fence-protected by Task-subprocess isolation + canonical preamble. Cohesive↔Superpowers two-grade composition is the right shape, though the grade-selection *rule* is implicit. |
| Library-native alignment | **Mostly healthy** | Task subprocess + Skill tool + `${CLAUDE_PLUGIN_ROOT}` discipline + frontmatter-trigger negative-lint all honored. Gaps: `plugin.json` is metadata-only; no `using-cohesive` session-start bootstrap analog to Superpowers'; Skill-tool contract not separated from Task-tool contract in conventions. |
| Agent-readiness | **Under-enforced** | The "Adding a new skill" sequence is concrete but omits validator-array updates. The Skill-tool dispatch contract for the validate-rewrite repair loop lives only inline. The dispatch-prompt-contract mirror has prose-only enforcement. Several change scenarios (extending a route, promoting an inherited section, modifying a verdict gate) require derivation rather than reading. |
| Future extensibility | **Healthy** | Substrate growth is well-modeled: section-growth policy in `skills.md`, named-invariant promotion criteria in `style-guide-rot.md`, deviation-recording rule in `skill-shape.md` §"When sections may differ", bootstrap-status as a maturity ratchet. The skill pack is shaped to absorb new chain skills, new routes, and new artifact types without architectural rework. |

## Highest-leverage findings

### 1. Dispatch-prompt-contract mirror is enforced by prose only

**Severity:** High
**Category:** Invariant / Centralization
**Why it matters:** `cohesively/SKILL.md:107-126` and `matrices/router.md:51-66` carry the same dispatch-prompt-contract grid with "update both in the same pass" as the only enforcement. All four reviewers independently flagged this; the external memo named it as a marketplace-pack antipattern (router bloat where dispatch contract drifts from subskill bodies). The grids *are* in parity today (verified cell-by-cell), but parity is a prose convention away from a one-PR drift. The next contributor adding a route can satisfy a reviewer without satisfying both surfaces.

**Evidence:**
- `skills/cohesively/SKILL.md:109` — "update both in the same pass"
- `docs/substrate/matrices/router.md:68` — mirror clause
- No grep target in `validate_plugin.sh` (15 checks; none compare these tables)

**Recommended fix:** Add `validate_plugin.sh` Check 13i: extract route names + prereq-state-passed columns from each grid and assert set equality. Or single-source the table in `matrices/router.md` and replace the SKILL.md table with a pointer + the `validate-rewrite` exception. Either resolves the drift surface; the validator approach is cheaper.

**Substrate artifact to add or update:** Semantic linter — `scripts/validate_plugin.sh` Check 13i. Promote to named invariant `DISPATCH_CONTRACT_MIRROR` once the grep wording stabilizes per `style-guide-rot.md` promotion criteria.

### 2. handoffs.md verdict drift on `audit-substrate` re-entry edge

**Severity:** High
**Category:** Spec drift
**Why it matters:** `handoffs.md:112` says "When `audit-substrate` returns **Gaps Found** with named missing artifacts …", but the actual verdict vocabulary is `{Substrate sound, Substrate gaps, Substrate sparse}`. This is the exact failure shape HANDOFF_VOCABULARY_PARITY would catch, and it landed on the most load-bearing chain doc in the substrate. A future agent reading `handoffs.md` will look for `Gaps Found` in `audit-substrate/SKILL.md` and not find it.

**Evidence:**
- `docs/substrate/architecture/handoffs.md:112` — `"returns Gaps Found"`
- `skills/audit-substrate/SKILL.md:68,129` — `Verdict: Substrate sound / Substrate gaps / Substrate sparse`
- `docs/substrate/architecture/skills.md:18,234` — `{Substrate sound, Substrate gaps, Substrate sparse}`

**Recommended fix:** One-line edit to `handoffs.md:112`: `"Gaps Found"` → `"Substrate gaps"`. `Pure implementation` rewrite per `skill-shape.md` §1a.

**Substrate artifact to add or update:** Spec — `docs/substrate/architecture/handoffs.md` §"audit-substrate → rewrite-specs".

### 3. No `using-cohesive` session-start bootstrap analog

**Severity:** High
**Category:** Library alignment / Idiom mismatch
**Why it matters:** Superpowers ships `using-superpowers` as a session-start skill that teaches Claude when Superpowers applies. This is the harness-native answer to plugin-discovery competition; it loads at session bootstrap, with high relevance for any user message. Cohesive's `discovery-vs-superpowers.md:34-44` mitigation is "the router as canonical entry point" — which only fires when the user knows to invoke `cohesively`. A first-time user who types "what's wrong with this codebase?" lands directly in trigger competition with Superpowers' research/exploration skills, and the harness picks based on description-match heuristics. This is the user-experience defect the user's prompt explicitly asks about.

**Evidence:**
- `skills/` has no `using-cohesive/` directory
- `docs/substrate/gotchas/discovery-vs-superpowers.md:6-11` admits the failure mode but mitigates only via "router as canonical entry"
- External memo: "Borrow the marketplace pattern of an 'auto-pick best plugin' tier above the router"

**Recommended fix:** Author `skills/using-cohesive/SKILL.md` modeled after `superpowers:using-superpowers`'s frontmatter-trigger shape. Body: teaches Claude when Cohesive applies (substrate-shaped work; design before code; review-against-substrate); routes to `cohesively` for everything else; explicitly distinguishes from Superpowers' implementation-discipline framing.

**Substrate artifact to add or update:** New skill `skills/using-cohesive/SKILL.md`; add `### using-cohesive` section to `architecture/skills.md` (required by `SKILL_DESIGN_DOC_SECTION`); update `validate_plugin.sh` `expected_skills` array; add a row to `skill-section-presence.md`. New gotcha or addendum to `discovery-vs-superpowers.md` §"Correct pattern" naming the bootstrap as the structural mitigation.

### 4. Skill-tool (skill→skill) dispatch contract has no documented home

**Severity:** High
**Category:** Convention gap / Invariant
**Why it matters:** `validate-rewrite/SKILL.md` repair loop and `implement-cohesively`'s phase loop both invoke other Cohesive skills via the **Skill** tool — same-conversation-context dispatch, *not* fresh-eyes. The constraints these dispatches must honor (repair-scope-only; chosen-direction-must-not-be-re-derived; commit-template; per-pass paths-only when re-dispatching reviewers) live inline in each calling skill's body. `dispatch-protocol.md` covers Task-tool / fresh-eyes only, and explicitly excludes Skill-tool dispatches. A future agent adding a second internal loop or composing Skill-tool dispatches in a new skill has nothing canonical to read; they'll either re-derive the constraints (likely incompletely) or copy from one of the two existing skills (lossy).

**Evidence:**
- `skills/validate-rewrite/SKILL.md` Step 4.2 (inline contract; explicit "this dispatch is not covered by dispatch-protocol.md")
- `docs/substrate/conventions/dispatch-protocol.md:1-79` (skill→agent only)
- `skills/implement-cohesively/SKILL.md` (Skill-tool dispatches with no contract reference)
- `docs/substrate/architecture/handoffs.md:92` (names "loose location" of constraints; does not enumerate them as a contract)

**Recommended fix:** Author `docs/substrate/conventions/skill-tool-dispatch.md` naming Skill-tool's contract: same conversation context; prompt-as-handoff; subroutine-call shape; the four constraints already inline in `validate-rewrite`. Cite from the two consuming skills; cross-reference from `dispatch-protocol.md` so both contracts are discoverable from one search.

**Substrate artifact to add or update:** New convention doc `docs/substrate/conventions/skill-tool-dispatch.md`. Cited from `validate-rewrite/SKILL.md` and `implement-cohesively/SKILL.md`. Promote to convention-with-grep on the four-constraint inline literal.

### 5. "Adding a new skill" sequence omits validator-array updates

**Severity:** High
**Category:** Agent-readiness / Onboarding
**Why it matters:** `architecture/skills.md:258-266` §"Adding a new skill" gives a 4-step sequence: skills.md → handoffs.md → router.md → SKILL.md. A future agent following this sequence will write a clean skill and break the validator. `scripts/validate_plugin.sh` carries six skill-set arrays (`expected_skills:131`, `discovery_prereq_subskills:207`, `path_prereq_subskills:235`, `persisting_skills:280`, `verdict_led_skills:303`, `voice_imperative_skills:341`) plus a row in `skill-section-presence.md`. The validator failure on a clean skill addition is exactly the bounded-context failure agent-readiness pressure-tests for.

**Evidence:**
- `docs/substrate/architecture/skills.md:258-266`
- `scripts/validate_plugin.sh:131,207,235,280,303,341` — six arrays
- `docs/substrate/matrices/skill-section-presence.md` — one row per skill

**Recommended fix:** Add Step 5 to `skills.md` §"Adding a new skill": "Update validator skill-set arrays (six lists in `scripts/validate_plugin.sh`) and add a row to `docs/substrate/matrices/skill-section-presence.md`. Run `bash scripts/validate_plugin.sh`." Or refactor the validator to read `expected_skills` from disk directly (eliminates the manual update; the other five arrays remain — annotate which to update by skill type).

**Substrate artifact to add or update:** Architecture doc — `architecture/skills.md` §"Adding a new skill" Step 5. Optional: validator refactor to derive `expected_skills` from `skills/` directory listing.

### 6. Right-sized-chain default lives in prose only

**Severity:** Medium
**Category:** Concept / UX
**Why it matters:** `cohesively/SKILL.md` §"Route: design" carries "Run steps 1–2. Pause for user approval before step 3" as prose only. A small "fix this typo" request hitting the design route pays the full chain ceremony unless the model honors that sentence. Prose-only rules are exactly what `style-guide-rot.md` warns against. The user's framing ("as easy and helpful as possible") puts the chain-ceremony tax on the experiential path; a behavior matrix encoding per-route per-step auto-chain-vs-pause makes the rule mechanically auditable.

**Evidence:**
- `cohesively/SKILL.md` §"Route: design" "Default behavior:" — single prose sentence
- `matrices/router.md` cells R001/R002/R014 — no auto-chain column
- `gotchas/style-guide-rot.md` — the failure shape "rules far from generation drift silently"

**Recommended fix:** Add a column to `matrices/router.md` cells (`auto-chains: y/n` per chain step) OR author `docs/substrate/matrices/chain-pacing.md` enumerating per-route auto-chain-vs-pause-for-approval rules. The router body cites the matrix instead of carrying the prose rule.

**Substrate artifact to add or update:** New matrix `docs/substrate/matrices/chain-pacing.md` OR added column to `matrices/router.md` §"Cells".

### 7. `plugin.json` is metadata-only; harness-recommended discoverability fields absent

**Severity:** High (deferred; pending harness-schema verification)
**Category:** Library alignment / Manifest thinness
**Why it matters:** `.claude-plugin/plugin.json` carries name, version, description, author, license, keywords. The Claude Code plugin manifest schema (and adjacent marketplace registration) likely accepts richer fields that surface plugin capability at install time. Cohesive's 9 skills + 6 agents are discoverable only via directory walk. `validate_plugin.sh:51-57` already greps for an *optional* `marketplace.json` but the repo doesn't ship one. This is harness-side fight: Cohesive declares in docs what the manifest could declare structurally.

**Evidence:**
- `.claude-plugin/plugin.json:1-22`
- `validate_plugin.sh:51-57` (conditional `marketplace.json` check)
- `ARCHITECTURE.md:84-86` (claims skill/agent counts the manifest doesn't declare)

**Recommended fix:** Survey current Claude Code plugin manifest schema (check via `context7` MCP or the plugin-marketplace docs). If the schema supports declared skill/agent enumeration or marketplace-registration fields, fill them in. At minimum ship `marketplace.json` so `validate_plugin.sh:51-57` validates against something.

**Substrate artifact to add or update:** New gotcha `docs/substrate/gotchas/manifest-thinness.md` recording surveyed harness fields and which Cohesive deliberately omits vs. should fill. `validate_plugin.sh` extension to require (not just opportunistically check) the discoverability fields once chosen.

### 8. R016 / R900 routing overlap

**Severity:** Medium
**Category:** Locality / Seam
**Why it matters:** `matrices/router.md:32` (R016, "implement-shaped without prereqs → ask the canonical clarifying question") and `:38` (R900, default "ask the canonical clarifying question") overlap. R016's Notes column already carries 4 lines of disambiguation — that is the smell. The resolution rule at `:47` (`explicit instruction → verb tense → scope hint → default`) does not name precedence between cell IDs and default cells. Under growth pressure (rewrite-shaped without prereqs, audit-shaped without prereqs) the overlap fragments further.

**Evidence:**
- `matrices/router.md:32` (R016 Notes — 4 disambiguation lines)
- `matrices/router.md:38` (R900 — single line)
- `matrices/router.md:47` (resolution rule, no cell-vs-default precedence)

**Recommended fix:** Either collapse R016 into R900 with an "implement-shape" sub-row, or extend the resolution rule with explicit cell-vs-default precedence (cell IDs win over R900 for matched verb-tense/scope-hint).

**Substrate artifact to add or update:** `matrices/router.md` §"Rules" — explicit precedence; refactor cells if collapse chosen.

### 9. Cohesive↔Superpowers grade-selection rule is implicit

**Severity:** Medium
**Category:** Locality
**Why it matters:** Two composition grades (loose with 5-line fallback for worktrees; tight with hard error for writing-plans/executing-plans) are deliberate and load-bearing — different failure modes, different blast radii. But the *rule* for choosing a grade at composition-add time is not codified. A future agent adding a new Superpowers composition will infer from existing examples; the inference may not survive a Superpowers ergonomic shift.

**Evidence:**
- `composition-with-superpowers.md:34-50` (lists examples; no general rule)
- `cohesively/SKILL.md:143-146` (lists three composed skills; no grade-selection guidance)

**Recommended fix:** Add §"Grade selection" to `composition-with-superpowers.md` codifying the rule (artifact-consuming → tight; environment-scaffolding → loose), with the existing three skills as worked examples.

**Substrate artifact to add or update:** `docs/substrate/architecture/composition-with-superpowers.md` §"Grade selection".

### 10. Bootstrap-status promotion procedure is implicit

**Severity:** Medium
**Category:** Hidden invariant
**Why it matters:** `architecture/skills.md:53-66` claims sections earn `validated` status when "a `cohesive:rewrite-specs` pass on that skill's purpose, ownership, or seams has run *with the design layer as prior substrate*." A future contributor promoting an inherited section will not know which lens of `spec-cohesion-reviewer` confirms parity, what evidence belongs in the row's Notes column, or which delta ledger records the promotion. The labels are honest; the procedure is reviewer-derived.

**Evidence:**
- `architecture/skills.md:54,60-62`

**Recommended fix:** Add §"Promotion procedure" subsection naming (a) which lenses of `spec-cohesion-reviewer` must confirm parity, (b) evidence to cite in the row's Notes column, (c) delta ledger that records the promotion, (d) when the row updates relative to the rewrite (during the same pass that triggered validation, atomically).

**Substrate artifact to add or update:** `architecture/skills.md` §"Bootstrap status".

### 11. No "wrong route, recover" pattern documented

**Severity:** Medium
**Category:** Scar without gotcha
**Why it matters:** If the router picks `audit (substrate)` for what was actually a `design` request, the user has no canonical recovery. `cohesively/SKILL.md` notes "user can stop the chain at any subskill boundary" — one line of body prose. R013/R014 (ambiguous defaults) are exactly where mis-routing concentrates. A future contributor changing route classification logic has no documented failure mode to test against; the scar is real but unrecorded.

**Evidence:**
- `skills/cohesively/SKILL.md` §"What this skill is *not*" / Red flags — single-sentence stop guidance
- `matrices/router.md:29-30` (R013/R014 ambiguous-default cells)

**Recommended fix:** Author `docs/substrate/gotchas/wrong-route-recovery.md` documenting the "stop the chain, re-invoke `cohesively` with sharpened phrasing" pattern. Reference from R013/R014 Notes column.

**Substrate artifact to add or update:** `docs/substrate/gotchas/wrong-route-recovery.md`.

### 12. `no-implementation-handoff.md` undersells current enforcement

**Severity:** Medium
**Category:** Spec drift (label only)
**Why it matters:** `gotchas/no-implementation-handoff.md:68-70` lists three lint checks as "Lint check (deferred V1)"; `validate_plugin.sh:427-460` ships all three (Checks 13e/13f/13g, all passing). A reviewer auditing substrate maturity reads "deferred" and undercounts enforcement coverage. Same drift class as the audit-substrate verdict drift, smaller blast radius.

**Evidence:**
- `gotchas/no-implementation-handoff.md:68-70` (claims deferred)
- `validate_plugin.sh:427-460` (Checks 13e/13f/13g shipped)

**Recommended fix:** Update `no-implementation-handoff.md` §"Tests / checks that preserve this" to mark Check 13e/13f/13g shipped (cite line numbers); keep the manual scenario test as the remaining V1 gap.

**Substrate artifact to add or update:** `docs/substrate/gotchas/no-implementation-handoff.md` §"Tests / checks that preserve this".

### 13. Intra-pack trigger competition: `discover-substrate` vs `audit-substrate`

**Severity:** Low
**Category:** Library alignment
**Why it matters:** `discover-substrate/SKILL.md:3` carries trigger phrase `"audit substrate before changing X"`; `audit-substrate` exists as a separate skill. Validator Check 9b only narrows generic triggers across plugin boundaries (Cohesive vs Superpowers); it does not catch intra-pack overlap. Direct invocation may compete; router-routed traffic is unaffected.

**Evidence:**
- `skills/discover-substrate/SKILL.md:3` (trigger phrase contains "audit")
- `validate_plugin.sh:182-199` (Check 9b — boundary-cross only)

**Recommended fix:** Tighten `discover-substrate`'s trigger from "audit substrate before changing X" to "inventory substrate before changing X." Extend Check 9b to scan intra-pack verb overlaps.

**Substrate artifact to add or update:** Edit `skills/discover-substrate/SKILL.md` frontmatter; extend `validate_plugin.sh` Check 9b.

### 14. Repair-loop stall failure-mode taxonomy undocumented

**Severity:** Low
**Category:** Locality / Future scar
**Why it matters:** `handoffs.md:90-96` documents max-passes behavior (stall banner; recommend brainstorm-design or manual repair). The user sees the same chat shape for a structurally unsolvable design, a reviewer flake, and scope creep. The loop is new (2026-05-05) and lacks production scars; document the taxonomy now or wait for the first real stall.

**Evidence:**
- `handoffs.md:90-96`
- `skills/validate-rewrite/SKILL.md` Step 4 (loop body)

**Recommended fix:** Defer until a real stall is observed; then author `docs/substrate/gotchas/repair-loop-stall-modes.md` with the failure-mode taxonomy and a stall-banner template surfacing the distinction.

**Substrate artifact to add or update:** Future gotcha; not urgent.

### 15. No friction/ergonomics gotcha for chain-announcement stacking

**Severity:** Low
**Category:** Scar without gotcha
**Why it matters:** Router announcement + subskill announcement + clarifying question can stack on a small request. `implement-cohesively` Phase 1 surfaces a dispatch budget at >8 phases; no equivalent for the design route's 4-step chain. A future contributor tightening verbosity has no documented baseline; they may simplify in ways that defeat the legibility-of-phase-transitions argument for the router.

**Evidence:**
- `skills/implement-cohesively/SKILL.md:78` (dispatch-budget surface, implementation-only)
- No equivalent for the design route's announcement stack

**Recommended fix:** Author `docs/substrate/gotchas/chain-announcement-stacking.md` naming the failure mode and the legibility tradeoff.

**Substrate artifact to add or update:** `docs/substrate/gotchas/chain-announcement-stacking.md`.

### 16. No queued-scenario-tests matrix tracking deferred behavior tests

**Severity:** Low
**Category:** Test guarantee
**Why it matters:** Multiple gotchas (`soft-prereqs.md`, `discovery-vs-superpowers.md`, `no-implementation-handoff.md`, `skipping-per-phase-plan.md`) list "Manual scenario test (planned)" as the only behavior-fence. Nothing tracks how many such gaps exist or when they get encoded. The planned-vs-real ratio is itself substrate.

**Evidence:**
- 4+ gotcha files with `Manual scenario test (planned)` rows
- No `docs/substrate/matrices/queued-scenario-tests.md`

**Recommended fix:** Author the matrix; rows = planned scenarios, columns = source gotcha, target skill, test shape, promotion-to-encoded-test status.

**Substrate artifact to add or update:** `docs/substrate/matrices/queued-scenario-tests.md`.

## Confusing or weak concepts

| Concept | Issue | Recommendation |
|---|---|---|
| `audit-substrate` verdict label | `handoffs.md` says "Gaps Found"; SKILL.md says "Substrate gaps" | Fix handoffs.md (Finding 2) |
| Skill-tool dispatch | Treated inline as if it were a special case of Task-tool dispatch | Author dedicated convention doc (Finding 4) |
| Right-sized chain | Default-pause behavior lives as one prose sentence | Promote to matrix (Finding 6) |
| Cohesive↔Superpowers grade | Two grades exist; the selection rule does not | Codify in composition-with-superpowers.md (Finding 9) |

## Invariants that should be named

| Invariant | Current enforcement | Recommended enforcement |
|---|---|---|
| **HANDOFF_VOCABULARY_PARITY** — verdict vocabulary parity across producing SKILL.md / consuming SKILL.md / handoffs.md / router.md | `spec-cohesion-reviewer` lens 14 (reviewer judgment, fires only during validate-rewrite) | Validator check extracting verdict tokens from each SKILL.md and asserting the same string appears in handoffs.md edge entries. Promote to named invariant when wording stabilizes. |
| **DISPATCH_CONTRACT_MIRROR** — `cohesively/SKILL.md` §"Dispatch prompt contract" ↔ `matrices/router.md` §"Dispatch prompt contract" | Prose annotation "update both in same pass" | Validator check (Finding 1). Promote to named invariant; or single-source the table. |
| **DESIGN_LAYER_OWNERSHIP_CANONICAL** — `architecture/skills.md` is canonical for Owns/Does-not-own claims; SKILL.md bodies reference rather than duplicate | `spec-cohesion-reviewer` lens 13 (reviewer judgment) | Validator could grep SKILL.md bodies for forbidden duplication patterns. Lower priority than the first two. |
| **SKILL_TOOL_DISPATCH_CONTRACT** — Skill-tool composition follows the four-constraint contract (repair scope; chosen direction not re-derived; commit template; per-pass paths-only on re-dispatched reviewer) | Inline body prose in `validate-rewrite` and `implement-cohesively` | Author convention doc first (Finding 4); promote to grep when shape stabilizes. |

## Test guarantee gaps

| Behavior | Current coverage | Risk | Recommended test |
|---|---|---|---|
| Soft-prereq question fires when discover-substrate not invoked | None (planned manual) | Subskills proceed without discovery; output degrades silently | Encode as fixture-based scenario test |
| Implement-now without Approved verdict surfaces directive error | None (planned manual) | Freeform code follows; substrate bypassed | Encode |
| Discovery-vs-Superpowers trigger picks correctly with both installed | None (planned manual) | Wrong plugin invoked; downstream skill output degraded | Manual scenario; encode when fixture harness exists |
| Per-phase plan skip catches Drift vs Incomplete distinction | None (planned manual) | Reviewer can't decompose failure modes; repair direction ambiguous | Encode |
| `validate-rewrite` repair loop converges or stalls within MAX_REPAIR_PASSES | None (real-session evidence only via 2026-05-05 dogfood) | Loop hides design-shape problems behind repeated cosmetic fixes | Encode synthetic-stall test |

## Locality and abstraction review

- **Router → subskills:** Clean seam. The router renders one sentence and dispatches with explicit prereq state. The duplication of the dispatch-prompt contract across two surfaces is the locality wart; finding 1 names the fix.
- **Subskill → reviewer agent:** Fence-protected by Task subprocess + canonical preamble + paths-only inputs. No drift observed; structural enforcement is the strongest in the substrate.
- **Cohesive ↔ Superpowers:** Two-grade composition is deliberate locality (different failure modes, different blast radii). Grade-selection rule absent — finding 9.
- **Internal repair loop (`validate-rewrite` ↔ `rewrite-specs`):** New (2026-05-05); per-pass fresh-eyes preserved structurally. Skill-tool dispatch contract not centralized — finding 4.
- **Suspected duplication-that-wants-abstraction:** dispatch-prompt-contract mirror (finding 1). Currently the only explicit prose-annotated mirror in the substrate.
- **No premature centralization observed.** The architecture/conventions split (read-when-changing-shape vs read-when-authoring) is the right locality, not over-decomposition.

## Library-native alignment opportunities

- `plugin.json` thinness — finding 7. Highest near-term lever.
- `using-cohesive` session-start bootstrap — finding 3. Solves first-time-user discovery directly.
- Skill-tool vs Task-tool contract separation — finding 4. Conventions-side fix.
- CI integration with harness-side validation tooling (if shipped) — finding 4 secondary; survey when checking plugin.json schema.

## Agent-readiness

- **Adding a new chain skill:** "Adding a new skill" sequence is concrete but omits validator-array updates and skill-section-presence row — finding 5.
- **Modifying an existing handoff:** `spec-cohesion-reviewer` lens 14 covers gate verdicts; the doc-list to read is implicit. Mitigated by AGENTS.md "When you are about to..." index but a verdict-rename specifically still requires reasoning across 4 surfaces.
- **Extending a route:** Bounded; the dispatch-prompt-contract mirror is the trap (finding 1). With the validator check, the change surface becomes fully bounded.
- **Promoting an inherited bootstrap-status section:** Procedure implicit — finding 10.
- **Render-template discipline spot-check:** All four sampled SKILL.md Output format blocks are pure templates; no leakage. Checks 13b/13c/13d are doing real work.

## Substrate improvements

### Specs to rewrite
1. `handoffs.md:112` — fix `Gaps Found` → `Substrate gaps` (finding 2). One-line rewrite.
2. `gotchas/no-implementation-handoff.md` — mark Check 13e/13f/13g shipped (finding 12). One-section rewrite.
3. `architecture/skills.md` §"Adding a new skill" — add Step 5 (validator updates + skill-section-presence row) (finding 5).
4. `architecture/skills.md` §"Bootstrap status" — add §"Promotion procedure" subsection (finding 10).
5. `architecture/composition-with-superpowers.md` — add §"Grade selection" (finding 9).
6. `cohesively/SKILL.md` §"Route: design" or `matrices/router.md` cells — promote default-pause prose to matrix (finding 6).
7. `matrices/router.md` §"Rules" — extend with explicit cell-vs-R900 precedence (finding 8).

### Behavior matrices to add
1. `docs/substrate/matrices/chain-pacing.md` — per-route per-step auto-chain-vs-pause (finding 6).
2. `docs/substrate/matrices/queued-scenario-tests.md` — track planned manual scenario tests by source gotcha (finding 16).

### Semantic linters to add
1. `validate_plugin.sh` Check 13i — dispatch-prompt-contract mirror diff (finding 1; promotes to `DISPATCH_CONTRACT_MIRROR` invariant when wording stable).
2. `validate_plugin.sh` Check 13j — verdict-vocabulary parity grep (finding 2's class; promotes to `HANDOFF_VOCABULARY_PARITY` invariant when wording stable).
3. `validate_plugin.sh` Check 9b extension — intra-pack trigger overlap (finding 13).
4. `validate_plugin.sh` (consider) — read `expected_skills` from disk (finding 5 secondary).

### Gotchas to document
1. `wrong-route-recovery.md` (finding 11).
2. `manifest-thinness.md` (finding 7; survey-driven).
3. `chain-announcement-stacking.md` (finding 15).
4. `repair-loop-stall-modes.md` (finding 14, deferred until real stall observed).

### Skills to add
1. `using-cohesive` (finding 3) — the highest user-facing-ergonomics lever.

### Convention docs to add
1. `skill-tool-dispatch.md` (finding 4) — separates Skill-tool contract from Task-tool contract.

## Recommended roadmap

### First: repair substrate

1. **Fix `handoffs.md:112`** — one-line spec drift; closes finding 2 immediately. (Pure implementation rewrite.)
2. **Fix `no-implementation-handoff.md`** — undersold-enforcement labels. (Pure implementation rewrite.)
3. **Add validator Check 13i (dispatch-prompt-contract mirror)** — closes finding 1's drift surface. (Pure implementation; small lint extension.)
4. **Author `using-cohesive` skill** — closes finding 3 (highest user-facing lever). Design-shape: requires §"### using-cohesive" in `architecture/skills.md`, a row in `skill-section-presence.md`, validator-array updates. *Mixed* per `skill-shape.md` §1a.
5. **Author `skill-tool-dispatch.md` convention** — closes finding 4. (Pure implementation; new doc, no design-layer change.)

### Then: simplify architecture

6. **Promote default-pause behavior to matrix** (finding 6) — `chain-pacing.md`.
7. **Resolve R016/R900 overlap** (finding 8) — extend `matrices/router.md` §"Rules".
8. **Codify Cohesive↔Superpowers grade-selection rule** (finding 9) — `composition-with-superpowers.md` §"Grade selection".
9. **Promote `architecture/skills.md` §"Adding a new skill" to include validator updates** (finding 5) and §"Bootstrap status" §"Promotion procedure" (finding 10).
10. **Survey harness manifest schema; fill `plugin.json` discoverability fields** (finding 7) — gated on schema verification.

### Then: strengthen enforcement

11. **Promote `DISPATCH_CONTRACT_MIRROR` to named invariant** once Check 13i grep wording stabilizes (criteria per `style-guide-rot.md` promotion).
12. **Promote `HANDOFF_VOCABULARY_PARITY` to named invariant** — Check 13j (verdict-vocabulary parity grep).
13. **Author `queued-scenario-tests.md` matrix** (finding 16); start encoding planned manual scenarios — soft-prereqs first (highest dogfood signal), then implement-now-without-Approved.
14. **Author wrong-route-recovery and chain-announcement-stacking gotchas** (findings 11, 15) — substrate-side scar capture for predictable user-experience defects.
15. **Defer `repair-loop-stall-modes` gotcha** (finding 14) until first production stall.

## Appendices (linked)

- Substrate discovery report: rendered inline in chat upstream of this review (the "Substrate Discovery — Cohesive skill pack (inter-skill flow surface)" section).
- External skill-pack comparison memo: rendered inline in chat upstream (the "Inter-skill flow comparison: Cohesive vs. the field" section).
- Per-reviewer raw findings: dispatched 2026-05-05 in parallel via Task tool; outputs synthesized above. Not separately persisted (chain-architecture review reuses the chat-rendered raw findings as the audit trail per substrate-layout convention).

### Recommended next Cohesive skill

- **`cohesive:rewrite-specs`** — promote convention to enforcement where leverage is highest. The roadmap's "First: repair substrate" cluster is six rewrite-shaped changes; bundling them into one rewrite pass against a delta ledger gets the highest-leverage findings (1, 2, 3, 4, 5) closed atomically with `validate-rewrite` review on the result. Suggested slug: `skill-pack-flow-tightening`. Suggested classification: **Mixed** (`using-cohesive` skill addition is design-shape; the others are pure-implementation).
