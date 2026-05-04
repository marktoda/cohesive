# Cohesive Architecture Review — Skill Architecture & Agent Prompt Quality

**Date:** 2026-05-04
**Scope:** Cohesive plugin skills+agents tiers (post-substrate-collapse-repair state)
**Reviewers dispatched:** structure-reviewer, agent-readiness-reviewer (focused subset; substrate-alignment and library-native skipped because just-covered in `2026-05-04-post-phase-1-architecture-review.md` and `2026-05-04-substrate-collapse-repair.md`)
**Substrate discovery:** reused from prior session passes
**Prior reviews:** [`2026-05-04-post-phase-1-architecture-review.md`](2026-05-04-post-phase-1-architecture-review.md), [`2026-05-04-self-review.md`](2026-05-04-self-review.md)

---

## Verdict

**Mostly healthy.**

## Thesis

The post-collapse skill architecture is structurally sound — the substrate-audit split repaired the one real category error, three-tier separation holds, and conventions-vs-invariant boundaries are explicit. But three specific sharp edges keep this from "Healthy." Two of them are about implicit contracts that propagate sloppiness silently, and one is about agent prompt concision: **all five agent files are missing the token-discipline note that `references/reviewer-agent-template.md:119-121` explicitly requires.** The two reviewers dispatched for this very review both produced ~2K-word reports rather than the bounded ones the convention demands — the failure mode is observable in this very review's tooling. The sharp edges are small in code-mass but high in user-experience leverage.

## Cohesion scorecard

| Axis | Rating |
|---|---|
| Spec coherence | Healthy |
| Code/spec alignment | Mostly healthy |
| Domain model clarity | Mostly healthy (god-document risk on discovery output) |
| Invariant enforcement | Mostly healthy (the one named invariant is honest about current/intended state) |
| Test guarantees | Drifting (no transcripts; no agent-output schema check) |
| Locality and seams | Healthy |
| Library-native alignment | Mostly healthy |
| Agent-readiness | **Drifting** (token-discipline missing; output-shape drift; sharp edges in soft-prereqs) |
| Future extensibility | Mostly healthy |

## Highest-leverage findings

Organized under the three sub-questions the reviewers were asked.

### A. Skill architecture & composability

#### 1. `discover-substrate` output is an implicit-contract god-document

**Severity:** High
**Category:** Locality / Seam
**Why it matters:** Five downstream skills (`brainstorm-design`, `rewrite-specs`, `cohesive-review --scope codebase`, `cohesive-review --scope diff`, `substrate-audit`) all consume discovery's output, each wanting a different cut. The format lives only as inline prose in `skills/discover-substrate/SKILL.md:101-142`, not as a `references/templates/substrate-discovery-report.md`. This is the only universally-consumed artifact in the plugin without a shared template. If the format drifts, every consumer drifts independently.
**Evidence:** `skills/discover-substrate/SKILL.md:101-142`; `references/templates/` (8 templates, none for the discovery report); 5 consumer skills re-state expected shape in prose.
**Recommended fix:** Promote to `references/templates/substrate-discovery-report.md` and have all 5 consumers reference it by path.
**Substrate artifact to add or update:** New template + cross-references.

#### 2. `brainstorm-design → rewrite-specs` hand-off is via human memory

**Severity:** High
**Category:** Seam
**Why it matters:** Brainstorm produces a long structured report in chat only; rewrite-specs requires "the chosen direction." The router masks this by chaining; direct invocation forces the user to copy/paste. Router cell R008 ("rewrite-only with named direction") assumes the user remembered the direction.
**Evidence:** `skills/brainstorm-design/SKILL.md` has no Persistence section; `skills/rewrite-specs/SKILL.md:46-49` lists "the recommended direction from `brainstorm-design`" as input — but it's conversation-only.
**Recommended fix:** Persist brainstorm output to `docs/history/brainstorms/YYYY-MM-DD-<slug>.md` so rewrite-specs can read it as a path. Alternative: explicit "conversation-only" declaration. Either way, document the choice.
**Substrate artifact to add or update:** Brainstorm-design persistence section + new history subdir.

#### 3. `cohesive-review` codebase + diff bundling sits at threshold that triggered substrate split

**Severity:** Medium
**Category:** Concept clarity
**Why it matters:** Codebase has Phase 1/2/3/4/5 + 4 agents + persistence; diff has 2 agents + chat-only. They share Phase-1 + reviewer-dispatch primitives but otherwise diverge. Currently fine; the duplication risk is the same one that justified the substrate-mode split.
**Evidence:** `skills/cohesive-review/SKILL.md:38-108` (codebase) vs `:110-167` (diff) — disjoint process bodies.
**Recommended fix:** Don't split for v0.1. Document the deliberate keep-together with a trigger condition for revisiting in `ARCHITECTURE.md` §"Risks the design accepts."
**Substrate artifact to add or update:** ARCHITECTURE.md risks section.

### B. Sharp edges for users

#### 4. `rewrite-specs` Hard constraint #1 invites the soft-prereqs failure mode

**Severity:** High
**Category:** Hidden rule / Sharp edge
**Why it matters:** `skills/rewrite-specs/SKILL.md:18` says "If `brainstorm-design` hasn't recommended a direction… stop and route to `brainstorm-design`." Per `docs/substrate/gotchas/soft-prereqs.md:13-23`, this detection is exactly the failure mode — Claude defaults to "do I remember a brainstorm earlier?" producing false positives. The Hard constraint as written invites the bug the gotcha names. Same pattern in `brainstorm-design` and `cohesive-review` Step 0.
**Evidence:** `skills/rewrite-specs/SKILL.md:18` vs `docs/substrate/gotchas/soft-prereqs.md:34-47`.
**Recommended fix:** Replace with the canonical forced-choice question from the gotcha. Sweep all three subskills.
**Substrate artifact to add or update:** Three skill bodies + convention reinforcement in `skill-conventions.md`.

#### 5. No stop-condition for tiny / fresh-substrate repos

**Severity:** High
**Category:** Sharp edge
**Why it matters:** A user runs `cohesive-review --scope codebase` against a 2-file fresh repo. Phase 2 spec-prior gate doesn't fire (nothing to be inconsistent). Four reviewers dispatch against near-empty substrate, hallucinate, user's first impression of Cohesive is incoherent.
**Evidence:** `skills/cohesive-review/SKILL.md:53-67` triggers only on `≥3 blocking spec-level issues`.
**Recommended fix:** Add Phase 1.5: "If discovery surfaces fewer than ~5 normative files, stop and recommend `cohesive:substrate-audit` instead."
**Substrate artifact to add or update:** Skill body + rubric.

#### 6. Output overwhelm with no TL;DR convention

**Severity:** Medium
**Category:** Sharp edge / Convention gap
**Why it matters:** A `cohesive-review --scope codebase` produces 5K-10K tokens. Diff mode has a tight chat verdict table; codebase mode does not. No verdict-first compressed view as the lead.
**Evidence:** `skills/cohesive-review/SKILL.md:91-101` and `:170-181` define a 6-section template with no TL;DR.
**Recommended fix:** Add TL;DR convention to `references/skill-conventions.md` for any persisted skill output (verdict + top 1-3 findings + recommended next skill).
**Substrate artifact to add or update:** Conventions doc + architecture-review-report template.

#### 7. `discover-substrate` description is too generic — competes with Superpowers

**Severity:** Medium
**Category:** Sharp edge
**Why it matters:** Gotcha at `docs/substrate/gotchas/discovery-vs-superpowers.md:36-44` says "should not claim general discovery." The skill description still does. Triggers compete with Superpowers' research/exploration skills.
**Evidence:** `skills/discover-substrate/SKILL.md:3` vs gotcha.
**Recommended fix:** Narrow trigger phrases per the gotcha pattern.
**Substrate artifact to add or update:** Skill description.

### C. Agent prompt quality (the headline finding)

#### 8. Token-discipline note missing in ALL 5 agent files (template requires it)

**Severity:** High
**Category:** Convention drift / Agent-readiness
**Why it matters:** `references/reviewer-agent-template.md:119-121` explicitly requires every reviewer agent to declare a token-discipline note ("Output ~500 lines max. Read only paths above."). None of the five agent files contain such a line. Dispatched reviewers reach for the section list as the contract and emit ~2K-word reports — observable failure mode in this very review's two dispatches.
**Evidence:** Template at `:119-121`; absent in `agents/spec-cohesion-reviewer.md`, `agents/substrate-alignment-reviewer.md`, `agents/structure-reviewer.md`, `agents/library-native-reviewer.md`, `agents/agent-readiness-reviewer.md`.
**Recommended fix:** Add a single concrete-bound line to each agent: "Output ≤500 words / ≤8 ranked findings. Stop when bounded; do not fill empty sections."
**Substrate artifact to add or update:** All 5 agent files.

#### 9. Output-shape has drifted across 5 agents — synthesizer can't merge cleanly

**Severity:** High
**Category:** Convention drift / Agent-readiness
**Why it matters:** Canonical shape per template is `Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact`. Reality: `substrate-alignment-reviewer` drops "Evidence"; `library-native-reviewer` and `agent-readiness-reviewer` drop "Category"; `spec-cohesion-reviewer` uses entirely different keys (`Risk / Substrate artifact / Suggested repair`). The Phase 4 synthesizer cannot uniformly merge findings.
**Evidence:** `agents/substrate-alignment-reviewer.md:89-109`, `agents/structure-reviewer.md:135-141`, `agents/library-native-reviewer.md:139-146`, `agents/agent-readiness-reviewer.md:166-174`, `agents/spec-cohesion-reviewer.md:72-77`.
**Recommended fix:** Sweep all 5 to canonical 6 fields. Add a behavior matrix at `docs/substrate/matrices/reviewer-output-shape.md` to track field presence and prevent re-drift.
**Substrate artifact to add or update:** 5 agent files + new matrix.

#### 10. `agent-readiness-reviewer` and `library-native-reviewer` have 7-8 pre-finding sections — encourage maximalism

**Severity:** Medium
**Category:** Agent-readiness
**Why it matters:** Output template at `agents/agent-readiness-reviewer.md:135-165` lists eight enumerated sections before "High-leverage findings (ranked)." Dispatched reviewer treats each as obligatory and burns budget on coverage rather than ranking. Same pattern in `library-native-reviewer.md:111-138` (7 sections).
**Evidence:** Section counts above.
**Recommended fix:** Mark all but the ranked-findings section explicitly optional ("write 'none observed' or omit"). Pair with the token-discipline fix.
**Substrate artifact to add or update:** Two agent files.

#### 11. `spec-cohesion-reviewer` missing the canonical fresh-eyes bullet entirely

**Severity:** Medium
**Category:** Convention drift
**Why it matters:** Only the complementary bullet is present at `:89-96` ("Read prior conversation context. You won't have it; don't pretend."). The load-bearing canonical bullet ("Inherit conversation context from the calling skill. Treat your input prompt as the entire context.") is absent. Other 4 agents have it.
**Evidence:** `agents/spec-cohesion-reviewer.md:89-96` vs `references/reviewer-agent-template.md:71-73`.
**Recommended fix:** Add the verbatim bullet. One-line edit.
**Substrate artifact to add or update:** One agent file.

#### 12. `library-native-reviewer` claims package files in inputs but dispatching skill doesn't pass them

**Severity:** Medium
**Category:** Dispatch contract drift
**Why it matters:** Agent at `:31-36` says "Inputs you will receive… includes package files (`package.json`, `pyproject.toml`, etc.)" but neither `cohesive-review` Phase 3 dispatch (`:80-86`) nor the substrate-discovery output template surfaces package files explicitly. Agent globs the repo, violating its own scope rule.
**Evidence:** `agents/library-native-reviewer.md:31-36` vs `skills/cohesive-review/SKILL.md:80-86`.
**Recommended fix:** Add a "Package files surfaced" line to the substrate-discovery report template (covered by Finding #1); have `cohesive-review` Phase 3 pass it explicitly.
**Substrate artifact to add or update:** Discovery template + dispatch contract.

## Phased roadmap

### Pass 1: Mechanical agent + skill sweeps (this pass)
1. Token-discipline note in all 5 agent files (#8)
2. Sweep agents to canonical output shape (#9) + behavior matrix
3. Mark pre-finding sections optional (#10)
4. Add canonical fresh-eyes bullet to spec-cohesion-reviewer (#11)
5. Adopt soft-prereqs canonical question in 3 skills (#4)
6. Add Phase 1.5 sparse-substrate stop-condition to cohesive-review (#5)
7. Promote discovery output to template (#1) + dispatch package-files line (#12)
8. Decide brainstorm-design persistence (#2) — persistence path, not conversation-only
9. Add TL;DR convention to skill-conventions (#6)
10. Narrow discover-substrate description triggers (#7)

### Pass 2: Documented deliberate decisions (small)
- ARCHITECTURE.md: keep-together rationale for cohesive-review codebase+diff (#3) with trigger condition for split.

### Deliberate non-changes
- Validator script extension (PLUGIN_ROOT_PATHS path-discipline grep) — still V1 work.
- Reviewer-agent corpus sweep beyond the items above — done in this pass.
- Transcripts in `docs/history/transcripts/` — this review counts as a third dogfood artifact.

## Self-consistency check

After Pass 1 lands, the agent files should be uniform on token-discipline and output shape. The soft-prereqs gotcha that has lived as folklore should now be implemented in the three skill bodies it names. The discovery output should have a real template. The cohesive-review codebase mode should have a TL;DR. A re-running of `cohesive-review --scope codebase` against this repo should not surface findings 4, 5, 6, 8, 9, 10, 11, 12.

The agent-readiness axis should move from Drifting to Mostly healthy after Pass 1.

## Recommended next Cohesive skill

Per verdict (Mostly healthy):
- `cohesive:rewrite-specs` — for the Pass 1 repairs above. Most are mechanical edits across agents and skills; the discovery template promotion and persistence decision are slightly larger but each is bounded.
