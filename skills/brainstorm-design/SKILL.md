---
name: brainstorm-design
description: Use before code when brainstorming a feature, refactor, or architecture change. Reads the substrate the codebase already has, captures current scope and future pressure separately, proposes 2–4 design options grounded in that substrate, then attacks each option through a 25-question pressure-test battery before recommending one. Triggers on "brainstorm a refactor of X", "design a feature for X", "what's the right way to add X", "how should we restructure X", "I'm thinking about Y, what do you think". Always pair with discover-substrate first; never produce code from this skill.
---

# Brainstorm design

## What this skill produces

A substrate-grounded **design recommendation** that:
- captures current scope, future pressure, and non-goals separately
- explores the option space — in one shot when shallow, as a multi-turn axis dialog when the space forks along ≥2 structural dimensions
- pressure-tests the chosen direction through the question battery
- recommends one option (or named hybrid) with main risk and structural mitigation
- lists the substrate that must be created or updated *before* implementation begins

The output is the input to either `rewrite-specs` (if a direction is approved) or another round of brainstorming (if no direction survives pressure-testing).

## Voice

Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output. The voice guide is the load-bearing source for verdict-leads, header-depth cap, density budgets, and forbidden phrasings; the imperative above is what triggers the model to load it via a Read tool call. Do not reproduce the imperative or any citation to the voice guide inside the Output format render template — instructions placed inside render templates leak verbatim into user-facing output (the failure mode `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` documents).

## Hard constraints

1. **Never produce code from this skill.** Not a snippet, not a function signature. Brainstorming ends at "here's the recommended direction."
2. **Substrate discovery is a prereq; ask the user, don't guess.** Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md`, detecting prior discovery from session memory silently degrades. Open the turn with the canonical forced-choice question:

   > "I see we're about to run brainstorm-design. Has substrate discovery already happened for this change surface, or should I run `discover-substrate` first?"

   When the `cohesively` router invokes this skill, it passes "discovery already complete; report at <path>" in the dispatch prompt and this skill skips the question.

3. **Always propose at least two credible options for non-trivial changes.** Single-option "design" is just a proposal, not a decision.
4. **Never recommend an option whose main risk is mitigated by "we'll be careful."** Mitigation is structure: a test, a linter, a boundary, a constraint.
5. **Conversational mode is multi-turn; each turn asks at most one forced-choice question.** Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Clarifying questions" → §"Per turn, not per invocation". Each conversational turn presents a verdict-led pick on one decision and asks the user to ratify or redirect — never a vague "what do you want?" prompt. Forbidden phrasings from `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` apply per-turn.

## Process

### Phase 0: Resolve the artifact directory

If the brainstorm is going to be persisted (the user has asked for it, or the router's `design` route is chaining toward `rewrite-specs`), resolve where it will be written before grounding begins. Apply the four-rule resolution from `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md` §"Artifact directory resolution" with artifact category `brainstorms/`:

1. If `docs/history/brainstorms/` exists, write there.
2. Else if the repo carries `docs/adr/`, `docs/specs/`, `docs/design/`, `docs/decisions/`, or `docs/architecture/`, write to a `brainstorms/` subdir alongside it.
3. Else default to `docs/cohesive/brainstorms/`.
4. If `docs/` does not exist, still default to `docs/cohesive/brainstorms/`.

Brainstorms are not always persisted — many design conversations end at the recommendation. When persistence is requested, announce the resolved path in chat before writing.

### Phase 1: Ground the brainstorm

Use the discovery report (passed by the router or produced by Hard constraint #2's pre-check) as the starting material. If the discovery report carries `**Empty-substrate verdict: yes**`, broaden option-generation to fundamentals rather than grounding in nothing — this is a fresh-substrate codebase, not a mature one.

Then, in chat, capture three things separately (plus a fourth optional category for re-decide cycles):

#### Current scope
What this change must accomplish. The behavior the user is asking for.

#### Future pressure (not current scope)
Things the user has hinted at or that the substrate suggests will matter later — but that should not become current-scope features just because they're foreseeable. Capturing future pressure separately is the mechanism that prevents speculative implementation.

#### Non-goals
What this change explicitly does not do. Helps the options stay focused.

#### What we already tried *(optional — re-decide cycles only)*

When this brainstorm is invoked from a `cohesive:validate-rewrite` Approved trailer's **Re-decide** option (the user read the architectural reflection and judged the locked design unsound), capture the discarded direction and what made it feel wrong. This input is the substrate residue of a failed lock — without it, the next round of options re-derives the same path that just got discarded.

The dispatching `validate-rewrite` invocation passes this input as part of the Skill-tool dispatch prompt. The shape:

- **Discarded direction:** <option name + 1-2 sentence summary from the discarded brainstorm's `## Direction` block>
- **Reflection's harder-downstream concerns:** <bullets from the discarded validate-rewrite Approved trailer's Architectural reflection §"Harder downstream">
- **Reflection's load-bearing-on-memory concerns:** <bullets from the discarded validate-rewrite Approved trailer's Architectural reflection §"Load-bearing on memory">
- **Re-decide pass count:** N (incrementing across the cycle; cap at 2-3 per the convention in `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Re-decide acknowledgment")

The brainstorm uses these inputs to bias option-generation: any new option must either resolve the harder-downstream concerns of the discarded direction or explicitly accept them with a different structural mitigation. Options that re-derive the discarded path without addressing its concerns are out of scope. The pressure-test battery in Phase 4 attacks the new options against the discarded reflection's concerns, not just against the substrate at large.

If any of the four input categories is unclear, ask **one** precise clarifying question. Suggested forms: "Which future pressure should this design optimize for most: <option A>, <option B>, or <option C>?" (when future pressure is the unclear input) or "Which of the prior reflection's concerns is the most load-bearing for this re-decide: <concern A> or <concern B>?" (when re-decide-cycle inputs are unclear).

### Phase 2: Identify axes and select mode

Identify the **axes of disagreement** the substrate exposes — the orthogonal structural dimensions along which credible options would differ. Common axes:

- **Centralization** — per-component vs unified
- **Timing** — synchronous-with-state-change vs async/eventual
- **Locality** — context-required-to-change-this-area increases or decreases
- **Enforcement substrate** — added invariants/linters vs trust-and-document
- **Migration shape** — in-place vs parallel-path vs flag-gated cutover

Axes are internal at this stage — they determine mode but are not yet user-rendered. Naming them explicitly inside the agent's working state is what makes the auto-detect gate well-defined.

Then apply the **auto-detect mode gate**:

| Signal | Mode |
|---|---|
| ≥2 distinct axes of disagreement, OR option space touches ≥2 substrate kinds (specs + invariants + linters) | **Conversational** (Phase 3b) |
| Single-axis option space, naming, placement within an established pattern, single-pattern refactor | **Autonomous** (Phase 3a) |

User override at any phase boundary: "give me the autonomous version" / "walk me through it." Auto-detect is a default, not a lock. The table form (rather than binary if/else) makes a future third mode a sibling row, not nested prose.

### Phase 3a: Propose options (autonomous mode)

Generate 2–4 named design options. Each option must:
- Have a short, memorable name (not "Option A" alone — name the *idea*, e.g., "connector-local classification" or "shared decision kernel")
- Describe the core architectural choice in 1–2 sentences
- Be substantially distinct from the other options (not just parameter variations)

For each option, immediately note:
- **Substrate changes required** — which docs/matrices/invariants/tests/linters would need to be added or updated
- **Locality impact** — what context a future change to this area would require
- **Future fit** — which future pressure this option makes easy or hard
- **Risks** — initial risks before pressure-testing

Then proceed to Phase 4 (Pressure-test) and Phase 5 (Recommend) — autonomous mode renders the trailer in a single turn.

### Phase 3b: Conversational dialog (conversational mode)

Multi-turn axis dialog → leaf direction summary → sub-decision routing. **Axes and sub-decisions are different layers**: an axis is a top-level structural fork where any pick reshapes the leaf design; a sub-decision is an open call within the chosen leaf, classified by who decides.

**The first user-visible turn in conversational mode is the axes map** — this makes the auto-detect gate's "≥2 axes" determination auditable from the chat surface and the persisted file's `## Decision dialog` §"Axes walked".

#### Axis dialog

Open with a single short turn rendering the **axes map** — a one-line structural overview:

> "These split along **<axis 1>** (one family) × **<axis 2>** (another). I'll walk through them in order of where your taste matters most."

Then drill axes one at a time. Order: **user-impact-if-redirected** first (taste-driven, future-pressure-shaping, organizational/risk axes), **substrate-evidence-strength** as tiebreaker (strongest agent pick last, so prior decisions shape the leaf direction). Each axis turn must:

- **Name the axis and enumerate the option space first.** Render the credible option families for this axis with a one-line shape description each (e.g., "**A:** flat SDK-mirroring triple / **B:** bundled mcpAttachments / **C:** derived from AdapterSpec") *before* naming the agent's pick. Picking from an option space the user can't see is rule 2b naming-instead-of-showing — the user must be able to evaluate the pick against the alternatives, not reverse-engineer what A and C are from the counter-pressure paragraphs.
- Surface the agent's pick + substrate evidence (path:line, gotcha citation, invariant name) in verdict-led voice ("I'd pick X because Y")
- Name the strongest counter-pressure for the other side (the best argument, not a strawman)
- Close with a forced-choice: ratify, push back with substantive counter-pressure, or move on

If the user pushes back on an axis, that axis opens into one additional turn where the agent surfaces deeper substrate evidence and re-decides. Don't loop further; if disagreement persists after that exchange, the user is the Decider and their pick stands. The agent records the divergence for Phase 4's cross-branch graft check.

#### Leaf direction summary

After all axes converge, render a one-turn summary:

> "OK — that lands us at <leaf direction name>. Open sub-decisions: [1] <name> [Pick], [2] <name> [Confirm — I'd pick X because Y], [3] <name> [Default — Z]. Want to start with the Pick, push back on the Confirm, or challenge a Default?"

#### Sub-decision routing

Each open sub-decision inside the chosen direction is tagged in chat. Tags are **Pick / Confirm / Default** — *not* Decide/Lock/Build, which are the gate-vocabulary tokens reserved for the methodology's three-gate user-facing model (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md` §"Gate-token reuse"):

- **Pick** — multiple substrate-coherent paths exist; the call shapes future-pressure outcomes; or there's an organizational/risk-tolerance dimension. The user picks; the agent surfaces options and tradeoffs but does not pick.
- **Confirm** — substrate evidence points clearly to one answer with low organizational impact. The agent recommends; the user ratifies or pushes back.
- **Default** — mechanical follow-on (naming, placement within an established pattern); one option is overwhelmingly conventional and reversible. The agent applies the default, surfaces it, and the user can promote any Default to discussion.

**Default classification posture: aggressive Default.** A sub-decision is material (Pick or Confirm) only if different choices would land on different specs / invariants / tests / linters / matrices — not different identifiers, file names, or placements within an established pattern. Tighter dialog beats thoroughness theater. The Default list is *visible* in the leaf-direction-summary turn so the user can promote any item, but Defaults don't block convergence.

Sub-decisions surface together (in the leaf-direction-summary turn) so the user sees the open-seam set in one render. Within that set, drilling proceeds one decision at a time as the user picks/ratifies/challenges. Backtrack to any earlier axis or sub-decision is always available — "back up to <axis>, I want to revisit" — and re-enters the dialog at that point.

Once all sub-decisions converge — Picks made, Confirms ratified, Defaults left in place — proceed to Phase 4.

### Phase 4: Pressure-test

Apply the question battery from `${CLAUDE_PLUGIN_ROOT}/references/design-pressure-testing.md` to the surface this mode produced:

- **Autonomous mode** — apply to every option from Phase 3a. Don't skip the one you already prefer; attack it as hard as the others.
- **Conversational mode** — apply to the assembled leaf from Phase 3b. **Open with the cross-branch graft check** before running the rest of the battery: aim Q15 (premature centralization), Q19 (future idea this makes hard), and Q20 (appears-easy-but-isn't) at the leaf with explicit attention to whether the leaf's main risk would be reduced by grafting structure from a non-chosen axis branch. If yes, surface the hybrid candidate with substrate evidence, offer backtrack to the divergence axis, and re-enter Phase 3b's axis dialog there if the user accepts. Then run the remaining battery categories on the leaf as a whole.

The battery covers eight categories:
1. **Spec impact** — what docs change/become obsolete/get renamed
2. **Behavior matrix impact** — cells added/removed/invalidated
3. **Invariant impact** — what gets stronger/weaker/newly required, what enforcement story
4. **Test impact** — what becomes misleading/inadequate, what new test is needed
5. **Locality and abstraction** — required context, premature centralization, seams
6. **Future fit** — easy/hard/appears-easy-but-isn't
7. **Gotcha and scar surface** — rediscovered/retired/new failure modes
8. **Enforcement edges** — invalid changes still easy, semantic linters needed

Refuse to recommend until every applicable question has a concrete answer (or "N/A" with justification). "I don't know" must be turned into "we should find out by [doing X]" before the recommendation.

### Phase 5: Recommend

Recommend exactly one option, or a named hybrid. The recommendation surfaces:
- The **main risk** of the chosen option in one sentence
- The **structural mitigation** for that risk (not "we'll be careful")
- A list of **substrate that must exist before implementation** (specs, matrices, invariants, tests, linters) — in the persisted brainstorm file, agent-facing; not in the chat trailer
- Whether the recommendation is ready for `rewrite-specs` or needs another brainstorm round

The agent-facing substrate list is what `rewrite-specs` reads as input — it's load-bearing for the next chain step. It belongs in the persisted brainstorm file (substrate-shape vocabulary the agent uses to do the rewrite). The chat trailer renders the user-facing `## Direction` block — Direction + Main risk + Structural mitigation — which is what the user reads to decide whether to approve. The two surfaces carry the same recommendation in different shapes per the audience seam in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.

## Output format

The skill renders the centralized chat trailer per `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` — without the verdict slot (brainstorm is not verdict-led; per the §"Variants" `brainstorm-design` row, the body block carries `## Direction` instead). When the brainstorm persists, the persisted file at `docs/history/brainstorms/YYYY-MM-DD-<slug>.md` carries the full substrate-shape body — agent-facing.

**Mode-aware rendering.** The trailer renders in one turn at Phase 5 — same shape in both modes (Direction + Main risk + Structural mitigation, optionally preceded by a Pressure test summary table when ≥3 options were considered). In autonomous mode it follows Phase 4's option pressure-testing directly. In conversational mode it follows Phase 3b's dialog (axes → leaf summary → sub-decisions) and Phase 4's leaf battery (cross-branch graft check + remaining categories); the Phase 3b dialog turns are short verdict-led exchanges (one axis pick + counter-pressure + forced choice), not mini-trailers.

**Body block specification (chat trailer).** Per the §"Variants" `brainstorm-design` row of the centralized template: `## Direction` block — `**Direction:**` <chosen option name> + `**Main risk:**` <one sentence> + `**Structural mitigation:**` <test/type/constraint/linter — not "we'll be careful">. Optionally a `## Pressure test summary` table renders above when ≥3 options were considered.

**`### Next` block (chat trailer).** One entry, decision-shape leading, skill citation parenthetical, payload following:

- **Ready for spec rewrite:** Rewrite the docs to make this direction true. *(`cohesive:rewrite-specs`.)* **Files to edit:** <enumerate the docs/matrices/invariants the chosen direction touches, with the specific change in each>. Slug: `<derived-from-topic>`. Classification: <Pure implementation / Design / Mixed>.
- **Needs another round:** Refine the design before writing it down. *(`cohesive:brainstorm-design`.)* **Design question:** <name the unresolved question — e.g., "should X be one concept or two given the future pressure of Y">.

**Persisted file shape (substrate-shape, agent-facing).** When the recommendation is accepted, the persisted brainstorm file uses the full substrate-shape body below — what `rewrite-specs` consumes:

```md
# Brainstorm — <topic>

### Current scope
- ...

### Future pressure (not current scope)
- ...

### Non-goals
- ...

## Design options

### Option A: <named idea>
**Summary:** <1–2 sentences>
**Substrate changes required:** <docs / matrices / invariants / tests / linters>
**Locality impact:** <required context delta>
**Future fit:** <which future pressure this serves; which it doesn't>
**Initial risks:** <before pressure-testing>

### Option B: <named idea>
... (same structure)

(Option C, D as needed)

## Pressure test summary

| Option | Cohesion | Substrate delta | Future fit | Locality | Main risk |
|---|---:|---|---|---|---|
| A | High/Med/Low | Small/Med/Large | ... | ... | <one sentence> |
| B | ... | ... | ... | ... | ... |

## Breakage analysis

For each option (or just the recommended one if the others are clearly out):

### Option <X>
- **Docs that would change:** ...
- **Existing assumptions that break:** ...
- **Behavior matrix impact:** ...
- **Invariant impact:** ...
- **Test guarantee impact:** ...
- **Gotchas triggered:** ...
- **Locality / centralization concerns:** ...
- **Easy invalid change still possible:** ...

## Recommendation

**Direction:** <Option name or named hybrid>

**Main risk:** <one sentence>

**Structural mitigation:** <test / type / constraint / linter / runtime wrapper / CI check — not "we'll be careful">

**Required substrate before implementation:**
- Specs: ...
- Matrices: ...
- Named invariants: ...
- Tests / checks: ...
- Gotchas: ...
- Semantic linters (proposed): ...

### Next

<decision-shaped sentence>. *(`cohesive:rewrite-specs`.)* **Files to edit:** <enumerated>. Slug: `<derived-from-topic>`.
```

The persisted file's `## Recommendation` block carries the substrate-shape "Required substrate before implementation" list — agent-facing, consumed by `rewrite-specs` as input. The chat trailer renders only the `## Direction` decision-shape block; the substrate list does not appear in chat per the audience seam.

## Persistence

When the user accepts a recommendation (or after Phase 4 if the chain proceeds to `rewrite-specs`), persist the brainstorm output to:

```
docs/history/brainstorms/YYYY-MM-DD-<slug>.md
```

The persisted file is agent-facing and uses the substrate-shape body in §"Output format". `rewrite-specs` consumes it as input, closing the soft-prereqs hand-off gap that previously made `brainstorm-design → rewrite-specs` rely on human memory.

**Conversational-mode addition: Decision dialog record.** When Phase 2 selected conversational mode, the persisted file adds a `## Decision dialog` section *between* `## Design options` and `## Pressure test summary`. The section records what was discussed — not as transcript, but as a structured residue:

```md
## Decision dialog

### Axes walked
- **<axis 1>:** agent picked <X>; user <ratified | redirected to Y>. Substrate evidence: <path:line / artifact>.
- **<axis 2>:** ...

### Sub-decisions
| # | Sub-decision | Tag | Outcome | Notes |
|---|---|---|---|---|
| 1 | <name> | Pick | <user pick> | <why this mattered to user taste / future pressure> |
| 2 | <name> | Confirm | <ratified / overridden> | <agent rec + user disposition> |
| 3 | <name> | Default | <agent default> | <only present if user promoted to discussion> |

### Cross-branch graft check (Phase 4 opening, conv-mode)
- **Hybrid candidate surfaced?** yes/no. If yes: <which non-chosen branch suggested the graft, what evidence, whether the user accepted backtrack>.
- **Cleared?** yes (proceeded to remaining battery) / no (re-entered Phase 3b axis dialog at <axis>).
```

This section is agent-facing (consumed by `rewrite-specs` to understand which sub-decisions are user-load-bearing vs Default-applied). It is omitted in autonomous-mode files.

If the user declines persistence (one-shot brainstorm, no rewrite intended), the skill is conversation-only.

## Acceptance criteria

- At least two credible options for non-trivial changes.
- Future ideas are captured under "Future pressure," not promoted to current scope.
- Every option has a substrate-changes line (not just a code-changes line).
- The recommendation states a main risk *and* a structural mitigation.
- The recommendation lists required substrate by category.
- Exactly one next-skill recommendation.
- When the recommendation is accepted, the brainstorm output is persisted to `docs/history/brainstorms/YYYY-MM-DD-<slug>.md`.
- Mode is selected explicitly per Phase 2's auto-detect gate (≥2 axes / ≥2 substrate kinds → conversational). User overrides ("walk me through it" / "give me the autonomous version") are honored at any phase boundary.
- In conversational mode: the **axes map is the first user-visible chat turn** (auditable from the persisted file's `## Decision dialog` §"Axes walked"); each turn asks at most one forced-choice question; sub-decisions carry explicit Pick / Confirm / Default tags; the cross-branch graft check opens Phase 4 before the trailer renders.
- In conversational mode: the persisted file carries a `## Decision dialog` section recording axes walked, sub-decision outcomes, and the cross-branch graft check result.

## Red flags

- Producing code (snippets, function names, file paths to create). This skill is design-only.
- "Option A is clearly best" without showing the comparison table or pressure-testing alternatives.
- Recommending an option whose main risk has no structural mitigation.
- Treating future pressure as current scope ("since we'll need X eventually, let's add it now").
- Claiming "no behavior matrix needed" without checking whether the change introduces branchy behavior.
- Skipping pressure-test questions because "they don't apply" without saying *why* they don't apply.
- Conversational mode drifting into "what do you want?" / "tell me more" / open-ended hedging — voice stays verdict-led per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`. The user's role is forced-choice ratification or substantive redirect, not authoring.
- Tagging sub-decisions as Confirm by default to look thorough. Default posture is aggressive Default; a sub-decision is material only if different choices land on different specs / invariants / tests / linters / matrices.
- Reusing gate-vocabulary tokens (Decide / Lock / Build) as sub-decision tags. Sub-decision tags are Pick / Confirm / Default per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md` §"Gate-token reuse".
- Skipping Phase 4's cross-branch graft check in conversational mode because the dialog "felt right." Q15/Q19/Q20 against the leaf is what catches premature commitment at the top-level axis.
- Treating axis-pick disagreement as something to silently resolve. If a user redirected on an axis, that divergence is recorded for Phase 4's graft check and persisted in `## Decision dialog`.

## What this skill is *not*

- Not an implementation planner. After `validate-rewrite` Approved, `cohesive:implement-cohesively` drives implementation against the delta ledger (per-phase composition with `superpowers:writing-plans` and `superpowers:executing-plans`); for non-substrate-shaped implementation, `superpowers:writing-plans` is also available directly.
- Not an architecture review. That's `cohesive:review-codebase`.
- Not a substrate audit. That's `cohesive:audit-substrate`.

## Composition

- **Always preceded by:** `discover-substrate` (or its output reused from earlier in session)
- **Modes:** autonomous (one-turn trailer) or conversational (multi-turn axis dialog) — selected by the auto-detect gate in Phase 2; user override available either direction at any phase boundary
- **Often followed by:** `rewrite-specs` (if direction is approved and large enough to justify a spec rewrite). When `rewrite-specs` runs, the chain continues `validate-rewrite` → `implement-cohesively`. If the change is small and substrate is already in good shape, the user may go directly to `superpowers:writing-plans` without the rewrite chain.
