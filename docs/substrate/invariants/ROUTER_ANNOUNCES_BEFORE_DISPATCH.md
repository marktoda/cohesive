# ROUTER_ANNOUNCES_BEFORE_DISPATCH

> The Cohesive router (`cohesively`) emits a one-sentence workflow announcement in chat before invoking any subskill. The announcement form is canonical.

## Rule

Whenever `cohesively` selects a route and is about to dispatch the first subskill, it emits exactly one sentence in this form, before any tool call:

```
I'm treating this as a Cohesive <route> workflow: <subskill-1> → <subskill-2> → <subskill-3>. Reason: <one short clause>.
```

- `<route>` is one of the canonical route names: `design`, `review (codebase)`, `review (diff)`, `review (substrate audit)`, `rewrite-only`, `artifact`.
- `<subskill-1> → <subskill-2> → ...` lists the subskills in the order they will run.
- The reason clause is one sentence, not a paragraph.

The announcement is plain text, not a comment, not buried in a tool call.

## Scope

### Applies to
- Every invocation of `skills/cohesively/SKILL.md`
- Every direct invocation of `cohesively`'s routes (the router never silently dispatches)

### Does not apply to
- Subskills invoked directly by the user (e.g., `/cohesive:cohesive-review --scope codebase`). Direct subskill invocations skip the router entirely.
- Subskills chaining further subskills internally (each subskill is responsible for its own announcements per its own conventions, not the router's).
- The router refusing to route (e.g., when it detects a missing approved direction in the rewrite-only route). A refusal message is not a dispatch announcement and follows different conventions.

## Why this matters

The router's value depends on legibility. A user invoking `/cohesive:cohesively review my code` benefits from knowing immediately whether the router heard "review the codebase" (multi-phase architecture review) or "review the diff" (lighter PR review) — the two have very different cost and depth. Without the announcement, the user finds out only by watching subskill outputs scroll by.

The announcement also serves substrate review: dogfood transcripts (`docs/history/transcripts/`) are checkable for invariant compliance with a single grep for the canonical opening sentence. Without the canonical form, transcripts can't be machine-validated.

The self-review on 2026-05-04 noted that this rule lived in prose at `cohesively/SKILL.md:83` and again in the Red flags at line 127 — but with no structural enforcement, a future router edit could silently break it. Promoting to a named invariant + validator check is the substrate fix.

## Where this rule must hold

- The body of `${CLAUDE_PLUGIN_ROOT}/skills/cohesively/SKILL.md` must specify the announcement format.
- Every transcript checked into `docs/history/transcripts/` that captures a router invocation must show the announcement at the top of the transcript section corresponding to the router turn.

## Enforcement

- **Tests:** none yet. V1 will add a transcript-shape check: any `docs/history/transcripts/<file>.md` whose body shows a `cohesively` invocation must contain the canonical opening sentence within the first ~10 lines of that turn.
- **Semantic linters:** `scripts/validate_plugin.sh` greps `skills/cohesively/SKILL.md` for the canonical announcement template (regex anchored on "I'm treating this as a Cohesive" + the route name list) and fails if missing or modified without updating the invariant.
- **CI checks:** wired through `validate_plugin.sh` once `.github/workflows/validate.yml` lands.

Behavioral enforcement (does the router actually announce in practice?) is verified by transcript dogfooding. Each new transcript is an integration test for this invariant.

## Known bypass risks

- **A future contributor adds a route but forgets to update the route list.** The announcement format would still hold for existing routes. Mitigated by `docs/substrate/matrices/router.md`, which enforces that every route gets a row and a corresponding announcement template.
- **A user invokes a subskill directly and the router never runs.** Out of scope — the rule is about the router's behavior when it does run.
- **The harness suppresses the chat output.** Theoretical; not observed. If it happens, the invariant still requires the router to attempt the announcement.

## Review checklist

When reviewing a change to `cohesively/SKILL.md`:

- [ ] Is the canonical announcement form preserved exactly? ("I'm treating this as a Cohesive <route> workflow: ...")
- [ ] If a new route is added: does the announcement template show how the new route names itself?
- [ ] Is the announcement still ordered before any subskill dispatch instruction?
- [ ] Is `docs/substrate/matrices/router.md` updated to include the new route?

When reviewing a new transcript checked into `docs/history/transcripts/`:

- [ ] Does the router turn open with the canonical sentence?
- [ ] Does the named route match a row in `docs/substrate/matrices/router.md`?

## Related

- **`docs/substrate/matrices/router.md`** — the behavior matrix for router routing decisions; cells reference this invariant.
- **`references/skill-conventions.md`** — names this rule for any future skill that takes a "router-like" role.
- **Self-review** flagged the rule as folklore-only.

## History

- 2026-05-04 — Created. Promoted from `cohesively/SKILL.md:83` prose to a named invariant.
