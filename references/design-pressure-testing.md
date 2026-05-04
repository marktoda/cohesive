# Design pressure-testing

A design that hasn't been attacked is just a preference. Pressure-testing is how Cohesive turns a brainstormed option into a recommendation that has earned its place. It is the second half of `brainstorm-design` and the question battery `rewrite-specs` and `review-spec-cohesion` use to keep designs honest.

## When to pressure-test

- After `brainstorm-design` has produced 2–4 options and before any one of them is recommended
- Before `rewrite-specs` is invoked — pressure-testing is what selects the option being rewritten
- During `review-spec-cohesion` — the reviewer asks the same questions of the rewritten spec to check that the rewrite preserved the answers
- Whenever a design feels "obviously right" — that's the moment it most needs attack

## The question battery

Run this checklist against each option. The output of `brainstorm-design` should answer every question that applies; "N/A" is acceptable when justified, "I don't know" is not — fill the gap before recommending.

### Spec impact
1. **What docs would need to change?** Name the files. If you can't name them, you don't yet know what the system claims about itself.
2. **What docs become obsolete?** Listing what gets deleted is as important as listing what gets added.
3. **What concept gets renamed or merged?** If the design changes a category, surface that explicitly.

### Behavior matrix impact
4. **What matrix cells get added?** Use stable IDs if a matrix already exists.
5. **What matrix cells get removed or invalidated?** Removal is the easy one to miss.
6. **What new branchy behavior appears that wasn't in the old matrix?**

### Invariant impact
7. **Which existing invariants get stronger, weaker, or newly required?**
8. **What new global rule does this design depend on?** Name it. If it doesn't have a name yet, propose one (`SHOUTY_CASE`).
9. **What enforcement path does the new invariant need?** Test, type, constraint, semantic linter, runtime wrapper — be specific.

### Test impact
10. **Which existing tests become misleading?** A test that passes for the wrong reason is worse than no test.
11. **Which existing tests become inadequate?** They still pass but no longer guarantee what matters.
12. **What test would have caught the bug this design is preventing?** If you can't write that test, the design's defect story is fuzzy.

### Locality and abstraction
13. **Which subsystem now needs more context to change?** Increased required context is a hidden cost.
14. **Which subsystem now needs less?** Decreased required context is a hidden benefit.
15. **Does this centralize too early?** Is the shared contract real, or is this just code-shape similarity?
16. **Does this duplicate locally for clarity?** If so, what enforces consistency between the duplicates?
17. **What seam does this design create?** Name it. Seams that aren't named drift.

### Future fit
18. **What future idea does this make easy?** Be specific — name a concrete future feature, not "extensibility."
19. **What future idea does this make hard?** Every design closes some doors. Surface which ones.
20. **What future idea does this *appear* to make easy but actually doesn't?** This is the most dangerous category.

### Gotcha and scar surface
21. **Which existing gotcha does this design rediscover?** Read `docs/substrate/gotchas/**` (or repo-native equivalents) and any incident notes before answering.
22. **Which gotcha does this design retire?** Conversely.
23. **What new failure mode does this design introduce that the team hasn't seen before?**

### Enforcement edges
24. **What invalid change remains too easy to ship after this design?** A design that prevents the obvious mistakes but leaves the subtle ones is half-done.
25. **What semantic linter would prevent the most likely future mistake in this area?** Even if you don't implement it, naming it is substrate.

## Worked example

For a hypothetical "split intake classification into per-connector adapters + shared decision kernel" design:

- **Q1 (docs to change):** `docs/intake/classification.md`, `docs/connectors/slack.md`, `docs/connectors/telegram.md`. ✓
- **Q4 (matrix cells added):** New matrix `docs/intake/decision-kernel-matrix.md` with cells for cross-channel decisions. Slack thread cases stay in the Slack matrix.
- **Q7 (invariants):** Strengthens `INTAKE_DETERMINISTIC` (decision kernel is now pure). Adds `CONNECTOR_NORMALIZATION_BOUNDARY` (connectors must produce normalized events; kernel must not see channel-native shapes).
- **Q9 (enforcement):** Boundary invariant needs a semantic linter — the decision kernel module must not import from any connector module. Test: kernel module's import list is whitelisted.
- **Q13 (more context):** Adding a new connector now requires understanding the normalized event shape *and* the decision kernel's expectations. Mitigated by Q9 boundary + a normalized-event spec.
- **Q15 (premature centralization):** Risk: yes — decision kernel might absorb things that should stay connector-local. Mitigation: matrix cells default to connector-local; only stable cross-channel decisions enter the kernel.
- **Q21 (rediscovered gotcha):** None known.
- **Q24 (still-easy invalid changes):** A connector could short-circuit the kernel and make decisions inline. Mitigated by Q9 linter.

The summary recommendation can now reference these answers concretely instead of arguing in the abstract.

## Comparison rubric

When pressure-testing produces side-by-side analyses of multiple options, render the comparison as a small table to make the trade-offs legible:

| Option | Cohesion | Substrate delta | Future fit | Locality | Main risk |
|---|---:|---|---|---|---|
| A | High | Small | Medium | Strong | Behavior drift across connectors |
| B | Low | Large | High | Weak | Premature centralization |
| C | High | Medium | High | Strong | Boundary must be enforced (Q9) |

The "Main risk" column is the single most important. If you can't name the main risk of an option, you haven't pressure-tested it.

## Anti-patterns

- **Asking the questions but answering them generically.** "Yes, this could affect future extensibility" is not an answer. Name the future feature.
- **Treating "we'd add a test" as enforcement.** Tests are enforcement *if they would fail* on the violation. Many proposed tests wouldn't.
- **Skipping question 20** (the appears-easy-but-isn't trap). It's where most design self-deception lives.
- **Pressure-testing only the option you already prefer.** Attack the alternative you'd reject just as hard. If you can't, the rejection is taste, not analysis.
- **Recommending an option whose main risk is mitigated by "we'll be careful."** That's not mitigation. Mitigation is structure: a test, a linter, a boundary, a constraint.

## Output integration

When `brainstorm-design` runs the battery, the resulting report includes a "Pressure test summary" section with the comparison table and a "Breakage analysis" section organized by category (docs / assumptions / matrices / invariants / tests / gotchas / locality). See `${CLAUDE_PLUGIN_ROOT}/skills/brainstorm-design/SKILL.md` for the canonical output format.
