#!/usr/bin/env bash
# Cohesive plugin static validation.
#
# Enforces:
#   - Named invariant PLUGIN_ROOT_PATHS (no hardcoded absolute paths)
#   - Named invariant SKILL_DESIGN_DOC_SECTION (every skill dir has a `### <name>`
#     section in docs/substrate/architecture/skills.md)
#   - Plugin-manifest shape (plugin.json / marketplace.json validity)
#   - Skill / agent frontmatter shape (delegated to scripts/_frontmatter_check.py)
#   - The v0.1 expected skill set
#   - Substrate-vocabulary tokens in skill descriptions
#   - Negative-trigger discipline (descriptions avoid generic-review phrases without
#     cohesion-narrowing language)
#   - Canonical prereq-detection question (currently no skill carries a discovery-state prereq —
#     discovery is dispatched internally by consumer skills as of 2026-05-06; check structure
#     preserved against future regressions)
#   - Fresh-eyes preamble bullet verbatim across reviewer agents
#   - "### Next" footer in every persisting skill body (renamed from "Recommended next Cohesive skill" in audience-seam rewrite)
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

# 8. v0.1 skill set: the 11 expected skills are present.
# Locks in the verb-noun lexicon `discover-substrate -> brainstorm-design -> rewrite-specs -> validate-rewrite`
# plus standalone diagnostics `review-codebase`, `review-diff`, `audit-substrate`, the adoption skill `init`
# (added 2026-05-06 in init-and-substrate-vocabulary), the router `cohesively`, and the session-start
# orientation skill `using-cohesive` (added 2026-05-05 in skill-pack-flow-tightening).
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

# 10. Canonical prereq-detection question in subskills with a substrate-discovery prereq.
# Per docs/substrate/conventions/skill-shape.md §"Canonical prereq-detection question". Stable
# opening: a blockquote line beginning `> "I see we're about to run <skill>.`
#
# As of the 2026-05-06 discovery-as-internal-step rewrite, brainstorm-design / audit-substrate /
# review-codebase / review-diff dispatch discover-substrate internally (Step 0 / Phase 1.0) and
# no longer carry the canonical discovery-state question — discovery is now plumbing internal to
# each consumer skill rather than a user-visible prereq. Their canonical questions are now about
# change-surface or scope (asked only when the user's request is unclear), not discovery state.
# rewrite-specs is excluded because its prereq is a chosen-direction (a different question),
# not discovery state.
#
# Path-prereq subskills (implement-cohesively, validate-rewrite) are also excluded — their prereq
# is a file path, not session state, so they use directive errors per skill-shape.md §"Path
# prereqs use directive errors, not the canonical question". See check 10b below.
#
# The array is intentionally empty at v0.1.5 — no skill carries the discovery-state canonical
# question anymore. The check is preserved so a future skill that re-introduces the discovery-
# state prereq pattern would land in this array.
discovery_prereq_subskills=()
errors_before=$errors
for s in "${discovery_prereq_subskills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  if ! grep -qE "^[[:space:]]*> \"I see we're about to run $s\." "$skill_md"; then
    fail "skills/$s/SKILL.md missing canonical prereq-detection question (per docs/substrate/conventions/skill-shape.md §Canonical prereq-detection question)"
  fi
done
if [ "${#discovery_prereq_subskills[@]}" -eq 0 ]; then
  ok "discovery-prereq subskills array is empty (discovery is internal to consumer skills as of 2026-05-06)"
elif [ "$errors" -eq "$errors_before" ]; then
  ok "all ${#discovery_prereq_subskills[@]} discovery-prereq subskills have the canonical prereq-detection question"
fi

# 10b. Path-prereq subskills carry a directive-error template instead of the canonical question.
# Per docs/substrate/conventions/skill-shape.md §"Path prereqs use directive errors, not the
# canonical question". Three checks, all required:
#   (a) positive: a "directive error" phrase appears in the body;
#   (b) positive: an upstream "Run cohesive:<skill>" instruction appears in the body;
#   (c) negative: neither the canonical-question literal nor the legacy "stop and ask" phrasing
#       appears anywhere in the body — the canonical question and the directive error are
#       mutually exclusive prereq-handling shapes, so any path-prereq subskill carrying both
#       is internally incoherent. The negative check exists to catch the regression class
#       where Hard constraint #1 prescribes the directive error but Step 0 (or any other
#       section) silently re-introduces the session-prereq fallback.
path_prereq_subskills=(
  validate-rewrite
  implement-cohesively
)
errors_before=$errors
for s in "${path_prereq_subskills[@]}"; do
  skill_md="skills/$s/SKILL.md"
  [ -f "$skill_md" ] || continue
  if ! grep -qE "directive error" "$skill_md"; then
    fail "skills/$s/SKILL.md missing directive-error template (per docs/substrate/conventions/skill-shape.md §Path prereqs use directive errors, not the canonical question)"
    continue
  fi
  if ! grep -qE "Run \`?cohesive:" "$skill_md"; then
    fail "skills/$s/SKILL.md directive-error template does not name an upstream cohesive: skill"
    continue
  fi
  if grep -qE "^[[:space:]]*> \"I see we're about to run $s\." "$skill_md"; then
    fail "skills/$s/SKILL.md carries the canonical clarifying question alongside the directive-error template (path-prereq subskills must not have both — see skill-shape.md §Path prereqs use directive errors)"
    continue
  fi
  if grep -qE "stop and ask" "$skill_md"; then
    fail "skills/$s/SKILL.md carries 'stop and ask' phrasing alongside the directive-error template (path-prereq subskills must use directive errors only — see skill-shape.md §Path prereqs use directive errors)"
  fi
done
[ "$errors" -eq "$errors_before" ] && ok "all ${#path_prereq_subskills[@]} path-prereq subskills carry directive-error templates"

# 11. Fresh-eyes preamble bullet verbatim across reviewer agent files.
# Per docs/substrate/conventions/reviewer-agent-shape.md §"The fresh-eyes preamble".
fresh_eyes_bullet='Inherit conversation context from the calling skill. Treat your input prompt as the entire context.'
if [ -d agents ]; then
  errors_before=$errors
  agent_count=0
  for agent_md in agents/*.md; do
    [ -e "$agent_md" ] || continue
    agent_count=$((agent_count + 1))
    if ! grep -qF "$fresh_eyes_bullet" "$agent_md"; then
      fail "$agent_md missing fresh-eyes preamble bullet (per docs/substrate/conventions/reviewer-agent-shape.md §The fresh-eyes preamble)"
    fi
  done
  [ "$errors" -eq "$errors_before" ] && ok "all $agent_count reviewer agents carry the fresh-eyes preamble bullet verbatim"
fi

# 12. "### Next" footer in every persisting skill body (renamed from "Recommended next Cohesive skill" in the audience-seam rewrite per docs/substrate/conventions/audience-separation.md).
# Per docs/substrate/conventions/skill-shape.md §"Recommended-next-skill footer".
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
    fail "skills/$s/SKILL.md missing '### Next' footer (per docs/substrate/conventions/skill-shape.md §Next-step footer; renamed from 'Recommended next Cohesive skill' in the audience-seam rewrite — see docs/substrate/conventions/audience-separation.md)"
  fi
done
[ "$errors" -eq "$errors_before" ] && ok "all ${#persisting_skills[@]} persisting skills have the '### Next' footer"

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

# 13b. Voice-imperative grep, skills: every non-router non-orientation skills/*/SKILL.md
# body (outside fenced code blocks) contains the literal imperative directing the model
# to load the voice guide before rendering chat output. Per references/output-voice.md
# and docs/substrate/gotchas/style-guide-rot.md §"Correct pattern". TWO exemptions per
# docs/substrate/conventions/skill-shape.md §"When sections may differ": the router
# `cohesively` and the session-start orientation skill `using-cohesive` (both have
# render budgets too small to need the imperative; their dispatched subskills carry
# the voice load).
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

# 13e. Implementation-path coverage in validate-rewrite Approved footer.
# Per docs/substrate/gotchas/no-implementation-handoff.md and the validate-rewrite
# Output format. The Approved verdict footer must document the default
# implementation path plus the canonical conditional alternatives, so a reader
# scanning the skill body can see the full set of moves the user might pick from
# (even when only a subset render in any given Approved trailer per the
# triggering conditions in skills/validate-rewrite/SKILL.md §"Conditional
# alternatives"). The render shape evolved through several passes:
#   - decide-lock-build rewrite: four-row table → default-recommend pattern
#     (one default + alternatives behind a `(other options)` disclosure per
#     references/templates/chat-trailer.md §"Default-recommend rule")
#   - conditional-alternatives rewrite: dropped "Schedule for later" entirely
#     (it was always-trivially-live, i.e. the user can always do nothing);
#     renamed "Hand off to Superpowers without delta-coverage discipline" to
#     "Implement with Superpowers directly" (user-facing language); made the
#     remaining three alternatives (Land specs first / Implement with
#     Superpowers directly / Re-decide) conditionally rendered.
# The check enforces the post-rewrite vocabulary.
errors_before=$errors
if grep -qF '`cohesive:implement-cohesively`' skills/validate-rewrite/SKILL.md \
   && grep -qF 'Land specs first' skills/validate-rewrite/SKILL.md \
   && grep -qF 'Implement with Superpowers directly' skills/validate-rewrite/SKILL.md \
   && grep -qF '`superpowers:writing-plans`' skills/validate-rewrite/SKILL.md \
   && grep -qF 'Re-decide' skills/validate-rewrite/SKILL.md; then
  ok "validate-rewrite Approved footer covers the default + canonical conditional alternatives (Land specs first / Implement with Superpowers directly / Re-decide)"
else
  fail "skills/validate-rewrite/SKILL.md missing one or more of the canonical implementation paths. The default + three conditional alternatives must all be named in the skill body: cohesive:implement-cohesively (default), Land specs first, Implement with Superpowers directly, superpowers:writing-plans, Re-decide. See §\"Conditional alternatives\" and the gotcha at docs/substrate/gotchas/no-implementation-handoff.md."
fi

# 13f. implement-cohesively cites IMPLEMENTATION_PLAN_COVERS_DELTA + large-delta-mega-plan.
# Per docs/substrate/gotchas/no-implementation-handoff.md "Tests / checks that preserve this"
# bullet 3. The skill body's Process / Hard constraints must reference the named invariant
# (single-pass coverage rule) and the abandonment-cliff gotcha (Step 1 budget gate)
# so a reader of the SKILL alone can trace to the structural pins.
errors_before=$errors
if grep -qF 'docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md' skills/implement-cohesively/SKILL.md \
   && grep -qF 'docs/substrate/gotchas/large-delta-mega-plan.md' skills/implement-cohesively/SKILL.md; then
  ok "implement-cohesively cites IMPLEMENTATION_PLAN_COVERS_DELTA invariant and large-delta-mega-plan gotcha"
else
  fail "skills/implement-cohesively/SKILL.md must cite docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md AND docs/substrate/gotchas/large-delta-mega-plan.md (per docs/substrate/gotchas/no-implementation-handoff.md). One or both citations are missing."
fi

# 13g. Literal bypass-acknowledgment string in validate-rewrite.
# Per docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md §Known bypass risks,
# docs/substrate/gotchas/no-implementation-handoff.md "Tests / checks that preserve
# this" bullet 4, and docs/substrate/architecture/handoffs.md §"Post-implementation
# review entry point". The SKILL body must carry the literal string the Output
# format renders to the transcript when the user picks the "Implement with
# Superpowers directly" alternative. The string was rewritten in the
# conditional-alternatives pass to drop the `IMPLEMENTATION_PLAN_COVERS_DELTA`
# invariant token from chat (per references/output-voice.md rule 2c —
# substrate-shape vocabulary stays out of chat); the invariant doc remains the
# substrate-side record.
errors_before=$errors
bypass_string="Implementing with plain Superpowers — Cohesive's verification of the rewrite doesn't apply. Run cohesive:review-diff after implementation to catch any drift."
if grep -qF "$bypass_string" skills/validate-rewrite/SKILL.md; then
  ok "validate-rewrite carries the literal bypass-acknowledgment string (with post-impl verification imperative)"
else
  fail "skills/validate-rewrite/SKILL.md missing the literal bypass-acknowledgment string (per docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md §Known bypass risks and docs/substrate/architecture/handoffs.md §'Post-implementation review entry point'). Expected the full string '$bypass_string' to appear in the SKILL body."
fi

# 13h. "Delta at a glance" preamble in delta-ledger files dated on or after the cutoff.
# Per references/templates/design-delta-ledger.md §"Delta at a glance" and the
# rewrite-specs SKILL Acceptance criteria. Forward-looking: ledgers dated before the
# cutoff are grandfathered (the convention shipped on the cutoff date). Update the
# cutoff only when the convention itself changes in a way historical ledgers cannot
# satisfy; otherwise the cutoff is stable.
preamble_cutoff='2026-05-05'
errors_before=$errors
warnings_before_preamble=$warnings
if [ -d docs/history/delta-ledgers ]; then
  preamble_check_count=0
  preamble_skipped_count=0
  preamble_malformed_count=0
  for ledger in docs/history/delta-ledgers/*.md; do
    [ -e "$ledger" ] || continue
    base=$(basename "$ledger" .md)
    date_prefix=${base:0:10}
    if [[ ! "$date_prefix" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      preamble_malformed_count=$((preamble_malformed_count + 1))
      warn "$ledger has malformed filename (no leading YYYY-MM-DD prefix per docs/substrate/conventions/substrate-layout.md §Naming); skipped from preamble check"
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
      ok "Delta at a glance preamble check: no ledgers dated >= $preamble_cutoff present yet (cutoff active; $preamble_skipped_count grandfathered, $preamble_malformed_count malformed)"
    else
      ok "Delta at a glance preamble present in all $preamble_check_count delta-ledger files dated >= $preamble_cutoff ($preamble_skipped_count grandfathered, $preamble_malformed_count malformed)"
    fi
  fi
fi

# 13i. DISPATCH_CONTRACT_MIRROR: skills/cohesively/SKILL.md §"Dispatch prompt contract"
# and docs/substrate/matrices/router.md §"Dispatch prompt contract (per route)" must
# enumerate the same set of routes. Per docs/substrate/architecture/handoffs.md and the
# 2026-05-05 skill-pack-flow-tightening rewrite (closing review finding 1: prose-only
# parity is one PR away from drift).
extract_routes_from_section() {
  local file="$1"
  local heading="$2"  # exact heading text, e.g. "## Dispatch prompt contract"
  awk -v h="$heading" '
    $0 == h { in_section=1; next }
    in_section && /^## / { in_section=0 }
    in_section && /^[|] `[^`]+`/ {
      if (match($0, /`[^`]+`/)) {
        route = substr($0, RSTART+1, RLENGTH-2)
        sub(/ [(]V1[)]$/, "", route)
        print route
      }
    }
  ' "$file"
}
errors_before=$errors
cohesively_routes=$(extract_routes_from_section skills/cohesively/SKILL.md '## Dispatch prompt contract' | sort -u)
router_routes=$(extract_routes_from_section docs/substrate/matrices/router.md '## Dispatch prompt contract (per route)' | sort -u)
if [ -z "$cohesively_routes" ]; then
  fail "DISPATCH_CONTRACT_MIRROR: extracted no routes from skills/cohesively/SKILL.md §\"Dispatch prompt contract\". The section heading or table format may have drifted. (Check 13i)"
elif [ -z "$router_routes" ]; then
  fail "DISPATCH_CONTRACT_MIRROR: extracted no routes from docs/substrate/matrices/router.md §\"Dispatch prompt contract (per route)\". The section heading or table format may have drifted. (Check 13i)"
elif [ "$cohesively_routes" != "$router_routes" ]; then
  cohesively_only=$(comm -23 <(echo "$cohesively_routes") <(echo "$router_routes") | tr '\n' ' ')
  router_only=$(comm -13 <(echo "$cohesively_routes") <(echo "$router_routes") | tr '\n' ' ')
  fail "DISPATCH_CONTRACT_MIRROR: dispatch-prompt-contract route sets differ between skills/cohesively/SKILL.md and docs/substrate/matrices/router.md. Only in cohesively/SKILL.md: [$cohesively_only]. Only in router.md: [$router_only]. Per docs/substrate/architecture/handoffs.md and the update-both-in-the-same-pass annotation in both surfaces. (Check 13i)"
fi
[ "$errors" -eq "$errors_before" ] && ok "DISPATCH_CONTRACT_MIRROR: route sets in cohesively/SKILL.md and matrices/router.md agree (Check 13i)"

# 13l. Chain-rendering anti-pattern in cohesively/SKILL.md.
# Per the decide-lock-build rewrite (docs/history/delta-ledgers/2026-05-06-decide-lock-build.md
# §"Conceptual changes" row 2 and skills/cohesively/SKILL.md Red flags) and
# docs/substrate/conventions/audience-separation.md §"Gates and reversals". Chain
# rendering — concrete subskill IDs joined by → arrows — was retired from router
# announcements in favor of one-sentence outcome sentences. The check greps for
# "→ <subskill-id>" patterns where subskill-id is one of the eight Cohesive
# subskills; matches outside the Red flags anti-pattern reference fail. The Red
# flag uses generic placeholders (skill-1 / skill-2) so it doesn't match.
errors_before=$errors
subskill_chain_pattern='→ (discover-substrate|brainstorm-design|rewrite-specs|validate-rewrite|implement-cohesively|review-codebase|review-diff|audit-substrate)'
chain_violations=$(grep -nE "$subskill_chain_pattern" skills/cohesively/SKILL.md 2>/dev/null || true)
if [ -n "$chain_violations" ]; then
  fail "Chain-rendering anti-pattern in skills/cohesively/SKILL.md (Check 13l): subskill IDs joined by → arrows render dispatch machinery in user-facing chat output. Lines: $(echo "$chain_violations" | tr '\n' ';'). Retire to one-sentence outcome announcements per skills/cohesively/SKILL.md §\"Output\" canonical announcement template."
else
  ok "Chain-rendering anti-pattern absent from cohesively/SKILL.md (Check 13l)"
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

echo ""
if [ "$errors" -eq 0 ]; then
  echo "[ OK ] Validation passed ($warnings warnings)"
  exit 0
else
  echo "[FAIL] Validation failed: $errors errors, $warnings warnings"
  exit 1
fi
