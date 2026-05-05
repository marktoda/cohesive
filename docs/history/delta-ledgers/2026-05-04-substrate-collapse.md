# Design Delta Ledger — Substrate Collapse

**Date:** 2026-05-04
**Worktree / branch:** `.worktrees/cohesive-substrate-collapse` on `design/substrate-collapse`
**Approved direction:** Collapse v0.1's substrate to one named invariant; demote the other four to conventions; split `cohesive-review --scope substrate` into a standalone `substrate-audit` skill; delete consumer-less templates; reconcile delta-ledger and review-output paths; drop the "when CI lands" hedge; honest DoD on transcripts.

The driver: post-Phase-1 architecture review at [`docs/history/reviews/2026-05-04-post-phase-1-architecture-review.md`](../reviews/2026-05-04-post-phase-1-architecture-review.md) found that the substrate had been *making false enforcement claims* — every named invariant doc asserted `validate_plugin.sh` enforcement that didn't exist, and the corpus had drifted from canonical wording across 4 of 5 agents and 5 of 6 skills. The substrate-model thesis says judgment must become structural OR it degrades to folklore; v0.1 was in a third state — folklore that *claimed* to be enforced, which is worse than admitted folklore. The collapse honestly says: one invariant earns its name (PLUGIN_ROOT_PATHS, the only rule with a real runtime failure mode); the rest are conventions until their wording stabilizes and a real failure mode justifies promotion.

## Files rewritten

- `ARCHITECTURE.md`
  - **Before:** named five v0.1 invariants in §"Substrate"; cited `FRESH_EYES_DISPATCH` as the load-bearing safety property in §"Fresh-eyes review"; listed 6 skills + 9 templates.
  - **After:** names one invariant (`PLUGIN_ROOT_PATHS`); fresh-eyes-review section attributes the load-bearing fence to harness subprocess isolation with the agent-file preamble as convention reinforcement; lists 7 skills + 7 templates; adds a "Local validation only" line dropping the CI-landing hedge; adds a "Conventions over invariants" entry to "Risks the design accepts."
  - **Reason:** ARCHITECTURE is the binding doc; it must accurately describe what is enforced and what is convention.

- `AGENTS.md`
  - **Before:** §"Named invariants (read these before changing anything)" enumerated five; "When you are about to..." cross-referenced `ROUTER_ANNOUNCES_BEFORE_DISPATCH`, `ONE_PRECISE_QUESTION`, `FRESH_EYES_DISPATCH`; §"Default substrate locations" said `delta-ledgers/`; §48 gated v0.1 on two transcripts.
  - **After:** §"The one named invariant" lists only `PLUGIN_ROOT_PATHS` with explicit framing of why it earns the name; "When you are about to..." routes contributors through `docs/substrate/designs/skill-conventions.md` and `docs/substrate/designs/reviewer-agent-template.md` for the demoted rules; transcripts are no longer release-gating ("v0.1 ships one architecture-review artifact; further dogfood is welcome but not gating").
  - **Reason:** Contributor entry point must accurately reflect the one-invariant world; release-gate honesty.

- `README.md`
  - **Before:** line 63 wrote architecture-review output to `docs/cohesive/reviews/`; §"What's in the box" listed `cohesive-review/ Codebase | diff | substrate review`; templates list mentioned `implementation plan`.
  - **After:** review output is `docs/history/reviews/`; cohesive-review listed as `Codebase | diff review`; new `substrate-audit/ Substrate audit — what memory is missing` line; templates list updated to drop `implementation plan` and `semantic linter`; new entries for `skill-conventions.md`, `reviewer-agent-template.md`, `substrate-layout.md`.
  - **Reason:** Source-of-truth hierarchy says README is derived from ARCHITECTURE + on-disk reality; this brings it back into sync.

- `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md`
  - **Before:** elaborate "Enforcement" section enumerating Tests / Types / Constraints / Semantic linters / Runtime wrappers / CI checks (most empty or speculative); blockquote at top read "No hardcoded absolute paths, ever."
  - **After:** single-paragraph Enforcement section describing what `validate_plugin.sh` actually does; blockquote frames the failure mode ("Hardcoded absolute paths break the plugin for every user who isn't the original author"); explicit framing that this is "the one named invariant Cohesive ships at v0.1" and why other v0.1 rules earned only convention status.
  - **Reason:** Drop the elaborate enforcement schema in favor of describing what's actually enforced.

- `docs/substrate/designs/skill-conventions.md`
  - **Before:** had a §"Output format conventions" pointing at `SUBSKILL_RECOMMENDS_NEXT`; §"Dispatch discipline" pointing at `FRESH_EYES_DISPATCH`; §"Clarifying questions" pointing at `ONE_PRECISE_QUESTION`. Each treated the rule as enforced by a named invariant.
  - **After:** absorbs all three rules as conventions in their own right; new §"Router conventions" carries the announcement form and clarifying-question rule that previously lived as named invariants in the router. Frontmatter now opens by stating that the conventions are reviewer-judged, not mechanically enforced — "treating them as conventions is deliberate." `SUBSKILL_RECOMMENDS_NEXT.md`'s per-verdict rule and non-Cohesive-next-step rule both folded in.
  - **Reason:** This is now where the four demoted rules canonically live.

- `docs/substrate/designs/reviewer-agent-template.md`
  - **Before:** §"The fresh-eyes preamble (load-bearing — verbatim)" framed the bullet as "the textual half of named invariant `FRESH_EYES_DISPATCH`"; anti-pattern table cited "Breaks `FRESH_EYES_DISPATCH`" as the failure mode.
  - **After:** §"The fresh-eyes preamble (convention)" frames verbatim copy as the safest default and points at `agent-dispatch-protocol.md` for the property's actual structural fence (harness subprocess isolation); anti-pattern column reads "Drift across agent files; loosens convention reinforcement."
  - **Reason:** Honest framing of where the load-bearing fence lives.

- `skills/cohesive-review/SKILL.md`
  - **Before:** three modes — `--scope codebase`, `--scope diff`, `--scope substrate`; ~40 lines of mode-conditional branching; substrate mode dispatched zero agents.
  - **After:** two modes — `--scope codebase` and `--scope diff`. Substrate-audit work routes to the new standalone `substrate-audit` skill with explicit cross-references. Each mode's output schema now ends with a per-verdict "Recommended next Cohesive skill" footer with concrete next-step recommendations.
  - **Reason:** The substrate mode shared no machinery with codebase/diff; merging them was a category error. Splitting realigns skill boundaries with the route boundaries the router already encodes.

- `skills/cohesively/SKILL.md`
  - **Before:** §"Required behavior" framed the announcement and one-question rules as load-bearing properties of the router's invariants; route R007 chained `discover-substrate → cohesive-review --scope substrate`.
  - **After:** §"Required behavior" cites the conventions doc as the rule's home; route R007 chains `discover-substrate → substrate-audit`; default-route language updated to use the new route name.
  - **Reason:** Conventions live in `skill-conventions.md`; substrate-audit is its own skill.

- `docs/substrate/designs/agent-dispatch-protocol.md`
  - **Before:** §"Both halves are required" closed with "This is the textual half of `FRESH_EYES_DISPATCH`"; §"Concrete dispatch sites in v0.1" claimed the prior self-review confirmed agent-side preamble compliance; §"Enforcement" promised a `validate_plugin.sh` grep.
  - **After:** load-bearing fence attributed to harness subprocess isolation; agent-file preamble and skill-side prose framed as convention reinforcement; honest acknowledgment that the prior self-review's compliance claim was incorrect and that the wording had drifted; §"Enforcement" describes the structural fence (harness) plus the convention reinforcement (reviewer-judged); explains why this design doc, not a named invariant, is the canonical home.
  - **Reason:** This design doc was already explaining the property in detail; with `FRESH_EYES_DISPATCH` demoted, this becomes the single source of truth for what the property is and why it holds.

- `docs/substrate/designs/three-layer-architecture.md`
  - **Before:** §"Related substrate" listed `FRESH_EYES_DISPATCH.md` as the load-bearing safety property.
  - **After:** points at `agent-dispatch-protocol.md` for the property; ties it to harness subprocess isolation plus convention reinforcement.
  - **Reason:** Cross-reference cleanup after demotion.

- `docs/substrate/gotchas/soft-prereqs.md`
  - **Before:** §"Related invariant" cited `ONE_PRECISE_QUESTION` and `SUBSKILL_RECOMMENDS_NEXT`; body called the canonical question "a compliant `ONE_PRECISE_QUESTION`."
  - **After:** §"Related conventions" points at `skill-conventions.md` sections; body refers to "the clarifying-question convention."
  - **Reason:** Cross-reference cleanup.

- `docs/substrate/gotchas/discovery-vs-superpowers.md`
  - **Before:** §"Related invariant" cited `ROUTER_ANNOUNCES_BEFORE_DISPATCH`.
  - **After:** §"Related convention" points at `skill-conventions.md` §"Router conventions."
  - **Reason:** Cross-reference cleanup.

- `docs/substrate/matrices/router.md`
  - **Before:** R007 chain mentioned `cohesive-review --scope substrate`; cells R009 and R900 cited `ONE_PRECISE_QUESTION`; rules section cited `ROUTER_ANNOUNCES_BEFORE_DISPATCH`; "Related substrate" listed two demoted invariant docs.
  - **After:** R007 chains to `substrate-audit`; convention citations replace invariant citations; "Related substrate" points at the conventions doc; History section gains a 2026-05-04 entry recording the collapse.
  - **Reason:** Cross-reference cleanup + honest record of what changed.

- `docs/substrate/designs/substrate-layout.md`
  - **Before:** layout block omitted `designs/`; naming table omitted Design and Transcript rows; growth pattern had four phases that didn't mention `designs/`.
  - **After:** layout block adds `designs/` and `transcripts/`; naming table adds rows for Design and Transcript; growth pattern is five phases naming when `designs/` typically appears.
  - **Reason:** Closes the documentation gap that the post-Phase-1 architecture review flagged: the `designs/` tier is load-bearing in `ARCHITECTURE.md` and `AGENTS.md` but was unowned by the canonical layout doc.

## Files added

- `skills/substrate-audit/SKILL.md` — new standalone skill carved out of `cohesive-review --scope substrate`. Single-pass scan; no reviewer-agent dispatch. Output written to `docs/history/reviews/YYYY-MM-DD-<slug>-substrate-audit.md`. Composition note: precedes `rewrite-specs` when the audit's findings warrant turning into artifacts.

## Files removed

- `docs/substrate/invariants/FRESH_EYES_DISPATCH.md` — demoted to convention. The property remains real and load-bearing (the harness's Task-subprocess isolation enforces it structurally); `agent-dispatch-protocol.md` and `reviewer-agent-template.md` carry the convention now.
- `docs/substrate/invariants/ROUTER_ANNOUNCES_BEFORE_DISPATCH.md` — demoted. The announcement form is documented in `skill-conventions.md` §"Router conventions" and `cohesively/SKILL.md`'s "Required behavior."
- `docs/substrate/invariants/ONE_PRECISE_QUESTION.md` — demoted. The clarifying-question rule is documented in `skill-conventions.md` §"Clarifying questions."
- `docs/substrate/invariants/SUBSKILL_RECOMMENDS_NEXT.md` — demoted. The recommended-next-skill rule is documented in `skill-conventions.md` §"Output format conventions."
- `references/templates/implementation-plan.md` — consumer-less abstraction. No skill produces it; no agent reads it. Recreate alongside the consuming skill in V1 if `plan-implementation` ships.
- `references/templates/semantic-linter-spec.md` — consumer-less abstraction. Same reasoning.

## Renamed

- `docs/history/design-changes/` → `docs/history/delta-ledgers/`
  - **Before:** AGENTS.md and on-disk used `design-changes/`; every skill body and `docs/substrate/designs/substrate-layout.md` used `delta-ledgers/`.
  - **After:** unified to `delta-ledgers/` because that name matches the canonical artifact name (`design-delta-ledger`) used in templates. AGENTS.md was patched to match.
  - **Reason:** Schism between AGENTS.md and the skill bodies meant a future `rewrite-specs` would write to one location while contributors read from another.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| Five named invariants | One named invariant + four conventions | Tightened. The four demoted rules still exist as rules; they no longer carry the named-invariant ceremony or claimed validator enforcement. |
| `cohesive-review --scope substrate` | Standalone `substrate-audit` skill | Split. The codebase/diff review and the missing-memory audit shared no machinery; treating them as one skill was a category error. |
| Validator enforces five invariants | Validator enforces one invariant + structural shape | Honest framing. The validator is unchanged at the script level; what changed is the substrate's claim about it. |
| Transcripts gate v0.1 release | Transcripts welcome, not gating | Honest DoD. The post-Phase-1 architecture review at `docs/history/reviews/2026-05-04-post-phase-1-architecture-review.md` is the v0.1 dogfood artifact; the design rewrite this ledger records is a second one in flight. |
| `design-changes/` | `delta-ledgers/` | Renamed. One canonical name for the artifact across all references. |

## New or updated substrate

### Specs (rewritten)
- `ARCHITECTURE.md` — names one invariant; "Local validation only" replaces "when CI lands" hedge; v0.1 scope updated to 7 skills.
- `AGENTS.md` — §"The one named invariant"; honest DoD on transcripts.
- `README.md` — `docs/history/reviews/` path; substrate-audit listed; templates list updated.
- `docs/substrate/designs/skill-conventions.md` — absorbs the four demoted rules; §"Router conventions" added; opening framing of conventions-as-reviewer-judged.
- `docs/substrate/designs/reviewer-agent-template.md` — §"The fresh-eyes preamble (convention)" reframed.
- `docs/substrate/designs/substrate-layout.md` — `designs/` and `transcripts/` rows added.
- `skills/cohesive-review/SKILL.md` — two-mode skill; per-verdict footers.
- `skills/cohesively/SKILL.md` — substrate-audit chained as standalone skill; convention-doc cross-references.
- `docs/substrate/designs/agent-dispatch-protocol.md` — fence-attribution honest; demotion explained.
- `docs/substrate/designs/three-layer-architecture.md` — cross-references.
- `docs/substrate/matrices/router.md` — R007 chain; convention citations.
- `docs/substrate/gotchas/soft-prereqs.md`, `discovery-vs-superpowers.md` — convention citations.

### Behavior matrices
- `docs/substrate/matrices/router.md` — R007 chain switched (substrate-audit standalone skill); rules and "Related substrate" updated.

### Named invariants
- `PLUGIN_ROOT_PATHS` — kept; doc simplified (dropped elaborate Tests/Types/Constraints/Semantic-linters/Runtime-wrappers/CI-checks schema); blockquote framing tightened to name the failure mode.
- `FRESH_EYES_DISPATCH`, `ROUTER_ANNOUNCES_BEFORE_DISPATCH`, `ONE_PRECISE_QUESTION`, `SUBSKILL_RECOMMENDS_NEXT` — removed as named invariants; the underlying rules survive as conventions.

### Gotchas
- No new gotchas. Existing two updated to point at conventions instead of demoted invariants.

### Semantic linter specs
- None. The collapse drops the elaborate enforcement-schema vocabulary in favor of describing what `validate_plugin.sh` actually does.

### Tests / checks proposed (not yet implemented)
- `validate_plugin.sh` should add a `${CLAUDE_PLUGIN_ROOT}` discipline grep and a hardcoded-path grep that respects anti-pattern fenced blocks. The implementation lands in a follow-up; this rewrite describes the validator's intended state but does not change the script.

## What this rewrite *did not* do

- **Implementation code:** unchanged. `scripts/validate_plugin.sh` is unchanged at the script level. `scripts/scan_substrate.py` is unchanged. The collapse describes what the validator should enforce; landing the new grep is implementation work in a follow-up pass.
- **CI:** unchanged. The collapse drops the "when CI lands" hedge from invariant docs but does not add a workflow file. v0.1 is local-validation-only by design.
- **Reviewer-agent files:** unchanged. The fresh-eyes preamble drift across 4 of 5 agent files identified by the post-Phase-1 architecture review is *not* swept here. The collapse demotes the verbatim-bullet rule to convention; the drift is now drift-from-convention rather than drift-from-invariant. A future tightening pass can sweep all five agents to the canonical wording when the wording itself stabilizes.
- **Skill-output sweeps:** unchanged. The 5-of-6 drift in "Recommended next Cohesive skill" heading wording is not swept. Same reasoning: convention rather than invariant; sweep when wording stabilizes.

These deferrals are deliberate. The substrate-collapse thesis is "stop claiming enforcement that doesn't exist"; doing the corpus sweeps now would re-introduce a brittle verbatim-text contract that v0.1 hasn't earned.

## Remaining ambiguity

- **Should `cohesively/SKILL.md` add a per-route "Recommended next Cohesive skill" footer?** The router was previously exempt from the recommended-next-skill rule because its output is an announcement, not a workflow output. Conventions doc preserves that exemption. Worth re-checking in fresh-eyes review whether the exemption is still right or whether the router should also recommend explicitly when a route ends inside Cohesive vs. hands off to Superpowers.
- **Architecture-review-rubric scope.** The rubric title is "Architecture review rubric" and it implements `cohesive-review --scope codebase`. With substrate-audit split out, the title is accurate. But the rubric never described substrate mode anyway, so no edits were made. Worth confirming nothing references the rubric as covering substrate-audit.
- **Reviewer-agent count update.** ARCHITECTURE.md says 5 reviewer agents; that's still accurate (substrate-audit doesn't dispatch any). README "What's in the box" says the same. Confirmed consistent.
- **`design-pressure-testing.md:94` reference inversion.** Flagged by both the prior self-review and the post-Phase-1 review. Not addressed in this collapse pass; remains a Low-severity carry-over for a future cleanup.

## Ready for fresh-eyes review?

**Yes.** The rewrite is internally consistent: the source-of-truth hierarchy holds, every cross-reference resolves, the conventions doc absorbs the four demoted rules, and the substrate-audit split aligns skill boundaries with the route boundaries the router already encoded. Deliberate non-changes (validator script, CI, corpus sweeps) are documented above. Fresh-eyes should focus on (a) whether the conventions doc captures the four demoted rules faithfully, (b) whether `agent-dispatch-protocol.md` is now the right canonical home for the fresh-eyes property, and (c) whether the substrate-audit skill is fully separable from cohesive-review or still has hidden coupling.

## How to read this ledger

1. Read the "Approved direction" line and know the destination.
2. Skim "Conceptual changes" and know what's *different*.
3. Read "Files rewritten" with before/after to verify each rewrite.
4. Use "Remaining ambiguity" as the focused review punch list.
