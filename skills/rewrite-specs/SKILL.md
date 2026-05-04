---
name: rewrite-specs
description: Use after brainstorm-design has produced an approved direction and before any code is written. Hard-rewrites design docs, specs, behavior matrices, invariants, gotchas, and substrate maps to describe the chosen end state as if it were already true — not as "we will" or "we should consider." Produces a design delta ledger documenting every change. Triggers on "rewrite the specs for X", "update the design docs to reflect Y", "make the docs match the chosen direction", "produce a spec rewrite for the new architecture". Always work in a worktree; always pair with review-spec-cohesion afterwards.
---

# Rewrite specs

## What this skill produces

- A **set of rewritten docs** that describe the system's chosen end state in present-tense, normative language
- A **design delta ledger** at `docs/cohesive/<topic>/design-delta.md` (or repo-convention path) recording every change
- A handoff to `review-spec-cohesion` for fresh-eyes review

This is one of Cohesive's flagship skills. Spec rewriting is the cheapest place to discover that a design is wrong, and the rewrite-then-review loop is what makes that discovery happen *before* code.

## Hard constraints

1. **An approved direction is required.** If `brainstorm-design` hasn't recommended a direction (or the user hasn't named one), stop and route to `brainstorm-design`.
2. **Work in a worktree.** Spec rewrites can be invasive. Isolation lets the user review the rewrite as a coherent diff and discard if needed. See "Worktree handling" below.
3. **No code changes.** Specs and docs only. If a doc claims behavior the implementation doesn't yet have, that's expected — implementation follows in a separate phase.
4. **Hard rewrite, not append.** Replace obsolete normative claims; don't leave them in place with a "(deprecated)" note next to the new claim. Contradictory docs are worse than slightly-stale docs.
5. **End-state language only.** "The system does X" — not "the system should do X" or "we will move toward X." If something is genuinely speculative, mark the *whole section* as non-normative; don't sprinkle "should" through normative sections.

## Worktree handling

Before rewriting, set up an isolated workspace.

**If `superpowers:using-git-worktrees` is available:** invoke it with branch name `design/<slug>` where `<slug>` describes the rewrite topic. Superpowers handles directory selection (`.worktrees/` preferred), gitignore safety, project setup, and baseline test run.

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

For each new doc, use the appropriate template:
- Behavior matrix: `${CLAUDE_PLUGIN_ROOT}/references/templates/behavior-matrix.md`
- Named invariant: `${CLAUDE_PLUGIN_ROOT}/references/templates/invariant.md`
- Gotcha: `${CLAUDE_PLUGIN_ROOT}/references/templates/gotcha.md`
- Substrate map: `${CLAUDE_PLUGIN_ROOT}/references/templates/substrate-map.md`
- Claimed system shape (Phase 1 of `cohesive-review --scope codebase`): `${CLAUDE_PLUGIN_ROOT}/references/templates/claimed-system-shape.md`

Place new docs under the existing repo convention if one exists (e.g. `docs/design/`, `docs/specs/`, `docs/invariants/`). Otherwise default to `docs/cohesive/<topic>/`.

### 4. Update the substrate map

If a substrate map exists at the repo level, update it to reflect the rewrites: new specs, new matrices, new invariants, removed concepts. If no substrate map exists yet, **don't create one as part of this rewrite** — that's a separate decision the user should make explicitly.

### 5. Produce the design delta ledger

Write `docs/cohesive/<topic>/design-delta.md` (or `<repo-convention>/design-delta.md`) using the template at `${CLAUDE_PLUGIN_ROOT}/references/templates/design-delta-ledger.md`. The ledger is what the fresh-eyes reviewer reads to understand the rewrite as a delta.

### 6. Commit the rewrite

```bash
git add -A
git commit -m "design: rewrite specs for <topic>

Approved direction: <option name>
See: docs/cohesive/<topic>/design-delta.md
"
```

### 7. Hand off to review

Announce: "Spec rewrite complete on branch `design/<slug>`. Design delta ledger at `docs/cohesive/<topic>/design-delta.md`. Ready for fresh-eyes review via `cohesive:review-spec-cohesion`."

Do **not** invoke `review-spec-cohesion` from inside this skill — the review must run in a different context that didn't see the rewrite happen.

## Output format

The skill's chat output (separate from the file changes) is short:

```md
## Spec rewrite complete

**Worktree:** `.worktrees/cohesive-<slug>` on `design/<slug>`
**Approved direction:** <option name>

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
- Specs: <count>
- Behavior matrices: <count, including which are new>
- Named invariants: <count, names>
- Gotchas: <count>
- Semantic linter specs (proposed, not implemented): <count>

### Design delta ledger
`docs/cohesive/<topic>/design-delta.md`

### Remaining ambiguity
- <thing the rewrite couldn't fully resolve>

### Next Cohesive skill
`cohesive:review-spec-cohesion` — fresh-eyes review of the rewritten specs against the substrate model and approved direction.
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
| Skipping the design delta ledger | Reviewer can't see the rewrite as a delta; review becomes "read everything again" | Always produce the ledger |

## Acceptance criteria

- All affected docs are in end-state language; no "we will" / "should consider" in normative sections.
- Obsolete concepts are removed, not annotated.
- A design delta ledger exists at the canonical path.
- Substrate map (if it exists) is updated.
- The rewrite happens on a `design/<slug>` branch in a worktree.
- A commit captures the rewrite atomically.
- The skill does not invoke `review-spec-cohesion` — handoff is announced; user invokes the review.

## What this skill is *not*

- Not implementation. No code, no tests, no CI changes.
- Not the review. The fresh-eyes review of the rewrite is `review-spec-cohesion`, run separately.
- Not where new substrate concepts get *invented*. The direction was decided in `brainstorm-design`. This skill writes that direction down.
