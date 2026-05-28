---
name: rewrite-specs
description: Use after brainstorm-design has produced an approved direction and before any code is written. Hard-rewrites design docs, specs, behavior matrices, invariants, gotchas, and substrate maps to describe the chosen end state as if it were already true — not as "we will" or "we should consider." Lands rewrite commits on a `design/<slug>` branch; the git diff is the authoritative record of what changed. Triggers on "rewrite the specs for X", "update the design docs to reflect Y", "make the docs match the chosen direction", "produce a spec rewrite for the new architecture". Always work in a worktree; always pair with validate-rewrite afterwards.
---

# Rewrite specs

## What this skill produces

- A **set of rewritten docs** that describe the system's chosen end state in present-tense, normative language
- A **rewrite commit** (or repair commit, on repair-pass mode) on a `design/<slug>` branch whose message body carries a `Classification:` trailer (`Pure implementation` / `Design` / `Mixed`). The git diff between `merge-base(main, HEAD)` and `HEAD` is the authoritative record of what the rewrite changed; no separate persisted artifact describes the change.
- A handoff to `validate-rewrite` for fresh-eyes review

This is one of Cohesive's flagship skills. Spec rewriting is the cheapest place to discover that a design is wrong, and the rewrite-then-review loop is what makes that discovery happen *before* code.

## Voice

Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output. The voice guide is the load-bearing source for verdict-leads, header-depth cap, density budgets, and forbidden phrasings; the imperative above is what triggers the model to load it via a Read tool call. Do not reproduce the imperative or any citation to the voice guide inside the Output format render template — instructions placed inside render templates leak verbatim into user-facing output.

## Hard constraints

1. **An approved direction is required.** Don't try to detect prior brainstorm output from session memory — that detection silently degrades. The skill takes a chosen direction explicitly from its dispatcher; if none was passed, ask.

   **Explicit dispatch (skip the question).** Whenever this skill is invoked from another Cohesive skill via the Skill tool, the dispatch prompt names the chosen direction. Three dispatch shapes apply:

   - **Router dispatch from `cohesively`** — the router passes the brainstorm-approved direction per `${CLAUDE_PLUGIN_ROOT}/skills/cohesively/SKILL.md` §"Dispatch prompt contract".
   - **Repair-loop dispatch from `validate-rewrite`** — the dispatch prompt names a per-pass validation review path under `docs/cohesive/reviews/` and instructs repair-mode operation. The "approved direction" is the *repair scope*; treat each ranked repair in the cited review as the rewrite's input. Process Step 1b governs repair-mode mechanics.
   - **Direct user invocation with inline direction** — the user names a direction in the invocation prompt ("rewrite specs for X; the chosen direction is Y").

   **If no direction is passed,** open the turn with the canonical forced-choice question:

   > "I see we're about to run rewrite-specs. Has a direction been chosen (from a prior `brainstorm-design`, an architecture review, or named by you), or should I run `brainstorm-design` first to produce one?"

2. **Work in a worktree.** Spec rewrites can be invasive. Isolation lets the user review the rewrite as a coherent diff and discard if needed. See "Worktree handling" below.
3. **No code changes.** Specs and docs only. If a doc claims behavior the implementation doesn't yet have, that's expected — implementation follows in a separate phase.
4. **Hard rewrite, not append.** Replace obsolete normative claims; don't leave them in place with a "(deprecated)" note next to the new claim. Contradictory docs are worse than slightly-stale docs.
5. **End-state language only.** "The system does X" — not "the system should do X" or "we will move toward X." If something is genuinely speculative, mark the *whole section* as non-normative; don't sprinkle "should" through normative sections.

## Worktree handling

Before rewriting, set up an isolated workspace.

**Detection.** Check the available-skills list in the session's system reminder. If `superpowers:using-git-worktrees` appears there, Superpowers is installed; if not, use the fallback. This is the platform-native check — there is no separate "is plugin X installed" API; the harness exposes installed-skill availability through the system reminder, and that's the source of truth.

**If `superpowers:using-git-worktrees` is available:** invoke it via the Skill tool with branch name `design/<slug>` where `<slug>` describes the rewrite topic. Superpowers handles directory selection (`.worktrees/` preferred), gitignore safety, project setup, and baseline test run.

**Fallback if superpowers isn't installed:**

```bash
mkdir -p .worktrees
grep -qF .worktrees .gitignore 2>/dev/null || echo '.worktrees/' >> .gitignore
slug=<topic-slug>
git worktree add .worktrees/cohesive-${slug} -b design/${slug}
cd .worktrees/cohesive-${slug}
```

Announce in chat: "Working in worktree `.worktrees/cohesive-${slug}` on branch `design/${slug}`."

## Process

### 1. Read the approved direction and the substrate context

Inputs:
- The recommended direction from `brainstorm-design` (option name, summary, main risk, structural mitigation)
- The substrate discovery from `discover-substrate` (existing specs/matrices/invariants and what was missing)
- Pressure-test answers (which docs change, which concepts get renamed, which invariants are added)

### 1a. Classify the rewrite

Before identifying the doc surface, classify whether the rewrite is:

- **Pure implementation** — touches `${CLAUDE_PLUGIN_ROOT}/skills/<name>/SKILL.md` bodies and other implementation surfaces only. No skill purpose/ownership/seam/verdict changes. Skip the design layer; the rewrite proceeds against SKILL.md and the surrounding implementation surface.
- **Design** — touches skill purpose, ownership, seams, verdicts, or the chain itself. Update the design-layer surfaces (skill purpose docs, handoff contracts) **first** in this rewrite. SKILL.md changes follow.
- **Mixed** — both. Land the design-layer changes *first* in the commit sequence, then the implementation changes. The design layer is the substrate; the SKILL.md is the implementation of that substrate.

Default to **Mixed** when ambiguous. The cost of over-classifying is one additional doc edit; the cost of under-classifying is a substrate-implementation collapse.

The classification persists in the rewrite commit message body as a `Classification:` trailer (see Step 6 below). `spec-cohesion-reviewer` reads the trailer during `validate-rewrite` and cross-checks it against the spec diff: a `Pure implementation` rewrite whose diff touches design-layer files (e.g., seam docs, named-invariant docs) raises an Important issue.

### 1b. Repair-pass mode (if the input is a validate-rewrite review)

When the input is a `validate-rewrite` review with a `Repair → re-validate` or `Close in same worktree → merge` disposition, "the recommended direction" is the enumerated repair list, not a brainstorm option. Skip Step 2's full doc-surface scan — the surface is already fixed by the review's findings. Each ranked repair already names a specific artifact (file:line, named invariant, gotcha, matrix); rewrite those surfaces to address the finding. The repair commit message body cites the originating review finding IDs (e.g., `Closes: B1, I2`) so the next `validate-rewrite` reader can grep the commit history to see what each repair pass closed. Step 1a's classification still applies — a repair-pass rewrite is typically **Pure implementation** (textual fixes against named findings) but can be **Mixed** when the repair touches design-layer surfaces.

### 2. Identify the doc surface to rewrite

For each doc in the substrate discovery's "Relevant specs/docs" section, decide:
- **Rewrite** — normative content changes
- **Add** — new doc needed for new behavior
- **Remove or deprecate** — obsolete; deletion or explicit deprecation
- **Untouched** — describes a part of the system this rewrite doesn't affect

If a doc is in "Untouched," skip it. If you're not sure, err on the side of leaving it alone; surgery beats wholesale rewrite.

### 3. Rewrite each affected doc to end-state

For each rewrite:
- Open the doc; identify what it normatively claims about the system
- Replace those claims with the new design's claims, in present tense
- Remove obsolete concepts entirely (don't leave them as "previously called X")
- If a section becomes non-normative speculation, label the whole section "## Future direction (non-normative)" — don't sprinkle "may" or "should consider" through normative paragraphs
- When the prose enumerates substrate (named invariants, gotchas, matrices, specs), reference the canonical list categorically rather than by count per `${CLAUDE_PLUGIN_ROOT}/references/substrate-references.md`. Constraint counts that express a design property ("four-concept core," "seven primitives") stay; inventory counts that tally items enumerated elsewhere ("the 9 invariants," "ships 8 gotchas") get replaced with a categorical reference plus a link to the canonical home.

For each new doc, use the appropriate template:
- Behavior matrix: `${CLAUDE_PLUGIN_ROOT}/references/templates/behavior-matrix.md`
- Named invariant: `${CLAUDE_PLUGIN_ROOT}/references/templates/invariant.md`
- Gotcha: `${CLAUDE_PLUGIN_ROOT}/references/templates/gotcha.md`
- Substrate map: `${CLAUDE_PLUGIN_ROOT}/references/templates/substrate-map.md`
- Claimed system shape (Phase 1 of `cohesive:review-codebase`): `${CLAUDE_PLUGIN_ROOT}/references/templates/claimed-system-shape.md`

Place new canonical artifacts (invariants, matrices, gotchas) under the repo's existing doc convention (`docs/design/`, `docs/specs/`, `docs/adr/`, etc.). Extend what's there — don't impose a parallel layout.

### 4. Update the substrate map

If a substrate map exists at the repo level, update it to reflect the rewrites: new specs, new matrices, new invariants, removed concepts. If no substrate map exists yet, **don't create one as part of this rewrite** — that's a separate decision the user should make explicitly.

### 6. Commit the rewrite

For a **forward** rewrite (initial pass against an approved direction):

```bash
git add -A
git commit -m "design: rewrite specs for <topic>

Approved direction: <option name>
Classification: <Pure implementation | Design | Mixed>
"
```

The `Classification:` trailer is required and is what `spec-cohesion-reviewer` reads during `validate-rewrite` to cross-check against the diff (see Step 1a above).

For a **repair-pass** rewrite (Step 1b — invoked from `validate-rewrite`'s repair loop or by the user against a disposition that routed back here), the commit message cites the pass number and the closed finding IDs so `git log --grep "pass-"` over the `design/<slug>` branch yields the per-handoff auditing surface the repair loop promises:

```bash
git add -A
git commit -m "design: repair pass-<N> — closes <finding IDs>

Pass: <N>
Closes: <comma-separated finding IDs, e.g., B1, I2, I3>
Source review: docs/cohesive/reviews/<YYYY-MM-DD>-<slug>-rewrite-validation[-pass-<N-1>].md
Classification: <Pure implementation | Design | Mixed>
"
```

The commit message is the auditing surface for repair sequences. Both templates require the `Classification:` trailer.

### 7. Hand off to review

Announce: "Spec rewrite complete on branch `design/<slug>`. Ready for fresh-eyes review via `cohesive:validate-rewrite` (which reads the spec diff directly from git). After Approved verdict, the implementation route — `cohesive:implement-cohesively` — drives code against the spec diff anchored at the rewrite-tip SHA the validation review captures; the validate-rewrite Approved footer renders the full decision matrix."

`validate-rewrite` always dispatches the `spec-cohesion-reviewer` agent in a Task subprocess with no inherited conversation context — the structural fresh-eyes fence is the harness's subprocess isolation, not which conversation the user invokes the review from. Whether `validate-rewrite` is invoked directly from this turn (e.g. by the `cohesively` router chaining the `design` route) or from a fresh session, the dispatched agent reads only paths it's passed.

## Output format

The skill's chat output (separate from the file changes) is short:

```md
# Spec Rewrite Complete — <topic>

**Worktree:** `.worktrees/cohesive-<slug>` on `design/<slug>`
**Approved direction:** <option name>
**Classification:** <Pure implementation | Design | Mixed>

### Files rewritten
- `path/to/file.md` — <one-line summary of change>
- ...

### Files added
- `path/to/new.md` — <purpose>
- ...

### Files removed / deprecated
- `path/to/old.md` — <why>
- ...

### Substrate updated
- Specs touched
- Behavior matrices touched (including which are new)
- Named invariants touched (with names)
- Gotchas touched (with names)
- Semantic linter specs touched (proposed, not implemented; with names)

### Remaining ambiguity
- <thing the rewrite couldn't fully resolve>

### Next
Fresh-eyes review of the rewritten specs against the design and approved direction. *(`cohesive:validate-rewrite`.)* **Scope:** the spec diff on branch `design/<slug>` (`git diff $(merge-base main HEAD)..HEAD`) — validate-rewrite reads the diff directly.
```

## Anti-patterns (Red Flags)

| Anti-pattern | Why it's wrong | Fix |
|---|---|---|
| Adding "(deprecated)" alongside a new claim, leaving the old claim in place | Contradictory docs are worse than stale docs | Replace, don't append |
| "We should consider moving toward X" in a normative section | Hedge language obscures what the doc actually claims | Move to "Future direction (non-normative)" or commit to it |
| Sprinkling "may" / "could" / "TBD" through end-state docs | Makes the doc unimplementable from itself | Either commit or mark the section non-normative |
| Preserving obsolete concept names "for politeness" | Concept proliferation is the most expensive form of doc rot | Remove the old name; if needed, add a one-line "Renamed from X" note in a migration section |
| Making implementation the only place where behavior is knowable | Defeats the purpose of substrate-first work | Add the behavior to a spec or matrix |
| Treating all future pressure as current scope | Spec bloat; future pressure becomes implicit promise | Keep future pressure in a clearly-marked non-normative section |
| Rewriting docs in the main worktree | Loses the ability to review the rewrite as a coherent diff | Use a worktree |
| Omitting the `Classification:` trailer from the rewrite commit body | `spec-cohesion-reviewer` has no human-authored classification to cross-check against the diff; raises a Blocking Issue | Always include the `Classification:` trailer in the rewrite commit message per Step 6 |
| Claiming a Pure-implementation classification when the diff touches design-layer surfaces | The classification trailer disagrees with what the diff shows; surfaces an Important issue in validate-rewrite | Use Mixed when in doubt; the cost of over-classifying is one extra doc edit |

## Acceptance criteria

- All affected docs are in end-state language; no "we will" / "should consider" in normative sections.
- Obsolete concepts are removed, not annotated.
- The rewrite commit message body carries a `Classification:` trailer (`Pure implementation` / `Design` / `Mixed`).
- Substrate map (if it exists) is updated.
- The rewrite happens on a `design/<slug>` branch in a worktree.
- A commit captures the rewrite atomically.
- The skill does not invoke `validate-rewrite` — handoff is announced; user invokes the review.

## What this skill is *not*

- Not implementation. No code, no tests, no CI changes.
- Not the review. The fresh-eyes review of the rewrite is `validate-rewrite`, run separately.
- Not where new substrate concepts get *invented*. The direction was decided in `brainstorm-design`. This skill writes that direction down.
