# validate_plugin.sh Check 15 (SKILL_DESIGN_DOC_SECTION) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Check 15 to `scripts/validate_plugin.sh` that mechanically enforces the named invariant `SKILL_DESIGN_DOC_SECTION` — every directory under `skills/` has a `### <name>` section heading in `docs/substrate/architecture/skills.md`.

**Architecture:** Insert one new check block in `scripts/validate_plugin.sh` between the existing Check 14 (`PLUGIN_ROOT_PATHS`) and the final summary block. The check uses the script's existing `fail`/`ok` helpers, follows the canonical bash snippet in `docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md` §"Enforcement", iterates `skills/*/`, and greps `docs/substrate/architecture/skills.md` for `^### <skill_name>$`. The check is one-direction (every skill dir must have a section; sections without dirs are allowed).

**Tech Stack:** bash, grep, find. No new dependencies.

---

## File Structure

**Files:**
- Modify: `scripts/validate_plugin.sh:478-489` — insert Check 15 between Check 14 and the final exit-summary block

No new files. No tests-as-files (the validator is the test). The "test" is a temporary fixture: rename a section heading in `architecture/skills.md`, run the validator, observe it fails, restore, observe it passes.

## Task 1: Add Check 15 to validate_plugin.sh

**Files:**
- Modify: `scripts/validate_plugin.sh` — insert between line 478 (end of Check 14) and line 480 (`echo ""` before exit-summary)

- [ ] **Step 1: Confirm the validator currently has no Check 15 and the failing fixture would not be caught**

Run:
```bash
bash scripts/validate_plugin.sh 2>&1 | tail -3
```

Expected: `[ OK ] Validation passed (0 warnings)` (or whatever current passing state is — the point is no Check 15 line appears in output).

Now create the failing fixture: rename a section heading in `architecture/skills.md` to verify the absence of the check is visible.

```bash
sed -i.bak 's|^### cohesively$|### cohesively-renamed|' docs/substrate/architecture/skills.md
bash scripts/validate_plugin.sh 2>&1 | tail -3
```

Expected: `[ OK ] Validation passed (0 warnings)` — the validator does NOT catch the renamed section because Check 15 doesn't exist yet. This confirms the gap.

Restore the fixture:
```bash
mv docs/substrate/architecture/skills.md.bak docs/substrate/architecture/skills.md
```

- [ ] **Step 2: Insert Check 15 before the final summary block**

Find the line `# 14. PLUGIN_ROOT_PATHS:` and locate the end of that check block (the line immediately before `echo ""` in the exit-summary). Insert this block:

```bash

# 15. SKILL_DESIGN_DOC_SECTION: every directory under skills/ has a `### <name>`
# section in docs/substrate/architecture/skills.md.
# Per docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md.
SKILLS_DESIGN_DOC="docs/substrate/architecture/skills.md"
if [ ! -f "$SKILLS_DESIGN_DOC" ]; then
  fail "$SKILLS_DESIGN_DOC missing (per SKILL_DESIGN_DOC_SECTION)"
else
  errors_before=$errors
  skill_section_count=0
  for skill_dir in skills/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    skill_section_count=$((skill_section_count + 1))
    if ! grep -qE "^### ${skill_name}\$" "$SKILLS_DESIGN_DOC"; then
      fail "skills/${skill_name}/ has no '### ${skill_name}' section in $SKILLS_DESIGN_DOC (per SKILL_DESIGN_DOC_SECTION)"
    fi
  done
  [ "$errors" -eq "$errors_before" ] && ok "SKILL_DESIGN_DOC_SECTION: all $skill_section_count skills have '### <name>' sections in architecture/skills.md"
fi
```

Use `Edit` tool with the find-target being the existing line `ok "PLUGIN_ROOT_PATHS: no hardcoded absolute paths in skills/, agents/, references/"` and adding the new check block immediately after the closing `fi` of Check 14 (which is two lines below — the structure is `if [ -n "$violations" ]; ...; else; ok "..."; fi`). The new check goes after that closing `fi`.

Concretely, the existing structure around lines 472–479:
```bash
if [ -n "$violations" ]; then
  echo "$violations" | while IFS= read -r line; do
    fail "PLUGIN_ROOT_PATHS violation: $line"
  done
else
  ok "PLUGIN_ROOT_PATHS: no hardcoded absolute paths in skills/, agents/, references/"
fi

echo ""
```

Insert the new Check 15 block between the closing `fi` and `echo ""`.

- [ ] **Step 3: Run validator on clean tree to verify Check 15 reports OK**

Run:
```bash
bash scripts/validate_plugin.sh 2>&1 | tail -5
```

Expected: an `[ OK ] SKILL_DESIGN_DOC_SECTION: all 9 skills have '### <name>' sections in architecture/skills.md` line appears, immediately before the final `[ OK ] Validation passed (0 warnings)`.

If `9` does not appear, count `ls -d skills/*/ | wc -l` and verify it matches the count in the OK line.

- [ ] **Step 4: Re-create the failing fixture; verify Check 15 catches it**

Run:
```bash
sed -i.bak 's|^### cohesively$|### cohesively-renamed|' docs/substrate/architecture/skills.md
bash scripts/validate_plugin.sh 2>&1 | tail -5
echo "Exit: $?"
```

Expected output contains:
- `[FAIL] skills/cohesively/ has no '### cohesively' section in docs/substrate/architecture/skills.md (per SKILL_DESIGN_DOC_SECTION)`
- The final summary: `[FAIL] Validation failed: 1 errors, 0 warnings`
- Exit code: `1`

The `(per SKILL_DESIGN_DOC_SECTION)` suffix in the failure message must be present — it names the invariant by name, matching the convention used by Check 14 (`per PLUGIN_ROOT_PATHS`).

- [ ] **Step 5: Restore the fixture; verify clean validator pass**

Run:
```bash
mv docs/substrate/architecture/skills.md.bak docs/substrate/architecture/skills.md
bash scripts/validate_plugin.sh 2>&1 | tail -3
echo "Exit: $?"
```

Expected:
- `[ OK ] SKILL_DESIGN_DOC_SECTION: all 9 skills have '### <name>' sections in architecture/skills.md`
- `[ OK ] Validation passed (0 warnings)`
- Exit code: `0`

- [ ] **Step 6: Verify the one-direction property (sections without skill dirs are allowed)**

The check iterates `skills/*/` and greps for the section. It does NOT iterate sections in `architecture/skills.md` looking for skill dirs. So a section heading for a planned-but-not-yet-implemented skill should pass. Verify by adding a phantom section heading and confirming OK:

```bash
echo "" >> docs/substrate/architecture/skills.md
echo "### planned-future-skill" >> docs/substrate/architecture/skills.md
echo "Placeholder for a planned skill." >> docs/substrate/architecture/skills.md
bash scripts/validate_plugin.sh 2>&1 | tail -3
echo "Exit: $?"
```

Expected: still passes (`[ OK ] Validation passed (0 warnings)`, exit 0). The phantom section's name `planned-future-skill` doesn't have a corresponding `skills/planned-future-skill/` directory, but the check is one-direction and only fails when skill dirs lack sections — not the inverse.

Restore by removing the phantom section:
```bash
git checkout docs/substrate/architecture/skills.md
bash scripts/validate_plugin.sh 2>&1 | tail -3
```

Expected: clean pass.

- [ ] **Step 7: Update the validator's top-of-file comment-block to mention SKILL_DESIGN_DOC_SECTION**

The validator's header docstring (lines 4–18) lists what it enforces. Currently it names `PLUGIN_ROOT_PATHS` only as a named invariant. Add a line for the new invariant:

Find the existing `# Enforces:` block (around lines 4–18) and add a new bullet:
```
#   - Named invariant SKILL_DESIGN_DOC_SECTION (every skill dir has a `### <name>` section in architecture/skills.md)
```

Place it immediately after the `# Named invariant PLUGIN_ROOT_PATHS` bullet so the two named invariants enforced by the script appear together at the top.

- [ ] **Step 8: Run validator one final time on clean tree to confirm both checks pass**

Run:
```bash
bash scripts/validate_plugin.sh
```

Expected: full validator run completes with `[ OK ] Validation passed (0 warnings)`, and the output includes both:
- `[ OK ] PLUGIN_ROOT_PATHS: no hardcoded absolute paths in skills/, agents/, references/`
- `[ OK ] SKILL_DESIGN_DOC_SECTION: all 9 skills have '### <name>' sections in architecture/skills.md`

Exit code: 0.

- [ ] **Step 9: Commit**

```bash
git add scripts/validate_plugin.sh
git commit -m "implement: phase 1 — validate_plugin.sh Check 15 (SKILL_DESIGN_DOC_SECTION)

Plan: docs/history/plans/2026-05-05-architecture-refactor-phase-1.md
Delta entries: named-invariant SKILL_DESIGN_DOC_SECTION; semantic-linter Check 15
Cross-review: pending (delta-coverage-reviewer dispatch follows)
"
```

The commit message cites the plan path and the delta entries by stable ID per `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`. The `Cross-review: pending` line is updated to `Cross-review: Covered` if the per-phase reviewer returns Covered (see `cohesive:implement-cohesively` Phase 2c) — the current commit captures pre-review state.

---

## Self-Review

**1. Spec coverage:**
- Delta entry "named-invariant SKILL_DESIGN_DOC_SECTION (added; mechanically enforced by validate_plugin.sh Check 15)" → covered by Task 1 Steps 2–8.
- Delta entry "Semantic linter spec validate_plugin.sh Check 15" → covered by Task 1 Steps 2–8.
- Acceptance criterion "For every directory under skills/, the validator runs the regex grep" → Task 1 Step 2 (the bash snippet's for-loop).
- Acceptance criterion "Failure message format includes (per SKILL_DESIGN_DOC_SECTION)" → Task 1 Step 4 (verifies the literal in output).
- Acceptance criterion "OK line emitted on success" → Task 1 Step 3 (verifies the literal in output).
- Acceptance criterion "bash scripts/validate_plugin.sh passes on the current state" → Task 1 Step 8 (final validation).
- Acceptance criterion "TDD: failing test/scenario lands first" → Task 1 Step 1 (failing fixture before the check exists) + Step 4 (failing fixture after the check exists, verifies catch).
- Acceptance criterion "one-direction check: sections without skill dirs are allowed" → Task 1 Step 6 (phantom section test).

No spec gaps.

**2. Placeholder scan:** No "TBD", "TODO", "implement later", "fill in details", "appropriate error handling", "similar to Task N", or other placeholders. All steps include exact commands, exact expected output, and the actual bash to add.

**3. Type consistency:** The variable name `SKILLS_DESIGN_DOC` is introduced in Step 2 and not used elsewhere. The variable `skill_section_count` is local to the new block. The functions `fail` and `ok` are existing globals defined at the top of the script (line 30, 32). The variable `errors` and `errors_before` are existing globals already used by other checks. No new identifiers introduced beyond the new check block.

The validator's documented check ordinal (`Check 15`) matches the `# 15.` comment in the new block.

The failure-message literal `(per SKILL_DESIGN_DOC_SECTION)` matches the convention of Check 14's `(per PLUGIN_ROOT_PATHS)`. The OK message format `SKILL_DESIGN_DOC_SECTION: all <N> skills have '### <name>' sections in architecture/skills.md` matches the OK message format for Check 14 in shape (named invariant + scope summary).

No type/identifier inconsistencies.

---

## Execution Handoff

This plan is consumed by `cohesive:implement-cohesively` Phase 2b which dispatches `superpowers:executing-plans` against this plan path. After Phase 2b lands the commit, Phase 2c dispatches `delta-coverage-reviewer` against (this plan, the delta-ledger entries it covers, the phase diff). The cross-review's Covered/Drift/Incomplete verdict gates Phase 3 (`cohesive:review-diff`).
