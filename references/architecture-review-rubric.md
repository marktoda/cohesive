# Architecture review rubric

The rubric `review-codebase` follows. It implements the four-phase architecture review.

## What this rubric optimizes for

A principled architecture review whose goal is **not** to find bugs or style issues. The goal is to determine whether the codebase has a coherent, durable substrate: clear specs, aligned implementation, principled domain concepts, enforceable invariants, appropriate locality, strong tests, and enough encoded judgment that future humans and agents can safely extend the system without relying on the original architect's memory.

## The four phases

### Phase 1: Read normative substrate

Before reading any implementation file, read what the codebase claims about itself.

In priority order, read what exists:
1. `CLAUDE.md`, `AGENTS.md`
2. `architecture.md`
3. `README.md`
4. `docs/design/**`, `docs/specs/**`, `docs/adr/**`
5. Repo-native substrate locations (invariants, gotchas, matrices, testing docs)

Use `discover-substrate` (or its `scan_substrate.py` script) to enumerate. Don't glob.

Output a **claimed system shape** summary:

```md
## Claimed system shape

### Product goal
<what the team says the product does>

### Architectural priors
<what the team says about how it's built>

### Intended seams
<the boundaries the team has named>

### Named invariants
<global rules with stable names>

### Testing philosophy
<what the team says tests should pin>

### Future direction implied by docs
<where the docs hint the system is going>
```

This summary is the baseline for everything in Phase 3. The reviewers compare implementation against *what the docs claim*, not against generic taste.

### Phase 2: Spec-prior review (the gate)

Before reviewing implementation, judge whether the docs themselves are coherent.

Ask:
- Are the docs internally consistent?
- Are architectural priors still good (or have they been quietly invalidated by product evolution)?
- Are there contradictions between design docs?
- Are old concepts still present in normative sections?
- Are important rules underspecified?
- Are invariants named, or are they only in folklore?

**Stop condition.** If the substrate is seriously inconsistent — three or more blocking issues at the spec level — stop the review and return a spec-prior report only. Don't dispatch the focused reviewers; reviewing implementation against a broken spec produces noise.

```md
## Spec-prior issues found

I should not do a full implementation review yet because the substrate itself is inconsistent.

### Blocking spec issues
1. ...
2. ...
3. ...

### Recommended substrate repairs
1. ...

### Why this matters
Reviewing code against contradictory or stale specs produces findings that are not actionable. Repair the substrate first; then re-run `review-codebase`.
```

If the substrate is coherent enough to continue, proceed to Phase 3.

### Phase 3: Focused reviewer dispatch

Dispatch the four reviewer agents in parallel using a single message with multiple Task tool calls. Each agent gets:
- The Phase 1 claimed-system-shape summary
- The list of normative doc paths
- A scoping hint (e.g., "review the whole repo" or "focus on subsystem X")
- An instruction to read paths surfaced by the substrate scan, not to glob the world

The four reviewer agents:

1. **`substrate-alignment-reviewer`** — does the implementation agree with what the docs claim, and is what *should* be invariant actually enforced?
2. **`structure-reviewer`** — are seams in the right places, concepts right-sized, locality preserved?
3. **`library-native-reviewer`** — where is code fighting its frameworks/type system instead of using them natively?
4. **`agent-readiness-reviewer`** — could a future agent or new contributor make a small correct change with bounded context?

Each returns a structured report. The synthesizer (Phase 4) merges them.

### Phase 4: Synthesis

The final report is **not** a flat list of findings. Start with a thesis.

**A good thesis:** one paragraph that names the codebase's overall shape, the highest-leverage risk, and whether the system is in a position to scale development without founder memory. Concrete; specific to this codebase; not generic.

Example:

> Cornbot is broadly moving toward the right architecture: connector-local adapters, shared decision kernels, and explicit workflow state. The main risk is that several company-defining invariants are still enforced by convention rather than structure. The code is locally competent, but the substrate is not yet strong enough for the company to scale development without founder memory.

After the thesis: the verdict, the cohesion scorecard (9 axes from `cohesion-rubric.md`), and ranked findings.

## Verdict vocabulary

Use one of:

- **Healthy** — substrate strong; future contributors can change the system safely
- **Mostly healthy** — solid substrate with a few high-leverage gaps
- **Cohesive but under-enforced** — concepts and architecture are right, but rules depend on memory rather than structure
- **Spec drift risk** — implementation has diverged from docs in ways that produce confusion
- **Architecture risk** — the structural shape itself is wrong for where the product is going

## Findings format

Findings are ranked by **leverage × severity**, not by where they were found.

```md
### [N]. <Finding title>

**Severity:** Blocker / High / Medium / Low
**Category:** Spec drift / Invariant / Locality / Tests / Domain model / Library alignment / Substrate / Agent-readiness
**Why it matters:**
<concrete consequence — not "could lead to bugs">

**Evidence:**
<file:line references; quoted snippets when illustrative>

**Recommended fix:**
<specific next step>

**Substrate artifact to add or update:**
Spec / behavior matrix / invariant / gotcha / semantic linter / test / type boundary
```

Every finding maps to a substrate artifact. If you can't name one, the finding may be preference rather than a real cohesion issue.

## What this review is *not*

- Not a code style review. Naming case, formatting, micro-naming preferences are out of scope.
- Not a defect hunt. Implementation bugs that aren't substrate gaps belong in `review-diff` or in the team's normal bug pipeline.
- Not a refactor proposal. Findings recommend substrate changes, not large code rewrites. (The team can decide whether to refactor based on the substrate that gets added.)

## Stop conditions

Stop the review and return early if:

- ≥3 blocking issues at the spec level (Phase 2 gate)
- The codebase has fewer than 5 normative doc files and no architecture.md/CLAUDE.md/AGENTS.md — recommend `cohesive:audit-substrate` instead, since the substrate is too thin for an architecture review
- The user explicitly scoped the review to a single subsystem and the subsystem doesn't exist as a clear seam — ask for clarification rather than guessing

## Token discipline

Architecture reviews can burn a lot of tokens. Discipline:

- Reviewers read **only paths surfaced by `discover-substrate`**, not arbitrary globs
- Each reviewer's output is bounded — long discussion belongs in linked appendix files if needed
- Implementation files are read selectively, anchored to the substrate (e.g., the file the spec claims implements feature X)
- The synthesizer merges; it doesn't re-read

## Phased roadmap section

The final report ends with a phased roadmap. Three phases:

1. **First: repair substrate.** What needs to be added or rewritten before any other work — specs, invariants, matrices, gotchas, linters.
2. **Then: simplify architecture.** What structural changes follow naturally from the repaired substrate.
3. **Then: strengthen enforcement.** Where the team should turn convention into automation (semantic linters, CI checks, runtime wrappers).

This sequencing matters: substrate first, structure second, enforcement third. Inverting it produces churn.
