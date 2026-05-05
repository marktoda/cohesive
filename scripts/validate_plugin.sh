#!/usr/bin/env bash
# Cohesive plugin static validation.
#
# Enforces:
#   - Named invariant PLUGIN_ROOT_PATHS (no hardcoded absolute paths)
#   - Plugin-manifest shape (plugin.json / marketplace.json validity)
#   - Skill / agent frontmatter shape (delegated to scripts/_frontmatter_check.py)
#   - The v0.1 expected skill set
#   - Substrate-vocabulary tokens in skill descriptions
#   - Negative-trigger discipline (descriptions avoid generic-review phrases without
#     cohesion-narrowing language)
#   - Canonical prereq-detection question in subskills with a discover-substrate prereq
#   - Fresh-eyes preamble bullet verbatim across reviewer agents
#   - "Recommended next Cohesive skill" footer in every persisting skill body
#   - Component dirs at plugin root, not nested under .claude-plugin/
#   - Referenced files exist (warn-level)
#   - Scripts are executable (warn-level)
#
# Usage: bash scripts/validate_plugin.sh
# Exits 0 on success, 1 on failure. Prints findings.

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

# 4. Every skill directory has a SKILL.md with valid frontmatter (delegated to Python helper).
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

# 5. Every agent file has valid frontmatter (delegated to Python helper).
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

# 6. Referenced files exist (basic check: scan SKILL.md bodies for references/ and templates/ paths)
if [ -d skills ]; then
  warnings_before=$warnings
  ref_count=0
  while IFS= read -r ref; do
    ref_count=$((ref_count + 1))
    # Strip surrounding chars commonly used in markdown
    ref_clean=$(echo "$ref" | sed -E 's/[`\)\]"\.,;:]+$//')
    if [ ! -e "$ref_clean" ]; then
      warn "skill references missing path: $ref_clean"
    fi
  done < <(grep -rhoE '(references|templates)/[A-Za-z0-9_./-]+\.md' skills/ 2>/dev/null | sort -u || true)
  [ "$warnings" -eq "$warnings_before" ] && ok "all $ref_count references/ + templates/ paths cited from skills/ exist"
fi

# 7. Scripts are executable
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

# 8. v0.1 skill set: the 9 expected skills are present.
# Locks in the verb-noun lexicon `discover-substrate -> brainstorm-design -> rewrite-specs -> validate-rewrite`
# plus standalone diagnostics `review-codebase`, `review-diff`, `audit-substrate`, and the router `cohesively`.
expected_skills=(
  cohesively
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
# Mitigates the discovery-vs-superpowers gotcha at the trigger-string level: the verb-only
# names lose Cohesive brand identity in the name alone, so the description must carry it.
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

# 9b. Negative-trigger discipline. Cohesive skill descriptions must not use bare quoted
# generic-review trigger phrases that overlap with Superpowers' code-reviewer surface.
# Tightened triggers like "review the codebase for cohesion" pass; bare "review the codebase"
# does not. Codified in docs/substrate/gotchas/discovery-vs-superpowers.md.
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
      fail "skills/$s/SKILL.md description uses generic-review trigger $phrase without cohesion narrowing (per docs/substrate/gotchas/discovery-vs-superpowers.md)"
    fi
  done
done
[ "$errors" -eq "$errors_before" ] && ok "no skill description uses bare generic-review trigger phrases"

# 10. Canonical prereq-detection question in subskills with a discover-substrate or
# brainstorm-design prereq. Per docs/substrate/designs/skill-conventions.md §"Canonical prereq-detection
# question". Stable opening: a blockquote line beginning `> "I see we're about to run <skill>.`
prereq_subskills=(
  brainstorm-design
  rewrite-specs
  implement-cohesively
  review-codebase
  review-diff
  audit-substrate
)
errors_before=$errors
for s in "${prereq_subskills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  if ! grep -qE "^[[:space:]]*> \"I see we're about to run $s\." "$skill_md"; then
    fail "skills/$s/SKILL.md missing canonical prereq-detection question (per docs/substrate/designs/skill-conventions.md §Canonical prereq-detection question)"
  fi
done
[ "$errors" -eq "$errors_before" ] && ok "all ${#prereq_subskills[@]} prereq-bearing subskills have the canonical prereq-detection question"

# 11. Fresh-eyes preamble bullet verbatim across reviewer agent files.
# Per docs/substrate/designs/reviewer-agent-template.md §"The fresh-eyes preamble".
fresh_eyes_bullet='Inherit conversation context from the calling skill. Treat your input prompt as the entire context.'
if [ -d agents ]; then
  errors_before=$errors
  agent_count=0
  for agent_md in agents/*.md; do
    [ -e "$agent_md" ] || continue
    agent_count=$((agent_count + 1))
    if ! grep -qF "$fresh_eyes_bullet" "$agent_md"; then
      fail "$agent_md missing fresh-eyes preamble bullet (per docs/substrate/designs/reviewer-agent-template.md §The fresh-eyes preamble)"
    fi
  done
  [ "$errors" -eq "$errors_before" ] && ok "all $agent_count reviewer agents carry the fresh-eyes preamble bullet verbatim"
fi

# 12. "Recommended next Cohesive skill" footer in every persisting skill body.
# Per docs/substrate/designs/skill-conventions.md §"Recommended-next-skill footer".
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
)
errors_before=$errors
for s in "${persisting_skills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  if ! grep -qE '^### Recommended next Cohesive skill' "$skill_md"; then
    fail "skills/$s/SKILL.md missing '### Recommended next Cohesive skill' footer (per docs/substrate/designs/skill-conventions.md §Recommended-next-skill footer)"
  fi
done
[ "$errors" -eq "$errors_before" ] && ok "all ${#persisting_skills[@]} persisting skills have the 'Recommended next Cohesive skill' footer"

# 13a. VERDICT_BEFORE_EVIDENCE: verdict-led skills' Output format block opens with **Verdict:**
# within the first 3 non-blank lines after the outermost # title in a code block.
# Per docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md.
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
  # Awk: find first `# title` line inside a fenced block, then check next 3 non-blank
  # lines for `**Verdict:**`. Exits 0 if found, 1 otherwise.
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
    fail "$skill_md violates VERDICT_BEFORE_EVIDENCE: Output format code block must lead with '# <title>' then **Verdict:** within first 3 non-blank lines (per docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md)"
  fi
done
[ "$errors" -eq "$errors_before" ] && ok "VERDICT_BEFORE_EVIDENCE: all ${#verdict_led_skills[@]} verdict-led skills lead Output format with **Verdict:**"

# 13b. Voice-imperative grep, skills: every non-router skills/*/SKILL.md body (outside
# fenced code blocks) contains the literal imperative directing the model to load the
# voice guide before rendering chat output. Per references/output-voice.md and
# docs/substrate/gotchas/style-guide-rot.md §"Correct pattern". Cohesively router is
# exempt (its dispatched subskills carry the voice load; documented in
# docs/substrate/invariants/PLUGIN_ROOT_PATHS.md §"Convention pins...").
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
    fail "$skill_md missing voice imperative in body prose (outside fenced code blocks). Add the literal line 'Read \${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.' in a ## Voice section. Per references/output-voice.md and docs/substrate/gotchas/style-guide-rot.md §\"Correct pattern\"."
  fi
done
[ "$errors" -eq "$errors_before" ] && ok "all ${#voice_imperative_skills[@]} non-router skill bodies carry the voice imperative"

# 13c. Voice-imperative grep, reviewer agents: every agents/*-reviewer.md body (outside
# fenced code blocks) contains the same imperative literal.
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
      fail "$agent_md missing voice imperative in body prose (outside fenced code blocks). Add the literal line 'Read \${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.' Per references/output-voice.md and docs/substrate/gotchas/style-guide-rot.md §\"Correct pattern\"."
    fi
  done
  [ "$errors" -eq "$errors_before" ] && ok "all $agent_imperative_count reviewer-agent bodies carry the voice imperative"
fi

# 13d. Anti-citation lint: no Output format / "How to structure your output" code block
# in any non-router skills/*/SKILL.md or agents/*-reviewer.md contains the literal
# citation line. Citations placed in render templates leak verbatim into user-facing
# output. Per docs/substrate/gotchas/style-guide-rot.md §"Correct pattern".
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
    fail "$skill_md contains voice-citation literal inside a fenced code block (render template). Citations in render templates leak verbatim to users. Move the load directive to body prose as an imperative. Per docs/substrate/gotchas/style-guide-rot.md §\"Correct pattern\"."
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
      fail "$agent_md contains voice-citation literal inside a fenced code block (render template). Citations in render templates leak verbatim to users. Move the load directive to body prose as an imperative. Per docs/substrate/gotchas/style-guide-rot.md §\"Correct pattern\"."
    fi
  done
fi
[ "$errors" -eq "$errors_before" ] && ok "no citation literals inside render templates across $template_check_count files (anti-citation lint)"

# 13e. Decision-matrix presence in validate-rewrite Approved footer.
# Per docs/substrate/gotchas/no-implementation-handoff.md and the validate-rewrite
# Output format. The Approved verdict footer must render the four-row decision
# matrix; without it, the user has no canonical choice between implementation
# paths and Cohesive falls back to freeform code-writing.
errors_before=$errors
if grep -qF '| Implement now with delta-coverage discipline (default) | `cohesive:implement-cohesively` |' skills/validate-rewrite/SKILL.md \
   && grep -qF '| Land specs first; implement separately later |' skills/validate-rewrite/SKILL.md \
   && grep -qF '| Hand off to Superpowers without delta-coverage discipline | `superpowers:writing-plans` |' skills/validate-rewrite/SKILL.md \
   && grep -qF '| Schedule for later | (no immediate action) |' skills/validate-rewrite/SKILL.md; then
  ok "validate-rewrite Approved footer carries the four-row decision matrix"
else
  fail "skills/validate-rewrite/SKILL.md missing one or more rows of the implementation decision matrix (per docs/substrate/gotchas/no-implementation-handoff.md). All four canonical rows must be present: implement-now, land-specs-first, hand-off-to-Superpowers, schedule-for-later."
fi

# 13f. implement-cohesively cites phase-derivation matrix + IMPLEMENTATION_PLAN_COVERS_DELTA.
# Per docs/substrate/gotchas/no-implementation-handoff.md "Tests / checks that preserve this"
# bullet 3. The skill body's Process / Hard constraints must reference both substrate
# artifacts so a reader of the SKILL alone can trace to the matrix and the invariant.
errors_before=$errors
if grep -qF 'docs/substrate/matrices/phase-derivation.md' skills/implement-cohesively/SKILL.md \
   && grep -qF 'docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md' skills/implement-cohesively/SKILL.md; then
  ok "implement-cohesively cites phase-derivation matrix and IMPLEMENTATION_PLAN_COVERS_DELTA invariant"
else
  fail "skills/implement-cohesively/SKILL.md must cite docs/substrate/matrices/phase-derivation.md AND docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md (per docs/substrate/gotchas/no-implementation-handoff.md). One or both citations are missing."
fi

# 13g. Literal bypass-acknowledgment string in validate-rewrite.
# Per docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md §Known bypass risks
# and docs/substrate/gotchas/no-implementation-handoff.md "Tests / checks that
# preserve this" bullet 4. The SKILL body must carry the literal string the
# Output format renders to the transcript when the bypass row is picked.
errors_before=$errors
bypass_string='Implementation may drift from the rewrite; the IMPLEMENTATION_PLAN_COVERS_DELTA invariant does not apply.'
if grep -qF "$bypass_string" skills/validate-rewrite/SKILL.md; then
  ok "validate-rewrite carries the literal bypass-acknowledgment string"
else
  fail "skills/validate-rewrite/SKILL.md missing the literal bypass-acknowledgment string (per docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md §Known bypass risks). Expected the string '$bypass_string' to appear in the SKILL body."
fi

# 13h. "Delta at a glance" preamble in delta-ledger files dated on or after the cutoff.
# Per references/templates/design-delta-ledger.md §"Delta at a glance" and the
# rewrite-specs SKILL Acceptance criteria. Forward-looking: ledgers dated before the
# cutoff are grandfathered (the convention shipped on the cutoff date). Update the
# cutoff only when the convention itself changes in a way historical ledgers cannot
# satisfy; otherwise the cutoff is stable.
preamble_cutoff='2026-05-05'
errors_before=$errors
if [ -d docs/history/delta-ledgers ]; then
  preamble_check_count=0
  preamble_skipped_count=0
  for ledger in docs/history/delta-ledgers/*.md; do
    [ -e "$ledger" ] || continue
    base=$(basename "$ledger" .md)
    date_prefix=${base:0:10}
    if [[ ! "$date_prefix" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      continue
    fi
    if [[ "$date_prefix" < "$preamble_cutoff" ]]; then
      preamble_skipped_count=$((preamble_skipped_count + 1))
      continue
    fi
    preamble_check_count=$((preamble_check_count + 1))
    if ! grep -qE '^## Delta at a glance' "$ledger"; then
      fail "$ledger missing required '## Delta at a glance' preamble (per references/templates/design-delta-ledger.md §Delta at a glance; rule applies to ledgers dated >= $preamble_cutoff)"
    fi
  done
  if [ "$errors" -eq "$errors_before" ]; then
    if [ "$preamble_check_count" -eq 0 ]; then
      ok "Delta at a glance preamble check: no ledgers dated >= $preamble_cutoff present yet (cutoff active; $preamble_skipped_count grandfathered)"
    else
      ok "Delta at a glance preamble present in all $preamble_check_count delta-ledger files dated >= $preamble_cutoff ($preamble_skipped_count grandfathered)"
    fi
  fi
fi

# 14. PLUGIN_ROOT_PATHS: no hardcoded absolute paths in skills/, agents/, references/.
# Per docs/substrate/invariants/PLUGIN_ROOT_PATHS.md. Excludes lines inside fenced code
# blocks and lines marked as anti-pattern examples (so the rule's own anti-pattern
# documentation doesn't trip the rule).
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
