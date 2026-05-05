# Output voice — worked example

**Date:** 2026-05-04
**Source:** authored side-by-side example for the `cut-anchor-pin` rewrite. Real user-request shape; both renders authored to compare. A real capture is queued — see §"Captured transcripts (queued)" below.
**Companion:** `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`

This is the load-bearing artifact for the voice guide. Rules describe shape; this transcript shows it. Read this when authoring or revising a skill's Output format block — examples teach voice, prose doesn't.

## The scenario

User invokes `cohesive:cohesively` with: *"Review this branch for cohesion before I open the PR. The branch adds a new GraphQL resolver for `userPreferences` and updates two specs."*

Both renders below assume `discover-substrate` and the two reviewer agents have already run; what's shown is the synthesizer's chat render.

---

## The wordy render (anti-example — do not emulate)

> ## Cohesive Change Cohesion Review
>
> Hi! I've completed the change cohesion review for your branch. Before getting into the findings, let me briefly recap the methodology: Cohesive's `review-diff` skill dispatches the substrate-alignment-reviewer and structure-reviewer agents in parallel, and I've synthesized their outputs below.
>
> ### Background
>
> The branch under review modifies `schema/user.graphql` and `resolvers/user-preferences.ts`, and updates two specs: `docs/specs/user-preferences.md` and `docs/specs/graphql-resolvers.md`. I read the substrate discovery report first, then dispatched the reviewers, then synthesized.
>
> ### Reviewer 1: Substrate-alignment-reviewer
>
> The substrate-alignment-reviewer found that the new resolver mostly preserves documented behavior. There were three findings worth noting:
>
> #### Finding 1.1: Spec-implementation alignment
>
> The new resolver's behavior is documented in the updated spec, which is good. However, there's a subtle mismatch between the resolver's null-handling and the spec's claim that "missing preferences default to system defaults." The implementation actually returns null for missing preferences, which is a meaningful difference.
>
> ##### Why this matters
>
> A future contributor reading the spec would assume defaults are applied, but the implementation doesn't apply them. This is exactly the kind of drift Cohesive is designed to catch.
>
> ##### Recommended fix
>
> Either update the spec to match the implementation (returns null) or update the implementation to match the spec (apply defaults). It's worth noting that the choice depends on what the team wants the contract to be.
>
> #### Finding 1.2: ...
> [continues for several more nested headers]
>
> ### Reviewer 2: Structure-reviewer
>
> [similarly structured paragraph]
>
> ### Overall Verdict
>
> Based on the synthesis above, the verdict is **Pass with notes**. There are no blocking issues, but Finding 1.1 should be addressed before merge.
>
> ### What you might want to do next
>
> You could consider running `cohesive:rewrite-specs` if you want to formalize the spec changes, or you could run `superpowers:writing-plans` if you're ready to proceed with implementation. Either approach has merit. Let me know if you have any questions!

**What's wrong with this:**

- Verdict appears in paragraph 8 of 12, after a methodology recap, agent attribution, and a setup paragraph. The reader has to scroll to learn whether the change is safe to merge.
- 5 levels of header nesting (`##` → `###` → `####` → `#####`). Header soup.
- "It's worth noting that," "Hi!", "Let me know if you have any questions!" — ceremony without information.
- Two next-step recommendations with no decision support. "Either approach has merit" pushes the choice back to the user instead of using the verdict to pick one.
- Reviewer attribution ("The substrate-alignment-reviewer found...") is a process artifact, not a finding. The reader cares about the finding, not which agent produced it.
- Methodology recap at the top is dead weight. The user invoked the skill; they know what it does.

---

## The punchy render (canonical)

> # Change Cohesion Review
>
> **Verdict:** Pass with notes
>
> ## Main concern
>
> Spec claims missing preferences default to system defaults; resolver returns null. Drift is small but real — fix before merge.
>
> ## Findings
>
> | Severity | Area | Finding | Suggested substrate |
> |---|---|---|---|
> | High | Spec drift | `user-preferences.md` claims default-fallback; resolver returns null (`resolvers/user-preferences.ts:42`) | Update spec or resolver; pick the contract |
> | Medium | Test gap | No test pins the chosen behavior either way | Add a regression test once the contract is decided |
> | Low | Locality | New resolver imports `lib/cache` directly; other resolvers go through `lib/cache/wrapper` | Route through wrapper for consistency |
>
> ## Highest-leverage fix
>
> Decide the contract: defaults-on-missing or null-on-missing. Update one of the two artifacts (spec or resolver) to match the other; add a regression test. ~30 minutes including the test.
>
> ### Recommended next Cohesive skill
>
> `cohesive:rewrite-specs` — the contract decision is a substrate change; rewrite the spec, then implement.

**Why this works:**

- Verdict appears on the first non-blank line after the title (the canonical frame the validator and `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md` use — counting non-blank lines, not raw line numbers, because the blank between title and verdict is a rendering choice). Reader knows the answer immediately.
- No instruction lines in user-facing output. The voice guide that shaped this render was loaded from a body-level imperative in the skill — `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` — not from a citation inside the render template. Citations in render templates leak verbatim to users (the v0.1 pre-pivot mistake; see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` §"Correct pattern").
- 3 levels of header nesting maximum, all `##` or `###`.
- Findings are a table — `Severity / Area / Finding / Suggested substrate` per row, ranked by leverage. Reader scans the column they care about.
- Single next-step recommendation, picked by verdict.
- No reviewer attribution. The findings stand on their own.
- No methodology recap. No hedge words. No pleasantries.
- ~22 lines of chat render vs ~80 in the wordy version. Same information; different render.

---

## The seven cuts

What was removed from wordy → punchy, and why each cut earned its place:

1. **The greeting and methodology recap** (~6 lines). The user invoked the skill; recap is dead weight.
2. **Reviewer attribution** ("The substrate-alignment-reviewer found..."). Process artifact, not finding.
3. **Header soup** (`####`, `#####`). Cap at `###`; substructure is for tables and bullets.
4. **"It's worth noting that"** and similar hedge phrases. Direct claims earn trust; hedging erodes it.
5. **Two next-step recommendations.** Verdict picks one.
6. **The closing pleasantry** ("Let me know if you have any questions!"). The user can ask if they want to.
7. **Narrative findings.** Convert to a table. The same information renders in a third the lines.

The cuts are not about saying less. They are about saying the same thing in a render the reader can scan.

---

## Captured transcripts (required before promoting voice-imperative to invariant)

This file is an *authored* contrast — both renders were written for pedagogy. Every anti-pattern in the wordy render has been observed in real Cohesive runs, but the side-by-side itself is constructed.

The next substrate task in this area is to capture a *real* transcript from a dogfood `cohesive:review-codebase` or `cohesive:review-diff` run on an external repo and persist it here as a sibling file:

```
docs/history/transcripts/output-voice-captured-YYYY-MM-DD-<slug>.md
```

A real capture carries two kinds of weight. **Pedagogical:** the anti-patterns it shows are observed-not-imagined, and the rationale-for-cuts can quote the actual generated output. **Empirical:** the capture is the gating artifact for the voice-imperative load-bearing claim. The post-pivot pattern (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` §"Correct pattern") rests on the assumption that a body-level `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.` imperative actually triggers a Read tool call at chat-render time. Until a captured transcript shows the Read call happening, the assumption is reasoned-but-unverified. The capture is one of the four promotion criteria documented in `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` §"Why the voice imperative is convention-with-grep, not a named invariant"; without it, promotion is blocked.

Until a real capture lands, this authored transcript is the canonical reference; once a capture exists, the captured file becomes canonical and this authored file is preserved as the original pedagogical reference.

### Acceptance criteria for the captured transcript

A captured transcript counts toward the empirical-load proof when **all four** of the following hold:

1. **Source skill named.** The capture comes from a real, user-invoked run of `cohesive:review-diff`, `cohesive:review-codebase`, or `cohesive:audit-substrate` — one of the verdict-led skills the voice imperative governs. Authored or simulated runs do not count; the capture must be from a session the user actually initiated.
2. **Tool-call evidence of the Read.** The transcript records a `Read` tool call invoked on `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` (or an equivalent absolute resolution of that path) by the rendering model, *between* the skill's invocation and the chat render. A transcript showing the imperative in the SKILL.md body but no corresponding Read call is empirical evidence the *opposite* way — the imperative is being treated as setup-only context — and disqualifies the rewrite from invariant promotion until the imperative wording is strengthened.
3. **Voice-rule reflection in the rendered output.** The chat render in the same transcript reflects at least three voice rules from `output-voice.md` §"The five rules" — verdict-leads (rule 1), faithful-subset (rule 2), header-depth cap at `###` (rule 3), branchy content as bullets/tables (rule 4), or single recommended-next move (rule 5). "Reflects" means the rule is observably applied; absence of forbidden phrasings (per §"Forbidden phrasings") also counts. The capture is what proves the load *did the work*, not just that the file was read.
4. **Persistence path.** The capture lives at `docs/history/transcripts/output-voice-captured-YYYY-MM-DD-<slug>.md` with a frontmatter block naming the source skill, the date, and the runtime context (model, harness version, plugin version). The frontmatter is what makes the capture auditable across release cycles — promotion criterion 1 in `output-voice.md` §"Why the voice imperative is convention-with-grep…" requires *two release cycles without rewording*; release-cycle delineation is reconstructed from frontmatter dates.

A capture meeting all four criteria is sufficient on its own — multiple captures are not required for the empirical-proof gate (criterion 3 of the promotion list). The other three promotion criteria (no rewording across two release cycles, real regression caught by the validator, no rewording anticipated) remain independent gates.

Disqualifying conditions: a capture that is partial (no tool-call log), reconstructed (assembled from multiple sessions), or simulated (the user faked a Read call to satisfy the criterion) does not count. The point of "captured-not-authored" is that the empirical claim is non-fiction; reconstructed evidence reintroduces the authored-fiction problem the gate exists to retire.

## Notes for future contributors

- When voice evolves and a new transcript is needed, **add a new dated transcript file** rather than editing this one. This file is the substrate record of what voice meant on 2026-05-04. The next iteration is `output-voice-worked-example-YYYY-MM-DD.md`.
- The wordy render above was *authored* for contrast, not captured from a real session — but every anti-pattern in it has been observed in real Cohesive runs. Future transcripts should prefer real captures when available.
- If you find yourself adding a fourth header level, your render is doing too much; move it to the persisted file or replace it with a table.
- If you find yourself recommending more than one next skill, the skill's verdict logic is broken; fix the verdict, not the recommendation.

## Related

- `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` — the voice and density rules this transcript demonstrates
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md` — the rule that caught the wordy render's biggest sin
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/wordy-output.md` — the scar this transcript helps prevent
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` — why this transcript exists alongside the rules
