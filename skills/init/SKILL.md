---
name: init
description: Use when starting Cohesive on a codebase that has no Cohesive substrate yet — implicit substrate exists in comments, test names, branchy code, and conventions, but no named invariants, behavior matrices, or gotcha docs. Init scans for proto-substrate signals, translates each to its Cohesive type with a side-by-side definition (Rosetta Stone), and produces a draft substrate the user reviews and selectively keeps. Triggers on "initialize cohesive", "set up substrate", "bootstrap cohesive", "we're new to cohesive", "first time using cohesive on this codebase", "init". Runs once at adoption time; refuses if substrate already exists (use `audit-substrate` instead). Designed to teach the substrate vocabulary by translating the user's own code.
---

# Init

## What this skill produces

A **draft substrate directory** at `docs/substrate/init-draft/` containing proposed artifacts (named invariants, behavior matrices, gotchas, plus skeletal CLAUDE.md and ARCHITECTURE.md if neither exists). Each draft artifact carries a side-by-side translation: file:line evidence + Cohesive's name for the substrate type + a 1-paragraph user-facing definition + the proposed artifact itself. The user reviews each draft, deletes drafts that don't apply, edits drafts that do, and `git mv`s the kept ones to canonical locations.

This skill is the **Rosetta Stone** for non-Cohesive-native engineers: it teaches the substrate vocabulary by translating the user's own code into it. The pedagogical move lives in the *draft files the user opens*, not in the chat trailer — chat shows an index of drafts produced + 3 example type labels with one-line summaries, while each draft file carries the full translation paragraph from `${CLAUDE_PLUGIN_ROOT}/references/substrate-vocabulary.md`. The surface seam is deliberate: chat respects the density budget, the file the user reviews carries the substantive translation. After init runs once, the codebase has substrate AND the user has working knowledge of what the categories mean.

## Voice

Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output. The voice guide is the load-bearing source for verdict-leads, header-depth cap, density budgets, and forbidden phrasings; the imperative above is what triggers the model to load it via a Read tool call. Do not reproduce the imperative or any citation to the voice guide inside the Output format render template — instructions placed inside render templates leak verbatim into user-facing output (the failure mode `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` documents).

## Hard constraints

1. **Refuse when *substrate* already exists.** Substrate-shaped paths block init; agent-handoff paths (CLAUDE.md / AGENTS.md) do not. Init refuses if any of `docs/substrate/`, `docs/adr/`, `docs/design/`, or `docs/decisions/` exists with content — halt with a directive error per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Path prereqs use directive errors, not the canonical question":

   ```
   This codebase already has Cohesive-shaped substrate (found: <path>). Init is for codebases starting from zero.
   For codebases with existing substrate, use cohesive:audit-substrate to find what's missing,
   or cohesive:review-codebase for full architecture review.
   ```

   `CLAUDE.md` and `AGENTS.md` are agent-handoff files present in most mature codebases — they signal "an agent has worked here," not "Cohesive substrate exists." `docs/specs/` similarly is a generic spec directory that may exist independent of Cohesive adoption (e.g., a codebase that already maintained behavioral specs before adopting Cohesive). All three are detect-and-warn, not refuse: init proceeds, surfaces a warning line in the chat trailer ("Detected existing CLAUDE.md / AGENTS.md / docs/specs/; init will not overwrite or propose overlapping drafts."), and step 4's skeletal-CLAUDE.md generation continues to skip when one exists. Step 2's signal scan does not propose drafts that overlap with existing `docs/specs/` content.

   Do not invent a way to merge with existing substrate; do not propose drafts that overlap with what's already there. The first-time use-case is the entire scope of the refusal — but the refusal trigger is "Cohesive-shaped substrate exists" (the four substrate-shaped paths above), not "any spec or agent file exists."

2. **Never auto-commit.** Init produces a draft directory the user explicitly reviews and moves. The skill does not `git add` or `git commit`; it writes the draft files and stops. Auto-commit would let confidently-wrong proposals enter the canonical substrate without review.

3. **Translate every proposed artifact via `${CLAUDE_PLUGIN_ROOT}/references/substrate-vocabulary.md`.** Each draft carries the substrate type's user-facing definition inline so the user learns what the category means while reviewing whether the proposal fits. Bare draft files without the translation defeat init's pedagogical purpose.

4. **Bound the proposal count.** Cap at ≤5 drafts per substrate type and ≤20 drafts total in v0.1. Init is for the first substrate, not the complete substrate; users should reach `audit-substrate` for deeper inventory after init's drafts are accepted.

5. **A `--brief` flag suppresses inline translations.** Senior engineers who already know the vocabulary can pass `--brief` to skip the translation paragraphs. Default is verbose (pedagogical); --brief is the opt-out, not the default.

## Process

### 0. Parse arguments and check substrate state

**Parse `--brief`.** If the dispatch prompt or user invocation includes the literal token `--brief`, set `verbose=false`; default `verbose=true`. The flag controls whether per-draft files render the §"What this is" translation paragraph (verbose default per Hard constraint #5).

**Refuse if substrate exists; warn-and-continue on agent-handoff files.**

Check for substrate-shaped paths (any of `docs/substrate/`, `docs/adr/`, `docs/design/`, `docs/decisions/` containing files). If any are present, halt with the directive error from Hard constraint #1. Init does not run incrementally on existing substrate.

Separately, check for agent-handoff or spec paths (`CLAUDE.md` / `AGENTS.md` / `docs/specs/`). If any are present, do not refuse — proceed to step 1, but capture their existence so the chat trailer renders a warning line ("Detected existing CLAUDE.md / AGENTS.md / docs/specs/; init will not overwrite or propose overlapping drafts.") and step 4's skeletal generation skips them. Step 2's signal scan also avoids proposing drafts that would overlap with existing `docs/specs/` content (per Hard constraint #1's "do not propose drafts that overlap with what's already there").

### 1. Resolve the draft directory

Apply the four-rule resolution from `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md` §"Artifact directory resolution" with artifact category `init-draft/`:

1. If `docs/` exists, write to `docs/substrate/init-draft/`.
2. Else default to `docs/substrate/init-draft/` (creating `docs/`).

Announce the resolved path in chat before scanning.

### 2. Scan for proto-substrate signals

Walk the repo (skipping `.git`, `node_modules`, `.venv`, `.worktrees`, `dist`, `build`, vendor dirs). For each file, scan for the patterns the substrate-vocabulary table names as signals:

- **Proto-invariants:** comments containing `MUST`, `NEVER`, `INVARIANT`, `WARNING`, `DO NOT` (case-sensitive — these tend to be deliberate flags). Capture file:line + the comment + the next non-comment line of code (so the artifact has context).
- **Proto-gotchas:** comments containing `FIXME`, `HACK`, `WORKAROUND`, `// because`, `# because`, or referencing bug IDs (`bug #`, `issue #`, `incident`). Test names matching `*regression*`, `*bug_*`, `*incident*`, `*reproduces*`. Code paths with comments substantially longer than the code (≥3× ratio).
- **Proto-matrices:** switch statements / chains of `if/elif` or `match` over an enum or string literal with ≥4 branches. Feature-flag dispatches with multiple flag combinations. Functions whose docstring lists "cases" or numbered conditions.
- **Proto-conventions:** existing `scripts/check_*.sh` / `scripts/validate_*.sh` files (these *are* semantic linters or candidates). Pre-commit hooks beyond standard formatters. CI workflow steps that grep source code.

Use `${CLAUDE_PLUGIN_ROOT}/scripts/scan_substrate.py` for the file-walk + categorization base; the proto-signal patterns above are init's extension. Cap reads at 200 files for v0.1; if the codebase is larger, scan a representative subset (prefer src/, lib/, app/, core/ over tests/).

Bound proposals per Hard constraint #4: ≤5 per substrate type, ≤20 total. Rank by signal strength (a comment with `MUST` next to a non-trivial code path beats a comment with `MUST` in test scaffolding).

### 3. Render the draft directory

For each ranked proposal, write a draft file at `docs/substrate/init-draft/<category>/<slug>.md` using this shape (verbose default; `--brief` skips the §"What this is" block):

```md
# Draft: <substrate-type> — <slug>

**Status:** Draft — review and either edit + `git mv` to canonical location, or delete.

## What this is  *(omit on --brief)*

<the substrate type's user-facing translation paragraph from `${CLAUDE_PLUGIN_ROOT}/references/substrate-vocabulary.md`>

**What this earns:** <the corresponding column from the vocabulary table; for the convention substrate type the discriminator is "over a named invariant" not "over a rule" — see `${CLAUDE_PLUGIN_ROOT}/references/substrate-vocabulary.md` §"How to read this table">

## Evidence the codebase already implies this

`<path>:<line>` — `<excerpt>`

<plus 1-3 lines of surrounding code or related signals if helpful>

## Proposed artifact

<a draft of the artifact in canonical shape; for invariants use the template at references/templates/invariant.md; for gotchas use gotcha.md; etc.>

## Where this lives if you keep it

`<canonical path — e.g., docs/substrate/invariants/<INVARIANT_NAME>.md>`

## Decision

- [ ] Keep — `git mv` to the canonical path, edit as needed.
- [ ] Edit — refine the artifact before keeping.
- [ ] Reject — delete this file. Common reasons: the comment was a one-off note, not a load-bearing rule; the pattern is not project-specific; the rule is already enforced by tests/types.

## What to do next

If this codebase has many proto-signals init didn't catch (and it likely does), run `cohesive:audit-substrate` after the kept drafts are merged to canonical locations.
```

### 4. Generate the skeletal CLAUDE.md and ARCHITECTURE.md  *(if neither exists)*

Init produces a CLAUDE.md skeleton at the repo root only if neither CLAUDE.md nor AGENTS.md exists today. The skeleton contains:

- A 1-paragraph project description (extracted from package.json/pyproject.toml/Cargo.toml description field if present, or left as a placeholder).
- A `## Substrate` section listing the kept-drafts categories that survive review (left as a `<!-- populated after init drafts are accepted -->` placeholder).
- A `## Local commands` section listing detected scripts under `scripts/` / `bin/` / `Makefile` targets.
- A `## Conventions` section with a `<!-- populated after init drafts are accepted -->` placeholder.

Same shape for ARCHITECTURE.md if neither it nor `architecture.md` exists.

Do not write either file if a substantive equivalent already exists; only zero-substrate codebases get the skeleton.

### 5. Render the chat trailer

Render the centralized chat trailer per `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md`. Init has no verdict (utility skill, parallel to `discover-substrate`); the trailer leads with a count of drafts produced + the draft directory path + a "what to do next" pointer.

### 6. Hand off to the user

Init does not invoke another skill. The user reviews drafts, edits or deletes each, `git mv`s kept drafts to canonical locations, then commits. The recommended next Cohesive skill is `cohesive:audit-substrate` for the deeper second-pass inventory.

## Output format

The skill renders the centralized chat trailer per `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` and persists the draft directory to `docs/substrate/init-draft/`. The chat render is the decision-rendering of the scan per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2a (with sub-rules 2b / 2c) and the audience seam in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.

**No verdict.** Like `discover-substrate`, init is a utility skill that produces a draft, not a judgment. The chat trailer renders no `**Verdict:**` slot per the §"Variants" `init` row of the centralized template.

**Body block specification.** A `## Drafts produced` section with one line per substrate type counted, followed by a `## Top translations` section showing 3 example translations side-by-side (so the user sees the Rosetta Stone immediately in chat without opening files), followed by a `## What to do next` pointer.

**Sample chat-trailer render:**

```md
# Cohesive Init — <repo-name>

**Headline:** Found <N> proto-substrate signals across <M> categories. Drafts at `docs/substrate/init-draft/`.

## Drafts produced

- **Signals scanned:** <N total proto-substrate signals across the repo>
- **Drafts surfaced:** <M> *(capped at 20; for the rest, run `cohesive:audit-substrate` after the kept drafts are committed)*
- Named invariants: <count>
- Behavior matrices: <count>
- Gotchas: <count>
- Semantic-linter candidates: <count>
- Skeletal CLAUDE.md: yes / no / *(skipped — already exists)*
- Skeletal ARCHITECTURE.md: yes / no / *(skipped — already exists)*

<!-- Render conditional: when M < N, the "for the rest, run audit-substrate" parenthetical anchors the user's expectation that init is bounded. When M == N (rare; small codebase), drop the parenthetical. -->

## Detected existing files  *(rendered iff CLAUDE.md / AGENTS.md / docs/specs/ exist)*

- `CLAUDE.md` exists — init will not overwrite. Skeletal CLAUDE.md generation skipped.
- `AGENTS.md` exists — init will not overwrite. Skeletal CLAUDE.md generation skipped (covers the AGENTS.md role for harness).
- `docs/specs/` carries content — init proposed no overlapping drafts.

## Top translations

### 1. <substrate-type> — <slug>

**Evidence:** `<path>:<line>` — `<excerpt>`

**What Cohesive calls this:** <substrate-type>. <1-line user-facing summary from substrate-vocabulary.md>

**Draft at:** `docs/substrate/init-draft/<category>/<slug>.md`

### 2. <substrate-type> — <slug>
...

### 3. <substrate-type> — <slug>
...

## What to do next

1. Open `docs/substrate/init-draft/` and review each draft. Each carries an evidence excerpt, a definition of what Cohesive thinks the type is, and a proposed artifact.
2. For each draft: edit + `git mv` to the canonical path (keep), or delete (reject).
3. After kept drafts are committed, run `cohesive:audit-substrate` for the deeper second-pass inventory — init is bounded; audit is exhaustive.

### Persisted record
`docs/substrate/init-draft/` (draft directory; not a single file)

### Next

Review the drafts and keep what fits. *(`cohesive:audit-substrate` after kept drafts are committed.)* **Scope:** the same repo, post-init, for the second-pass inventory.
```

## Acceptance criteria

- Init refuses to run if substrate already exists (Hard constraint #1).
- Init does not auto-commit; produces draft files and stops (Hard constraint #2).
- Every draft carries a side-by-side translation from `${CLAUDE_PLUGIN_ROOT}/references/substrate-vocabulary.md` (Hard constraint #3) — unless `--brief` is set.
- Proposal count is bounded ≤5 per type and ≤20 total (Hard constraint #4).
- The chat trailer renders an index in show-shape: 3 example drafts each carrying file:line evidence + type label + 1-line user-facing summary + path to the draft file (where the full translation lives). The full translation paragraphs live in the per-draft files, not chat.
- The `### Next` footer points to `cohesive:audit-substrate` for the second-pass inventory.
- Skeletal CLAUDE.md and ARCHITECTURE.md only land when neither already exists.

## Red flags

- Running on a codebase with existing substrate. Init is one-shot at adoption time; it doesn't merge or update.
- Auto-committing the draft directory. The skill writes files; the user commits.
- Producing >20 drafts. If the scan surfaces more, init is doing audit's job poorly. Stop at 20 and recommend audit for the rest.
- Drafts without translations (default mode). Defeats the pedagogical purpose; the user gets artifacts they can't evaluate.
- Drafts that overwrite existing files. The init-draft directory is fresh-output-only.
- Skeletal CLAUDE.md / ARCHITECTURE.md generated when one already exists. Augmenting existing top-level docs is a different skill and a different concern.

## Composition

- **Always preceded by:** nothing. Init is the entry point; no Cohesive prereq.
- **Never invoked by:** the `cohesively` router's chain routes (`design`, `rewrite-only`, `implement`). Init is a one-shot adoption skill, not a workflow step. The router's `init` route dispatches it directly without a chain.
- **Often followed by:** `cohesive:audit-substrate` (the second-pass inventory). After kept drafts are committed and substrate is no longer empty, audit-substrate finds what init missed.
- **Bypass:** users who already know the vocabulary can author substrate by hand without init. Init is the accessibility on-ramp, not a requirement.

## What this skill is *not*

- Not a substrate audit. Init is bounded (≤20 drafts, signal-grep based); audit-substrate is exhaustive and runs against existing substrate to find what's missing.
- Not a replacement for `cohesive:rewrite-specs`. Init proposes a *first* substrate; rewrite-specs locks a *chosen direction* into specs.
- Not a CLAUDE.md generator. The skeletal CLAUDE.md is a side product when none exists, not init's primary output.
- Not idempotent. Re-running init on a codebase that already has init-draft/ should refuse or warn, not regenerate. (V0.1 simply refuses per Hard constraint #1; future versions could support re-runs against incremental scans.)
