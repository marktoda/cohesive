# Rewrite Validation Review — Cut, Anchor, Pin (pass 4, post repair pass 3)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-04
**Subject:** post-pass-3 substrate-vs-implementation refinement
**Design delta ledger:** [`../delta-ledgers/2026-05-04-cut-anchor-pin.md`](../delta-ledgers/2026-05-04-cut-anchor-pin.md)
**Prior validations:** [pass 1](2026-05-04-cut-anchor-pin-rewrite-validation.md)

**Status:** Issues Found

## Executive judgment

A future contributor reading these docs can implement the rewrite. The contributor-vs-user-facing axis introduced in repair pass 3 is genuinely sharper than the prior "claims about itself" framing, and the "who reads it, when?" test is a usable rule of thumb. The two gotchas, the new invariant, and the worked transcript form a coherent triangle. The single biggest gap is that the move-and-move-back left two demonstrable cross-doc inconsistencies — one broken intra-doc link, one stale `references/` cross-reference path — exactly the kind of artifact the rewrite was trying to eliminate. These should be fixed in the same pass to avoid teaching future contributors the wrong path.

## Blocking issues

### B1. Broken link in `PLUGIN_ROOT_PATHS.md` to the moved-back `output-voice.md`

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md:9` links `references/output-voice.md` as `[references/output-voice.md](../designs/output-voice.md)`. After repair pass 3, `output-voice.md` lives at `references/output-voice.md`; the relative target `../designs/output-voice.md` resolves to `docs/substrate/designs/output-voice.md`, which does not exist. A reader following the link from the canonical invariant doc lands nowhere. This is the second-most-trafficked invariant doc in the repo and the one a contributor reads first when making a path-discipline change; a dead link there contradicts the rewrite's whole "the move-and-move-back is now coherent" claim.
- **Substrate artifact:** Spec (the invariant doc).
- **Suggested repair:** Change target to `../../../references/output-voice.md` or use the canonical `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` form.

## Important issues

### I1. Bare-relative `output-voice.md` links from inside `docs/substrate/designs/`

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** `docs/substrate/designs/skill-conventions.md:5`, `:71`, `:83` link `output-voice.md` as a bare relative target — which from `docs/substrate/designs/` resolves to `docs/substrate/designs/output-voice.md`, not the actual `references/output-voice.md`. Same pattern probable elsewhere in the same dir. This is the exact failure mode `style-guide-rot.md` warns about — the citation is the load-bearing line, but the prose around it links somewhere wrong, so a contributor following the prose link finds nothing.
- **Substrate artifact:** Spec.
- **Suggested repair:** Replace bare `output-voice.md` link targets with `../../../references/output-voice.md` (or the `${CLAUDE_PLUGIN_ROOT}/...` form) everywhere they appear inside `docs/substrate/designs/*.md`.

### I2. Convention-pin enumeration inconsistent across three docs

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** AGENTS.md, `skill-conventions.md`, and `PLUGIN_ROOT_PATHS.md` each enumerate the validator's convention-pin set, and the three lists disagree. AGENTS.md includes voice-citation; PLUGIN_ROOT_PATHS.md omits it; skill-conventions.md adds the negative-trigger check. A future contributor cannot tell which is canonical.
- **Substrate artifact:** Spec.
- **Suggested repair:** Pick one canonical enumeration (likely PLUGIN_ROOT_PATHS.md, since it lives next to the validator) and have the others link to it instead of restating. The voice-citation grep is currently planned-not-implemented, so its inclusion in AGENTS.md/skill-conventions.md without inclusion in PLUGIN_ROOT_PATHS.md may be the correct asymmetry — but it must be stated as such, not left ambiguous.

### I3. README/ARCHITECTURE don't enumerate gotchas

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** README.md:130–138 enumerates the 6 design docs and the 2 invariants by name but leaves `gotchas/` unenumerated. ARCHITECTURE.md does the same. The four gotchas (`soft-prereqs`, `discovery-vs-superpowers`, `wordy-output`, `style-guide-rot`) are normatively significant — `wordy-output` and `style-guide-rot` are new and load-bearing for this rewrite — but neither source-of-truth doc names them.
- **Substrate artifact:** Spec.
- **Suggested repair:** Either enumerate the four gotchas in README "What's in the box" (consistent with the invariant treatment) or explicitly note "see `docs/substrate/gotchas/` for the current list."

### I4. AGENTS.md "When you are about to..." missing the Output-format authoring bullet

- **Severity:** Medium
- **Category:** Spec drift / Locality
- **Why it matters:** ARCHITECTURE.md "Where to look first" has the row "Author or revise an Output format block (or any chat-rendered output) → references/output-voice.md and the worked transcript." AGENTS.md "When you are about to..." doesn't have the equivalent bullet. The two source-of-truth docs disagree on what counts as a top-level contributor scenario.
- **Substrate artifact:** Spec.
- **Suggested repair:** Add a `When you are about to... Author or revise an Output format block` bullet to AGENTS.md pointing at `references/output-voice.md` and the worked transcript.

## Substrate gaps

- "Captured transcripts (queued)" task in `output-voice-worked-example.md:125` is not filed as substrate — no entry in any matrix, gotcha, or ARCHITECTURE risk tracks "the canonical voice transcript is authored, not captured."
- The "who reads it, when?" test in AGENTS.md has no worked example. Edge cases (templates, scripts, the validator) would benefit from one or two cited classifications.

## Locality concerns

The seam between `output-voice.md` (implementation) and its companion gotchas (substrate, on the contributor side) is correctly placed but undocumented. A contributor changing voice rules must update files on both sides of the line in the same pass; that coupling is real and probably correct, but stated nowhere.

## Future-fit concerns

The "Why voice-citation is convention-with-grep, not a named invariant" section gives clear promotion criteria coherent with `style-guide-rot.md`. Cross-skill question budget acceptably deferred.

## Enforcement concerns

`VERDICT_BEFORE_EVIDENCE.md` and `wordy-output.md` correctly flag enforcement as planned. The convention-pin enumeration ambiguity (I2) is the only enforcement-related concern.

## Vague language to tighten

None of normative weight. `wordy-output.md:71` "earns a doc" is fine in a Notes section.

## Recommended repairs (ranked)

1. Fix the broken `../designs/output-voice.md` link in `PLUGIN_ROOT_PATHS.md:9` (B1).
2. Sweep bare `output-voice.md` link targets inside `docs/substrate/designs/*.md` to point at `../../../references/output-voice.md` (I1).
3. Pick one canonical enumeration of validator convention-pins and have the other two docs link to it (I2).
4. Add the missing AGENTS.md "When you are about to..." Output-format authoring bullet (I4).
5. Enumerate the four gotchas in README "What's in the box" or note explicitly that `gotchas/` is non-enumerated (I3).

## What looked right

- The "who reads it, when?" test in AGENTS.md is the rewrite's strongest single move. It produces a usable classification without requiring the conversation context that prompted the cut.
- The two new gotchas genuinely complement each other: one names the symptom, the other names the trap the proposed fix must avoid.
- `VERDICT_BEFORE_EVIDENCE.md` enumerates the three-line layout explicitly (title, citation, verdict) — testable spec a grep can later pin without ambiguity.
- The reviewer-output-shape matrix's legend cleanly distinguishes "pending" from "broken."
- The deliberate non-promotion of voice-citation to invariant shows the "promotion is deliberate" principle being applied — a calibration moment in a rewrite that could easily have over-promoted.

### Recommended next Cohesive skill

**Issues Found** — `cohesive:rewrite-specs` — repair pass 4 in the same worktree: fix B1 (broken link), sweep I1 (bare-relative output-voice.md targets), and address I2/I3/I4 (enumeration consistency). Then re-run `cohesive:validate-rewrite`.
