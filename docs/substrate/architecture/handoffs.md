# Skill handoffs

> Every Cohesive transition is one of five formalized shapes plus one provisional sixth: a chain transition (verdict-gated, artifact-carrying), a router dispatch (`cohesively` → subskill, with prereq state), an off-chain re-entry (a review or audit finding back into the chain), an internal repair loop (a skill dispatching another Cohesive skill via the Skill tool inside its own Process), session-start orientation (the bootstrap skill `using-cohesive` advising Claude to enter Cohesive at all), and — newly named in 2026-05-06 — a provisional **adoption** shape (the one-shot `init` skill at codebase adoption time; pending formalization to a sixth shape after init has run against multiple real codebases — see §"init → user-driven keep/reject (adoption)"). This doc enumerates chain transitions, re-entry edges, the one internal repair loop, the session-start orientation seam, and the adoption seam. Router dispatches live in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md`; Cohesive↔Superpowers seams live in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md`.

## The five transition shapes

**1. Chain transition.** A skill produces an artifact carrying a verdict (or no verdict, in which case user approval gates the transition). The downstream skill consumes that artifact and runs. Four forward chain transitions form the linear chain.

**2. Router dispatch.** `cohesively` selects a route and dispatches the first subskill of that route, passing prereq state and chosen-direction state explicitly per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md` §"Dispatch prompt contract". The router does not own the chain; it owns the entry point.

**3. Off-chain re-entry.** A diagnostic skill (`review-codebase`, `review-diff`, `audit-substrate`) produces findings that re-enter the chain at the appropriate skill. Re-entry is user-driven — the diagnostic recommends a next Cohesive skill in its output footer; the user invokes it. The Design Incoherent verdict from `validate-rewrite` is also treated as off-chain re-entry because it returns further back than the immediate predecessor (to `brainstorm-design`, not to `rewrite-specs`).

**4. Internal dispatch (with or without loop).** A skill dispatches another Cohesive skill via the Skill tool *within its own Process* and consumes that skill's output. Two sub-shapes share this transition:

- **One-shot internal dispatch** — the consumer dispatches a sub-skill once, consumes the persisted output, and proceeds. The 2026-05-06 discovery-as-internal-step rewrite created four instances: `brainstorm-design` / `audit-substrate` / `review-codebase` / `review-diff` each dispatch `cohesive:discover-substrate` internally as a Step 0 / Phase 1.0 / Step 1 / Step 2 sub-step. See §"discover-substrate ↔ consumer skills (internal-dispatch transition)" below.
- **Internal repair loop** — the consumer dispatches a sub-skill, dispatches a reviewer-agent Task subprocess, and *re-dispatches* the sub-skill on a verdict. Currently one such loop: `validate-rewrite`'s Issues Found repair loop with `rewrite-specs` (see §"validate-rewrite ↔ rewrite-specs (Issues Found internal repair loop)" below).

Both sub-shapes share the same property: the dispatch is invisible to the user as a chain edge; the consumer's own output is what the user sees.

**5. Session-start orientation.** The bootstrap skill `using-cohesive` advises Claude when Cohesive-shaped work is the right framing. It carries no artifact and no verdict; its sole effect is to route the user's substrate-shaped requests to `cohesively` rather than to Superpowers' research/exploration framing. The seam exists because Cohesive needs a session-start surface that competes natively with `superpowers:using-superpowers` for the harness's bootstrap loading slot — without it, first-time users land in the trigger competition documented in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/discovery-vs-superpowers.md`. See §"using-cohesive → cohesively (session-start orientation)" below for the per-handoff contract.

## The chain

```
discover-substrate ──▶ brainstorm-design ──▶ rewrite-specs ──▶ validate-rewrite ──▶ implement-cohesively
                                                                       │
                                                                       └─ internal repair loop
                                                                          (Issues Found → rewrite-specs)
```

Forward chain: four edges. The Issues Found verdict from `validate-rewrite` is **not** a public chain edge — it drives an internal repair loop within `validate-rewrite` that dispatches `rewrite-specs` and re-dispatches the reviewer until verdict converges (Approved), exits to design (Design Incoherent), or stalls at `MAX_REPAIR_PASSES`. See §"validate-rewrite ↔ rewrite-specs (Issues Found internal repair loop)" below. Design Incoherent returns further back to `brainstorm-design` (treated as off-chain re-entry — see §"Off-chain re-entry").

## Per-handoff contracts

Each handoff specifies: artifact crossing the seam, persistence shape, verdict gate (if any), what the downstream must not re-derive, and the failure mode if the contract drifts.

**Verdict labels are agent-facing.** Edge entries below name verdicts using their **internal labels** (`Approved`, `Issues Found`, `Substrate gaps`, `Pass`, `Cohesive but under-enforced`, etc.) — these are the dispatch keys the routing logic and the cohesion rubric operate on. The user-facing verdict labels rendered in chat are translated from these internal labels per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md`; the translation happens once, in the centralized chat-trailer template at `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md`. Handoff contracts here, the cohesion rubric in `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md`, and `spec-cohesion-reviewer`'s lens-14 checks all keep working with the internal labels — they are the substrate-shape vocabulary, the agent's tool. The audience seam in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md` documents the boundary.

### using-cohesive → cohesively (session-start orientation)

**Transition shape.** Session-start orientation per §"The five transition shapes" #5. Not a chain edge, not a router dispatch (the router is the *target*, not the source), not an off-chain re-entry. `using-cohesive` is upstream of every other Cohesive skill — it advises Claude when to enter the methodology at all.

**Artifact crossing.** None persisted. `using-cohesive`'s output is at most a 1–2 sentence orientation rendered in chat (when its frontmatter trigger fires) plus an internal advisory to invoke `cohesively` on the user's next substrate-shaped request. The orientation is a framing nudge, not a deliverable.

**Persistence.** None. `using-cohesive` does not write a file; it does not maintain conversation state beyond the orientation message.

**Verdict gate.** None. The skill is advisory; it has no verdict to gate downstream skills on.

**What `cohesively` must not re-derive.** The orientation message itself. If the router renders its own session-start framing on top of `using-cohesive`'s, the user sees double-orientation and the seam's value (one canonical entry point) is lost. The router's announcement (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Router conventions") is the route announcement, not a re-orientation.

**Failure mode if the contract drifts.** `using-cohesive`'s frontmatter trigger phrase widens to "explore the codebase" or similar generic surfaces; the harness picks `using-cohesive` for non-Cohesive-shaped requests; the orientation fires when it shouldn't. Detection: `validate_plugin.sh` Check 9b (negative-trigger lint) applies to `using-cohesive`'s frontmatter description on the same surface as every other Cohesive skill. The narrowing rule is in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/discovery-vs-superpowers.md` §"Correct pattern", which `using-cohesive` cites by reference.

### init → user-driven keep/reject (adoption)

**Transition shape.** Adoption — distinct from chain transition (no verdict carries forward), router dispatch (`init` is the dispatched skill, not the source), off-chain re-entry (`init` doesn't re-enter the chain — it's the entry surface for users with no chain to re-enter yet), or session-start orientation (`init` runs once at adoption time, not at every session start). A new transition shape, named here, that the §"The five transition shapes" section may want to formalize as a sixth shape after init has run against multiple real codebases.

**Inbound — direct invocation or router cell R017.** The user invokes `cohesive:init` directly when they know their codebase has no Cohesive substrate, or the `cohesively` router dispatches `init` per cell R017 (`docs/substrate/matrices/router.md`) when the user's request matches first-time-adoption trigger phrases ("initialize cohesive" / "set up substrate" / "we're new to cohesive" / "init"). No prereq state passes; init has no Cohesive prereq.

**Artifact crossing — outbound to user.** A draft directory at `docs/substrate/init-draft/` containing per-artifact draft files (each with evidence + side-by-side translation + proposed artifact + decision checkbox). Optional skeletal CLAUDE.md and ARCHITECTURE.md if neither exists.

**Persistence.** Init writes the draft directory and stops. The user reviews each draft, edits or deletes, and `git mv`s kept drafts to canonical locations (`docs/substrate/invariants/`, `docs/substrate/gotchas/`, `docs/substrate/matrices/`, etc.). The user owns the keep/reject decision and the move; init does not auto-commit or auto-merge.

**Verdict gate.** None. Init is a utility skill (parallel to `discover-substrate`); it produces drafts, not judgments.

**What the user must not skip.** The translation step. Each draft file carries the substrate-type's user-facing definition inline; opening the file *is* the pedagogical moment. A user who `git mv`s without opening the file misses the Rosetta Stone — which is recoverable (the file is preserved in canonical location) but defeats init's primary purpose.

**Failure mode if the contract drifts.** (a) Init proposes drafts overlapping with existing substrate it failed to detect — caught by Hard constraint #1's substrate-shaped-paths refusal list. (b) The user accepts every draft without reading the translations — hard to detect mechanically; mitigation is the chat trailer's "what to do next" pointer naming the review step explicitly. (c) Init's draft directory persists beyond adoption (becomes ambient cruft) — mitigation is convention: the draft directory lives at `docs/substrate/init-draft/` and is cleaned up by the user as part of the keep/reject pass.

### init → audit-substrate (often-followed-by edge)

**Transition shape.** Off-chain user-driven re-entry — init is bounded (≤20 drafts); audit-substrate is exhaustive. After kept drafts are committed and the codebase is no longer empty-substrate, audit finds what init missed.

**Artifact crossing.** No formal artifact; the user's claim that "kept drafts are committed to canonical locations" is the implicit prereq. Audit-substrate runs its own discover-substrate pass and finds the now-non-empty substrate to audit.

**Persistence.** N/a — the transition is user-driven; audit's own persistence rules apply once it runs.

**Verdict gate.** None at the seam. Audit's verdict (Substrate sound / Substrate gaps / Substrate sparse) gates *its own* downstream `### Next` recommendation, not this transition.

**What `audit-substrate` must not re-derive.** The drafts init already proposed and the user already kept. Audit reads the substrate as-committed; it does not re-extract proto-signals from the same comments init scanned. (In practice: audit will sometimes re-flag a comment init missed; that's expected — the bounded-init / exhaustive-audit seam is the design.)

**Failure mode if the contract drifts.** Init produces drafts that overlap with what audit-substrate will later flag — wasted reviewer attention. Mitigation: init caps at 20 and is signal-grep based; audit operates against the kept substrate. The categories are distinct enough that overlap is rare.

### discover-substrate ↔ consumer skills (internal-dispatch transition)

As of the 2026-05-06 discovery-as-internal-step rewrite, `discover-substrate` is no longer a chain edge the router dispatches separately. Each consumer skill (`brainstorm-design`, `audit-substrate`, `review-codebase`, `review-diff`) dispatches `cohesive:discover-substrate` via the Skill tool internally as a sub-step of its own Process. This is structurally an **internal-dispatch transition** — same shape as the validate-rewrite ↔ rewrite-specs internal repair loop (transition shape #4 per §"The five transition shapes"), but with the consumer dispatching upstream rather than re-dispatching downstream.

**Transition shape.** Internal dispatch within the consumer skill's Process. The consumer dispatches `cohesive:discover-substrate` via the Skill tool with a change surface (the user's brainstorm topic / audit scope / review scope / changed-files set), waits for the persisted report path, and consumes the report as input to its main work. The router does not see this dispatch — it only dispatches the consumer skill.

**Artifact crossing.** Substrate discovery report (persisted to disk by `discover-substrate`; path returned to the dispatching consumer).

**Persistence.** Always persisted (so cross-skill reuse is possible per the optional-override path in each consumer's Hard constraint #1). The report lives at the path `discover-substrate` chooses per its artifact-resolution rules.

**Verdict gate.** None at the seam. Discovery is a no-verdict utility; the consumer's verdict is what gates anything downstream.

**Optional override (cross-skill reuse).** If the dispatch prompt to a consumer skill includes "Discovery already complete; report at <path>", the consumer skips the internal `discover-substrate` dispatch and reads the named report directly. This handles three cases: (a) the user explicitly invoked `cohesive:discover-substrate` before the consumer; (b) another consumer skill ran discovery earlier in the same session and the report covers the same change surface; (c) legacy router-driven invocation patterns from before the 2026-05-06 internalization. The override is an optimization; the default is internal dispatch.

**What the consumer must not re-derive.** The substrate inventory itself, when an override report path is supplied. Re-running discovery against an already-supplied report wastes the cross-skill reuse benefit and risks producing a divergent inventory.

**Failure mode if the contract drifts.** (a) The consumer renders discovery's chat output as if it were a separate chain step (the user-reported pain the rewrite closed) — caught by reviewer attention on chat-trailer surfaces. (b) The consumer dispatches discover-substrate without a change surface — caught by discover-substrate's own input contract (it asks for a change surface if unclear). (c) The optional-override path is taken with a stale or scope-mismatched report — currently reviewer-judged; a future delta could add a freshness check or scope-match verification. (d) A new consumer skill is added but doesn't dispatch discovery internally — caught by the per-skill design layer in `architecture/skills.md` § the new skill's section, which would flag the omission against the new "Internally dispatches" Composition convention.

**Cited from.** Each consumer skill's Hard constraint #1 + Process Step (0 / 1 / 1.0 / 2 depending on the skill) + `## Composition` "Internally dispatches" bullet. The router does not cite this transition because it does not participate.

### brainstorm-design → rewrite-specs

**Artifact crossing.** Approved direction — option name, summary paragraph, named main risk, structural mitigation.

**Persistence.** Brainstorm output (chat or `docs/history/brainstorms/<date>-<slug>.md`); the approved direction is the trailing recommendation.

**Verdict gate.** No automated verdict. The user approves a direction by responding ("go with Option C" or equivalent). The router's `design` route passes the approved direction in its dispatch prompt to `rewrite-specs`, closing the soft-prereqs gap.

**What `rewrite-specs` must not re-derive.** The chosen direction. If `rewrite-specs` re-litigates which option to take, it has crossed the seam back into design — a category error.

**Failure mode if the contract drifts.** The rewrite implements a direction subtly different from what was approved; the delta ledger doesn't match the brainstorm output; `validate-rewrite` returns Design Incoherent or Issues Found, and the user repairs.

### rewrite-specs → validate-rewrite

**Artifact crossing.** Design delta ledger (`docs/history/delta-ledgers/<date>-<slug>.md`) + rewritten spec paths + branch name (`design/<slug>`).

**Persistence.** Delta ledger persisted at canonical path; rewritten specs persisted in place at their original paths; branch carries the atomic commit.

**Verdict gate.** None on this edge — the verdict is *produced* by `validate-rewrite`. The handoff requires only that the ledger and rewrite are committed atomically on the `design/<slug>` branch.

**What `validate-rewrite` must not re-derive.** The rewrite scope. The reviewer reads the delta ledger as the rewrite's executive summary; re-reading the entire repo to derive scope defeats the ledger's purpose.

**Failure mode if the contract drifts.** Reviewer reads specs without the ledger and produces a generic architecture review rather than a rewrite-targeted validation; the verdict no longer maps to the intended downstream actions. Detection: `validate-rewrite` quotes the ledger's `## Delta at a glance` preamble verbatim into the validation review; if the preamble is absent or the review fails to cite it, the contract has drifted.

### validate-rewrite → implement-cohesively (Approved branch)

**Artifact crossing.** Validation review path + design delta ledger path + branch name (`design/<slug>`).

**Persistence.** Validation review at `docs/history/reviews/<date>-<slug>-rewrite-validation.md`; delta ledger already persisted; branch already committed.

**Verdict gate.** **Approved** required. Issues Found and Design Incoherent verdicts go to different edges (see below).

**What `implement-cohesively` must not re-derive.** The design intent. The phase loop derives phases from the delta ledger; re-reading the brainstorm output or re-asking what the design is converts implementation back into design.

**Failure mode if the contract drifts.** Implementation falls into freeform code; phases stop being delta-derived; `IMPLEMENTATION_PLAN_COVERS_DELTA` is violated; `delta-coverage-reviewer` returns Drift or Incomplete. The named invariant exists precisely because this is the most expensive failure of the implementation phase.

### validate-rewrite ↔ rewrite-specs (Issues Found internal repair loop)

**Transition shape.** Internal repair loop within `validate-rewrite`, not user-driven re-entry. When the `spec-cohesion-reviewer` agent returns `Issues Found`, `validate-rewrite` dispatches `rewrite-specs` in repair mode via the Skill tool, then re-dispatches the reviewer for the next pass. The user sees pass-by-pass progress in chat but does not invoke `rewrite-specs` themselves except after a max-passes stall or a Design Incoherent exit.

**Artifact crossing.** Per-pass validation review (`<date>-<slug>-rewrite-validation[-pass-N].md`) carrying `Issues Found` verdict and the enumerated `## Recommended repairs (ranked)` list. The Skill-tool dispatch prompt to `rewrite-specs` names this review path as the source and instructs repair-mode operation per `${CLAUDE_PLUGIN_ROOT}/skills/rewrite-specs/SKILL.md` §"Process Step 1b. Repair-pass mode".

**Persistence.** Each pass's review persists for audit trail. Repair commits land on the same `design/<slug>` branch in pass order; commit messages cite the pass number and the closed finding IDs.

**Verdict gate.** **Issues Found** drives the loop forward. Three exits terminate the loop:

- **Approved** — verdict converged. `validate-rewrite` renders disposition + (if applicable) implementation decision matrix; the loop exits to `validate-rewrite → implement-cohesively (Approved branch)` per the next section.
- **Design Incoherent** — the chosen direction is unsound. `validate-rewrite` renders disposition recommending `brainstorm-design`; the loop cannot fix design-shape problems and exits to off-chain re-entry per `validate-rewrite → brainstorm-design (Design Incoherent re-entry)`.
- **Max passes reached** — the loop's pass count hits `MAX_REPAIR_PASSES` (default 5; configurable per-invocation via `--max-passes=N`) without converging. `validate-rewrite` surfaces the latest review with a stall banner naming the latest verdict and findings; the recommendation is `cohesive:brainstorm-design` (the design itself may be unsound) or manual repair followed by re-invocation.

**What the dispatched `rewrite-specs` must not re-derive.** The brainstormed direction. The repair fixes specs against a still-approved direction; if the direction itself is unsound, the *next* pass's reviewer should return Design Incoherent (which exits the loop). The Skill-tool dispatch prompt to `rewrite-specs` states this constraint inline in `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Step 4. Repair loop" substep 2, alongside the repair-scope and commit-template constraints. (The reviewer-agent dispatch protocol in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/dispatch-protocol.md` covers skill→agent dispatches only; skill→skill dispatches like this loop's are constrained by the dispatching skill body itself.)

**What `validate-rewrite` must not do across passes.** Pass conversation context to the next pass's reviewer agent. Each pass dispatches a fresh `spec-cohesion-reviewer` Task subprocess with paths-only input — the fresh-eyes property in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/fresh-eyes-review.md` applies per pass, not just on the first pass.

**Failure mode if the contract drifts.** (a) The reviewer for pass N is given the prior pass's review or the loop's conversation context, contaminating fresh-eyes — caught by the dispatch-protocol convention and reviewer-agent paths-only invariant. (b) The dispatched `rewrite-specs` widens beyond the named findings and re-litigates the rewrite as a whole — caught by the next pass's reviewer flagging scope creep. (c) The loop runs without a max-passes ceiling and consumes turns indefinitely on a structurally unsolvable design — prevented by `MAX_REPAIR_PASSES` per the loop body in `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Repair loop".

## Off-chain re-entry

Diagnostic skills produce findings that re-enter the chain at the appropriate skill. Re-entry is user-driven (the diagnostic recommends a next skill in its footer; the user invokes it). Off-chain re-entry verdicts also participate in `spec-cohesion-reviewer`'s lens-3 consistency checks (the verdict vocabulary is the same surface as the chain edges').

### review-codebase → brainstorm-design

When `review-codebase` returns Drifting or Incoherent with findings naming design-shape issues (wrong seams, missing concepts, structural drift from documented behavior), the appropriate next skill is `brainstorm-design` to propose a corrective direction. The review's `### Next` footer renders this recommendation per verdict.

### review-codebase → rewrite-specs

When `review-codebase` returns Drifting with findings naming spec-shape issues (docs claim behavior the code doesn't have, named invariants without enforcement) and the corrective direction is "make the docs match the code" (no genuine design choice required), the appropriate next skill is `rewrite-specs` directly without a fresh brainstorm.

### audit-substrate → rewrite-specs

When `audit-substrate` returns **Substrate gaps** with named missing artifacts (an invariant that should exist; a behavior matrix the branchy logic deserves), the natural next skill is `rewrite-specs` to author the missing substrate. No brainstorm needed — the audit identified what's missing.

### validate-rewrite → brainstorm-design (Design Incoherent re-entry)

When `validate-rewrite` returns **Design Incoherent**, the rewrite cannot be repaired in place — the chosen direction itself is unsound. The footer recommends `brainstorm-design` to surface a different option and re-enter the chain from earlier.

### validate-rewrite → brainstorm-design (Re-decide re-entry)

When `validate-rewrite` returns **Approved** but the user reads the Architectural reflection and judges the locked design unsound (the reflection's Harder-downstream or Load-bearing-on-memory bullets reveal a structural problem the brainstorm missed), the user picks the **Re-decide** alternative from the Approved trailer's `Other options` disclosure (rendered when the reflection's bullets identify a specific structural concern, per `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Conditional alternatives"). This is distinct from Design Incoherent: the rewrite *did* lock coherently — the spec-cohesion-reviewer found no Blocker/High issues — but the user's architectural judgment after reading the reflection says the chosen direction has costs that weren't visible at brainstorm time. The reviewer can't catch this; only the user can, because it's a judgment on whether the design's tradeoffs fit the user's future priorities.

**Artifact crossing.** The discarded brainstorm's `## Direction` block (chosen direction summary) plus the Architectural reflection bullets from the discarded `validate-rewrite` Approved trailer (Harder-downstream + Load-bearing-on-memory). These cross the seam as `brainstorm-design`'s "What we already tried" optional input category (per `${CLAUDE_PLUGIN_ROOT}/skills/brainstorm-design/SKILL.md` §"Phase 1: Ground the brainstorm").

**Persistence.** The discarded design's worktree is either dropped (`git worktree remove --force`) or kept for reference; the discarded `design/<slug>` branch survives in git history. The brainstorm input itself is in-conversation, derived from the persisted artifacts (the discarded brainstorm file under `docs/history/brainstorms/` and the discarded validation review under `docs/history/reviews/`).

**Verdict gate.** **Approved + user override.** The verdict-floor mapping in `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Verdict → severity-floor mapping (validate-rewrite)" guarantees the Approved verdict is structurally merge-ready; the re-decide path is a user-driven override of the rubric's "merge-ready" framing on architectural-judgment grounds.

**What `brainstorm-design` must not re-derive.** The discarded direction. If the new round of options surfaces the same direction that was just discarded, either the reflection's concerns weren't real or the brainstorm isn't using the "What we already tried" input as bias. Either way, the result is a re-decide loop that converges to the same lock; cap at 2-3 cycles per the convention in `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Re-decide acknowledgment" — beyond that, the user has to commit to a direction or cut scope rather than continuing to brainstorm.

**Failure mode if the contract drifts.** (a) The brainstorm runs without the "What we already tried" input and re-derives the discarded path — caught by reviewer attention plus the cap on cycles. (b) The user picks Re-decide on every Approved verdict reflexively, never letting any direction land — caught by the cap; if the cap is hit, the recommendation is to commit or cut scope, not to brainstorm again. (c) The re-decide acknowledgment line (per validate-rewrite SKILL.md) is omitted, so the user enters a re-decide cycle without the substrate inputs flowing — caught by reviewer attention on subsequent passes' brainstorm output (the new options should visibly engage with the discarded direction's concerns).

### review-diff → out of chain

`review-diff` operates on a PR or working changes. Its findings re-enter the user's git workflow (fix the PR), not the Cohesive chain. The footer recommends specific fixes; the user makes them.

## Chain exits (implement-cohesively terminal verdicts)

`implement-cohesively` is the chain's terminal skill. It returns one of four verdicts; each routes to a different downstream action. These are not chain transitions (no Cohesive skill consumes them as a prereq verdict) but they are part of the chain-edge contract that `spec-cohesion-reviewer` lens 14 verifies for parity with the SKILL.md vocabulary.

### implement-cohesively → finishing-a-development-branch (Implemented)

**Verdict gate.** **Implemented** — every phase's `delta-coverage-reviewer` returned Covered, the final `cohesive:review-diff` returned Pass or Pass with notes, and Phase 3.5 has produced the ephemeral-cleanup commit. The branch is ready to merge with main's tree carrying only durable decision records.

**Artifact crossing.** The branch (with Phase 3.5 cleanup commit at HEAD) + the cleanup commit SHA, surfaced in the trailer's Branch state slot. Phase 3.5 strips ephemeral artifacts via `git rm` and produces a commit whose body lists removed paths verbatim; the verbatim list is the breadcrumb for forensic recovery via `git log --all -- <pattern>`. See `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md` §"Phase 3.5. Strip implementation scaffolding".

**Downstream skill.** `superpowers:finishing-a-development-branch` (recommended, not invoked — branch finishing is a user action per the Cohesive↔Superpowers seam in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md`).

**What the downstream must not re-derive.** The implementation's substrate alignment (the Implemented verdict is the substrate-side check). The downstream also must not undo the Phase 3.5 cleanup — ephemeral artifacts are intentionally absent from the post-cleanup tree.

**Failure modes.** (a) Auto-invocation of branch finishing instead of recommending it — caught by structure-reviewer as a Cohesive↔Superpowers seam violation. (b) Phase 3.5 doesn't fire on Implemented (run scaffolding leaks into main) or fires on a non-Implemented verdict (artifacts load-bearing for the next attempt are stripped) — both caught by Hard constraint #6 in the skill body and by structure-reviewer attention on merged branches.

### implement-cohesively → implement-cohesively resume (Phase Drift)

**Verdict gate.** **Phase Drift** — a per-phase `delta-coverage-reviewer` returned Drift or Incomplete after one repair cycle (the Phase 2c escalation rule per `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md`).

**Downstream skill.** `cohesive:implement-cohesively` (resume) — the user repairs the flagged phase by hand or via a focused `superpowers:writing-plans` repair plan, then re-invokes `implement-cohesively` which picks up at the failed phase.

**What the downstream must not re-derive.** The phase derivation table from Phase 1. Resuming does not re-derive phases; it picks up from the recorded coverage state.

**Failure mode if the contract drifts.** Resumption re-derives phases from scratch and produces a different phase ordering, decoupling commit history from the per-phase plans. Detection: per-phase commit messages cite plan paths and stable IDs (`IMPLEMENTATION_PLAN_COVERS_DELTA`); a re-derivation that breaks that grep auditing is the symptom.

### implement-cohesively → rewrite-specs (Substrate Drift)

**Verdict gate.** **Substrate Drift** — the final `cohesive:review-diff` returned Needs substrate, Risky, or Block; the implementation introduced behavior not covered by the rewrite, or invariant violations that aren't repairable in code alone.

**Downstream skill.** `cohesive:rewrite-specs` — extend the rewrite to cover the implementation that landed (and re-validate), or revert the divergent code (and re-implement).

**What the downstream must not re-derive.** The original approved direction. The Substrate Drift verdict means the rewrite was incomplete, not that the chosen direction was wrong; the repair extends scope rather than reopening design.

**Failure mode if the contract drifts.** User reverts the implementation without extending the rewrite, leaving the substrate gap that produced the drift unaddressed; the next implementation pass repeats the drift. Detection: validate-rewrite on the repaired rewrite shows the drifted entries are now covered by the ledger; `delta-coverage-reviewer` on the next implementation pass returns Covered.

### implement-cohesively → out of chain (Aborted)

**Verdict gate.** **Aborted** — the user stopped the implementation pass before completion (e.g., scope reassessment, external blocker). No downstream Cohesive skill applies.

**Downstream skill.** None. The branch state is whatever the last successful phase committed; the user decides whether to discard the worktree, leave it for later, or invoke `cohesive:rewrite-specs` to reduce scope before resuming.

**What the downstream must not re-derive.** N/a — Aborted is a leave-the-state-as-is verdict.

**Failure mode if the contract drifts.** The skill auto-recovers (resumes phases unsolicited) when the user explicitly stopped. Detection: implement-cohesively's Phase 2c escalation rule explicitly stops at Phase Drift; Aborted is a user action surfaced to the user, not an internal recovery state.

## Post-implementation review entry point

Some implementation paths land code outside `cohesive:implement-cohesively`'s phase loop — the Approved-trailer bypass option (`superpowers:writing-plans` directly), a teammate writing code against a Cohesive-locked design, or an external tool (an autonomous agent, a code-generation pipeline) producing a branch claimed to match the locked design. In all three cases, the question "does the code match the locked design?" still needs an answer; the entry point for that answer is **`cohesive:review-diff` against the branch with the delta-ledger path as scope**.

This is not a new skill — `review-diff` already exists and dispatches the substrate-alignment-reviewer + structure-reviewer agents against a diff. What this section does is name the *pattern* connecting a Cohesive-locked design to a non-Cohesive implementation, so future readers know where the verification entry point is when the implementation didn't run through `implement-cohesively`'s Phase 3.

### Pattern: post-implementation review against a locked design

**Trigger conditions** (any one fires the pattern):

- The user picked the **Implement with Superpowers directly** alternative in `cohesive:validate-rewrite`'s Approved trailer (rendered when the rewrite is small enough that the phased loop would be ceremony, per `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Conditional alternatives"), code landed via `superpowers:writing-plans`, and the user wants to know if the implementation drifted from the rewrite.
- A teammate (or a non-Cohesive AI session) landed a branch claimed to implement a `design/<slug>` rewrite, and the user wants to verify before merge.
- An external tool produced a branch matching a Cohesive-locked delta ledger and the user is the human-in-the-loop verifier.

**Artifact crossing.** Branch (the implementation under review) + design delta ledger path (the locked design being verified against) + optional substrate discovery report path (for context on the surrounding substrate).

**Skill invoked.** `cohesive:review-diff` with scope set to the branch and the delta ledger explicitly named in the invocation. The skill's Phase 1 substrate-discovery (scoped to changed files) runs as usual; the delta ledger becomes a primary input to the dispatched substrate-alignment-reviewer alongside the normative substrate the discovery surfaces.

**Verdict gate.** Same vocabulary as `review-diff`'s normal verdicts: **Pass** / **Pass with notes** / **Needs substrate** / **Risky** / **Block**. The user-facing labels translate per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` §"review-diff".

**Where this is recommended in chat.** Two surfaces name this pattern:

1. The bypass-acknowledgment line in `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Bypass acknowledgment" carries the imperative: "Run `cohesive:review-diff` after implementation to catch any drift."
2. The Approved trailer's `Implement with Superpowers directly` alternative — conditionally rendered when its triggering condition fires — carries the same imperative in its why-line.

**What `review-diff` must not re-derive.** The locked design. The reviewer reads the delta ledger as the design's executive summary; re-deriving design intent from the implementation is exactly what this pattern exists to catch (the implementation that drifts produces design "intent" that contradicts the ledger).

**Failure mode if the pattern drifts.** The user picks the bypass option, lands code, and merges without running `review-diff` — drift accumulates silently and the next architecture review catches it as substrate drift. Detection: the bypass-acknowledgment line is the substrate's explicit reminder; if the line is absent from the conversation transcript when implementation landed via the bypass path, the convention has been violated.

This pattern is **not** a chain edge. The chain edge `validate-rewrite → implement-cohesively (Approved branch)` is the canonical path; this pattern is the named recovery for the off-canonical paths.

## What this doc does not cover

- **Router dispatches** (user input → first chain skill). See `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md`.
- **Cohesive↔Superpowers seams** (Cohesive skill → Superpowers skill, internal to a phase loop). See `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md`.
- **Within-skill process steps.** A skill's internal steps live in the SKILL.md body, not here.
- **Convention-shape.** What every SKILL.md must look like is in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md`.
- **Substrate primitive contracts.** What an invariant or matrix file must contain is in the relevant template at `${CLAUDE_PLUGIN_ROOT}/references/templates/`.

## Adding a new chain skill or re-entry edge

The canonical entry point for adding a new skill is `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md` §"Adding a new skill" — its sequence drives all five substrate updates. This section's steps are subsumed by that sequence; follow the skills.md sequence and return here only when the skill genuinely is *not* a new chain participant (e.g., a new diagnostic skill that produces its own re-entry edges without new chain transitions). For non-chain skills (a new router shape, a new session-start orientation skill, or any addition outside the linear chain), follow skills.md Step 2's reference back to §"The five transition shapes" in this doc as the authoritative transition vocabulary, then add the skill's inbound/outbound contract under "Per-handoff contracts" naming the matching transition shape.

For pure handoff-contract changes that don't add a skill (e.g., adding a re-entry edge, adjusting a verdict gate, refining a must-not-re-derive clause):

1. Add or modify the per-handoff contract section here (artifact, persistence, verdict gate, must-not-re-derive, failure mode).
2. Update the chain diagram in §"The chain" if topology changes.
3. Update `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md` if the change touches router-dispatched verdicts.

The contract sections are normative. Drift between this doc and SKILL.md bodies is what `spec-cohesion-reviewer` watches for during `validate-rewrite` — specifically lens 14 (handoff contract consistency), which verifies the named verdict gate appears identically in the upstream SKILL.md's verdict vocabulary, the downstream SKILL.md's prereq check, and `router.md`'s dispatch contract row if router-dispatchable. Lens 14 covers gate verdicts only; non-gating terminal verdicts (the `Aborted` shape) are covered by lens 13 in `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md`.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md` — per-skill design layer; what each skill is for.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md` — user input → route mapping; dispatch-prompt-contract grid.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md` — internal implementation-phase seams.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/no-implementation-handoff.md` — the failure mode the chain edge to `implement-cohesively` closes.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md` — the failure mode router prereq-passing closes.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` — the named invariant pinning the chain edge to `implement-cohesively`.
