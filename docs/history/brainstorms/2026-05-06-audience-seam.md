# Brainstorm — audience seam (agent-internal substrate vs user-facing decisions)

**Date:** 2026-05-06
**Slug:** `audience-seam`
**Triggered by:** user request — "review the user experience of using the cohesively skill pack… users mostly care about the architecture decisions and how they trade off; substrate is just a tool for the agent to keep things in check."
**Predecessor:** `docs/history/reviews/2026-05-06-skill-pack-flow-iteration-2-architecture-review.md` (finding 3 — end-to-end-journey artifact still missing) and `docs/history/reviews/2026-05-05-skill-pack-flow-architecture-review.md` (findings 6, 15 — right-sized chain + chain-announcement-stacking deferred).

## Current scope

- The render surface of all 9 Cohesive skills + the router + `using-cohesive` orientation: what tokens, vocabularies, and structural shapes appear in chat versus persisted files.
- The verdict vocabularies (`Substrate sound/sparse/gaps`, `Cohesive but under-enforced`, etc.) and the `Recommended next Cohesive skill` payload convention.
- The orientation/announcement strings (`This is substrate-shaped work…`, `I'm treating this as a Cohesive <route> workflow…`).
- The chat-render rules in `references/output-voice.md` (rule 2 family, rule 5a) governing what content-kind belongs in chat.

## Future pressure (not current scope)

- New chain skills and new verdict-led outputs must satisfy whatever convention lands here without per-skill litigation.
- v0.1 release is gated on Cohesive passing its own cohesion review; the UX surface is part of the answer to "is this learnable?"
- Cohesive composes with Superpowers; the seam needs to render cleanly when handoff payloads cross plugin boundaries (e.g., `Recommended: superpowers:writing-plans`).
- Cohesive must remain teachable to contributors — methodology must stay legible *somewhere*, even if not in every chat turn.

## Non-goals

- Removing substrate-first methodology. The agent still drives off specs/invariants/matrices/gotchas/linters; that machinery doesn't move.
- Collapsing the persisted-file layer. Audit-trail content (delta ledgers, validation reviews, architecture-review reports) stays canonical.
- Changing reviewer-agent internals. Reviewers still produce six-field findings and operate on substrate.
- Adding a runtime "verbose mode" toggle. The choice belongs at design time, not at invocation time.

## Design options

### Option A: Vocabulary translation layer

**Summary:** Keep every skill's structural output shape. At render time, translate substrate-vocabulary tokens (verdict labels, finding categories, scorecard axes) into plain-language equivalents via a single `verdict-vocabulary.md` mapping matrix consumed by all skills.

**Substrate changes required:** new matrix `docs/substrate/matrices/verdict-vocabulary.md`; one-line addition to each verdict-led skill's `## Output format` ("verdict label rendered per `verdict-vocabulary.md`"); no change to handoff verdicts internally; no change to `output-voice.md` rules.

**Locality impact:** none — each skill stays self-contained. The translation table is the only new shared concept.

**Future fit:** easy to extend (new verdict → new mapping row). Doesn't help the deeper structural concerns (Top findings, Recommended-next payload, brainstorm Recommendation foregrounding "Required substrate").

**Initial risks:** substrate vocabulary still surfaces everywhere except the verdict line. Cosmetic fix masks structural issue.

### Option B: Audience seam via voice rule 6 (initial recommendation, later superseded)

**Summary:** Promote a sixth voice rule: chat-rendered output names architectural decisions, tradeoffs, risks, and concrete next moves; substrate-shaped concerns displace to the persisted file. Each verdict-led skill's `## Output format` carries two distinct templates (Chat trailer + Persisted body). Verdict labels translate to plain language at the seam.

**Substrate changes required:** new convention `audience-separation.md`; new voice rule 6; verdict-vocabulary matrix; per-skill Output format bisection; rule 2a amendment.

**Locality impact:** clean seam — reviewers and contributors work in one half at a time.

**Future fit:** every new skill complies by following the convention; well-modeled by existing voice-rule precedent.

**Initial risks:** rule 2a's "chat is a subset" needs amendment; rule-set growth (5 → 6 top-level rules with already-strained sub-rule layering); style-guide-rot risk if rule 6 lives only as convention; relies on the model loading the voice guide and applying the rule on every render across 6 skill bodies.

### Option C: Methodology-hidden — Cohesive becomes invisible scaffolding

**Summary:** Rewrite all user-facing surfaces (announcements, orientation, verdict labels, Recommended-next clauses, frontmatter descriptions) so the user never encounters the words "Cohesive", "substrate", "invariant", "matrix", "gotcha", "route" in normal output.

**Substrate changes required:** every skill body's announcement and Output format strings; the router's announcement template; `using-cohesive`'s orientation message; the entire verdict vocabulary set; frontmatter `description` strings.

**Locality impact:** invasive — bleeds across announcements, orientations, frontmatters, verdict labels, payloads. No single seam contains the change.

**Future fit:** harder. Cohesive's pedagogy is itself substrate-first; hiding the methodology in chat hides the practice the methodology teaches.

**Initial risks:** breaks Check 9a/9b's substrate-vocabulary requirement on frontmatters; collapses toward Option B with extra rewriting.

### Option D: Centralized chat-trailer template + substrate-vocabulary removal + methodology-name removal from chat surfaces

**Summary:** Refinement of Option B that replaces "add rule 6" with structural removals. Centralize the chat-render shell into a single `references/templates/chat-trailer.md`. Remove substrate vocabulary tokens from that template literal. Remove the "Cohesive" methodology-name from chat surfaces (announcement, orientation, "Recommended next Cohesive skill" footer). Amend rule 2a in place; do not add rule 6. Translate substrate-shaped verdict labels via a small `verdict-vocabulary.md` mapping at the centralized template.

**Substrate changes required:**
- new `references/templates/chat-trailer.md` (centralized chat shell with §"Variants" table for per-skill body-block exceptions)
- new `references/verdict-vocabulary.md` (internal-label → user-facing-label mapping)
- new `docs/substrate/conventions/audience-separation.md` (names the seam, cites the centralized template, names the validator promotion path)
- amend `references/output-voice.md` rule 2a's "subset" framing → "decision-render of"; reword rule 5a's "Recommended next Cohesive skill" → "Recommended next step"; do **not** add rule 6
- simplify `docs/substrate/conventions/skill-shape.md` §"Output format conventions" (replace inline canonical render shape with a 1-line citation to centralized template)
- 6 verdict-led `SKILL.md` `## Output format` blocks (replace duplicated render templates with a citation to centralized template + body-block specification only)
- `skills/cohesively/SKILL.md` announcement template + `skills/using-cohesive/SKILL.md` orientation message (rewrite to lead with outcome, not methodology)
- `docs/substrate/matrices/reviewer-output-shape.md` (simplify — per-skill render-shape rows collapse into chat-trailer references with body-block variants)
- `docs/substrate/architecture/handoffs.md` (chat-rendered verdict references translated; internal labels in the rubric stay as-is)
- new dated worked transcript at `docs/history/transcripts/2026-05-06-audience-seam.md`

**Locality impact:** centralization recognizes existing duplication (six skills already share the same shell shape per the density-budget table in `output-voice.md`). The body-block (table-vs-list-vs-matrix) stays per-skill; the shell collapses to one file. Net: smaller substrate, not larger.

**Future fit:**
- New skill: copies the chat-trailer template by reference; specifies its body-block. Lower cost than Options A/B/C.
- New verdict: adds a row to verdict-vocabulary.md.
- Methodology change: edit the chat-trailer template once; all six skills' chat output updates atomically.
- Composition with Superpowers: `Next: <action> (cohesive:<x> | superpowers:<y>)` renders plugin-agnostic — the chat treats Cohesive and Superpowers symmetrically as "the skill that takes the next architectural action."

**Initial risks:**
- Centralized template becomes a load-bearing artifact whose drift cascades to all six verdict-led skills at once.
- Heterogeneity concern: can a single template handle 6 distinct skill outputs? Resolved: shell is shared; body-block is per-skill.
- Validator backing deferred until wording stabilizes; reviewer-judged in the interim.

## Pressure test summary

| Option | Cohesion | Substrate delta | Future fit | Locality | Main risk |
|---|---:|---|---|---|---|
| A — Vocabulary translation | Med | Small (1 matrix + 9 one-liners) | Limited — verdict-line only | None new | Cosmetic; substrate-shape leaks elsewhere immediately |
| B — Audience seam via rule 6 | High | Medium (1 convention + 1 voice rule + 1 matrix + 6 skill bisections) | Strong — convention scales | Clean — one seam, applied per skill | Rule 6 lives far from 6 generation points; style-guide-rot scar fires; rule-set growth on already-strained set |
| C — Methodology-hidden | Low | Large (every skill + router + frontmatters + Check 9a/9b conflict) | Weak — fights Cohesive's own pedagogy | Invasive — no single seam | Conflicts with frontmatter substrate-vocabulary enforcement; collapses toward B with extra rewriting |
| D — Centralization + removal | High | Medium-net-smaller (centralization collapses duplication; reviewer-output-shape simplifies) | Strongest — shell change is one-file edit | Cleanest — one centralized surface | Centralized template is load-bearing; reviewer-judged compliance until validator backs it |

## Why Option D over Option B

Option B was the initial recommendation; deeper pressure-testing surfaced three structural problems with the rule-6 approach:

1. **The rule set is already strained.** Rule 2 has three sub-rules; rule 5 has a sub-rule; rule 2c was added because rule 2a wasn't enough. A sixth top-level rule on a substance-vs-bookkeeping axis already covered by rule 2 is layering, not architecture.
2. **Templates teach voice more reliably than rules.** `output-voice.md` §"How this guide is used" already names the Output format block as "the render template the model reproduces in user-facing output." `skill-shape.md` §"Anti-patterns" already names "instructions in render templates leak into user-facing output verbatim" as a known failure mode. Substrate vocabulary inside the chat-render template literal leaks the same way. No rule prevents that; only template content does.
3. **Rule 2a's "subset" framing already broke under the audience seam.** Adding rule 6 doesn't repair rule 2a; it stacks on top of a now-incoherent rule. The cheaper move is to fix rule 2a in place and stop.

Option D's structural removals (vs. Option B's policy addition) are listed in §"What gets removed" below.

## What gets removed (Option D)

1. **Six duplicated chat-render templates** across `review-codebase` / `review-diff` / `validate-rewrite` / `audit-substrate` / `brainstorm-design` / `implement-cohesively` Output format blocks → collapse to a single `references/templates/chat-trailer.md`. Parallel to how `references/templates/architecture-review-report.md` already centralizes the persisted-file shape; persisted templates are centralized; chat templates are not — that asymmetry is the substrate gap.
2. **Substrate vocabulary tokens** (`**Required substrate before implementation:**`, `**Substrate artifact to add or update:**`, `**Suggested substrate:**` table column, `**Files to edit:** docs/substrate/<...>`) → removed from the centralized chat-trailer literal. Replaced with `**Decision:**`, `**Tradeoff:**`, `**Risk:**`, `**Mitigation:**`, `**Next:**`. The vocabulary is enforced by the template's content, not by a rule the model must remember.
3. **"Cohesive" methodology-name** in three chat surfaces — the router's `I'm treating this as a Cohesive **<route>** workflow…` announcement, `using-cohesive`'s `This is substrate-shaped work…` orientation, the `### Recommended next Cohesive skill` footer — → all three rewritten to lead with what the user gets. Footer becomes `### Next` with the architectural action; methodology citation moves under-the-fold (or into the persisted file). Methodology stays in skill body prose, AGENTS.md, README, and reviewer-agent shapes — surfaces contributors read, not surfaces users read.
4. **Substrate-shaped verdict labels** (`Substrate sound / sparse / gaps`, `Cohesive but under-enforced`, `Spec drift risk`) leaking into chat → translated at the chat-trailer template via `references/verdict-vocabulary.md`. Internal labels stay as-is in `cohesion-rubric.md` and `handoffs.md` (agent-facing dispatch logic). Translation happens once, in the centralized template.
5. **Rule 2a's "faithful subset" framing** → amended in place (not replaced by rule 6). New wording: *the chat trailer is the decision-render of the persisted body; every chat claim has a persisted-file source line, but the chat is rendered in user-facing vocabulary while the body is rendered in agent-facing vocabulary.* Rule count stays at five.
6. **Rule 5a's "Recommended next Cohesive skill" naming convention** → reworded to "Recommended next step", with the skill name appearing parenthetically after the architectural action. Rule 5a's payload requirement survives; only the methodology-naming framing goes.

## What gets added (smaller than what gets removed)

- **`references/templates/chat-trailer.md`** — the single centralized chat shell: verdict-line slot (translated via verdict-vocabulary), thesis/main-concern slot, body-block slot (per-skill variant), next-step slot. Contains zero substrate-vocabulary tokens.
- **`references/verdict-vocabulary.md`** — small mapping table: internal label → user-facing label.
- **`docs/substrate/conventions/audience-separation.md`** — names the seam, points at the centralized template, names the validator promotion path.
- **One eventual validator check (deferred)** — Check 13k on the centralized chat-trailer template literal: forbidden substrate-vocabulary tokens grep. Lands when the template wording stabilizes per `style-guide-rot.md` promotion criteria.

## Why this is "hard to fuck up" — five forcing functions

1. **The chat-trailer template is the literal text the model reproduces.** A token that's not in the template can't appear in the output without the model deviating creatively. Templates have higher fidelity than rules.
2. **Centralization means one surface to police, not six.** A future contributor adding a new verdict-led skill copies the centralized template by reference — they don't author a new template. Drift surface collapses from `O(n_skills)` to `O(1)`.
3. **The per-skill SKILL.md `## Output format` block becomes a body-slot specification, not a render template.** The contributor's editing surface is "what does my body block look like", not "what does the verdict line say". Vocabulary discipline is *not their concern* — it's the centralized template's concern.
4. **The methodology-name removal is content-removal, not policy-addition.** Once the strings `cohesive:<skill>` and `Cohesive workflow` are gone from the chat-render templates, they don't drift back unless deliberately reintroduced.
5. **The validator check sits on one file, not many.** Check 13k greps `references/templates/chat-trailer.md` for forbidden tokens. Adding a forbidden token requires editing that one file and getting through review.

Compare to Option B (rule 6): rule 6 lives in `output-voice.md`, far from the six render sites; relies on the model loading the voice guide and applying the rule on every render; reviewers must check six surfaces. Style-guide-rot scar fires.

## Pressure-test answers — Option D

**Q: Does centralization fight the heterogeneity of skill outputs?** No — the shell is what's homogeneous (verdict + thesis + body-block + next-step). The body-block is per-skill (table for diff, six-field for validate-rewrite, etc.). Centralization captures the shell, not the body.

**Q: Does removing methodology-naming from chat undermine learnability?** No — the methodology lives in skill body prose, AGENTS.md, the substrate corpus, reviewer-agent shapes, and persisted-file templates. The user *experiences* substrate-first thinking without having to read the word "substrate" to receive the output.

**Q: Does the "Cohesive" name removal collide with `validate_plugin.sh` Checks 9a/9b?** No — Check 9a/9b operate on frontmatter `description` strings, not on chat-render templates. Frontmatter is the trigger surface; chat is the render surface. The two are already separate; the audience seam respects that separation.

**Q: Is the centralized template premature centralization?** No — it codifies duplication that already exists. Six SKILL.md files currently re-implement the same shell. Variants live in the body-block slot; the shared shell is genuinely shared today.

**Q: What if the centralized template needs a per-skill variant of the shell?** Document the variant in the centralized template's §"Variants" section. Same pattern `skill-shape.md` §"When sections may differ" already uses.

**Q: What's the worst case if Check 13k never lands?** Reviewer-judged compliance carries the load — same as the dispatch-prompt-contract mirror was before Check 13i landed. The convention works if reviewers check it; the centralized template makes "where to look" a one-file question.

**Q: Does this break composition with Superpowers?** Improves it. `Next: rewrite the design docs (cohesive:rewrite-specs)` or `Next: write the implementation plan (superpowers:writing-plans)` reads plugin-agnostic.

## Breakage analysis — Option D

- **Docs that would change:** `references/output-voice.md` (amend rules 2a + 5a; do not add rule 6); `docs/substrate/conventions/skill-shape.md` §"Output format conventions" (1-line citation replaces inline shape); 6 verdict-led `SKILL.md` Output format blocks (citation + body-block only); `skills/cohesively/SKILL.md` announcement; `skills/using-cohesive/SKILL.md` orientation; `docs/substrate/architecture/handoffs.md` (chat-rendered verdict references translated; internal labels in the rubric stay); `docs/substrate/matrices/reviewer-output-shape.md` (simplifies — per-skill render-shape rows collapse).
- **Existing assumptions that break:** rule 2a's "faithful subset" between chat and file. Under the seam, chat is *substantively the same decision* but rendered with different vocabulary and ordering — still verifiable (every chat claim is true per the persisted file) but no longer a literal subset. Amend rule 2a to "chat is the decision-render of the persisted body."
- **Behavior matrix impact:** new `verdict-vocabulary.md`; `reviewer-output-shape.md` simplifies (fewer rows, not more); `router.md` and `phase-derivation.md` unaffected.
- **Invariant impact:** `VERDICT_BEFORE_EVIDENCE` survives — chat-trailer template still leads with the (translated) verdict. `PLUGIN_ROOT_PATHS`, `IMPLEMENTATION_PLAN_COVERS_DELTA`, `SKILL_DESIGN_DOC_SECTION` unaffected. Candidate `CHAT_TRAILER_VOCABULARY` deferred.
- **Test guarantee impact:** Check 13k path documented in `audience-separation.md`; deferred until template wording stable. Single grep target when it lands.
- **Gotchas triggered:** `style-guide-rot.md` is *less* exposed under Option D than Option B (template-as-rule beats rule-far-from-template). `naming-instead-of-showing.md` unaffected — show-shape rule (2b) survives in the centralized template.
- **Locality / centralization concerns:** pressure-tested above — recognizes existing duplication, doesn't impose new coupling.
- **Easy invalid change still possible:** a contributor could edit the centralized template and add a substrate-vocabulary token. Mitigation: the template is one file under review; the validator promotion path is documented; the worked transcript pair makes the discipline visible.

## Recommendation

**Direction:** Option D — Centralized chat-trailer template + substrate-vocabulary removal + methodology-name removal from chat surfaces.

**Main risk:** the centralized chat-trailer template becomes a load-bearing artifact whose drift cascades to all six verdict-led skills at once. A bad edit to one file silently changes all chat output.

**Structural mitigation:** four reinforcements in order of strength:
1. **Worked transcript pair** at `docs/history/transcripts/2026-05-06-audience-seam.md` (dated, append-only) showing the same review/brainstorm rendered substrate-shape-vs-decision-shape side-by-side. Same pattern as `output-voice-worked-example.md`.
2. **Validator Check 13k path documented** in `audience-separation.md`: forbidden substrate-vocabulary tokens grep on `references/templates/chat-trailer.md`. Lands when wording stable; meanwhile single-file surface is reviewer-trivial.
3. **`reviewer-output-shape.md` simplification**: per-skill chat-render shape rows collapse into "uses centralized chat-trailer template" + body-block variant. Substrate gets *smaller* with this change.
4. **Centralized template carries its own §"Variants" table** so per-skill exceptions are tracked at the single source of truth.

**Required substrate before implementation:**

- **Specs:** `references/output-voice.md` (amend rule 2a's "subset" framing → "decision-render of"; reword rule 5a's "Recommended next Cohesive skill" → "Recommended next step"; **do not add rule 6**); `docs/substrate/conventions/skill-shape.md` §"Output format conventions" (replace inline canonical render shape with a 1-line citation); 6 verdict-led `SKILL.md` `## Output format` blocks (replace duplicated render templates with a citation to centralized template + body-block specification only); `skills/cohesively/SKILL.md` announcement template + `skills/using-cohesive/SKILL.md` orientation message (rewrite to lead with outcome).
- **References:** new `references/templates/chat-trailer.md` (centralized template with §"Variants" table); new `references/verdict-vocabulary.md` (internal-label → user-facing-label mapping).
- **Conventions:** new `docs/substrate/conventions/audience-separation.md` (names the seam, cites centralized template, names validator promotion path).
- **Matrices:** `docs/substrate/matrices/reviewer-output-shape.md` simplifies — per-skill render-shape rows collapse into chat-trailer references with body-block variants. Net: smaller substrate.
- **Named invariants:** none promoted this pass. Candidate `CHAT_TRAILER_VOCABULARY` deferred until template wording stabilizes per `style-guide-rot.md` criteria.
- **Tests / checks:** Check 13k path documented in `audience-separation.md`; deferred until template wording stable.
- **Gotchas:** none new.
- **Semantic linters (proposed):** Check 13k (deferred); reviewer-trivial because the surface is one file.

The recommendation is ready for `cohesive:rewrite-specs`. Classification: **Mixed** per `skill-shape.md` §1a — the new convention doc (`audience-separation.md`) and the rule 2a/5a amendments are design-shape; the centralization mechanics (chat-trailer template, verdict-vocabulary matrix, six SKILL.md Output format simplifications, two announcement-string rewrites, reviewer-output-shape simplification) are pure-implementation.

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — proceed to spec rewrite in a design worktree. Suggested slug: `audience-seam`. Classification: **Mixed**.
