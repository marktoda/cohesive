# Output voice — worked example

**Date:** 2026-05-04
**Source:** dogfood transcript captured during the `cut-anchor-pin` rewrite. Real user request, both renders authored to compare.
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
> > Voice and density: `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`
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

- Verdict appears in line 5 (after the title and the voice citation). Reader knows the answer immediately.
- 3 levels of header nesting maximum, all `##` or `###`.
- Findings are a table — `Severity / Area / Finding / Suggested substrate` per row, ranked by leverage. Reader scans the column they care about.
- Single next-step recommendation, picked by verdict.
- No reviewer attribution. The findings stand on their own.
- No methodology recap. No hedge words. No pleasantries.
- ~25 lines of chat render vs ~80 in the wordy version. Same information; different render.

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
