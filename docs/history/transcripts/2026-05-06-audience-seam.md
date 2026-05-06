# Audience seam — substrate-shape vs decision-shape worked example

**Date:** 2026-05-06
**Source:** authored side-by-side example for the `audience-seam` rewrite. Both renders authored to compare. A real capture is queued — see §"Captured transcripts (queued)" below.
**Companion:** `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md` and `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md`

This is the load-bearing artifact for the audience seam. The convention says chat output names architectural decisions, tradeoffs, risks, and concrete next moves; substrate-shape concerns (specs, named invariants, behavior matrices, gotchas, semantic linters) appear only in the persisted-file template. This transcript shows the same `validate-rewrite` review rendered substrate-shape (pre-rewrite, leaks methodology vocabulary into chat) versus decision-shape (post-rewrite, methodology stays agent-internal).

Read this when authoring or revising a skill's Output format block — examples teach the seam, prose alone doesn't.

## The scenario

User invokes `cohesive:cohesively` with: *"Validate the spec rewrite at design/audience-seam — make sure the audience separation is internally coherent before I implement."*

Both renders below assume `validate-rewrite` has dispatched `spec-cohesion-reviewer`, the agent has produced its review, and the skill is rendering the result.

The reviewer's verdict (internal): **Approved**. Highest severity present: Low (one inline-fixable finding). The disposition rule maps `(Approved, Low)` to `Close inline (≤2 lines per finding) → merge`.

---

## The substrate-shape render (anti-example — leaks methodology to the user)

> # Rewrite Validation Review — audience-seam
>
> **Verdict:** Approved
>
> ## Executive judgment
>
> The rewrite is internally coherent and aligned with the approved direction. One minor substrate gap remains: the chat-trailer template's §"Variants" table does not yet specify the body-block shape for `discover-substrate`, but discover-substrate is documented as not producing a chat trailer in its SKILL.md, so the gap is informational rather than load-bearing.
>
> ## Delta at a glance
>
> [verbatim quote of the ledger preamble — substrate-shape vocabulary throughout]
>
> ## Substrate gaps
>
> ### S1. Chat-trailer template §"Variants" table missing discover-substrate row
>
> **Severity:** Low
> **Category:** Substrate gap
> **Why it matters:** A future skill author authoring the discover-substrate render shape would not see it in the canonical Variants table.
> **Evidence:** `references/templates/chat-trailer.md` §"Variants" — table has 6 rows, `discover-substrate` is named only in prose.
> **Recommended fix:** Add a row to the Variants table noting that discover-substrate does not produce a chat trailer.
> **Substrate artifact to add or update:** Edit `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` §"Variants".
>
> ## What looked right
>
> - `audience-separation.md` correctly enumerates the five forcing functions
> - The verdict-vocabulary translation is one-direction-only
> - Persisted-file templates remain substrate-shaped
>
> ### Recommended next Cohesive skill
>
> **Disposition:** Close inline (≤2 lines per finding) → merge
>
> **Implementation route** — pick one:
>
> | Option | Skill | When to pick |
> |---|---|---|
> | Implement now with delta-coverage discipline (default) | `cohesive:implement-cohesively` | Substantial rewrites; the rewrite added named invariants, behavior matrices, or cross-cutting conceptual changes. Phase loop with per-phase cross-review against the delta. |
> | Land specs first; implement separately later | merge the `design/<slug>` branch first; later run `cohesive:implement-cohesively` against the merged delta ledger | Spec rewrite is independently valuable for human review before code lands. |
> | Hand off to Superpowers without delta-coverage discipline | `superpowers:writing-plans` | Small rewrites where the delta is mostly cosmetic; user accepts that the implementation may drift from the rewrite. |
> | Schedule for later | (no immediate action) | The rewrite is approved; implementation is not currently in scope. |

**What's wrong with this:**

- The verdict line carries the bare internal label `Approved` — agent-facing dispatch vocabulary. A user not steeped in Cohesive reads it and has to infer what it means in context (does this mean "approved by whom"? "approved against what?").
- The body section is titled `## Substrate gaps` — substrate-shape vocabulary leaking into chat. A user without Cohesive vocabulary reads this and asks: what's a "substrate gap"? Why is this section called that?
- Findings render the canonical six-field shape including `**Substrate artifact to add or update:**` — substrate-shape vocabulary; the user does not need to know what a substrate artifact is to act on the finding (they need to know which file to edit, which is in `**Recommended fix:**`).
- The handoff section is titled `### Recommended next Cohesive skill` — methodology naming. The user is already inside Cohesive; saying so on every render is ceremony.
- The disposition phrase `Close inline (≤2 lines per finding) → merge` is a half-translation: it names the action but uses substrate-shape rule notation (`≤2 lines per finding` is from the cohesion rubric).
- The implementation route matrix names skills with the bare prefix `cohesive:implement-cohesively`, `superpowers:writing-plans` — fine, but the "When to pick" column references "named invariants, behavior matrices, cross-cutting conceptual changes" — substrate-shape vocabulary again.

---

## The decision-shape render (canonical, post-audience-seam)

> # Rewrite Validation Review — audience-seam
>
> **Verdict:** Approved — ready to implement
>
> ## Executive judgment
>
> The rewrite is internally coherent and aligned with the approved direction. One minor inline fix remains: the central template's variants table doesn't list `discover-substrate` (the skill that doesn't produce a chat trailer) — close inline before merging.
>
> ## Delta at a glance
>
> [verbatim quote of the ledger preamble — agent-facing substrate-shape stays in the persisted file's body; the chat-trailer's quote is preserved verbatim per the contract]
>
> ## Findings
>
> ### F1. Variants table omits the skill that doesn't produce a chat trailer
>
> **Severity:** Low
> **Category:** Doc completeness
> **Why it matters:** A skill author looking up the variants table won't see `discover-substrate` listed (it's named only in prose), so they may not realize it's a deliberate omission.
> **Evidence:** `references/templates/chat-trailer.md` §"Variants" — table has 6 rows; `discover-substrate` is named only in prose.
> **Recommended fix:** Add a row noting "discover-substrate does not produce a chat trailer" to the Variants table.
> **Doc to update:** `references/templates/chat-trailer.md`
>
> ## What looked right
>
> - The audience seam has five forcing functions named, each independently testable
> - Verdict translation flows one direction only (agent → user, never reverse)
> - The persisted-file templates carry the same substrate-shape vocabulary they did pre-rewrite — the agent's tool stays the agent's tool
>
> ### Next
>
> **Disposition:** Close inline (≤2 lines per finding) → merge.
>
> **Implementation route** — pick one:
>
> | Option | Skill | When to pick |
> |---|---|---|
> | Implement now with full discipline (default) | `cohesive:implement-cohesively` | Substantial rewrites — the design added new docs, structural conventions, or cross-cutting changes. Phase loop with per-phase cross-review. |
> | Land docs first; implement separately later | merge the `design/<slug>` branch first; later run `cohesive:implement-cohesively` against the merged ledger | The doc rewrite is independently valuable for human review before code lands. |
> | Hand off to Superpowers without delta-coverage discipline | `superpowers:writing-plans` | Small rewrites where the doc delta is mostly cosmetic; user accepts that the implementation may drift from the rewrite. |
> | Schedule for later | (no immediate action) | The rewrite is approved; implementation is not currently in scope. |

**Why this works:**

- The verdict line carries the internal token (`Approved`) plus a decision-shape clarifier (`— ready to implement`) per `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md`. Dispatch grep targets that look for the token still resolve; the user sees a label they can act on without learning Cohesive's vocabulary.
- The body section is titled `## Findings` — generic, unambiguous. The user knows what they're looking at without translating.
- Each finding's six-field block uses substrate-shape *fields* (Severity, Category, Why it matters, Evidence, Recommended fix, **Doc to update**) — the last field renamed from "Substrate artifact to add or update" to "Doc to update" so the user-facing column names the file the change touches in their repo, not Cohesive's internal vocabulary. The substrate-vocabulary version is preserved in the persisted file's audit trail (where the agent reads it on subsequent passes).
- The handoff section is titled `### Next` — generic, decision-shape. The skill citation appears in the disposition phrase parenthetically. Methodology framing ("Recommended next Cohesive skill") is removed.
- The implementation route matrix's "When to pick" column uses decision-shape vocabulary ("new docs, structural conventions, cross-cutting changes" instead of "named invariants, behavior matrices"). The user evaluates against their change, not against Cohesive's classification system.

---

## What this transcript demonstrates

The audience seam is structural, not policy-based. The decision-shape render above is what the centralized `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` template produces; the substrate-shape render is what each SKILL.md produced pre-rewrite when the chat-render shell was duplicated across six skill bodies. Centralizing the shell removed substrate vocabulary from the user's surface in one edit; six SKILL.md `## Output format` blocks now cite the centralized template and specify only their body block.

Two failure modes the transcript guards against:

1. **Substrate-vocabulary leak in chat.** "Required substrate before implementation", "Substrate artifact to add or update", "Cohesive workflow", "Recommended next Cohesive skill" are the canonical leak tokens. The decision-shape render replaces them with their decision-shape analogs (`Doc to update`, `### Next`, decision-shape verdict labels per the verdict-vocabulary table).
2. **Methodology-name-as-user-label.** "Cohesive route", "substrate-shaped work", "Cohesive workflow" do not appear in the decision-shape render. The methodology lives in skill body prose, AGENTS.md, README, contributor docs, and persisted-file templates — surfaces contributors read, not surfaces users read.

The persisted file (`docs/history/reviews/2026-05-06-audience-seam-rewrite-validation.md` in this scenario) carries the substrate-shape body for the agent's audit trail. The chat trailer is the user's surface; it carries the decision-shape render. The two surfaces carry the same substance in different shapes per the audience seam.

## Captured transcripts (queued)

A real-session capture meeting these acceptance criteria is queued. The acceptance criteria mirror those in `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/output-voice-worked-example.md`:

- The render appears verbatim in the transcript (not authored side-by-side after-the-fact).
- The session shows the skill's tool calls leading up to the render — Read calls on `output-voice.md` and `audience-separation.md`, dispatch of the reviewer agent, persistence of the review file.
- The render satisfies the audience-seam acceptance criteria: no substrate-vocabulary tokens in chat, `### Next` heading instead of `### Recommended next Cohesive skill`, verdict label translated per `verdict-vocabulary.md`.
- The capture is dated and the session ID is recorded.

When the capture lands, append it as a new section here. Do not edit the side-by-side example above; both shapes (authored example + real capture) are useful for different audiences.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md` — the convention this transcript demonstrates
- `${CLAUDE_PLUGIN_ROOT}/references/templates/chat-trailer.md` — the centralized template the decision-shape render uses
- `${CLAUDE_PLUGIN_ROOT}/references/verdict-vocabulary.md` — internal-label → user-facing-label mapping
- `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` — voice rules; rule 2a amended in the same rewrite to recognize the seam
- `${CLAUDE_PLUGIN_ROOT}/docs/history/transcripts/output-voice-worked-example.md` — the prior worked transcript (verdict-leads / show-shape / payload-carrying); this transcript layers the audience seam on top
- `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-06-audience-seam.md` — the rewrite that landed this convention
