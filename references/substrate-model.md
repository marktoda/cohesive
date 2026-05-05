# The substrate model

> The codebase has to remember.

## What "substrate" means

The substrate is everything *around* the implementation that helps future contributors make correct changes. It's how the codebase remembers without depending on a particular human being in the room.

The substrate includes:

- **Specs** — what the system is supposed to do, knowable outside the implementation
- **Tests** — executable claims about behavior the system must hold
- **Behavior matrices** — branchy behavior written down as cases with stable IDs
- **Type boundaries** — where one part of the system promises something to another
- **Database constraints** — invariants the storage layer enforces unconditionally
- **Semantic linters** — automation that encodes institutional knowledge ("dependency X may only be imported through wrapper Y")
- **Architectural seams** — interfaces that minimize required context for safe change
- **CI checks** — gates that catch the mistakes humans and agents predictably make
- **Docs** — the parts of the design that aren't code
- **Incident notes / gotchas** — scars that prevent rediscovering old bugs
- **Naming conventions** — categories the team has agreed are real
- **Examples** — copy-pasteable shapes of correct usage
- **Local development commands** — the team-blessed way to run, build, test, lint

What makes substrate useful is that it survives the original author leaving the room. A convention without enforcement is just a hope. A rule that lives only in the architect's head is one resignation away from being lost.

## Why it matters more in the agentic era

Agents are good at preserving local style and producing locally plausible edits. They are much worse at preserving global rules that aren't visible in the codebase: audit invariants, product-specific bright lines, abstraction boundaries, incident scars, subtle architectural priors.

Code is becoming cheaper to produce. The scarce resource is *confidence* that a change preserves what matters. Substrate is what produces that confidence — for humans, for agents, for the next contributor who has never met the original architect.

Without substrate, a codebase can look healthy while depending on continuous human memory. It can pass its tests while relying on one person to remember which abstractions are forbidden, which race conditions are dangerous, which modules should not be coupled, and which complexity exists because of some painful incident six months ago.

The goal is not just to make the code work. The goal is to make the codebase remember.

## The leverage hierarchy

Different kinds of memory have different durability. From least to most leveraged:

```
Prompt              -> useful once
Review comment      -> useful for one PR
Spec                -> useful for future reasoning
Behavior matrix     -> useful for branchy behavior
Named invariant     -> useful for global rules
Test                -> useful forever
Semantic linter     -> changes the shape of every future PR
Architecture seam   -> reduces required context for future changes
Gotcha note         -> prevents rediscovering old bugs
```

Cohesive's job is to push judgment down this list — turning a one-time prompt into a test, a review comment into a semantic linter, an architectural intuition into a named seam.

## Make judgment executable

Agents do not reliably preserve "the team prefers this" or "we usually avoid that" or "this helper is dangerous unless you know the backstory." They preserve what the system makes visible, testable, and enforceable.

If a rule matters, make it structural:

- **a test** — claims behavior must hold
- **a type** — claims a value can only be a certain shape
- **a database constraint** — claims storage cannot violate it
- **an architectural boundary** — claims a layer cannot be reached from outside
- **a semantic linter** — claims a code pattern is forbidden or required
- **a CI check** — claims a build artifact must satisfy a property
- **a runtime assertion** — claims an invariant holds at a particular path

A normal linter encodes generic engineering rules (no unused variables, no inconsistent formatting). A *semantic* linter encodes institutional knowledge:

- every environment variable referenced in code must appear in the env spec
- every external mutation path must produce an audit event
- dependency X may only be imported through wrapper Y
- every design hook in the index must point to a real spec
- every database constraint must stay aligned with the TypeScript union that represents it

These are not universal truths. They are truths *this* codebase depends on. That is why they matter — and why they are worth automating.

## Architecture as context design

Systems eventually become too complex for one person to hold in their head. They also become too complex for one agent context window. Architecture in the agentic era is increasingly about *context design*: minimizing the amount of context required to make a safe change.

A subsystem should be cohesive enough that a future contributor can understand and modify it locally. The Slack connector should not require understanding the Telegram connector. A classifier change should not require reading every handler in the system. A pure decision function should not require simulating a database, a clock, and three side effects to understand its behavior.

This was always good architecture. The agentic era pushes it further: the architecture is no longer only serving human maintainers, it is serving agents that read bounded context and infer patterns from whatever structure we give them.

It also changes the tradeoff between locality and centralization. Shared abstractions are valuable when the shared contract is real. Premature centralization is dangerous: if an agent fixes Slack by changing a shared base class and breaks Telegram, the abstraction has *increased* the context required to make a safe change. Sometimes local duplication is better than the wrong abstraction.

The pattern Cohesive prefers: make each subsystem understandable in isolation, and enforce cross-subsystem rules mechanically.

## Substrate-first work

The Cohesive default: before changing behavior, look at what the codebase already remembers. Find the spec. Find the tests. Find the invariants and the gotchas. If they're missing, propose adding them *before* the code change. If they exist but are wrong, repair them.

This inverts the usual flow ("write code, then maybe update docs"). The reason is that updates to docs are the cheapest place to discover that an idea is wrong — far cheaper than discovering it in code review or in production. The spec becomes a design surface, not a retrospective explanation.

Specs in this model are not just documentation. A good spec contains enough behavioral truth that an agent could recreate the implementation from it, or port the subsystem to a new language with minimal prompting. The implementation is one realization of the spec, not the only place where the behavior is knowable.

## Why "cohesive"

A cohesive system is one whose parts agree with each other and with the system's stated intent. The substrate is the mechanism that produces cohesion — the connective tissue that keeps specs, code, tests, and architecture aligned over time.

Cohesion is not about cleanliness in the abstract. A cohesive codebase makes common future changes easy, dangerous changes visible, and invalid changes hard to ship. That requires judgment — about which parts of the product will evolve independently, which concepts are stable, which categories are real, which abstractions are premature, and which duplication is buying local clarity.

Those questions have always mattered. In the agentic era, they become more load-bearing because the architecture is not only serving human maintainers anymore.
