# Cohesive — repo guide

> A Claude Code skill pack for substrate-first agentic engineering. Helps a codebase remember.

This file is auto-loaded for sessions in this repo. It captures the philosophy and the contributor ground rules. For runtime details, read the skills, agents, and references on disk.

## What this repo is

Cohesive is a Claude Code plugin. Three implementation tiers under `${CLAUDE_PLUGIN_ROOT}`:

- **`skills/`** — workflow orchestration. The router (`cohesively`), the session-start orientation skill (`using-cohesive`), the adoption skill (`init`), and the gate / off-chain workflow subskills. User-facing surface.
- **`agents/`** — fresh-context reviewer agents. Dispatched via the Task tool with explicit input paths. They do not inherit conversation context.
- **`references/`** — runtime methodology cited by skills and agents during the workflow: rubrics, the design pressure-test battery, the locality-over-centralization principle, the substrate model, the chat-render voice guide, and fillable templates.

Top-level prose lives at the root: `README.md` is the entry point. This file (`CLAUDE.md`) is the contributor guide.

## The core idea

Code is cheap. Confidence is scarce.

**Substrate is how a codebase remembers** — specs, tests, behavior matrices, named invariants, semantic linters, CI checks, gotchas, architectural seams. A normal linter encodes generic engineering rules. A *semantic* linter encodes institutional knowledge: "every external mutation must produce an audit event," "this dependency may only be imported through wrapper Y," "every environment variable used in code must appear in the env spec."

A convention without enforcement is just a hope. Cohesive's job is to turn judgment into enforcement — to move judgment upstream and encode it into the codebase, so future humans and agents can change the system without needing the original author in the room.

The goal isn't to make the original author unnecessary. The goal is to make their judgment durable.

## Decide → Lock → Build

The user-facing model is three gates, paralleling Superpowers' `brainstorm → plan → execute`:

- **Decide** — recommended direction with main risk + structural mitigation. Many design conversations end here.
- **Lock** — chosen direction pinned into specs in a worktree, then fresh-eyes-validated.
- **Build** — locked design becomes code with spec-coverage verified. Single-pass implementation against a delta ledger, with end-of-run dual reviewer dispatch.

Stop at any gate.

## Composition over reinvention

Cohesive composes with [Superpowers](https://github.com/obra/superpowers) rather than reinventing implementation discipline. Cohesive owns substrate-shaped framing (thin intent paragraph, delta-size budget gate, end-of-run dual reviewer dispatch with AND-shape verdict synthesis). Superpowers owns per-pass plan writing and TDD execution. The seam between the two is documented and intentional.

## Fresh-eyes review

Reviewer agents run in isolated subprocesses with no conversation-context inheritance. The dispatching skill passes inputs as explicit file paths; the agent system prompt forbids reading prior conversation. This is the load-bearing safety property of every Cohesive review — without it, reviews degrade to performance. The Task-tool isolation provides the structural fence; the agent-file preamble is convention reinforcement.

## Don't dogfood Cohesive on Cohesive

We tried it. We're not doing it anymore.

The Cohesive workflow stores its substrate (named invariants, behavior matrices, gotchas, delta ledgers, design docs) as markdown files. The Cohesive *product itself* is also markdown — SKILL.md, agent definitions, references. When you try to dogfood the workflow on the codebase that ships the workflow, the two markdown trees become indistinguishable in conversation. Every time someone asked "is this a contributor-facing rule or a runtime-facing rule?", the answer required holding both trees in mind. Confusion compounded faster than substrate accrued.

So: don't recreate `docs/substrate/`, `docs/history/`, or any Cohesive-shaped substrate tree inside *this* repo. If you want substrate-style memory about the plugin itself, encode it as:

- prose paragraphs in `README.md` or in this `CLAUDE.md`,
- mechanical checks in `scripts/validate_plugin.sh`,
- conventions inlined into the SKILL.md or agent definition they govern,
- or a new section in this file.

Cohesive is best applied to systems where the substrate (specs, invariants, gotchas) is **different in kind** from the implementation (code, configs, schemas). When those are the same kind of artifact, the framing collapses.

## Contributor ground rules

- **Internal paths use `${CLAUDE_PLUGIN_ROOT}/...`** Never hardcoded absolute paths. (Named invariant: `PLUGIN_ROOT_PATHS`.)
- **Verdict-led skills open with `**Verdict:**`** within the first three non-blank lines of their Output format block. Chat outputs that bury the verdict are the most-regressed UX scar. (Named invariant: `VERDICT_BEFORE_EVIDENCE`.)
- **Skills compose; they don't reinvent.** If a Superpowers skill already does the thing well (worktrees, plan writing, TDD), invoke it. Don't reimplement.
- **Reviewer agents preserve fresh-eyes review.** Every agent file says, in some form, that the agent does not inherit conversation context.
- **`scripts/validate_plugin.sh`** runs locally and in CI. It enforces structural shape (frontmatter, expected skill set, vocabulary tokens, path discipline). A red check blocks merge.

