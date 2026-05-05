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
for d in skills agents hooks commands references scripts; do
  if [ -d ".claude-plugin/$d" ]; then
    fail "Component dir .claude-plugin/$d should be at plugin root, not inside .claude-plugin/"
  fi
done

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
  while IFS= read -r ref; do
    # Strip surrounding chars commonly used in markdown
    ref_clean=$(echo "$ref" | sed -E 's/[`\)\]"\.,;:]+$//')
    if [ ! -e "$ref_clean" ]; then
      warn "skill references missing path: $ref_clean"
    fi
  done < <(grep -rhoE '(references|templates)/[A-Za-z0-9_./-]+\.md' skills/ 2>/dev/null | sort -u || true)
fi

# 7. Scripts are executable
if [ -d scripts ]; then
  for script in scripts/*.sh scripts/*.py; do
    [ -e "$script" ] || continue
    if [ ! -x "$script" ]; then
      warn "$script is not executable (chmod +x)"
    fi
  done
fi

# 8. v0.1 skill set: the 8 expected skills are present.
# Locks in the verb-noun lexicon `discover-substrate -> brainstorm-design -> rewrite-specs -> validate-rewrite`
# plus standalone diagnostics `review-codebase`, `review-diff`, `audit-substrate`, and the router `cohesively`.
expected_skills=(
  cohesively
  discover-substrate
  brainstorm-design
  rewrite-specs
  validate-rewrite
  review-codebase
  review-diff
  audit-substrate
)
for s in "${expected_skills[@]}"; do
  if [ ! -f "skills/$s/SKILL.md" ]; then
    fail "expected skill missing: skills/$s/SKILL.md"
  fi
done

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
for s in "${expected_skills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  description=$(extract_description "$skill_md")
  if ! echo "$description" | grep -qiE "$substrate_tokens"; then
    fail "skills/$s/SKILL.md description lacks any substrate-vocabulary token ($substrate_tokens)"
  fi
done

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

# 10. Canonical prereq-detection question in subskills with a discover-substrate or
# brainstorm-design prereq. Per references/skill-conventions.md §"Canonical prereq-detection
# question". Stable opening: a blockquote line beginning `> "I see we're about to run <skill>.`
prereq_subskills=(
  brainstorm-design
  rewrite-specs
  review-codebase
  review-diff
  audit-substrate
)
for s in "${prereq_subskills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  if ! grep -qE "^[[:space:]]*> \"I see we're about to run $s\." "$skill_md"; then
    fail "skills/$s/SKILL.md missing canonical prereq-detection question (per references/skill-conventions.md §Canonical prereq-detection question)"
  fi
done

# 11. Fresh-eyes preamble bullet verbatim across reviewer agent files.
# Per references/reviewer-agent-template.md §"The fresh-eyes preamble".
fresh_eyes_bullet='Inherit conversation context from the calling skill. Treat your input prompt as the entire context.'
if [ -d agents ]; then
  for agent_md in agents/*.md; do
    [ -e "$agent_md" ] || continue
    if ! grep -qF "$fresh_eyes_bullet" "$agent_md"; then
      fail "$agent_md missing fresh-eyes preamble bullet (per references/reviewer-agent-template.md §The fresh-eyes preamble)"
    fi
  done
fi

# 12. "Recommended next Cohesive skill" footer in every persisting skill body.
# Per references/skill-conventions.md §"Recommended-next-skill footer".
# The router (cohesively) is exempt: its output is a one-sentence announcement.
persisting_skills=(
  discover-substrate
  brainstorm-design
  rewrite-specs
  validate-rewrite
  review-codebase
  review-diff
  audit-substrate
)
for s in "${persisting_skills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  if ! grep -qE '^### Recommended next Cohesive skill' "$skill_md"; then
    fail "skills/$s/SKILL.md missing '### Recommended next Cohesive skill' footer (per references/skill-conventions.md §Recommended-next-skill footer)"
  fi
done

# 13. PLUGIN_ROOT_PATHS: no hardcoded absolute paths in skills/, agents/, references/.
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
fi

echo ""
if [ "$errors" -eq 0 ]; then
  echo "[ OK ] Validation passed ($warnings warnings)"
  exit 0
else
  echo "[FAIL] Validation failed: $errors errors, $warnings warnings"
  exit 1
fi
