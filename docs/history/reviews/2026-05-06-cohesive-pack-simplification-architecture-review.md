# Architecture Review — Cohesive plugin v0.1 (simplification focus)

**Date:** 2026-05-06
**Scope:** Whole-architecture review of `/home/toda/dev/cohesive`
**User-named focus:** simplifications, old things to delete, things to be made more concise or clear
**Reviewers dispatched (parallel):** substrate-alignment-reviewer, structure-reviewer, library-native-reviewer, agent-readiness-reviewer

**Verdict (internal):** Mostly healthy
**Verdict (user-facing):** Mostly healthy — minor gaps; proceed with notes

## Thesis

Three rewrites in two days (decide-lock-build framing → post-lock-escape and post-impl-review pattern → tightenings closing self-review gaps) produced a load-bearing user-facing model (Decide → Lock → Build), successfully closed one round of self-review gaps, and dogfooded Cohesive on itself end-to-end. The methodology held under self-application. What's left is **cruft compaction**: a 610-line bash validator with six hand-maintained skill arrays that drift in lockstep, ~80 lines of duplicated prose across 10 SKILL.md files, and three normative docs that lead with dated rewrite history before substantive content. None of this threatens the architecture; all of it would materially shrink a future contributor's reading job.

## Cohesion scorecard (9-axis)

| Axis | Rating | Notes |
|---|---|---|
| Spec coherence | Healthy | Three rewrites converged; spec-cohesion-reviewer Approved on all final passes |
| Code/spec alignment | Healthy | Validator passes 0 warnings; recent self-review identified drift, follow-up closed it |
| Domain model clarity | Mostly healthy | Gates-as-nodes vs reversals-as-edges now pinned; ARCHITECTURE.md still carries stale dated history |
| Invariant enforcement | Cohesive but under-enforced | IMPLEMENTATION_PLAN_COVERS_DELTA named alongside structurally-enforced peers but is reviewer-judgment only; deferred grep stale since 2026-05-04 |
| Test guarantees | Mostly healthy | Validator-as-tests; checks generally well-placed; Check 13l one-rewrite scar |
| Locality and seams | Mostly healthy | Audience seam holds; cohesively/SKILL.md triple-encodes route table; validate-rewrite/SKILL.md is 280 lines (~2× peers) |
| Library-native alignment | Healthy | Plugin manifest, frontmatter, ${CLAUDE_PLUGIN_ROOT}, dir layout all idiomatic; validator script is the only library-native concern |
| Agent-readiness | Mostly healthy | A future agent landing on AGENTS.md reads 35 lines of meta-framing before the actionable section; SKILL.md bodies stack design + implementation + render-discipline layers |
| Future extensibility | Healthy | Re-decide reversal added cleanly; gate framing extends without router rename; convention-with-grep promotion criteria are documented |

## Highest-leverage findings (ranked by leverage × severity)

### F1. Validator-script complexity (6 lockstep skill arrays + 610 lines bash)

- **Severity:** High
- **Category:** Build-tooling / Implicit invariant
- **Why it matters:** `scripts/validate_plugin.sh:132-355` carries six hand-maintained skill arrays; every skill addition requires touching up to 6 arrays. A skill added to `expected_skills` but missed in `voice_imperative_skills` produces a clean validator run that doesn't actually pin the voice imperative for that skill. The script also bundles generic plugin-shape checks (1-7, ecosystem-portable) with Cohesive-specific named-invariant enforcement (8-15) under one entrypoint. Bash awk state-machines do work Python expresses in 5 lines.
- **Evidence:** `scripts/validate_plugin.sh:132-355` (six skill arrays); `:519-546` (extract_routes_from_section awk function); `:39-126` vs `:303-601` (generic vs Cohesive-specific bundling).
- **Recommended fix:** Port to `scripts/validate_plugin.py` with one check per function and a `--check <name>` filter. Derive the five subset skill-arrays from per-skill frontmatter or a single declarative table at `docs/substrate/matrices/skill-prereqs.md`. Split into `check_plugin_shape.py` (generic, ecosystem-portable) + `check_invariants.py` (Cohesive-specific). Compose in a thin top-level driver. Keep `validate_plugin.sh` as a one-line shim.
- **Substrate artifact to add or update:** Validator script (refactor); new matrix `docs/substrate/matrices/skill-prereqs.md`; new convention `docs/substrate/conventions/validator-shape.md`.

### F2. Voice imperative + "What this skill is *not*" + canonical-prereq-question duplication across 10 SKILL.md files

- **Severity:** High
- **Category:** Centralization
- **Why it matters:** The 4-line `## Voice` block is byte-identical across 8 SKILL.md files (N=8 with stable shared-contract reason — textbook centralization win). All 10 SKILL.md files end with a `## What this skill is *not*` block that restates composition + frontmatter + adjacent-skill claims already in `architecture/skills.md`. The canonical prereq-detection question prose is duplicated across 5 subskills with subtle per-skill drift, and a future contributor authoring a new subskill must read `skill-shape.md` + `cohesively/SKILL.md` §"Dispatch prompt contract" + `validate_plugin.sh` Checks 10 + 10b — three surfaces enumerating the same fact (which skills carry which prereq shape).
- **Evidence:** `validate-rewrite/SKILL.md:14-16` matches `review-codebase/SKILL.md:14-16` matches `audit-substrate/SKILL.md:14-16` etc. (the Voice block); `cohesively/SKILL.md:193-197` and 9 sibling files (the "What this skill is *not*" block); `validate_plugin.sh:209-261` + `cohesively/SKILL.md:95-108` + `skill-shape.md:175-198` (three prereq-classification enumerations).
- **Recommended fix:** Replace the 4-line `## Voice` block with one-line citation across the 8 skills; update the voice-imperative validator pin to grep the one-line form. Delete `## What this skill is *not*` from all 10 skills; promote any load-bearing line into `## What this skill does`. Consolidate per-skill prereq classification into one matrix at `docs/substrate/matrices/skill-prereqs.md`; have all three surfaces cite the matrix.
- **Substrate artifact to add or update:** `docs/substrate/conventions/skill-shape.md` (define one-line Voice form; remove "What this skill is not" from required sections); validator script (update voice-imperative pin); new matrix.

### F3. ARCHITECTURE.md / AGENTS.md / audience-separation / skills.md lead with dated rewrite history before substantive content

- **Severity:** Medium
- **Category:** Stale concept / Bounded-context
- **Why it matters:** `ARCHITECTURE.md:86` is a single 30-line paragraph that recapitulates three dated rewrites and counts artifacts that drift the moment anyone adds a skill. `AGENTS.md:5-39` is 35 lines of source-of-truth hierarchy + substrate-vs-implementation taxonomy + dated rewrite history before the actionable "When you are about to…" section at line 61 — taxonomy and rewrite-history teach contributor *reasoning*, not contributor *task*. `docs/substrate/conventions/audience-separation.md:92-100` §"Why no rule 6" is design-rationale-against-alternative stranded inline in a normative convention doc. `docs/substrate/architecture/skills.md:54-75` §"Bootstrap status" table tracks a one-time 2026-05-05 migration; six months from now "inherited" will be near-meaningless.
- **Evidence:** `ARCHITECTURE.md:86`; `AGENTS.md:5-39`; `audience-separation.md:92-100`; `architecture/skills.md:54-75`.
- **Recommended fix:** Compress `ARCHITECTURE.md §"v0.1 scope"` to inventory-only (one sentence). Trim `AGENTS.md` to ≤40 lines; move taxonomy and rewrite-history to `ARCHITECTURE.md` or `docs/history/notes/`. Move `audience-separation.md §"Why no rule 6"` into `docs/substrate/gotchas/style-guide-rot.md`. Sunset `architecture/skills.md §"Bootstrap status"` — either set an explicit sunset trigger (when all rows reach `validated`) or move now into the existing matrix at `docs/substrate/matrices/skill-section-presence.md`.
- **Substrate artifact to add or update:** ARCHITECTURE.md, AGENTS.md, audience-separation.md, architecture/skills.md.

### F4. cohesively/SKILL.md triple-encodes its route table

- **Severity:** Medium
- **Category:** Centralization (real, mis-localized)
- **Why it matters:** The router encodes its 7 routes three times in one file: §"Routes" (lines 33-89, prose per route), §"Required behavior #1" (lines 120-128, route→announcement-sentence table), §"Output" (lines 165-169, four routes re-listed as examples). Plus a fourth surface lives at `docs/substrate/matrices/router.md` and Check 13i greps both. Four encodings to add a route. The N=4 is real; the centralization is wrong-shaped.
- **Evidence:** `cohesively/SKILL.md:33-89`, `:120-128`, `:160-169`; plus `docs/substrate/matrices/router.md`.
- **Recommended fix:** Collapse the three intra-file encodings into one table (route name | when | stops at | clarifying question | announcement | dispatch state). Delete the §"Output" examples. Keep the matrix file as the cross-file mirror.
- **Substrate artifact to add or update:** `cohesively/SKILL.md` — single canonical route table replacing three.

### F5. validate-rewrite/SKILL.md is 280 lines (~2× peers) — the repair loop is buried

- **Severity:** High
- **Category:** Locality
- **Why it matters:** `validate-rewrite/SKILL.md` does two jobs: (a) dispatch a reviewer, (b) operate an internal repair loop with another skill. Job (b) is the substrate-novel part and dominates the file (Step 4 substeps 1-4, the cross-pass fresh-eyes-per-pass invariant restated 4 times, the Bypass + Re-decide acknowledgment prose). The repair loop is partially documented at `handoffs.md` §"validate-rewrite ↔ rewrite-specs"; promoting that to canonical and shrinking SKILL.md Step 4 to a 5-line cite-and-dispatch would materially flatten the skill.
- **Evidence:** `validate-rewrite/SKILL.md:100-138` (Step 4 repair loop); `:236-238` (acknowledgment prose).
- **Recommended fix:** Promote `handoffs.md §"validate-rewrite ↔ rewrite-specs"` to be the canonical repair-loop surface; cut SKILL.md Step 4 to a pointer + the user-visible pass-progress render line.
- **Substrate artifact to add or update:** Spec compression.

### F6. IMPLEMENTATION_PLAN_COVERS_DELTA invariant has no validator check; reviewer-judgment masquerading as structural enforcement

- **Severity:** Medium
- **Category:** Under-enforced invariant
- **Why it matters:** `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md:54-62` lists enforcement as: skill-body acceptance criteria, reviewer-agent verdict, plan persistence, "deferred V1 CI grep," final review. None of these are structural. `AGENTS.md:46` claims it's "enforced by `implement-cohesively`'s acceptance criteria + `delta-coverage-reviewer`." This is one named invariant where "named" exceeds "enforced." The deferred CI grep at line 59 has been deferred since 2026-05-04.
- **Evidence:** `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md:54-62`; `AGENTS.md:46`.
- **Recommended fix:** Either ship the deferred commit-citation grep (small awk over `git log` on the design branch checking that every phase commit cites a plan path + delta-entry IDs), or demote to convention-with-reviewer-attention and explicitly state "no mechanical fence at v0.1; reviewer-judged" in the invariant doc.
- **Substrate artifact to add or update:** Validator script or invariant-doc patch.

### F7. Two dispatch convention docs duplicate ~70% scaffolding

- **Severity:** Low
- **Category:** Spec drift / Idiom mismatch
- **Why it matters:** `dispatch-protocol.md` (Task tool, 82 lines) and `skill-tool-dispatch.md` (Skill tool, 135 lines) are adjacent files, both with prompt-shape templates, "must / must not contain" lists, "concrete dispatch sites in v0.1" sections, and cross-references to each other. The deliberate separation is load-bearing (different tool surfaces) but the scaffolding is duplicated. Each opens with a paragraph explaining the *other* doc's existence and risk.
- **Evidence:** `dispatch-protocol.md:1-5`; `skill-tool-dispatch.md:1-5`; mutually-referencing preambles; both end with §"Related substrate" linking to the same five docs.
- **Recommended fix:** Add a one-page `docs/substrate/conventions/dispatch-overview.md` with the decision matrix (when to use which) and the shared "what dispatch prompts must not contain" list. Trim each child doc to just its contract specifics. Don't merge — the separation is correct; the duplication isn't.
- **Substrate artifact to add or update:** New convention doc.

### F8. Validator Check 13l (chain-rendering anti-pattern) is a one-rewrite scar

- **Severity:** Low
- **Category:** Implicit invariant / Deletion candidate
- **Why it matters:** `validate_plugin.sh:548-564` greps `cohesively/SKILL.md` for `→ <subskill-id>` patterns to catch the retired chain-rendering pattern from the decide-lock-build rewrite. The check pins one file for one regression that landed and was repaired in one rewrite. `audience-separation.md:59` already pins the rule conceptually. Per the promotion criteria at `style-guide-rot.md:60`, a check needs "caught regression" plural plus wording stability — this is one regression, on one surface. Convention-with-grep hardening of a single-file scar is the validator-bloat failure mode.
- **Evidence:** `validate_plugin.sh:548-564`; `audience-separation.md:59`.
- **Recommended fix:** Delete Check 13l. If chain-rendering recurs anywhere (not just `cohesively/SKILL.md`), promote to a repo-wide grep then. Keep the audience-separation prose as the substrate.
- **Substrate artifact to add or update:** Validator delete.

### F9. PLUGIN_ROOT_PATHS.md hosts a "Convention pins" enumeration that doesn't belong there

- **Severity:** Low
- **Category:** Spec drift / Bounded-context
- **Why it matters:** AGENTS.md, ARCHITECTURE.md, and `skill-shape.md` all cite "the canonical enumeration of pinned conventions lives in `PLUGIN_ROOT_PATHS.md` §'Convention pins enforced alongside this invariant.'" An agent reading to learn which conventions are validator-pinned reads an invariant doc whose stated topic is path discipline. Pin #3 in that enumeration also names "Recommended next Cohesive skill" footer — a name that was renamed to `### Next` per `validate_plugin.sh:296`. Stale citation in a load-bearing list.
- **Evidence:** `AGENTS.md:49`; `ARCHITECTURE.md:55`; `skill-shape.md:3`; `PLUGIN_ROOT_PATHS.md:36-53`.
- **Recommended fix:** Promote the pin enumeration to a standalone matrix at `docs/substrate/matrices/validator-pins.md` keyed by check number. AGENTS.md, ARCHITECTURE.md, and skill-shape.md cite the matrix; the invariant doc shrinks to its actual concern (path discipline). Update pin #3 to `### Next`.
- **Substrate artifact to add or update:** New matrix; spec patches.

### F10. Default-recommend rule (N=1) and Render-conditional rules (N=2) haven't earned promotion

- **Severity:** Low
- **Category:** Premature centralization
- **Why it matters:** Per the user's named focus. §"Default-recommend rule" in `references/templates/chat-trailer.md` is used only by `validate-rewrite`'s Approved trailer. §"Render-conditional rules for the body block" pattern is used by `validate-rewrite` and `implement-cohesively` (N=2). Both currently exist as named conventions but haven't earned the convention-vs-inline promotion.
- **Evidence:** `validate-rewrite/SKILL.md:117-126`, `:146-156`; `implement-cohesively/SKILL.md:136-146`; `chat-trailer.md` §"Default-recommend rule" + §"Render-conditional rules".
- **Recommended fix:** Inline both rules into the two skills that use them. Cut the named-rule sections from `chat-trailer.md`. When a third use case appears, re-extract.
- **Substrate artifact to add or update:** `references/templates/chat-trailer.md` — remove §"Default-recommend rule" and §"Render-conditional rules" as named sections.

### F11. scan_substrate.py boolean-precedence bug

- **Severity:** Medium (code defect, but library-native)
- **Category:** External misuse
- **Why it matters:** `scripts/scan_substrate.py:82` — `dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".") or d in {".github", ".circleci", ".gitlab-ci.yml"}]`. Python operator precedence binds `and` tighter than `or`, so this reads as `(d not in SKIP_DIRS and not d.startswith(".")) or d in {...}`. `.gitlab-ci.yml` is a *file*, not a directory, so it can never appear in `dirnames`. The expression conflates dir-allowlist and file-allowlist namespaces.
- **Evidence:** `scripts/scan_substrate.py:82`.
- **Recommended fix:** Split into `ALLOWED_DOT_DIRS = {".github", ".circleci"}`, then `dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and (not d.startswith(".") or d in ALLOWED_DOT_DIRS)]`. Drop `.gitlab-ci.yml`.
- **Substrate artifact to add or update:** None — point fix.

### F12. SKILL body bodies stack design + implementation + render-discipline layers

- **Severity:** High
- **Category:** Pattern propagation / Bounded-context
- **Why it matters:** An agent attempting a one-line edit to `validate-rewrite/SKILL.md` (280 lines) or `implement-cohesively/SKILL.md` (231 lines) would predictably need to read 8+ docs to know which layer their edit belongs in. The §"When to edit SKILL.md alone, and when to edit the design layer first" rule mitigates but does not eliminate this — every body section contains lateral citations into 3-5 substrate docs each.
- **Evidence:** `validate-rewrite/SKILL.md:142-238` (Output format prose carrying ~100 lines of render-conditional rules in five sub-sections); `implement-cohesively/SKILL.md:128-184` (analogous block); `skill-shape.md:228-238` (deviations table accumulating six per-skill exceptions).
- **Recommended fix:** Extract per-skill `## Output format` render-conditional prose into the per-skill section in `architecture/skills.md` or into the `chat-trailer.md` template's §"Variants". Render-conditional rules should live in *one* place per skill, not be split between SKILL.md prose and centralized template's §"Variants".
- **Substrate artifact to add or update:** `chat-trailer.md` (consolidate render-conditional rules); shrink SKILL.md Output format to a one-line citation + the literal render template.

### F13. Skill-count drift across normative surfaces

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** `README.md:34` says "5 subskills underneath plus 3 off-chain diagnostics, 1 router, 1 orientation skill" (= 10). `ARCHITECTURE.md:11` says "eight workflow subskills make ten skills total" (subskills=8 is wrong; that count includes diagnostics). `skills.md:3` says "ten skills" with "five subskills" (correct). Three normative surfaces, three different framings.
- **Evidence:** `README.md:34`; `ARCHITECTURE.md:11`; `skills.md:3`.
- **Recommended fix:** Pick one convention (5 chain subskills + 3 diagnostics + 1 router + 1 orientation = 10). Sweep README, ARCHITECTURE.md, skills.md.
- **Substrate artifact to add or update:** Three doc patches.

### F14. audience-separation §"Why no rule 6" stranded design-rationale

- **Severity:** Low
- **Category:** Scar / Misleading doc
- **Why it matters:** Folded into F3 above. Listed separately for completeness.

## Phased roadmap

**Phase 1 — Cruft compaction (highest leverage):** F2 (cross-skill prose duplication), F3 (stale dated history in normative docs), F4 (cohesively triple-encoded route table), F8 (Check 13l), F10 (premature-centralization promotions), F13 (skill-count drift), F14 (folded into F3). All deletions/compressions; no new substrate.

**Phase 2 — Validator architecture:** F1 (port to Python; split generic vs Cohesive-specific; one source-of-truth for skill arrays). Substantial; needs its own delta ledger.

**Phase 3 — Strengthen enforcement:** F6 (IMPLEMENTATION_PLAN_COVERS_DELTA — ship the deferred grep or demote), F9 (validator-pins matrix), F12 (consolidate render-conditional rules to one home per skill). Each promotes a convention that's earned its slot.

**Phase 4 — Defer or fold:** F5 (extract repair loop to `architecture/repair-loop.md`), F7 (dispatch-overview.md). Lower leverage; can land alongside Phase 1 or wait.

**Defer indefinitely:** none. Every finding has a concrete fix.

## What looked right

- Three rewrites in two days converged Approved + dogfooded the methodology end-to-end. The system passes its own acid test.
- Audience seam holds across the chat-trailer template, audience-separation convention, and per-skill Output format blocks.
- Re-decide reversal added cleanly without renaming gates or touching the dispatch contract.
- Plugin ecosystem alignment is healthy (manifest, frontmatter, ${CLAUDE_PLUGIN_ROOT}, dir layout). Validator is the only library-native concern.
- Per-skill design layer in `architecture/skills.md` paired with implementation layer in SKILL.md is a sound separation that survived all three rewrites.

## Substrate improvements (recommended)

**Specs to rewrite:** ARCHITECTURE.md (compress §"v0.1 scope"); AGENTS.md (cut to ≤40 lines); 10× SKILL.md (drop "What this skill is *not*", replace Voice block with one-line cite); cohesively/SKILL.md (collapse triple-encoded route table); validate-rewrite/SKILL.md (cite repair loop instead of inlining); references/templates/chat-trailer.md (inline N=1 and N=2 rules back to skills); audience-separation.md (move §"Why no rule 6" to gotcha); architecture/skills.md (sunset §"Bootstrap status"); PLUGIN_ROOT_PATHS.md (extract §"Convention pins" to matrix).

**Matrices to add:** `docs/substrate/matrices/skill-prereqs.md` (skill prereq classification — single source); `docs/substrate/matrices/validator-pins.md` (convention pin enumeration with check-number mapping).

**Validator changes:** Port to Python with per-check function shape; derive subset skill-arrays from one source; delete Check 13l; either add the IMPLEMENTATION_PLAN_COVERS_DELTA grep or demote the invariant.

**Gotchas to author:** Possibly `docs/substrate/gotchas/validator-bash-drift.md` if the Python port is deferred. None blocking.

## Disposition

Recommended next step: lock the Phase 1 simplifications into a follow-up rewrite via `cohesive:rewrite-specs`. Phase 2 (validator port) can land in a separate rewrite. Phase 3 enforcement promotions can land alongside or after Phase 1.

Slug: `simplification-pass`. Classification: Mixed.
