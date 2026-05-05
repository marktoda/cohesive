---
name: brainstorm-design
description: Use before code when brainstorming a feature, refactor, or architecture change. Reads the substrate the codebase already has, captures current scope and future pressure separately, proposes 2–4 design options grounded in that substrate, then attacks each option through a 25-question pressure-test battery before recommending one. Triggers on "brainstorm a refactor of X", "design a feature for X", "what's the right way to add X", "how should we restructure X", "I'm thinking about Y, what do you think". Always pair with discover-substrate first; never produce code from this skill.
---

# Brainstorm design

## What this skill produces

A combined **design options + pressure-test report** that:
- captures current scope, future pressure, and non-goals separately
- proposes 2–4 named design options
- attacks each option through the pressure-test question battery
- recommends one option (or hybrid) with the main risk surfaced
- lists the substrate that must be created or updated *before* implementation begins

The output is the input to either `rewrite-specs` (if a direction is approved) or another round of brainstorming (if no option survives pressure-testing).

## Hard constraints

1. **Never produce code from this skill.** Not a snippet, not a function signature. Brainstorming ends at "here's the recommended direction."
2. **Substrate discovery is a prereq; ask the user, don't guess.** Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md`, detecting prior discovery from session memory silently degrades. Open the turn with the canonical forced-choice question:

   > "I see we're about to run brainstorm-design. Has substrate discovery already happened for this change surface, or should I run `discover-substrate` first?"

   When the `cohesively` router invokes this skill, it passes "discovery already complete; report at <path>" in the dispatch prompt and this skill skips the question.

3. **Always propose at least two credible options for non-trivial changes.** Single-option "design" is just a proposal, not a decision.
4. **Never recommend an option whose main risk is mitigated by "we'll be careful."** Mitigation is structure: a test, a linter, a boundary, a constraint.

## Process

### Phase 0: Resolve the artifact directory

If the brainstorm is going to be persisted (the user has asked for it, or the router's `design` route is chaining toward `rewrite-specs`), resolve where it will be written before grounding begins. Apply the four-rule resolution from `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/substrate-layout.md` §"Artifact directory resolution" with artifact category `brainstorms/`:

1. If `docs/history/brainstorms/` exists, write there.
2. Else if the repo carries `docs/adr/`, `docs/specs/`, `docs/design/`, `docs/decisions/`, or `docs/architecture/`, write to a `brainstorms/` subdir alongside it.
3. Else default to `docs/cohesive/brainstorms/`.
4. If `docs/` does not exist, still default to `docs/cohesive/brainstorms/`.

Brainstorms are not always persisted — many design conversations end at the recommendation. When persistence is requested, announce the resolved path in chat before writing.

### Phase 1: Ground the brainstorm

Use the discovery report (passed by the router or produced by Hard constraint #2's pre-check) as the starting material. If the discovery report carries `**Empty-substrate verdict: yes**`, broaden option-generation to fundamentals rather than grounding in nothing — this is a fresh-substrate codebase, not a mature one.

Then, in chat, capture three things separately:

#### Current scope
What this change must accomplish. The behavior the user is asking for.

#### Future pressure (not current scope)
Things the user has hinted at or that the substrate suggests will matter later — but that should not become current-scope features just because they're foreseeable. Capturing future pressure separately is the mechanism that prevents speculative implementation.

#### Non-goals
What this change explicitly does not do. Helps the options stay focused.

If any of the three is unclear, ask **one** precise clarifying question. Suggested form: "Which future pressure should this design optimize for most: <option A>, <option B>, or <option C>?" — this gives the user a concrete forced choice rather than asking them to write a brief.

### Phase 2: Propose options

Generate 2–4 named design options. Each option must:
- Have a short, memorable name (not "Option A" alone — name the *idea*, e.g., "connector-local classification" or "shared decision kernel")
- Describe the core architectural choice in 1–2 sentences
- Be substantially distinct from the other options (not just parameter variations)

For each option, immediately note:
- **Substrate changes required** — which docs/matrices/invariants/tests/linters would need to be added or updated
- **Locality impact** — what context a future change to this area would require
- **Future fit** — which future pressure this option makes easy or hard
- **Risks** — initial risks before pressure-testing

### Phase 3: Pressure-test each option

Apply the question battery from `${CLAUDE_PLUGIN_ROOT}/references/design-pressure-testing.md` to every option. Don't skip the option you already prefer; attack it as hard as the others.

The 25 questions cover six categories:
1. **Spec impact** — what docs change/become obsolete/get renamed
2. **Behavior matrix impact** — cells added/removed/invalidated
3. **Invariant impact** — what gets stronger/weaker/newly required, what enforcement story
4. **Test impact** — what becomes misleading/inadequate, what new test is needed
5. **Locality and abstraction** — required context, premature centralization, seams
6. **Future fit** — easy/hard/appears-easy-but-isn't
7. **Gotcha and scar surface** — rediscovered/retired/new failure modes
8. **Enforcement edges** — invalid changes still easy, semantic linters needed

Refuse to recommend an option until every applicable question has a concrete answer (or "N/A" with justification). "I don't know" must be turned into "we should find out by [doing X]" before the recommendation.

### Phase 4: Recommend

Recommend exactly one option, or a named hybrid. The recommendation must:
- State the **main risk** of the chosen option in one sentence
- State the **structural mitigation** for that risk (not "we'll be careful")
- List the **substrate that must exist before implementation** (specs, matrices, invariants, tests, linters)
- State whether the recommendation is ready for `rewrite-specs` or needs another brainstorm round

## Output format

```md
## Brainstorm: <topic>

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

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — proceed to spec rewrite in a design worktree
or
`cohesive:brainstorm-design` — another round; <reason>
```

## Persistence

When the user accepts a recommendation (or after Phase 4 if the chain proceeds to `rewrite-specs`), persist the brainstorm output to:

```
docs/history/brainstorms/YYYY-MM-DD-<slug>.md
```

The file uses the same shape as the chat output above. This lets `rewrite-specs` consume the chosen direction as a path rather than asking the user to re-state it from conversation memory — closing the soft-prereqs hand-off gap that previously made `brainstorm-design → rewrite-specs` rely on human memory.

If the user declines persistence (one-shot brainstorm, no rewrite intended), the skill is conversation-only.

## Acceptance criteria

- At least two credible options for non-trivial changes.
- Future ideas are captured under "Future pressure," not promoted to current scope.
- Every option has a substrate-changes line (not just a code-changes line).
- The recommendation states a main risk *and* a structural mitigation.
- The recommendation lists required substrate by category.
- Exactly one next-skill recommendation.
- When the recommendation is accepted, the brainstorm output is persisted to `docs/history/brainstorms/YYYY-MM-DD-<slug>.md`.

## Red flags

- Producing code (snippets, function names, file paths to create). This skill is design-only.
- "Option A is clearly best" without showing the comparison table or pressure-testing alternatives.
- Recommending an option whose main risk has no structural mitigation.
- Treating future pressure as current scope ("since we'll need X eventually, let's add it now").
- Claiming "no behavior matrix needed" without checking whether the change introduces branchy behavior.
- Skipping pressure-test questions because "they don't apply" without saying *why* they don't apply.

## What this skill is *not*

- Not an implementation planner. That's V1's `plan-implementation` (Superpowers' `writing-plans` works for now).
- Not an architecture review. That's `cohesive:review-codebase`.
- Not a substrate audit. That's `cohesive:audit-substrate`.

## Composition

- **Always preceded by:** `discover-substrate` (or its output reused from earlier in session)
- **Often followed by:** `rewrite-specs` (if direction is approved and large enough to justify a spec rewrite) or directly to implementation planning (if change is small and substrate is already in good shape)
