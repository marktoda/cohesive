# Design Delta Ledger — discovery-as-internal-step

**Date:** 2026-05-06
**Worktree / branch:** `.claude/worktrees/discovery-as-internal-step` on `design/discovery-as-internal-step`
**Approved direction:** `cohesive:discover-substrate` becomes an **internal sub-step** dispatched by each consumer skill (`brainstorm-design`, `audit-substrate`, `review-codebase`, `review-diff`) rather than a separate chain step the router dispatches first. Closes the user-reported pain: "when I ask for a brainstorm, it does discover substrate first… then I just get a shit ton of substrate info in chat and then it's like 'next: brainstorm!' but nooo I asked for a brainstorm in the first place." Matches the gate framing: gates are user-visible; sub-skills inside gates are agent-internal.

## Delta at a glance

This rewrite is **Mixed** — primarily Design (the chain model itself changes; the router's `design` / `review (codebase)` / `review (diff)` / `audit (substrate)` routes simplify from two-skill chains to single-skill dispatches; the per-skill ownership of discovery shifts from "router-passed prereq" to "consumer-internal sub-step") with implementation seams in 4 consumer SKILL bodies + the cohesively router + the router matrix + the validator's discovery_prereq_subskills array.

**Design-layer changes:**
- `docs/substrate/architecture/skills.md` — `### discover-substrate` rewritten: Purpose, Owns, Does not own, Outputs, Why-this-shape all reflect the internal-dispatch model. Names direct invocation as the rare case; consumer-internal dispatch as the modal case.
- `skills/cohesively/SKILL.md` §"The three gates" — Decide gate description updated: "what runs underneath" is now `brainstorm-design` (which dispatches `discover-substrate` internally as Step 0), not `discover-substrate` (silent) + `brainstorm-design`. Dispatch prompt contract grid updated: `design` / `review (codebase)` / `review (diff)` / `audit (substrate)` rows all show "n/a — discover-substrate is dispatched internally" for prereq state. Consumers paragraph updated to name "Internal-discovery consumers" instead of "Prereq-state consumers."
- `docs/substrate/matrices/router.md` §"Dispatch prompt contract (per route)" — mirror updated: First subskill column now lists the consumer skill directly (not `discover-substrate`); Prereq state column shows "n/a — internal dispatch" for the four routes.

**Implementation changes:**
- `skills/brainstorm-design/SKILL.md` — Hard constraint #2 rewritten from "discovery is a prereq; ask the user, don't guess" to "discovery is internal to this skill." New Step 0 in Process: "Dispatch substrate discovery (internal)" — names the Skill-tool dispatch, the persistence shape, and the skip-if-prereq-already-passed override. Phase 1 wording updated to consume the Step-0-produced report. The canonical clarifying question is retired (was about discovery state); a new clarifying question is named about change surface (asked only when the user's brainstorm topic doesn't name a subsystem).
- `skills/audit-substrate/SKILL.md` — same shape: Hard constraint #1 rewritten; Process Step 1 ("Re-use the substrate discovery report") rewritten to dispatch internally; canonical question retired in favor of a scope-clarification question.
- `skills/review-codebase/SKILL.md` — Hard constraint #1 rewritten; Phase 1 ("Read normative substrate") split into Phase 1.0 (dispatch discovery internally) and Phase 1.1 (read priority-ordered docs).
- `skills/review-diff/SKILL.md` — Hard constraint #1 rewritten; Process Step 2 ("Substrate discovery, scoped to changed files") rewritten to dispatch internally with the scoped-to-diff override semantics.
- `scripts/validate_plugin.sh` — Check 10 (`discovery_prereq_subskills`) array emptied. The check is preserved structurally so a future skill that re-introduces the discovery-state prereq pattern would land in the array; today the array is intentionally empty because no skill carries that pattern anymore. Comment updated to name the 2026-05-06 internalization rationale.

- **Files:** 6 rewritten, 1 added (this ledger), 0 removed
- **Conceptual changes:** Discovery is no longer a user-visible chain step — it's a consumer-internal sub-step. The "discovery-state prereq" pattern is retired across the substrate; the canonical-question convention applies only to skills with genuinely user-decision prereqs (currently none with discovery state; rewrite-specs has a chosen-direction prereq which is a different question). The router's chain model simplifies: 4 routes go from 2-skill chains to single-skill dispatches.
- **Named invariants:** none added / removed / changed.
- **Behavior matrices:** `docs/substrate/matrices/router.md` §"Dispatch prompt contract (per route)" updated to reflect single-skill dispatch for the 4 affected routes; cell IDs preserved per immutability rule.
- **Gotchas:** The user-reported failure mode ("I asked for a brainstorm but got a substrate dump first") is now structurally closed. A gotcha doc is not authored this pass because the failure mode is a one-shot regression that the rewrite eliminates, not a recurring scar; if the pattern re-emerges in a future invocation surface, a gotcha lands then.
- **Semantic linters:** Check 10 generalized (empty array now passes vacuously; the check stays structurally so future regressions are caught). No new check added; the deferred Check 13o (substrate-vocabulary table fields) is unaffected.
- **Tests proposed:** A worked-transcript demonstration of "user invokes /cohesive:cohesively brainstorm a refactor of X → user sees brainstorm output (not discovery output) as the user-visible content" — deferred until a real invocation produces the canonical surface for `docs/history/transcripts/`.
- **Deferred (out of scope this pass):** Full sweep of `composition` sections in the 4 consumer skill bodies to update "always preceded by: discover-substrate" (the language is technically still true — discovery happens before the consumer's main work — but with the new internal-dispatch model the more precise wording is "internally dispatches discover-substrate as Step 0"). Lighter-touch edits suffice; the sweep can ride along with future per-skill rewrites.

## Files rewritten

- `skills/brainstorm-design/SKILL.md`
  - **Before:** Hard constraint #2 said "Substrate discovery is a prereq; ask the user, don't guess" with a canonical forced-choice question about discovery state. Phase 1 ("Ground the brainstorm") said "Use the discovery report (passed by the router or produced by Hard constraint #2's pre-check)."
  - **After:** Hard constraint #2 rewritten to "Substrate discovery is internal to this skill." Step 0 of Process dispatches `cohesive:discover-substrate` via the Skill tool with the change surface from the user's brainstorm topic; persists the report; consumes it as Phase 1 input. Optional override clause names the three skip cases (user explicitly invoked discover-substrate; another consumer ran it earlier; legacy router prereq state). New canonical clarifying question is about change surface (which subsystem the brainstorm is about), not discovery state. Phase 1 wording updated to consume the Step-0 report.
  - **Reason:** Closes the user-reported pain. The Decide gate is now a single-skill operation: brainstorm-design owns discovery internally; the user sees the brainstorm output, not separate discovery output.

- `skills/audit-substrate/SKILL.md`
  - **Before:** Hard constraint #1 carried the canonical discovery-state question. Process Step 1 said "Re-use the substrate discovery report" — referenced the user's answer to the prereq question or the router's dispatch prompt.
  - **After:** Hard constraint #1 rewritten to "Substrate discovery is internal to this skill." Step 1 rewritten to "Dispatch substrate discovery internally and consume the report" — dispatches discover-substrate via the Skill tool with the audit scope; persists; consumes. New canonical clarifying question is about scope (whole repo vs subsystem), not discovery state.
  - **Reason:** Same as brainstorm-design. The audit (substrate) route becomes a single-skill operation.

- `skills/review-codebase/SKILL.md`
  - **Before:** Hard constraint #1 carried the canonical discovery-state question. Phase 1 ("Read normative substrate") said "Use `discover-substrate` (or its output) to get the list" — implicit dispatch.
  - **After:** Hard constraint #1 rewritten to "Substrate discovery is internal to this skill." Phase 1 split into Phase 1.0 (dispatch discovery internally) and Phase 1.1 (read priority-ordered docs from the discovery report's listing).
  - **Reason:** Same as brainstorm-design. The review (codebase) route becomes a single-skill operation.

- `skills/review-diff/SKILL.md`
  - **Before:** Hard constraint #1 carried the canonical discovery-state question. Process Step 2 said "Run `discover-substrate` with the changed file paths as the change surface (or reuse its output if the router already ran it)."
  - **After:** Hard constraint #1 rewritten to "Substrate discovery is internal to this skill." Process Step 2 rewritten to "Dispatch substrate discovery internally, scoped to changed files" — dispatches via Skill tool; scoped to changed-files set per Hard constraint #4 (which says the discovery scope is bounded to the diff, not whole-repo); persists; consumes.
  - **Reason:** Same as brainstorm-design. The review (diff) route becomes a single-skill operation.

- `skills/cohesively/SKILL.md`
  - **Before:** §"The three gates" Decide row said `discover-substrate` (silent) + `brainstorm-design`. Dispatch prompt contract had four "Discovery already complete; report at <path>" entries for the four affected routes.
  - **After:** Decide row says `brainstorm-design` (which dispatches `discover-substrate` internally as Step 0). Dispatch prompt contract simplified — the four routes show "n/a — discover-substrate is dispatched internally by <consumer>" for prereq state. Consumers paragraph updated to name "Internal-discovery consumers" instead of "Prereq-state consumers" with a clarifying note about the optional-override path.
  - **Reason:** Mirrors the consumer-skill changes; the router's view of the chain reflects the new model.

- `docs/substrate/matrices/router.md`
  - **Before:** Dispatch prompt contract grid listed `discover-substrate` as the First subskill for design / review (codebase) / review (diff) / audit (substrate); Prereq state column carried the canonical "Discovery already complete" strings for the latter three.
  - **After:** First subskill column lists the consumer skill directly (`brainstorm-design`, `review-codebase`, `review-diff`, `audit-substrate`); Prereq state column shows "_none — <consumer> dispatches `discover-substrate` internally as <step>_". Cell IDs (R001-R017) preserved per immutability rule; no new cells added.
  - **Reason:** Matrix mirror of the cohesively SKILL.md change. Check 13i (DISPATCH_CONTRACT_MIRROR) requires both surfaces to enumerate the same routes, which they do — only the per-route columns changed.

- `docs/substrate/architecture/skills.md`
  - **Before:** `### discover-substrate` Why-this-shape said "Discovery is the prereq for every other chain skill."
  - **After:** `### discover-substrate` rewritten throughout: Purpose names the internal-dispatch primary pattern; Owns adds the persistence/reuse semantics; Does-not-own adds "Being a chain step the router dispatches separately"; Outputs clarifies persisted-to-disk-with-path-return; Why-this-shape names the user-reported pain ("shit ton of substrate info in chat") as the motivation for the internalization.
  - **Reason:** The design layer reflects the new model. Lens-13 agreement: discover-substrate's design-layer Purpose / Owns / Why-this-shape now match the SKILL.md body's behavior (dispatched internally as primary pattern; direct invocation rare).

- `scripts/validate_plugin.sh`
  - **Before:** `discovery_prereq_subskills` array listed 5 skills (brainstorm-design, rewrite-specs, review-codebase, review-diff, audit-substrate); the check failed if any of those skills lacked the canonical question literal.
  - **After:** Array emptied. Comment block updated to name the 2026-05-06 internalization rationale: discovery is now plumbing internal to consumer skills, so no skill carries the discovery-state canonical question anymore. Check structure preserved (so a future regression surfaces) but passes vacuously today.
  - **Reason:** The validator's enforcement target moved when the skills' shape moved. Keeping the check structure means a future contributor reintroducing the old pattern would land in the array; emptying the array reflects today's state without removing the convention-with-grep machinery.

## Files added

- `docs/history/delta-ledgers/2026-05-06-discovery-as-internal-step.md` — this file.

## Files removed or deprecated

None.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| `discover-substrate` is a chain step the router dispatches first; its chat output is part of the user-visible flow | `discover-substrate` is a sub-step the consumer skill dispatches internally; its chat output is plumbing the user does not see | Reframed |
| 4 consumer skills (brainstorm-design, audit-substrate, review-codebase, review-diff) carry the canonical "Has substrate discovery already happened?" question | 4 consumer skills dispatch discovery internally; their canonical clarifying questions are now about change surface or scope (asked only when the user's request is unclear) | Retired (discovery-state question) / Replaced (change-surface or scope question) |
| Router routes `design` / `review (codebase)` / `review (diff)` / `audit (substrate)` are 2-skill chains (discover-substrate → consumer) | Router routes are single-skill dispatches (consumer dispatches discovery internally) | Simplified |
| Dispatch prompt contract for the 4 affected routes carries "Discovery already complete; report at <path>" prereq state | Dispatch prompt contract for those routes shows "n/a — internal dispatch" for prereq state; the optional-override path is named in each consumer's Hard constraint #1 | Tightened |

## New or updated substrate

### Specs

- `skills/brainstorm-design/SKILL.md` — Hard constraint #2 + new Step 0 + Phase 1 wording updates.
- `skills/audit-substrate/SKILL.md` — Hard constraint #1 + Step 1 update.
- `skills/review-codebase/SKILL.md` — Hard constraint #1 + Phase 1 split.
- `skills/review-diff/SKILL.md` — Hard constraint #1 + Step 2 update.
- `skills/cohesively/SKILL.md` — gates table + dispatch contract + consumers paragraph.
- `docs/substrate/matrices/router.md` — dispatch contract mirror.
- `docs/substrate/architecture/skills.md` — `### discover-substrate` rewritten.

### Behavior matrices

- `docs/substrate/matrices/router.md` updated (per-route columns; cell IDs preserved).

### Named invariants

None added, removed, strengthened, or weakened.

### Gotchas

None added or retired. The user-reported failure mode is structurally closed by this rewrite; no recurring-scar gotcha is needed.

### Semantic linter specs

- Check 10 (canonical prereq-detection question) generalized: array emptied; check passes vacuously today. Future regression surfaces if a skill re-introduces the pattern.

### Tests / checks proposed (not yet implemented)

- A worked-transcript demonstration of the new flow (user invokes `/cohesive:cohesively brainstorm a refactor of X` → user sees brainstorm output, not discovery output). Deferred until a real invocation produces the canonical surface.

## What this rewrite *did not* do

- **Sweep `## Composition` sections in the 4 consumer skill bodies.** The "Always preceded by: `discover-substrate`" language is technically still true (discovery happens before the consumer's main work) but with the new model the more precise wording is "internally dispatches `discover-substrate` as Step 0 / Phase 1.0." The lighter-touch updates in this pass don't sweep Composition sections; future per-skill rewrites can absorb the wording polish.
- **Update `docs/substrate/architecture/handoffs.md`'s discover-substrate handoffs.** The current `discover-substrate → brainstorm-design` (and 3 sibling) handoff entries treat discovery as a chain edge; with the new model they're internal-dispatch transitions. The handoff doc's transition shapes are described in §"The five transition shapes" + the provisional "Adoption" sixth shape; "internal-dispatch" is materially the same shape as "internal repair loop" (§4 in the existing five shapes). Updating handoffs.md is deferred to keep this rewrite scoped; the matrix mirror in router.md (which is the cited canonical home for dispatch contracts) is updated.
- **Author the worked transcript demonstrating the new flow.** Deferred until a real invocation produces it.
- **Address the dispatch-contract footnote about `validate-rewrite` being the documented exception.** The exception still holds; the four-skill internalization doesn't change validate-rewrite's status as the documented non-discovery-prereq consumer.

## Remaining ambiguity

- **The optional-override path's discovery-report-staleness question.** Each consumer's Hard constraint #1 names an "optional override" — if a discovery report path is passed in the dispatch prompt, skip re-running discovery. But discovery reports can become stale (a report produced an hour ago against a different change surface, or against the same surface but before the user ran a substantial branch operation). v0.1 trusts the dispatch prompt's claim; the consumer doesn't validate freshness. If staleness becomes a real failure mode, a future delta could add a freshness check (e.g., "is the report's persisted timestamp within 5 minutes of the current invocation?").
- **Direct invocation of `/cohesive:discover-substrate` is now the rare case but its render isn't tightened.** discover-substrate's SKILL.md Output format still describes a full inventory render appropriate for direct invocation. Internal dispatchers won't render its output (the consumer reads the persisted file directly), so this isn't a contradiction — but a future contributor running `/cohesive:discover-substrate` directly will get the full inventory render, which is the correct behavior for that path.
- **The composition-with-superpowers seam at the gate boundary.** With the Decide gate now a single-skill operation, the gate boundary (where the user sees output) is brainstorm-design's chat trailer. Implications for the Lock and Build gates are not affected by this rewrite (those gates were already single-or-near-single-skill operations), but a future composition refactor that touches gate boundaries should consider that "what runs underneath" the Decide gate is now structurally a single skill, not a chain.
