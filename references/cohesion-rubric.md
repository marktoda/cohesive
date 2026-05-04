# The cohesion rubric

How to judge whether a subsystem, change, or whole codebase is *cohesive*. This is the rubric Cohesive's review skills score against.

## What cohesion means here

A cohesive system has these properties:

1. **Behavior is knowable outside the implementation.** A future contributor can read the spec, the behavior matrix, the test names, and the invariant docs and learn what the system is supposed to do without reading every implementation file.
2. **Implementation agrees with what's documented.** Specs and code don't drift in opposite directions. When they do, one of them is wrong, and the team treats that drift as a real bug.
3. **Important global rules are named, scoped, and enforced.** "Every external mutation produces an audit event" exists as `AUDIT_EXTERNAL_MUTATION` with a documented scope, a list of runtime paths, and an enforcement story (test, type, semantic linter, runtime wrapper, CI check).
4. **Branchy behavior is written down as cases.** Where the system has 6 ways to handle an inbound message, those 6 are enumerated with stable IDs (C001..C006), and tests are named after cells where practical.
5. **Locality is preserved.** Subsystems can be understood and modified in isolation. Premature centralization is rare. Where shared abstractions exist, the shared contract is real.
6. **Scars are documented.** Old incidents have notes that explain symptom, why it happened, the tempting wrong fix, and the correct pattern. New contributors don't rediscover them.
7. **The codebase teaches itself.** A new agent or human, given only the docs and the build, can make a small correct change without needing the original architect.

## The 9-axis scorecard

`cohesive-review --scope codebase` returns ratings on these nine axes. Use *Healthy / Mostly healthy / Under-enforced / Drifting / At risk* as the rating vocabulary.

### 1. Spec coherence

Are the docs internally consistent? Do they describe the same system?

- **Healthy:** Docs agree with each other, are dated or versioned where needed, describe current reality.
- **Drifting:** Multiple docs describe the same thing differently; some refer to old concepts.
- **At risk:** Foundational docs (architecture.md, README) are stale; trusting them produces wrong code.

### 2. Code/spec alignment

Does the implementation agree with what the docs say?

- **Healthy:** Implementation matches docs; deviations are flagged as known and explained.
- **Drifting:** Implementation has quietly evolved past the docs.
- **At risk:** Reading the docs would lead an agent or human to write incorrect changes.

### 3. Domain model clarity

Are concepts right-sized, well-named, and orthogonal?

- **Healthy:** Concepts are distinct; names are stable; nothing important is unnamed; nothing trivial is over-named.
- **Drifting:** Overlapping concepts; weak names; categories that don't match how the team actually thinks about the product.
- **At risk:** Foundational concepts are confused or overloaded; agents/humans can't infer behavior from types.

### 4. Invariant enforcement

Are the rules the system depends on actually enforced?

- **Healthy:** Important invariants are named, scoped, and enforced by structure (tests/types/constraints/linters/CI/runtime wrappers).
- **Under-enforced:** Invariants are stated in docs but enforcement depends on reviewer memory.
- **At risk:** Invariants exist only as folklore; no automated check would catch a violation.

### 5. Test guarantees

Do tests actually constrain behavior, or do they just check that code runs?

- **Healthy:** High-level e2e/contract tests cover important user-visible behavior; behavior matrix cells have corresponding tests; gotchas have regression tests.
- **Drifting:** Many small unit tests; few high-level guarantees; coverage looks high but real behavior isn't pinned.
- **At risk:** Tests are mostly tautological; refactors easily pass; behavior changes silently.

### 6. Locality and seams

Can subsystems be changed in isolation?

- **Healthy:** Clear seams between subsystems; minimal cross-subsystem coupling; shared abstractions only where the contract is real.
- **Drifting:** Some premature centralization; changes in one subsystem ripple unexpectedly.
- **At risk:** Major coupling across subsystems; changes require global understanding.

### 7. Library-native alignment

Is the code working *with* its frameworks, type system, and external libraries — or *against* them?

- **Healthy:** Idiomatic use; types align with library expectations; conventions match the ecosystem.
- **Drifting:** Some custom abstractions where library-native would suffice; occasional fights with the type system.
- **At risk:** Major reinvention of library-provided primitives; type system circumvented; constant friction.

### 8. Agent-readiness

Could a future agent (or new contributor) make a small correct change with bounded context?

- **Healthy:** A subsystem can be modified by reading just its files + linked specs/invariants/matrices.
- **Drifting:** Some subsystems require reading neighbors to understand; required context is creeping.
- **At risk:** Most subsystems require global understanding; agents reliably violate hidden rules.

### 9. Future extensibility

Does the architecture create the right change surface for the *next* ten changes the product will likely need?

- **Healthy:** Likely future changes are well-shaped; common new features land in obvious places; categories anticipated by the design hold up.
- **Drifting:** Some likely future changes will require awkward special cases.
- **At risk:** Likely future changes will require architectural rework; the design doesn't scale to where the product is going.

## Severity vocabulary for findings

When `cohesive-review` returns issues, use:

- **Blocking** — would produce or has produced a real defect; substrate must be repaired before further work in this area
- **High** — high-leverage substrate gap; not yet a defect, but a predictable source of future defects
- **Medium** — substrate improvement worth making in the next pass
- **Low** — taste-level observation; useful context but not actionable on its own

## How findings become substrate

Every finding should map to a substrate artifact:

| Finding type | Artifact to add or update |
|---|---|
| Behavior knowable only by reading code | Spec |
| Branchy behavior without enumeration | Behavior matrix |
| Global rule depending on memory | Named invariant + enforcement |
| Predictable future mistake | Semantic linter |
| Recurring bug class | Gotcha note + regression test |
| Wrong abstraction | Locality decision |
| Important behavior without test pinning | Test guarantee |
| Hidden coupling | Architectural seam (split or interface) |

If a finding cannot be mapped to a substrate artifact, ask whether it's a real finding or just preference.

## What this rubric is *not*

This is not a code style review. Cohesive is not concerned with naming case, comment style, or formatting beyond what affects the substrate. Generic style review is well-served by other tools.

This is also not a "ship faster" framework. Substrate work compounds, but it has upfront cost. The argument is that the compound returns are larger than the cost when the codebase needs to live for years and be edited by people who weren't there at the start.
