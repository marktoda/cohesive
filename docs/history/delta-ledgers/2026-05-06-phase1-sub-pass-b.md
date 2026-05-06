# Design Delta Ledger — Phase 1 sub-pass B (scope.md + audience seam extension)

**Date:** 2026-05-06
**Worktree / branch:** `.claude/worktrees/phase1-sub-pass-b` on `design/phase1-sub-pass-b`
**Approved direction:** Phase 1 sub-pass B of the accessibility roadmap — scoped down from the original three-piece plan to two pieces. The verb-first subskill rename is **deferred** because its cost (every citation, commit, plan, and `### Next` payload across the substrate breaks; every reader's muscle memory has to relearn) outweighs the Superpowers-aesthetic benefit, and Cohesive's namespace IS its identity (`cohesive:discover-substrate` is more legible than `cohesive:inventory` because the methodology shape is the value prop). The two pieces that DO ship: (1) a new negative-space convention doc at `docs/substrate/conventions/scope.md` that enumerates what Cohesive does and explicitly what it doesn't do, closing the day-1-onwards scope-creep failure mode; (2) an audience seam extension that names `references/substrate-vocabulary.md` as the canonical translation source for substrate types in chat surfaces (parallel to how `verdict-vocabulary.md` is the canonical source for verdict labels).

## Delta at a glance

This rewrite is **Mixed** — primarily Design (new convention doc establishing the negative-space discipline + audience-seam extension to substrate types) with implementation seams in `references/substrate-vocabulary.md`'s consumer enumeration and `ARCHITECTURE.md`'s convention doc count.

**Design-layer changes:**
- `docs/substrate/conventions/scope.md` — new convention doc. Names "Cohesive overbuilds simplicity and extensibility; underbuilds everywhere else" as the methodology's discipline; enumerates what Cohesive ships, what it deliberately doesn't ship (implementation discipline / tooling and ops / project management / code-style and aesthetics), the open extension surfaces, and promotion criteria. Closes the day-1-onwards scope-creep failure mode named in the simplification architecture review.
- `docs/substrate/conventions/audience-separation.md` — new §"Surface-by-surface translation: substrate types" section. Pins `references/substrate-vocabulary.md` as the canonical translation source for substrate types in chat surfaces, parallel to how `verdict-vocabulary.md` is the canonical source for verdict labels. Names the colloquial first-phrase rule (chat surfaces use "a rule the code is *guaranteed* to follow" instead of `Named invariant`, etc.) and the documented exemption for artifact-naming surfaces (init's drafts, audit-substrate's Top fixes — both pedagogical/deliverable surfaces where the substrate-shape vocabulary is by-design).

**Implementation changes:**
- `references/substrate-vocabulary.md` — restored the third consumer (scope.md, now exists); tightened the chat-trailers consumer language from "Phase 1 sub-pass B, planned" to the actual now-canonical convention.
- `ARCHITECTURE.md` — convention doc count updated from 5 to 7 (adds audience-separation and scope; the 5-count was already stale from earlier rewrites that added audience-separation).

- **Files:** 2 rewritten, 2 added (scope.md + this ledger), 0 removed
- **Conceptual changes:** New "negative-space" convention category with explicit discipline ("overbuild simplicity and extensibility; underbuild everywhere else"); the audience seam now has a parallel translation surface for substrate types matching the existing one for verdict labels.
- **Named invariants:** none added/removed/changed.
- **Behavior matrices:** none.
- **Gotchas:** none.
- **Semantic linters:** none added; the deferred Check 13o for substrate-vocabulary table fields can now land any time (there are now three documented consumers — init, chat-trailer translation, and scope.md — meeting the "≥2 consumers" promotion criterion). Deferred to a follow-up so this rewrite stays scoped.
- **Tests proposed:** worked-transcript demonstration of init still deferred (waiting on a real-codebase run); scope.md is read-and-cite-only, no test needed.
- **Deferred (out of scope this pass):** verb-first subskill rename (rejected as low-value/high-cost per the rewrite's approved direction); Check 13o promotion (deferred to a follow-up); per-skill chat-trailer site updates that mention substrate types (only init does today, and init's exemption is documented; future skills will inherit the convention via audience-separation.md).

## Files rewritten

- `references/substrate-vocabulary.md`
  - **Before:** Listed two consumers — init (canonical) and chat trailers ("Phase 1 sub-pass B, planned"). Forward-referenced scope.md indirectly via `audience-separation.md` which itself didn't yet name substrate-vocabulary as canonical for chat-surface substrate-type translation.
  - **After:** Lists three canonical consumers: init's draft-file render template (today's only direct consumer), chat trailers (now formally named via the new audience-separation §"Surface-by-surface translation: substrate types" section), and the new scope.md (cites the user-facing definitions when explaining what each substrate type is for and what the methodology overbuilds vs underbuilds). The chat-trailer consumer language changed from "planned" to a precise statement of the colloquial first-phrase rule with a citation to the new audience-separation section.
  - **Reason:** Closes the forward reference deferred in the init pass-1 review (B1 there); promotes the substrate-vocabulary table from one-canonical-consumer (init) to a three-consumer canonical translation surface, parallel to verdict-vocabulary.md.

- `docs/substrate/conventions/audience-separation.md`
  - **Before:** Documented two translation surfaces (verdict-vocabulary.md for verdict labels) but did not enumerate the substrate-type translation surface. The colloquial-vs-precise distinction for substrate types was implicit (sometimes used in init's drafts, sometimes leaked in audit's Top fixes); no canonical rule named it.
  - **After:** New §"Surface-by-surface translation: substrate types" section pins both translation surfaces explicitly: verdict labels translate via `verdict-vocabulary.md`; substrate types translate via `substrate-vocabulary.md`. The colloquial first-phrase rule is named with concrete examples (`Named invariant` → "a rule the code is *guaranteed* to follow"; `Behavior matrix` → "a decision table"; etc.). The artifact-naming exemption is named explicitly: skills whose primary deliverable IS the substrate-shape thing the user should add (init's draft files, audit's Top fixes) render the agent-internal substrate-type name as the artifact label rather than the colloquial.
  - **Reason:** Without this section, a future contributor authoring a new chat-render surface that mentions a substrate type would have no canonical place to look up "is `Named invariant` substrate-shape that should translate, or user-facing that should stay?" The translation rule was load-bearing on reviewer attention; this section makes it findable.

## Files added

- `docs/substrate/conventions/scope.md` — the new negative-space doc. Enumerates what Cohesive does and deliberately doesn't do. Closes the day-1-onwards scope-creep failure mode named in the simplification architecture review. Cited from `references/substrate-vocabulary.md` (consumer #3) and from `audience-separation.md` Related substrate.
- `docs/history/delta-ledgers/2026-05-06-phase1-sub-pass-b.md` — this file.

## Files removed or deprecated

None.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| Cohesive's scope (what it does and doesn't do) is implicit; reviewer-judged at simplification-pass cadence | Cohesive's scope is explicit at `docs/substrate/conventions/scope.md`, structured as Does (the 11 skills + 6 reviewer agents) / Doesn't (4 categories: implementation discipline / tooling and ops / project management / code-style and aesthetics) / Can extend (the open seams) / Promotion criteria (the bar a new addition has to clear) | Promoted to substrate |
| Substrate-type translation in chat surfaces was reviewer-judged (implicit colloquial first-phrase rule used by init; potential leakage in any new chat surface) | Substrate-type translation is canonical via the substrate-vocabulary table, documented in audience-separation.md §"Surface-by-surface translation: substrate types," with the colloquial first-phrase rule pinned and the artifact-naming exemption named (init drafts + audit Top fixes) | Pinned |
| `references/substrate-vocabulary.md` had one canonical consumer (init) | Three canonical consumers (init / chat-trailer translation / scope.md), meeting the deferred Check 13o "≥2 consumers" promotion criterion (Check 13o itself still deferred to a follow-up rewrite to keep this pass scoped) | Extended |
| Verb-first subskill rename was Phase 1 sub-pass B work | Deferred; rejected as low-value/high-cost. The rewrite preserves the substrate-prefixed names because Cohesive's namespace IS its identity. | Deferred |

## New or updated substrate

### Specs

- `docs/substrate/conventions/scope.md` — new convention doc.
- `docs/substrate/conventions/audience-separation.md` — new §"Surface-by-surface translation: substrate types" section.
- `references/substrate-vocabulary.md` — consumer enumeration extended.
- `ARCHITECTURE.md` — convention doc count updated.

### Behavior matrices

None.

### Named invariants

None.

### Gotchas

None added or retired.

### Semantic linter specs

- No new check this pass. Check 13o (substrate-vocabulary table fields grep) is now eligible for promotion (3 documented consumers) but is deferred to a follow-up so this rewrite stays scoped.

### Tests / checks proposed (not yet implemented)

- Check 13o (substrate-vocabulary table fields) — deferred to a follow-up.
- Convention-with-grep promotion check for scope.md is harder to mechanize because the doc's content is qualitative; reviewer attention via `cohesive:review-codebase` is the realistic enforcement (named in scope.md §"How this convention is enforced").

## What this rewrite *did not* do

- **Verb-first subskill rename.** Deferred per the approved direction. The cost of breaking every citation, commit message, and `### Next` payload across the substrate exceeds the Superpowers-aesthetic benefit. Cohesive's namespace IS its identity; renaming `discover-substrate` to `inventory` weakens the methodology distinction without commensurate user-facing benefit (the audience seam already keeps subskill IDs out of the user's primary chat surfaces).
- **Per-skill chat-trailer site updates.** Today only `init` consumes the substrate-vocabulary translation in its chat trailer (and via the artifact-naming exemption). Future skills with chat surfaces that mention substrate types will inherit the audience-separation §"Surface-by-surface translation: substrate types" rule; this pass doesn't sweep existing per-skill body templates because the existing templates either don't mention substrate types in chat (most cases) or are documented exemptions (init, audit-substrate).
- **Validator Check 13o promotion.** The substrate-vocabulary table now has three canonical consumers (the "≥2" promotion criterion is met), but landing the check requires a non-trivial awk pattern + per-row schema documentation. Deferred to a follow-up rewrite to keep this pass scoped.

## Remaining ambiguity

- **Where the line is between "convention doc" and "scope doc."** scope.md is convention-shaped (lives under `conventions/`, has a §"How this convention is enforced" section) but is structurally different from the other conventions (skill-shape, reviewer-agent-shape, etc. are *prescriptive*; scope.md is *demarcating*). The category split between prescriptive conventions and demarcating conventions might surface a future structural distinction; for now scope.md sits inside `conventions/` as a peer.
- **The negative-space cap on adjacent skills.** scope.md names "implementation discipline" (Superpowers' territory) as an explicit non-overlap. But there's a soft case: `cohesive:debug` would be substrate-shaped (debugging touches behavior, invariants, regressions). The "doesn't do" framing covers this today by saying "bug debugging — Superpowers' debugging skills"; if a future user wants Cohesive-shaped debugging (e.g., "find where this regression's invariant is named"), the boundary may need re-examination. Documented in scope.md §"Why these cuts."
- **The deferred verb-first rename's revisit criterion.** This rewrite rejects the rename as low-value, but if a future signal emerges (e.g., adoption hits a hard wall on the substrate-prefixed names; multiple new users report the names as the entry barrier), the rename becomes worth revisiting. No explicit trigger criterion is documented; reviewer attention via the next simplification-pass cadence is the realistic surfacing.
