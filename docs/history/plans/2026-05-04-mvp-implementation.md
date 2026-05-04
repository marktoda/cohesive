# Cohesive Implementation Plan

> **Note (preserved historical artifact):** This was the binding plan that drove v0.1 implementation. **It is not authoritative for current state.** The binding architectural map is `/ARCHITECTURE.md`. Path references and structural claims within this document reflect the layout at the time of writing (2026-05-04 morning, before the layout migration); some have since moved. Preserved as the dated record of what was decided.

**Companion to:** `initial_design.md` (spec v0.1, 2026-05-04) — preserved at `docs/history/initial-design.md`
**Status:** Approved 2026-05-04 with simplifications agreed in chat; superseded by `/ARCHITECTURE.md` for current state
**Date:** 2026-05-04

This plan implements the spec with the following deltas. The substrate thesis, naming, four-phase architecture-review structure, hard-rewrite-specs principle, and fresh-eyes spec review all stand. What changes is the surface: fewer skills, fewer agents, no separate templates tier, one script.

---

## 0. Source-of-truth hierarchy

This plan is the binding document for what ships in v0.1. When the plan, the spec, the README, and the on-disk structure disagree, the plan wins.

1. **`docs/implementation_plan.md` (this document)** — binding for v0.1. §1 carries the delta ledger vs the original spec; §2 carries the canonical file structure. Update this doc whenever you add, remove, or modify a skill/agent/reference/template/script.
2. **`docs/initial_design.md`** — the v0.1 design vision. Preserved as a historical artifact and high-level reference. **Not updated for plan deltas.** It describes a more ambitious surface than what ships; readers should always cross-reference §1 below.
3. **`README.md` §"What's in the box"** — derived from §2 of this plan. Must match.
4. **On-disk `skills/`, `agents/`, `references/`, `scripts/`** — the implementation. Must match §2.

`scripts/validate_plugin.sh` enforces the parity between §2 and on-disk reality.

---

## 1. Simplifications applied

| Spec | Plan | Reason |
|---|---|---|
| `pressure-test-design` as separate skill | merged into `brainstorm-design` | Brainstorms without pressure-test are useless; spec router always paired them |
| `architecture-review` + `review-change-cohesion` + `substrate-audit` | one `cohesive-review` skill with `--scope codebase\|diff\|substrate` modes | Same reviewers, only the input target differs |
| 8 reviewer agents | 4 (`substrate-alignment`, `structure`, `library-native`, `agent-readiness`) | spec-drift+invariants+tests collapse to substrate-alignment; locality+domain+complexity collapse to structure |
| 6 artifact-creation skills | 2 (`invariant`, `matrix`) deferred to V1 | Most were "fill out a template"; templates alone suffice |
| Top-level `templates/` tier | `references/templates/` subdirectory | Templates are reference material, not a component type |
| Own `using-worktrees` skill | compose with `superpowers:using-git-worktrees` (de-facto canonical, ships in Anthropic's official marketplace) | Avoids duplicating well-tested logic; calling skills include a 5-line inline fallback if superpowers isn't installed |
| 3 scripts | 1 (`scan_substrate.py`) | git-context is one shell line; `new_artifact.py` is V1-only |
| Bare `/cohesive` alias | dropped (README install instruction only) | One-word convenience not worth a component |
| `context: fork` / `agent: general-purpose` frontmatter | custom agents in `agents/` dispatched via Task tool | Those frontmatter fields aren't real Claude Code; this matches plugin-dev pattern |

Net: **17 skills → 6 (MVP) + 2 (V1)**, **8 agents → 4**, **9 templates → 9 (under references/)**, **3 scripts → 1**, **5 references → 4**.

---

## 2. Final structure

```
cohesive/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── README.md
├── LICENSE
├── .gitignore
├── docs/
│   ├── initial_design.md           # spec
│   ├── implementation_plan.md      # this file
│   └── transcripts/                # MVP test transcripts
├── skills/
│   ├── cohesively/SKILL.md         # router
│   ├── discover-substrate/SKILL.md
│   ├── brainstorm-design/SKILL.md  # includes pressure-test
│   ├── rewrite-specs/SKILL.md      # composes superpowers:using-git-worktrees
│   ├── review-spec-cohesion/SKILL.md
│   └── cohesive-review/SKILL.md    # codebase | diff | substrate modes
├── agents/
│   ├── spec-cohesion-reviewer.md   # for review-spec-cohesion
│   ├── substrate-alignment-reviewer.md
│   ├── structure-reviewer.md
│   ├── library-native-reviewer.md
│   └── agent-readiness-reviewer.md
├── references/
│   ├── substrate-model.md
│   ├── cohesion-rubric.md
│   ├── design-pressure-testing.md
│   ├── locality-over-centralization.md
│   ├── architecture-review-rubric.md
│   └── templates/
│       ├── substrate-map.md
│       ├── behavior-matrix.md
│       ├── invariant.md
│       ├── semantic-linter-spec.md
│       ├── gotcha.md
│       ├── design-delta-ledger.md
│       ├── cohesion-review.md
│       ├── architecture-review-report.md
│       └── implementation-plan.md
└── scripts/
    ├── scan_substrate.py
    └── validate_plugin.sh
```

**MVP totals:** 6 skills + 5 agents + 5 references + 9 templates + 2 scripts. ~29 hand-written files.

---

## 3. Conventions (locked in)

- **Frontmatter style:** plugin-dev third-person with explicit trigger phrases. `description: Use when [trigger]. Triggers on "phrase 1", "phrase 2".`
- **All internal paths:** `${CLAUDE_PLUGIN_ROOT}`. No hardcoded paths.
- **Plugin author:** Mark Toda <mark.toda@uniswap.org>. License MIT. Repo `https://github.com/marktoda/cohesive`.
- **Default artifact dir:** `docs/cohesive/` with detection of existing repo conventions (`docs/design/`, `docs/specs/`, `docs/adr/`, `docs/invariants/`, `docs/gotchas/`) — prefer existing if present.
- **Architecture review report output:** `docs/cohesive/reviews/YYYY-MM-DD-<slug>-architecture-review.md`, also rendered to chat.
- **No SessionStart hook in v0.** Description-based auto-trigger only.
- **Skill-level prereqs are soft:** subskills check for prior skill output and run a quick inline version if missing, instead of hard-gating.
- **Subagent dispatch:** custom agents in `agents/`, called via Task tool. Reviewer prompts live in agent system prompts, not in skill bodies. Pass inputs explicitly so the agent doesn't inherit conversation context.

---

## 4. Per-skill notes

### 4.1 `cohesively` (router)

Decision table reduced to ~4 routes (design / review / artifact-create / passthrough). Body announces the chosen route, then chains. ≤200 lines. One precise pre-canned clarifying question per route, never a vague one.

### 4.2 `discover-substrate`

Walks the spec §9.4 file list via `scan_substrate.py`, separates "found" vs "missing", emits §9.6 report. The single most-reused skill — every other workflow leans on it. Acceptance test: run on cohesive itself.

### 4.3 Worktree handling — composed, not owned

Cohesive does not ship a worktree skill. Skills that need isolation (`rewrite-specs`, future `implement-cohesively`) instruct Claude to invoke `superpowers:using-git-worktrees` with our branch-prefix convention (`design/<slug>`, `impl/<slug>`, `audit/<slug>`).

If superpowers isn't installed, skill body includes a fallback:
```bash
mkdir -p .worktrees && grep -qF .worktrees .gitignore || echo .worktrees/ >> .gitignore
git worktree add .worktrees/cohesive-<slug> -b <prefix>/<slug>
```

### 4.4 `brainstorm-design` (with pressure-test merged)

Two-phase body: (1) propose 2–4 options grounded in discovered substrate, (2) attack each option through the §11.3 question battery. Output is a single combined report — options + breakage analysis + recommendation + required substrate before implementation. The §11.3 questions live as a numbered checklist inside `references/design-pressure-testing.md`; the skill body references it.

### 4.5 `rewrite-specs`

Hard-rewrite to end state. Anti-patterns (§13.4) ship as a Red Flags table at the bottom (superpowers convention). Output is the design delta ledger from `references/templates/design-delta-ledger.md`. Hard prereq: an approved direction. Recommended prereq: a worktree.

### 4.6 `review-spec-cohesion`

Body is short. It dispatches `agents/spec-cohesion-reviewer.md` via Task tool, passing the rewritten spec paths and the substrate-discovery report explicitly. The agent must not read prior conversation context — fresh-eyes is the whole point.

### 4.7 `cohesive-review` (unified)

Three modes selected by argument or inferred from context:

- `codebase`: full architecture-review per spec §15. Four phases (read normative → spec-prior gate → focused subagents → synthesize). Phase 3 dispatches the four reviewer agents in parallel via one message with multiple Task tool calls. Stop condition: ≥3 spec-prior blockers → return spec-prior report only.
- `diff`: read `git diff` (or `gh pr diff <n>`); skip Phase 1 normative read except for files touched by the diff; dispatch `substrate-alignment-reviewer` + `structure-reviewer` only.
- `substrate`: substrate-audit per spec §17 — single-pass scan, fills the §17.3 template, emphasizes *missing* over *found*. No subagent dispatch.

Output (modes `codebase` and `substrate`): written to `docs/cohesive/reviews/YYYY-MM-DD-<slug>.md` by default, also rendered in chat.

---

## 5. The four reviewer agents

| Agent | Replaces (from spec §15.3) | Single sentence |
|---|---|---|
| `substrate-alignment-reviewer` | spec-drift + invariant-enforcement + test-guarantee | "Does the implementation agree with what the docs claim, and is what *should* be invariant actually enforced by tests/types/constraints/CI?" |
| `structure-reviewer` | locality + domain-model + complexity | "Are the seams in the right places, the concepts right-sized, and is anything centralized prematurely or duplicated wastefully?" |
| `library-native-reviewer` | library-native | "Where is the code fighting its frameworks, type system, or external libraries instead of using them natively?" |
| `agent-readiness-reviewer` | agent-readiness | "Could a future agent or new contributor safely change this with bounded context, or does it depend on memory the codebase doesn't hold?" |

All four use the `<example>...<commentary>` description block convention. All four take explicit input paths in the dispatch prompt — they do not read conversation context.

---

## 6. Milestone sequence

### Milestone 1: Skeleton (½ day)

1. `git init`, `plugin.json`, `marketplace.json`, README shell, MIT LICENSE, `.gitignore`.
2. `scripts/validate_plugin.sh` (spec §25.1 checks).
3. `skills/cohesively/SKILL.md` stub: announces routing only, no real subskill calls yet.
4. **Gate:** plugin installs locally; `/cohesive:cohesively foo` triggers and prints "I would route this to ...".

### Milestone 2: Foundation (1 day)

1. `scripts/scan_substrate.py`.
2. `references/substrate-model.md`, `cohesion-rubric.md`.
3. `skills/discover-substrate/SKILL.md` end-to-end.
4. **Gate:** `discover-substrate` produces the §9.6 report on cohesive itself and on one external repo.

### Milestone 3: Design-rewrite flow (2 days)

1. `references/design-pressure-testing.md`, `locality-over-centralization.md`.
2. Templates: `behavior-matrix.md`, `design-delta-ledger.md`, `cohesion-review.md`, `substrate-map.md`.
3. Skills: `brainstorm-design`, `rewrite-specs`, `review-spec-cohesion`.
4. Agent: `spec-cohesion-reviewer.md`.
5. **Gate:** dogfood — design-rewrite cohesive's own spec and pass the fresh-eyes review.

### Milestone 4: Unified review (2 days)

1. `references/architecture-review-rubric.md`.
2. Templates: `architecture-review-report.md`, `invariant.md`, `gotcha.md`, `semantic-linter-spec.md`, `implementation-plan.md`.
3. `skills/cohesive-review/SKILL.md` with all three modes.
4. Reviewer agents: `substrate-alignment`, `structure`, `library-native`, `agent-readiness`.
5. **Gate:** dogfood — `/cohesive:cohesive-review --scope codebase` on cohesive itself produces a coherent report.

### Milestone 5: Wire router + finalize (½ day)

1. Replace router stub with full subskill dispatch.
2. README workflows section + when-to-use vs superpowers per spec §27.
3. Save dogfood transcripts to `docs/transcripts/`.
4. Run `plugin-validator` and `skill-reviewer` end-to-end.
5. **Gate:** spec §26 acceptance criteria all checked.

### V1 (post-MVP)

- Skills: `invariant`, `matrix` (procedural skills earn their slot per §22 and §20.2), `plan-implementation`, `implement-cohesively`, `finish-branch`.
- `scripts/new_artifact.py`.
- Optional bare `/cohesive` install instructions.
- Re-evaluate whether dropped artifact skills (`gotcha`, `locality`, `substrate-map`) should be added back based on dogfooding feedback.

---

## 7. Risks (unchanged from prior plan)

- **Discovery competition with superpowers** when both installed. Description copy must distinguish substrate/architecture work from implementation discipline.
- **Reviewer token cost.** Agents must be instructed to read only paths surfaced by `discover-substrate`, not glob the world.
- **Behavior matrix template is unproven.** Expect to iterate after first real use.
- **Soft prereqs** may produce mediocre output if subskills are routinely invoked without context. Tighten to hard gates if observed.

---

## 8. Definition of done (MVP)

All ten of spec §26, plus:

- `validate_plugin.sh` exits clean
- `plugin-validator` agent: zero critical issues
- `skill-reviewer` agent: each MVP skill rated "good" or better
- README's "when to use Cohesive vs Superpowers" section drafted and verified by a fresh-context agent
- One dogfood design-rewrite transcript and one architecture-review transcript checked into `docs/transcripts/`
