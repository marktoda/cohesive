# Replace the delta ledger with git diff

**Status:** Brainstorm — design accepted, not yet implemented
**Date:** 2026-05-27
**Author:** Mark + Claude (brainstorm)

## Motivation

Early-user feedback (PR #544 and the broader pattern across PRs #474, #465, #490, #504) surfaced three structural failure modes in the current cohesive flow:

1. **`validate-rewrite` has no convergence rule.** Five-pass repair loops with no escalating bar; pass-N reviewers re-raise issues prior passes closed.
2. **The router routes on lexical signals, not change shape.** Additive substrate-touching changes get treated like substrate-shaping changes — full brainstorm → rewrite → validate → implement for an enum extension.
3. **`docs/history/` is write-only memory in practice.** Brainstorms, delta-ledgers, reviews accumulate in consumer repos with zero observed downstream consumption.

This proposal addresses the load-bearing structural cause underneath several of those symptoms: **the delta ledger is a parallel representation of information git already carries.** Removing it tightens the substrate-shape→implementation seam, removes a maintenance artifact, and makes the system's own slogan — *"go from one cohesive design state to another; the diff is the things to build"* — literally true.

Two related changes (router off-ramp; convergence rule) are described as future addons in §6.

## Lens

The unifying principle: **the artifact is the source of truth, not the description of the artifact.**

The delta ledger today *describes* what changed: Files-rewritten paths, Conceptual-change rows, Named-invariants-touched, Tests-proposed, plus a verbatim-quoted Delta-at-a-glance preamble. Every category is either information git already records (file paths) or information that can be derived by a reviewer agent reading the diff (which invariants got touched, what categorization fits). The ledger adds no information; it adds a parallel structure that must be kept in sync with the underlying docs.

When two parallel representations of the same fact exist, the failure mode is drift between them — which is exactly the failure the ledger's own "Delta at a glance preamble drift" Blocking-issue category is designed to catch. The cohesive flow is paying maintenance cost to protect against drift in an artifact whose only job is to describe another artifact.

The structural fix is to collapse the parallel structure. Let the docs themselves (and git) be the substrate.

## Architecture — before and after

### Before

```
┌─────────────────────┐
│  brainstorm-design  │ produces direction + (optional) persisted brainstorm
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│   rewrite-specs     │ produces:
│                     │   (a) doc commits on design/<slug>
│                     │   (b) delta-ledger at docs/cohesive/delta-ledgers/...
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│  validate-rewrite   │ reads (b) preamble + the rewritten docs
│                     │ dispatches spec-cohesion-reviewer with paths to (b) + docs
│                     │ repair loop: rewrite-specs cites finding IDs from (b)
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ implement-cohesively│ reads (b), enumerates stable IDs, composes intent paragraph
│                     │ dispatches writing-plans + executing-plans
│                     │ end-of-run: delta-coverage-reviewer maps (b) entries to diff hunks
└─────────────────────┘
```

### After

```
┌─────────────────────┐
│  brainstorm-design  │ produces direction + (optional) persisted brainstorm
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│   rewrite-specs     │ produces:
│                     │   doc commits on design/<slug>
│                     │   (no separate ledger artifact)
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│  validate-rewrite   │ computes git diff $(merge-base main HEAD)..HEAD
│                     │ dispatches spec-cohesion-reviewer with paths to docs + diff
│                     │ on Approved: writes Rewrite-tip SHA to review file
│                     │ repair loop: rewrite-specs cites finding IDs from review file
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ implement-cohesively│ reads Rewrite-tip SHA from review file
│                     │ spec-diff = merge-base(main, SHA)..SHA   (stable)
│                     │ hands diff to writing-plans as the intent
│                     │ end-of-run: delta-coverage-reviewer compares
│                     │   spec-diff vs impl-diff (SHA..HEAD)
└─────────────────────┘
```

The substrate has one fewer kind of persisted artifact. Reviews remain (they are the audit trail). Doc files remain (they ARE the substrate). The ledger — which sat between them describing them — collapses out.

## Per-skill changes

### §1 — `rewrite-specs`

**Step 5 (Produce the design delta ledger): DELETE.**

**Step 6 (Commit the rewrite):** simplify commit-message templates.

Forward rewrite:
```
design: rewrite specs for <topic>

Approved direction: <option name>
Classification: <Pure implementation | Design | Mixed>
```
(Drop the `See: docs/cohesive/delta-ledgers/...` line; add the `Classification:` trailer so it persists in git history instead of the ledger preamble.)

Repair rewrite (unchanged shape; just drops the ledger pointer):
```
design: repair pass-<N> — closes <finding IDs>

Pass: <N>
Closes: <comma-separated finding IDs>
Source review: docs/cohesive/reviews/<...>-rewrite-validation[-pass-<N-1>].md
```

**Step 1a (Classification):** still human-authored (Pure / Design / Mixed). Persisted via the `Classification:` trailer in the rewrite commit message body and surfaced in the rewrite-specs chat trailer. The validate-rewrite reviewer reads both the commit-message classification AND the diff, and raises an issue if they disagree (e.g., classified Pure-implementation but the diff touches a seam doc). This makes the classification cross-checkable rather than purely declarative.

**Step 4 (Update substrate map):** unchanged.

**Output format:** the `### Design delta ledger` section disappears. The chat trailer collapses to:

```md
# Spec Rewrite Complete — <topic>

**Worktree:** `.worktrees/cohesive-<slug>` on `design/<slug>`
**Approved direction:** <option name>
**Classification:** <Pure implementation | Design | Mixed>

### Files rewritten
- ...
### Files added
- ...
### Files removed / deprecated
- ...

### Remaining ambiguity
- ...

### Next
Fresh-eyes review on `design/<slug>`. *(`cohesive:validate-rewrite`.)*
```

**Substrate removed:**

- `references/templates/design-delta-ledger.md` (deleted)
- `scripts/validate_plugin.sh` checks for `## Delta at a glance` preamble presence (deleted)
- Anti-patterns about ledger-preamble drift, ledger-skipping, preamble-vs-body sync (deleted)
- "Step 0: Resolve the artifact directory for delta-ledgers/" (deleted)

### §2 — `validate-rewrite`

**Required input contract:** the prereq becomes **branch name** (typically `design/<slug>`), not ledger path. The skill computes the spec-diff itself via `git diff $(git merge-base main HEAD)..HEAD`.

**On Approved verdict — capture the rewrite-tip SHA.** When the terminal verdict is Approved, the persisted review file gets a header line near the top:

```md
**Rewrite-tip:** <full SHA of HEAD at Approved time>
```

This SHA is the load-bearing primitive for downstream consumers: `implement-cohesively` reads it as the boundary between "the rewrite" and "anything after." Persisting it in the review file (rather than only in chat) makes the boundary stable across re-invocations, interrupted runs, and Coverage Drift retries. The validate-rewrite skill captures `git rev-parse HEAD` at the moment Approved is rendered and writes it as part of the Step 5 terminal render.

**Missing-input directive error** changes to:
```
Missing rewrite branch for slug `<slug>`. Run cohesive:rewrite-specs first;
expected branch design/<slug> with rewrite commits.
```
(Drop the "expected output at docs/cohesive/delta-ledgers/..." form.)

**Step 2 (dispatch spec-cohesion-reviewer):** the dispatch prompt names:
- Branch name and base SHA
- Rewritten spec paths (derived from the diff's changed paths)
- A spec-diff snapshot at a tmp path (e.g., `.cohesive/tmp/<slug>-spec-diff.patch`) — the dispatching skill writes the diff to disk so the reviewer reads it as a file
- Substrate discovery report path (optional)

The reviewer reads the diff to understand what changed and reads the spec files at HEAD to judge whether the new design is coherent. Fresh-eyes property is preserved by Task subprocess isolation; the diff is a *file* the reviewer reads, not a conversation-context summary.

**Render shape:** the `## Delta at a glance` body block is no longer a verbatim quote from a ledger preamble — it becomes an auto-generated 5-bullet summary derived from the diff:
- N files rewritten / added / removed
- K named invariants touched (greppable as `invariant:` headings in the diff)
- M behavior matrix rows added / changed
- J gotchas added or retired
- Classification (inferred from the file paths touched)

Render-only — never persisted as a parallel artifact.

**Repair loop:** unchanged in shape. Pass-N reviewer reads the latest diff at dispatch time (which now includes pass-(N-1)'s repair commits). The fresh-eyes property holds per pass per Hard constraint #1.

**Substrate removed:**

- "ledger preamble drift" Blocking-issue category in `references/templates/cohesion-review.md`
- ~3 cross-references to `${CLAUDE_PLUGIN_ROOT}/references/templates/design-delta-ledger.md`

### §3 — `implement-cohesively`

**Required input contract:** **branch name + validation review path** (drop ledger path).

**Step 0 (Resolve inputs and confirm prereqs):** parse the validation review file and extract the `**Rewrite-tip:**` SHA. Verify the SHA exists in branch history via `git cat-file -e <SHA>`; on missing (e.g., the branch was rebased after Approved), halt with a directive error:

```
Rewrite tip SHA `<X>` not found on branch `design/<slug>`.
The branch was likely rebased or rewritten after validate-rewrite Approved.
Re-run cohesive:validate-rewrite to capture a fresh rewrite-tip SHA.
```

**Step 1 (Compose the intent paragraph and dispatch writing-plans):** becomes "Capture the spec diff using the persisted rewrite-tip SHA."

```
1. REWRITE_TIP=<SHA parsed from validation review file at Step 0>
2. git diff $(git merge-base main $REWRITE_TIP)..$REWRITE_TIP > .cohesive/tmp/<slug>-spec-diff.patch
3. Inspect diff size; surface budget gate if large (threshold: re-calibrate
   from "non-Deferred entry count" to changed-line-count, e.g., 1000 LOC).
4. Compose intent paragraph:

   Make this spec diff true in code: .cohesive/tmp/<slug>-spec-diff.patch.
   Constraints: <named invariants the docs cite>.
   Acceptance: cohesive:implement-cohesively dispatches delta-coverage-reviewer
   and cohesive:review-diff at end-of-run; both must Pass.

5. Skill-tool dispatch superpowers:writing-plans.
```

The spec-diff is now anchored to a stable SHA captured at validate-rewrite Approved time, not to "HEAD at implement-cohesively invocation time." This makes the snapshot stable across:

- **Coverage Drift retries.** Re-invoking implement-cohesively after a Drift verdict reads the same SHA, produces the same spec-diff. Implementation-diff = `$REWRITE_TIP..HEAD` captures original + repair commits.
- **Interrupted runs.** SHA is persistent state in the review file; re-invocation reads it.
- **Mixed classification.** The SHA is the boundary regardless of whether the rewrite touched docs only or docs + code.

**Delta-size budget gate:** threshold re-calibrates from non-Deferred-entry-count to changed-lines-count (or hunk-count). Initial default: 1000 changed lines (tunable). Below threshold: silent. Above: pause for user confirmation.

**Step 2 (Execute the plan):** unchanged.

**Step 3 (End-of-run dual reviewer dispatch):**
- `delta-coverage-reviewer` dispatch prompt names: **spec-diff path** (captured at Step 1) + **branch name** + **rewrite-tip SHA** (so the reviewer can compute implementation-diff = `$REWRITE_TIP..HEAD`).
- `cohesive:review-diff` unchanged.

**Step 3.5 (Post-implementation cleanup):** removes the per-pass plan at `docs/cohesive/plans/<slug>.md` AND the spec-diff snapshot at `.cohesive/tmp/<slug>-spec-diff.patch`. No ledger to clean (it never existed). The cleanup commit body lists the removed paths verbatim, same as today.

**Substrate removed:**

- Stable-ID enumeration logic in Hard constraint #3 (replaced with "spec-diff snapshot covers the rewrite")
- Anti-patterns about ledger-entry omission, stable-ID accuracy, deferred-entry handling (deleted)
- The named invariant `IMPLEMENTATION_PLAN_COVERS_DELTA` renames to `IMPLEMENTATION_COVERS_SPEC_DIFF`, with rules rewritten against the diff-vs-diff model

### §4 — `delta-coverage-reviewer`

**Input contract:** **spec-diff path + implementation-branch name + rewrite-tip SHA** (was: ledger path + plan path + whole-branch diff).

**Job:** for each hunk in the spec-diff that promises behavior or structure (e.g., a new behavior matrix row, a new invariant rule, a renamed concept), find a corresponding hunk in the implementation-diff (`git diff <rewrite-tip-SHA>..HEAD`) that delivers it.

**Verdict vocab unchanged:** Covered / Drift / Incomplete.

**Substrate replaced:** the reviewer becomes a diff-vs-diff comparison agent rather than a ledger-vs-diff mapping agent. Cleaner mental model.

## Deferred items

Per the brainstorm conclusion: deferred items live in the rewritten docs themselves as `## Future direction (non-normative)` sections (already supported by `rewrite-specs` Hard constraint #5). No separate persisted "deferred list."

## Migration shape

Clean cut (no consumers outside this plugin, no users locked in).

**One implementation pass touches:**
- `skills/rewrite-specs/SKILL.md` (Step 5 deleted; Step 6 commit template simplified; output format collapsed)
- `skills/validate-rewrite/SKILL.md` (Step 1 input contract changed; Step 2 dispatch prompt changed; ledger-preamble Blocking-issue category removed)
- `skills/implement-cohesively/SKILL.md` (Step 1 logic rewritten; intent paragraph format changed; Step 3 reviewer dispatch input changed; Step 3.5 cleanup list updated)
- `agents/delta-coverage-reviewer.md` (input contract + job description rewritten)
- `references/templates/design-delta-ledger.md` (deleted)
- `references/templates/cohesion-review.md` (ledger-preamble-drift category removed)
- `references/named-invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` (renamed + rewritten as `IMPLEMENTATION_COVERS_SPEC_DIFF`)
- `scripts/validate_plugin.sh` (delta-ledger preamble grep removed)
- `skills/cohesively/SKILL.md` (dispatch-prompt-contract table updated: implement route prereqs change from "delta ledger path" to "branch name + review path")
- `README.md` and `CLAUDE.md` (any references to "design delta ledger" updated to "spec diff" or removed)

**Tests/checks to add:**
- `scripts/validate_plugin.sh` check: no remaining references to `delta-ledgers/` or `design-delta-ledger.md` in any skill body
- `scripts/validate_plugin.sh` check: every spec-cohesion-reviewer dispatch prompt names a `.patch` file as input
- `scripts/validate_plugin.sh` check: every persisted validate-rewrite Approved review file carries a `**Rewrite-tip:**` SHA header (greppable)
- Self-review pass on the proposal docs themselves (this artifact + the rewritten skill bodies) catching missed references

## Future addons (L2, L3 — not part of this design)

### L2 — Router off-ramp for extension changes

Add a forced-choice question at the `cohesively` router:

> "Does this change introduce a new invariant / seam / kind family, or extend an existing one?"

Two routes after the answer:
- **Extend:** light path = `rewrite-specs` (single-file mode, no validate-rewrite repair loop) → `writing-plans` → `executing-plans` + lightweight cross-mirror sweep reviewer
- **Shape:** existing heavy path = `brainstorm-design` → `rewrite-specs` → `validate-rewrite` → `implement-cohesively`

L1 makes L2 lighter because the heavy path itself becomes lighter. Best landed after L1.

### L3 — Convergence rule for `validate-rewrite`

Three changes to `validate-rewrite`:

1. **Pass budget declared at start** (default 2). Pass count visible per-pass.
2. **Escalating reviewer bar**, encoded in dispatch prompt:
   - pass 1: any cohesion issue
   - pass 2: design-level only; defer prose nits
   - pass 3+: substrate-corrupting blockers only
3. **Prior-pass closed findings forwarded** to next-pass reviewer as "Do not re-raise unless closure rationale is wrong" context — fresh-eyes is about objectivity, not amnesia.
4. **Marginal-value heuristic:** if pass N closes K and surfaces ≤ K/2 new issues, auto-converge with "Approved with residual" verdict.

L3 is orthogonal to L1 — touches reviewer dispatch prompts, not the data model. Can land independently.

## Risks and open questions

1. **Spec-diff snapshot timing.** ~~Open.~~ **Resolved: persist rewrite-tip SHA in the validate-rewrite Approved review file.** The spec-diff is anchored to a stable SHA captured at validate-rewrite Approved time, not to "HEAD at implement-cohesively invocation time." This makes Coverage Drift retries, interrupted runs, and Mixed classifications all handle cleanly. Residual risk: branch rebase between Approved and implement-cohesively invocation invalidates the SHA. Mitigation: implement-cohesively Step 0 verifies the SHA exists in branch history (`git cat-file -e <SHA>`); on missing, errors with a directive pointing the user at re-running validate-rewrite. See §2 and §3 for the concrete mechanics.

2. **Re-calibration of the budget gate threshold.** "1000 changed lines" is a starting guess. Real-world calibration after a few runs.

3. **Classification disagreement.** Today's classification is human-authored at rewrite-specs Step 1a and lives in the ledger preamble. After L1, it lives in the rewrite commit message's `Classification:` trailer. The validate-rewrite reviewer reads both the human-authored value AND the diff, and raises an issue if they disagree. Risk: the reviewer's diff-inferred classification could over-flag (e.g., a comment-only doc change marked Pure-implementation that the reviewer reads as "touches a seam"). Mitigation: classification disagreement surfaces as an Important issue (not Blocking) unless the diff clearly contradicts the human classification.

4. **Reviewer prompt size.** Today's reviewer reads the ledger preamble (~50 lines) for orientation. Tomorrow's reviewer reads the diff itself (could be 1000+ lines). For large rewrites, the prompt might exceed the agent's context budget. Mitigation: diff-as-file (reviewer reads selectively); the diff is bounded by what the rewrite actually changed.

5. **Audit trail continuity.** Today, the ledger acts as a forensic record of what the rewrite intended. After L1, the audit trail is: rewrite commits + validation reviews + implementation commits. Is that enough for "why did we make this change" questions a year later? Probably yes — the brainstorm artifact (if persisted) plus the rewrite commit messages carry the intent.

## Self-review

- Placeholder scan: no TBD / TODO / vague requirements.
- Internal consistency: §1–§4 form a coherent flow; the diff is captured once (Step 1 of implement-cohesively) and consumed by all downstream readers.
- Scope: this is L1 only; L2 and L3 are explicitly future addons. Scoped to one implementation pass.
- Ambiguity: spec-diff snapshot timing (originally open question #1) resolved — `validate-rewrite` persists rewrite-tip SHA at Approved time; `implement-cohesively` reads it. No remaining design-level ambiguity.

## Next

After this brainstorm is accepted, the next step is to run the cohesive flow on itself (one time only, against this proposal) to convert this brainstorm into the actual rewritten skills. Concrete sequence:

1. Open a worktree on branch `design/replace-delta-ledger-with-git-diff`.
2. Use the current `rewrite-specs` (ironic but necessary) to rewrite the affected skills + templates per §1–§4 above, plus the validator and any cross-references.
3. Run `validate-rewrite` against the rewrite.
4. Once Approved, use `implement-cohesively` to land any code/script changes (mainly `scripts/validate_plugin.sh`).
5. After this lands, L1 is done; future cohesive flows on this repo or any consumer repo use the new shape.

For L2 and L3, separate brainstorms after L1 ships.
