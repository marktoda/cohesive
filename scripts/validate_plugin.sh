#!/usr/bin/env bash
# Cohesive plugin static validation.
#
# Enforces structural shape:
#   - Plugin manifest validity (plugin.json / marketplace.json)
#   - Component dirs at plugin root (not nested under .claude-plugin/)
#   - Skill / agent frontmatter shape
#   - The expected v0.1 skill set
#   - Substrate-vocabulary tokens in skill descriptions
#   - Negative-trigger discipline (avoid generic-review trigger phrases)
#   - Path-prereq subskills carry directive-error templates
#   - Fresh-eyes preamble bullet across reviewer agents
#   - "### Next" footer in every persisting skill
#   - VERDICT_BEFORE_EVIDENCE (verdict-led skills lead with **Verdict:**)
#   - Voice imperative in skill / agent bodies (load output-voice.md)
#   - Anti-citation lint (no voice-citation literal inside render templates)
#   - validate-rewrite Approved-footer alternatives are present
#   - Bypass-acknowledgment string in validate-rewrite
#   - Chain-rendering anti-pattern absent from router
#   - Forbidden phase-shaped literals absent from runtime surfaces
#   - No retired delta-ledger references in production surface
#   - Change-type gate present in cohesively router
#   - Pass-budget default 2 + closed-findings forwarding (L3 convergence rule)
#   - PLUGIN_ROOT_PATHS (no hardcoded absolute paths)
#   - Referenced files exist (warn-level)
#   - Scripts are executable (warn-level)
#
# Usage: bash scripts/validate_plugin.sh
# Exits 0 on success, 1 on failure.

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLUGIN_ROOT"

errors=0
warnings=0

fail() { echo "[FAIL] $*"; errors=$((errors + 1)); }
warn() { echo "[WARN] $*"; warnings=$((warnings + 1)); }
ok()   { echo "[ OK ] $*"; }

echo "Validating cohesive plugin at $PLUGIN_ROOT"
echo ""

# 1. plugin.json exists and is valid JSON
if [ ! -f .claude-plugin/plugin.json ]; then
  fail ".claude-plugin/plugin.json missing"
else
  if python3 -c "import json,sys; json.load(open('.claude-plugin/plugin.json'))" 2>/dev/null; then
    ok ".claude-plugin/plugin.json is valid JSON"
  else
    fail ".claude-plugin/plugin.json is not valid JSON"
  fi
fi

# 2. marketplace.json (optional but recommended) is valid JSON if present
if [ -f .claude-plugin/marketplace.json ]; then
  if python3 -c "import json,sys; json.load(open('.claude-plugin/marketplace.json'))" 2>/dev/null; then
    ok ".claude-plugin/marketplace.json is valid JSON"
  else
    fail ".claude-plugin/marketplace.json is not valid JSON"
  fi
fi

# 3. Component dirs are at plugin root, not inside .claude-plugin/
errors_before=$errors
for d in skills agents hooks commands references scripts; do
  if [ -d ".claude-plugin/$d" ]; then
    fail "Component dir .claude-plugin/$d should be at plugin root, not inside .claude-plugin/"
  fi
done
[ "$errors" -eq "$errors_before" ] && ok "component dirs at plugin root (not nested under .claude-plugin/)"

# 4. Every skill directory has a SKILL.md with valid frontmatter.
if [ -d skills ]; then
  shopt -s nullglob
  for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_md="${skill_dir}SKILL.md"
    if [ ! -f "$skill_md" ]; then
      fail "skills/$skill_name/ has no SKILL.md"
      continue
    fi
    if msg=$(python3 scripts/_frontmatter_check.py "$skill_md" "$skill_name" 2>&1); then
      ok "skills/$skill_name/SKILL.md has valid frontmatter"
    else
      fail "$msg"
    fi
  done
fi

# 5. Every agent file has valid frontmatter.
if [ -d agents ]; then
  for agent_md in agents/*.md; do
    [ -e "$agent_md" ] || continue
    agent_name=$(basename "$agent_md" .md)
    if msg=$(python3 scripts/_frontmatter_check.py "$agent_md" "$agent_name" 2>&1); then
      ok "$agent_md has valid frontmatter"
    else
      fail "$msg"
    fi
  done
fi

# 6. Referenced files exist (scan SKILL.md bodies for references/ and templates/ paths).
if [ -d skills ]; then
  warnings_before=$warnings
  ref_count=0
  while IFS= read -r ref; do
    ref_count=$((ref_count + 1))
    ref_clean=$(echo "$ref" | sed -E 's/[`\)\]"\.,;:]+$//')
    if [ ! -e "$ref_clean" ]; then
      warn "skill references missing path: $ref_clean"
    fi
  done < <(grep -rhoE '(references|templates)/[A-Za-z0-9_./-]+\.md' skills/ 2>/dev/null | sort -u || true)
  [ "$warnings" -eq "$warnings_before" ] && ok "all $ref_count references/ + templates/ paths cited from skills/ exist"
fi

# 7. Scripts are executable.
if [ -d scripts ]; then
  warnings_before=$warnings
  script_count=0
  for script in scripts/*.sh scripts/*.py; do
    [ -e "$script" ] || continue
    script_count=$((script_count + 1))
    if [ ! -x "$script" ]; then
      warn "$script is not executable (chmod +x)"
    fi
  done
  [ "$warnings" -eq "$warnings_before" ] && ok "all $script_count scripts/ files are executable"
fi

# 8. v0.1 skill set: the 11 expected skills are present.
expected_skills=(
  using-cohesive
  cohesively
  init
  discover-substrate
  brainstorm-design
  rewrite-specs
  validate-rewrite
  implement-cohesively
  review-codebase
  review-diff
  audit-substrate
)
errors_before=$errors
for s in "${expected_skills[@]}"; do
  if [ ! -f "skills/$s/SKILL.md" ]; then
    fail "expected skill missing: skills/$s/SKILL.md"
  fi
done
[ "$errors" -eq "$errors_before" ] && ok "v0.1 skill set complete (${#expected_skills[@]}/${#expected_skills[@]} present: ${expected_skills[*]})"

# Helper: extract the (multi-line) description value from a SKILL.md frontmatter
# block as a single space-joined string.
extract_description() {
  local skill_md="$1"
  awk '
    /^---$/{c++; next}
    c==1 && /^description:/{flag=1; sub(/^description:[[:space:]]*/, ""); print; next}
    c==1 && flag && /^[a-z_-]+:/{flag=0}
    c==1 && flag{print}
    c>=2{exit}
  ' "$skill_md" | tr '\n' ' '
}

# 9a. Every Cohesive skill description contains at least one substrate-vocabulary token.
# Mitigates the discovery-vs-superpowers ambiguity at the trigger-string level.
substrate_tokens='substrate|cohesion|cohesive|invariant|gotcha|behavior matrix|spec|rewrite'
errors_before=$errors
for s in "${expected_skills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  description=$(extract_description "$skill_md")
  if ! echo "$description" | grep -qiE "$substrate_tokens"; then
    fail "skills/$s/SKILL.md description lacks any substrate-vocabulary token ($substrate_tokens)"
  fi
done
[ "$errors" -eq "$errors_before" ] && ok "all ${#expected_skills[@]} skill descriptions carry a substrate-vocabulary token"

# 9b. Negative-trigger discipline. Skill descriptions must not use bare generic-review
# trigger phrases that overlap with Superpowers' code-reviewer surface. Tightened
# triggers like "review the codebase for cohesion" pass; bare "review the codebase" does not.
generic_triggers=(
  '"review the codebase"'
  '"review the architecture"'
  '"is this codebase healthy"'
  '"review the code"'
)
errors_before=$errors
for s in "${expected_skills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  description=$(extract_description "$skill_md")
  for phrase in "${generic_triggers[@]}"; do
    if echo "$description" | grep -qF "$phrase"; then
      fail "skills/$s/SKILL.md description uses generic-review trigger $phrase without cohesion narrowing"
    fi
  done
done
[ "$errors" -eq "$errors_before" ] && ok "no skill description uses bare generic-review trigger phrases"

# 10. Path-prereq subskills carry a directive-error template instead of a clarifying question.
# Three checks: directive-error phrase present, upstream cohesive:<skill> instruction present,
# and the canonical session-prereq question / "stop and ask" phrasing absent.
path_prereq_subskills=(
  validate-rewrite
  implement-cohesively
)
errors_before=$errors
for s in "${path_prereq_subskills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  if ! grep -qE "directive error" "$skill_md"; then
    fail "skills/$s/SKILL.md missing directive-error template"
    continue
  fi
  if ! grep -qE "Run \`?cohesive:" "$skill_md"; then
    fail "skills/$s/SKILL.md directive-error template does not name an upstream cohesive: skill"
    continue
  fi
  if grep -qE "^[[:space:]]*> \"I see we're about to run $s\." "$skill_md"; then
    fail "skills/$s/SKILL.md carries the canonical clarifying question alongside the directive-error template (path-prereq subskills must not have both)"
    continue
  fi
  if grep -qE "stop and ask" "$skill_md"; then
    fail "skills/$s/SKILL.md carries 'stop and ask' phrasing alongside the directive-error template"
  fi
done
[ "$errors" -eq "$errors_before" ] && ok "all ${#path_prereq_subskills[@]} path-prereq subskills carry directive-error templates"

# 11. Fresh-eyes preamble bullet verbatim across reviewer agent files.
fresh_eyes_bullet='Inherit conversation context from the calling skill. Treat your input prompt as the entire context.'
if [ -d agents ]; then
  errors_before=$errors
  agent_count=0
  for agent_md in agents/*.md; do
    [ -e "$agent_md" ] || continue
    agent_count=$((agent_count + 1))
    if ! grep -qF "$fresh_eyes_bullet" "$agent_md"; then
      fail "$agent_md missing fresh-eyes preamble bullet"
    fi
  done
  [ "$errors" -eq "$errors_before" ] && ok "all $agent_count reviewer agents carry the fresh-eyes preamble bullet verbatim"
fi

# 12. "### Next" footer in every persisting skill body.
# The router (cohesively) is exempt: its output is a one-sentence announcement.
persisting_skills=(
  discover-substrate
  brainstorm-design
  rewrite-specs
  validate-rewrite
  implement-cohesively
  review-codebase
  review-diff
  audit-substrate
  init
)
errors_before=$errors
for s in "${persisting_skills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  if ! grep -qE '^### Next$' "$skill_md"; then
    fail "skills/$s/SKILL.md missing '### Next' footer"
  fi
done
[ "$errors" -eq "$errors_before" ] && ok "all ${#persisting_skills[@]} persisting skills have the '### Next' footer"

# 13a. VERDICT_BEFORE_EVIDENCE: verdict-led skills' Output format block opens with
# **Verdict:** within the first 3 non-blank lines after the outermost # title.
verdict_led_skills=(
  review-codebase
  review-diff
  validate-rewrite
  audit-substrate
  implement-cohesively
)
errors_before=$errors
for s in "${verdict_led_skills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  if awk '
    /^```/ { in_block = !in_block; if (!in_block) { found_title=0; count=0 }; next }
    in_block && !found_title && /^# / { found_title=1; count=0; next }
    in_block && found_title {
      if (/^[[:space:]]*$/) next
      count++
      if (count > 3) { found_title=0; next }
      if (/\*\*Verdict:\*\*/) { found_verdict=1; exit 0 }
    }
    END { exit found_verdict ? 0 : 1 }
  ' "$skill_md"; then
    : # ok
  else
    fail "$skill_md violates VERDICT_BEFORE_EVIDENCE: Output format code block must lead with '# <title>' then **Verdict:** within first 3 non-blank lines"
  fi
done
[ "$errors" -eq "$errors_before" ] && ok "VERDICT_BEFORE_EVIDENCE: all ${#verdict_led_skills[@]} verdict-led skills lead Output format with **Verdict:**"

# 13b. Voice-imperative grep, skills: every non-router non-orientation SKILL.md body
# (outside fenced code blocks) contains the literal imperative loading the voice guide.
voice_imperative_literal='Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.'
voice_imperative_skills=(
  discover-substrate
  brainstorm-design
  rewrite-specs
  validate-rewrite
  implement-cohesively
  review-codebase
  review-diff
  audit-substrate
  init
)
errors_before=$errors
for s in "${voice_imperative_skills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  if awk -v lit="$voice_imperative_literal" '
    /^```/ { in_block = !in_block; next }
    !in_block && index($0, lit) > 0 { found=1; exit 0 }
    END { exit found ? 0 : 1 }
  ' "$skill_md"; then
    : # ok
  else
    fail "$skill_md missing voice imperative in body prose (outside fenced code blocks). Add the literal line 'Read \${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.' in a ## Voice section."
  fi
done
[ "$errors" -eq "$errors_before" ] && ok "all ${#voice_imperative_skills[@]} non-router skill bodies carry the voice imperative"

# 13c. Voice-imperative grep, reviewer agents.
if [ -d agents ]; then
  errors_before=$errors
  agent_imperative_count=0
  for agent_md in agents/*.md; do
    [ -e "$agent_md" ] || continue
    agent_imperative_count=$((agent_imperative_count + 1))
    if awk -v lit="$voice_imperative_literal" '
      /^```/ { in_block = !in_block; next }
      !in_block && index($0, lit) > 0 { found=1; exit 0 }
      END { exit found ? 0 : 1 }
    ' "$agent_md"; then
      : # ok
    else
      fail "$agent_md missing voice imperative in body prose (outside fenced code blocks). Add the literal line 'Read \${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.'"
    fi
  done
  [ "$errors" -eq "$errors_before" ] && ok "all $agent_imperative_count reviewer-agent bodies carry the voice imperative"
fi

# 13d. Anti-citation lint: the voice-citation literal must NOT appear inside any fenced
# code block in SKILL.md or agent files. Citations in render templates leak verbatim to users.
voice_citation_literal='> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md'
errors_before=$errors
template_check_count=0
for s in "${voice_imperative_skills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  template_check_count=$((template_check_count + 1))
  if awk -v lit="$voice_citation_literal" '
    /^```/ { in_block = !in_block; next }
    in_block && index($0, lit) > 0 { found=1; exit 0 }
    END { exit found ? 0 : 1 }
  ' "$skill_md"; then
    fail "$skill_md contains voice-citation literal inside a fenced code block (render template). Move the load directive to body prose as an imperative."
  fi
done
if [ -d agents ]; then
  for agent_md in agents/*.md; do
    [ -e "$agent_md" ] || continue
    template_check_count=$((template_check_count + 1))
    if awk -v lit="$voice_citation_literal" '
      /^```/ { in_block = !in_block; next }
      in_block && index($0, lit) > 0 { found=1; exit 0 }
      END { exit found ? 0 : 1 }
    ' "$agent_md"; then
      fail "$agent_md contains voice-citation literal inside a fenced code block (render template). Move the load directive to body prose as an imperative."
    fi
  done
fi
[ "$errors" -eq "$errors_before" ] && ok "no citation literals inside render templates across $template_check_count files (anti-citation lint)"

# 13e. validate-rewrite Approved-footer alternatives. The default implementation path
# plus the three canonical conditional alternatives must all be named in the body.
errors_before=$errors
if grep -qF '`cohesive:implement-cohesively`' skills/validate-rewrite/SKILL.md \
   && grep -qF 'Land specs first' skills/validate-rewrite/SKILL.md \
   && grep -qF 'Implement with Superpowers directly' skills/validate-rewrite/SKILL.md \
   && grep -qF '`superpowers:writing-plans`' skills/validate-rewrite/SKILL.md \
   && grep -qF 'Re-decide' skills/validate-rewrite/SKILL.md; then
  ok "validate-rewrite Approved footer covers the default + canonical conditional alternatives (Land specs first / Implement with Superpowers directly / Re-decide)"
else
  fail "skills/validate-rewrite/SKILL.md missing one or more of the canonical implementation paths. Required: cohesive:implement-cohesively (default), Land specs first, Implement with Superpowers directly, superpowers:writing-plans, Re-decide."
fi

# 13g. Literal bypass-acknowledgment string in validate-rewrite. Must be reproduced
# verbatim in the SKILL body so the Output format renders it consistently.
errors_before=$errors
bypass_string="Implementing with plain Superpowers — Cohesive's verification of the rewrite doesn't apply. Run cohesive:review-diff after implementation to catch any drift."
if grep -qF "$bypass_string" skills/validate-rewrite/SKILL.md; then
  ok "validate-rewrite carries the literal bypass-acknowledgment string"
else
  fail "skills/validate-rewrite/SKILL.md missing the literal bypass-acknowledgment string. Expected: '$bypass_string'"
fi

# 13l. Chain-rendering anti-pattern in cohesively/SKILL.md. Subskill IDs joined by →
# arrows render dispatch machinery in user-facing chat output and were retired in
# favor of one-sentence outcome announcements.
errors_before=$errors
subskill_chain_pattern='→ (discover-substrate|brainstorm-design|rewrite-specs|validate-rewrite|implement-cohesively|review-codebase|review-diff|audit-substrate)'
chain_violations=$(grep -nE "$subskill_chain_pattern" skills/cohesively/SKILL.md 2>/dev/null || true)
if [ -n "$chain_violations" ]; then
  fail "Chain-rendering anti-pattern in skills/cohesively/SKILL.md: subskill IDs joined by → arrows render dispatch machinery in user-facing chat output. Lines: $(echo "$chain_violations" | tr '\n' ';')"
else
  ok "Chain-rendering anti-pattern absent from cohesively/SKILL.md"
fi

# 13m. Forbidden phase-shaped literals in skills/, agents/, references/. The
# implement-cohesively single-pass redesign retired the per-phase concept; literal
# phrases like "phase by phase" or "phase-by-phase" in user-facing surfaces are
# stale.
errors_before=$errors
phase_violations=$(grep -rinE 'phase[ -]by[ -]phase' skills/ agents/ references/ 2>/dev/null || true)
if [ -n "$phase_violations" ]; then
  echo "$phase_violations" | while IFS= read -r line; do
    fail "Forbidden phase-shaped literal: $line. The single-pass redesign retired the per-phase concept; replace with 'in a single pass' or 'per-pass'."
  done
else
  ok "no 'phase by phase' / 'phase-by-phase' literals in skills/, agents/, references/"
fi

# 13n. No remaining references to the retired design-delta-ledger artifact in
# skills/, agents/, or references/. The delta ledger was retired in favor of the
# git diff being the authoritative record of what the rewrite changed; any
# remaining reference in the production surface is a regression.
ledger_violations=$(
  grep -rinE 'delta[ -]ledger|design-delta-ledger|delta_ledger|IMPLEMENTATION_PLAN_COVERS_DELTA' \
    skills/ agents/ references/ 2>/dev/null \
    || true
)
if [ -n "$ledger_violations" ]; then
  echo "$ledger_violations" | while IFS= read -r line; do
    fail "Retired delta-ledger reference: $line. The delta-ledger artifact was retired; the git diff at the rewrite-tip SHA is the authoritative record. Update to spec-diff / rewrite-tip / IMPLEMENTATION_COVERS_SPEC_DIFF vocabulary."
  done
else
  ok "no retired delta-ledger references in skills/, agents/, references/"
fi

# 13o. Change-type gate presence in cohesively router. The L2 design adds a gate
# question for forward-looking routes (design / rewrite-only / extend) that picks
# between extending an existing concept and introducing a new one. A missing gate
# section means the router cannot route to the extend path.
errors_before=$errors
if grep -qF 'Change-type gate' skills/cohesively/SKILL.md \
   && grep -qF 'Are you extending an existing concept, or introducing a new one?' skills/cohesively/SKILL.md \
   && grep -qF '| `extend` |' skills/cohesively/SKILL.md; then
  ok "Change-type gate present in cohesively router (extend route + gate question)"
else
  fail "skills/cohesively/SKILL.md missing the L2 change-type gate. Required: §\"Change-type gate\" header, the question text 'Are you extending an existing concept, or introducing a new one?', and the \`extend\` route in the dispatch contract table."
fi

# 13p. Pass-budget convergence rule (L3). validate-rewrite's repair loop is capped
# at MAX_REPAIR_PASSES default 2. Regressing to 5 (or higher than 3) defeats the
# convergence rule. Body text must mention the default 2 — either via the explicit
# `MAX_REPAIR_PASSES = 2` form or the `default 2` phrasing in Hard constraints / Step 4.
errors_before=$errors
if grep -qE '`?MAX_REPAIR_PASSES`?[[:space:]]*=[[:space:]]*2\b' skills/validate-rewrite/SKILL.md \
   || grep -qF 'default 2' skills/validate-rewrite/SKILL.md; then
  ok "Pass-budget default 2 present in validate-rewrite (L3 convergence rule)"
else
  fail "skills/validate-rewrite/SKILL.md missing the L3 pass-budget default of 2. Required: text indicating MAX_REPAIR_PASSES default is 2 (either '\`MAX_REPAIR_PASSES = 2\`' or 'default 2' phrasing in Hard constraint #4 / Step 4)."
fi

# 13q. Closed-findings forwarding contract (L3). Pass-N reviewers (N ≥ 2) receive
# prior-pass closed findings as anti-amnesia context. The dispatch-prompt section
# header is canonical; the spec-cohesion-reviewer agent's input contract must
# acknowledge the list.
errors_before=$errors
if grep -qF 'Closed findings from prior passes' skills/validate-rewrite/SKILL.md \
   && grep -qF 'Closed findings from prior passes' agents/spec-cohesion-reviewer.md; then
  ok "L3 closed-findings forwarding contract present (validate-rewrite dispatch prompt + spec-cohesion-reviewer input contract)"
else
  fail "L3 closed-findings forwarding contract missing. Required: '## Closed findings from prior passes' section in skills/validate-rewrite/SKILL.md (dispatch-prompt shape) AND a corresponding bullet in agents/spec-cohesion-reviewer.md (Inputs section)."
fi

# 14. PLUGIN_ROOT_PATHS: no hardcoded absolute paths in skills/, agents/, references/.
# Excludes lines inside fenced code blocks and lines marked as anti-pattern examples.
violations=$(
  grep -rnE '(^|[^A-Z_])(/(home|Users|usr/local)/|~/)' skills/ agents/ references/ 2>/dev/null \
    | grep -vE '(```|<!-- anti-pattern|Anti-pattern:|Hardcoded paths)' \
    || true
)
if [ -n "$violations" ]; then
  echo "$violations" | while IFS= read -r line; do
    fail "PLUGIN_ROOT_PATHS violation: $line"
  done
else
  ok "PLUGIN_ROOT_PATHS: no hardcoded absolute paths in skills/, agents/, references/"
fi

echo ""
if [ "$errors" -eq 0 ]; then
  echo "[ OK ] Validation passed ($warnings warnings)"
  exit 0
else
  echo "[FAIL] Validation failed: $errors errors, $warnings warnings"
  exit 1
fi
