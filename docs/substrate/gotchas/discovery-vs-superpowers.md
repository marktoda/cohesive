# Gotcha: Cohesive's `discover-substrate` and Superpowers' research/exploration skills compete for the same trigger surface

## Symptom

A user with both Cohesive and Superpowers installed asks "what's in this codebase?" or "explore this area before we change it." Two skills from two different plugins both match the request. Either:

- Claude invokes the Superpowers research/exploration skill instead of `cohesive:discover-substrate`, missing the substrate-first framing (specs, named invariants, gotchas, semantic linters) that Cohesive's downstream skills depend on.
- Claude invokes both, producing duplicate work and conflicting framings.
- Claude picks based on description-string match rather than user intent, and the choice is not deterministic across sessions.

Downstream Cohesive skills (`brainstorm-design`, `review-codebase`, `review-diff`) then produce degraded output because they expected a substrate map shaped a particular way.

## Why it happened

Cohesive and Superpowers have overlapping but distinct concepts of "discover the codebase":

- **Superpowers** treats discovery as part of disciplined implementation: read the relevant files, understand the patterns, prepare to code.
- **Cohesive** treats discovery as substrate inventory: name the specs/invariants/matrices/gotchas, separate "found" from "missing," recommend the next Cohesive skill.

Both are legitimate. Both produce useful outputs. They are not interchangeable: Cohesive's downstream skills consume Cohesive-shaped reports; Superpowers' downstream skills consume Superpowers-shaped reports.

Plan §7 risks list named this: "Discovery competition with superpowers when both installed. Description copy must distinguish substrate/architecture work from implementation discipline." The plan named the risk; the description copy in v0.1 partially handles it but doesn't make the distinction sharp enough that Claude reliably picks the right one.

## Tempting wrong fix

Rename `discover-substrate` to something more visibly Cohesive-specific (e.g., `substrate-inventory`, `cohesive-discover`), or namespace harder, or make Cohesive's description string aggressively claim discovery.

Why it's wrong:

- The skill's name *is* already namespaced (`cohesive:discover-substrate`). The competition is at the natural-language trigger level, not the name level.
- Aggressively claiming discovery in Cohesive's description forces the user to memorize which plugin owns which intent — defeating the whole point of natural-language skill triggering.
- The skills are *not* the same. Renaming one to look less like the other doesn't help the user who has a real choice to make.

## Correct pattern

Make the choice explicit at the route level, not at the description-match level.

1. **Cohesive's `discover-substrate` description names what it is for: substrate-first work.** It should not claim general discovery. Triggers like "explore the codebase" should not be in Cohesive's trigger phrases. The skill is for substrate inventory specifically, before `brainstorm-design` / `rewrite-specs` / `review-codebase` / `review-diff` / `audit-substrate`.

2. **The router (`cohesively`) is the canonical entry point for Cohesive workflows.** When the user invokes `/cohesive:cohesively review my code`, the router selects `discover-substrate` deterministically as part of the route — there is no competition because the router decided. Users who want Cohesive's framing should invoke the router; users who want Superpowers' framing should invoke Superpowers' skills directly.

3. **The session-start orientation skill `using-cohesive` competes natively with `superpowers:using-superpowers` for the harness's bootstrap loading slot.** This is the structural mitigation for the description-match-level competition the router alone cannot solve: a user who never explicitly invokes `cohesively` still gets the right framing because `using-cohesive` fires at session start (or whenever its frontmatter trigger matches a substrate-shaped request) and orients Claude toward Cohesive vs Superpowers. The skill body lives at `${CLAUDE_PLUGIN_ROOT}/skills/using-cohesive/SKILL.md`; the seam is documented in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` §"using-cohesive → cohesively (session-start orientation)". The substrate-narrowing rule from item 1 above applies double to `using-cohesive`'s frontmatter description: any drift toward generic discovery triggers re-opens the competition this skill exists to close.

4. **Mixed-stack workflows compose explicitly.** A user doing implementation after Cohesive design work runs Cohesive first (`discover-substrate` / `brainstorm-design` / `rewrite-specs` / `validate-rewrite`), then Superpowers (`writing-plans` / `executing-plans` / TDD). Each plugin owns its phase. The handoff is a user action, not a skill auto-routing.

5. **When a user asks a discovery-shaped question without invoking either router**, Claude prefers the user's expressed intent. "What does this codebase remember?" is a Cohesive question. "Where does the auth flow live?" is a Superpowers question. The trigger phrases reflect the difference.

## Related convention

- **Router announcement** ([`docs/substrate/conventions/skill-shape.md`](../conventions/skill-shape.md) §"Router conventions") — the router's announcement makes the skill choice visible before any subskill runs, so the user can correct mid-route if Cohesive was the wrong framing.

## Tests / checks that preserve this

- **Substrate-vocabulary token check (`scripts/validate_plugin.sh` check 9a):** every Cohesive skill description must contain at least one of `substrate`, `cohesion`, `cohesive`, `invariant`, `gotcha`, `behavior matrix`, `spec`, `rewrite`. Necessary but not sufficient.
- **Negative-trigger check (`scripts/validate_plugin.sh` check 9b):** Cohesive skill descriptions must not use these bare quoted trigger phrases that overlap with Superpowers' code-reviewer surface:
  - `"review the codebase"`
  - `"review the architecture"`
  - `"is this codebase healthy"`
  - `"review the code"`
  Tightened forms pass: `"review the codebase for cohesion"`, `"review the architecture for cohesion"`, `"is this codebase cohesion-healthy"`. The narrowing clause is what disambiguates Cohesive from Superpowers' generic code review.
- **Router-driven invocation as the recommended path:** README and AGENTS.md guidance both direct users to invoke `cohesively` rather than picking subskills directly.
- **Manual scenario test (planned):** with both plugins installed, the test prompt "what's in this codebase" should not deterministically pick either; "audit substrate" should pick Cohesive; "explore the auth flow" should pick Superpowers.

## When this was discovered

- Date: 2026-05-04
- Source: plan §7 risks list (recognized at design time); confirmed by self-review (`docs/history/reviews/2026-05-04-self-review.md`).
- One-line summary: two plugins with overlapping discovery concepts compete at the trigger level; documenting the seam (router as canonical entry, descriptions narrow to substrate-specific work) prevents the wrong skill from being chosen.

## Notes for future contributors

- Resist the urge to "win" the trigger competition. Both plugins are legitimate; the goal is to make the choice obvious, not to capture user intent away from Superpowers.
- When adding new Cohesive skills with description triggers, audit them against Superpowers' published descriptions to ensure the seams stay clean.
- The "correct pattern" section above should be re-validated whenever Superpowers ships a new discovery-shaped skill or Cohesive ships a new V1 skill in the discovery family.
