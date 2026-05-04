# Cohesive Architecture Review — Post Phase-1 Substrate Pass

**Date:** 2026-05-04
**Scope:** `/home/toda/dev/cohesive` (whole repo)
**Reviewers dispatched:** substrate-alignment, structure, library-native, agent-readiness
**Substrate discovery:** complete; report inline below
**Prior review:** [`2026-05-04-self-review.md`](2026-05-04-self-review.md)

---

## Verdict

**Cohesive but under-enforced — and now mis-asserting enforcement.**

The Phase 1 substrate work the prior self-review prescribed has landed cleanly. AGENTS.md exists. ARCHITECTURE.md is the binding map. The five rules are now named invariants in `docs/substrate/invariants/`. Two gotchas exist. The router has a behavior matrix. Three cross-cutting design docs codify the three-tier separation, the dispatch protocol, and the Superpowers seam.

But Phase 3 enforcement did not land, and in the meantime the substrate has accumulated drift. Every named-invariant doc now *asserts* that `scripts/validate_plugin.sh` enforces it — none of those checks exist. And the corpus the invariants are supposed to protect has drifted away from the canonical texts the invariants and conventions reference: 4 of 5 reviewer agents have non-canonical fresh-eyes preambles (1 is missing the bullet entirely); 5 of 6 skills use non-canonical "Recommended next Cohesive skill" headings; the README points reviews to a directory the rest of the system rejects; transcripts (DoD release gate) are still empty.

This is structurally worse than the prior self-review's state. Before, the rules were folklore *and known to be folklore*. Today they are folklore *that the substrate falsely claims is enforced*. A future agent will read an invariant doc, run the green validator, and ship a non-compliant change with confidence.

## Executive thesis

Phase 1 closed the documentation gap; Phase 3 is the load-bearing pass that has not landed. The fix list is small (~40 lines of bash for the five validator greps; mechanical sweeps across 5 agents + 5 skills + 1 README; ~2 transcripts; ~5 lines of CI YAML), but until it lands, Cohesive cannot pass its own `cohesive-review --scope codebase` — the methodology pack ships with a substrate that lies about its own enforcement, which is the precise failure mode the substrate-model thesis exists to prevent.

## Spec-prior gate

**Result:** Pass with one annotation. No blocking spec-level issues.

The source-of-truth hierarchy is well-defined (`ARCHITECTURE.md` binding → README/AGENTS derived → on-disk implementation). Five invariants are mutually consistent. The router matrix matches `cohesively/SKILL.md`. Design docs cohere. Two non-blocking inconsistencies were noted and surfaced as Phase-3 findings:

- `README.md:63` says reviews go to `docs/cohesive/reviews/`; ARCHITECTURE/AGENTS/SKILL all say `docs/history/reviews/`.
- `AGENTS.md:18,58` says delta ledgers live at `docs/history/design-changes/` (matches on-disk); every skill body and `references/substrate-layout.md` say `docs/history/delta-ledgers/`.

Neither is a blocker; both are spec drift findings (Findings #2 and #5).

## Cohesion scorecard

| Axis | Rating | Summary |
|---|---|---|
| 1. Spec coherence | Mostly healthy | Source-of-truth hierarchy works; two doc-vs-doc path inconsistencies identified above. |
| 2. Code/spec alignment | **At risk** | 4/5 agents and 5/6 skills do not match the canonical text the invariants and conventions reference. |
| 3. Domain model clarity | Drifting | `cohesive-review --scope substrate` is still a category error; `docs/substrate/designs/` tier is unnamed in the canonical layout doc. |
| 4. Invariant enforcement | **At risk** | All five invariants assert validator enforcement that does not exist. False structural claim. |
| 5. Test guarantees | **At risk** | Zero tests, zero CI, zero transcripts despite AGENTS.md DoD gate. |
| 6. Locality and seams | Mostly healthy | Three-tier separation holds; preamble-drift weakens the locality argument from prior review. |
| 7. Library-native alignment | Mostly healthy | Polish list (emoji output, missing `$schema`, scan_substrate precedence). |
| 8. Agent-readiness | **At risk** | Predictable failures across all three V1 onboarding scenarios; validator is a false floor. |
| 9. Future extensibility | Drifting | Two templates remain consumer-less; CI not yet landed. |

## Highest-leverage findings

Ranked by leverage × severity. Convergent across reviewers cited inline.

### 1. Every named invariant asserts enforcement that does not exist in `validate_plugin.sh`

**Severity:** Blocker
**Category:** Invariant enforcement / Spec drift
**Why it matters:** Each of the five invariant docs concludes its "Enforcement" section with a specific `validate_plugin.sh` grep, e.g., `PLUGIN_ROOT_PATHS.md:45` ("grep over `skills/`, `agents/`, `references/` for `/home/`, `/Users/`, `/usr/`, `~/` outside fenced 'anti-pattern' blocks"), `FRESH_EYES_DISPATCH.md:61` ("greps each `agents/*.md` for the canonical bullet"), `SUBSKILL_RECOMMENDS_NEXT.md:51` ("greps each SKILL.md for the canonical header"). The actual validator (`scripts/validate_plugin.sh:1-127`) contains no such greps. It checks frontmatter shape, JSON validity, file existence — nothing else. Worse, line 99-108 still rewards bare `references/...` paths the way the prior self-review at finding #1 already flagged. The substrate now teaches rules with one hand while lying about their enforcement floor with the other. This is the central, load-bearing failure of the v0.1 acid test.

**Evidence:** `scripts/validate_plugin.sh:1-127`; `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md:45`; `docs/substrate/invariants/FRESH_EYES_DISPATCH.md:61`; `docs/substrate/invariants/ROUTER_ANNOUNCES_BEFORE_DISPATCH.md:46`; `docs/substrate/invariants/ONE_PRECISE_QUESTION.md:45`; `docs/substrate/invariants/SUBSKILL_RECOMMENDS_NEXT.md:51`.

**Recommended fix:** Implement the five greps each invariant already specifies. Mechanical work; ~40 lines of bash total. Each failure message must reference the invariant by name (per `AGENTS.md:49`). Order matters: do the corpus sweeps (Findings #3 and #4) before turning the greps on, or CI lands red.

**Substrate artifact to add or update:** `scripts/validate_plugin.sh` extension. Order of operations: corpus sweeps → validator greps → CI workflow.

---

### 2. `SUBSKILL_RECOMMENDS_NEXT` is violated by 5 of 6 skills

**Severity:** Blocker
**Category:** Invariant / Code-spec drift
**Why it matters:** The invariant mandates the exact heading `### Recommended next Cohesive skill`. Of six skills, only `discover-substrate/SKILL.md:140` matches. `brainstorm-design/SKILL.md:147` uses `## Next Cohesive skill`; `rewrite-specs/SKILL.md:138` uses `### Next Cohesive skill`; `review-spec-cohesion/SKILL.md:116` uses `## Next Cohesive skill`; `cohesive-review/SKILL.md` is missing the heading from all three of its mode-specific output schemas. The invariant exists *because* the prior self-review observed this drift; the substrate fix promoted the rule to a named invariant, but did not bring the violating skills into compliance. An agent writing the V1 `invariant` skill will copy whichever sibling they read first and silently ship a non-compliant skill.

**Evidence:** `skills/discover-substrate/SKILL.md:140` (canonical); `skills/brainstorm-design/SKILL.md:147`; `skills/rewrite-specs/SKILL.md:138`; `skills/review-spec-cohesion/SKILL.md:116`; `skills/cohesive-review/SKILL.md:56-66, 127-155, 168-196` (heading absent in all three modes). Convergent finding across substrate-alignment, structure, and agent-readiness reviewers.

**Recommended fix:** Sweep five SKILL.md files to use the exact heading. For multi-verdict skills (`cohesive-review`, `review-spec-cohesion`), name one recommended-next per verdict-branch per `SUBSKILL_RECOMMENDS_NEXT.md:13-19`. Then add the validator grep.

**Substrate artifact to add or update:** Five skill body edits + the validator grep + `cohesive-review` per-verdict footers (this is also a structural fix because the multi-mode skill currently has zero of three modes producing the canonical footer).

---

### 3. `FRESH_EYES_DISPATCH` canonical preamble has three variants across 5 agents; one agent is missing it entirely

**Severity:** Blocker
**Category:** Invariant / Locality (weakens the locality argument)
**Why it matters:** The canonical bullet at `references/reviewer-agent-template.md:71-73` reads: "Inherit conversation context from the calling skill. Treat your input prompt as the entire context." Of five agents:
- `agents/substrate-alignment-reviewer.md:133` matches verbatim.
- `agents/structure-reviewer.md:151`, `library-native-reviewer.md:155`, `agent-readiness-reviewer.md:181` use the shortened "Inherit conversation context. Treat your input prompt as the entire context." (drops "from the calling skill").
- `agents/spec-cohesion-reviewer.md` does not contain the canonical bullet under "What you must not do" at all; only a near-companion line at :91 ("Read prior conversation context. You won't have it; don't pretend.").

The prior self-review's locality verdict — "the preamble duplication is correctly local because each agent must be standalone-readable" — depends on every copy being faithful. The codebase is not in that state. Worse, `docs/substrate/designs/agent-dispatch-protocol.md:124` explicitly claims: "The self-review on 2026-05-04 confirmed the agent-side preamble is present in all five agent files." That claim is false.

**Evidence:** `references/reviewer-agent-template.md:71-73`; the five agent files cited above. Convergent finding across substrate-alignment, structure, and agent-readiness reviewers.

**Recommended fix:** Sweep all five agent files to the canonical bullet verbatim. Correct the false claim in `agent-dispatch-protocol.md:124`. Then add the validator grep that `FRESH_EYES_DISPATCH.md:61` already promised.

**Substrate artifact to add or update:** Five agent edits + correction to design doc + validator grep.

---

### 4. No transcripts in `docs/history/transcripts/` (DoD release gate violated)

**Severity:** Blocker (DoD)
**Category:** Test guarantee / Substrate
**Why it matters:** `AGENTS.md:48` is explicit: "v0.1 release is gated on having two such transcripts." The directory exists and is empty. Three named invariants (`ROUTER_ANNOUNCES_BEFORE_DISPATCH`, `ONE_PRECISE_QUESTION`, `FRESH_EYES_DISPATCH`) name "transcript-shape check" as their V1 enforcement; without transcripts those checks have nothing to validate. An agent extending Cohesive has no integration-test exemplar of an end-to-end workflow. This is the same gap the prior self-review flagged as Blocker (Finding #2); it has not moved.

**Evidence:** `ls /home/toda/dev/cohesive/docs/history/transcripts/` returns empty; `AGENTS.md:48`. Convergent finding across substrate-alignment, structure, and agent-readiness reviewers.

**Recommended fix:** Land at least two transcripts. This very review is one candidate; pair it with a design-rewrite transcript. Or, if release timing forces it, edit `AGENTS.md:48` to defer the transcript gate to V1 with explicit acknowledgment — but do *not* silently ship under a violated DoD.

**Substrate artifact to add or update:** Two transcripts under `docs/history/transcripts/` (with a `README.md` index) — OR an explicit AGENTS.md DoD edit.

---

### 5. README contradicts binding doc on review output path

**Severity:** High
**Category:** Spec drift
**Why it matters:** `README.md:63` says `cohesive-review --scope codebase` writes to `docs/cohesive/reviews/`. ARCHITECTURE.md:59, AGENTS.md:57, and `cohesive-review/SKILL.md` (six occurrences) all say `docs/history/reviews/`. Per ARCHITECTURE.md:47, README is *derived from* the binding doc. README has drifted. A user following README:63 will create a parallel directory or lose trust.

**Evidence:** `README.md:63`; `ARCHITECTURE.md:59`; `AGENTS.md:57`; `skills/cohesive-review/SKILL.md:12,14,103,105,198,225`.

**Recommended fix:** One-line edit. Replace `docs/cohesive/reviews/` with `docs/history/reviews/` in README:63.

**Substrate artifact to add or update:** One README edit.

---

### 6. Delta-ledger directory schism (`design-changes/` vs `delta-ledgers/`)

**Severity:** High
**Category:** Seam / Concept
**Why it matters:** AGENTS.md:18 and :58 say delta ledgers live at `docs/history/design-changes/`; on disk, `docs/history/design-changes/` exists and contains two ledgers. Every other normative doc — `skills/rewrite-specs/SKILL.md:11,84,93,99,133`, `skills/review-spec-cohesion/SKILL.md:26`, `references/substrate-layout.md:18,39` — calls the directory `docs/history/delta-ledgers/`. A future `rewrite-specs` run will write to `delta-ledgers/`; a contributor reading AGENTS.md will look in `design-changes/`. This is exactly the failure mode `substrate-layout.md` was created to prevent.

**Evidence:** `AGENTS.md:18,58`; `references/substrate-layout.md:18,39`; `skills/rewrite-specs/SKILL.md:11`; `docs/history/design-changes/2026-05-04-layout-migration.md` (file in `design-changes/` but content header reads "Design Delta Ledger").

**Recommended fix:** Pick one. Cheaper option: `git mv docs/history/design-changes docs/history/delta-ledgers`, patch `AGENTS.md:18,58` to match.

**Substrate artifact to add or update:** Directory rename + AGENTS.md edits + a one-line check in `validate_plugin.sh` that the canonical directory exists.

---

### 7. `docs/substrate/designs/` is a load-bearing tier missing from the canonical layout doc

**Severity:** High
**Category:** Concept / Substrate gap
**Why it matters:** `references/substrate-layout.md` is the canonical "where do artifacts live" reference. Its table at lines 7-19 enumerates `invariants/`, `matrices/`, `gotchas/` under `docs/substrate/` — but not `designs/`. ARCHITECTURE.md:38, AGENTS.md:9,47,56, and the layout-migration ledger all treat `docs/substrate/designs/` as a first-class tier with three load-bearing docs (three-layer-architecture, agent-dispatch-protocol, composition-with-superpowers). A contributor reading the layout doc to learn where things go will conclude designs don't exist as a category. The concept is asserted in three places but unowned by the layout reference.

**Evidence:** `references/substrate-layout.md:7-19,30-40`; `ARCHITECTURE.md:38`; `AGENTS.md:47,56`; `docs/substrate/designs/` (3 files).

**Recommended fix:** Add a `designs/` row to the layout table with a one-sentence criterion ("cross-cutting design decisions spanning multiple components; promoted from history when stable"). Add a row to the naming table at :30-40. Update the §"Growth pattern" block.

**Substrate artifact to add or update:** `references/substrate-layout.md` extension.

---

### 8. `cohesive-review --scope substrate` remains a category error inside one skill

**Severity:** High (carry-over from prior review Finding #5)
**Category:** Concept / Seam
**Why it matters:** The merged skill bundles three modes; codebase + diff legitimately share Phase 1 + reviewer-dispatch machinery, but substrate mode runs zero agents (`cohesive-review/SKILL.md:164` "**No subagent dispatch.**"), no spec-prior gate, no Phase 1 normative read. Roughly 17% of the skill is mode-conditional branching. The router (`cohesively/SKILL.md:52-58`) already treats "substrate audit" as a separate route — the change is just realigning skill boundaries with the route boundaries the router already encodes. Prior review scheduled this for Phase 2; not done.

**Evidence:** `skills/cohesive-review/SKILL.md:37-105` (codebase, 4-phase), :107-157 (diff, 2 agents), :159-198 (substrate, 0 agents); `skills/cohesively/SKILL.md:52-58`.

**Recommended fix:** Carve `skills/substrate-audit/SKILL.md` out. `cohesive-review` keeps codebase + diff. Update README §"What's in the box," ARCHITECTURE.md skill count, and `references/architecture-review-rubric.md` title scope.

**Substrate artifact to add or update:** New skill + trim of existing skill + README/ARCHITECTURE updates.

---

### 9. Soft-prereqs gotcha's canonical detection rule has not propagated into subskill bodies

**Severity:** High
**Category:** Hidden rule / Gotcha enforcement
**Why it matters:** `docs/substrate/gotchas/soft-prereqs.md:34-42` defines the canonical detection rule: ask the user a forced-choice question at turn open. The fix outline at :43-48 names three subskills to update. None of those have been updated. `skills/brainstorm-design/SKILL.md:30` still says "If `discover-substrate` hasn't run yet, invoke it first" without spec; `skills/cohesive-review/SKILL.md:30` says "Or re-use its output from earlier in this session" without telling Claude how to detect that. The gotcha doc names the prevention; the subskills still leave detection to the heuristic the gotcha was created to forbid.

**Evidence:** `docs/substrate/gotchas/soft-prereqs.md:35-42`; `skills/brainstorm-design/SKILL.md:30`; `skills/cohesive-review/SKILL.md:30`; `skills/rewrite-specs/SKILL.md`.

**Recommended fix:** Add a "Step 0 / Prereq check" subsection to each of the three subskills with the canonical question text. Add a grep in `validate_plugin.sh` for the canonical question's named substring in any subskill that names `discover-substrate` as a prereq.

**Substrate artifact to add or update:** Three skill body edits + an enforcement grep.

---

### 10. CI workflow asserted by every invariant does not exist

**Severity:** Medium
**Category:** Spec drift / Test guarantee
**Why it matters:** Every invariant doc carries the same conditional sentence: "CI checks: wired through `validate_plugin.sh` once `.github/workflows/validate.yml` lands." The workflow has not landed. Even after Findings #1-4 are fixed, there is no structural fence preventing PR-time regressions. The duplication is also itself a smell — five docs all hedge on the same condition; that hedge belongs in one place.

**Evidence:** `.github/` does not exist; `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md:47` (representative).

**Recommended fix:** Add a five-line `.github/workflows/validate.yml` running `bash scripts/validate_plugin.sh` on push and PR. Drop the conditional language from each invariant once the workflow exists.

**Substrate artifact to add or update:** New CI workflow file + edits to each invariant's "Enforcement" section.

---

### 11. Two templates remain consumer-less abstractions

**Severity:** Medium
**Category:** Complexity / Premature substrate
**Why it matters:** `references/templates/implementation-plan.md` (flagged as Finding #12 in prior self-review) and `references/templates/semantic-linter-spec.md` (similar shape) have no in-codebase consumer. No skill produces them; no agent reads them. Cohesive's own structure-reviewer agent flags exactly this pattern as "abstract base classes 'for future extensibility' with no concrete plan." Phase 1 of prior roadmap explicitly listed step 8: "Decide: delete or commit." Not done.

**Evidence:** `references/templates/implementation-plan.md`; `references/templates/semantic-linter-spec.md`; absence of any consumer (grep confirms).

**Recommended fix:** Delete both. Recreate alongside the consuming skill in the same commit when V1 ships those skills.

**Substrate artifact to add or update:** Delete two template files; trim README §"What's in the box."

---

### 12. Library-native polish (collected; each Medium-or-Low)

Convergent with prior review's Finding #14, partially still applicable:
- **`validate_plugin.sh` emits emoji** (`:14-18,122,125`) while `references/reviewer-agent-template.md` forbids them. Self-inconsistency on first run. Replace with `[OK]` / `[WARN]` / `[FAIL]` markers.
- **`plugin.json` lacks `$schema`** while sibling `marketplace.json:2` has it. One-line addition gets free editor validation.
- **`scan_substrate.py:82` operator-precedence ambiguity** in the dotfile-allowlist filter; benign today, brittle on next edit.
- **Validator's awk frontmatter parsing duplicated** at :64,88; extract a `fm_field` shell function.
- **JSON validation reimplements `python3 -m json.tool`**; switch.
- **Frontmatter schema only checks two fields** (`name`, `description`); `model:`, `color:` typos pass silently.

**Substrate artifact to add or update:** One library-native polish PR. Each item is a 1-3 line change.

---

### 13. Skill-side fresh-eyes prose missing in `cohesive-review` Phase 3

**Severity:** Medium
**Category:** Invariant / Code-spec drift
**Why it matters:** `references/skill-conventions.md:79` mandates: "The dispatching skill body must explicitly state, in prose: 'The reviewer reads only paths passed to it, not the conversation.'" `skills/cohesive-review/SKILL.md:79-85` describes Phase 3 dispatch but does not contain that sentence. `review-spec-cohesion/SKILL.md:16-18` does. The prior self-review observed this drift; the conventions doc landed but the skill body did not catch up.

**Evidence:** `skills/cohesive-review/SKILL.md:79-85`; `references/skill-conventions.md:79`; `docs/substrate/invariants/FRESH_EYES_DISPATCH.md:61-64`.

**Recommended fix:** Add the canonical sentence to `cohesive-review/SKILL.md` Phase 3. Add the matching grep to `validate_plugin.sh`.

**Substrate artifact to add or update:** One skill edit + validator grep.

---

### 14. `cohesively/SKILL.md` and `discover-substrate/SKILL.md` deviate from `skill-conventions.md` required sections

**Severity:** Medium
**Category:** Convention drift
**Why it matters:** `references/skill-conventions.md:24-43` requires `Hard constraints`, `Process`, `Output format`, `Acceptance criteria`, `What this skill is *not*`. The router uses `Required behavior` and `Routes`; `discover-substrate` lacks `Hard constraints`. The conventions doc names a router exemption (Routes-replaces-Process) but not the other deviations. A future router-shaped skill or a future no-dispatch skill will copy whichever sibling they read first.

**Evidence:** `references/skill-conventions.md:23-43,96-99`; `skills/cohesively/SKILL.md`; `skills/discover-substrate/SKILL.md`.

**Recommended fix:** Either rename router headings to match or expand `skill-conventions.md` exemptions list. Prefer the rename.

**Substrate artifact to add or update:** Two skill body edits or one conventions doc edit.

---

### 15. Reference-cites-skill direction at `design-pressure-testing.md:94` not flipped

**Severity:** Low
**Category:** Seam direction
**Why it matters:** Carry-over from prior review. `references/design-pressure-testing.md:94` cites `${CLAUDE_PLUGIN_ROOT}/skills/brainstorm-design/SKILL.md` for the canonical output format. `docs/substrate/designs/three-layer-architecture.md:47` explicitly sanctions this case as "should be flipped in a future cleanup" — but that cleanup has now spanned the entire migration cycle. Exceptions accumulate.

**Evidence:** `references/design-pressure-testing.md:94`; `docs/substrate/designs/three-layer-architecture.md:47`.

**Recommended fix:** Move the canonical output-format spec into the reference; have the skill cite the reference.

**Substrate artifact to add or update:** Two file edits.

---

## Substrate improvements (consolidated)

### Specs to rewrite or annotate
- `README.md:63` — fix review path (Finding #5)
- `AGENTS.md:18,58` — align with directory rename (Finding #6)
- `references/substrate-layout.md` — add `designs/` row (Finding #7)
- `docs/substrate/designs/agent-dispatch-protocol.md:124` — correct false "confirmed" claim (Finding #3)
- Each invariant's "Enforcement" section — match what the validator actually does (Findings #1, #10)

### Behavior matrices
- No new matrices required this pass. The router matrix is in good shape.

### Named invariants
- No new invariants required. The five existing are sufficient for v0.1; the work is implementing their claimed enforcement.

### Semantic linters to add (`validate_plugin.sh` extensions)
1. `${CLAUDE_PLUGIN_ROOT}` discipline check (PLUGIN_ROOT_PATHS)
2. Canonical fresh-eyes preamble grep over `agents/*.md` (FRESH_EYES_DISPATCH)
3. Canonical router announcement template grep in `cohesively/SKILL.md` (ROUTER_ANNOUNCES_BEFORE_DISPATCH)
4. Forbidden-phrase grep in skill bodies (ONE_PRECISE_QUESTION)
5. Canonical "Recommended next Cohesive skill" header grep per skill (SUBSKILL_RECOMMENDS_NEXT)
6. Skill-side fresh-eyes prose grep at Task-dispatch sites (Finding #13)
7. Soft-prereqs canonical question grep in subskills with `discover-substrate` as prereq (Finding #9)
8. Delta-ledger directory existence check (Finding #6)

### Gotchas
- Existing two gotchas are correct; the soft-prereqs gotcha needs propagation into subskill bodies (Finding #9).

### Templates
- DELETE `references/templates/implementation-plan.md` and `references/templates/semantic-linter-spec.md` (Finding #11).

### CI / tests
- Add `.github/workflows/validate.yml` running `bash scripts/validate_plugin.sh` on push and PR (Finding #10).
- Two transcripts under `docs/history/transcripts/` (Finding #4).

### Skill / agent corpus sweeps (must precede validator greps)
- Five agent files: align fresh-eyes preamble verbatim (Finding #3).
- Five skill files: align "Recommended next" heading verbatim, including per-verdict for multi-verdict skills (Finding #2).
- Three subskill files: add canonical soft-prereq question (Finding #9).
- One skill file (`cohesive-review`): add canonical skill-side fresh-eyes prose (Finding #13).
- Two skill files: align with conventions or expand exemption (Finding #14).

### Architecture simplification
- Split `cohesive-review --scope substrate` into a separate `substrate-audit` skill (Finding #8).
- Rename `docs/history/design-changes/` → `docs/history/delta-ledgers/` (Finding #6).
- Flip `references/design-pressure-testing.md:94` reference direction (Finding #15).

### Library-native polish (one PR)
- Strip emoji from `validate_plugin.sh`.
- Add `$schema` to `plugin.json`.
- Fix `scan_substrate.py:82` precedence.
- Extract `fm_field` shell function.
- Switch JSON validation to `python3 -m json.tool`.

## Phased roadmap

### Phase 1: Repair the corpus (blocking v0.1 release)
The substrate documents the corpus must conform to; fix the corpus first, so the validator greps land green.
1. Sweep five agent files to canonical fresh-eyes preamble verbatim (Finding #3).
2. Correct `agent-dispatch-protocol.md:124` false claim (Finding #3).
3. Sweep five skill files to canonical "Recommended next" heading, with per-verdict footers for multi-verdict skills (Finding #2).
4. Add canonical soft-prereqs question to three subskills (Finding #9).
5. Add canonical skill-side fresh-eyes prose to `cohesive-review` Phase 3 (Finding #13).
6. Fix `README.md:63` (Finding #5).
7. Rename `docs/history/design-changes/` → `delta-ledgers/`; patch `AGENTS.md` (Finding #6).
8. Add `designs/` row to `references/substrate-layout.md` (Finding #7).
9. Delete two consumer-less templates (Finding #11).
10. Land two transcripts (Finding #4) — this review counts as one.

### Phase 2: Land enforcement
Now that the corpus matches the canonical text, the greps can fail-on-violation rather than fail-on-fixture.
1. Extend `scripts/validate_plugin.sh` with the eight greps in the substrate-improvements list above (Findings #1, #6, #9, #13).
2. Add `.github/workflows/validate.yml` (Finding #10).
3. Drop the "when CI lands" hedge from each invariant doc (Finding #10).

### Phase 3: Architecture simplification
Done after substrate is enforced, so simplification doesn't drift the corpus again.
1. Split `cohesive-review --scope substrate` into `substrate-audit` (Finding #8).
2. Reconcile `cohesively`/`discover-substrate` with `skill-conventions.md` (Finding #14).
3. Flip `design-pressure-testing.md:94` reference direction (Finding #15).
4. Library-native polish (Finding #12).

This sequencing matters: corpus before greps (so greps don't land red), greps before CI (so CI has something to run), simplification last (so the substrate is stable when the structural change happens). Inverting it produces churn.

## Self-consistency check

The acid test: after Phase 1+2 land, re-running `cohesive-review --scope codebase` on this repo should not surface Findings #1, #2, #3, #4, #5, #6, #7, #9, #10, #13. Findings #8, #11, #14, #15, #12 are Phase 3 / polish.

Currently Cohesive does not pass its own review. The structural seams and locality decisions remain sound (as both this review and the prior one found). The thesis-test for v0.1 release: when this validator's exit code matches its docs' enforcement claims, Cohesive has earned the right to recommend itself to other codebases. Until then, the methodology is shipping with substrate that lies about its own enforcement — which is the precise failure mode the substrate-model thesis exists to prevent.

## Recommended next Cohesive skill

`cohesive:rewrite-specs` — Phase 1 of the roadmap above is corpus-and-substrate edits across ~15 files. A spec-rewrite pass is the right vehicle: produce a single design delta ledger documenting the corpus sweeps and substrate-layout extension, then run `cohesive:review-spec-cohesion` for fresh-eyes review before the implementation pass that adds the validator greps and CI.
