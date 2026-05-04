#!/usr/bin/env bash
# Cohesive plugin static validation per spec §25.1.
# Usage: bash scripts/validate_plugin.sh
# Exits 0 on success, 1 on failure. Prints findings.

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLUGIN_ROOT"

errors=0
warnings=0

fail() { echo "❌ $*"; errors=$((errors + 1)); }
warn() { echo "⚠️  $*"; warnings=$((warnings + 1)); }
ok()   { echo "✅ $*"; }

echo "🔍 Validating cohesive plugin at $PLUGIN_ROOT"
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

# 4. Every skill directory has a SKILL.md with frontmatter and description
if [ -d skills ]; then
  shopt -s nullglob
  for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_md="${skill_dir}SKILL.md"
    if [ ! -f "$skill_md" ]; then
      fail "skills/$skill_name/ has no SKILL.md"
      continue
    fi
    # Check frontmatter delimiters at start
    if ! head -1 "$skill_md" | grep -q '^---$'; then
      fail "skills/$skill_name/SKILL.md missing opening --- frontmatter"
      continue
    fi
    # Check name field matches dir
    fm_name=$(awk '/^---$/{c++; next} c==1 && /^name:/{print $2; exit}' "$skill_md")
    if [ -z "$fm_name" ]; then
      fail "skills/$skill_name/SKILL.md missing 'name:' frontmatter field"
    elif [ "$fm_name" != "$skill_name" ]; then
      fail "skills/$skill_name/SKILL.md frontmatter name '$fm_name' does not match directory '$skill_name'"
    fi
    # Check description field present
    if ! awk '/^---$/{c++; next} c==1' "$skill_md" | grep -q '^description:'; then
      fail "skills/$skill_name/SKILL.md missing 'description:' frontmatter field"
    else
      ok "skills/$skill_name/SKILL.md has valid frontmatter"
    fi
  done
fi

# 5. Every agent file has frontmatter with name and description
if [ -d agents ]; then
  for agent_md in agents/*.md; do
    [ -e "$agent_md" ] || continue
    agent_name=$(basename "$agent_md" .md)
    if ! head -1 "$agent_md" | grep -q '^---$'; then
      fail "$agent_md missing opening --- frontmatter"
      continue
    fi
    fm_name=$(awk '/^---$/{c++; next} c==1 && /^name:/{print $2; exit}' "$agent_md")
    if [ -z "$fm_name" ]; then
      fail "$agent_md missing 'name:' frontmatter field"
    elif [ "$fm_name" != "$agent_name" ]; then
      fail "$agent_md frontmatter name '$fm_name' does not match filename '$agent_name'"
    else
      ok "$agent_md has valid frontmatter"
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
# Locks in the verb-noun lexicon `discover-substrate → brainstorm-design → rewrite-specs → validate-rewrite`
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

# 9. Every Cohesive skill description contains at least one substrate-vocabulary token.
# Mitigates the discovery-vs-superpowers gotcha at the trigger-string level: the verb-only
# names (`review-codebase`, `audit-substrate`, etc.) lose Cohesive brand identity in the name
# alone, so the description must carry it. Tokens chosen are the canonical Cohesive vocabulary.
substrate_tokens='substrate|cohesion|cohesive|invariant|gotcha|behavior matrix|spec|rewrite'
for s in "${expected_skills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  description=$(awk '/^---$/{c++; next} c==1 && /^description:/{flag=1} c==1 && flag{print; if (/^[a-z]+:/ && !/^description:/) exit} c>=2{exit}' "$skill_md" | tr '\n' ' ')
  if ! echo "$description" | grep -qiE "$substrate_tokens"; then
    fail "skills/$s/SKILL.md description lacks any substrate-vocabulary token ($substrate_tokens)"
  fi
done

echo ""
if [ "$errors" -eq 0 ]; then
  echo "✅ Validation passed ($warnings warnings)"
  exit 0
else
  echo "❌ Validation failed: $errors errors, $warnings warnings"
  exit 1
fi
