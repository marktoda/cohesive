# Cohesive Architecture Review — v0.1 Release-Gate Self-Review

**Date:** 2026-05-04
**Scope:** `--scope codebase`, whole repo (Cohesive itself)
**Substrate discovery:** in-conversation, see Phase 1 below
**Reviewers dispatched:** substrate-alignment, structure, library-native, agent-readiness (4-way parallel)
**Methodology:** four-phase rubric per `${CLAUDE_PLUGIN_ROOT}/references/architecture-review-rubric.md`

---

## TL;DR

**Verdict:** Cohesive but under-enforced.

**Thesis:** The substrate is uncommonly well-shaped — three-tier separation is held cleanly on disk, the substrate-collapse design (demote rules with unstable wording from invariant to convention) is internally consistent, and the documentation teaches future contributors the seams that matter. The methodology is right. The gap is enforcement: the one named invariant Cohesive ships (`PLUGIN_ROOT_PATHS`) is asserted by three top-level docs to be enforced by `validate_plugin.sh`, but the script does no such check; the router→subskill contract for prereq state is claimed by four subskills and absent in the router; the external-repo artifact directory is documented in prose and unwired in every persisting skill. Each gap is a contract two halves of the substrate disagree about — the substrate names the rule but the implementation doesn't realize it. By the project's own thesis, that is the *exact* failure mode Cohesive exists to prevent. Closing the top three findings is small concrete work (≤ 30 lines of bash + a router section + a placement matrix) and lifts the verdict to *Mostly healthy*.

**Top findings:**
1. `PLUGIN_ROOT_PATHS` is named-and-claimed-enforced; the script does not enforce it — the one survivor of substrate-collapse has no structural fence.
2. Router→subskill prereq-state contract is one-sided — subskills claim the router passes "discovery already complete; report at <path>"; router never does.
3. External-repo artifact directory (`docs/cohesive/<x>/` with detection of repo conventions) is documented in `AGENTS.md` and `ARCHITECTURE.md`; every persisting skill hardcodes this-repo paths instead.

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — the highest-leverage repairs are substrate-side (validator script, router section, placement matrix, conventions-vs-validator boundary). Land them in a worktree and re-run `cohesive-review --scope diff` before merging.

---

## Claimed system shape (Phase 1)

- **Product goal.** A Claude Code plugin that helps codebases remember — substrate-first agentic engineering for senior architects building durable systems.
- **Architectural priors.** Three-tier separation (`skills/` orchestration, `agents/` fresh-context review, `references/` content); compose with Superpowers, don't reinvent; fresh-eyes reviewer dispatch with structural fence at Task-subprocess isolation; substrate-first work; convention-over-invariant until wording stabilizes; ARCHITECTURE.md > README > on-disk source-of-truth order.
- **Intended seams.** skills↔agents (Task-tool dispatch), skills↔references (citation), agents↔references (system-prompt-named working set), Cohesive↔Superpowers (composition skills), `docs/substrate/` (current normative) vs `docs/history/` (workflow products + retired vision).
- **Named invariants.** `PLUGIN_ROOT_PATHS` only. Four others (FRESH_EYES_DISPATCH, ROUTER_ANNOUNCES_BEFORE_DISPATCH, ONE_PRECISE_QUESTION, and a fourth) demoted to conventions during the 2026-05-04 substrate collapse.
- **Testing philosophy.** No automated tests in v0.1. Validation = `validate_plugin.sh` (structural shape, frontmatter, JSON, file-existence) + dogfood. CI explicitly out of scope.
- **Future direction.** V1 ships dedicated artifact skills (`invariant`, `matrix`); the `PLUGIN_ROOT_PATHS` grep gets implemented; conventions earn invariant status when wording stabilizes; manual scenario tests named in gotcha docs get written.

Phase 1.5 sparse-substrate gate: passed (rich substrate). Phase 2 spec-prior gate: passed (no blocking spec-level contradictions; the validator-enforcement drift is *acknowledged* in `PLUGIN_ROOT_PATHS.md` itself, which is honest about the gap).

---

## Cohesion scorecard (9 axes)

| Axis | Rating | Note |
|---|---|---|
| 1. Spec coherence | **Mostly healthy** | Three top-level docs disagree about whether `validate_plugin.sh` enforces `PLUGIN_ROOT_PATHS`; the invariant doc is honest, the others aren't. |
| 2. Code/spec alignment | **Drifting** | Validator script doesn't deliver the invariant the docs name; router doesn't honor the prereq-state contract subskills assume. |
| 3. Domain model clarity | **Healthy** | Substrate / invariant / matrix / gotcha / convention vocabulary is sharp and consistently applied. |
| 4. Invariant enforcement | **Under-enforced** | The one named invariant has no structural grep. The convention layer is entirely reviewer-judged. |
| 5. Test guarantees | **At risk** | Zero automated tests. Two gotcha docs name "planned" scenario tests; both lists empty. The V1-lint admission is widespread. |
| 6. Locality and seams | **Mostly healthy** | Three-tier separation holds on disk; one inverted citation is acknowledged debt; `cohesive-review/SKILL.md` is two distinct workflows in one body. |
| 7. Library-native alignment | **Healthy** | Correctly uses Skill/Task tools, frontmatter idioms, `${CLAUDE_PLUGIN_ROOT}`, parallel-Task dispatch. The substrate-collapse design shows meta-discipline about platform vs convention. |
| 8. Agent-readiness | **Drifting** | Three counter-party contracts (router-flag, external-repo paths, validator-coverage) where one half claims the other half does work that doesn't happen. |
| 9. Future extensibility | **Mostly healthy** | Demotion mechanics are documented; promotion criteria less so. New-skill drift would land undetected without a skill-section matrix. |

---

## Highest-leverage findings (ranked)

### 1. The plugin's only named invariant is not structurally enforced

**Severity:** Blocker
**Category:** Invariant enforcement / Spec drift (cross-doc)

**Why it matters:** `PLUGIN_ROOT_PATHS` is the one rule Cohesive kept as a named invariant after the 2026-05-04 substrate collapse — kept *specifically because* it has a real runtime failure mode and (per its own doc) deserves structural enforcement. Three top-level docs claim the rule is "enforced by `scripts/validate_plugin.sh`": `ARCHITECTURE.md:35`, `ARCHITECTURE.md:46`, `AGENTS.md:24`, `README.md:124`, `references/skill-conventions.md:106`. The script (re-read at v0.1 commit) checks frontmatter, JSON validity, component-dir placement, executable bits, and emits a `warn` (never `fail`) when a `references/...` or `templates/...` path doesn't resolve — only inside `skills/`, never in `agents/` or `references/`. There is no grep for `/home/`, `/Users/`, `/usr/`, or `~/`. A hardcoded path in a new agent file passes validation cleanly. By the methodology Cohesive itself articulates, the named invariant is held by reviewer memory — exactly what the substrate-collapse said the invariant set must not contain.

**Evidence:** `scripts/validate_plugin.sh:1-127` (no path-pattern grep, only path-existence warn at lines 99-108); contradicting claims at `ARCHITECTURE.md:35,46`, `README.md:124`, `AGENTS.md:24`, `references/skill-conventions.md:106`. The honest counter-claim is at `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md:32-38` ("intended state, not yet implemented").

**Recommended fix:** Implement the grep — five lines of bash:

```bash
if grep -rnE '(^|[^A-Z_])/(home|Users|usr/local)/' skills/ agents/ references/ 2>/dev/null \
     | grep -vE '(```|<!-- anti-pattern|Anti-pattern:)'; then
  fail "PLUGIN_ROOT_PATHS violation: hardcoded absolute path"
fi
```

The rule is well-scoped; there's no reason to keep three docs claiming enforcement that doesn't exist. This is the single-highest-leverage repair in the report.

**Substrate artifact:** `scripts/validate_plugin.sh` (extend); `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` (move "intended state" to "current state"); cleanup pass on the three docs that overstate.

---

### 2. Router→subskill prereq-state contract is one-sided

**Severity:** Blocker (for the user experience the README markets)
**Category:** Spec drift (cross-component)

**Why it matters:** Four subskills (`brainstorm-design/SKILL.md:26`, `rewrite-specs/SKILL.md:22`, `cohesive-review/SKILL.md:35`, `substrate-audit/SKILL.md:27`) state in their Hard Constraints: *"When the `cohesively` router invokes this skill, it passes 'discovery already complete; report at <path>' in the dispatch prompt and this skill skips the question."* The router (`skills/cohesively/SKILL.md`) contains no instruction to do this — `grep "discovery already complete"` returns zero hits in the router body. Two failure paths follow: (a) an agent reading only the router will dispatch subskills without the flag and the user gets the canonical clarifying question on top of an already-routed turn; (b) an agent reading only a subskill will believe the router does something it doesn't, and the substrate teaches a contract neither side honors. The whole point of `soft-prereqs.md`'s "router-driven case" exemption was to avoid the double-prompt; the implementation never delivered the exemption.

**Evidence:** `skills/cohesively/SKILL.md` Routes section (no dispatch-prompt content named); `skills/brainstorm-design/SKILL.md:26`, `skills/rewrite-specs/SKILL.md:22`, `skills/cohesive-review/SKILL.md:35`, `skills/substrate-audit/SKILL.md:27` all assert the router contract; `docs/substrate/gotchas/soft-prereqs.md:41-42` describes the contract.

**Recommended fix:** Add a "Dispatch prompt contract" section to `cohesively/SKILL.md` listing, per route, the explicit strings the router includes in each subskill dispatch (discovery state + path, chosen direction or brainstorm path, scope hint). Mirror in `docs/substrate/matrices/router.md` as a new "Dispatch payload" column per cell.

**Substrate artifact:** Skill body (cohesively); behavior matrix (router.md).

---

### 3. External-repo artifact directory documented in prose, unwired in skill bodies

**Severity:** High (every external-repo run is affected)
**Category:** Spec drift / Locality

**Why it matters:** `AGENTS.md:57` and `ARCHITECTURE.md:48` state: "When Cohesive runs against an *external* repo, the default-artifact directory is `docs/cohesive/<x>/` with detection of existing repo conventions (`docs/design/`, `docs/specs/`, `docs/adr/`, `docs/invariants/`, `docs/gotchas/`, `docs/substrate/`, `docs/history/`) preferring existing if present." Every skill that persists output hardcodes Cohesive-repo locations: `cohesive-review` writes to `docs/history/reviews/`, `substrate-audit` writes to the same, `rewrite-specs` writes to `docs/history/delta-ledgers/`, `brainstorm-design` writes to `docs/history/brainstorms/`. The "detection of existing repo conventions" logic exists in *no* skill body. An external-repo `cohesive-review` run silently creates `docs/history/` in the user's repo (wrong place per the documented contract) and ignores any `docs/specs/` or `docs/adr/` already there. Cohesive's actual user-facing value is external-repo runs; the dogfood case happens to mask the bug.

**Evidence:** `skills/cohesive-review/SKILL.md:12,127`, `skills/substrate-audit/SKILL.md:96`, `skills/rewrite-specs/SKILL.md` (artifact path), `skills/brainstorm-design/SKILL.md` (artifact path); contract at `AGENTS.md:57`, `ARCHITECTURE.md:48`.

**Recommended fix:** Add a "Step 0: Resolve artifact directory" to each persisting skill, citing `references/substrate-layout.md` for the detection rules. The detection logic itself goes once, in `substrate-layout.md`. Add a behavior matrix `docs/substrate/matrices/artifact-placement.md` with cells (this-repo / external-repo-with-docs-substrate / external-repo-with-docs-adr / external-repo-empty) × (review / audit / delta-ledger / brainstorm) so the contract is testable.

**Substrate artifact:** Reference (substrate-layout.md detection rules); skill bodies (Step 0 in 4 skills); behavior matrix (artifact-placement.md).

---

### 4. No tests for any convention; named "planned" lists are all empty

**Severity:** High
**Category:** Test guarantee

**Why it matters:** `soft-prereqs.md:55-60` lists three "Manual scenario test (planned)" items and one "Lint check (V1)"; `discovery-vs-superpowers.md:51-54` lists three more; the soft-prereqs gotcha self-admits "If this checks list is empty, the gotcha is enforced by reviewer memory only." It is empty. A future contributor "tidying" the prereq-question prose in any of the three subskills can silently delete the canonical question; nothing fails. The substrate-collapse moved four invariants to conventions on the bet that wording would stabilize and tests would land before the wording mattered. Wording has stabilized (substrate-alignment review confirms canonical question form is verbatim across the three subskills, fresh-eyes preamble is verbatim across all five agents). The tests are still missing. The bet is half-completed.

**Evidence:** `docs/substrate/gotchas/soft-prereqs.md:55-60`, `docs/substrate/gotchas/discovery-vs-superpowers.md:51-54`; no `tests/` dir; no scenario fixtures under `docs/history/transcripts/`; `validate_plugin.sh` performs no convention grep.

**Recommended fix:** Add five small grep-based checks to `validate_plugin.sh`: (a) each of the three subskill bodies contains the canonical prereq question fragment; (b) each of the five agent files contains the canonical fresh-eyes preamble bullet verbatim; (c) `discover-substrate`'s description does not contain "explore" or generic-discovery triggers; (d) every persisting skill body contains a `### Recommended next Cohesive skill` footer; (e) every skill frontmatter `description` begins with `Use when`. Each is one line. Together they retire roughly half the "reviewer memory only" admissions in the substrate.

**Substrate artifact:** Semantic linter (`validate_plugin.sh` — five grep checks).

---

### 5. `cohesive-review/SKILL.md` is two distinct skills in one body; the substrate-audit precedent has not been followed through

**Severity:** Medium
**Category:** Locality / Seam

**Why it matters:** The skill body holds two genuinely distinct workflows: codebase mode (5-phase synthesis + sparse-substrate gate + spec-prior gate + 4-reviewer dispatch) and diff mode (lightweight 2-reviewer dispatch with chat-only output). They share `discover-substrate` invocation and the dispatch shape; they share no rubric, no synthesis logic, no persistence rule. The file is 256 lines, the largest in `skills/`. A contributor changing diff-mode behavior scrolls past 130 lines of codebase-mode rubric. `substrate-audit` was extracted from this same skill on identical reasoning — `skills/substrate-audit/SKILL.md:12` cites the precedent ("its previous existence as `--scope substrate` here was a category error"). The same logic applies to splitting diff mode; the precedent has not been carried through. The skill-quality cost is composability: the two modes can't be invoked or recommended independently from a router footer without naming the mode flag, which leaks one skill's API into the other's. *(Co-flagged by the user's request about skill quality.)*

**Evidence:** `skills/cohesive-review/SKILL.md:41-129` (codebase mode) vs `skills/cohesive-review/SKILL.md:131-188` (diff mode); precedent at `skills/substrate-audit/SKILL.md:12`.

**Recommended fix:** Either split into `cohesive-review` (codebase) and `cohesive-diff-review`, mirroring the substrate-audit extraction; or accept the two-mode shape and add a third entry to `references/skill-conventions.md` §"When sections may differ" naming scope-modal skills as an accepted deviation. The status quo — undocumented mode-switching in one body — is the worst spot.

**Substrate artifact:** Either extract a new skill, or document the deviation. *Recommendation: extract.* The substrate-audit precedent is 18 days old; honoring it costs little.

---

### 6. Inverted citation in `design-pressure-testing.md` persists as acknowledged debt

**Severity:** Medium
**Category:** Seam

**Why it matters:** The three-tier separation forbids references citing skills as canonical homes for output formats. `references/design-pressure-testing.md:94` cites `${CLAUDE_PLUGIN_ROOT}/skills/brainstorm-design/SKILL.md` exactly that way. The `three-layer-architecture.md:47` design doc names this case as known debt. Every release that ships with the inversion weakens the rule by example — the reviewer the design doc names as the rule's enforcer (`structure-reviewer`) now has to make exceptions for the rule's home repo.

**Evidence:** `references/design-pressure-testing.md:94`; `docs/substrate/designs/three-layer-architecture.md:47`.

**Recommended fix:** Move the canonical "Pressure test summary" output format from `brainstorm-design/SKILL.md` into `design-pressure-testing.md` (it's pure content, belongs in references); the skill cites the reference instead. ~10 lines.

**Substrate artifact:** Reference (`design-pressure-testing.md`) + skill body (`brainstorm-design`).

---

### 7. No matrix tracks per-skill section presence

**Severity:** Medium
**Category:** Centralization (under-enforced)

**Why it matters:** `skill-conventions.md:153-160` lists two accepted section deviations (`cohesively`, `discover-substrate`) and says any additional deviation requires "explicit discussion." There is no matrix tracking which of the canonical sections each of the 7 skills actually carries; drift surfaces only when a reviewer happens to notice. The `reviewer-output-shape.md` matrix is the working precedent: it caught and named drift across 5 agent files and produced a single grid where compliance is visible at a glance. The same shape applied to skill-section presence would do the same for skill-body drift — and (combined with finding 4) would be testable.

**Evidence:** `docs/substrate/matrices/reviewer-output-shape.md` (working precedent); `references/skill-conventions.md:153-160` (deviation list with no matrix backing).

**Recommended fix:** Add `docs/substrate/matrices/skill-section-presence.md` — 7 rows × ~10 columns (canonical sections + accepted-optional sections). Mirrors `reviewer-output-shape.md` exactly.

**Substrate artifact:** Behavior matrix (`docs/substrate/matrices/skill-section-presence.md`).

---

### 8. Discovery-vs-Superpowers seam still violated by router triggers

**Severity:** Medium
**Category:** Cross-plugin contract

**Why it matters:** `discovery-vs-superpowers.md:38,52` says Cohesive's discovery-shaped descriptions should not claim general discovery; triggers should be substrate-specific. `discover-substrate`'s frontmatter is correctly narrow. But `cohesively/SKILL.md` frontmatter triggers include "review the architecture" and "review the codebase" alongside "audit substrate" — directly overlapping Superpowers' code-reviewer / research / exploration skill triggers. The gotcha contract is one-sided: the named-failure-mode skill complies; the router that's supposed to be Cohesive's canonical entry point still claims generic discovery surface.

**Evidence:** `skills/cohesively/SKILL.md` frontmatter description vs `docs/substrate/gotchas/discovery-vs-superpowers.md:38,52`.

**Recommended fix:** Audit each Cohesive skill's `description:` triggers against Superpowers' published descriptions; tighten Cohesive's wording to "substrate-first," "cohesion," "preserve invariants" verbs and away from generic "review." Promote the description-string review from "planned" to a `validate_plugin.sh` grep that fails on overly broad triggers.

**Substrate artifact:** Cross-plugin contract (`discovery-vs-superpowers.md` upgrade) + semantic linter (validate_plugin.sh trigger-string check).

---

### 9. Demoted-invariant lineage is invisible

**Severity:** Low–Medium
**Category:** Substrate

**Why it matters:** The 2026-05-04 substrate collapse demoted four (or five) invariants — `FRESH_EYES_DISPATCH`, `ROUTER_ANNOUNCES_BEFORE_DISPATCH`, `ONE_PRECISE_QUESTION`, plus at least one more — to conventions. `AGENTS.md:26` mentions the demotion in passing without naming the demoted rules. There is one delta ledger (`docs/history/delta-ledgers/2026-05-04-substrate-collapse.md`) and the corresponding repair (`2026-05-04-substrate-collapse-repair.md`), but `AGENTS.md` doesn't link to them. A future contributor can't tell which conventions were once invariants, what triggered the demotion, or what would justify re-promotion.

**Evidence:** `AGENTS.md:26` (no link); `docs/history/delta-ledgers/2026-05-04-substrate-collapse.md` (exists but unlinked from contributor guide).

**Recommended fix:** Add a one-line link from `AGENTS.md` §"The one named invariant" to the substrate-collapse delta ledger, listing the demoted invariant names explicitly. Re-promotion criteria can wait until the conventions are tested (finding 4).

**Substrate artifact:** Edit `AGENTS.md`; verify ledger contents.

---

### 10. Smaller items (rolled up; each ≤ Low severity)

| # | Finding | Severity | Substrate artifact |
|---|---|---|---|
| 10a | `validate_plugin.sh` uses ❌/⚠️/✅ emoji while skill-conventions forbids emoji in skill bodies — convention drift, not strictly a violation | Low | One-line script fix or one-line conventions exemption |
| 10b | `plugin.json` lacks the `$schema` field that `marketplace.json` declares — manifest-hygiene asymmetry | Low | Add schema reference (if Anthropic publishes one) |
| 10c | Skill-conventions §Frontmatter framing reads as platform requirement; it's Cohesive's narrowing of a free-text field | Low | One-line clarification |
| 10d | `substrate-audit` opens output with `## Headline` instead of `## TL;DR`; either rename or document exemption | Low | Edit skill body or add exemption to skill-conventions |
| 10e | `references/skill-conventions.md` step 5 ("validator must pass") overstates coverage; an agent will believe the green check validates more than it does — composes with finding 1 | Low | Rephrase step 5 once finding 1 lands |
| 10f | Two reviewer agents (`agent-readiness`, `substrate-alignment`) have overlapping "candidate invariant" surface; not a problem at 5 agents but worth watching | Low | Defer; revisit at 6th agent |

---

## Substrate improvements (consolidated)

By artifact type:

- **Semantic linter (`scripts/validate_plugin.sh`):** add five grep checks for (a) `PLUGIN_ROOT_PATHS` violations [finding 1], (b) prereq-question presence in three subskills [finding 4], (c) fresh-eyes preamble verbatim across five agents [finding 4], (d) `Recommended next` footer in every persisting skill [finding 4], (e) overly broad description triggers on Cohesive skills [finding 8]. Each is one line.
- **Behavior matrices (new):** `skill-section-presence.md` [finding 7], `artifact-placement.md` [finding 3]. Both mirror the working `reviewer-output-shape.md` precedent.
- **Skill body (`cohesively/SKILL.md`):** add a "Dispatch prompt contract" section per route [finding 2]; revise frontmatter triggers [finding 8].
- **Skill body (4 persisting skills):** add "Step 0: Resolve artifact directory" citing `references/substrate-layout.md` [finding 3].
- **Skill split:** extract `cohesive-diff-review` from `cohesive-review` per the `substrate-audit` precedent [finding 5]; OR document the deviation in `skill-conventions.md`.
- **Reference move:** hoist the "Pressure test summary" output format from `brainstorm-design/SKILL.md` into `references/design-pressure-testing.md` [finding 6].
- **Reference (`substrate-layout.md`):** add the external-repo detection rules [finding 3].
- **Reference (`skill-conventions.md`):** rephrase step-5 validator-coverage claim once the validator catches up [finding 10e]; one-line clarifications for findings 10a, 10c.
- **Doc edit (`AGENTS.md`):** link the substrate-collapse delta ledger [finding 9].
- **Cross-doc cleanup:** align `ARCHITECTURE.md`, `README.md`, `AGENTS.md`, `skill-conventions.md` to whatever `validate_plugin.sh` actually does after finding 1 lands [finding 1 follow-up].

---

## Phased roadmap

The order matters: substrate first, structure second, enforcement third. Inverting it produces churn.

### Phase 1: Repair substrate (close named contracts before V1)

1. Implement the `PLUGIN_ROOT_PATHS` grep in `validate_plugin.sh` (finding 1). 5 lines of bash.
2. Add the "Dispatch prompt contract" section to `cohesively/SKILL.md` (finding 2). One section, ≤ 30 lines.
3. Add "Step 0: Resolve artifact directory" to four persisting skills + the detection rules to `substrate-layout.md` (finding 3). One paragraph each, one shared reference.
4. Sweep `ARCHITECTURE.md` / `README.md` / `AGENTS.md` to match the now-correct enforcement story (finding 1 follow-up).
5. Link the substrate-collapse delta ledger from `AGENTS.md` (finding 9).

After Phase 1, the verdict moves from *Cohesive but under-enforced* to *Mostly healthy*.

### Phase 2: Simplify structure (skill quality / composability)

6. Extract `cohesive-diff-review` per the substrate-audit precedent, OR document the scope-modal deviation explicitly (finding 5).
7. Hoist the "Pressure test summary" output format into `references/design-pressure-testing.md` (finding 6); close the acknowledged inverted-citation debt.
8. Tighten Cohesive's description triggers vs Superpowers (finding 8).

### Phase 3: Strengthen enforcement (turn convention into automation)

9. Land the four other grep checks in `validate_plugin.sh` (finding 4): canonical prereq question, fresh-eyes preamble, recommended-next footer, broad-trigger detection.
10. Add the two new behavior matrices: `skill-section-presence.md`, `artifact-placement.md` (finding 7 + finding 3 follow-up).
11. Address the small items (10a–10e) in a single sweep.

### What V1 still owes

- Dedicated artifact skills (`invariant`, `matrix`) per the artifact route deferral.
- Re-promotion criteria for demoted invariants (only meaningful once Phase 3 enforcement lands).
- Real external-repo dogfood transcripts under `docs/history/transcripts/` (the existing reviews are all in-repo).

---

## Self-referential caveat

This is a self-review: Cohesive reviewed itself, with reviewer agents loaded by Cohesive's own dispatch protocol, judged against rubrics Cohesive itself wrote. The fresh-eyes structural fence (Task-subprocess isolation) holds — the four reviewers ran in parallel with no cross-talk and no inherited context — but the rubrics are the methodology's own. Two effects to watch in future external-repo dogfood:

1. **Confirmation alignment.** The rubrics privilege Cohesive's substrate vocabulary (named invariants, behavior matrices, semantic linters). A codebase using a *different* taxonomy with the same effect would underscore on these axes. None of the v0.1 findings depend on this; future dogfood should.
2. **No "dogfood-convergence" gotcha.** This caveat itself should be promoted to a substrate gotcha (`docs/substrate/gotchas/dogfood-convergence.md`) before the next self-review pass — naming the failure mode where a methodology validating itself silently selects findings consistent with its own framing. A two-paragraph doc would close it.

(This caveat does not raise the findings count; it suggests one substrate addition for the next pass.)

---

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — the highest-leverage repairs are substrate-side (validator script, router section, placement matrix, conventions cleanup). Land them in a worktree and re-run `cohesive-review --scope diff` before merging.

After Phase 1 is done, an end-to-end external-repo dogfood (run `cohesive:cohesively review the architecture` against a real non-Cohesive repo) is the next acid test — the v0.1 self-review can't simulate it.
