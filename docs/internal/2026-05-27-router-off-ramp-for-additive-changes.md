# Router off-ramp for additive changes (L2)

**Status:** Brainstorm — design accepted, not yet implemented
**Date:** 2026-05-27
**Author:** Mark + Claude (brainstorm)
**Predecessor:** L1 — replace delta ledger with git diff (`docs/internal/2026-05-27-replace-delta-ledger-with-git-diff.md`)

## Motivation

Early-user feedback flagged that the cohesive router routes on lexical signals, not change shape. Substrate-*touching* changes (extend an enum, add a leaf, add a behavior-matrix row) get the same heavy treatment as substrate-*shaping* changes (introduce a new invariant family, move a seam, add an admission layer). The feedback's concrete example (PR #544: extending `SurfaceRole`, extending `F1_HOME_KINDS`, adding one tool) was a clear extension yet got the full `brainstorm → rewrite → 5-pass validate → implement` flow. That's ceremony — and the user's recurring complaint was that ceremony compounds across additive changes that don't earn it.

L2 addresses this by adding an off-ramp at the router for extensions, with a category-membership question deciding which path runs. The cross-mirror sweep (the discipline that catches the actual failure mode of additive changes — forgetting one of the N places that enumerate the same kind) becomes a new fresh-context reviewer agent dispatched at end-of-run.

## Lens

L1's principle was *artifact > description-of-artifact*. L2's principle is *route-shape matches change-shape*. A consequence: don't create parallel orchestrator skills when the existing one can carry a mode flag. The path divergence is at the entry (router gate) and at the exit (reviewer dispatch); the middle (writing-plans + executing-plans) is shared.

## Architecture

### Two paths, two shared subskills, one mode flag

```
        Heavy path (gate Option 2)            Light path (gate Option 1)
        ─────────────────────────             ─────────────────────────
        cohesive:brainstorm-design            (skipped — no design space)
              │                                       │
              ▼                                       │
        cohesive:rewrite-specs  ◄─── shared ──► cohesive:rewrite-specs
              │                                       │
              ▼                                       │
        cohesive:validate-rewrite             (skipped — no novel design)
              │                                       │
              ▼                                       ▼
        cohesive:implement-cohesively         cohesive:implement-cohesively
        (standard mode)                       (extend mode)
        → delta-coverage + review-diff        → cross-mirror-reviewer
```

Both paths use `rewrite-specs` to land the doc commits (the substrate change is the same shape: doc files updated, `Classification:` trailer in the commit). Both use `implement-cohesively` to coordinate writing-plans + executing-plans + end-of-run reviewer dispatch. The mode flag on `implement-cohesively` switches between dual-reviewer (standard) and solo cross-mirror (extend), and switches the input contract (validation-review-path for standard, change-surface-description for extend).

## Per-surface changes

### §1 — `cohesively` router

A new gate fires for forward-looking requests (those that would currently route to `design` or `rewrite-only`). It does NOT fire for `review (codebase)`, `review (diff)`, `audit (substrate)`, `init`, or `implement` — those don't add substrate or are already past the decision point.

Forced-choice question via `AskUserQuestion`, with **agent-recommended pre-fill** based on signals in the user's request:

| Field | Value |
|---|---|
| Header | `Change type` |
| Question | "Are you extending an existing concept, or introducing a new one?" |
| Option 1 | **Extending an existing concept** — adds a leaf to an enum, a row to a behavior matrix, a sibling case to an existing pattern, or tightens an existing invariant. *Pre-filled `(Recommended)` when the request says "add X to Y," "support a new value for E," "extend Y with Z."* |
| Option 2 | **Introducing a new concept** — new named-invariant family, new behavior matrix, new seam, new admission layer, concept merge/split. *Pre-filled `(Recommended)` when the request says "introduce a new family," "add a new admission layer," "refactor X into N concepts."* |

When the signals are mixed or absent, the pre-fill goes to Option 2 (the safer default — heavier flow handles ambiguity through brainstorm-design's pressure-testing).

Routes:
- Option 1 → new `extend` route → chain: `rewrite-specs` → `implement-cohesively` (extend mode)
- Option 2 → existing `design` or `rewrite-only` route — unchanged

Router announcement for the extend route:

> "I'll extend the existing concept and verify all sibling sites are updated."

### §2 — `implement-cohesively` gains a mode

Today the skill has one mode (Approved validate-rewrite required as prereq). After L2 it has two: **standard** (existing behavior) and **extend** (new).

**Mode comparison:**

| Mode | Trigger | Required inputs | End-of-run reviewer dispatch |
|---|---|---|---|
| **standard** *(existing)* | Reached via `implement` route, post-validate-rewrite-Approved | Validation review path (with `Rewrite-tip:` SHA) + branch name | Dual: `delta-coverage-reviewer` + `cohesive:review-diff`, AND-shape synthesis |
| **extend** *(new)* | Reached via new `extend` route | Branch name + change-surface description + (auto-dispatched) discovery report | Solo: `cross-mirror-reviewer` |

**Internal step changes:**

- **Step 0 (Resolve inputs):** Branches on mode.
  - *Standard mode:* requires the validation review file with the `Rewrite-tip:` SHA; verifies SHA exists in branch history (unchanged from L1).
  - *Extend mode:* requires the change-surface description (one or two sentences naming what to extend, e.g., "add HOME to SurfaceRole"); dispatches `cohesive:discover-substrate` scoped to that surface to find sibling sites; persists the discovery report path.
- **Step 1 (Capture spec diff):** Branches on mode.
  - *Standard mode:* reads the `Rewrite-tip:` SHA and computes `git diff $(merge-base main <SHA>)..<SHA>` (unchanged from L1).
  - *Extend mode:* the spec diff is whatever `rewrite-specs` just landed on the branch — there's no validate-rewrite stage to mark the boundary. Compute the rewrite-tip as `git log --grep="^design: rewrite specs" -n 1 --format=%H` on the branch (the most recent rewrite commit before any code lands), and compute the spec diff from `merge-base(main, HEAD)..<rewrite-tip>`. Snapshot to `.cohesive/tmp/<slug>-spec-diff.patch` for the reviewer at Step 3.
- **Step 2 (Execute plan):** Identical in both modes.
- **Step 3 (End-of-run reviewer dispatch):** Branches on mode.
  - *Standard mode:* dispatches `delta-coverage-reviewer` (Task subprocess) + `cohesive:review-diff` (Skill tool) in parallel (unchanged from L1).
  - *Extend mode:* dispatches `cross-mirror-reviewer` (Task subprocess) solo. The reviewer's verdict is the run's verdict (no AND-shape synthesis needed since there's only one reviewer).
- **Step 3.5 (Cleanup):** Identical in both modes; strips per-pass plan, spec-diff snapshot, and discovery report on Implemented / Covered.
- **Step 4 (Hand off):** Identical.

**Verdict vocabulary (both modes share the same external labels):**

| Internal verdict | Standard mode synthesis | Extend mode synthesis |
|---|---|---|
| **Implemented** | `delta-coverage-reviewer: Covered` + `cohesive:review-diff: Pass / Pass with notes` | `cross-mirror-reviewer: Covered` |
| **Coverage Drift** | `delta-coverage-reviewer: Drift / Incomplete` + `cohesive:review-diff: Pass` | `cross-mirror-reviewer: Sites Missing` |
| **Substrate Drift** | Any reviewer flags substrate misalignment | `cross-mirror-reviewer: Bigger than extension` |
| **Aborted** | User paused before Step 3 | User paused before Step 3 |

The terminology stays unified (Implemented / Coverage Drift / Substrate Drift / Aborted); only the mapping differs by mode. User-facing labels per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` are unchanged.

**Hard constraint update:** Hard constraint #1 ("An Approved validate-rewrite verdict is required") becomes mode-conditional. Standard mode requires the Approved review path; extend mode requires the change-surface description and branch name. Directive errors are mode-specific.

**Branch shape:** Standard mode lands implementation commits on the same `design/<slug>` branch as the rewrite, after the rewrite-tip SHA (unchanged). Extend mode does the same — `rewrite-specs` produces `design/<slug>` with the rewrite commit; `implement-cohesively` in extend mode lands implementation commits after the rewrite-tip on the same branch.

### §3 — New reviewer agent: `cross-mirror-reviewer`

Fresh-context agent dispatched via Task tool at end-of-run on extend mode. Reads only paths passed; no inherited conversation context (the load-bearing fresh-eyes property is preserved by Task subprocess isolation, per Cohesive's existing convention).

**Inputs the dispatching skill (`implement-cohesively` extend mode) passes:**
- **Branch name** (typically `design/<slug>`)
- **Spec-diff path** — the `.cohesive/tmp/<slug>-spec-diff.patch` file captured at Step 1 (`merge-base(main, HEAD)..<rewrite-tip>`)
- **Implementation-diff** — computed by the reviewer or pre-computed by the skill (`git diff <rewrite-tip>..HEAD`)
- **Substrate discovery report path** — the sibling-site enumeration from Step 0
- **Change-surface description** — the one-or-two-sentence summary of what was extended

**Job:** Two checks, in priority order:

1. **Sibling-site coverage.** For each sibling site identified by discovery (every place in the codebase that enumerates, pattern-matches, or references the extended concept), verify the implementation diff updated it. A sibling site is *covered* if there's a corresponding hunk in the implementation diff. List uncovered sites as `Sites Missing` findings.

2. **Extension shape preserved.** Check that the diff stayed within "extension" shape — touching only the named concept (the SurfaceRole enum, the F1_HOME_KINDS matrix, etc.), not introducing new categories. Signals that the diff went beyond:
   - New `## Named invariants` headings in the rewrite diff
   - New behavior matrix files
   - New seam docs (skill purpose changes, ownership changes)
   - New top-level concepts in any spec
   If any signal fires, the verdict is `Bigger than extension`.

**Verdict vocabulary:**

| Verdict | Meaning | Trigger |
|---|---|---|
| **Covered** | Every sibling site updated; diff stays within extension shape | All sibling-site checks pass + no shape-change signals |
| **Sites Missing** | Some sibling sites weren't updated | One or more sibling sites have no corresponding implementation hunk |
| **Bigger than extension** | The diff introduces a new concept or restructures categories | Any shape-change signal fires |

The **Bigger than extension** verdict is the structural backstop for mis-classification. The reviewer surfaces it; the user decides:
- Accept and treat as a shape-change retroactively (re-route through `cohesive:rewrite-specs` + `cohesive:validate-rewrite` to get fresh-eyes on the now-larger rewrite)
- Revert the divergent implementation and keep the change as a pure extension

**Output template:**

```md
# Cross-Mirror Review — <topic>

**Verdict:** Covered / Sites Missing / Bigger than extension

## Sibling-site coverage

| Sibling site | Status | Implementation hunk |
|---|---|---|
| `<file>:<line>` — <enum value, matrix row, etc.> | Covered | `<file>:<lines>` |
| `<file>:<line>` — <…> | Missing | — |

## Extension shape

- Did the diff stay within extension shape? Yes / No (`Bigger than extension`)
- If No: <which shape-change signal fired and where>

## Findings (only on Sites Missing or Bigger than extension)

### F1. <title>
- **Severity:** Blocker / High / Medium / Low
- **Category:** Sibling-site gap / Shape-change creep
- **Why it matters:** <concrete consequence>
- **Evidence:** <file:line refs; quoted hunks>
- **Recommended fix:** <repair direction>

## What looked right

- <calibration; one or two items>
```

**Token discipline:** ≤500 words / ≤8 ranked findings (when applicable). Coverage table is the primary artifact; findings surface only when Verdict is Sites Missing or Bigger than extension.

## Migration shape

Clean cut (no consumers outside the plugin itself). One implementation pass touches:

- `skills/cohesively/SKILL.md` — adds the gate question for forward-looking routes; adds the `extend` route and its dispatch contract row; updates the routing-decision logic.
- `skills/implement-cohesively/SKILL.md` — adds extend mode throughout (Hard constraints, Step 0, Step 1, Step 3, Verdict synthesis, Output format, Anti-patterns, Acceptance criteria). Significant rewrite but bounded — the heavy-path behavior is unchanged.
- `agents/cross-mirror-reviewer.md` — new agent file, mirrors the structure of `delta-coverage-reviewer.md`.
- `skills/using-cohesive/SKILL.md` — frontmatter trigger description may need a small update to acknowledge the extend route.
- `references/verdict-vocabulary.md` — no changes (the user-facing labels stay the same; only the internal-verdict mapping per mode differs).
- `scripts/validate_plugin.sh` — add `cross-mirror-reviewer` to the agent enumeration; add a check that the gate question appears in `cohesively/SKILL.md`.

## Risks and open questions

1. **Signal-scan accuracy for pre-fill.** The router's pre-fill is heuristic — "add X to Y" usually but not always means extension; "introduce X" usually but not always means new concept. Risk: wrong pre-fill nudges user toward the wrong route. Mitigation: pre-fill is *just* a recommendation; the user picks. If pre-fill quality is low after dogfooding, the heuristic can be made more conservative (default to Option 2 more often).

2. **`Bigger than extension` backstop usability.** When the reviewer returns this verdict, the user has to decide between revert and retroactive-shape-change. The latter requires re-routing through validate-rewrite, which means the work isn't lost but takes more steps. Risk: friction at the backstop. Mitigation: the verdict message names both options explicitly, and the chat trailer renders both as conditional next-step recommendations.

3. **Discover-substrate scope on extend path.** Step 0 in extend mode runs discover-substrate scoped to the change surface. The scope inference is non-trivial — "what counts as a sibling site of SurfaceRole" depends on how SurfaceRole is enumerated. Risk: missed sibling sites if discovery's scope is too narrow. Mitigation: discover-substrate's scoping logic is already designed for this; if needed, the change-surface description can name explicit search anchors.

4. **Mode detection ambiguity.** If a user invokes `implement-cohesively` directly (not through the router) without specifying a mode, the skill needs to detect. Heuristic: if a validation review file with `Rewrite-tip:` SHA is named in the inputs, standard mode; if a change-surface description is provided, extend mode; if neither, halt with a directive error asking the user to specify.

## Self-review

- **Placeholder scan:** No TBD / TODO / vague requirements.
- **Internal consistency:** §1-§3 form a coherent flow. Mode flag on implement-cohesively is the single source of branching; everything else is downstream of it. The cross-mirror-reviewer's input contract matches what extend mode produces.
- **Scope:** L2 only. L1 (delta ledger → git diff) is the predecessor. L3 (validate-rewrite convergence rule) remains a future addon; this design doesn't touch it.
- **Ambiguity:** The signal-scan heuristic (open question #1) and the discover-substrate scoping (open question #3) are the two operational details that resolve at implementation time; both are flagged for the implementer.

## Next

After this brainstorm is accepted, the implementation sequence is:

1. Open a worktree on branch `design/router-off-ramp-for-additive-changes`.
2. Add the gate question + `extend` route + dispatch contract to `cohesively/SKILL.md`.
3. Add extend mode throughout `implement-cohesively/SKILL.md` (Hard constraints, Step 0, Step 1, Step 3, Output format).
4. Create `agents/cross-mirror-reviewer.md` (mirror of `delta-coverage-reviewer.md`'s structure).
5. Update `scripts/validate_plugin.sh` (add agent to enumeration; add gate-question grep).
6. Run validator; iterate.
7. Commit and merge.

L1's clean precedent: design committed, rewrite-specs run on cohesive itself (one-time dogfood exception), validator passes 0/0, merge to main. L2 follows the same shape.

For L3 (validate-rewrite convergence rule), a separate brainstorm when ready.
