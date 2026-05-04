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

## The fresh-eyes preamble (load-bearing — verbatim)

Every reviewer agent's "What you must not do" section must include this exact bullet:

```md
- Inherit conversation context from the calling skill. Treat your input prompt as the entire context.
```

This is the textual half of named invariant `FRESH_EYES_DISPATCH`. The runtime half is enforced at the dispatch site in the calling skill body. Both halves must be present for the invariant to hold.

If the agent reads any reference docs as part of its job, list them under "Inputs you will receive" with explicit `${CLAUDE_PLUGIN_ROOT}/...` paths. The agent must not glob.

## Path discipline

All references to skills, references, templates, scripts use `${CLAUDE_PLUGIN_ROOT}/<path>`. Enforced by named invariant `PLUGIN_ROOT_PATHS`.

## Output format conventions

The agent's output uses this finding shape:

```md
### <Finding title>

**Severity:** Blocker / High / Medium / Low
**Category:** <category specific to this agent's lens>

**Why it matters:**
<concrete consequence — not "could lead to bugs">

**Evidence:**
<file:line references; quoted snippets when illustrative>

**Recommended fix:**
<specific next step>

**Substrate artifact to add or update:**
Spec / behavior matrix / invariant / gotcha / semantic linter / test / type boundary
```

Findings are ranked by leverage × severity, not by file location.

## Severity rules

- **Blocker** — would produce a defect or already has; substrate must be repaired before further work.
- **High** — high-leverage substrate gap; not yet a defect, but a predictable source of future defects.
- **Medium** — substrate improvement worth making in the next pass.
- **Low** — taste-level observation; useful context but not actionable on its own.

Don't mark everything blocking. Per `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md`, if everything is blocking the prioritization is failing.

## Token discipline

Every reviewer agent body should declare a token-discipline note ("Output ~500 lines max. Read only paths above.") near the bottom or inside "How to structure your output." Reviewers can blow up token budgets quickly; the constraint is part of the contract.

## Section-order deviations

The five existing reviewer agents have minor section-order drift (some put "How to scope" before "How to structure," some after). New agents should follow the order above. Existing agents will be brought into line in a future cleanup pass.

## When adding a new reviewer agent

1. Read `${CLAUDE_PLUGIN_ROOT}/agents/structure-reviewer.md` — it's the closest reference shape (5 axes; full template).
2. Copy the section order from this template. Do not invent new section names.
3. Pick a `color:` not in use by another reviewer.
4. Verify the dispatching skill body (most often `${CLAUDE_PLUGIN_ROOT}/skills/cohesive-review/SKILL.md`) includes a Task tool dispatch that:
   - Passes the claimed-system-shape summary
   - Passes the list of normative doc paths
   - Passes the scope
   - States "The reviewer reads only paths passed to it, not the conversation."
5. Add the agent to plan §2 and §5 in the same pass.
6. Run `bash scripts/validate_plugin.sh`.

## Anti-patterns

| Anti-pattern | Why it's wrong | Fix |
|---|---|---|
| Missing the fresh-eyes preamble bullet | Breaks `FRESH_EYES_DISPATCH` | Copy the bullet verbatim |
| Agent body assumes prior conversation context | Reviewer runs in a fresh subprocess | Treat the dispatch prompt as the whole context |
| Globbing the repo "to find relevant files" | Token discipline / scope discipline | Read only paths in "Inputs" |
| Output without "Substrate artifact to add or update" lines | Findings without targets aren't actionable | Every finding maps to an artifact |
| Marking every finding "Blocker" | Prioritization signal lost | At most ~10–20% of findings should be Blocker |
| First-person framing ("I'll review...") | Convention is third-person agent description | "You are the X reviewer..." in agent body, third-person in description frontmatter |
