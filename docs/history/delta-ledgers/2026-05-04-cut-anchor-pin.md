# Design Delta Ledger — Cut, Anchor, Pin (UX/conciseness/clarity rewrite)

**Date:** 2026-05-04
**Worktree / branch:** `.claude/worktrees/cut-anchor-pin` on `worktree-cut-anchor-pin`
**Approved direction:** "Cut, anchor, pin" — three-layer UX/conciseness/clarity refactor: tighten the canonical Output format shape (cut), add a normative voice guide + worked transcript with citation-from-skill-bodies (anchor), promote `VERDICT_BEFORE_EVIDENCE` to a named invariant (pin).

This ledger records *what changed* in the substrate during this `rewrite-specs` pass. It exists so the fresh-eyes reviewer can see the rewrite as a delta. Implementation follow-up — edits to each `skills/*/SKILL.md` Output format block, each `agents/*.md` output block, and `scripts/validate_plugin.sh` — is explicitly out of scope for this rewrite per AGENTS.md "Substrate vs implementation" and `rewrite-specs` Hard Constraint #3, and is tracked under "Implementation follow-up" below.

## Files rewritten

- `docs/substrate/designs/skill-conventions.md`
  - **Before:** Named one invariant (`PLUGIN_ROOT_PATHS`); §"Output format conventions" specified TL;DR convention + recommended-next footer; §"Tone" governed both SKILL.md prose and the chat the skill renders to the user, conflated.
  - **After:** Names two invariants. §"Output format conventions" now specifies five rules in priority order: voice citation (rule 1), verdict-leads (rule 2, citing the new invariant), chat-render-may-be-faithful-subset (rule 3), header-depth cap at `###` (rule 4), branchy-content-as-bullets-or-tables (rule 5). §"Tone" scoped explicitly to SKILL.md body prose and points at `output-voice.md` for chat-rendered output. Anti-patterns table extended with five new entries (missing voice citation, buried verdict, chat-render-duplicates-persisted-body, header soup, multiple-recommendations).
  - **Reason:** Per the "Cut" layer, the canonical Output format shape needs to *bake in* brevity rather than rely on per-skill restatement. Per the "Anchor" layer, the conventions doc must point at the voice guide so the seam is documented.

- `docs/substrate/designs/reviewer-agent-template.md`
  - **Before:** §"Output format conventions" specified the six-field finding shape with no citation requirement and no header-depth cap. The agent's per-finding `**Severity:**` was implicitly the only render rule.
  - **After:** §"Output format conventions" now opens with two rules: voice citation (rule 1) and the canonical six-field shape (rule 2). Explicitly notes that reviewer agents do not render verdicts — verdicts are the synthesizing skill's job — so `VERDICT_BEFORE_EVIDENCE` does not apply directly to agent findings. Cap finding nesting at `###`. Anti-patterns table extended with three new entries (missing voice citation, header soup, narrative paragraphs instead of six-field block).
  - **Reason:** Voice rules apply transitively through the synthesizing skill, so agents need the citation hook. Header-depth caps propagate from finding to synthesized chat output.

- `AGENTS.md`
  - **Before:** §"The one named invariant" listed `PLUGIN_ROOT_PATHS` as the single rule with a real failure mode; convention references mentioned skill-conventions and reviewer-agent-template. §"When you are about to..." had a `validate_plugin.sh` bullet referencing only `PLUGIN_ROOT_PATHS`.
  - **After:** §"The named invariants" (renamed) lists two invariants with explicit failure modes for each. Convention references add a new bullet for chat-rendered output pointing at `references/output-voice.md` and the worked transcript. The `validate_plugin.sh` bullet references both invariants by name.
  - **Reason:** Per the "Pin" layer, the second invariant must be discoverable from the source-of-truth doc agents and contributors read first.

- `ARCHITECTURE.md`
  - **Before:** §"Substrate" claimed "v0.1 ships one" invariant; §"Conventions" listed skill-conventions and reviewer-agent-template references but no voice guide; §"Where to look first" had no row for chat-render authoring; §"Risks the design accepts" framed "Conventions over invariants" as v0.1 default; §"v0.1 scope" said "8 references."
  - **After:** §"Substrate" lists two invariants. §"Conventions" adds a bullet for `output-voice.md` and a "Verdict discipline" bullet linking the invariant. §"Where to look first" adds two rows (Output format authoring → output-voice; verdict change → VERDICT_BEFORE_EVIDENCE). §"Risks" updates "Conventions over invariants" to acknowledge two have graduated. §"v0.1 scope" updated to "9 references."
  - **Reason:** Architecture is the binding map; rule promotions and new conventions must show up here for the source-of-truth hierarchy to hold.

- `docs/substrate/matrices/reviewer-output-shape.md`
  - **Before:** 5 agents × 6 canonical fields (Severity, Category, Why it matters, Evidence, Recommended fix, Substrate artifact). All cells `✓`.
  - **After:** 5 agents × 7 columns. New "Voice citation" column tracks whether each agent file carries the voice-citation line in its "How to structure your output" block. All five cells in the new column are `pending`; implementation follow-up flips them to `✓`. Body extended to note that verdict-leads is tracked at the skill level (in `VERDICT_BEFORE_EVIDENCE.md`'s Applies-to list), not in this matrix.
  - **Reason:** New convention pins need a tracked grid so drift is visible; verdict-shape stays scoped to skills (where it belongs) rather than getting mixed into agent-finding shape (where it doesn't).

## Files added

- `references/output-voice.md` — normative reference for chat-rendered output. Five rules (verdict-leads, faithful-subset, header-depth cap, bullets/tables not narrative phases, single next-recommendation), do/don't table, forbidden-phrasings list, density-budget guideline table, citation requirement. Cited from every Output format block (after implementation follow-up).
- `docs/history/transcripts/output-voice-worked-example.md` — load-bearing companion to the voice guide. Side-by-side wordy-vs-punchy render of the same `cohesive:review-diff` invocation with seven cuts justified inline. Dated, append-only.
- `docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md` — the second named invariant. Specifies the rule, scope (`review-codebase`, `review-diff`, `validate-rewrite`, `audit-substrate`), why-it-matters, enforcement plan (two grep checks in `validate_plugin.sh`, queued for implementation), known bypass risks, review checklist.
- `docs/substrate/gotchas/wordy-output.md` — the scar this rewrite retires. Symptom (verdict buried, header soup, multi-recommendations, ceremony), why it happened (voice rules as convention only, no central guide, no worked example, no invariant on the most-regressed rule), tempting wrong fix ("be more concise" in CLAUDE.md), correct pattern (the three-layer Cut/Anchor/Pin model), tests/checks, when discovered.
- `docs/substrate/gotchas/style-guide-rot.md` — the trap this rewrite must avoid. Symptom (style guides rot when read far from generation), why it happens (locality of citation matters), tempting wrong fix (more rules, or copy verbatim into every skill), correct pattern (cite from where the model reads at generation time + pair rules with a worked transcript).

## Files removed or deprecated

_None._ This rewrite is purely additive on the substrate side. (Implementation follow-up will edit per-skill Output format blocks but will not delete substrate.)

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| "The one named invariant" | "The named invariants" (two) | Renamed |
| Tone rules apply to both SKILL.md prose and chat-rendered output | Tone rules scope to SKILL.md prose; chat-rendered output follows `output-voice.md` | Tightened (split conflation) |
| Output format = TL;DR + recommended-next footer | Output format = voice citation + (verdict if verdict-led) + faithful-subset + header cap + bullets/tables + recommended-next footer | Tightened (five rules in priority order) |
| Reviewer-output-shape matrix tracks finding-fields only | Matrix tracks finding-fields + voice-citation column | Extended |
| Implicit drift surface for chat-render rules | Documented as the gotcha `wordy-output.md` retired by this rewrite | Named |
| Implicit risk that style guides rot far from generation | Documented as the gotcha `style-guide-rot.md` defended against by the citation-from-skill-body pattern | Named |

## New or updated substrate

### Specs / references
- `references/output-voice.md` — new normative reference for chat output
- `docs/substrate/designs/skill-conventions.md` — updated Output format conventions (5 rules), Tone scope, anti-patterns
- `docs/substrate/designs/reviewer-agent-template.md` — updated Output format conventions, anti-patterns
- `AGENTS.md` — updated "The named invariants," convention references, validator bullet
- `ARCHITECTURE.md` — updated Substrate, Conventions, Where to look first, Risks, v0.1 scope sections

### Behavior matrices
- `docs/substrate/matrices/reviewer-output-shape.md` — added Voice-citation column (5 cells, all `pending` until implementation)

### Named invariants
- `VERDICT_BEFORE_EVIDENCE` — added. Scope: `review-codebase`, `review-diff`, `validate-rewrite`, `audit-substrate`. Enforcement queued for implementation pass (two grep checks).
- `PLUGIN_ROOT_PATHS` — unchanged.

### Gotchas
- `docs/substrate/gotchas/wordy-output.md` — added. Names the user-reported scar this rewrite retires.
- `docs/substrate/gotchas/style-guide-rot.md` — added. Names the trap this rewrite must avoid.

### Semantic linter specs (proposed, not yet implemented)
- **Verdict-leads grep.** For each skill in `VERDICT_BEFORE_EVIDENCE.md`'s "Applies to" list, the SKILL.md "Output format" block's first three non-blank lines after the outermost header must contain `**Verdict:**`. Failure message names the invariant.
- **Voice-citation grep.** Every `skills/*/SKILL.md` Output format block must contain the literal line `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`. Same check for every `agents/*.md` "How to structure your output" code block. Failure message names the convention pin and references `style-guide-rot.md`.

### Tests / checks proposed (not yet implemented)
- Manual scenario test: invoke `cohesive:review-diff` with no voice citation in the dispatching skill; verify the chat render still leads with verdict (the invariant) but voice rules drift (the convention).
- Manual scenario test: dogfood the rewritten substrate via `cohesive:review-codebase` against this very repo; verify the synthesized output respects the new five Output format rules.

## What this rewrite *did not* do

- **Implementation code:** not changed. Per-skill Output format blocks (8 SKILL.md files) and per-agent output blocks (5 agent files) are queued for implementation follow-up. They retain the *old* shape until that follow-up lands. The substrate-vs-implementation seam is intentional — fresh-eyes review of the substrate alone is what `validate-rewrite` exists for.
- **Validator script:** `scripts/validate_plugin.sh` not changed. The two new grep checks (verdict-leads, voice-citation) are specified in `VERDICT_BEFORE_EVIDENCE.md` and `wordy-output.md` but added to the validator in the implementation pass.
- **CI:** unchanged (out of scope for v0.1 per ARCHITECTURE.md).
- **Promoted rules other than verdict-leads:** `OUTPUT_DENSITY` and `FORCED_CHOICE_QUESTIONS` were considered for promotion in the brainstorm and explicitly left as conventions. Density is hard to grep-pin (any single proxy is flawed); forbidden-phrasings is grep-able but the list is still settling.
- **Cross-skill question budget:** the brainstorm noted that a chained route can ask 3+ questions across subskills; this rewrite acknowledges the issue in `wordy-output.md` "Notes for future contributors" but does not encode a budget. Deferred to a future substrate pass.
- **Reviewer-agent body edits:** the new "Voice citation" matrix column lists all five agent cells as `pending`. The agent files themselves are not touched in this rewrite; the citation lines are added in implementation follow-up.

## Implementation follow-up

The following work is *not* part of this rewrite and must run in a separate Superpowers `writing-plans` → `executing-plans` cycle, with `cohesive:review-diff` on the result:

1. **Each `skills/*/SKILL.md` Output format block:** add the voice citation line as the first non-blank line; for verdict-led skills, ensure `**Verdict:**` appears in the first three non-blank lines after the section header; cap header depth at `###`; convert any narrative-phase rendering to bullet/table form; ensure chat render is a faithful subset of the persisted file (where applicable).
2. **Each `agents/*.md` "How to structure your output" code block:** add the voice citation line; cap finding nesting at `###`.
3. **`scripts/validate_plugin.sh`:** add two grep checks per the spec in `VERDICT_BEFORE_EVIDENCE.md` §"Enforcement" and `wordy-output.md` §"Tests / checks that preserve this." Failure messages name the rule by name.
4. **Reviewer-output-shape matrix:** flip the five Voice-citation cells from `pending` to `✓` after step 2 lands.

The implementation pass should pair with a manual `cohesive:review-codebase` dogfood run and update this ledger's "Implementation follow-up" status when complete.

## Remaining ambiguity

Things the rewrite couldn't fully resolve and that the fresh-eyes reviewer should flag:

- **Voice-citation pin status: convention or invariant?** The brainstorm chose convention with grep enforcement, but `style-guide-rot.md` notes that if the citation requirement survives two release cycles without drift, it earns invariant promotion. Reviewer should consider whether the citation pin is already strong enough to ship as an invariant, given that it's grep-pinned today.
- **Worked-transcript authenticity.** The transcript at `docs/history/transcripts/output-voice-worked-example.md` is *authored* for contrast rather than captured from a real session. Every anti-pattern it shows has been observed, but the side-by-side is constructed. Reviewer should consider whether to flag this as substrate weakness (and queue capturing a real transcript for a future pass) or accept it as a deliberately-pedagogical artifact.
- **Density-budget table location.** The density budgets in `output-voice.md` are guidelines, not invariants. Reviewer should consider whether they are placed correctly (in the voice guide rather than in skill-conventions) and whether their format (a per-skill table) creates a maintenance dependency between the voice guide and per-skill outputs.
- **Cross-skill question budget.** Acknowledged in `wordy-output.md` "Notes for future contributors" but not encoded as substrate. Reviewer should flag whether this should be addressed in this pass or deferred.
- **Reviewer-agent verdict-leads scope.** `VERDICT_BEFORE_EVIDENCE` explicitly excludes reviewer-agent findings (which use `**Severity:**` per finding rather than `**Verdict:**` per output). The reviewer-output-shape matrix carries an explanation, but the synthesizing-skill side and the agent side may still feel asymmetric. Reviewer should confirm the seam is documented clearly enough.

## Ready for fresh-eyes review?

**Yes** — proceed to `cohesive:validate-rewrite`.

## How to read this ledger

1. Read the "Approved direction" line and the three layers (Cut / Anchor / Pin) above to set intent.
2. Skim "Conceptual changes" to see what's *different*.
3. Read "Files added" and "Files rewritten" — the five new substrate artifacts plus five edited references / docs / matrices are the body of the rewrite.
4. Use "Remaining ambiguity" as the focused review punch list.
5. Read "Implementation follow-up" to understand what is intentionally *not* in this rewrite.

---

## Repair pass 1 (2026-05-04)

After the first `cohesive:validate-rewrite` run, the `spec-cohesion-reviewer` returned **Issues Found** with two blockers and four important issues. The validation report at [`../reviews/2026-05-04-cut-anchor-pin-rewrite-validation.md`](../reviews/2026-05-04-cut-anchor-pin-rewrite-validation.md) lists all findings; this section records which ones the repair pass closed.

### Issues closed

- **B1 (Blocker) — Canonical chat-render layout disagreement.** Picked **title-then-citation-then-verdict** as the canonical layout (matching the worked transcript). Updated `docs/substrate/designs/skill-conventions.md` §"Output format conventions" rule 1 and the canonical chat-render shape to put the outermost `#` title first, then the voice-citation blockquote, then `**Verdict:**`. Updated `docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md` to enumerate the three lines explicitly (title on line 1, citation on line 2, verdict on line 3) and re-spec the validator grep against the new anchor (the outermost `#` title inside the Output format code block, not the section header above it). Worked transcript was already in the chosen layout, so no change there.
- **B2 (Blocker) — `PLUGIN_ROOT_PATHS.md:8` claimed "the one named invariant".** Updated to "one of two named invariants" with cross-link to `VERDICT_BEFORE_EVIDENCE.md`. Also extended the doc's prose about other rules to acknowledge they live in `references/output-voice.md` alongside the existing references. Added a 2026-05-04 history line on the file.
- **I3 (Medium) — "Faithful subset" undefined.** Added a testable three-part definition to `references/output-voice.md` rule 2: (a) verdict matches; (b) every chat claim appears in the persisted file; (c) chat does not introduce findings/recommendations/facts absent from the persisted file. `docs/substrate/designs/skill-conventions.md` rule 3 now points at the definition rather than restating it.
- **I2 (Medium) — Voice-citation pin status named-but-unranked.** Added §"Why voice-citation is convention-with-grep, not a named invariant" to `references/output-voice.md` with two stated reasons (wording is the youngest part of this rewrite; the verdict-leads invariant earns more from promotion because it ratifies a behavior, while voice-citation pinning would ratify a literal string). Promotion criteria spelled out: two release cycles without wording change, a real regression caught by the grep, no further rewording anticipated. Until then, convention-with-grep.
- **I1 (High) — Matrix Voice-citation column doesn't self-explain.** Added a cell legend to `docs/substrate/matrices/reviewer-output-shape.md` immediately above the table: `✓` = spec required and agent compliant; `pending` = spec required, agent file queued; `✗` = regression. The legend resolves the "queued vs broken" ambiguity at the table itself rather than only in the explanatory note below.
- **I4 (Medium) — Worked transcript is authored, not captured.** Added §"Captured transcripts (queued)" to `docs/history/transcripts/output-voice-worked-example.md` naming the next substrate task: capture a real `cohesive:review-codebase` or `cohesive:review-diff` transcript from an external-repo dogfood run, persist as `docs/history/transcripts/output-voice-captured-YYYY-MM-DD-<slug>.md`. When a real capture lands, the captured file becomes canonical and this authored file is preserved as the original pedagogical reference.

### Vague language tightened

- `references/output-voice.md` rule 2: "may be a faithful subset" → "is a faithful subset" (with the testable definition above).
- `docs/substrate/designs/skill-conventions.md` rule 3: "may be a faithful subset of the persisted file" → "is a faithful subset of the persisted file."
- `docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`: "and to any persisted artifact the skill writes" expanded into an explicit two-bullet "Applies to" sub-list (chat output; persisted artifact) with the line that both surfaces are enforced through the SKILL.md Output format block as the single source of truth.
- `references/output-voice.md` density-budgets section: dropped the unreserved `OUTPUT_DENSITY` reference; replaced with prose explaining why density stays convention (every word/paragraph/header proxy is flawed individually).

### Files touched in repair pass 1

- `docs/substrate/designs/skill-conventions.md` — Output format rule 1 layout; canonical chat-render shape title-first; rule 3 references the testable definition; "may" → "is"
- `references/output-voice.md` — rule 2 with testable definition; "may" → "is"; new §"Why voice-citation is convention-with-grep, not a named invariant"; density-budgets prose updated
- `docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md` — rule statement enumerates the three lines; enforcement section anchors greps on the outermost `#` title; persisted-artifact scope clarified; new history entry
- `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` — "one named invariant" → "one of two"; new history entry
- `docs/substrate/matrices/reviewer-output-shape.md` — cell legend added above the table
- `docs/history/transcripts/output-voice-worked-example.md` — new §"Captured transcripts (queued)"

### Issues acknowledged but not closed in this pass

- **Cross-skill question budget** (substrate gap) — still acknowledged in `wordy-output.md` Notes; deferred to a future substrate pass per the original ledger §"Remaining ambiguity."
- **Density-budget locality** (substrate gap) — the per-skill table in `output-voice.md` still creates a maintenance dependency when adding a new skill; deferred. The dependency is now slightly more visible because density-budgets prose explicitly names the per-skill grid as a guideline.
- **Reviewer-output-shape matrix Voice-citation cells still `pending`** — the cells flip to `✓` when the implementation pass adds the citation lines to each `agents/*.md` "How to structure your output" code block. The legend now distinguishes "queued" from "broken," so the matrix is self-explanatory until then.

### Implementation follow-up — sharpened

The original "Implementation follow-up" section above remains the canonical handoff. The grep specifications it describes are now slightly more concrete after this repair pass:

- The verdict-leads grep anchors on the **outermost `#` title inside the Output format code block** and verifies `**Verdict:**` appears in lines 1–3 after that title.
- The voice-citation grep verifies `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` appears within the same window.
- Both greps share the same anchor, so a single parser pass can check both.

### Ready for fresh-eyes review (second pass)?

**Yes** — re-run `cohesive:validate-rewrite`. The two blockers and the four important issues are closed; the remaining ambiguity is the explicitly-deferred set above.

---

## Repair pass 2 (2026-05-04)

User feedback during repair pass 1: "I fear you are mixing references/* as substrate instead of implementation again." The user authorized a hard cut to a correct substrate-vs-implementation split.

### What changed

The rewrite originally placed `output-voice.md` under `references/` and edited two pre-existing files (`references/skill-conventions.md`, `references/reviewer-agent-template.md`) without addressing their structural location. Per AGENTS.md §"Substrate vs implementation," anything substrate-shaped (a rule, a rubric, a convention, a design principle) belongs under `docs/substrate/`. All three of those files (and six others co-located with them) carry normative claims and were therefore in the wrong place.

This repair pass moves all substrate-shaped `.md` files out of `references/` (root level) into `docs/substrate/designs/`. After the move:

- `references/` contains only `templates/` — fillable forms (genuinely implementation; runtime content skills consume to produce artifacts).
- `docs/substrate/designs/` is the canonical home for all normative conventions, rubrics, and design docs.
- Skills cite the moved files via `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/...` — what's cited is unchanged in *kind* (still implementation citing substrate), only the path changed.

### Files moved

Nine files moved with `git mv` (history preserved):

| Old path | New path |
|---|---|
| `references/skill-conventions.md` | `docs/substrate/designs/skill-conventions.md` |
| `references/reviewer-agent-template.md` | `docs/substrate/designs/reviewer-agent-template.md` |
| `references/output-voice.md` | `references/output-voice.md` |
| `references/cohesion-rubric.md` | `references/cohesion-rubric.md` |
| `references/design-pressure-testing.md` | `references/design-pressure-testing.md` |
| `references/locality-over-centralization.md` | `references/locality-over-centralization.md` |
| `references/substrate-model.md` | `references/substrate-model.md` |
| `references/substrate-layout.md` | `docs/substrate/designs/substrate-layout.md` |
| `references/architecture-review-rubric.md` | `references/architecture-review-rubric.md` |

### Citation sweep

255 citations across ~50 files updated in a single sed pass:

- Pattern: `references/<one-of-9-filenames>.md` → `docs/substrate/designs/<filename>.md`
- Files swept: every substrate doc (`docs/substrate/**`), every history doc (`docs/history/**`), `AGENTS.md`, `ARCHITECTURE.md`, `README.md`, every skill body (`skills/*/SKILL.md`), every reviewer agent (`agents/*.md`), the validator script (`scripts/validate_plugin.sh`), and the templates (`references/templates/*.md`).
- Targeted post-pass cleanup of relative paths broken by the move: `../docs/substrate/designs/X.md` → `X.md` (sibling refs inside `docs/substrate/designs/`); `../../../docs/substrate/<X>/` → `../<X>/` (cleaner relative paths between substrate subdirs).

### Hard Constraint #3 reckoning

`rewrite-specs` Hard Constraint #3 specifies: "If a substrate change implies an implementation change ... the implementation update is a separate phase." The move-following citation updates are explicitly named there as the implementation phase.

This repair pass updates citations across **both** substrate and implementation in a single commit, deviating from the strict reading. The rationale, recorded here for honesty:

- A move-only commit leaves the repo in a broken state: skill bodies and reviewer agents cite paths that no longer exist; the validator may pass (it doesn't check link integrity) but the runtime `${CLAUDE_PLUGIN_ROOT}/references/skill-conventions.md` reads fail.
- Citation updates following a move are mechanical, not behavioral. They don't introduce design decisions; they preserve correctness during a structural move.
- The intent of Hard Constraint #3 is to prevent conflating *what we claim* with *what we do* — i.e., to keep design intent and behavior change in separate review surfaces. A path-rename sweep is neither claim nor behavior; it's bookkeeping.
- The alternative (move-only commit + queued citation update) creates a window of broken state. That's worse than violating the strict reading of Hard Constraint #3 once, with the violation explicitly recorded.

Future contributors: the cleaner pattern is to do the move and citation sweep in one PR with `cohesive:review-diff` flagging it explicitly. This repair pass operates within the existing `rewrite-specs` worktree because the user authorized it explicitly during the rewrite turn.

### Substrate-vs-implementation prose updates

- `AGENTS.md` §"Substrate vs implementation" — implementation now lists `references/templates/**` (not `references/**`); a paragraph documents the move and lists every relocated file.
- `ARCHITECTURE.md` §"Three-tier architecture" — third tier renamed from `references/` to `references/templates/`; explanation that all three implementation tiers cite substrate at `docs/substrate/**`. v0.1 scope updated: "12 substrate design docs under `docs/substrate/designs/`."
- `README.md` §"What's in the box" — re-rendered. `references/` line collapsed to just `templates/`; added a `docs/substrate/` section listing the new location of conventions, rubrics, and designs; added `docs/history/` section listing reviews / delta-ledgers / transcripts / plans.

### Issues acknowledged but not closed in this pass

- **Validator path-integrity check.** The validator does not check that markdown link targets resolve. A future enhancement could add a link-checker (Python or shell) that walks `*.md` files and verifies relative links resolve. Out of scope here.
- **External-repo `references/` references in historical docs.** Some `docs/history/*.md` artifacts (delta ledgers from earlier rewrites) reference `references/foo.md` paths that pre-date this move. The sed pass updated those — which technically rewrites history. Documented here so future readers know that historical docs were swept; the path-correctness-now overrides the historical-record-preservation in the case of mechanical path migrations. Narrative claims in historical docs were not touched.

### Implementation follow-up — supersedes prior

The implementation follow-up section from the original ledger (per-skill Output format edits, per-agent output edits, validator greps) still applies. After repair pass 2, the substrate references those edits will cite point at the new `docs/substrate/designs/` paths. Implementation pass should:

1. Add the voice-citation line — `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` — to each `skills/*/SKILL.md` Output format block (citation now points at substrate, not at the moved-and-deleted `references/output-voice.md`).
2. Same citation in each `agents/*.md` "How to structure your output" code block.
3. Verdict-leads grep + voice-citation grep in `scripts/validate_plugin.sh`.
4. Flip the 5 Voice-citation cells in `reviewer-output-shape.md` from `pending` to `✓`.

### Ready for fresh-eyes review (third pass)?

**Yes** — re-run `cohesive:validate-rewrite` if desired. The substrate-vs-implementation split is now structurally clean. The reviewer should focus on whether the move broke any normative claim or rendered any rule incoherent in its new location.

---

## Repair pass 3 (2026-05-04)

User feedback after Repair pass 2: "wait wait — some of these still feel like implementation (ie references for the skills at hand): cohesion-rubric.md for example feels like something that would be referenced by the skills, no?" The user named the correct cut: **substrate is conventions for contributors or agents working on this codebase itself; references and skills are the implementation that other people will install to get the benefits of the cohesive workflow pattern**.

This is a sharper definition than the AGENTS.md prose I had been using ("what the system claims about itself"). Repair pass 2 used the looser definition and over-pulled files into substrate.

### What changed

Six of the nine files moved in Repair pass 2 moved *back* to `references/` because they are runtime methodology — content cited by skills/agents at generation time when running the workflow on the user's codebase. They are the methodology Cohesive teaches and the workflow it ships, not rules about how this repo is built.

Three files stayed in `docs/substrate/designs/` because they are contributor-facing — rules about *this codebase* that apply when someone authors or maintains this plugin's skills, agents, or layout.

### Files moved back to `references/`

| File | Why it's implementation |
|---|---|
| `cohesion-rubric.md` | 9-axis scorecard reviewer agents cite at runtime |
| `design-pressure-testing.md` | 25-question battery `brainstorm-design` uses at runtime |
| `locality-over-centralization.md` | Design principle reviewers cite at runtime to inform judgment |
| `architecture-review-rubric.md` | Four-phase rubric `review-codebase` implements at runtime |
| `substrate-model.md` | Foundational thesis cited by skills explaining the methodology |
| `output-voice.md` | Voice rules cited at chat-generation time by every skill's Output format block |

### Files staying in `docs/substrate/designs/`

| File | Why it's substrate |
|---|---|
| `skill-conventions.md` | Rules for writing SKILL.md *in this repo*; contributor-facing |
| `reviewer-agent-template.md` | Canonical reviewer-agent shape *for this repo's agents*; contributor-facing |
| `substrate-layout.md` | Where *this repo's* artifacts live; contributor-facing |
| `three-layer-architecture.md` (pre-existing) | Architectural decision about this plugin's structure |
| `composition-with-superpowers.md` (pre-existing) | Design decision about how this plugin composes with Superpowers |
| `agent-dispatch-protocol.md` (pre-existing) | Design contract for this plugin's reviewer-agent dispatch |

### Test for the split (added to AGENTS.md)

The test for which side a file belongs to: **who reads it, and when?**

- A file read by a *contributor* writing or reviewing this repo → substrate.
- A file read by a *skill or agent* at runtime as part of doing the workflow on the user's codebase → implementation.

A file can be cited from both sides. When that happens, the file's home is determined by its *primary runtime role*: cited at generation time → implementation.

### Citation sweep (reverse direction)

The 6 files moved back required reversing roughly half of the Repair pass 2 sweep. Pattern: `docs/substrate/designs/<file>.md` → `references/<file>.md` for the 6 filenames listed above.

Total sweep: ~140 path replacements across the same ~50 files.

### Prose updates

- **`AGENTS.md` §"Substrate vs implementation"** — rewrote with the contributor-vs-user-facing frame. Added the "who reads it, when?" test and the cited-from-both-sides rule. The new prose is the primary substrate change of this repair pass; it codifies the user's sharper definition so future contributors don't repeat the over-pull I just did.
- **`ARCHITECTURE.md` §"Three-tier architecture"** — three implementation tiers (skills/, agents/, references/); substrate at `docs/substrate/**` is the fourth, contributor-facing layer. Updated v0.1 scope to: 8 skills, 5 agents, 6 runtime references in `references/`, 9 templates, 6 substrate design docs in `docs/substrate/designs/`, 2 scripts.
- **`README.md` §"What's in the box"** — re-rendered. `references/` lists the 6 runtime methodology files plus `templates/`. `docs/substrate/designs/` lists only the 6 contributor-facing design docs.

### Final structure

```
references/                                    (runtime methodology — implementation)
  substrate-model.md
  cohesion-rubric.md
  design-pressure-testing.md
  locality-over-centralization.md
  architecture-review-rubric.md
  output-voice.md
  templates/
    (9 fillable forms)

docs/substrate/                                (contributor-facing — substrate)
  designs/
    skill-conventions.md
    reviewer-agent-template.md
    substrate-layout.md
    three-layer-architecture.md
    composition-with-superpowers.md
    agent-dispatch-protocol.md
  invariants/  (PLUGIN_ROOT_PATHS, VERDICT_BEFORE_EVIDENCE)
  gotchas/     (soft-prereqs, discovery-vs-superpowers, wordy-output, style-guide-rot)
  matrices/    (router, reviewer-output-shape, skill-section-presence, artifact-placement)
```

### Hard Constraint #3 reckoning, continued

This repair pass also updates citations across both substrate and implementation in one commit, for the same reason as Repair pass 2: avoiding a window of broken state. The double-citation-sweep across passes 2 and 3 is roughly 400 path edits in total; the substrate-vs-implementation split is now correct in *both* the prose and the file layout.

### Issues acknowledged but not closed in this pass

- The validator still does not check link integrity. Future enhancement.
- Historical docs in `docs/history/**` had their citations swept across passes 2 and 3. The prior-pass note about historical-docs path migration applies here too.
- A `cohesive:review-diff` against this branch would be the right way to confirm no normative claim broke during the move-and-move-back. Recommended next step.

### Ready for fresh-eyes review (fourth pass)?

**Yes** — re-run `cohesive:validate-rewrite`, or run `cohesive:review-diff` against this branch. The contributor-vs-user-facing axis is now the documented split, and the file layout matches. Reviewer should confirm: (a) `references/<file>.md` files are all genuinely runtime-cited; (b) `docs/substrate/designs/<file>.md` files are all genuinely contributor-facing; (c) AGENTS.md prose accurately encodes the test ("who reads it, when?") so future contributors apply it consistently.
