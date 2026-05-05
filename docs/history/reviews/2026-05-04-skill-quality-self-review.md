# Cohesive Architecture Review — Skill Quality & Substrate (v0.1 Release Gate, second pass)

**Date:** 2026-05-04 (afternoon, post-lexicon-rename)
**Scope:** `--scope codebase`, whole repo (Cohesive itself)
**Substrate discovery:** in-conversation, see Phase 1 below
**Reviewers dispatched:** substrate-alignment, structure, library-native, agent-readiness (4-way parallel)
**Methodology:** four-phase rubric per `${CLAUDE_PLUGIN_ROOT}/references/architecture-review-rubric.md`
**Prior art triaged:** the four review artifacts under `docs/history/reviews/` from earlier today, especially `2026-05-04-self-review-v0.1-release-gate.md`

---

## TL;DR

**Verdict:** Cohesive but under-enforced.

**Thesis:** The substrate is in better shape than this morning's release-gate review found it. The two prior structural blockers landed cleanly — the cohesive-review/cohesive-diff split is now `review-codebase` + `review-diff`, and the router→subskill dispatch-prompt contract is a per-route table in `cohesively/SKILL.md:95-117` honored by all five consumer subskills. The remaining gap is the single highest-leverage one the prior review named: **the plugin's only named invariant (`PLUGIN_ROOT_PATHS`) is still claimed-and-not-enforced by `scripts/validate_plugin.sh`** despite five top-level docs asserting otherwise. The second-highest gap is also a counter-party contract: every persisting skill still hardcodes `docs/history/...` paths, which means external-repo runs (Cohesive's actual user-facing value) silently litter that directory into user repos. Both are small concrete repairs (≤ 30 lines of bash + Step 0 in five skill bodies + one new behavior matrix). Closing them lifts the verdict to *Mostly healthy* and makes v0.1 ready to ship for external users.

**Top findings:**
1. **Blocker** — `PLUGIN_ROOT_PATHS` is the only survivor of the substrate-collapse and is still not structurally enforced; five docs claim a check the validator doesn't perform.
2. **High** — Every persisting skill (`review-codebase`, `review-diff`, `audit-substrate`, `rewrite-specs`, `brainstorm-design`, `validate-rewrite`) hardcodes Cohesive-repo artifact paths despite the documented external-repo placement contract.
3. **High** — Three of the five validator-grep checks the prior review specified are still unimplemented (canonical prereq-question, fresh-eyes preamble, recommended-next footer); each is one line and would close half of the "reviewer memory only" admissions in the gotcha docs.

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — the highest-leverage repairs are substrate-side (validator script grep, Step 0 in five skill bodies, two new behavior matrices, gotcha doc for self-review confirmation bias). Land them in a worktree and re-run `cohesive:review-diff` before merging. After that, an external-repo dogfood is the final acid test the in-repo self-review can't simulate.

---

## Claimed system shape (Phase 1)

- **Product goal.** A Claude Code plugin that helps codebases remember — substrate-first agentic engineering for senior architects building durable systems that other agents can safely extend.
- **Architectural priors.** Three-tier separation (`skills/` orchestration, `agents/` fresh-context review, `references/` content); composition with Superpowers over reinvention; fresh-eyes Task-subprocess isolation as the structural safety fence; substrate-first work; convention-over-invariant trade-off explicit until wording stabilizes; ARCHITECTURE.md > README > on-disk source-of-truth order.
- **Intended seams.** skills↔agents (Task-tool dispatch with explicit input paths); skills↔references (citation only); agents↔references (system-prompt-named working set); Cohesive↔Superpowers (composition skills with documented detection); `docs/substrate/` (current normative) vs `docs/history/` (workflow products + retired vision).
- **Named invariants.** `PLUGIN_ROOT_PATHS` only. Four others demoted to convention during the 2026-05-04 substrate-collapse.
- **Testing philosophy.** No automated tests in v0.1. Validation = `validate_plugin.sh` (structural shape, frontmatter, JSON, expected skill set, substrate-vocabulary tokens) + dogfood. CI explicitly out of scope.
- **Future direction.** V1 ships dedicated artifact skills (`create-invariant`, `create-matrix`); the validator gains the `PLUGIN_ROOT_PATHS` grep and the convention-layer greps; conventions earn invariant status when wording stabilizes; manual scenario tests named in gotcha docs get written.

Phase 1.5 sparse-substrate gate: passed (rich substrate). Phase 2 spec-prior gate: passed (no blocking spec contradictions; the validator-vs-claim drift is a single known issue, honestly named in `PLUGIN_ROOT_PATHS.md` itself).

---

## Triage of the prior release-gate review

| # | Prior finding | Status |
|---|---|---|
| 1 | `PLUGIN_ROOT_PATHS` not structurally enforced | **Open** (re-confirmed by 2 reviewers) |
| 2 | Router→subskill prereq-state contract one-sided | **Closed** — `cohesively/SKILL.md:95-117` adds the per-route dispatch-prompt-contract table |
| 3 | External-repo artifact directory unwired | **Open** (re-confirmed by 3 reviewers) |
| 4 | No tests for any convention | **Partial** — two of five validator greps landed (expected-skill-set, substrate-vocabulary token); three remain |
| 5 | `cohesive-review/SKILL.md` is two skills in one body | **Closed** — split into `review-codebase` and `review-diff`, with non-overlapping bodies and clean adjacency cross-references |
| 6 | Inverted citation in `design-pressure-testing.md` | Not re-checked |
| 7 | No skill-section-presence matrix | **Open** |
| 8 | Discovery-vs-Superpowers seam in router triggers | **Open** (sharpened by agent-readiness reviewer below) |
| 9 | Demoted-invariant lineage invisible | Partially addressed via lexicon-rename ledger |

---

## Cohesion scorecard (9 axes)

| Axis | Rating | Note |
|---|---|---|
| 1. Spec coherence | **Mostly healthy** | One persistent contradiction: five docs claim `validate_plugin.sh` enforces `PLUGIN_ROOT_PATHS`; the script and the invariant doc disagree. |
| 2. Code/spec alignment | **Drifting** | Validator doesn't deliver the named invariant; persisting skills don't honor the documented external-repo placement contract. |
| 3. Domain model clarity | **Healthy** | Substrate / invariant / matrix / gotcha / convention vocabulary is sharp and consistently applied. |
| 4. Invariant enforcement | **Under-enforced** | The one named invariant has no structural grep; convention layer is reviewer-judged. |
| 5. Test guarantees | **At risk** | Zero automated behavior tests. Two new validator checks landed but the gotcha-named "planned" tests are still unwritten. |
| 6. Locality and seams | **Healthy** | Three-tier separation holds on disk; the skill split removed the largest internal locality blot; no new ones surfaced. |
| 7. Library-native alignment | **Healthy** | Correctly uses Skill/Task tools, frontmatter idioms, `${CLAUDE_PLUGIN_ROOT}`, parallel-Task dispatch. Path discipline is genuinely honored on disk (zero hardcoded `/home/...` outside of anti-pattern examples). Validator emoji output is the one minor mismatch. |
| 8. Agent-readiness | **Mostly healthy (internal) / Drifting (external)** | Internal contributors are well-served; external user-agents still face the validator-claim / external-repo-paths / generic-trigger triad. |
| 9. Future extensibility | **Mostly healthy** | Demotion mechanics are documented; promotion criteria less so. The `validate-rewrite` exception to the dispatch contract is named in prose but not in the router matrix — a predictable extension footgun. |

---

## Highest-leverage findings (ranked)

### 1. The plugin's only named invariant is still not structurally enforced

**Severity:** Blocker
**Category:** Invariant / Spec drift (cross-doc)

**Why it matters:** `PLUGIN_ROOT_PATHS` is the one rule Cohesive kept after the 2026-05-04 substrate collapse — kept *specifically because* it has a real runtime failure mode and (per its own doc) deserves structural enforcement. Five top-level docs claim the rule is "enforced by `scripts/validate_plugin.sh`": `ARCHITECTURE.md:35,46`, `AGENTS.md:24`, `README.md:124`, `references/skill-conventions.md:106`. The script (currently 161 lines, with two new substrate-discipline checks added since this morning) contains zero grep for `/home/`, `/Users/`, `/usr/local/`, or `~/` — only a warn-level path-existence check. A new agent file with `/home/toda/...` passes validation cleanly. By the methodology Cohesive itself articulates, the named invariant is held by reviewer memory — the exact failure mode the substrate-collapse said the invariant set must not contain. Two reviewers confirmed independently.

**Evidence:** `scripts/validate_plugin.sh:1-161` (no path-pattern grep); contradicting claims at `ARCHITECTURE.md:35,46`, `README.md:124`, `AGENTS.md:24`, `references/skill-conventions.md:106`. Honest counter-claim at `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md:32-38`.

**Recommended fix:** Add the grep — five lines of bash:

```bash
if grep -rnE '(^|[^A-Z_])/(home|Users|usr/local)/' skills/ agents/ references/ 2>/dev/null \
     | grep -vE '(```|<!-- anti-pattern|Anti-pattern:)'; then
  fail "PLUGIN_ROOT_PATHS violation: hardcoded absolute path"
fi
```

Then sweep the five overstating docs in a single pass to match what the script now actually does.

**Substrate artifact to add or update:** Semantic linter (`scripts/validate_plugin.sh`); update `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` "Enforcement" section from "intended state" to "current state"; cross-doc cleanup of the five overstating claims.

---

### 2. External-repo artifact directory contract is documented in prose, unwired in every persisting skill

**Severity:** High
**Category:** Spec drift / Locality / External-user composability

**Why it matters:** `AGENTS.md:57` and `ARCHITECTURE.md:48` document an external-repo artifact-directory protocol with detection of `docs/design/`, `docs/specs/`, `docs/adr/`, `docs/invariants/`, `docs/gotchas/`, `docs/substrate/`, `docs/history/`. Every skill that persists output hardcodes Cohesive-repo locations: `review-codebase` and `audit-substrate` write to `docs/history/reviews/`; `rewrite-specs` writes to `docs/history/delta-ledgers/`; `brainstorm-design` writes to `docs/history/brainstorms/`; `validate-rewrite` writes to `docs/history/reviews/`. The detection logic exists in *zero* skill bodies. An external-repo run silently creates `docs/history/` in the user's repo (wrong place per the documented contract) and ignores any pre-existing `docs/specs/` or `docs/adr/`. Three reviewers flagged this. Cohesive's actual user-facing value is external-repo runs; the in-repo dogfood case happens to mask the bug. **This is the user-impacting failure most likely to bite on first non-Cohesive run.**

**Evidence:** `skills/review-codebase/SKILL.md:10,110-112`; `skills/audit-substrate/SKILL.md:9,96`; `skills/rewrite-specs/SKILL.md:11,89`; `skills/brainstorm-design/SKILL.md:163`; `skills/validate-rewrite/SKILL.md:10,67`; contract at `AGENTS.md:57`, `ARCHITECTURE.md:48`.

**Recommended fix:** Add a "Step 0: Resolve artifact directory" preamble to each of the five persisting skills, citing one shared reference. Centralize the detection rules in `references/substrate-layout.md`. Add `docs/substrate/matrices/artifact-placement.md` with cells (this-repo / external-with-docs-substrate / external-with-docs-adr / external-empty) × (review / audit / delta-ledger / brainstorm / validation) so the contract is testable.

**Substrate artifact to add or update:** Reference (`substrate-layout.md` detection rules); five skill bodies (Step 0); behavior matrix (`artifact-placement.md`).

---

### 3. Three convention-layer greps still missing from the validator

**Severity:** High
**Category:** Test guarantee / Invariant enforcement

**Why it matters:** Two of the five recommended grep checks landed (expected-skill-set, substrate-vocabulary token at `validate_plugin.sh:120-151`); three remain unimplemented:

- (a) The canonical prereq-detection question fragment in the five subskill bodies (`brainstorm-design`, `rewrite-specs`, `review-codebase`, `review-diff`, `audit-substrate`).
- (b) The fresh-eyes preamble verbatim across the five reviewer agents.
- (c) The `### Recommended next Cohesive skill` footer in every persisting skill.

Each is one line of grep. Each closes a self-admitted "reviewer memory only" gap in the gotcha docs (`soft-prereqs.md:55-60`, `discovery-vs-superpowers.md:51-54`). The substrate-collapse moved four invariants to conventions on the bet that wording would stabilize and tests would land. Wording has stabilized. Half the tests are now in. The other half is a 30-minute job.

**Evidence:** `scripts/validate_plugin.sh:1-161` (no convention greps beyond expected-skill-set and substrate-vocabulary); `docs/substrate/gotchas/soft-prereqs.md:55-60`; `docs/substrate/gotchas/discovery-vs-superpowers.md:51-54`.

**Recommended fix:** Three additional grep blocks in `validate_plugin.sh`, one per convention. Each is ≤5 lines.

**Substrate artifact to add or update:** Semantic linter (`scripts/validate_plugin.sh`).

---

### 4. Router frontmatter triggers still overlap with Superpowers' generic-review skills

**Severity:** Medium-High
**Category:** Cross-plugin contract / External-user routing

**Why it matters:** An external user-agent on a non-Cohesive repo with both Cohesive and Superpowers installed sees `cohesively`'s description trigger on "review the architecture", "review the codebase", "is this codebase healthy" — directly overlapping Superpowers' code-reviewer / research / exploration skills. The new substrate-vocabulary check (validator step 9) verifies that descriptions *contain* a Cohesive token (e.g., "cohesion") but does not check that they *avoid* generic-review verbs. A description that says "Use when you want to review the codebase for cohesion" passes the positive-token check while still claiming generic-review trigger surface. The agent-readiness reviewer surfaced this sharpening of the prior finding 8.

**Evidence:** `skills/cohesively/SKILL.md` frontmatter; `skills/review-codebase/SKILL.md` frontmatter; `scripts/validate_plugin.sh:139-151` (positive-token-only check); contract at `docs/substrate/gotchas/discovery-vs-superpowers.md`.

**Recommended fix:** Tighten validator check 9 to also fail when descriptions contain `review the codebase`, `review the architecture`, `is this codebase healthy`, or other documented generic-review phrases — *unless* paired with an explicit cohesion-narrowing clause. Audit Cohesive's eight skill descriptions and tighten any that overlap.

**Substrate artifact to add or update:** Semantic linter (negative-trigger check); `discovery-vs-superpowers.md` (codify the negative-trigger list).

---

### 5. No behavior tests for the skill chain — confirms missing-memory hypothesis

**Severity:** High
**Category:** Test guarantee / Agent-readiness

**Why it matters:** A future agent "tidying" the dispatch-prompt-contract table in `cohesively/SKILL.md:95-117` could drop a row; nothing structurally fails. The contract is a 6-row table referenced by 5 subskills' Hard Constraints — exactly the pattern that *only* a behavior test catches. Substrate alone (the matrix exists) doesn't prevent regression because an agent making the change reads the matrix as descriptive, not normative. The agent-readiness reviewer confirmed: this is missing memory no other artifact substitutes for. The same applies to the router's announcement form, the `Empty-substrate verdict: yes` line, and the per-route clarifying questions.

**Evidence:** No `tests/` dir; no scenario fixtures under `docs/history/transcripts/`; the dispatch-prompt-contract table at `cohesively/SKILL.md:95-117` has no structural pin.

**Recommended fix:** Add `tests/scenarios/` with one fixture per router route (six scenarios). Each scenario is a saved transcript: input → expected announcement → expected dispatch-prompt fragment. A small Python script asserts the canonical strings appear in the live router and subskill bodies. Combine with finding 3 — the validator greps are the *static* half; the scenarios are the *dynamic* half.

**Substrate artifact to add or update:** Scenario tests (`tests/scenarios/router-dispatch.md`, six rows) + grep pin in `validate_plugin.sh` (component of finding 3).

---

### 6. Self-review confirmation-bias gotcha still unwritten

**Severity:** Medium
**Category:** Scar / Hidden rule

**Why it matters:** The prior review's caveat (lines 267-274) named the failure mode — methodology validating itself privileges its own taxonomy. A future agent running another self-review (this is the *fourth* today) will rediscover the same axis-8 issues because the rubric privileges Cohesive's vocabulary. Without `docs/substrate/gotchas/dogfood-convergence.md`, each self-review pays the cost of re-deriving the caveat from first principles, or worse, omits it. The user explicitly flagged this as missing memory; agent-readiness reviewer agreed.

**Evidence:** `docs/substrate/gotchas/` contains 2 files, neither covering self-review confirmation bias; the caveat appears in prose at `docs/history/reviews/2026-05-04-self-review-v0.1-release-gate.md:267-274` but is not promoted to substrate.

**Recommended fix:** Two-paragraph gotcha doc as the prior review specified, with a checklist item: "before persisting any self-review, name one finding the methodology's vocabulary would *suppress*."

**Substrate artifact to add or update:** Gotcha (`docs/substrate/gotchas/dogfood-convergence.md`).

---

### 7. No skill-section-presence matrix tracks per-skill canonical-section compliance

**Severity:** Medium
**Category:** Centralization (under-enforced)

**Why it matters:** `references/skill-conventions.md` lists section-deviation exemptions; no matrix tracks which canonical sections each of the now-eight skills carries. `docs/substrate/matrices/` contains only `reviewer-output-shape.md` and `router.md`. Drift surfaces only if a reviewer happens to notice. The `reviewer-output-shape.md` matrix is the working precedent: it caught and named drift across five agent files in a single grid. The same shape applied to skill-section presence would catch skill-body drift and (combined with finding 3) become testable.

**Evidence:** `ls docs/substrate/matrices/` → 2 files; precedent at `docs/substrate/matrices/reviewer-output-shape.md`.

**Recommended fix:** Add `docs/substrate/matrices/skill-section-presence.md` — 8 rows × ~10 columns (canonical sections + accepted-optional sections). Mirrors `reviewer-output-shape.md` exactly.

**Substrate artifact to add or update:** Behavior matrix (`docs/substrate/matrices/skill-section-presence.md`).

---

### 8. Smaller items (rolled up; each ≤ Low–Medium severity)

| # | Finding | Severity | Substrate artifact |
|---|---|---|---|
| 8a | `validate_plugin.sh` uses ❌/⚠️/✅/🔍 emoji while skill-conventions forbids emoji in skill outputs — convention drift | Low | One-line script fix or one-line conventions exemption |
| 8b | Validator parses YAML frontmatter via awk state machines despite Python being a hard dependency — reinvention | Low | Move frontmatter checks to a small Python helper |
| 8c | `discover-substrate` "Empty-substrate verdict" is a labeled-bold line, not a heading — concept doing structural work is invisible to external composers reading just one SKILL.md | Low | Promote to `### Empty-substrate verdict` in the skill's "Output format" section |
| 8d | `validate-rewrite` exception to the dispatch-prompt contract is named in prose only (`cohesively/SKILL.md:115`); not in `docs/substrate/matrices/router.md` | Low | Mirror exception as a "no prereq" row in `router.md` |
| 8e | Composition-with-Superpowers detection mechanism is "if available" without naming the platform-native check (the available-skills system reminder) | Low | One sentence in `rewrite-specs/SKILL.md` and the design doc |
| 8f | `plugin.json` description is a 75-word paragraph; marketplace cards truncate to ~120 chars — `marketplace.json` already has the right short tagline | Low | Swap roles or shorten `plugin.json.description` |
| 8g | Router dispatch-prompt-contract table partially restates rationale that lives in `soft-prereqs.md`; collapse the prose around the table to one sentence | Low | Trim `cohesively/SKILL.md` |

---

## Substrate improvements (consolidated)

By artifact type:

- **Semantic linter (`scripts/validate_plugin.sh`):** add greps for (a) `PLUGIN_ROOT_PATHS` violations [finding 1], (b) canonical prereq question in five subskills [finding 3], (c) fresh-eyes preamble verbatim across five agents [finding 3], (d) `### Recommended next Cohesive skill` footer in every persisting skill [finding 3], (e) negative-trigger check on Cohesive descriptions [finding 4]. Each ≤5 lines.
- **Behavior matrices (new):** `artifact-placement.md` [finding 2]; `skill-section-presence.md` [finding 7]. Both mirror the working `reviewer-output-shape.md` precedent.
- **Skill bodies (5 persisting skills):** add "Step 0: Resolve artifact directory" citing `references/substrate-layout.md` [finding 2].
- **Skill body (`cohesively/SKILL.md`):** trim restated rationale around the dispatch table [finding 8g]; verify negative-trigger compliance [finding 4].
- **Skill body (`discover-substrate/SKILL.md`):** promote "Empty-substrate verdict" to a labeled section heading [finding 8c].
- **Skill body (`rewrite-specs/SKILL.md`):** name the platform-native Superpowers detection mechanism [finding 8e].
- **Reference (`substrate-layout.md`):** add the external-repo detection rules [finding 2].
- **Reference (`skill-conventions.md`):** rephrase step-5 validator-coverage claim to match what the validator now actually does [finding 1 follow-up].
- **Gotcha (new):** `docs/substrate/gotchas/dogfood-convergence.md` [finding 6].
- **Scenario tests (new):** `tests/scenarios/router-dispatch.md` [finding 5].
- **Cross-doc cleanup:** align `ARCHITECTURE.md`, `README.md`, `AGENTS.md`, `skill-conventions.md` to whatever `validate_plugin.sh` actually does after finding 1 lands [finding 1 follow-up].
- **Tooling:** move frontmatter parsing to Python [finding 8b]; replace emoji in validator output [finding 8a]; shorten `plugin.json` description [finding 8f]; mirror `validate-rewrite` exception in router matrix [finding 8d].

---

## Phased roadmap

The order matters: substrate first, structure second, enforcement third. Inverting it produces churn.

### Phase 1: Close the named-contract gaps (release-gating)

1. Implement the `PLUGIN_ROOT_PATHS` grep in `validate_plugin.sh` [finding 1]. ~5 lines of bash.
2. Sweep `ARCHITECTURE.md` / `README.md` / `AGENTS.md` / `skill-conventions.md` to match what the validator now does [finding 1 follow-up].
3. Add "Step 0: Resolve artifact directory" to five persisting skills + the detection rules to `substrate-layout.md` [finding 2]. One paragraph each, one shared reference.
4. Add `docs/substrate/matrices/artifact-placement.md` [finding 2 follow-up].

After Phase 1, the verdict moves from *Cohesive but under-enforced* to *Mostly healthy*. **v0.1 is ready to ship at this point.**

### Phase 2: Strengthen enforcement (turn convention into automation)

5. Land the three remaining grep checks in `validate_plugin.sh` [finding 3]: canonical prereq question, fresh-eyes preamble, recommended-next footer.
6. Tighten validator check 9 with the negative-trigger list [finding 4].
7. Add the second behavior matrix `skill-section-presence.md` [finding 7].
8. Address the small items (8a–8g) in a single sweep.

### Phase 3: Behavior tests (the half-completed substrate-collapse bet)

9. Add `tests/scenarios/router-dispatch.md` with one scenario per router route [finding 5]. The static greps from Phase 2 are the structural half; these are the dynamic half.
10. Write the `dogfood-convergence` gotcha [finding 6] before the next self-review pass.

### What v0.1 still owes (deferred to V1)

- Dedicated artifact skills (`create-invariant`, `create-matrix`) per the artifact route deferral.
- Re-promotion criteria for demoted invariants (only meaningful once Phase 2 enforcement lands).
- Real external-repo dogfood transcripts under `docs/history/transcripts/` (the existing reviews are all in-repo).

---

## Self-referential caveat

This is the **fifth self-review** today and the second one explicitly framed as a release-gate review. The Phase 3 reviewer dispatch ran in parallel with no cross-talk and no inherited context — the structural fence (Task-subprocess isolation) holds. The convergence between the four reviewers is a positive signal: three of them independently flagged findings 1, 2, and 3 as the top items; the disagreement was about ranking, not existence.

Two effects to watch:

1. **Confirmation alignment.** This review's rubrics are Cohesive's own. A codebase using a *different* substrate taxonomy with the same effect would underscore on these axes. None of the v0.1 findings depend on this; future external-repo dogfood should be the corrective.
2. **Self-review fatigue.** Four prior reviews today means the substrate has been read four times by reviewers who may carry residual ranking bias from earlier passes. The fresh-eyes preamble mitigates but doesn't eliminate this. Phase 3 work (behavior tests + dogfood-convergence gotcha) addresses both effects structurally.

(This caveat does not raise the findings count; it adds weight to finding 6.)

---

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — Phase 1 is bounded substrate-side work (validator grep, five Step 0 sections, one new behavior matrix, doc cleanup). Land it in a worktree and re-run `cohesive:review-diff` before merging.

After Phase 1 ships, the next acid test is an end-to-end external-repo dogfood — running `cohesive:cohesively review the architecture` against a real non-Cohesive repo. The v0.1 self-review can't simulate it, and finding 2 means it's also the failure mode most likely to surface fresh issues no in-repo review will catch.
