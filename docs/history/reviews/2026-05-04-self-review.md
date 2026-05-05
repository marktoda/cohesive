# Cohesive Architecture Review — Self-Review

**Date:** 2026-05-04
**Scope:** `/home/toda/dev/cohesive` (whole repo)
**Reviewers dispatched:** substrate-alignment, structure, library-native, agent-readiness
**Substrate discovery:** complete; report inline below

---

## Verdict

**Cohesive but under-enforced.**

The structure is sound. The plan and code agree. The locality decisions (three-layer separation, externalized worktree, inline fallback) are well-made and survive scrutiny against Cohesive's own `locality-over-centralization.md` rubric. The codebase is small enough that one careful pass produced a self-consistent v0.1.

What's missing is the layer that would let it stay self-consistent without the original author in the room. Cohesive's central claim is that judgment must become structural — tests, types, semantic linters, named invariants, CI checks — or it degrades to folklore. By that standard, the methodology pack itself is currently folklore. Five cross-cutting rules are locked in `docs/implementation_plan.md` §3; none are named as invariants, none have a structural check, and the one validator that exists (`scripts/validate_plugin.sh`) verifies structural shape only. There are zero tests, zero CI workflows, and zero dogfood transcripts despite the plan's DoD requiring two.

## Executive thesis

Cohesive ships v0.1 looking healthy because one author wrote it in one sitting and remembers all the conventions. The structure is right. The seams are right. The composition with Superpowers is right. But the codebase is currently *unable to teach itself*: a future agent (or new contributor) asked to add the V1 `invariant` skill would copy whichever sibling SKILL.md they read first, omit the fresh-eyes dispatch preamble in any new agent they wrote, miss the `${CLAUDE_PLUGIN_ROOT}` discipline (the validator actively rewards the wrong form), and have no transcript to compare their output against. The plugin teaching substrate-first ships with its own substrate as memory rather than enforcement. The fix is small (5–10 named invariants + 5–10 lines added to `validate_plugin.sh` + two transcripts) but it's the substrate Cohesive's own substrate-alignment-reviewer agent would flag in axis 4 of its own rubric. Currently Cohesive cannot pass its own review.

## Spec-prior review

**Result:** Pass with one annotation. No blocking spec issues.

### Docs read
- README.md
- docs/initial_design.md (spec v0.1, 2026-05-04)
- docs/implementation_plan.md (binding plan, 2026-05-04)
- references/substrate-model.md, cohesion-rubric.md, architecture-review-rubric.md, design-pressure-testing.md, locality-over-centralization.md

### Claimed architectural priors (from Phase 1 system-shape summary)
- Three-layer seam: skills orchestrate, agents review fresh-context, references hold pure content
- Composition over reinvention (Superpowers for worktrees, with inline fallback)
- Substrate before implementation; soft prereqs; fresh-eyes review; one precise clarifying question max

### Spec inconsistencies
- **One non-blocking inconsistency.** `docs/initial_design.md` describes 17 skills and 8 agents while only 6 + 5 exist. The plan's §1 reconciliation table accounts for this cleanly, but a fresh agent reading only the spec would form an incorrect mental model. Mitigated; not blocking. Surfaces below as a high-leverage finding (Source-of-truth hierarchy).

### Recommended spec changes
- Add a "Source-of-truth hierarchy" section to plan §0 (or top-of-README pointer) naming `docs/implementation_plan.md` as binding for v0.1 and `docs/initial_design.md` as preserved-but-not-updated vision.
- Annotate spec §5.1 inline: "See `docs/implementation_plan.md` §1 for the binding v0.1 surface."

## System cohesion scorecard

| Area | Rating | Summary |
|---|---:|---|
| Spec coherence | Mostly healthy | Spec/plan reconciliation is explicit and correct; spec is misleading without it. |
| Code/spec alignment | Mostly healthy | Implementation matches plan; minor drifts (cohesive-review description vs body; rewrite-specs invariant template hedge). |
| Domain model clarity | Mostly healthy | Concepts mostly right-sized. `cohesive-review --scope substrate` is a category error; "claimed system shape" wants a template. |
| Invariant enforcement | **At risk** | Five locked cross-cutting rules; zero structural enforcement. The plan calls them "locked in" without locking. |
| Test guarantees | **At risk** | Zero tests. Zero CI. `docs/transcripts/` empty despite DoD. |
| Locality and seams | Healthy | Three-layer separation clean. Reviewer-preamble duplication is *correctly* local. Worktree fallback right shape. |
| Library-native alignment | Mostly healthy | Native plugin idioms throughout. `scan_substrate.py:82` precedence bug; `plugin.json` missing `$schema`; `jq` unused. |
| Agent-readiness | **Under-supported** | Conventions discoverable only by imitation with subtle drift; plan rules invisible from inside skills. |
| Future extensibility | Mostly healthy | V1 path is named; adding new skills/agents will silently drift conventions without §3 enforcement. |

## Highest-leverage findings

Ranked by leverage × severity. Convergent findings across reviewers are listed once with citations.

### 1. The five "locked-in" Plan §3 rules have zero structural enforcement
**Severity:** Blocker
**Category:** Invariant
**Why it matters:** Plan §3 commits to: `${CLAUDE_PLUGIN_ROOT}` paths, fresh-eyes dispatch (no inherited conversation context), soft prereqs, router announces before dispatching, one precise clarifying question max, every subskill output recommends one next skill. Each rule lives in prose. None is named. None has a check. `validate_plugin.sh` enforces structural shape only and at line 107 actively *rewards* a non-compliant `${CLAUDE_PLUGIN_ROOT}`-less reference path. The very next contributor adding a new skill will silently violate at least one rule and the validator will pass. This is the central instance of Cohesive failing to apply its own substrate-model thesis to itself.
**Evidence:** docs/implementation_plan.md:81–91; scripts/validate_plugin.sh:99–108; agents/spec-cohesion-reviewer.md:91; cohesively/SKILL.md:83,127; review-spec-cohesion/SKILL.md:16–18.
**Recommended fix:** Promote each rule to a named invariant. Suggested names and homes:
- `PLUGIN_ROOT_PATHS` — every `references/`, `templates/`, `skills/`, `agents/` reference in a SKILL.md or agent file is prefixed with `${CLAUDE_PLUGIN_ROOT}/`. Enforced by a one-line grep in `validate_plugin.sh`.
- `FRESH_EYES_DISPATCH` — every Task-tool dispatch in any Cohesive skill body explicitly forbids reading prior conversation context. Enforced by a grep over skill bodies for Task dispatch blocks; assert each contains a fresh-eyes preamble snippet.
- `ROUTER_ANNOUNCES_BEFORE_DISPATCH` — `cohesively`'s output begins with the canonical "I'm treating this as a Cohesive <route> workflow:" form. Enforced by a transcript-shape check once transcripts exist.
- `ONE_PRECISE_QUESTION` — every route in `cohesively` defines at most one pre-canned clarifying question; never a vague "what do you want?" form.
- `SUBSKILL_RECOMMENDS_NEXT` — every terminal SKILL.md output schema includes exactly one `### Recommended next Cohesive skill` block (per branch where multiple verdicts exist, e.g. `review-spec-cohesion`).

Each invariant goes in a new `docs/invariants/` directory (or under `references/invariants/`), filled out with the existing `references/templates/invariant.md` template. Each gets a check in `validate_plugin.sh`.
**Substrate artifact to add or update:** Five named invariants + extended `validate_plugin.sh` semantic linter + (V1) wired CI.

### 2. No dogfood transcripts (DoD violation)
**Severity:** Blocker
**Category:** Tests / Substrate
**Why it matters:** Plan §6 M3 step 5 requires "design-rewrite cohesive's own spec and pass the fresh-eyes review." §6 M5 step 3: "Save dogfood transcripts to `docs/transcripts/`." §8 DoD: "One dogfood design-rewrite transcript and one architecture-review transcript checked into `docs/transcripts/`." `ls docs/transcripts/` returns empty. For a methodology pack delivered as prompts, the transcript *is* the integration test — it's the only artifact that demonstrates the workflow composes end-to-end. Without one, the four reviewer agents have no anchor for "what does success look like?" and a future agent running Cohesive on a real codebase has no reference output to compare against.
**Evidence:** docs/implementation_plan.md:165 (M3.5), :187 (M5.3), :217 (DoD); empty `docs/transcripts/`.
**Recommended fix:** Block any v0.1 release tag on producing two transcripts: (a) `cohesive-review --scope codebase` against a non-trivial OSS repo, and (b) the design-rewrite flow against this very repo's spec/plan reconciliation issue. The current review (this document) partially satisfies (a) for cohesive itself.
**Substrate artifact to add or update:** Two transcripts in `docs/transcripts/` with a one-line index `docs/transcripts/README.md`.

### 3. No tests; no CI; the validator green-lights skills that violate Plan §3
**Severity:** High
**Category:** Tests / Invariant
**Why it matters:** `references/cohesion-rubric.md` axis 5 elevates test guarantees as a leverage tier. `references/substrate-model.md` puts tests in the leverage hierarchy. Cohesive ships zero tests. There is no `.github/workflows/`. The validator only checks structural shape: frontmatter exists, JSON parses, scripts executable. It does not check the rules that actually matter for substrate quality. A passing validator gives false confidence: an agent will read a green check and ship.
**Evidence:** No `tests/`; no `.github/`; `scripts/validate_plugin.sh:1–127` (structure-only).
**Recommended fix:** Add `tests/output_schema/` containing one canned skill output per skill plus a parser that asserts header presence and order. Add `.github/workflows/validate.yml` that runs `bash scripts/validate_plugin.sh` and the schema parser. Once Finding 1's invariants are named, extend the validator to enforce them.
**Substrate artifact to add or update:** Test fixtures + CI workflow + extended validator.

### 4. Skill conventions are discoverable only by imitation, with observable drift
**Severity:** High
**Category:** Agent-readiness / Domain model
**Why it matters:** Six SKILL.md files differ in section list (`cohesively` lacks "Hard constraints" and "Composition"; `discover-substrate` has no "Composition"; `rewrite-specs` is the only one with anti-patterns as a *table* vs others' bullet lists). No reference document names the canonical skill body shape. An agent writing the V1 `invariant` skill will pick whichever sibling they read first and silently produce something subtly off. Same drift exists across the five agent files (preamble structure, "How to scope your reading" placement, color choice).
**Evidence:** skills/cohesively/SKILL.md (no Hard constraints); skills/rewrite-specs/SKILL.md:141 (table); skills/brainstorm-design/SKILL.md:163 (bullets); agents/agent-readiness-reviewer.md:124–131 vs agents/library-native-reviewer.md:100–107 vs agents/substrate-alignment-reviewer.md:73–83.
**Recommended fix:** Add `docs/substrate/designs/skill-conventions.md` and `docs/substrate/designs/reviewer-agent-template.md` naming required vs optional sections, frontmatter format, anti-pattern presentation, and "Recommended next Cohesive skill" footer convention. Reference both from a new repo-root `AGENTS.md` so substrate discovery surfaces them. Add a section-presence check to `validate_plugin.sh`.
**Substrate artifact to add or update:** Two convention references + AGENTS.md + validator extension.

### 5. `cohesive-review --scope substrate` is a category error in the unification
**Severity:** High
**Category:** Domain model / Seams
**Why it matters:** The implementation plan justifies merging three review skills into `cohesive-review` with "same reviewers, only the input target differs." That's true for `--scope codebase` (4 phases, 4 parallel agents, synthesis) and `--scope diff` (lighter version of same). It's *false* for `--scope substrate`: zero agents dispatched, no synthesis, no spec-prior gate — just a single-pass scan that happens to share the `--scope` argument. ~40% of the SKILL.md is conditional branching against the three modes, the smell of a too-broad concept.
**Evidence:** skills/cohesive-review/SKILL.md:37–105 (codebase, 4-phase), :107–157 (diff, 2 agents), :159–198 (substrate, 0 agents); :163 ("**No subagent dispatch.**"); docs/implementation_plan.md:16 (the justification).
**Recommended fix:** Cheap path: keep `cohesive-review` for codebase + diff (which legitimately share machinery); restore a separate `substrate-audit` skill that internally calls `discover-substrate` and renders the audit. Update `references/architecture-review-rubric.md` title — currently it says "Architecture review" but the SKILL claims it covers all three modes.
**Substrate artifact to add or update:** Split skill + rubric clarification.

### 6. Source-of-truth hierarchy is unclear; agents will update the wrong doc
**Severity:** High
**Category:** Agent-readiness / Spec drift
**Why it matters:** Four documents agree today: `docs/initial_design.md`, `docs/implementation_plan.md` §1 delta table, `docs/implementation_plan.md` §2 final structure, README "What's in the box," and the actual `skills/` directory. They agree because one author wrote them in one sitting. None names the others as primary. An agent told "update the spec to reflect the new V1 invariant skill" cannot tell whether to edit the spec, the plan §1 table, or the README first.
**Evidence:** README.md:7,86–120; docs/implementation_plan.md:1–7,12–25; absence of any "this doc is the binding source" annotation in any of the three.
**Recommended fix:** Add §0 to plan: "Source-of-truth hierarchy. `implementation_plan.md` is binding for what ships. `initial_design.md` is the v0.1 vision and is *not* updated for plan deltas. README §What's in the box is generated/synchronized from plan §2." Add a `validate_plugin.sh` check that the on-disk skill list matches plan §2.
**Substrate artifact to add or update:** Plan §0 + validator parity check.

### 7. The router behavior has no matrix despite being the most branchy artifact
**Severity:** High
**Category:** Substrate / Domain model
**Why it matters:** `cohesively/SKILL.md` defines six routes plus a "routing decision logic" prose block at :99–106. Cohesion-rubric axis 4 (and behavior matrices generally) exist precisely for branchy behavior; the plugin teaches matrix-cell tests for cells of branchy behavior. The router has no matrix. A user request like "audit my PR for what's missing" is genuinely ambiguous (review/diff? review/substrate?), and the disambiguation lives only in prose ordered rules, with no test pinning any specific input → route mapping. Cohesive *teaches* this exact pattern but doesn't apply it to its own most-branchy artifact.
**Evidence:** skills/cohesively/SKILL.md:14–79, :99–106; references/cohesion-rubric.md:54–58 (axis 4 vocabulary).
**Recommended fix:** Add `docs/cohesive/router-matrix.md` with stable cell IDs (R001..R0NN) keyed on (verb tense × scope hint × explicit instruction × ambiguity). Each row: input shape, expected route, why. Eventually wire one acceptance test per cell.
**Substrate artifact to add or update:** Router behavior matrix.

### 8. Soft-prereqs is a load-bearing rule with no detection mechanism
**Severity:** High
**Category:** Hidden rule / Gotcha
**Why it matters:** Plan §3 line 89 commits to "skill-level prereqs are soft." Plan §7 explicitly flags this as a risk: "May produce mediocre output if subskills are routinely invoked without context. Tighten to hard gates if observed." This is a textbook gotcha — symptom, tempting wrong fix ("hard-gate"), correct pattern. It is not encoded as a gotcha. `brainstorm-design/SKILL.md:31` and `cohesive-review/SKILL.md:30` both say "if discover-substrate hasn't run yet, invoke it first" with no specification of *how* to detect that. Two agents fixing two bugs will invent two different detection heuristics.
**Evidence:** docs/implementation_plan.md:89,205; skills/brainstorm-design/SKILL.md:31; skills/cohesive-review/SKILL.md:30; absence of any gotcha doc.
**Recommended fix:** Add `docs/cohesive/gotchas/soft-prereqs.md` using the existing `references/templates/gotcha.md`. Define one detection rule (e.g., "ask the user; do not rely on session memory") and propagate it into all subskills.
**Substrate artifact to add or update:** Gotcha doc + propagated detection rule.

### 9. `scan_substrate.py:82` directory-filter has an operator-precedence bug
**Severity:** High
**Category:** Tooling
**Why it matters:** The expression `if d not in SKIP_DIRS and not d.startswith(".") or d in {".github", ".circleci", ".gitlab-ci.yml"}` parses as `(A and B) or C` due to Python precedence, so the dotfile-allowlist is functionally `OR`ed with the SKIP_DIRS check rather than AND'd. The current set is small enough that the bug doesn't bite hard, but it's one well-meant edit away from silently scanning `node_modules` or skipping `.docs`. Also `.gitlab-ci.yml` is a file, not a directory, so it doesn't belong in this set.
**Evidence:** scripts/scan_substrate.py:82.
**Recommended fix:**
```python
allow_dotdirs = {".github", ".circleci"}
dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and (not d.startswith(".") or d in allow_dotdirs)]
```
Add a unit test exercising `.github`, `.git`, `.cache`, `node_modules`, `docs`.
**Substrate artifact to add or update:** Test + small refactor.

### 10. Templates referenced as not-yet-authoritative when they are
**Severity:** Medium
**Category:** Stale doc
**Why it matters:** `rewrite-specs/SKILL.md:71` hedges: "Named invariant: `${CLAUDE_PLUGIN_ROOT}/references/templates/invariant.md` (V1 template — until then, use the spec format from `references/cohesion-rubric.md`)." But `references/templates/invariant.md` is a complete 78-line template today. The hedge would send a future agent to a non-existent fallback (cohesion-rubric.md doesn't define an invariant *format*, only rubric axis 4). Audit the other template references for similar staleness.
**Evidence:** skills/rewrite-specs/SKILL.md:71; references/templates/invariant.md (complete).
**Recommended fix:** Drop the hedge in `rewrite-specs/SKILL.md:71`. Audit other "until then" hedges across all skills.
**Substrate artifact to add or update:** Edit + sweep.

### 11. The "claimed system shape" summary is a stable artifact masquerading as inline output
**Severity:** Medium
**Category:** Domain model (missing concept)
**Why it matters:** Every codebase-mode review produces a "claimed system shape" summary in Phase 1. The four reviewer agents all receive it as their first input. It has a stable six-section structure. It's referenced in five files. It's exactly the kind of recurring-shape-with-stable-name that should be a template. Compare to `references/templates/substrate-map.md`, which is more verbose, less load-bearing, and *does* have a template.
**Evidence:** references/architecture-review-rubric.md:24–46; skills/cohesive-review/SKILL.md:50; received-as-input by all four reviewer agents.
**Recommended fix:** Add `references/templates/claimed-system-shape.md` with the six sections (Product goal / Architectural priors / Intended seams / Named invariants / Testing philosophy / Future direction). Reference it from the rubric and from `cohesive-review` Phase 1.
**Substrate artifact to add or update:** New template.

### 12. `references/templates/implementation-plan.md` is speculative substrate
**Severity:** Medium
**Category:** Complexity / Locality
**Why it matters:** The 9-template tier includes `implementation-plan.md`, but the MVP `skills/` list (plan §2) has no skill that produces one. `plan-implementation` is V1-deferred. README §"Recommended companion" says use Superpowers' `writing-plans` for now. So this template is an abstraction with one user, and that user doesn't exist yet. Self-consistency: this is exactly the kind of abstract-base-class-with-no-concrete-implementation that the structure-reviewer agent's own checklist (`agents/structure-reviewer.md:88–94`) is supposed to flag. Cohesive fails its own check.
**Evidence:** references/templates/implementation-plan.md (file exists); docs/implementation_plan.md:25 (no MVP producer); README.md:144.
**Recommended fix:** Delete the template until V1 introduces `plan-implementation`, or commit by adding a tiny MVP `plan-implementation` skill.
**Substrate artifact to add or update:** Deletion or skill addition.

### 13. Worktree-fallback detection is unspecified
**Severity:** Medium
**Category:** Hidden rule / Composition
**Why it matters:** `rewrite-specs/SKILL.md:28–38` and `cohesively/SKILL.md:90–96` say "if `superpowers:using-git-worktrees` is available, invoke it" without specifying *how* to detect availability. Plan §3 commits to the "5-line inline fallback." A future skill needing worktrees will copy the bash fallback and likely *always* use it, defeating the composition. The fallback is also itself untested.
**Evidence:** skills/rewrite-specs/SKILL.md:28–38; skills/cohesively/SKILL.md:90–96.
**Recommended fix:** Add `references/composing-with-superpowers.md` naming the detection rule (skill availability is announced by the harness in the system reminder; if listed, invoke; else fallback) and the canonical fallback snippet to share-by-reference. Add `scripts/check_worktree_fallback.sh` that exercises the fallback in a tmp git repo.
**Substrate artifact to add or update:** Composition reference + fallback test.

### 14. Other library-native polish (collected; each Low)
- `plugin.json` lacks `$schema` (marketplace.json has it).
- `plugin.json` description and `marketplace.json` plugin description both carry the long form; will drift. Marketplace should be one-liner.
- `validate_plugin.sh` re-implements YAML frontmatter parsing in awk; brittle for multi-line block scalars (the existing agent descriptions). A 5-line Python helper would be more robust.
- `validate_plugin.sh` uses emojis in output despite the agent prompts forbidding emojis — internal style inconsistency.
- `scan_substrate.py` uses `inv.__dict__.items()` for JSON serialization; `dataclasses.asdict(inv)` is the native idiom.
- `scan_substrate.py:36` `from __future__ import annotations` is redundant given PEP 585 syntax already in use.
- `validate_plugin.sh` JSON validation uses inline `python3 -c "import json"`; `jq empty` or `python3 -m json.tool` is the ecosystem standard.

**Substrate artifact to add or update:** Single tooling polish PR.

## Confusing or weak concepts

| Concept | Issue | Recommendation |
|---|---|---|
| `cohesive-review --scope substrate` | Mode that shares no machinery with the other two | Split back into `substrate-audit` skill |
| "claimed system shape" | Stable shape, no template | Add `references/templates/claimed-system-shape.md` |
| Spec vs plan | Both present, neither names itself binding | Plan §0 source-of-truth hierarchy |
| "Until V1" hedges | Some templates already complete | Audit and remove |
| "soft prereq" | Load-bearing rule with no detection | Gotcha doc + named detection rule |
| Implementation-plan template | No MVP consumer | Delete or commit |

## Invariants that should be named

| Invariant | Current enforcement | Recommended enforcement |
|---|---|---|
| `PLUGIN_ROOT_PATHS` | Reviewer memory | grep in `validate_plugin.sh` |
| `FRESH_EYES_DISPATCH` | Per-agent prose preamble | Skill-body grep + dispatch-prompt template |
| `ROUTER_ANNOUNCES_BEFORE_DISPATCH` | Prose in router body | Transcript-shape check (when transcripts exist) |
| `ONE_PRECISE_QUESTION` | Prose in router body | Manual until matrix exists; then matrix cell test |
| `SUBSKILL_RECOMMENDS_NEXT` | Prose in each skill | Output-schema parser test |

All five would be filed under `docs/invariants/` (or `references/invariants/`) using the existing `references/templates/invariant.md` template.

## Test guarantee gaps

| Behavior | Current coverage | Risk | Recommended test |
|---|---|---|---|
| Each skill's output schema | None | Silent shape drift between revisions | Snapshot test of a canned output per skill |
| Worktree fallback when superpowers absent | None | Fallback bug ships unnoticed | `scripts/check_worktree_fallback.sh` against tmp git repo |
| Router routing for ambiguous inputs | None | Prose-only disambiguation drifts | Per-cell matrix test once router-matrix exists |
| `${CLAUDE_PLUGIN_ROOT}` discipline | None | Validator green-lights non-compliant paths | One-line grep in `validate_plugin.sh` |
| Fresh-eyes preamble in every dispatch | None | Sixth reviewer agent silently contaminates | Skill-body grep for Task dispatches without the preamble |
| End-to-end design rewrite + spec-cohesion review | None (DoD violation) | Workflow has never been observed end-to-end | Transcript checked into `docs/transcripts/` |

## Locality and abstraction review (no findings — included for completeness)

The three-layer separation (skills/agents/references) is the codebase's strongest substrate decision. No skill embeds reference content inline. No agent embeds skill orchestration logic. The reviewer-preamble duplication across five agent files (~30 lines repeated verbatim) was specifically interrogated: it is *correctly local*, because the fresh-eyes property requires each agent file to be readable standalone by a Task subprocess with no shared context; extracting to a common reference would either be loaded into every context anyway or be a hint fresh-eyes contexts wouldn't follow. The codebase passes its own `locality-over-centralization.md` rubric here.

The worktree-fallback inline duplication in `rewrite-specs` is similarly correct: Superpowers is the centralized abstraction, the inline fallback is local duplication for a real "the contract isn't always available" case. Don't refactor.

The one minor seam violation: `references/design-pressure-testing.md:94` references `${CLAUDE_PLUGIN_ROOT}/skills/brainstorm-design/SKILL.md` for the canonical output format. The dependency direction should run the other way — the skill cites the reference, not vice versa. Flip the direction in a future pass.

## Library-native alignment opportunities

Cohesive looks like a real Claude Code plugin, not a methodology PDF wedged into the format. Frontmatter, agent dispatch, `${CLAUDE_PLUGIN_ROOT}` usage (zero `/home/toda` leaks anywhere), and Superpowers composition are all idiomatic. The polish list at Finding 14 is the entirety of the library-native debt: small, concentrated in the two scripts.

## Substrate improvements (consolidated)

### Specs to rewrite or annotate
- `docs/implementation_plan.md` §0: source-of-truth hierarchy
- `docs/initial_design.md` §5.1: pointer to plan §1 reconciliation
- `references/architecture-review-rubric.md`: title or scope clarification (does the rubric cover all three review modes or just codebase?)
- `skills/rewrite-specs/SKILL.md:71`: drop the "until V1" hedge

### Behavior matrices to add
- `docs/cohesive/router-matrix.md` (R001..R0NN; route selection)

### Named invariants to add
- `PLUGIN_ROOT_PATHS`, `FRESH_EYES_DISPATCH`, `ROUTER_ANNOUNCES_BEFORE_DISPATCH`, `ONE_PRECISE_QUESTION`, `SUBSKILL_RECOMMENDS_NEXT`

### Semantic linters to add (extensions to `validate_plugin.sh`)
- `${CLAUDE_PLUGIN_ROOT}` discipline check
- Skill-body required-section check
- Skill-directory parity with plan §2
- Fresh-eyes preamble grep over Task dispatch sites
- Frontmatter `Use when` / `Triggers on` shape check (skills)

### Gotchas to document
- `docs/cohesive/gotchas/soft-prereqs.md` — soft prereqs producing mediocre output
- `docs/cohesive/gotchas/discovery-vs-superpowers.md` — discovery skill competition (plan §7 risk)

### Templates to add or remove
- ADD: `references/templates/claimed-system-shape.md`
- ADD: `docs/substrate/designs/skill-conventions.md` and `docs/substrate/designs/reviewer-agent-template.md`
- ADD: `references/composing-with-superpowers.md`
- DECIDE: `references/templates/implementation-plan.md` — delete or commit by adding a V1 skill

### CI/tests
- `.github/workflows/validate.yml` running `validate_plugin.sh` and the schema parser
- `tests/output_schema/` with one canned output per skill

### Repo-root convention doc
- `AGENTS.md` listing the named invariants and convention references so substrate discovery surfaces them

### Transcripts (DoD blocker)
- `docs/transcripts/<date>-architecture-review.md` (this document partially satisfies)
- `docs/transcripts/<date>-design-rewrite.md`

## Phased roadmap

### Phase 1: Repair substrate (1–2 sessions, blocking v0.1 release)
1. Add `AGENTS.md` and a §0 source-of-truth hierarchy to plan.
2. Name the five invariants in `docs/invariants/` (or `references/invariants/`); fill out using the existing template.
3. Add `docs/substrate/designs/skill-conventions.md` and `docs/substrate/designs/reviewer-agent-template.md`.
4. Add `references/templates/claimed-system-shape.md`.
5. Write the two soft-prereqs and superpowers-competition gotchas.
6. Generate the two dogfood transcripts (this review counts as one).
7. Drop the "until V1" hedge in `rewrite-specs/SKILL.md:71`.
8. Decide: delete `references/templates/implementation-plan.md` or commit by adding a V1 skill.
9. Add `docs/cohesive/router-matrix.md` with at least the R001..R006 cells the current router prose implies.

### Phase 2: Simplify architecture (1 session)
1. Split `cohesive-review` so `--scope substrate` becomes a separate `substrate-audit` skill (or document the structural difference clearly).
2. Flip the `references/design-pressure-testing.md:94` reference direction.
3. Fix `scan_substrate.py:82` precedence bug + add unit test.
4. Audit `plugin.json` (`$schema`, description length parity with marketplace).

### Phase 3: Strengthen enforcement (1 session)
1. Extend `validate_plugin.sh` with the five semantic-linter checks.
2. Add `tests/output_schema/` with canned outputs and a schema parser.
3. Add `.github/workflows/validate.yml`.
4. Add `scripts/check_worktree_fallback.sh`.

This sequencing matters: substrate first (so the rules exist to be enforced), then structure (so the substrate doesn't move under the enforcers), then enforcement (so the rules become structural). Inverting it produces churn.

## Self-consistency check

The acid test for this review: after Phase 1 lands, re-running `cohesive-review --scope codebase` on this repo should *not* surface findings 1, 2, 3, 4, 6, 7, 8, 11, 12. The remaining low-severity polish in Phase 2/3 is tractable. After all three phases, Cohesive should be able to pass its own review — at which point the methodology has earned the right to recommend itself to other codebases.

Currently it cannot pass its own review. That's the headline.
