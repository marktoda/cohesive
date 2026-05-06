# Design Delta Ledger — Skill pack flow tightening

**Date:** 2026-05-05
**Worktree / branch:** `.worktrees/cohesive-skill-pack-flow-tightening` on `design/skill-pack-flow-tightening`
**Approved direction:** Close the highest-leverage findings from the 2026-05-05 architecture review at `${CLAUDE_PLUGIN_ROOT}/docs/history/reviews/2026-05-05-skill-pack-flow-architecture-review.md` in one atomic rewrite — operationalizing the review's "First: repair substrate" roadmap (steps 1–5) plus the rewrite-shaped items from "Then: simplify architecture" (steps 6–9). The review pressured these decisions; the rewrite encodes them rather than re-litigating.

This ledger records the substrate changes the rewrite made. The fresh-eyes reviewer (`cohesive:validate-rewrite`) reads it as the rewrite's executive summary; future readers see the rewrite as a delta rather than as 'a bunch of files moved around.'

## Delta at a glance

This rewrite is **Mixed**. Design-layer changes: new skill `using-cohesive` (per-skill section in architecture/skills.md, handoff section in handoffs.md, exemption in skill-shape.md, row in skill-section-presence.md); restructured "Adding a new skill" sequence (3-step → 5-step) in architecture/skills.md. Implementation changes: spec drift fixes, new convention doc, validator extension, README/ARCHITECTURE updates, mirror-annotation citations.

- **Files:** 12 rewritten, 3 added, 0 removed/deprecated
- **Conceptual changes:** session-start orientation as a 5th transition shape (handoffs.md); Skill-tool dispatch as a distinct contract from Task-tool dispatch (new conventions doc); validator-array updates as Step 5 of the "Adding a new skill" sequence (was implicit) — or `none` not applicable
- **Named invariants:** none added, none strengthened, none weakened, none removed (`DISPATCH_CONTRACT_MIRROR` and `HANDOFF_VOCABULARY_PARITY` remain candidate invariants — promotion deferred per `style-guide-rot.md` criteria)
- **Behavior matrices:** `skill-section-presence` (cells added: rows for `implement-cohesively` (pre-existing drift fix) and `using-cohesive` (new); intro skill count 8 → 10; new exemption entry); `router` (mirror-annotation citation updated to name Check 13i) — none added, none retired
- **Gotchas:** `discovery-vs-superpowers` (added §"Correct pattern" item 3 naming `using-cohesive` as structural mitigation; renumbered subsequent items 4 and 5); `no-implementation-handoff` (relabeled three "Lint check (deferred V1)" entries as shipped Checks 13e/13f/13g) — none added, none retired
- **Semantic linters:** `validate_plugin.sh` Check 13i (`DISPATCH_CONTRACT_MIRROR` mirror grep) — added
- **Tests proposed:** `none` (the deferred manual scenario tests in `discovery-vs-superpowers.md` and `no-implementation-handoff.md` remain deferred to V1 per the review's roadmap; encoding scenario tests is item 13 in the review's "Then: strengthen enforcement" tier and is out of scope for this rewrite)
- **Deferred (out of scope this pass):** review findings 6–11, 13–16 (right-sized-chain matrix; R016/R900 resolution; Cohesive↔Superpowers grade-selection rule; bootstrap-status promotion procedure; wrong-route-recovery gotcha; intra-pack trigger lint extension; chain-announcement-stacking gotcha; queued-scenario-tests matrix; repair-loop-stall taxonomy); review finding 7 (`plugin.json` thinness) gated on harness-schema verification; named-invariant promotion of `DISPATCH_CONTRACT_MIRROR` and `HANDOFF_VOCABULARY_PARITY` gated on grep-wording stability for one release cycle

## Files rewritten

For each file whose normative content changed:

- `docs/substrate/architecture/handoffs.md`
  - **Before:** Three transition shapes named in the opening blockquote (chain transition, router dispatch, off-chain re-entry) plus a fourth (internal repair loop) added later but not surfaced in the blockquote; the opening section heading "The three transition shapes" enumerated four shapes inconsistently. The `audit-substrate → rewrite-specs` re-entry section claimed the verdict was "Gaps Found" — drift from the SKILL.md vocabulary "Substrate gaps".
  - **After:** Five transition shapes named in the blockquote and the heading (chain, router dispatch, off-chain re-entry, internal repair loop, session-start orientation). New §"using-cohesive → cohesively (session-start orientation)" handoff contract added at the start of "Per-handoff contracts" — names the transition shape, the artifact crossing (none persisted), the verdict gate (none), what `cohesively` must not re-derive, and the failure-mode + detection rule. The `audit-substrate → rewrite-specs` verdict drift is fixed: `Gaps Found` → `Substrate gaps`.
  - **Reason:** Closes review findings 1, 2, and 3. The blockquote/heading enumeration update is the canonical rendering of the five-shape model; the new handoff section is the substrate location for the using-cohesive seam; the verdict-drift fix is the demonstrated parity issue HANDOFF_VOCABULARY_PARITY would catch.

- `docs/substrate/architecture/skills.md`
  - **Before:** Opening blockquote claimed nine skills. Skill-set-at-a-glance table grouped Chain / Off-chain / Router. §"Why these skills, not others" did not enumerate the using-cohesive vs cohesively distinction. Bootstrap-status table listed nine sections. §"Per-skill sections" intro said sections are ordered "by chain position, then off-chain, then router." §"Adding a new skill" was a 3-step sequence (skills.md → handoffs.md → router.md → SKILL.md implicit step 4) with no step covering validator-array updates or skill-section-presence row.
  - **After:** Ten skills named in the blockquote with explicit "session-start orientation skill (`using-cohesive`)" enumeration. New "Session-start orientation" group in the at-a-glance table with `using-cohesive` row. New §"Why these skills, not others" entry: "Why `using-cohesive` is separate from `cohesively`". Bootstrap-status table extends with `using-cohesive` row at `inherited` status. §"Per-skill sections" intro extends ordering rule to "chain position, then off-chain, then router, then session-start orientation". New §"### using-cohesive" section per `SKILL_DESIGN_DOC_SECTION` invariant — Purpose / Owns / Does not own / Inputs / Outputs / Why-this-shape. §"Adding a new skill" restructured into a 5-step sequence: design-layer (skills.md → handoffs.md → router.md), implementation layer (SKILL.md), enforcement layer (validator + skill-section-presence row + run validator).
  - **Reason:** Closes review finding 5 (Adding-a-new-skill sequence omitted validator-array updates; agent following docs would ship a clean skill the validator immediately rejects). Adds the design-layer substrate the new `using-cohesive` skill stands on (per Mixed classification and skill-shape.md §"When to edit SKILL.md alone, and when to edit the design layer first").

- `docs/substrate/conventions/skill-shape.md`
  - **Before:** §"When sections may differ" listed five accepted deviations: cohesively router exemption (Process → Routes; Hard constraints → Required behavior); cohesively voice exemption; discover-substrate's "When to invoke" + "Inputs"; the Token discipline section addition; implement-cohesively's Branch shape addition; validate-rewrite's footer placement.
  - **After:** Adds a sixth deviation entry naming the using-cohesive exemption — same router exemption as cohesively (no `## Voice`, "Output" instead of "Output format", "Required behavior" instead of "Hard constraints"), plus session-start-orientation-specific structure: "When Cohesive applies" + "When to defer to Superpowers" + "How to enter Cohesive" instead of "Routes" + "Routing decision logic"; "Composition" omitted because the only downstream is `cohesively` itself; the "Recommended next Cohesive skill" footer is exempt because the orientation message renders the next-step pointer inline rather than as a trailing H3 footer.
  - **Reason:** The `using-cohesive` skill body uses sections that don't match either the cohesively or the discover-substrate exemption verbatim; per skill-shape.md §"When sections may differ" rule, "new deviations require explicit discussion and an entry in this section before adoption." This entry registers the exemption.

- `docs/substrate/matrices/skill-section-presence.md`
  - **Before:** Tracked eight skills (eight rows in required-sections grid + eight rows in optional-sections grid). `implement-cohesively` row was missing — pre-existing drift the validator could not surface (the matrix can only flag rows that exist with `✗`, not rows that don't exist at all). Two documented exemptions: cohesively router exemption, discover-substrate utility exemption.
  - **After:** Tracks ten skills. New row for `implement-cohesively` (pre-existing drift fix) with all-`✓` cells in required + optional sections matching its actual SKILL.md sections. New row for `using-cohesive` with `~` cells in five required-section cells (per the new exemption added to skill-shape.md) and `–` cells in all optional-section cells. Three documented exemptions: cohesively, using-cohesive, discover-substrate. Intro skill count 8 → 10. History section gets a 2026-05-05 entry recording the additions.
  - **Reason:** Closes the row-absence drift for `implement-cohesively` (incidental cleanup; documented in §"History"). Records the new `using-cohesive` row + exemption as part of the skill addition. The matrix's invariant is "every Cohesive skill under skills/ has a row here"; the rewrite makes the invariant true everywhere, not just for the new skill.

- `docs/substrate/matrices/router.md`
  - **Before:** §"Dispatch prompt contract (per route)" annotation said "Adding a route or subskill requires updating this section *and* `cohesively/SKILL.md` §'Dispatch prompt contract' in the same pass. Drift between the two surfaces produces the exact 'soft-prereqs' failure mode the contract closes." Prose-only enforcement.
  - **After:** Same annotation extends with a citation: `scripts/validate_plugin.sh` Check 13i greps both surfaces and asserts route-name set equality plus prereq-state-string parity to catch the drift mechanically. Prose annotation now points at structural enforcement.
  - **Reason:** Closes review finding 1 (dispatch-prompt-contract mirror unenforced; one PR away from drift). The mirror parity is now mechanically checked, not just prose-noted.

- `skills/cohesively/SKILL.md`
  - **Before:** §"Dispatch prompt contract" annotation said "The matrix-side mirror (with the `validate-rewrite` exception) lives at `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md` §'Dispatch prompt contract'; update both in the same pass." Prose-only enforcement, mirroring router.md.
  - **After:** Annotation extends with the same Check 13i citation as the router.md side. Both surfaces now point at the structural enforcement.
  - **Reason:** Same as the router.md change — close finding 1 by promoting prose annotation to grep enforcement on both sides of the mirror.

- `docs/substrate/conventions/dispatch-protocol.md`
  - **Before:** Opening paragraph claimed the doc covers "every Cohesive reviewer-agent dispatch" (implicitly Task-tool only). Skill-tool dispatches (used by `validate-rewrite` repair loop and `implement-cohesively` phase loop) had no documented home; their constraints lived inline in the consuming skill bodies.
  - **After:** Opening paragraph names the doc as the **Task-tool reviewer-agent** dispatch contract specifically and cross-references the new `skill-tool-dispatch.md` for the parallel Skill-tool contract. §"Related substrate" extends with the new doc. Naming the two contracts as separate documents prevents conflation — a contributor authoring a composition seam can find the right one in one search.
  - **Reason:** Closes review finding 4 (Skill-tool dispatch contract has no documented home; future agent authoring an internal loop has nothing canonical to read).

- `docs/substrate/gotchas/discovery-vs-superpowers.md`
  - **Before:** §"Correct pattern" had four numbered items: substrate-narrowed description; router as canonical entry point; mixed-stack workflow composition; user-intent-preferred for direct discovery questions.
  - **After:** Five numbered items. New item 3 names `using-cohesive` as the structural mitigation: "The session-start orientation skill `using-cohesive` competes natively with `superpowers:using-superpowers` for the harness's bootstrap loading slot — solves the description-match-level competition the router alone cannot solve. The substrate-narrowing rule from item 1 applies double to its frontmatter description." Items 3 and 4 from the original become items 4 and 5.
  - **Reason:** Closes review finding 3 (no `using-cohesive` session-start bootstrap). The gotcha is the seam's substrate location; updating it is required by skill-shape.md §"Anti-patterns" rule "New skill not mentioned in `ARCHITECTURE.md` §'v0.1 scope' or README 'What's in the box' — Source-of-truth disagreement; update both in the same pass" extended to the gotcha that documents the seam.

- `docs/substrate/gotchas/no-implementation-handoff.md`
  - **Before:** §"Tests / checks that preserve this" listed three "Lint check (deferred V1)" entries: validate-rewrite Approved footer decision-matrix grep, implement-cohesively phase-derivation+invariant grep, validate-rewrite bypass-acknowledgment grep.
  - **After:** Same three entries relabeled as shipped, citing `scripts/validate_plugin.sh` Check 13e/13f/13g respectively. The manual scenario test remains the only V1-deferred entry.
  - **Reason:** Closes review finding 12 (substrate undersold its current enforcement coverage; reviewer auditing the gotcha would undercount fences). The label drift is exactly the spec-drift class HANDOFF_VOCABULARY_PARITY would catch on a different surface.

- `scripts/validate_plugin.sh`
  - **Before:** Nine `expected_skills` (without `using-cohesive`). Comment named "the 9 expected skills". No Check 13i.
  - **After:** Ten `expected_skills` (with `using-cohesive` added at top of the list). Comment updated to "the 10 expected skills" plus mention of the 2026-05-05 addition. New Check 13i (`DISPATCH_CONTRACT_MIRROR`) extracts route names from cohesively/SKILL.md §"Dispatch prompt contract" and matrices/router.md §"Dispatch prompt contract (per route)", normalizes (strips ` (V1)` suffix), and asserts set equality. Helper `extract_routes_from_section()` uses exact-string heading match (avoiding awk regex special-character escaping) and `match()` for first-backticked-token extraction.
  - **Reason:** Closes review finding 1's drift surface mechanically. Adding `using-cohesive` to `expected_skills` is the Step 5 from the rewritten "Adding a new skill" sequence — the worked example proving the new step is correctly enumerated.

- `README.md`
  - **Before:** §"What's in the box" `skills/` enumerated 9 skills (without using-cohesive); `conventions/` enumerated 4 docs (without skill-tool-dispatch.md).
  - **After:** `skills/` enumerates 10 skills with `using-cohesive/` listed first (`Session-start orientation — when does Cohesive apply?`); `conventions/` enumerates 5 docs with `skill-tool-dispatch.md` (`Skill-tool (skill→skill) dispatch contract`) added; `dispatch-protocol.md` description tightened to `Task-tool reviewer-agent dispatch-prompt contract` to clarify the seam.
  - **Reason:** README §"What's in the box" is derived from ARCHITECTURE.md and on-disk reality; per skill-shape.md §"Anti-patterns" rule, both must be updated in the same pass.

- `ARCHITECTURE.md`
  - **Before:** Three-tier-architecture section claimed "router (`cohesively`) plus eight subskills make nine skills total". Conventions section listed `dispatch-protocol.md` as the dispatch-prompt template. §"v0.1 scope" claimed 9 skills, 4 convention docs.
  - **After:** Three-tier-architecture section claims "session-start orientation skill (`using-cohesive`), the router (`cohesively`), and eight workflow subskills make ten skills total". Conventions section lists both `dispatch-protocol.md` (Task-tool, with explicit qualifier) and `skill-tool-dispatch.md` (Skill-tool dispatch contract). §"v0.1 scope" claims 10 skills, 5 convention docs; adds a sentence describing the 2026-05-05 `skill-pack-flow-tightening` rewrite alongside the 2026-05-04 `cut-anchor-pin` and 2026-05-05 architecture refactor entries.
  - **Reason:** ARCHITECTURE.md is binding for current architecture; per AGENTS.md "When you are about to..." rules, structural changes to skills/ or conventions/ require an ARCHITECTURE.md update in the same pass.

## Files added

- `docs/substrate/conventions/skill-tool-dispatch.md` — the canonical home of the Skill-tool (skill→skill) dispatch contract, distinct from `dispatch-protocol.md` (Task-tool / fresh-eyes). Carries the four-constraint contract used by `validate-rewrite`'s repair loop and `implement-cohesively`'s phase loop: repair/composition scope; no re-derivation of upstream decisions; commit shape (when applicable); per-pass paths-only when re-dispatching reviewers. Includes a comparison table distinguishing Skill-tool vs Task-tool dispatches and lists the three v0.1 dispatch sites. Cited from `dispatch-protocol.md` §"Related substrate".
- `skills/using-cohesive/SKILL.md` — the session-start orientation skill. Frontmatter description carries the substrate-vocabulary tokens enforced by Check 9a and avoids the bare generic-review triggers Check 9b forbids. Body uses the cohesively router exemption (no `## Voice`, "Output" instead of "Output format", "Required behavior" instead of "Hard constraints") plus session-start-orientation-specific 3-section decision rule ("When Cohesive applies" + "When to defer to Superpowers" + "How to enter Cohesive"). Carries Acceptance criteria and "What this skill is *not*" sections per the standard required set.
- `docs/history/delta-ledgers/2026-05-05-skill-pack-flow-tightening.md` — this ledger.

## Files removed or deprecated

`none` — this is a substrate-tightening rewrite; nothing previously load-bearing becomes obsolete.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| "Three transition shapes" (handoffs.md opening), "Four transition shapes" (in body, post-internal-repair-loop addition) | "Five transition shapes" — chain transition, router dispatch, off-chain re-entry, internal repair loop, session-start orientation | Tightened |
| `audit-substrate` returns "Gaps Found" (handoffs.md re-entry section) | `audit-substrate` returns "Substrate gaps" (matches SKILL.md vocabulary) | Replaced (drift fix) |
| Cohesive ships nine skills (skills.md, ARCHITECTURE.md, README.md) | Cohesive ships ten skills (chain + diagnostics + router + session-start orientation) | Tightened |
| "Adding a new skill" 3-step sequence (skills.md → handoffs.md → router.md, with SKILL.md implicit and validator updates absent) | 5-step sequence: design layer (skills.md → handoffs.md → router.md), implementation layer (SKILL.md), enforcement layer (validator arrays + skill-section-presence + run validator) | Tightened |
| `dispatch-protocol.md` covers "every Cohesive reviewer-agent dispatch" implicitly | `dispatch-protocol.md` covers Task-tool reviewer-agent dispatches only; `skill-tool-dispatch.md` covers Skill-tool (skill→skill) dispatches; both linked from each other | Renamed (clarification) |
| Three `discovery-vs-superpowers.md` "Correct pattern" items + 4 + 5 | Five "Correct pattern" items, with item 3 naming `using-cohesive` as structural mitigation | Tightened |
| Three "Lint check (deferred V1)" entries in `no-implementation-handoff.md` "Tests/checks" section | Three entries cited as shipped Checks 13e/13f/13g; one entry remains "Manual scenario test (planned)" | Tightened (label drift fix) |
| Dispatch-prompt-contract mirror enforced by prose annotation only | Mirror enforced by `validate_plugin.sh` Check 13i (route-name set equality grep), with the prose annotations on both surfaces extended to cite the check | Tightened |
| `skill-section-presence.md` tracks eight skills with two documented exemptions; `implement-cohesively` row absent | Tracks ten skills with three documented exemptions; pre-existing absent-row drift for `implement-cohesively` fixed | Tightened (drift fix) + Added |

## New or updated substrate

### Specs

- `docs/substrate/architecture/handoffs.md` — adds session-start orientation as the 5th transition shape; new §"using-cohesive → cohesively" handoff contract; fixes `audit-substrate` verdict drift.
- `docs/substrate/architecture/skills.md` — adds `### using-cohesive` per-skill section; new §"Why these skills, not others" entry for using-cohesive vs cohesively; bootstrap-status row; restructured "Adding a new skill" sequence (3 steps → 5 steps).
- `docs/substrate/conventions/skill-shape.md` — new §"When sections may differ" entry registering the `using-cohesive` exemption.
- `docs/substrate/conventions/dispatch-protocol.md` — opening paragraph clarifies Task-tool scope and cross-references `skill-tool-dispatch.md`.
- `docs/substrate/conventions/skill-tool-dispatch.md` (new) — canonical home of the Skill-tool dispatch contract.
- `docs/substrate/gotchas/discovery-vs-superpowers.md` — adds "Correct pattern" item 3 naming `using-cohesive` as structural mitigation.
- `docs/substrate/gotchas/no-implementation-handoff.md` — relabels three deferred lint checks as shipped.
- `ARCHITECTURE.md` — skill count 9 → 10; conventions count 4 → 5; new sentence describing this rewrite.
- `README.md` §"What's in the box" — adds `using-cohesive` to skills/; adds `skill-tool-dispatch.md` to conventions/; tightens `dispatch-protocol.md` description.

### Behavior matrices

- `docs/substrate/matrices/skill-section-presence.md` — adds rows for `implement-cohesively` (drift fix) and `using-cohesive` (new); intro skill count 8 → 10; new exemption entry; history entry for 2026-05-05.
- `docs/substrate/matrices/router.md` — mirror-annotation citation extended to name Check 13i.

### Named invariants

`none` — `DISPATCH_CONTRACT_MIRROR` and `HANDOFF_VOCABULARY_PARITY` remain candidate invariants. Promotion criteria per `style-guide-rot.md` require one release cycle of clean grep + a caught regression + a captured worked transcript; this rewrite ships the grep (Check 13i for the first; not yet for the second) but the other criteria need time. Defer promotion until the next release cycle.

### Gotchas

`none added`, `none retired`. Two existing gotchas updated:
- `discovery-vs-superpowers.md` — pattern item added.
- `no-implementation-handoff.md` — labels updated.

### Semantic linter specs

- `validate_plugin.sh` Check 13i (`DISPATCH_CONTRACT_MIRROR`) — added. Extracts route names from `skills/cohesively/SKILL.md` §"Dispatch prompt contract" and `docs/substrate/matrices/router.md` §"Dispatch prompt contract (per route)", normalizes (strips ` (V1)` suffix), asserts set equality. Either drift fails the build.

### Tests / checks proposed (not yet implemented)

`none` — the deferred manual scenario tests in `discovery-vs-superpowers.md` and `no-implementation-handoff.md` remain V1-deferred per the review's roadmap. Encoding scenario tests is finding 13 in the review's "Then: strengthen enforcement" tier and is out of scope.

## What this rewrite *did not* do

- Implementation code: not changed
- Tests: none added (no encoded behavior tests in v0.1; the validator's structural greps are the testing surface)
- CI: not changed (`.github/workflows/validate.yml` runs the validator unchanged; the new Check 13i is exercised by the same workflow)
- Right-sized-chain matrix (review finding 6): deferred
- R016/R900 routing overlap (review finding 8): deferred
- Cohesive↔Superpowers grade-selection rule (review finding 9): deferred
- Bootstrap-status promotion procedure (review finding 10): deferred
- Wrong-route-recovery gotcha (review finding 11): deferred
- Intra-pack trigger competition lint extension (review finding 13): deferred (the existing Check 9b boundary-cross check covers Cohesive vs Superpowers; intra-pack overlap remains reviewer-judged)
- Repair-loop stall taxonomy gotcha (review finding 14): deferred (the loop is new — 2026-05-05 — and lacks production scars)
- Chain-announcement-stacking gotcha (review finding 15): deferred
- Queued-scenario-tests matrix (review finding 16): deferred
- `plugin.json` discoverability fields (review finding 7): deferred (gated on harness-schema verification)
- Named-invariant promotion of `DISPATCH_CONTRACT_MIRROR` and `HANDOFF_VOCABULARY_PARITY`: deferred (gated on grep-wording stability for one release cycle plus caught regression + worked transcript)

## Remaining ambiguity

- `using-cohesive` frontmatter trigger calibration: the description carries the substrate-vocabulary tokens (substrate, cohesion, invariant, gotcha, behavior matrix, spec, rewrite) and avoids bare generic-review triggers, but how cleanly the harness picks `using-cohesive` over `superpowers:using-superpowers` for a given user request is empirical. The structural mitigation (substrate-narrowing per Check 9a/9b) is in place; calibration of trigger phrasing requires dogfood evidence, which this rewrite cannot produce on its own.
- `using-cohesive` exemption shape vs growth pressure: the new exemption (cohesively router exemption + 3-section decision rule) covers the current shape, but if a future session-start surface needs a different structure, the §"When sections may differ" rule requires a new entry. The exemption is registered as a one-off, not a category.
- The "Adding a new skill" Step 5 names six validator skill-set arrays; if a future array is added (or removed), Step 5 needs to update in the same pass to keep the sequence concrete. The §"Adding a new skill" entry says "consult those comments rather than guessing" — pointing at the validator's inline comments — but if those comments drift, Step 5 drifts with them. Watch for it on the next validator change.
- **Check 13j candidate (prereq-state-string parity)** — the dispatch-prompt-contract mirror between `skills/cohesively/SKILL.md` §"Dispatch prompt contract" and `docs/substrate/matrices/router.md` §"Dispatch prompt contract (per route)" carries both route names and prereq-state strings. Check 13i (shipped this rewrite) asserts route-name set equality only. Prereq-state-string parity is HANDOFF_VOCABULARY_PARITY-class enforcement and is currently reviewer-judged. Promotion shape: a sibling extractor in `validate_plugin.sh` that emits `(route, prereq-state-string)` pairs and asserts cross-surface equality, gated on the same wording-stability + caught-regression + worked-transcript criteria as `HANDOFF_VOCABULARY_PARITY` itself. Defer to the same release cycle.
- `using-cohesive` Hard Constraint #1 ("Orient at most once per session per request shape") and Hard Constraint #4 ("Never re-orient over an already-running route") have no detection mechanism in v0.1 — the handoff carries no persisted state, and "already inside a Cohesive workflow" is a session-state judgment with no canonical signal. Reviewer-judged via `cohesive:review-diff` until a real regression motivates promotion to a structural check. Documented in `docs/substrate/gotchas/discovery-vs-superpowers.md` §"Notes for future contributors".

## Repair pass 2

**Source review:** `docs/history/reviews/2026-05-05-skill-pack-flow-tightening-rewrite-validation.md` (pass 1, Issues Found).

**Closed findings:**

- **B1** (Blocker — preamble file count diverges from body): preamble first bullet updated `14 rewritten, 3 added, 0 removed/deprecated` → `12 rewritten, 3 added, 0 removed/deprecated`. The body's §"Files rewritten" was always 12; the preamble was the drift surface and is now consistent with body and §"How to read this ledger" item 4.
- **I1** (Medium — handoffs.md "Adding a new chain skill" deference is now nuanced): the deference paragraph in `docs/substrate/architecture/handoffs.md` §"Adding a new chain skill or re-entry edge" extends with a sentence pointing non-chain skill authors at §"The five transition shapes" in the same doc as the authoritative transition vocabulary, plus instruction to add a contract section naming the matching transition shape. Aligns with skills.md Step 2's reference and removes the load-bearing-but-implicit nature of the five-shape model for non-chain additions.
- **I2** (Low — using-cohesive ownership phrasing): the Owns bullet in `docs/substrate/architecture/skills.md` §"using-cohesive" replaces "Documenting the seam between Cohesive and Superpowers..." with "Being the structural mitigation for the trigger competition documented in...". The gotcha file documents the seam; the skill's existence at the harness session-start slot is what closes it. Phrasing now matches the gotcha's framing and the SKILL.md body's language.

**Deferred:**

- **I3** (Low — validator-array drift watcher): no change this pass per the source review's own recommendation. Carried forward in §"Remaining ambiguity" item 3.

**Repair classification:** Pure implementation. Three textual fixes against named findings; no skill purpose, ownership, seams, verdicts, or chain-shape changes. The I2 fix is a phrasing tightening within the same ownership claim (the skill still owns being the mitigation; the language now reflects that the gotcha file documents the seam while the skill's existence closes it).

**Verification:** `bash scripts/validate_plugin.sh` clean (0 errors, 0 warnings) post-repair, including Check 13h (preamble preserved on the updated ledger).

## Repair pass 3

**Source review:** `docs/history/reviews/2026-05-05-skill-pack-flow-tightening-rewrite-validation-pass-2.md` (pass 2, Issues Found — 2 Blockers, 1 Medium, 1 Low; pass 1's repairs converged but pass-2 fresh eyes surfaced new findings).

**Closed findings:**

- **B1** (Blocker — Check 13i annotation overpromised prereq-state-string parity): both annotation surfaces (`skills/cohesively/SKILL.md` §"Dispatch prompt contract" and `docs/substrate/matrices/router.md` §"Dispatch prompt contract (per route)") now claim only what the validator's grep enforces (route-name set equality). The prereq-state-string parity claim is moved to §"Remaining ambiguity" as a deferred Check 13j candidate, alongside a HANDOFF_VOCABULARY_PARITY-class promotion path. The annotations now match the implementation.
- **B2** (Blocker — two competing "how to add a skill" sequences): `docs/substrate/conventions/skill-shape.md` §"Process when adding a new skill" replaced with a one-paragraph stub that defers to `docs/substrate/architecture/skills.md` §"Adding a new skill" as canonical. The legacy 6-bullet sequence (which omitted the design layer and validator-array steps) is removed; the convention doc now governs only step 4 of the canonical sequence (the SKILL.md body shape). One canonical entry point for adding a skill, not two.
- **I1** (Medium — bootstrap-status `inherited` overloaded): the bootstrap-status table at `docs/substrate/architecture/skills.md` §"Bootstrap status" now distinguishes three statuses: `inherited` (retroactively authored against an existing SKILL.md), `newly-authored` (authored forward alongside or before the SKILL.md body), and `validated` (parity confirmed by `validate-rewrite` lens 13). The `using-cohesive` row updates from `inherited` to `newly-authored` with a note explaining the design layer is genuinely prior substrate. The post-table prose says skepticism applies to both non-validated statuses. `skills.md` §"Adding a new skill" Step 1 instruction now names `newly-authored` as the correct status for newly-added rows. Spec-cohesion-reviewer reads the table at dispatch and applies extra skepticism to both statuses per the updated prose.
- **I2** (Low — using-cohesive Hard Constraints #1/#4 detection mechanism): `docs/substrate/gotchas/discovery-vs-superpowers.md` §"Notes for future contributors" adds a note calling out the reviewer-judged nature of the constraints — the handoff carries no persisted state; `cohesive:review-diff` is the canonical surface that catches re-orientation drift; promotion to a structural check waits for a real regression. The constraint is now substrate-noted; the failure mode is named for future reviewers.

**Repair classification:** Pure implementation. Four textual fixes against named findings; no skill purpose, ownership, seams, verdicts, or chain-shape changes. The bootstrap-status table gains a third status label, but the table's *role* (tracking design-layer maturity) is unchanged — the change is a refinement of the label vocabulary, not a new state machine.

**Verification:** `bash scripts/validate_plugin.sh` clean (0 errors, 0 warnings) post-repair, including Check 13h (preamble preserved), Check 13i (route-name set equality holds — the annotation tightening is a prose change, not a route-name change).

## Repair pass 4

**Source review:** `docs/history/reviews/2026-05-05-skill-pack-flow-tightening-rewrite-validation-pass-3.md` (pass 3, Issues Found — 1 Blocker, 2 Medium, 1 Low; convergence trajectory holding).

**Closed findings:**

- **B1** (Blocker — `skills.md` §"Bootstrap status" cited non-existent "lens-2"): replaced "lens-2 (design-implementation agreement) and lens-14 (handoff contract consistency)" with "lens 13 (design-implementation agreement) and lens 14 (handoff contract consistency)" in the §"Bootstrap status" closing paragraph. The lens numbers now match handoffs.md and the spec-cohesion-reviewer agent's contract; spacing normalized for typographic consistency. Pre-existing typo inherited into the new prose; closed.
- **I1** (Medium — `using-cohesive` Owns claim duplicated SKILL.md Hard Constraint #5 mechanism): tightened SKILL.md Hard Constraint #5 to reference the skills.md design-layer ownership claim and the validator checks (Check 9a / 9b) rather than restate the substrate-vocabulary-token list and forbidden-phrase list inline. The design layer is now the canonical site for the ownership claim; the validator is the canonical site for the mechanism; the SKILL.md body references both. The duplication-that-drifts-across-release-cycles failure mode is closed for this pair.
- **I2** (Medium — Skill-tool dispatch §"Output" template field conflated persisted vs chat trailer): split the §"Output" template field in `skill-tool-dispatch.md` §"What the dispatch prompt must contain" into `## Output (persisted)` and `## Output (chat trailer)` sub-fields, with worked examples for each across the v0.1 dispatch sites (rewrite-specs repair mode; superpowers:writing-plans per phase; superpowers:executing-plans per phase). Added a clarifying paragraph after the prompt-template code block naming the persisted output as load-bearing and the chat trailer as advisory.

**Deferred:**

- **I3** (Low — Step 5 array enumeration drift watcher): no change this pass per the source review's recommendation. Already in §"Remaining ambiguity" item 3.

**Repair classification:** Pure implementation. Three textual fixes against named findings; no skill purpose, ownership, seams, verdicts, or chain-shape changes. The I1 fix moves a phrasing from one site to another (SKILL.md → reference; skills.md and validator → canonical) without changing the underlying claim. The I2 fix splits one prose field into two with clarifying examples; no new contract surface.

**Verification:** `bash scripts/validate_plugin.sh` clean (0 errors, 0 warnings) post-repair.

## Ready for fresh-eyes review?

**Yes** — `bash scripts/validate_plugin.sh` passes clean (0 errors, 0 warnings) with all 13 checks (4 + 5 + 6 + 7 + 8 + 9a + 9b + 10 + 10b + 11 + 12 + 13a-i + 14 + 15) green, including the new Check 13i. The rewrite is structurally consistent and ready for `cohesive:validate-rewrite`.

## How to read this ledger

1. Read the "Approved direction" line and know the destination (close 5 high-leverage findings from the architecture review in one rewrite).
2. Skim "Delta at a glance" and know the shape of the change in 9 lines.
3. Skim "Conceptual changes" and know what's *different* in detail (8 conceptual shifts).
4. Read "Files rewritten" with before/after snippets to verify each rewrite (12 files rewritten, 3 added).
5. Use "Remaining ambiguity" as the focused review punch list.

The "Delta at a glance" preamble is also the surface `validate-rewrite` quotes verbatim into its rendered review, so the validation-review reader sees the same scannable summary at decision time. Keep it consistent with the body sections — the `spec-cohesion-reviewer` agent flags divergence as a Blocking Issue.
