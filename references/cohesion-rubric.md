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

`review-codebase` returns ratings on these nine axes. Use *Healthy / Mostly healthy / Under-enforced / Drifting / At risk* as the rating vocabulary.

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

When `review-codebase`, `review-diff`, or `validate-rewrite` returns issues, use:

- **Blocker** — would produce or has produced a real defect; substrate must be repaired before further work in this area
- **High** — high-leverage substrate gap; not yet a defect, but a predictable source of future defects
- **Medium** — substrate improvement worth making in the next pass
- **Low** — taste-level observation; useful context but not actionable on its own

This is the canonical severity vocabulary; reviewer agents (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md` §"Output format conventions") and chat-rendered review outputs cite this list rather than restate it.

### Verdict → severity-floor mapping (validate-rewrite)

`validate-rewrite` returns one of three verdicts. Severity gates the verdict deterministically:

- **Approved** — highest severity present is `Medium`, `Low`, or none. The rewrite is implementable now; the disposition rule below specifies what (if anything) to close before merge.
- **Issues Found** — highest severity present is `High` or `Blocker`. The rewrite is salvageable but not merge-ready; a repair pass + re-validation is required.
- **Design Incoherent** — verdict orthogonal to severity. The design itself is incoherent; spec repairs won't help. Return to `brainstorm-design`.

This pin is normative: an agent that returns `Issues Found` with no `High` or `Blocker` finding violates the verdict contract (and vice versa, an `Approved` verdict with a `High` finding is a contract violation). The agent verdict definitions at `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md` §"How to structure your output" cite this mapping rather than restate it.

## Disposition rule for validation-review findings

When `validate-rewrite` returns a verdict, the recommendation that follows is determined by the verdict and the highest severity present among the findings. The rule below picks; the agent does not render a menu of options.

| Verdict | Highest severity present | Recommendation | Re-validate after repair? | Canonical Disposition phrase |
|---|---|---|---|---|
| Approved | none | Route to the implementation decision matrix in `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Output format" | N/A | `Merge as-is — no findings` |
| Approved | Low | Close inline (≤2 lines per finding) | No | `Close inline (≤2 lines per finding) → merge` |
| Approved | Medium | Close in the same worktree before merge | Yes if the repair adds a new file or named invariant; otherwise no | `Close in same worktree → merge` |
| Issues Found | High or Blocker | Repair, then re-run `validate-rewrite` | Yes | `Repair → re-validate` |
| Design Incoherent | — | Return to `${CLAUDE_PLUGIN_ROOT}/skills/brainstorm-design/SKILL.md` with the reviewer's report | N/A (no repair pass at this verdict) | `Return to brainstorm-design` |

The 5-row table is total over the verdict→severity-floor mapping above: every legitimate `(verdict, highest-severity)` pair maps to exactly one row. Combinations the verdict-floor mapping forbids (e.g., `Approved + High`, `Issues Found + Medium`) are contract violations on the agent's verdict choice, not gaps in the disposition rule. The **Canonical Disposition phrase** column is the literal string the dispatching skill and the cohesion-review template render in the validation review's `## Recommended next Cohesive skill` section; citing surfaces (`${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Output format", `${CLAUDE_PLUGIN_ROOT}/references/templates/cohesion-review.md` §"Recommended next Cohesive skill") cite this column rather than restate the strings.

**Why this is a rule, not a menu.** The "Three options" pattern (offering the reader a choice between fix-and-merge, substrate-note-and-merge, and pause) emerges when the agent treats the disposition as a judgment call. It violates `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule #5 ("Recommend exactly one next move") by forcing the reader to re-derive what to do. The rule above eliminates the menu surface: the verdict + highest severity determine the recommendation, deterministically.

**Substrate-note as user override.** The default for `Approved + Low` is close-inline (the lower-friction path). When the user judges that a finding has cross-pass relevance — future reviewers should see it as deferred substrate, not silently repaired — the user overrides the close-inline default and substrate-notes the finding in the ledger §"Remaining ambiguity" with a stable ID, rationale, and a citation to the validation review that surfaced it. See `${CLAUDE_PLUGIN_ROOT}/references/templates/design-delta-ledger.md` §"Remaining ambiguity" for the contract. A user-elected substrate-note that does not land in the ledger is a substrate violation — the next reviewer can't see it, and the same gap surfaces again in a future pass. The override does not change the agent's rendered Disposition phrase; the agent renders the rule's default, and the user's override is a post-render move.

**User override.** The user can override the rule's recommendation ("just merge — I don't care about the Medium", or substrate-note the Low instead of close-inline). The override is a deliberate move against a published default, not a derivation from a menu. Overrides do not require general ledger annotation in v0.1, *except* substrate-note overrides per the section above (which use the ledger §"Remaining ambiguity" residue the rule already provides). The cost of unannotated overrides is observability: the team cannot count silent overrides per release cycle. Re-evaluation trigger: if more than 3 `validate-rewrite` passes in a single release cycle reveal the same finding repeatedly because it was silently overridden, promote a first-class override-residue surface (a §"Overrides applied" section in the ledger) in the next pass and update this clause.

**Citations.** `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Output format", `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md` §"How to structure your output", `${CLAUDE_PLUGIN_ROOT}/references/templates/cohesion-review.md` §"Recommended next Cohesive skill", and `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"When sections may differ" (the `validate-rewrite` deviation entry) all cite this section — including the `Canonical Disposition phrase` column for the literal phrase strings — rather than restate the table. Single canonical home prevents the same multi-surface drift that pre-`design/cohesion-review-cleanup` §"Delta at a glance" exhibited.

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
