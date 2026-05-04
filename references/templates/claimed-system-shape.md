# Claimed system shape

The canonical Phase 1 output of `review-codebase`. Filled by reading the codebase's normative docs (CLAUDE.md / AGENTS.md / architecture.md / README.md / docs/design / docs/specs / docs/adr / docs/invariants / docs/gotchas / docs/testing) and summarizing what the codebase claims about itself.

This summary is the baseline for Phase 3. The four reviewer agents compare implementation against *what the docs claim*, not against generic taste — so the quality of this summary determines the quality of the review.

## Template

```md
## Claimed system shape

### Product goal
<What the team says the product does. One paragraph. Verbatim from README/architecture if possible; paraphrased only if the original is contradictory or stale.>

### Architectural priors
<What the team says about how it's built — the architectural commitments the docs surface. Bulleted list. Examples: "three-layer separation", "composition over reinvention", "substrate before implementation".>

### Intended seams
<The boundaries the team has named. Concrete: where the docs say one subsystem ends and another begins; what the shared interfaces are. Bulleted list.>

### Named invariants
<Global rules with stable names (SHOUTY_CASE) that the docs enforce. Bulleted list. If the codebase has none — say so. "None encoded as artifacts" is a legitimate finding.>

### Testing philosophy
<What the team says tests should pin. e2e / integration / unit balance. Behavior-matrix-cell tests. Regression tests for gotchas. If the codebase has no tests — say so.>

### Future direction implied by docs
<Where the docs hint the system is going. What's labeled "future" or "V1" or "out of scope for now." This is what reviewers use to judge whether the architecture is shaping up to where the product is going.>
```

## How to fill it

- **Read normative docs first**, before any implementation file. The summary is what the docs claim; implementation comparison is Phase 3, not Phase 1.
- **Quote when possible.** The summary should be a faithful paraphrase, not the reviewer's own interpretation.
- **Separate "found" from "missing."** If "Named invariants" is empty because no invariants are encoded, write that explicitly: "None encoded as artifacts; rules locked in plan prose only."
- **Don't editorialize.** Phase 1 is read-the-docs, not judge-the-docs. Judgment is Phase 2 (spec-prior gate) and Phase 3 (focused reviewers).
- **Bound your length.** This summary is consumed by four reviewer agents; keep it tight. ~80–150 lines is typical.

## Why each section matters

- **Product goal** — anchors every finding in "is this codebase serving its stated purpose?"
- **Architectural priors** — lets reviewers compare the claimed structure against the structure on disk.
- **Intended seams** — substrate-alignment-reviewer and structure-reviewer both use this to detect spec drift and seam violations.
- **Named invariants** — the substrate-alignment-reviewer's primary anchor. If empty, that *is* the headline finding.
- **Testing philosophy** — substrate-alignment-reviewer compares this against the actual `tests/` directory; mismatches drive test-guarantee findings.
- **Future direction implied by docs** — feeds into agent-readiness ("could a future agent extend this?") and structure ("are seams shaped for future changes?").

## Consumers

This template is consumed by:

- `${CLAUDE_PLUGIN_ROOT}/skills/review-codebase/SKILL.md` Phase 1 (always)
- All four reviewer agents in `${CLAUDE_PLUGIN_ROOT}/agents/` as their first input
- The synthesizer in `review-codebase` Phase 4 (to anchor the thesis)

When the template changes, all five files above need to know.

## Anti-patterns

| Anti-pattern | Why it's wrong | Fix |
|---|---|---|
| Filling sections with "TBD" or "unclear" | Reviewers can't anchor against vagueness | If the docs don't say, write "Not stated in normative docs" — that's a finding for Phase 2 |
| Editorializing in Phase 1 ("the team should also...") | Phase 1 is descriptive; judgment is Phase 2/3 | Restate what the docs claim; save judgment for the synthesizer |
| Skipping "Named invariants: none" when there are none | Reviewers will assume invariants exist and look for enforcement | Always state explicitly when a section is empty |
| Quoting >50% of any normative doc | The summary is a summary, not a copy | Paraphrase faithfully; quote only the load-bearing claims |
