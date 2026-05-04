# [INVARIANT_NAME]

> SHOUTY_CASE name. Stable across the codebase's lifetime — chosen carefully because tests, linters, and reviewers will reference it by this name forever.

## Rule

One sentence. The invariant in its strongest, most specific form.

Example: "Every external mutation must emit an audit event before returning success."

## Scope

### Applies to
- <runtime path 1>
- <runtime path 2>
- ...

### Does not apply to
- <case 1> — <why excluded>
- ...

Explicit non-applicability is as important as applicability. The exclusions tell future contributors when *not* to enforce.

## Why this matters

Why this invariant exists. Often this is a scar: a past incident, a regulatory requirement, a security property the system depends on. The "why" is what makes future contributors respect the rule when it inconveniences them.

## Runtime paths

Every place this invariant must hold:

- **API endpoints:** <which ones; entry points>
- **Background jobs:** <which queues / workers>
- **Agent workflows:** <which workflows / tools>
- **Future runtime paths:** <forms of access not yet built — naming them here means future implementers know to honor the rule>

## Enforcement

How the invariant is structurally enforced (not "the team remembers"):

- **Tests:** <which tests fail when the invariant is violated; ideally one per runtime path>
- **Types:** <type-level enforcement, if any>
- **Constraints:** <DB, schema, runtime constraints>
- **Semantic linters:** <custom checks that catch violations at lint time>
- **Runtime wrappers:** <library functions that all callers must go through>
- **CI checks:** <workflow-level gates>

A convention without enforcement is just a hope. If a row in this table is empty, the invariant is partially aspirational.

## Known bypass risks

Specific, named ways the invariant can be circumvented (intentionally or not):

- <bypass path> — <why it's a risk; what mitigates it>
- ...

Naming bypasses is not weakness — it's substrate. Future contributors will encounter the bypass and need to know whether it's tolerated, mitigated, or actively being closed.

## Review checklist

For reviewers (human or agent) when changes touch a runtime path covered by this invariant:

- [ ] Does the change introduce a new runtime path? If yes, does it honor the invariant?
- [ ] Does the change modify an existing path? If yes, does enforcement still hold?
- [ ] Does the change add a bypass? If yes, is the bypass documented and approved?
- [ ] Does the change update tests/linters that pin this invariant?

## Related

- Other invariants this depends on or conflicts with: <names>
- Behavior matrix cells covered by this invariant: <IDs>
- Gotchas related to past violations: <names>

## History

- YYYY-MM-DD — Created
- YYYY-MM-DD — Strengthened: added runtime wrapper enforcement
- YYYY-MM-DD — Bypass added: <path>, <reason>
