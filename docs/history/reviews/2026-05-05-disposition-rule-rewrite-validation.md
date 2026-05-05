# Rewrite Validation Review — Disposition rule for validation-review findings

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** Pass 1 review of spec rewrite on branch `design/disposition-rule`. Design delta ledger at `docs/history/delta-ledgers/2026-05-05-disposition-rule.md`.

**Verdict:** Issues Found

## Executive judgment

The rewrite gives the disposition a single canonical home and three citing surfaces, retires the three-option menu shape at the agent and skill body, and tightens severity vocabulary cleanly. But the rule it installs is not deterministic the way the rewrite's own thesis demands: one row offers `Close inline OR substrate-note`, and the substrate-note clause re-introduces user preference. The disposition derivation step the skill's Output format prescribes therefore still requires a judgment call — the same shape the rewrite forbids elsewhere as a Red flag. That defect is structural (it's in the rubric table itself, the load-bearing artifact) and propagates through three citing surfaces. Repairable in one pass; not mergeable as-is.

## Delta at a glance

- **Files:** 6 rewritten, 0 added, 0 removed/deprecated
- **Conceptual changes:** disposition rule promoted to canonical home of validation-review-finding recommendation; "Three options" menu pattern explicitly forbidden; `Approved` verdict semantics refined (merge-ready vs. repair-required dispositions); severity vocabulary aligned (`Blocking` → `Blocker` in rubric, matching reviewer-agent template)
- **Named invariants:** none added (disposition rule lives as convention in cohesion-rubric.md; promotion criteria deferred — see Remaining ambiguity)
- **Behavior matrices:** disposition table embedded in `references/cohesion-rubric.md` §"Disposition rule for validation-review findings" (6-row mapping of `(verdict, highest-severity)` → `(recommendation, re-validate?)`); not a standalone matrix file
- **Gotchas:** none added (a future "Three options improvisation" gotcha is substrate-noted for follow-up if the pattern recurs)
- **Semantic linters:** none (a future grep that flags option-menu shapes in validation-review chat output is substrate-noted)
- **Tests proposed:** none
- **Deferred (out of scope this pass):** promotion of disposition rule to named invariant; validator check pinning the literal `Disposition:` line in `validate-rewrite` rendered output; gotcha note for the "Three options" failure mode

## Blocking issues

### B1. Disposition rule's "Approved + Low" row offers two options, not one

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** The rewrite's load-bearing thesis is that `(verdict, highest-severity-present)` deterministically picks one recommendation, retiring the menu shape. The Approved-Low row instead offers `Close inline (≤2 lines per finding) **or** substrate-note in the ledger §"Remaining ambiguity" with rationale and a stable ID`. That's a two-option menu inside the rule that purports to forbid menus. Three citing surfaces (skill, agent, template) inherit the defect. A future reviewer hitting Approved-Low still has to render two phrases or pick — exactly the failure the substrate-note in §"Substrate-note disposition" makes explicit ("when the user prefers documenting over inline closure"). The rule is not deterministic; user preference re-enters at the granularity the rewrite shrunk from three options to two.
- **Evidence:** `references/cohesion-rubric.md:111` (table row); `references/cohesion-rubric.md:119` ("when the user prefers documenting over inline closure"); `skills/validate-rewrite/SKILL.md:153` lists both phrases as legitimate Disposition derivations from a single rubric row.
- **Recommended fix:** Pick one default for Approved + Low (close inline is the lower-friction default; substrate-note is for findings the user wants visible across passes) and make the alternative require an explicit override that the rubric notes the same way it notes user override of the rule itself. Or split the row into two by adding a second axis (e.g., "finding has cross-pass relevance: yes/no"). Either move makes the table a function from inputs to a single output.
- **Substrate artifact to add or update:** spec (`references/cohesion-rubric.md` §"Disposition rule for validation-review findings" + §"Substrate-note disposition")

### B2. `Approved + High` collapses verdict semantics; ledger denies the change

- **Severity:** Blocker
- **Category:** Domain model
- **Why it matters:** The rule routes `Approved + High` to `Repair → re-validate` — i.e., not merge-ready. Functionally that's the same disposition as `Issues Found + Blocker`. The verdict `Approved` therefore no longer signals merge-readiness; merge-readiness is now a property of `(verdict, highest-severity)` jointly. The ledger's §"What this rewrite did not do" explicitly claims "Verdict vocabulary: not changed" and that "the disposition fineness lives in the rubric, not in the verdict set" — but the verdict's *meaning* did change, even if its lexical set didn't. A future contributor reading "Approved" in a review without reading the disposition will believe the rewrite is mergeable when it isn't. The verdict's contract is now under-documented.
- **Evidence:** `references/cohesion-rubric.md:113` (Approved + High → Repair, re-validate Yes); ledger `docs/history/delta-ledgers/2026-05-05-disposition-rule.md:95` ("Verdict vocabulary: not changed").
- **Recommended fix:** Either (a) restate verdict semantics in the rubric: "Approved means the rewrite is implementable *after the disposition action*; merge-readiness is a property of (verdict, highest-severity)", with a forward citation from the agent's verdict definitions at `agents/spec-cohesion-reviewer.md:88-91`; or (b) move Approved + High under `Issues Found` and shrink the rule's Approved rows accordingly. Option (a) preserves existing verdict shape; option (b) makes the verdict carry merge-readiness as before. Pick one and propagate.
- **Substrate artifact to add or update:** spec (cohesion-rubric.md verdict semantics + agent template verdict definitions).

### B3. `Issues Found` row covers only Blocker; behavior for `Issues Found + High` undefined

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** The disposition table has one Issues Found row (`Issues Found | Blocker`). The agent's verdict definition at `agents/spec-cohesion-reviewer.md:90` says Issues Found is "salvageable" with "blocking issues that must be repaired before implementation, important issues that should be repaired in the same pass." A reviewer who returns `Issues Found` because of multiple High findings (no Blockers) hits a rubric row that doesn't exist. The rubric is incomplete on its own thesis. Either Issues Found requires at least one Blocker (not stated anywhere), or rows are missing. Implicit category boundaries are exactly the substrate gap this rewrite was meant to close for `Approved`.
- **Evidence:** `references/cohesion-rubric.md:108-115` (rubric table — only one Issues Found row); `agents/spec-cohesion-reviewer.md:90` (verdict definition does not require Blocker for Issues Found).
- **Recommended fix:** Either pin the verdict→severity-floor mapping explicitly ("Issues Found requires highest-severity = Blocker; High-only findings → Approved + High → repair pass"), or add rows for `Issues Found + High` etc. Pinning is cleaner and consistent with B2 option (b). State the pin in the rubric's verdict definitions, not just in the table caption.
- **Substrate artifact to add or update:** spec (cohesion-rubric.md §"Severity vocabulary for findings" extended to a verdict→severity-floor pin, or the table extended).

## Important issues

### I1. "Blocking issues" section heading vs. "Blocker" severity not reconciled

- **Severity:** Medium
- **Category:** Domain model
- **Why it matters:** The rewrite renames severity `Blocking` → `Blocker` for alignment with the reviewer-agent template, but the cohesion-review template at `references/templates/cohesion-review.md:17-29` keeps the section heading `## Blocking issues` with IDs `B1`/`B2`. The relationship between section name and severity name is now implicit: a finding with severity `Blocker` lives in §"Blocking issues"; a finding with severity `High` lives in §"Important issues". Future readers will guess; one will guess wrong. Worth a one-line note in the template clarifying that the section name is the severity-class home, not a third concept.
- **Evidence:** `references/templates/cohesion-review.md:17` ("## Blocking issues"); `references/cohesion-rubric.md:97-101` (severity vocabulary).
- **Recommended fix:** Add a one-line gloss above §"Blocking issues" in the template: "Findings with severity `Blocker`. Severity vocabulary: see `references/cohesion-rubric.md` §'Severity vocabulary for findings'." Same pattern for `## Important issues` (severity `High`/`Medium`).
- **Substrate artifact to add or update:** spec (`references/templates/cohesion-review.md`).

### I2. Disposition rule's `User override` clause undermines the rule's deterministic claim

- **Severity:** Medium
- **Category:** Future-fit
- **Why it matters:** §"User override" says the user can override the recommendation as "a deliberate move against a published default, not a derivation from a menu." That framing is correct in spirit but operationally the same as the menu it replaced: the user still picks. The difference is that the published default now exists and is named, which is a real improvement — but the ledger's §"Remaining ambiguity" already flags that overrides have no substrate residue ("the next `validate-rewrite` pass will surface the finding again if it still applies"). Without a residue, override frequency is unobservable; the team won't know if the rule is too strict until it has been overridden many times silently.
- **Evidence:** `references/cohesion-rubric.md:121` (User override paragraph); ledger §"Remaining ambiguity" entry on override behavior.
- **Recommended fix:** Either land a minimal override-residue surface now (a one-line entry in the ledger's §"Remaining ambiguity" naming the overridden disposition + rationale, mirrored on the deferred-finding shape), or accept the gap explicitly and defer the substrate residue with a re-evaluation trigger ("if `validate-rewrite` runs reveal more than N silent overrides per release cycle, add residue surface").
- **Substrate artifact to add or update:** ledger template (`references/templates/design-delta-ledger.md` §"Remaining ambiguity") or rubric override clause.

## Substrate gaps

- No worked example of a rewrite that lands `Approved + Medium` and what the rendered Disposition phrase looks like end-to-end. The disposition derivation rule is novel; without a worked transcript, the next reviewer agent will improvise the phrase wording. The §"Disposition derivation" note in `skills/validate-rewrite/SKILL.md:153` is a list of example phrases, not a worked render.
- No grep target named yet that would catch a regression of the "Three options" shape in chat-rendered output. Ledger substrate-notes it as deferred; that's defensible for a first iteration, but the Red flag at `skills/validate-rewrite/SKILL.md:180` is the only line of defense, and Red flags are convention.

## Locality concerns

- The disposition rule has a single canonical home and three explicit citation points. ✓ Locality is preserved cleanly.

## Future-fit concerns

- The ledger's "Verdict vocabulary: not changed" claim is the strongest signal of future-fit drift in this rewrite (see B2). Resolving B2 resolves this.

## Enforcement concerns

- No enforcement story for the new convention beyond the body-level Red flag in skill and agent. Promotion criteria are correctly deferred per `style-guide-rot.md` (wording stability + caught regression + worked transcript) — defensible for a first iteration. Track via ledger §"Remaining ambiguity"; no further action needed this pass.

## Vague language to tighten

- `references/cohesion-rubric.md:111` — "Close inline (≤2 lines per finding) **or** substrate-note in the ledger" (the "or" is the B1 defect)
- `references/cohesion-rubric.md:119` — "when the user prefers documenting over inline closure" (re-introduces preference into the deterministic rule)
- `references/cohesion-rubric.md:113` — "unless the repair changes scope (new files, renamed concepts, added invariants) — then yes" (Approved + Medium row's re-validate column carries a conditional that's narrative, not derivable from `(verdict, highest-severity)`; consider a third axis or a separate disposition phrase)

## Recommended repairs (ranked)

1. **B1: Make the Approved + Low row deterministic.** Pick one default; treat the other as user override. Propagate to skill `Disposition derivation` examples and to the agent's "What you must not do" entry.
2. **B2: Reconcile verdict semantics with the disposition rule.** Either restate `Approved` to mean "implementable after the disposition action" or move `Approved + High` under `Issues Found`. Update ledger §"What this rewrite did not do" accordingly.
3. **B3: Pin the verdict → severity-floor mapping.** State explicitly that `Issues Found` requires `Blocker`. State this in the rubric's severity-vocabulary section, with forward citations from the agent verdict definitions.
4. **I1: Reconcile section heading "Blocking issues" with severity "Blocker"** in `references/templates/cohesion-review.md` via a one-line gloss.
5. **I2: Either land minimal override residue now or defer with a re-evaluation trigger.**

## Recommended next Cohesive skill

**Disposition:** Repair → re-validate

## What looked right

- Single canonical home for the disposition rule with three explicit citation surfaces (skill, agent, template). The contract/slot relationship at `references/templates/design-delta-ledger.md:13-15` and `references/templates/cohesion-review.md:13-15` is symmetric and reads cleanly from either entry point.
- The decision to keep the imperative outside the render template at `agents/spec-cohesion-reviewer.md:65-67` and `skills/validate-rewrite/SKILL.md:14-16` is correct per the style-guide-rot scar; the citation literal is absent from both render templates.
- §"Why this is a rule, not a menu" rationale at `references/cohesion-rubric.md:117` names the failure it retires and cites `output-voice.md` rule #5 — the kind of explicit anti-pattern preservation that makes the next contributor able to defend the rule against revision pressure.
- The ledger's §"Remaining ambiguity" entries (promotion deferral, validator pin deferral, gotcha deferral, override behavior) are the right shape: each names the deferred work, the trigger to re-evaluate, and the load-bearing defense in the meantime. This is the deferred-finding contract working as designed.
