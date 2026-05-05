# Reviewer agent template

The canonical shape for a Cohesive reviewer agent (`agents/<name>.md`). Read this before adding a new reviewer agent or modifying an existing one. The shape is intentionally rigid because reviewer agents run with no inherited conversation context — every fact about how they work has to be readable from the agent file alone.

## Frontmatter

```yaml
---
name: <agent-name>
description: |
  Use this agent <one-sentence trigger>. <One-sentence what-it-does>. Examples:

  <example>
  Context: <when this agent is dispatched>.
  user: <how the dispatching skill invokes the agent>
  assistant: "<the agent's first-line response>"
  <commentary><why this example demonstrates the right trigger></commentary>
  </example>

  <example>
  Context: <a different scenario, often a different scope or input shape>.
  user: <how it's invoked here>
  assistant: "<first-line response>"
  <commentary><what's different about this case></commentary>
  </example>

model: inherit
color: <distinct color: blue / purple / green / orange / pink>
---
```

Rules:

- `description` is a `|` block scalar. Two `<example>...<commentary>` blocks are required.
- `model: inherit` lets the user's session-level model selection flow down.
- `color` is required; pick one not already used by another reviewer agent.
- No `tools:` field unless the agent genuinely needs to scope its tool surface.

## Required body sections (in order)

```md
You are the **<Agent Display Name>** for Cohesive <kind> reviews. You answer one question:

> <The single question the agent answers, as a quote.>

<One-paragraph framing: why this agent exists, what it merges or focuses, why a fresh context is required.>

## Inputs you will receive
(What the dispatching skill passes. Always: claimed-system-shape summary, normative doc paths, scope, substrate discovery report. Plus agent-specific inputs.)

## What you check
(Numbered subsections naming each lens the agent applies. Each subsection is a paragraph or a bulleted list of concrete checks.)

## How to scope your reading
(What the agent reads, what it does NOT read. Always includes "You read **only**:" followed by a list and "You do **not** glob the whole repo.")

## How to structure your output
(A markdown code block showing the agent's canonical output shape. Always uses Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact to add or update.)

## What you must not do
(Bulleted list. MUST include: "Inherit conversation context from the calling skill. Treat your input prompt as the entire context.")

## Tone
(One short paragraph. Always declares: specific, file:line references, no filler.)
```

## The fresh-eyes preamble (convention)

Every reviewer agent's "What you must not do" section includes a bullet that names, in some compatible form, the no-context-inheritance rule. The canonical wording is:

```md
- Inherit conversation context from the calling skill. Treat your input prompt as the entire context.
```

Copying this verbatim is the safest default — divergence in wording produces drift across agent files that the structural fence (the harness's Task-subprocess isolation) doesn't catch.

The structural fence does the heavy lifting: calling Task tool with `subagent_type` creates an isolated subprocess with no inherited conversation. The agent-file bullet is convention reinforcement on top of that fence. See [`docs/substrate/designs/agent-dispatch-protocol.md`](agent-dispatch-protocol.md) for the full property and why both halves matter.

If the agent reads any reference docs as part of its job, list them under "Inputs you will receive" with explicit `${CLAUDE_PLUGIN_ROOT}/...` paths. The agent must not glob.

## Path discipline

All references to skills, references, templates, scripts use `${CLAUDE_PLUGIN_ROOT}/<path>`. Enforced by named invariant `PLUGIN_ROOT_PATHS`.

## Output format conventions

Reviewer-agent findings are consumed by a synthesizing skill (`review-codebase`, `review-diff`, `validate-rewrite`) which renders the user-facing chat output. The agent itself does not render to the user directly. Two rules apply:

1. **Voice imperative.** Every reviewer agent body carries, as the opening prose paragraph of its "How to structure your output" section (above the code block, not inside it), a single-line imperative directing the model to load the voice guide before generating findings:

   ```
   Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.
   ```

   The imperative lives in body prose — outside any fenced code block — so it triggers a `Read` tool call at finding-generation time without leaking into user-facing output. The "How to structure your output" code block immediately below stays a pure render template (six-field finding shape only); it carries **no instructions** and **no citation literal**. Instructions placed inside render templates leak verbatim into user-facing output (the failure mode `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` documents). Reviewer findings flow through a synthesizing skill that renders to chat, so voice rules apply transitively; the imperative pulls the voice guide into context at the moment the agent generates findings the synthesizer will later render. Reviewer agents do not render verdicts — verdicts are the synthesizing skill's job — so `VERDICT_BEFORE_EVIDENCE` does not apply directly to agent findings; it applies to the skill's render of those findings.

   The imperative's body-prose placement is the asymmetry with skills: skills carry the imperative in a top-level `## Voice` section between `## What this skill produces` and `## Hard constraints`; reviewer agents (which are system prompts, not SKILL.md files) carry it inside "How to structure your output" because that is the agent's render-shaping section and the closest analog. The `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` matrix tracks per-agent compliance via the "Voice imperative in body" and "Citation absent from output template" columns.

   `validate_plugin.sh` Check 13c greps each `agents/*-reviewer.md` body (outside fenced code blocks) for the imperative literal; Check 13d greps inside the agent's first code block to confirm the citation literal does **not** appear there.

2. **Canonical six-field finding shape.** Every finding uses these six fields, in this order:

```md
### <Finding title>

**Severity:** Blocker / High / Medium / Low
**Category:** <category specific to this agent's lens>

**Why it matters:** <one or two sentences — concrete consequence, not "could lead to bugs">

**Evidence:** <file:line references; quoted snippets when illustrative>

**Recommended fix:** <specific next step>

**Substrate artifact to add or update:** Spec / behavior matrix / invariant / gotcha / semantic linter / test / type boundary
```

Findings are ranked by leverage × severity, not by file location. Cap finding nesting at `###`. The six-field shape is tracked across all five reviewer agents in the [reviewer-output-shape behavior matrix](../matrices/reviewer-output-shape.md); drift in any agent file is a regression against that matrix.

## Severity rules

- **Blocker** — would produce a defect or already has; substrate must be repaired before further work.
- **High** — high-leverage substrate gap; not yet a defect, but a predictable source of future defects.
- **Medium** — substrate improvement worth making in the next pass.
- **Low** — taste-level observation; useful context but not actionable on its own.

Don't mark everything blocking. Per `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md`, if everything is blocking the prioritization is failing.

## Token discipline

Every reviewer agent body declares a token-discipline note ("Output ~500 lines max. Read only paths above.") near the bottom or inside "How to structure your output." Reviewers can blow up token budgets quickly; the constraint is part of the contract.

## Section-order deviations

The five existing reviewer agents have minor section-order drift (some put "How to scope" before "How to structure," some after). New agents follow the order above. *Future cleanup, non-normative:* existing agents will be brought into line when their wording stabilizes.

## When adding a new reviewer agent

1. Read `${CLAUDE_PLUGIN_ROOT}/agents/structure-reviewer.md` — it's the closest reference shape (5 axes; full template).
2. Copy the section order from this template. Do not invent new section names.
3. Pick a `color:` not in use by another reviewer.
4. Verify the dispatching skill body (most often `${CLAUDE_PLUGIN_ROOT}/skills/review-codebase/SKILL.md` or `${CLAUDE_PLUGIN_ROOT}/skills/review-diff/SKILL.md`) includes a Task tool dispatch that:
   - Passes the claimed-system-shape summary
   - Passes the list of normative doc paths
   - Passes the scope
   - States "The reviewer reads only paths passed to it, not the conversation."
5. Update `/ARCHITECTURE.md` agent count and `README.md` §"What's in the box" in the same pass.
6. Run `bash scripts/validate_plugin.sh`.

## Anti-patterns

| Anti-pattern | Why it's wrong | Fix |
|---|---|---|
| Missing the fresh-eyes preamble bullet | Drift across agent files; loosens convention reinforcement | Copy the bullet verbatim |
| Agent body assumes prior conversation context | Reviewer runs in a fresh subprocess | Treat the dispatch prompt as the whole context |
| Globbing the repo "to find relevant files" | Token discipline / scope discipline | Read only paths in "Inputs" |
| Output without "Substrate artifact to add or update" lines | Findings without targets aren't actionable | Every finding maps to an artifact |
| Marking every finding "Blocker" | Prioritization signal lost | At most ~10–20% of findings should be Blocker |
| First-person framing ("I'll review...") | Convention is third-person agent description | "You are the X reviewer..." in agent body, third-person in description frontmatter |
| "How to structure your output" missing the voice imperative in body prose | Voice rules drift transitively through the synthesizing skill — the load doesn't trigger | Add the imperative `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` as the opening prose paragraph of "How to structure your output," outside any fenced code block |
| Voice citation literal placed inside the "How to structure your output" code block | Instructions in render templates leak verbatim into the synthesized chat output; users see `> Voice and density: ...` rendered | Remove the citation from the code block; the imperative belongs in body prose above the template, not inside it |
| Finding render with `####` or `#####` headers | Header soup propagates to the synthesized chat output | Cap finding nesting at `###`; use bullets for sub-structure |
| Narrative paragraphs instead of the six-field finding shape | Synthesizer can't merge non-canonical findings | Use the six-field block verbatim per [reviewer-output-shape matrix](../matrices/reviewer-output-shape.md) |
