# Rewrite Validation Review — cohesive:init + substrate-vocabulary (pass 2)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** Phase 1 pass A on branch `design/init-and-substrate-vocabulary` (pass 2 of internal repair loop); design delta ledger at `docs/history/delta-ledgers/2026-05-06-init-and-substrate-vocabulary.md`

**Status:** Issues Found

## Executive judgment

The rewrite lands a coherent new skill with a defensible Rosetta Stone pedagogy, a well-shaped translation table, and substrate-first edits in skills.md / handoffs.md / router.md / skill-section-presence.md. Pass-2 closed every named pass-1 finding cleanly. But three sweep failures in surfaces the rewrite *did* edit (ARCHITECTURE.md three-tier paragraph, the `### cohesively` Purpose in skills.md, the README's `skills/` tree) leave a future contributor with internally contradictory skill counts and a route enumeration that omits the new skill.

## Delta at a glance

(Full preamble matches `docs/history/delta-ledgers/2026-05-06-init-and-substrate-vocabulary.md` lines 9-30.)

## Blocking issues

### B1. ARCHITECTURE.md three-tier paragraph contradicts §"v0.1 scope" on skill count

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** Line 11 says "the session-start orientation skill (`using-cohesive`), the router (`cohesively`), and **eight workflow subskills make ten skills total**"; line 86 says "11 skills" and enumerates init. A future contributor reading top-down lands on the wrong count first.
- **Evidence:** `ARCHITECTURE.md:11` vs `:86`.
- **Recommended fix:** Edit line 11 to "the session-start orientation skill (`using-cohesive`), the router (`cohesively`), the adoption skill (`init`), and eight workflow subskills make eleven skills total."

### B2. `### cohesively` per-skill section in skills.md still names "seven canonical routes" (omits `init`)

- **Severity:** Blocker
- **Category:** Spec drift / Locality
- **Why it matters:** `docs/substrate/architecture/skills.md` is the canonical per-skill design layer. Its `### cohesively` Purpose enumerates exactly seven routes, while every other surface in the same rewrite — the cohesively SKILL.md body, router.md (8-row dispatch contract), and even skills.md's own §"Why `using-cohesive` is separate from `cohesively`" prose — disagree on whether init is a route. Lens 14 mismatch.
- **Evidence:** `skills.md:249` ("seven canonical routes") and `:49` ("seven canonical routes"). Cf. `cohesively/SKILL.md:133` (8 routes including `init`); `router.md:62` (init dispatch row).
- **Recommended fix:** Update both occurrences to "eight canonical routes (`design`, `review (codebase)`, `review (diff)`, `audit (substrate)`, `rewrite-only`, `implement`, `init`, `artifact`)".

### B3. README §"What's in the box" `skills/` tree omits `init/`

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** README is named in §"Files rewritten" of the ledger. §"Main commands" was updated to add `/cohesive:init`; §"What's in the box" `skills/` tree (lines 127-139) was not — lists 10 skills with no `init/`. A first-time reader gets a contradictory inventory.
- **Evidence:** `README.md:127-139` (skills tree without init) vs `:40-46` (Main commands with init).
- **Recommended fix:** Add `init/` to the skills tree with a one-line gloss.

## Important issues

### I1. `skill-section-presence.md` History footer doesn't record the init addition

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** §"Cells" tables and lead are correctly extended; §"History" still records "skill count 8 → 10" without the 2026-05-06 entry naming the init addition.
- **Evidence:** `skill-section-presence.md:85`.
- **Recommended fix:** Add a 2026-05-06 History entry naming the init addition and citing the delta ledger.

### I2. `init/SKILL.md` draft template still uses old "What it earns over a 'rule'" column name

- **Severity:** Low
- **Category:** Vague language
- **Why it matters:** Pass-2 renamed the vocabulary table column to "What this earns" but `init/SKILL.md:83` (draft-file render template) still emits `**What it earns over a "rule":**`. Init will write drafts with the old framing the table no longer carries.
- **Evidence:** `init/SKILL.md:83`.
- **Recommended fix:** Update the SKILL.md draft template literal to `**What this earns:**`.

### I3. `Detected existing files` warns on `docs/specs/` but Hard constraint #1 doesn't classify it

- **Severity:** Low
- **Category:** Domain model
- **Why it matters:** Process Step 0 and Output format §"Detected existing files" both name `docs/specs/` as warn-and-proceed; Hard constraint #1's enumeration is `docs/substrate/`, `docs/adr/`, `docs/design/`, `docs/decisions/`. Reader can't tell where `docs/specs/` falls cleanly.
- **Evidence:** `init/SKILL.md:20,46,163`.
- **Recommended fix:** In Hard constraint #1, name `docs/specs/` explicitly as detect-and-warn alongside CLAUDE.md/AGENTS.md.

## What looked right

- The substrate-vocabulary.md `Convention` row's inversion convention is named explicitly in §"How to read this table" and pinned again in the row's parenthetical — the load-bearing distinction survives both surfaces.
- The new `init → user-driven keep/reject (adoption)` handoff section in handoffs.md correctly flags itself as a candidate sixth transition shape rather than silently mutating §"The five transition shapes".
- The chat-vs-file surface seam is named explicitly in §"What this skill produces" and again in Acceptance criteria.
- Bounded-proposal-count signaling (`Signals scanned: N total; Drafts surfaced: M (capped at 20)`) closes the user-expectation gap with a chat-trailer line, not a config knob.

### Next

**Disposition:** Repair → re-validate
