# [Feature Name] Cohesive Implementation Plan

> For agentic workers: preserve the listed substrate. Do not implement behavior that contradicts the approved specs, behavior matrices, or named invariants. When the plan reveals a substrate problem, stop and revise substrate before continuing.

## Goal

One paragraph. What the implementation accomplishes, in present tense as if it were done. References the approved direction from `brainstorm-design`.

## Approved substrate

The substrate this plan must preserve and the substrate it adds. Implementation that violates or omits any of these is incomplete.

- **Spec:** `path/to/spec.md` (rewritten by `rewrite-specs`; reviewed by `review-spec-cohesion`)
- **Behavior matrix:** `path/to/matrix.md` — cells in scope: <IDs>
- **Named invariants:**
  - `INVARIANT_A` — preserved
  - `INVARIANT_B` — newly required by this change; enforcement: <test/type/constraint/linter/runtime wrapper>
- **Gotchas:** <names of gotchas this implementation must respect>
- **Semantic linter specs:** <names; specs only — implementation may be deferred>

## Architecture

Brief. The structural shape of the change — which subsystems, which seams, which interfaces. References the approved direction from `brainstorm-design`.

## Files to create or modify

| File | Responsibility | Why this file |
|---|---|---|
| `path/to/file.ts` | <one line> | <why here, not elsewhere> |
|   |   |   |

## Confidence gates

What the implementation must satisfy before each task is considered done:

- **Failing tests to write first:** <list — TDD-style, before implementation>
- **Tests that must pass:** <list — including the failing tests above, after implementation>
- **Semantic checks:** <new lints to satisfy>
- **CI checks:** <gates that must remain green>
- **Manual review questions:** <questions the reviewer should answer>

## Tasks

### Task 1: <name>

**Invariant preserved:** <name>
**Matrix cells touched:** <IDs>
**Gotcha to respect:** <name or "none">

- [ ] Write failing test for <behavior>
- [ ] Verify the test fails for the right reason
- [ ] Implement minimal change
- [ ] Run targeted tests
- [ ] Update substrate if needed (matrix cell, invariant scope, gotcha)
- [ ] Commit

### Task 2: <name>

(same structure)

## Out of scope

Things this plan deliberately doesn't do, even though they came up:

- <item> — <why deferred>

## Substrate to update during implementation

If implementation reveals a gap, update these substrate artifacts inline:

- <substrate path> — when <condition>

## Definition of done

The change ships when:

- [ ] All tasks above complete
- [ ] All confidence gates pass
- [ ] Behavior matrix cells in scope have corresponding tests
- [ ] Named invariants have enforcement (not just docs)
- [ ] Substrate updated where the plan said it would be
- [ ] PR description references the spec, matrix cells, and invariants
