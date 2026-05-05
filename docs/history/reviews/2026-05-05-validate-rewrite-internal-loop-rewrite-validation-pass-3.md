# Rewrite Validation Review — validate-rewrite internal repair loop + path-prereq directive errors

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** /home/toda/dev/cohesive/.worktrees/cohesive-validate-rewrite-internal-loop/docs/history/delta-ledgers/2026-05-05-validate-rewrite-internal-loop.md and the nine rewritten files it covers (post repair pass 2).

**Verdict:** Approved

## Executive judgment

The rewrite makes the auto-typing complaint structurally disappear and collapses the recurring O(N×M) "structured-input enumeration" patches into a clean two-shape distinction (session-prereq → canonical question; path-prereq → directive error). The loop contract is locally legible across handoffs.md, skills.md, and the two SKILL.md bodies; the three exits (Approved / Design Incoherent / max-passes stall) are named identically everywhere; verdict vocabulary stays {Approved, Issues Found, Design Incoherent} and the stall is consistently framed as a loop-exit shape, not a fourth verdict. A future contributor can read these specs and implement the loop without the original conversation in their head. Two Medium issues remain: the validate-rewrite Output format render template uses a 3-field finding shape that disagrees with the canonical 6-field reviewer-agent shape it is supposedly surfacing, and the skills.md Bootstrap status table was not updated to reflect that this rewrite *is* a forward rewrite of `### validate-rewrite` and thus should promote that row from `inherited` to `validated`.

## Delta at a glance

This rewrite is **Mixed**.

**Design-layer changes:**
- `docs/substrate/architecture/handoffs.md` — §"The three transition shapes" gains a fourth shape (internal repair loop); §"The chain" diagram updates the validate-rewrite ↔ rewrite-specs edge from public backward edge to internal loop; §"validate-rewrite ↔ rewrite-specs (Issues Found internal repair loop)" replaces the prior public-backward-edge contract with a loop contract (transition shape, per-pass artifact crossing, three loop exits including max-passes stall, fresh-eyes per pass, failure modes).
- `docs/substrate/architecture/skills.md` — `### validate-rewrite` Purpose, Owns, Does not own, Inputs, Outputs, and Why-this-shape sections updated to reflect the internal loop ownership; new `--max-passes=N` input; per-pass review filename convention; max-passes-stall as a third terminal verdict shape.
- `docs/substrate/conventions/skill-shape.md` — new §"Path prereqs use directive errors, not the canonical question" section under §"Canonical prereq-detection question" introducing the path-prereq vs. session-prereq distinction and the directive-error template.

**Implementation changes:** see ledger §"Delta at a glance" for the seven implementation-layer entries (validate-rewrite/SKILL.md, rewrite-specs/SKILL.md, implement-cohesively/SKILL.md, soft-prereqs.md, router.md, validate_plugin.sh).

## Blocking issues

_None._

## Important issues

### I1. Output format render template uses 3-field finding shape; agent template uses 6-field

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** validate-rewrite's §"What this skill produces" promises the chat output is "the agent's report, surfaced." The agent (`spec-cohesion-reviewer`) renders findings in the canonical 6-field shape (Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact) per `references/templates/cohesion-review.md` and `docs/substrate/conventions/reviewer-agent-shape.md` §"Output format conventions". But the validate-rewrite SKILL.md Output format render template instructs a 3-field shape (Risk / Substrate artifact / Suggested repair). A future contributor editing the SKILL template would either (a) reproduce the 3-field shape and break agent-output parity, or (b) silently ignore the template because it doesn't match what the agent produces. Either way, the template is no longer a faithful render slot.
- **Evidence:** `skills/validate-rewrite/SKILL.md` Output format `### B1.` block under `## Blocking issues`; compare to `references/templates/cohesion-review.md` §"Blocking issues" and `agents/spec-cohesion-reviewer.md` §"Issue format (canonical six-field shape)".
- **Recommended fix:** Replace the 3-field block in the SKILL.md Output format with the canonical 6-field shape (or replace it with a one-line `(see references/templates/cohesion-review.md §"Blocking issues" for the canonical six-field shape)` pointer). The skill-shape.md §"Output format conventions" rule "the chat render is a faithful subset of the persisted file" means the SKILL render template must match the persisted reviewer template.
- **Substrate artifact to add or update:** spec (the SKILL.md Output format block).

### I2. skills.md Bootstrap status row for `validate-rewrite` not promoted to `validated`

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** `docs/substrate/architecture/skills.md` §"Bootstrap status" specifies: a section earns `validated` status when "a `cohesive:rewrite-specs` pass on that skill's purpose, ownership, or seams has run *with the design layer as prior substrate* — confirming that the skills.md claim and the SKILL.md body agree under fresh-eyes review." The footnote: "When a section earns validated status, update the row in the same delta ledger that triggered the validation." This rewrite *is* such a pass on `### validate-rewrite` (Purpose, Owns, Inputs, Outputs all changed); the row is still marked `inherited` and the ledger does not record a promotion. Future readers will think the section is still untested; a subsequent forward rewrite will receive the inherited-section warning treatment from `spec-cohesion-reviewer` even though it has now been validated.
- **Evidence:** `docs/substrate/architecture/skills.md` Bootstrap status row for `validate-rewrite` (`| validate-rewrite | inherited | not yet validated; verdict vocabulary verified verbatim during repair pass 1 (B2) |`); compare to the validation-promotion rule in the same section. Ledger §"Per-file changes" makes no mention of skills.md Bootstrap status.
- **Recommended fix:** Update the row to `**validated**` with a note like "validated by the 2026-05-05 internal-loop refactor; spec-cohesion-reviewer lens 13 confirmed parity through repair pass 2." Add a one-line entry under ledger §"Per-file changes" recording the promotion.
- **Substrate artifact to add or update:** spec (the Bootstrap status table) + delta ledger entry.

## Substrate gaps

- The auditing surface that `handoffs.md` §"validate-rewrite ↔ rewrite-specs" promises (`git log --grep "pass-"` over `design/<slug>` yields the per-handoff repair sequence) is satisfied by the `rewrite-specs` Step 6 template literal `pass-<N>` — but no test or check pins this. A future drift in the commit subject (e.g., `pass <N>` without the dash) silently breaks the audit. Worth a v0.1 deferred semantic-linter spec or a `validate_plugin.sh` future check.
- No regression test pins the loop's pass-isolation property (Hard constraint #2 "the pass-N reviewer is dispatched with paths only, never with the pass-(N-1) review as context"). Currently enforced by reviewer memory and the dispatch protocol's prose. The acid test #1 in the ledger is at the user-visible level; the structural property could merit a planned scenario test in `gotchas/soft-prereqs.md`-style enumeration.

## Locality concerns

- The directive-error template now lives canonically in `skill-shape.md` §"Path prereqs use directive errors", with citing pointers in `soft-prereqs.md`, `validate-rewrite/SKILL.md` Step 1, `implement-cohesively/SKILL.md` Hard constraint #1, and `router.md` cell R016. The template literal itself is duplicated across three SKILL.md bodies (validate-rewrite, implement-cohesively × two error variants). Acceptable: the literals are short and end-state-prescriptive, not shared logic. The seam to repair if a literal must change is the design layer + each citing SKILL.md — manageable, and the negative grep at Check 10b ratifies the convention.

## Future-fit concerns

- Ledger §"Open follow-ups (not in scope)" correctly fences the deferred items (status skill, default chat-only persistence, same-finding-N-passes detection). They are non-normative; nothing leaks into the loop's promised semantics.

## Enforcement concerns

- All four named invariants unchanged in content; ledger correctly records this. The new convention (path-prereq → directive error) is enforced by `validate_plugin.sh` Check 10b with positive (a)/(b) and negative (c)/(d) greps — which, per repair pass 2 B1, structurally pin the regression class. Convention-with-grep is consistent with `output-voice.md` §"Why the voice imperative is convention-with-grep, not a named invariant"; promotion criteria are not yet met.

## Behavior knowable outside implementation?

Yes. A future contributor reading only handoffs.md §"validate-rewrite ↔ rewrite-specs (Issues Found internal repair loop)" + validate-rewrite/SKILL.md Step 4 + rewrite-specs/SKILL.md Step 1b can reproduce the loop's behavior: pass count, three exits, per-pass artifact persistence, fresh-eyes per pass, must-not-re-derive constraints, commit template. The directive-error pattern is similarly reproducible from skill-shape.md §"Path prereqs" + Hard constraint #1 of either path-prereq subskill. No load-bearing behavior is hidden in implementation.

## Vague language to tighten

- `skills/validate-rewrite/SKILL.md` Red flags — "Calibration matters." Acceptable as a one-clause pointer rather than vague hedge; non-normative.
- `docs/substrate/architecture/handoffs.md` failure-mode bullet — "consumes turns indefinitely on a structurally unsolvable design" — colloquial but precise; no fix needed.

No "should/may/TBD/we will" leakage in normative sections of any rewritten file.

## Recommended repairs (ranked)

1. Replace the 3-field finding block in `skills/validate-rewrite/SKILL.md` Output format with the canonical 6-field shape (or a citing pointer). [I1]
2. Promote `### validate-rewrite` row in `docs/substrate/architecture/skills.md` Bootstrap status table to `validated`; add a one-line ledger entry under §"Per-file changes". [I2]

## What looked right

- The fourth transition shape ("Internal repair loop") in `handoffs.md` §"The three transition shapes" is genuinely structurally distinct from off-chain re-entry, and the per-handoff contract names all three exits with their downstream consequences. A future skill that wants the same internal-loop shape has a named template to copy.
- The repair-pass commit template in `rewrite-specs/SKILL.md` Step 6 + `Source review:` body line + `Pass:` / `Closes:` body lines makes `git log --grep "pass-"` a real audit surface for the per-pass progression — exactly what the loop contract promises.
- The Check 10b negative greps for both the canonical-question literal *and* the legacy "stop and ask" phrasing structurally pin the regression class that pass-1 B1 surfaced. Convention-with-grep, with the negative half doing as much work as the positive half.
- The `architecture/skills.md` §"Why `validate-rewrite` is separate from `rewrite-specs`" sentence about the loop preserving the seam ("each pass dispatches a fresh `spec-cohesion-reviewer` Task subprocess with paths-only input") closes the locality question a future reader of the loop diagram would have hit.

---

**Disposition:** Close in same worktree → merge

(Per the disposition rule in `references/cohesion-rubric.md` §"Disposition rule for validation-review findings", row `Approved + Medium`. Re-validation is not required; the two repairs are textual fixes within existing files, closed in the worktree before merge.)
