# Skills

> Cohesive ships eleven skills. The user-facing model is **three gates: Decide → Lock → Build**, with subskills running underneath. The agent-internal subskill order is `discover-substrate → brainstorm-design` (Decide), `rewrite-specs → validate-rewrite` (Lock, repair loop internal), `implement-cohesively` (Build). Three off-chain diagnostics (`review-codebase`, `review-diff`, `audit-substrate`) sit alongside the gates. One adoption skill (`init`) is the day-1 entry point for codebases with no existing substrate. One router (`cohesively`) selects the route; one session-start orientation skill (`using-cohesive`) sits upstream of the router. This doc is the per-skill design layer: what each skill is for, why the set has these skills and not others, and what each owns versus delegates. The SKILL.md body under `${CLAUDE_PLUGIN_ROOT}/skills/<name>/` is the implementation prompt; the section here is the substrate above it.

## Skill set at a glance

The user-facing surface for the flagship workflow is the gate vocabulary (Decide / Lock / Build). The Gate column below tells contributors which gate a subskill runs under; subskill names themselves do not appear in user-facing chat-render surfaces (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md` §"Gate vocabulary is the user-facing chat-surface vocabulary").

| Skill | Gate | Role | Owns | Output verdict |
|---|---|---|---|---|
| `discover-substrate` | Decide (silent) | Inventory existing substrate; flag missing memory | Substrate read; gap surfacing | _none (utility)_ |
| `brainstorm-design` | Decide | Convert intent into chosen direction | Pressure-testing options against substrate | _none (user approves)_ |
| `rewrite-specs` | Lock | Hard-rewrite docs to end state | Spec rewrite + delta ledger | _none (validate-rewrite verdicts)_ |
| `validate-rewrite` | Lock | Fresh-eyes review + architectural reflection at the lock→build handoff | Coherence, completeness, enforceability check; reflection synthesizing how the architecture feels after the lock | Approved / Issues Found / Design Incoherent |
| `implement-cohesively` | Build | Land code that makes the rewrite true; verify spec-coverage | Phase derivation; per-phase cross-review; spec-coverage verdict | Implemented / Phase Drift / Substrate Drift / Aborted |
| `review-codebase` | _diagnostic_ | Architecture-altitude cohesion review | Multi-reviewer dispatch + synthesis | Healthy / Mostly healthy / Cohesive but under-enforced / Spec drift risk / Architecture risk |
| `review-diff` | _diagnostic_ | Cohesion review of a PR or working changes | Two-reviewer dispatch on bounded surface | Pass / Pass with notes / Needs substrate / Risky / Block |
| `audit-substrate` | _diagnostic_ | Find missing memory | Single-pass scan; no reviewer dispatch | Substrate sound / Substrate gaps / Substrate sparse |
| `init` | _adoption_ | First-time substrate from a zero-substrate codebase, with translations that teach the vocabulary | Proto-substrate scan + Rosetta Stone translation; bounded draft directory | _none (utility)_ |
| `cohesively` | _router_ | Convert intent into the right route | Route selection; prereq-state passing | _none (announces, dispatches)_ |
| `using-cohesive` | _orientation_ | Advise Claude when Cohesive applies | When-to-enter-Cohesive decision; advisory routing to `cohesively` | _none (advisory)_ |

## What every Cohesive skill is

Three properties define a Cohesive skill.

1. **Substrate-shape, not implementation-shape.** Skills work against specs, behavior matrices, named invariants, gotchas, and design docs. The only skill that produces code is `implement-cohesively`, which composes `superpowers:executing-plans` per phase rather than writing code directly.
2. **Verdict-led where applicable.** Reviewing skills lead chat output with `**Verdict:**` from a controlled vocabulary. Workflow skills hand off via verdicts that gate downstream skills. Verdicts are how the chain knows what state it's in.
3. **Fresh-eyes-when-reviewing.** Skills that dispatch reviewers do so via Task subprocess with no inherited conversation context. The structural fence is the harness's subprocess isolation — see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/fresh-eyes-review.md`.

A skill that violates any of these is mis-tiered — it's either not a Cohesive skill or it belongs in a different tier (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/three-tier-architecture.md`).

## Why these skills, not others

The skill set is the answer to several deliberate cuts. Each entry below explains why a plausible alternative isn't a Cohesive skill.

**Why `audit-substrate` is separate from `discover-substrate`.** Discovery inventories what's there to inform downstream chain skills. Audit judges whether what's there is sufficient and produces a verdict the user acts on. Different output shape, different consumer, different lifecycle. Collapsing them would force every discovery call to verdict, which most chain calls don't want.

**Why `validate-rewrite` is separate from `rewrite-specs`.** Fresh-eyes review is structurally impossible inside the skill that produced the artifact under review — the rewriter and the reviewer cannot share context without breaking the fence. The seam is load-bearing, not aesthetic. The internal repair loop preserves this seam — each pass dispatches a fresh `spec-cohesion-reviewer` Task subprocess with paths-only input, so the per-pass fresh-eyes property holds even though `validate-rewrite` and `rewrite-specs` now compose internally.

**Why there is no `synthesize-design` between `brainstorm-design` and `rewrite-specs`.** The design pressure-test battery in `brainstorm-design` produces a chosen direction; that direction is the synthesis. A separate skill would split a coherent decision into two skill turns and add a verdict the user has to pass twice.

**Why `cohesively` is a router, not a workflow.** A meta-skill that internally calls every step would hide phase transitions. Cohesive treats user-driven phase transitions as a feature: the user sees what's running, decides whether to continue, and can re-enter at any point. The router announces a route and dispatches; the chain runs as a sequence of legible turns.

**Why `implement-cohesively` exists rather than handing off to `superpowers:writing-plans` directly.** The failure mode in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/no-implementation-handoff.md`: without a substrate-shaped phase loop, freeform code follows by default and bypasses the substrate the rewrite established. Cohesive owns the phase derivation (delta ledger → per-phase intent) and the per-phase cross-review (delta-coverage-reviewer); Superpowers owns plan-writing and TDD execution inside each phase. See `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/composition-with-superpowers.md`.

**Why `review-codebase` and `review-diff` are two skills, not one with a `--scope` flag.** Different reviewer panels (4 reviewers vs 2), different rubrics (architecture-review-rubric vs cohesion-rubric), different output shapes (persisted report vs chat-only verdict). The shared concept is "fresh-eyes review against substrate"; the executions diverge enough that one skill body would be a configuration-laden mess.

**Why `using-cohesive` is separate from `cohesively`.** `using-cohesive` teaches Claude *when Cohesive applies* — it fires at session start (or whenever its frontmatter trigger matches a substrate-shaped user request) and orients Claude toward the methodology vs Superpowers' implementation-discipline framing. `cohesively` *routes within Cohesive* once the user has signaled Cohesive-shaped work — it picks among the eight canonical routes and dispatches the first subskill. Collapsing them into one skill would force a single body to do both jobs at two different altitudes (orientation vs route selection), which is the failure shape the seam between the bootstrap and the router exists to prevent. The split is also the structural mitigation for `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/discovery-vs-superpowers.md` — without `using-cohesive`, first-time users with both plugins installed land in trigger competition between Cohesive's `discover-substrate`/`audit-substrate` and Superpowers' research/exploration skills.

## Per-skill sections

Each section follows the same shape: Purpose, Owns, Does not own, Inputs, Outputs, Why this shape. Sections are ordered by chain position, then off-chain, then router, then session-start orientation. The section heading is `### <skill-name>` matching the directory name under `${CLAUDE_PLUGIN_ROOT}/skills/`; this is the regex target for the named invariant `SKILL_DESIGN_DOC_SECTION` (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md`).

### Bootstrap status

Per-skill sections in this doc carry one of three statuses, named explicitly in the table below:

- **`inherited`** — the section was authored *retroactively* against a pre-existing SKILL.md (most v0.1 skills' sections were authored this way during the 2026-05-05 architecture refactor; the design-layer claim was extracted from the SKILL.md body, not used to author it).
- **`newly-authored`** — the section was authored *forward*, alongside (or before) the SKILL.md body it governs. The design layer is genuinely the prior substrate, not a retroactive claim — but no `validate-rewrite` pass has yet confirmed parity under fresh-eyes review.
- **`validated`** — a `cohesive:rewrite-specs` pass on that skill's purpose, ownership, or seams has run *with the design layer as prior substrate* and `validate-rewrite` confirmed parity under fresh-eyes review (specifically `spec-cohesion-reviewer` lens 13).

| Section | Status | Notes |
|---|---|---|
| `discover-substrate` | inherited | not yet validated against a forward rewrite |
| `brainstorm-design` | inherited | not yet validated against a forward rewrite |
| `rewrite-specs` | **validated** | the architecture refactor itself touched its SKILL.md (Step 1a addition); spec-cohesion-reviewer lens 13 confirmed parity through repair-pass-3 |
| `validate-rewrite` | **validated** | validated by the 2026-05-05 validate-rewrite-internal-loop refactor (Purpose / Owns / Inputs / Outputs / Why-this-shape rewritten with the design layer as prior substrate); spec-cohesion-reviewer lens 13 confirmed parity through repair pass 2 |
| `implement-cohesively` | **validated** | validated by the 2026-05-05 review-diff repair pass; verdict vocabulary reconciled to four terminals (`Implemented / Phase Drift / Substrate Drift / Aborted`) |
| `review-codebase` | inherited | not yet validated against a forward rewrite |
| `review-diff` | inherited | not yet validated against a forward rewrite |
| `audit-substrate` | inherited | not yet validated against a forward rewrite |
| `init` | newly-authored | authored 2026-05-06 in the init-and-substrate-vocabulary rewrite alongside its SKILL.md body; the design layer is genuinely prior substrate, but parity is not yet validated against a forward rewrite |
| `cohesively` | inherited | not yet validated against a forward rewrite |
| `using-cohesive` | newly-authored | authored 2026-05-05 in the skill-pack-flow-tightening rewrite alongside its SKILL.md body; the design layer is genuinely prior substrate, but parity is not yet validated against a forward rewrite |

Both `inherited` and `newly-authored` sections may surface lens 13 (design-implementation agreement) and lens 14 (handoff contract consistency) drift on the first `validate-rewrite` pass that touches them — for `inherited` sections the drift is the predicted retroactive-claim mismatch, for `newly-authored` sections it is the predicted forward-rewrite mismatch. `spec-cohesion-reviewer` reads this table during dispatch (the agent's input set includes this doc) and applies extra skepticism to both statuses. When a section earns `validated` status, update the row in the same delta ledger that triggered the validation.

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
- Identifying axes of disagreement and selecting mode (autonomous one-shot vs conversational multi-turn dialog) per Phase 2's auto-detect gate.
- In autonomous mode: producing 2–4 design options with named tradeoffs.
- In conversational mode: walking axes one at a time as verdict-led picks, surfacing a leaf-direction summary, routing sub-decisions as Pick / Confirm / Default tags, and opening Phase 4's pressure-test with a cross-branch graft check.
- Pressure-testing through the design-pressure-testing rubric (see `${CLAUDE_PLUGIN_ROOT}/references/design-pressure-testing.md`) — applied to every option in autonomous mode, applied to the assembled leaf in conversational mode.
- Recommending one option (or named hybrid) and surfacing remaining ambiguity for the user to resolve.

**Does not own.**
- Writing the rewrite — that's `rewrite-specs` after a direction is approved.
- Implementation — that's `implement-cohesively`.
- Producing code, even illustrative snippets. The skill output is design-shape only.

**Inputs.** User intent + substrate discovery report (passed by router or freshly invoked).

**Outputs.** Approved direction (option name, summary paragraph, named main risk, structural mitigation). User-approved; no automated verdict. When conversational mode ran, the persisted file additionally carries a `## Decision dialog` section recording axes walked, sub-decision outcomes, and the cross-branch graft check result.

**Why this shape.** The design choice is the load-bearing decision of the chain. Pressure-testing before approval is what makes the rewrite worth running; without it, `rewrite-specs` writes specs against a half-pressured direction and `validate-rewrite` finds incoherence. The skill exists to *spend more turns on design* rather than rushing to specs.

**Why two modes.** A one-shot trailer is right for shallow option spaces (single-axis decisions, naming, placement within an established pattern) — the user gets a recommendation efficiently. A branching design space (≥2 distinct structural axes, or option space touching ≥2 substrate kinds) is where the user's taste should shape the leaf direction; the conversational dialog gives them participation per axis with verdict-led picks they can ratify or redirect. Auto-detect by axis count keeps the autonomous path fast for trivial cases and opens the dialog only where the option space actually forks. The pressure-test rigor and the recommendation shape are mode-shared — conversational mode is more participation, not less rigor.

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
- Rendering the per-verdict next step on terminal verdicts (Approved → default-recommend implementation route per the chat-trailer template's §"Default-recommend rule"; Design Incoherent → re-brainstorm; max-passes stall → user direction).

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

**Purpose.** Convert user intent into one of eight canonical routes (`design`, `review (codebase)`, `review (diff)`, `audit (substrate)`, `rewrite-only`, `implement`, `init`, `artifact`), announce the route, and dispatch the chain's first subskill with prereq state passed explicitly.

**Owns.**
- Route selection per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md` cells R001-R017.
- Announcement of the chosen route in canonical form before any tool call.
- Prereq-state and chosen-direction passing per the dispatch-prompt-contract grid in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md`.

**Does not own.**
- Workflow execution — each subskill runs its own process.
- Phase transitions within a route — those are user-driven, not auto-routed.
- Direct invocation of Superpowers — the `implement` route dispatches `cohesive:implement-cohesively`, which composes Superpowers internally.

**Inputs.** User intent (any natural-language request).

**Outputs.** Canonical announcement sentence + first subskill dispatch. No persisted artifact, no verdict.

**Why this shape.** A router rather than a workflow, because phase transitions are user-driven by design. A workflow router would hide what's running and remove the user's ability to re-enter the chain at any point. The canonical announcement makes the routing decision legible; the prereq-passing closes `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md`.

### init

**Purpose.** First-time adoption on a codebase with no Cohesive substrate. Scans for proto-substrate signals (rules in comments, scars in test names, branchy code) and produces a draft substrate at `docs/substrate/init-draft/` with side-by-side translations explaining each Cohesive type in plain terms. Designed to teach the substrate vocabulary by translating the user's own code into it (the Rosetta Stone move). One-shot; refuses if substrate already exists.

**Owns.**
- The proto-substrate scan against the user's repo (extends `${CLAUDE_PLUGIN_ROOT}/scripts/scan_substrate.py` with grep-based pattern matching for `MUST` / `NEVER` / `FIXME` / `HACK` / regression-test-name patterns / branchy enum dispatches).
- The side-by-side translation: rendering each proposed artifact with its Cohesive type's user-facing definition from `${CLAUDE_PLUGIN_ROOT}/references/substrate-vocabulary.md` inline, so the user learns what the type means while reviewing whether the proposal fits.
- The bounded proposal count (≤5 per type, ≤20 total in v0.1) — init is for the first substrate, not the complete substrate.
- The skeletal CLAUDE.md and ARCHITECTURE.md when neither exists. Augmenting existing top-level docs is out of scope.
- The refusal-when-substrate-exists check (Hard constraint #1).

**Does not own.**
- Exhaustive substrate generation. `audit-substrate` finds what init missed (init is bounded; audit is not).
- Auto-commit. Init writes draft files; the user reviews, edits, deletes, and `git mv`s manually.
- Merging with existing substrate. Init refuses when substrate exists; the right skill for an existing-substrate codebase is `audit-substrate`.
- Route selection. `cohesively` routes to `init` per cell R017 in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md`.

**Inputs.** The repo root; an optional `--brief` flag that suppresses inline translation paragraphs (default is verbose / pedagogical).

**Outputs.** A draft directory at `docs/substrate/init-draft/` containing per-artifact draft files (each with evidence + translation + proposed artifact + decision checkbox). Optional skeletal CLAUDE.md and ARCHITECTURE.md if neither exists. Chat trailer with a count of drafts produced + 3 example translations + a "what to do next" pointer to `audit-substrate`. No verdict (utility skill, parallel to `discover-substrate`).

**Why this shape.** Cohesive's value compounds over accumulated substrate, but on day 1 a fresh codebase has none. Without init, the user lands in `discover-substrate` → "Empty-substrate verdict: yes" → audit-substrate finds nothing because there's nothing there. Init breaks the chicken-and-egg by extracting the implicit substrate every codebase already carries (in comments, in test names, in branching logic) and translating it to the Cohesive vocabulary the first time the user encounters each type. The Rosetta Stone move (translation alongside the artifact) is what makes init pedagogical rather than just generative — the user develops the vocabulary by deciding what to keep on their own code, not by reading a glossary.

### using-cohesive

**Purpose.** Advise Claude when Cohesive-shaped work is the right framing for the user's request, and route the user to `cohesively` for route selection. Fires at session start (or whenever its frontmatter trigger matches) so Cohesive competes natively with `superpowers:using-superpowers` for the harness's bootstrap loading slot.

**Owns.**
- Carrying the substrate-narrowed trigger phrases that distinguish Cohesive's framing (substrate-first, durable-judgment) from Superpowers' (implementation-discipline).
- Producing a 1–2 sentence orientation message in chat when its trigger fires, naming `cohesively` as the canonical entry point.
- Being the structural mitigation for the trigger competition documented in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/discovery-vs-superpowers.md` (the gotcha file documents the seam; this skill's existence — at the harness's session-start loading slot — is what closes it).

**Does not own.**
- Route selection — that's `cohesively`. `using-cohesive` advises *whether* to enter Cohesive; `cohesively` advises *which Cohesive workflow* to run.
- Workflow execution — every chain skill, every diagnostic, every reviewer-dispatching skill is downstream.
- Discovery, audit, brainstorm, rewrite, validate, implement, review — `using-cohesive` does not produce substrate work itself; it points at the skills that do.
- Maintaining conversation state — its only effect is the orientation message; it does not persist a file or carry state across turns.

**Inputs.** User intent (any natural-language request). The session-start trigger fires when the request's natural-language shape matches Cohesive's substrate-first framing.

**Outputs.** A 1–2 sentence orientation message in chat (rendered when the trigger fires) + an internal advisory to invoke `cohesively` on the user's next substrate-shaped request. No persisted artifact, no verdict, no per-route dispatch — `cohesively` handles dispatch.

**Why this shape.** Cohesive needs a session-start surface that competes natively with Superpowers' bootstrap (`using-superpowers`) for the harness's session-start loading slot. Without it, the only canonical entry point is `cohesively`, which fires only when the user explicitly types its name or one of its router-trigger phrases — leaving first-time users to land in the trigger competition described in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/discovery-vs-superpowers.md`. Splitting bootstrap orientation (this skill) from route selection (`cohesively`) is the structural fix: the bootstrap is upstream of the router, and the router is upstream of every workflow. Three altitudes, three skills.

## Adding a new skill

When the brainstorm pressure surfaces a new skill, the change touches the design layer first, then the implementation layer, then the validator. Five steps in order:

1. **`${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md`** (this doc) — add the per-skill section, add a row in the at-a-glance table, add the "why this skill, not a mode of X" entry under §"Why these skills, not others", add a row to the §"Bootstrap status" table with status `newly-authored` (the section is being authored forward alongside the SKILL.md body, not retroactively against an existing one — `inherited` is reserved for retroactive sections; see §"Bootstrap status" prose for the distinction).
2. **`${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md`** — add the inbound and outbound handoff contracts. For non-chain skills (router, session-start orientation), add a brief contract section naming the transition shape (per §"The five transition shapes") even when no chain edge is involved.
3. **`${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md`** — if the skill is router-dispatchable, add a cell with stable ID and update the dispatch-prompt-contract grid. If the skill is upstream of the router (session-start orientation) or otherwise outside route selection, no router-matrix change is needed.
4. **`${CLAUDE_PLUGIN_ROOT}/skills/<name>/SKILL.md`** — author the skill body per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md`. The named invariant `SKILL_DESIGN_DOC_SECTION` (see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md`) enforces that every directory under `skills/` has a `### <name>` section in this doc; the validator's mechanical grep catches a missing section.
5. **`${CLAUDE_PLUGIN_ROOT}/scripts/validate_plugin.sh`** + **`${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/skill-section-presence.md`** — update the validator's six skill-set arrays (add the new skill to whichever apply per its shape: `expected_skills` always; `discovery_prereq_subskills`, `path_prereq_subskills`, `persisting_skills`, `verdict_led_skills`, `voice_imperative_skills` per the skill's body sections and prereq shape) and add a row to `skill-section-presence.md` with the appropriate `~` / `✓` / `–` cells. Run `bash scripts/validate_plugin.sh` and confirm clean before commit. The mapping from skill-body shape to which arrays apply is documented inline at the array definitions in `validate_plugin.sh`; consult those comments rather than guessing.

Steps 1–3 are the design layer; step 4 is the implementation layer; step 5 is the enforcement layer. Skipping step 5 is the failure mode the agent-readiness review of 2026-05-05 surfaced — a future agent following only steps 1–4 ships a "clean" skill that the validator immediately rejects.

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
