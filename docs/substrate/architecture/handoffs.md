# Skill handoffs

> Every Cohesive transition is one of three shapes: a chain transition (verdict-gated, artifact-carrying), a router dispatch (`cohesively` → subskill, with prereq state), or off-chain re-entry (a review or audit finding back into the chain). This doc enumerates chain transitions and re-entry edges. Router dispatches live in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md`; Cohesive↔Superpowers seams live in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md`.

## The three transition shapes

**1. Chain transition.** A skill produces an artifact carrying a verdict (or no verdict, in which case user approval gates the transition). The downstream skill consumes that artifact and runs. Five forward chain transitions form the linear chain; one transition (Issues Found) is a backward edge from `validate-rewrite` to `rewrite-specs`.

**2. Router dispatch.** `cohesively` selects a route and dispatches the first subskill of that route, passing prereq state and chosen-direction state explicitly per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md` §"Dispatch prompt contract". The router does not own the chain; it owns the entry point.

**3. Off-chain re-entry.** A diagnostic skill (`review-codebase`, `review-diff`, `audit-substrate`) produces findings that re-enter the chain at the appropriate skill. Re-entry is user-driven — the diagnostic recommends a next Cohesive skill in its output footer; the user invokes it. The Design Incoherent verdict from `validate-rewrite` is also treated as off-chain re-entry because it returns further back than the immediate predecessor (to `brainstorm-design`, not to `rewrite-specs`).

## The chain

```
discover-substrate ──▶ brainstorm-design ──▶ rewrite-specs ──▶ validate-rewrite ──▶ implement-cohesively
                                                       ▲                      │
                                                       └──── Issues Found ────┘
```

Forward chain: four edges. Backward edge: Issues Found returns to `rewrite-specs` for repair. Design Incoherent returns further back to `brainstorm-design` (treated as off-chain re-entry — see §"Off-chain re-entry").

## Per-handoff contracts

Each handoff specifies: artifact crossing the seam, persistence shape, verdict gate (if any), what the downstream must not re-derive, and the failure mode if the contract drifts.

### discover-substrate → brainstorm-design

**Artifact crossing.** Substrate discovery report.

**Persistence.** Chat or persisted (caller's choice). When `cohesively` dispatches the `design` route, the report is passed via the dispatch prompt; when invoked directly, the report renders in chat.

**Verdict gate.** None. Discovery is a no-verdict utility.

**What `brainstorm-design` must not re-derive.** The substrate inventory. The brainstorm reads the discovery report as input; re-discovering wastes a turn and produces an inventory that may diverge from the report.

**Failure mode if the contract drifts.** Brainstorm produces options grounded in a re-derived inventory; the inventory disagrees with the report; the user sees two substrate views and can't tell which is canonical. Detection: `spec-cohesion-reviewer` flags substrate-claim divergence during `validate-rewrite`.

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

### validate-rewrite → rewrite-specs (Issues Found backward edge)

**Artifact crossing.** Validation review carrying Issues Found verdict + the specific blocking issues named in the review body.

**Persistence.** Validation review persisted; the specific issues are body content.

**Verdict gate.** **Issues Found** required. The repair pass `rewrite-specs` consumes the issue list as its rewrite scope.

**What the repair `rewrite-specs` must not re-derive.** The brainstormed direction. The repair fixes specs against a still-approved direction; if the direction itself is unsound, that's Design Incoherent, not Issues Found.

**Failure mode if the contract drifts.** Repair pass widens beyond the named issues and re-litigates the rewrite as a whole; subsequent `validate-rewrite` has nothing to anchor against; the repair loop consumes turns without converging.

## Off-chain re-entry

Diagnostic skills produce findings that re-enter the chain at the appropriate skill. Re-entry is user-driven (the diagnostic recommends a next skill in its footer; the user invokes it). Off-chain re-entry verdicts also participate in `spec-cohesion-reviewer`'s lens-3 consistency checks (the verdict vocabulary is the same surface as the chain edges').

### review-codebase → brainstorm-design

When `review-codebase` returns Drifting or Incoherent with findings naming design-shape issues (wrong seams, missing concepts, structural drift from documented behavior), the appropriate next skill is `brainstorm-design` to propose a corrective direction. The review's `### Recommended next Cohesive skill` footer renders this recommendation per verdict.

### review-codebase → rewrite-specs

When `review-codebase` returns Drifting with findings naming spec-shape issues (docs claim behavior the code doesn't have, named invariants without enforcement) and the corrective direction is "make the docs match the code" (no genuine design choice required), the appropriate next skill is `rewrite-specs` directly without a fresh brainstorm.

### audit-substrate → rewrite-specs

When `audit-substrate` returns Gaps Found with named missing artifacts (an invariant that should exist; a behavior matrix the branchy logic deserves), the natural next skill is `rewrite-specs` to author the missing substrate. No brainstorm needed — the audit identified what's missing.

### validate-rewrite → brainstorm-design (Design Incoherent re-entry)

When `validate-rewrite` returns **Design Incoherent**, the rewrite cannot be repaired in place — the chosen direction itself is unsound. The footer recommends `brainstorm-design` to surface a different option and re-enter the chain from earlier.

### review-diff → out of chain

`review-diff` operates on a PR or working changes. Its findings re-enter the user's git workflow (fix the PR), not the Cohesive chain. The footer recommends specific fixes; the user makes them.

## Chain exits (implement-cohesively terminal verdicts)

`implement-cohesively` is the chain's terminal skill. It returns one of four verdicts; each routes to a different downstream action. These are not chain transitions (no Cohesive skill consumes them as a prereq verdict) but they are part of the chain-edge contract that `spec-cohesion-reviewer` lens 14 verifies for parity with the SKILL.md vocabulary.

### implement-cohesively → finishing-a-development-branch (Implemented)

**Verdict gate.** **Implemented** — every phase's `delta-coverage-reviewer` returned Covered, the final `cohesive:review-diff` returned Pass or Pass with notes, and the branch is ready to merge.

**Downstream skill.** `superpowers:finishing-a-development-branch` (recommended, not invoked — branch finishing is a user action per the Cohesive↔Superpowers seam in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md`).

**What the downstream must not re-derive.** The implementation's substrate alignment. The Implemented verdict is the substrate-side check; finishing-a-development-branch handles merge mechanics.

**Failure mode if the contract drifts.** `implement-cohesively` auto-invokes branch finishing instead of recommending it; user loses the explicit hand-off and the branch merges without their final approval. Detection: structure-reviewer flags auto-invocation as a Cohesive↔Superpowers seam violation.

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

## What this doc does not cover

- **Router dispatches** (user input → first chain skill). See `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md`.
- **Cohesive↔Superpowers seams** (Cohesive skill → Superpowers skill, internal to a phase loop). See `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md`.
- **Within-skill process steps.** A skill's internal steps live in the SKILL.md body, not here.
- **Convention-shape.** What every SKILL.md must look like is in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md`.
- **Substrate primitive contracts.** What an invariant or matrix file must contain is in the relevant template at `${CLAUDE_PLUGIN_ROOT}/references/templates/`.

## Adding a new chain skill or re-entry edge

The canonical entry point for adding a new skill is `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md` §"Adding a new skill" — its sequence drives all four substrate updates. This section's steps are subsumed by that sequence; follow the skills.md sequence and return here only when the skill genuinely is *not* a new chain participant (e.g., a new diagnostic skill that produces its own re-entry edges without new chain transitions).

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
