# Rewrite Validation Review — validate-rewrite internal repair loop + path-prereq directive errors

**Verdict:** Issues Found

## Executive judgment

The internal repair loop is structurally well-specified — the new fourth transition shape, the three named loop exits, and the per-pass fresh-eyes property hold across `handoffs.md`, `skills.md`, and `validate-rewrite/SKILL.md`. The directive-error convention also lands cleanly: skill-shape.md §"Path prereqs use directive errors" carves the surface, `implement-cohesively` Hard constraint #1 implements it, the soft-prereqs gotcha narrows correctly, and `router.md`'s exception bullet stops claiming a non-existent canonical question. **One Blocker prevents Approved**: skill-shape.md §"Path prereqs use directive errors" (line 202) lists `validate-rewrite` *alongside* `implement-cohesively` as using directive errors for its delta-ledger path prereq, but `validate-rewrite/SKILL.md` Step 1 still uses the old "stop and ask" shape, and `validate_plugin.sh` Check 10b's `path_prereq_subskills` array silently omits `validate-rewrite`. The convention claims a two-skill pattern; the implementation is one-skill; the validator can't catch the gap. Two Medium drifts in commit-message contracts and one Medium scope-of-stall language compound but do not block.

## Delta at a glance

This rewrite is **Mixed**.

**Design-layer changes:**
- `docs/substrate/architecture/handoffs.md` — §"The three transition shapes" gains a fourth shape (internal repair loop); §"The chain" diagram updates the validate-rewrite ↔ rewrite-specs edge from public backward edge to internal loop; §"validate-rewrite ↔ rewrite-specs (Issues Found internal repair loop)" replaces the prior public-backward-edge contract with a loop contract (transition shape, per-pass artifact crossing, three loop exits including max-passes stall, fresh-eyes per pass, failure modes).
- `docs/substrate/architecture/skills.md` — `### validate-rewrite` Purpose, Owns, Does not own, Inputs, Outputs, and Why-this-shape sections updated to reflect the internal loop ownership; new `--max-passes=N` input; per-pass review filename convention; max-passes-stall as a third terminal verdict shape.
- `docs/substrate/conventions/skill-shape.md` — new §"Path prereqs use directive errors, not the canonical question" section under §"Canonical prereq-detection question" introducing the path-prereq vs. session-prereq distinction and the directive-error template.

**Implementation changes:**
- `skills/validate-rewrite/SKILL.md` — Hard constraints #1 and #2 gain "per pass" qualifiers; new Hard constraint #4 (the loop is internal, do not auto-pivot to brainstorm); §"What this skill produces" adds loop semantics and per-pass file naming; Process steps 3–5 rewritten as persist+branch / repair-loop / terminal-render; Acceptance criteria gain max-passes/no-auto-pivot guarantees; Red flags gain pass-contamination and auto-loop-past-ceiling; Composition adds the internal dispatch.
- `skills/rewrite-specs/SKILL.md` Hard constraint #1 — three-input-case enumeration collapses to "explicit dispatch (skip the question) | direct user-named direction | otherwise canonical question." Repair-loop dispatch from `validate-rewrite` named explicitly. Step 1b "Repair-pass mode" body unchanged; only the invocation path changes.
- `skills/implement-cohesively/SKILL.md` Hard constraint #1 — three-input-case enumeration retires entirely. Replaced with directive-error template per the new skill-shape convention. The canonical clarifying question retires for this skill — its prereq is a file path, not session state.
- `docs/substrate/gotchas/soft-prereqs.md` — §"Structured-artifact handoff is not this failure mode" retires; replaced with §"What this gotcha does not cover" pointing at handoffs.md for path-prereq contracts. Planned-test list updated: removes the two structured-handoff scenario tests; adds the implement-cohesively directive-error scenario test.
- `docs/substrate/matrices/router.md` §"Dispatch contract exceptions" — implement-cohesively row updated to clarify directive-error vs. canonical-question (router-level R016 question still applies at route classification).
- `scripts/validate_plugin.sh` — Check 10 split into 10 (discovery-prereq subskills require canonical question) and new 10b (path-prereq subskills require directive-error template plus an upstream `cohesive:` skill name).

## Blocking issues

### B1. validate-rewrite is named as a path-prereq subskill but its SKILL.md still uses "stop and ask"

- **Severity:** Blocker
- **Category:** Spec drift / Enforcement
- **Why it matters:** `skill-shape.md:202` lists the v0.1 directive-error subskills as `validate-rewrite (delta ledger path), implement-cohesively (validation review path + delta ledger path)`. But `validate-rewrite/SKILL.md:47` Step 1 still says "If any required input is missing, stop and ask. Do not invent inputs." — the old session-state shape, not a directive error. `validate_plugin.sh` Check 10b's `path_prereq_subskills=(implement-cohesively)` array omits `validate-rewrite`, so the lint that purports to enforce the new convention silently lets `validate-rewrite` keep the wrong shape. A future reader of `skill-shape.md` will believe the convention is two-skill and uniform; reading `validate-rewrite/SKILL.md` they'll see it isn't. This is the failure mode the convention exists to close (canonical question vs directive error confusion) reproduced inside the very rewrite that introduces the convention. Lens 13 (design-implementation agreement) fails on `validate-rewrite`.
- **Evidence:** `docs/substrate/conventions/skill-shape.md:202` lists `validate-rewrite (delta ledger path)` as a v0.1 directive-error subskill. `skills/validate-rewrite/SKILL.md:47` Process Step 1: `If any required input is missing, stop and ask. Do not invent inputs.` `scripts/validate_plugin.sh:228-230` `path_prereq_subskills=(implement-cohesively)`. `docs/substrate/gotchas/soft-prereqs.md:64-67` "Tests/checks" list updates only for `implement-cohesively`, not `validate-rewrite`.
- **Recommended fix:** Either (a) replace `validate-rewrite/SKILL.md` Step 1's "stop and ask" with a concrete directive-error template (`Missing design delta ledger for slug <slug>. Run cohesive:rewrite-specs first; expected output at docs/history/delta-ledgers/<date>-<slug>.md.`), add `validate-rewrite` to `validate_plugin.sh:228` `path_prereq_subskills`, and add the corresponding scenario test to `gotchas/soft-prereqs.md` "Tests/checks"; or (b) narrow `skill-shape.md:202` to only list `implement-cohesively` and drop the `validate-rewrite` claim there, with a note that `validate-rewrite`'s prereq is currently looser. Option (a) is the substrate-faithful fix.
- **Substrate artifact to add or update:** `skills/validate-rewrite/SKILL.md` Process Step 1 (directive-error template); `scripts/validate_plugin.sh` Check 10b (`path_prereq_subskills` array); `docs/substrate/gotchas/soft-prereqs.md` Tests/checks list.

## Important issues

### I1. Repair commit message contract drifts between handoffs.md and rewrite-specs/SKILL.md

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** `handoffs.md:84` says repair commits "cite the pass number and the closed finding IDs." But `rewrite-specs/SKILL.md:140-144` Step 6's commit template carries only `Approved direction:` and the ledger path — no pass number, no finding IDs. Step 1b notes the ledger's per-file entries cite finding IDs (`Closes B1`), but that's ledger content, not commit-message content. The handoff contract claim is unenforced; `git log --grep` for "pass-N" or finding IDs over a `design/<slug>` branch will not find what `handoffs.md` promises. The auditing surface the handoff contract names doesn't exist.
- **Evidence:** `docs/substrate/architecture/handoffs.md:84`: `Repair commits land on the same design/<slug> branch in pass order; commit messages cite the pass number and the closed finding IDs.` `skills/rewrite-specs/SKILL.md:140-144` commit template carries neither. `skills/rewrite-specs/SKILL.md:97` mentions the ledger §"Per-file changes" cites finding IDs, but that's the ledger, not the commit.
- **Recommended fix:** Add a repair-mode commit template to `rewrite-specs/SKILL.md` Step 1b (e.g., `design: repair pass-<N> — closes <findings>`) and reference it from Step 6. Or weaken the `handoffs.md` claim to match what Step 6 actually produces.
- **Substrate artifact to add or update:** `skills/rewrite-specs/SKILL.md` Step 1b or Step 6.

### I2. "Max-passes stall" verdict-shape language is inconsistent across surfaces

- **Severity:** Medium
- **Category:** Spec drift / Domain model
- **Why it matters:** Three surfaces describe the loop's max-passes terminal differently: `validate-rewrite/SKILL.md:10` ("a terminal verdict of **Approved**, **Design Incoherent**, or a **max-passes stall**" — implies stall is a third *verdict*); `skills.md:151` (verdict vocabulary stays {Approved, Issues Found, Design Incoherent}; "Issues Found only escapes the loop on max-passes stall" — stall is a *surfacing condition*, not a verdict); `handoffs.md:90` ("Max passes reached" is a *loop exit*, not a verdict). Three readers will form three models. Lens 14 (handoff contract consistency) is technically clean — there's no downstream Cohesive skill that gates on "max-passes stall" — but the SKILL.md frontmatter description still says `Returns Approved / Issues Found / Design Incoherent`, which `skills.md:151` matches and `SKILL.md:10` contradicts.
- **Evidence:** `skills/validate-rewrite/SKILL.md:10`, `:203` ("max-passes stall" framed as terminal verdict alongside Approved/Design Incoherent). `docs/substrate/architecture/skills.md:151` (max-passes stall as Issues-Found-surfacing condition; verdict vocabulary unchanged). `docs/substrate/architecture/handoffs.md:86-90` (three loop *exits*; verdict vocabulary unchanged). `skills/validate-rewrite/SKILL.md` frontmatter line 3: "Returns Approved / Issues Found / Design Incoherent."
- **Recommended fix:** Pick one model and propagate. Recommend the `handoffs.md` / `skills.md` framing: "max-passes stall is a *loop-exit shape* that surfaces the latest pass's `Issues Found` verdict with a stall banner." Update `validate-rewrite/SKILL.md:10` and Acceptance criteria line 203 to use that language; "terminal verdict" should remain {Approved, Issues Found, Design Incoherent}.
- **Substrate artifact to add or update:** `skills/validate-rewrite/SKILL.md` §"What this skill produces" and Acceptance criteria.

### I3. Loop dispatch protocol cited but unanchored

- **Severity:** Medium
- **Category:** Enforcement
- **Why it matters:** `handoffs.md:92` says the Skill-tool dispatch prompt to `rewrite-specs` "states this constraint explicitly per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/dispatch-protocol.md`." That convention file is not in the rewrite scope and was not listed for review. If it doesn't exist (or doesn't pin the loop's dispatch-prompt shape), the contract claim is decorative. `validate-rewrite/SKILL.md:98` describes the dispatch but does not reference `dispatch-protocol.md`. A reviewer reading the SKILL.md alone cannot verify the convention is anchored.
- **Evidence:** `docs/substrate/architecture/handoffs.md:92` cites `docs/substrate/conventions/dispatch-protocol.md`. `skills/validate-rewrite/SKILL.md:94-99` describes the dispatch with no cross-reference to that convention.
- **Recommended fix:** Either confirm `dispatch-protocol.md` exists and pins the loop dispatch shape (and cite it from `validate-rewrite/SKILL.md` Step 4), or inline the constraint into `validate-rewrite/SKILL.md` Step 4 ("the dispatch prompt names the just-persisted pass-N review path, instructs repair-mode operation, and states the must-not-re-derive-direction constraint").
- **Substrate artifact to add or update:** `skills/validate-rewrite/SKILL.md` Step 4, or `docs/substrate/conventions/dispatch-protocol.md` (if missing).

## Recommended repairs (ranked)

1. Close B1 by adding the directive-error template to `validate-rewrite/SKILL.md` Step 1, adding `validate-rewrite` to `validate_plugin.sh` Check 10b, and adding the matching scenario test to `soft-prereqs.md`. This is the load-bearing repair — without it, the convention's own claim is wrong.
2. Close I2 by reconciling "max-passes stall" language across `validate-rewrite/SKILL.md`, `skills.md`, and `handoffs.md` (recommend the loop-exit framing).
3. Close I1 by aligning the repair-mode commit message contract.
4. Close I3 by anchoring or inlining the dispatch-protocol citation.

## What looked right

- The fourth transition shape in `handoffs.md` §"The three transition shapes" is structurally distinct from off-chain re-entry — invisible-to-user as a chain edge, dispatched within Process, three named exits. That distinction is what makes the loop legible.
- The per-handoff contract for the loop names all three exits and ties each to its downstream rendering (Approved → next handoff section, Design Incoherent → off-chain re-entry section, Max passes reached → user-direction surface). The fresh-eyes-per-pass clarification at `handoffs.md:94` closes a real ambiguity.
- The path-prereq-vs-session-prereq cut in `skill-shape.md` §"Path prereqs use directive errors" is the right substrate generalization; it eliminates the recurring O(N×M) Hard-constraint-#1 patches that motivated the rewrite.
- `gotchas/soft-prereqs.md` §"What this gotcha does not cover" delegates path-prereq guidance to `handoffs.md` cleanly, with the failure-mode reasoning preserved.

---

**Disposition:** Repair → re-validate
