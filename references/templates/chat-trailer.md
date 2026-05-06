# Chat trailer template

The single centralized chat-render template every Cohesive verdict-led skill produces. The shell is shared; the body block varies per skill (per the §"Variants" table below). This template literal contains zero substrate-vocabulary tokens — the model reproduces what's here at render time, and substrate concerns appear only in the persisted-file template each skill writes alongside.

This is normative for chat-rendered output across `review-codebase`, `review-diff`, `validate-rewrite`, `audit-substrate`, `brainstorm-design`, and `implement-cohesively`. Each of those SKILL.md `## Output format` sections cites this template by reference and specifies only its body block — they do not duplicate the shell.

## The shell

```md
# <Output title>

**Verdict:** <user-facing label from `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md`>

**Thesis:** <one or two sentences — what was found and what it means, in decision-shape>

<body block — per §"Variants">

### Persisted record

`<persisted-file path>`  *(omit this section when the skill renders chat-only)*

### Next

<decision-shaped sentence naming the architectural action>. *(`cohesive:<skill>` or `superpowers:<skill>`.)* **<Payload-kind>:** <concrete inputs — files, scope, design question, or branch>.
```

## Slot rules

- **`**Verdict:**`** — user-facing label per the verdict-vocabulary table for this skill. Lead within the first three non-blank lines after the `#` title (the `VERDICT_BEFORE_EVIDENCE` invariant). Skills without a verdict (`brainstorm-design`, `discover-substrate`) omit this slot per §"Variants".
- **`**Thesis:**`** — one or two sentences. Decision-shape: name what was found and what to do. For `review-diff` this slot is labeled `**Main concern:**` instead, by §"Variants". Skills with a structural body block where the thesis is implicit (`implement-cohesively`'s Phases table, `brainstorm-design`'s Recommendation) substitute or omit per §"Variants".
- **body block** — per-skill content. Show-shape per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 2b: every claim carries title + concrete evidence + the change that closes it (or the skill-specific analog per §"Variants"). Cap header depth at `###` (rule 3).
- **`### Persisted record`** — one-line citation to the persisted file. Skills that render chat-only (`review-diff` by default) omit this section.
- **`### Next`** — exactly one decision-shaped recommendation per verdict branch (rule 5; payload requirement per rule 5a). The decision-shaped sentence leads; the skill citation appears parenthetically; the payload follows. Skill name is `cohesive:<x>` or `superpowers:<y>` rendered as inline code; methodology framing ("Recommended next Cohesive skill", "the Cohesive workflow") does not appear in chat — see §"Why methodology naming is removed from chat" below.

## Vocabulary the chat trailer never uses

The shell above carries decision-shape vocabulary only. Substrate-shape tokens — present in the persisted-file templates each skill writes alongside — do not appear in the chat trailer:

- `**Required substrate before implementation:**`
- `**Substrate artifact to add or update:**`
- `**Suggested substrate:**` (as a Findings-table column header)
- `**Recommended next Cohesive skill:**` (use `### Next` instead)
- `Cohesive workflow`, `Cohesive route`, `substrate-shaped work` (as user-facing labels)
- Internal verdict labels uncited from `verdict-vocabulary.md` (e.g., bare "Substrate gaps", "Cohesive but under-enforced")

These tokens belong in skill body prose (which the model reads at dispatch time, but the user does not see in chat) and in persisted-file templates (which the agent reads when it carries audit-trail work). The chat trailer is the user's surface; it does not carry the methodology's vocabulary.

## Variants

Each verdict-led skill specifies a body-block variant below. Per-skill SKILL.md `## Output format` sections cite this row rather than duplicate the body-block shape.

| Skill | Verdict slot? | Thesis label | Body-block shape |
|---|---|---|---|
| `review-codebase` | yes (5-vocabulary) | `**Thesis:**` | `## Top findings` — three show-shape findings, each: `### N. <title>` + `**Evidence:**` `<path>:<line>` + excerpt + `**Change:**` <specific edit> |
| `review-diff` | yes (5-vocabulary) | `**Main concern:**` (one sentence) | `## Findings` — table with columns `Severity \| Area \| Evidence (file:line + excerpt) \| Change \| Doc to update`, ordered by leverage |
| `validate-rewrite` | yes (3-vocabulary) | (omitted; review structure carries the thesis) | Full review per `${CLAUDE_PLUGIN_ROOT}/references/templates/cohesion-review.md` (Executive judgment / Delta at a glance / Blocking issues / etc.); after the review body, the `### Next` footer renders the **Disposition** phrase + (Approved-only) **Implementation route** matrix per `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Disposition rule for validation-review findings" |
| `audit-substrate` | yes (3-vocabulary) | `**Headline:**` (one or two sentences) | `## Top fixes` — three show-shape fixes, each: `### N. <artifact-to-add title>` + `**Evidence the gap exists:**` `<path>:<line>` + excerpt + `**What the artifact would say:**` <2-3 sentence sketch> + `**Where it lives:**` `<path>` |
| `brainstorm-design` | no | (omitted) | `## Direction` — `**Direction:**` <chosen option name> + `**Main risk:**` <one sentence> + `**Structural mitigation:**` <test/type/constraint/linter — not "we'll be careful">. Optionally a `## Pressure test summary` table above when ≥3 options were considered |
| `implement-cohesively` | yes (4-vocabulary) | `**Thesis:**` | `## Phases` table (`# \| Intent \| Delta entries \| Plan \| Cross-review`) + `## Delta coverage` (yes/no + uncovered list) + `## Final substrate review` (verdict + path) + `## Branch state` (branch + commits + plans count) |

`discover-substrate` is not in this table because it does not produce a chat trailer — it produces a discovery report rendered as one scannable page (per its SKILL.md §"Output format"). Its missing-memory entries follow the same show-shape principle (title + path:line + artifact-shape) but the report is not a verdict-led trailer.

## How `### Next` carries payload

Per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rule 5a, the `### Next` slot names the architectural action *and* the concrete inputs the next skill operates on. Three payload kinds, by next-skill type:

- **Files (for `cohesive:rewrite-specs`)** — `**Files to edit:**` enumerates the docs/matrices/invariants and the specific change in each. Plus a slug.
- **Scope (for `cohesive:review-codebase` / `cohesive:review-diff` / `cohesive:audit-substrate` / `superpowers:writing-plans` / `superpowers:executing-plans`)** — `**Scope:**` names the subsystem, file set, change surface, branch, or repo region.
- **Design question (for `cohesive:brainstorm-design`)** — `**Design question:**` names the specific architectural question to revisit.

Per-verdict-branch recommendations: when a skill has multiple verdict branches (e.g., `validate-rewrite` Approved / Issues Found / Design Incoherent; `review-codebase` 5 verdicts), provide one `### Next` recommendation per branch, each carrying its own payload. The payload kind matches the next skill's input contract.

## How verdict translation works

The `**Verdict:**` slot renders the user-facing label per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md`. The internal label (the row the skill's logic returns) maps to a user-facing label via that table; the chat trailer never renders the internal label directly.

When a future contributor adds a new verdict to a skill, they add a row to `verdict-vocabulary.md` in the same pass that updates the skill's verdict vocabulary in `cohesion-rubric.md` and `handoffs.md` edge contracts. The three surfaces drift together; failing to update the translation table is a substrate violation that the deferred Check 13k will eventually grep.

## Why methodology naming is removed from chat

The chat trailer is the user's surface. The user invoked a skill; the user knows they are inside a methodology; saying so on every render is ceremony. The strings `Cohesive workflow`, `Cohesive route`, `Recommended next Cohesive skill`, `substrate-shaped work` (as user-facing labels) are content-removal targets — they appear in skill body prose, AGENTS.md, README, persisted-file templates, and contributor docs (where the methodology-name is a reading aid), but not in chat-render templates.

The structural argument: the user does not need the methodology's name to act on its output. They need the architectural decision and the next concrete step. The skill citation in `### Next` (`cohesive:rewrite-specs` rendered as inline code) is the only methodology surface the user sees in chat; it appears parenthetically after the decision-shaped sentence, not as the lead.

This rule is the audience seam. The contract that pins it is `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` rules 1, 2 (with 2a/2b/2c), 3, 4, 5 (with 5a) — chat-render rules this template implements
- `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` — translation source consumed by the `**Verdict:**` slot
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md` — the convention this template structurally implements
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Output format conventions" — how SKILL.md bodies cite this template
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/reviewer-output-shape.md` §"Synthesizing-skill chat render shape" — per-skill compliance tracking against this template
