# Skills

> Cohesive ships nine skills. They form one chain (`discover-substrate → brainstorm-design → rewrite-specs → validate-rewrite → implement-cohesively`), three off-chain diagnostics (`review-codebase`, `review-diff`, `audit-substrate`), and one router (`cohesively`). This doc is the per-skill design layer: what each skill is for, why the set has these skills and not others, and what each owns versus delegates. The SKILL.md body under `${CLAUDE_PLUGIN_ROOT}/skills/<name>/` is the implementation prompt; the section here is the substrate above it.

## Skill set at a glance

| Skill | Role | Owns | Output verdict |
|---|---|---|---|
| **Chain** | | | |
| `discover-substrate` | Inventory existing substrate; flag missing memory | Substrate read; gap surfacing | _none (utility)_ |
| `brainstorm-design` | Convert intent into chosen direction | Pressure-testing options against substrate | _none (user approves)_ |
| `rewrite-specs` | Hard-rewrite docs to end state | Spec rewrite + delta ledger | _none (validate-rewrite verdicts)_ |
| `validate-rewrite` | Fresh-eyes review of the rewrite | Coherence, completeness, enforceability check | Approved / Issues Found / Design Incoherent |
| `implement-cohesively` | Land code that makes the rewrite true | Phase derivation; per-phase cross-review | Implemented / Phase Drift / Substrate Drift / Aborted |
| **Off-chain** | | | |
| `review-codebase` | Architecture-altitude cohesion review | Multi-reviewer dispatch + synthesis | Healthy / Mostly healthy / Cohesive but under-enforced / Spec drift risk / Architecture risk |
| `review-diff` | Cohesion review of a PR or working changes | Two-reviewer dispatch on bounded surface | Pass / Pass with notes / Needs substrate / Risky / Block |
| `audit-substrate` | Find missing memory | Single-pass scan; no reviewer dispatch | Substrate sound / Substrate gaps / Substrate sparse |
| **Router** | | | |
| `cohesively` | Convert intent into the right route | Route selection; prereq-state passing | _none (announces, dispatches)_ |

## What every Cohesive skill is

Three properties define a Cohesive skill.

1. **Substrate-shape, not implementation-shape.** Skills work against specs, behavior matrices, named invariants, gotchas, and design docs. The only skill that produces code is `implement-cohesively`, which composes `superpowers:executing-plans` per phase rather than writing code directly.
2. **Verdict-led where applicable.** Reviewing skills lead chat output with `**Verdict:**` from a controlled vocabulary. Workflow skills hand off via verdicts that gate downstream skills. Verdicts are how the chain knows what state it's in.
3. **Fresh-eyes-when-reviewing.** Skills that dispatch reviewers do so via Task subprocess with no inherited conversation context. The structural fence is the harness's subprocess isolation — see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/fresh-eyes-review.md`.

A skill that violates any of these is mis-tiered — it's either not a Cohesive skill or it belongs in a different tier (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/three-tier-architecture.md`).

## Why these skills, not others

The skill set is the answer to several deliberate cuts. Each entry below explains why a plausible alternative isn't a Cohesive skill.

**Why `audit-substrate` is separate from `discover-substrate`.** Discovery inventories what's there to inform downstream chain skills. Audit judges whether what's there is sufficient and produces a verdict the user acts on. Different output shape, different consumer, different lifecycle. Collapsing them would force every discovery call to verdict, which most chain calls don't want.

**Why `validate-rewrite` is separate from `rewrite-specs`.** Fresh-eyes review is structurally impossible inside the skill that produced the artifact under review — the rewriter and the reviewer cannot share context without breaking the fence. The seam is load-bearing, not aesthetic.

**Why there is no `synthesize-design` between `brainstorm-design` and `rewrite-specs`.** The design pressure-test battery in `brainstorm-design` produces a chosen direction; that direction is the synthesis. A separate skill would split a coherent decision into two skill turns and add a verdict the user has to pass twice.

**Why `cohesively` is a router, not a workflow.** A meta-skill that internally calls every step would hide phase transitions. Cohesive treats user-driven phase transitions as a feature: the user sees what's running, decides whether to continue, and can re-enter at any point. The router announces a route and dispatches; the chain runs as a sequence of legible turns.

**Why `implement-cohesively` exists rather than handing off to `superpowers:writing-plans` directly.** The failure mode in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/no-implementation-handoff.md`: without a substrate-shaped phase loop, freeform code follows by default and bypasses the substrate the rewrite established. Cohesive owns the phase derivation (delta ledger → per-phase intent) and the per-phase cross-review (delta-coverage-reviewer); Superpowers owns plan-writing and TDD execution inside each phase. See `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md`.

**Why `review-codebase` and `review-diff` are two skills, not one with a `--scope` flag.** Different reviewer panels (4 reviewers vs 2), different rubrics (architecture-review-rubric vs cohesion-rubric), different output shapes (persisted report vs chat-only verdict). The shared concept is "fresh-eyes review against substrate"; the executions diverge enough that one skill body would be a configuration-laden mess.

## Per-skill sections

Each section follows the same shape: Purpose, Owns, Does not own, Inputs, Outputs, Why this shape. Sections are ordered by chain position, then off-chain, then router. The section heading is `### <skill-name>` matching the directory name under `${CLAUDE_PLUGIN_ROOT}/skills/`; this is the regex target for the named invariant `SKILL_DESIGN_DOC_SECTION` (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md`).

### Bootstrap status

The per-skill design layer was authored retroactively against existing SKILL.md bodies during the 2026-05-05 architecture refactor. Every section in this doc started life as a *claim* about what the SKILL.md said, not a *spec* the SKILL.md was authored against. Sections earn **validated** status when a `cohesive:rewrite-specs` pass on that skill's purpose, ownership, or seams has run *with the design layer as prior substrate* — confirming that the skills.md claim and the SKILL.md body agree under fresh-eyes review.

| Section | Status | Notes |
|---|---|---|
| `discover-substrate` | inherited | not yet validated against a forward rewrite |
| `brainstorm-design` | inherited | not yet validated against a forward rewrite |
| `rewrite-specs` | **validated** | the architecture refactor itself touched its SKILL.md (Step 1a addition); spec-cohesion-reviewer lens 13 confirmed parity through repair-pass-3 |
| `validate-rewrite` | inherited | not yet validated; verdict vocabulary verified verbatim during repair pass 1 (B2) |
| `implement-cohesively` | **validated** | validated by the 2026-05-05 review-diff repair pass; verdict vocabulary reconciled to four terminals (`Implemented / Phase Drift / Substrate Drift / Aborted`) |
| `review-codebase` | inherited | not yet validated against a forward rewrite |
| `review-diff` | inherited | not yet validated against a forward rewrite |
| `audit-substrate` | inherited | not yet validated against a forward rewrite |
| `cohesively` | inherited | not yet validated against a forward rewrite |

Inherited sections may surface lens-2 (design-implementation agreement) and lens-14 (handoff contract consistency) drift on the first forward rewrite that touches them — this is the predicted bootstrap drift, not a defect of the inherited section. `spec-cohesion-reviewer` reads this table during dispatch (the agent's input set includes this doc) and applies extra skepticism to inherited-status sections. When a section earns validated status, update the row in the same delta ledger that triggered the validation.

### discover-substrate

**Purpose.** Read the codebase's existing substrate (specs, behavior matrices, named invariants, gotchas, semantic linters, CI checks, local commands) for a given change surface, and surface what's missing.

**Owns.**
- Reading existing substrate, including external-repo conventions (`docs/adr/`, `docs/specs/`, `docs/design/`, etc.).
- Producing the substrate discovery report that downstream skills consume.
- Surfacing gaps: implicit rules, branchy behavior without matrices, invariants without enforcement, scars trapped in comments.

**Does not own.**
- Verdicting whether the substrate is sufficient — that's `audit-substrate`.
- Proposing changes to the substrate — that's `brainstorm-design` (forward) or `rewrite-specs` (after a direction is chosen).
- General codebase exploration — that's Superpowers' research/exploration. Cohesive's discovery is *substrate-specific*. See `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/discovery-vs-superpowers.md`.

**Inputs.** A change surface (subsystem name, file path, or "the whole codebase" for review uses). No prereq.

**Outputs.** Substrate discovery report. No verdict.

**Why this shape.** Discovery is the prereq for every other chain skill. Making it a no-verdict utility lets multiple downstream skills consume the same report. A verdict here would force every consumer to dispatch on it; the consumers' own verdicts are what the chain actually acts on.

### brainstorm-design

**Purpose.** Convert the user's intent (forward pressure: "should we do X?") into a chosen design direction grounded in the substrate the codebase already has, after pressure-testing the candidate options against named criteria.

**Owns.**
- Reading the substrate discovery report to ground proposals.
- Producing 2-4 design options with named tradeoffs.
- Pressure-testing each option through the design-pressure-testing rubric (see `${CLAUDE_PLUGIN_ROOT}/references/design-pressure-testing.md`).
- Recommending one option and surfacing remaining ambiguity for the user to resolve.

**Does not own.**
- Writing the rewrite — that's `rewrite-specs` after a direction is approved.
- Implementation — that's `implement-cohesively`.
- Producing code, even illustrative snippets. The skill output is design-shape only.

**Inputs.** User intent + substrate discovery report (passed by router or freshly invoked).

**Outputs.** Approved direction (option name, summary paragraph, named main risk, structural mitigation). User-approved; no automated verdict.

**Why this shape.** The design choice is the load-bearing decision of the chain. Pressure-testing before approval is what makes the rewrite worth running; without it, `rewrite-specs` writes specs against a half-pressured direction and `validate-rewrite` finds incoherence. The skill exists to *spend more turns on design* rather than rushing to specs.

### rewrite-specs

**Purpose.** Hard-rewrite affected design docs, specs, behavior matrices, invariants, and gotchas to describe the chosen direction's end state in present-tense, normative language. Produce a design delta ledger documenting every change.

**Owns.**
- Identifying the doc surface to rewrite, add, remove, or leave alone.
- Classifying the rewrite as Pure implementation / Design / Mixed in the delta ledger preamble.
- Replacing obsolete claims with end-state language; never appending "(deprecated)" alongside new claims.
- Producing the design delta ledger at `docs/history/delta-ledgers/<date>-<slug>.md` per the canonical template.
- Working in a `design/<slug>` worktree (loose composition with `superpowers:using-git-worktrees`).

**Does not own.**
- Re-litigating the chosen direction. That's `brainstorm-design`.
- Reviewing the rewrite. That's `validate-rewrite`.
- Implementation. The rewrite describes the end state; code follows in `implement-cohesively`.

**Inputs.** Approved direction + substrate discovery report.

**Outputs.** Rewritten docs in place + design delta ledger. No verdict on this edge — `validate-rewrite` produces the verdict.

**Why this shape.** The hard rewrite (versus annotation) is what makes the rewrite cheap to validate: the reviewer sees one coherent end state, not a delta layered over deprecated text. The delta ledger gives the reviewer an executive summary so the validation isn't a re-read of the entire repo. The Pure/Design/Mixed classification routes design pressure to the design layer (`${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md` and `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md`) before the SKILL.md body.

### validate-rewrite

**Purpose.** Fresh-eyes review of the rewrite produced by `rewrite-specs`. Judges whether the rewritten specs and delta ledger describe a coherent, behaviorally complete, enforceable system that aligns with the codebase's stated future direction. On `Issues Found`, drives an internal repair loop with `rewrite-specs` until verdict converges (Approved), exits to design (Design Incoherent), or stalls at `MAX_REPAIR_PASSES`.

**Owns.**
- Dispatching `spec-cohesion-reviewer` in a Task subprocess with no inherited context — once per pass, fresh eyes preserved across passes.
- Returning one of three verdicts: **Approved**, **Issues Found**, **Design Incoherent**.
- The internal repair loop: on Issues Found, dispatching `rewrite-specs` in repair mode via the Skill tool, persisting the per-pass review, and re-dispatching the reviewer for the next pass — up to `MAX_REPAIR_PASSES` (default 5).
- Rendering the per-verdict decision matrix on terminal verdicts (Approved → implementation options; Design Incoherent → re-brainstorm; max-passes stall → user direction).

**Does not own.**
- Re-reading the brainstorm output. The reviewer reads only the rewritten specs and the delta ledger.
- Proposing fixes. The reviewer surfaces issues; the loop's dispatched `rewrite-specs` produces the repairs.
- Implementation. Approved gates `implement-cohesively`; the verdict does not itself produce code.
- Loop-internal user prompts. The user does not invoke `rewrite-specs` themselves during the loop except after a max-passes stall or a Design Incoherent exit.

**Inputs.** Design delta ledger path + rewritten spec paths. Optional: `--max-passes=N` to override the default ceiling.

**Outputs.** Per-pass validation reviews at `docs/history/reviews/<date>-<slug>-rewrite-validation[-pass-N].md`; the terminal-pass review is the one consumed by `implement-cohesively` (Approved) or surfaced for user direction (Design Incoherent / max-passes stall). Verdict vocabulary: {Approved, Issues Found, Design Incoherent}; "Issues Found" only escapes the loop on max-passes stall.

**Why this shape.** Fresh-eyes is structurally load-bearing — collapsing review into the rewriting skill defeats the property. The three-verdict vocabulary maps to three downstream actions: Approved → implement; Issues Found → re-rewrite (handled internally by the loop); Design Incoherent → re-brainstorm (user-driven, because design-shape problems aren't loop-repairable). The internal loop reflects how the skill is actually used in practice (Issues Found → repair → re-validate iterated manually until convergence); automating it removes ceremony without changing the workflow shape, and the `MAX_REPAIR_PASSES` ceiling prevents wack-a-mole on structurally unsolvable designs.

### implement-cohesively

**Purpose.** Land code that makes the approved rewrite true, phase-by-phase against the design delta ledger, with per-phase cross-review for delta coverage.

**Owns.**
- Deriving phases from the design delta ledger per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/phase-derivation.md`.
- Per-phase composition: `superpowers:writing-plans` (plan) → `superpowers:executing-plans` (TDD execution) → `delta-coverage-reviewer` (cross-review).
- Returning one of four terminal verdicts: **Implemented** (substrate and code agree; hand off to `superpowers:finishing-a-development-branch`), **Phase Drift** (a per-phase cross-review failed after one repair cycle; resume `implement-cohesively`), **Substrate Drift** (final `cohesive:review-diff` flagged drift; route to `cohesive:rewrite-specs` to extend or revert), **Aborted** (user stopped before completion; no downstream skill).
- Running `cohesive:review-diff` against the branch as the final substrate check.

**Does not own.**
- Writing code directly. Code is produced by `superpowers:executing-plans` inside the phase loop.
- Per-phase plan authoring. That's `superpowers:writing-plans`.
- Branch finishing. Recommended (not invoked) after Implemented verdict; user runs `superpowers:finishing-a-development-branch`.

**Inputs.** Validate-rewrite Approved verdict + design delta ledger path + branch name.

**Outputs.** Code committed phase-by-phase + per-phase plans persisted + final verdict. The named invariant `IMPLEMENTATION_PLAN_COVERS_DELTA` pins delta coverage across the phase loop.

**Why this shape.** The skill exists because the gap between "specs approved" and "code shipped" is where substrate is most easily abandoned (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/no-implementation-handoff.md`). The phase loop with delta-coverage cross-review converts a freeform implementation into a structured one without Cohesive owning code-writing.

### review-codebase

**Purpose.** Architecture-altitude cohesion review of a whole codebase or named subsystem. Judges whether the implementation agrees with the docs, whether invariants are enforced structurally, whether seams are in the right places, and whether a future agent can change the code with bounded context.

**Owns.**
- Phase 1 (claimed system shape) reading the docs the codebase normatively claims.
- Phase 2 (spec-prior gate) — stops if specs are seriously inconsistent.
- Phase 3 dispatching four reviewer agents in parallel (`substrate-alignment-reviewer`, `structure-reviewer`, `library-native-reviewer`, `agent-readiness-reviewer`).
- Phase 4 synthesizing reviewer outputs into a thesis-led report.
- Producing the persisted architecture review.

**Does not own.**
- Reviewing diffs — that's `review-diff`.
- Substrate gap-finding — that's `audit-substrate`.
- Proposing fixes structurally. Findings name issues; remediation is back into the chain via `brainstorm-design` or `rewrite-specs`.

**Inputs.** Codebase or subsystem scope.

**Outputs.** Persisted architecture review carrying one of {Healthy, Mostly healthy, Cohesive but under-enforced, Spec drift risk, Architecture risk}.

**Why this shape.** Whole-codebase review needs the four-reviewer panel to cover the lenses (alignment, structure, library-native, agent-readiness) without a single reviewer's blind spot dominating. The four-phase structure (claimed shape → spec-prior gate → reviewer dispatch → synthesis) makes each phase legible and stoppable.

### review-diff

**Purpose.** Cohesion review of a PR, branch, or working changes. Lighter than `review-codebase`; bounded surface; rendered in chat rather than persisted.

**Owns.**
- Diff acquisition (`gh pr diff`, `git diff main...HEAD`, or working changes).
- Dispatching two reviewer agents (`substrate-alignment-reviewer`, `structure-reviewer`) in parallel; expanding to four for very large diffs.
- Rendering the verdict with thesis + top findings in chat.

**Does not own.**
- Persisted reports. The output is chat-only.
- Whole-codebase concerns. The reviewer reads only the diff and the substrate it touches.
- General code review for implementation quality. That's `superpowers:code-reviewer`. Cohesive reviews substrate-shape; Superpowers reviews implementation-shape.

**Inputs.** PR number, branch name, or working changes.

**Outputs.** Chat-only verdict-led output: {Pass, Pass with notes, Needs substrate, Risky, Block}.

**Why this shape.** Diff review is high-frequency (every PR); persistence would create review noise. Two reviewers cover most diffs cleanly; the four-reviewer panel is reserved for diffs that warrant whole-codebase reasoning.

### audit-substrate

**Purpose.** Find missing memory in a codebase — implicit rules, branchy behavior without matrices, invariants without enforcement, scars trapped in comments, stale docs. Single-pass scan; no reviewer-agent dispatch.

**Owns.**
- Reading the codebase for substrate signals.
- Producing the audit report listing missing-substrate findings.
- Returning a verdict on substrate health.

**Does not own.**
- Cohesion review or architecture-altitude judgment. That's `review-codebase`.
- General codebase exploration. Cohesive's audit is *substrate-specific*.
- Authoring missing substrate. The audit names what's missing; `rewrite-specs` writes it.

**Inputs.** Codebase or subsystem scope.

**Outputs.** Persisted audit report carrying one of {Substrate sound, Substrate gaps, Substrate sparse}.

**Why this shape.** Audit is lighter than `review-codebase` because it doesn't need the four-reviewer panel — gap-finding is a single-lens question ("is the memory there?"). Keeping it separate from `discover-substrate` lets discovery stay no-verdict.

### cohesively

**Purpose.** Convert user intent into one of seven canonical routes (`design`, `review (codebase)`, `review (diff)`, `audit (substrate)`, `rewrite-only`, `implement`, `artifact`), announce the route, and dispatch the chain's first subskill with prereq state passed explicitly.

**Owns.**
- Route selection per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md` cells R001-R016.
- Announcement of the chosen route in canonical form before any tool call.
- Prereq-state and chosen-direction passing per the dispatch-prompt-contract grid in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md`.

**Does not own.**
- Workflow execution — each subskill runs its own process.
- Phase transitions within a route — those are user-driven, not auto-routed.
- Direct invocation of Superpowers — the `implement` route dispatches `cohesive:implement-cohesively`, which composes Superpowers internally.

**Inputs.** User intent (any natural-language request).

**Outputs.** Canonical announcement sentence + first subskill dispatch. No persisted artifact, no verdict.

**Why this shape.** A router rather than a workflow, because phase transitions are user-driven by design. A workflow router would hide what's running and remove the user's ability to re-enter the chain at any point. The canonical announcement makes the routing decision legible; the prereq-passing closes `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md`.

## Adding a new skill

When the brainstorm pressure surfaces a new skill, the change touches three docs *before* the SKILL.md is authored:

1. **`${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md`** (this doc) — add the per-skill section, add a row in the at-a-glance table, add the "why this skill, not a mode of X" entry under §"Why these skills, not others".
2. **`${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md`** — add the inbound and outbound handoff contracts.
3. **`${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md`** — if the skill is router-dispatchable, add a cell with stable ID and update the dispatch-prompt-contract grid.

Only after all three are updated does `skills/<name>/SKILL.md` get authored. The named invariant `SKILL_DESIGN_DOC_SECTION` (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md`) enforces that every directory under `skills/` has a `### <name>` section here, mechanically greppable by `scripts/validate_plugin.sh`.

## Section growth policy

A per-skill section that grows past ~80 lines is signaling the skill's design has earned its own file. At that point, extract to `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills/<name>.md` and replace the section here with a one-paragraph stub linking out. Don't pre-extract; let the pressure surface. The validator's grep target moves from `^### <name>$` in this doc to file existence at the extracted path; the named invariant survives the shape change.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` — what crosses each chain seam.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/three-tier-architecture.md` — why skills are separated from agents and references.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md` — what implementation-shaped work Cohesive delegates.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/fresh-eyes-review.md` — the structural property reviewer-dispatching skills depend on.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md` — input → route mapping; dispatch-prompt-contract.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` — the canonical SKILL.md body shape every skill follows.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md` — the named invariant pinning per-skill section presence.
