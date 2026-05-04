# Locality over premature centralization

A bias Cohesive applies whenever a design proposes shared abstractions, base classes, common utilities, or cross-subsystem refactors. The bias is not "never centralize" — it is "centralize only when the shared contract is real and enforceable, and prefer local duplication over the wrong abstraction."

## The principle in one paragraph

Shared abstractions are valuable when the shared contract is real. Premature centralization increases the context required to make a safe change: an agent fixing the Slack connector that has to also understand the Telegram connector, because both inherit from a shared base class, has to hold more in its head than necessary. If the abstraction also encodes constraints the team didn't actually agree on, edits in one subsystem silently break others. Local duplication is sometimes the better choice, especially when the duplicates may evolve independently.

## When centralization is the right call

All four conditions should hold:

1. **The shared contract is real.** Two subsystems are doing the same thing for the same reason, not the same thing for accidentally similar reasons.
2. **The contract is stable.** It won't fork in the next six months as the product evolves.
3. **The contract is enforceable.** Either the shared abstraction makes the contract structural (a type, an interface, a runtime check), or the team has a clear way to detect violation.
4. **The cost of divergence is high.** When subsystems drift, real harm follows — bugs, inconsistent UX, security gaps.

If any of the four is doubtful, the cost of premature centralization is likely to exceed the cost of local duplication.

## When local duplication is the right call

- The two subsystems are *currently* doing similar things but the product roadmap suggests they will diverge.
- The "shared" thing is small — a 5-line helper that's easier to inline than to extract.
- The duplicates encode different reasons that happen to look similar in code shape.
- The team has been burned before by the wrong abstraction in this area.
- Extracting requires inventing a shared concept that doesn't yet have a clean name.

Duplication carries cost: drift, divergent bug-fixes, inconsistency. But the cost is *visible*. The wrong abstraction's cost is invisible — it shows up as "why is this so hard to change?" months later.

## Diagnostic questions

When evaluating a centralization proposal:

- **Could the two subsystems have been written by different teams without consulting each other?** If yes, the similarity may be accidental.
- **Has the team ever wanted to change one subsystem in a way that didn't apply to the other?** If yes, the centralization will eventually fight the change.
- **What would force the abstraction to fork?** Name the future feature that would require subclassing or an `if connector == "slack"` branch. If you can name it easily, the contract isn't stable.
- **Does the abstraction add a vocabulary that isn't already in the team's head?** New shared concepts have to be learned. If the team naturally talks about `IntakeAdapter` already, the concept is real. If you're introducing it for the refactor, the team will have to be taught.

## When duplicate code is signaling something else

Sometimes "similar code in two places" means the *real* shared concept hasn't been named yet — but it isn't the one you'd extract by code-shape similarity. Look for:

- A shared *invariant* both copies are trying to enforce (extract the invariant as a check, not the code)
- A shared *boundary contract* both copies normalize against (extract the contract, leave the implementations local)
- A shared *gotcha* both copies are working around (write the gotcha doc; the working-around stays local until the underlying problem is fixed)

In these cases, the substrate fix is upstream of the code dedup.

## Anti-patterns

### "Code looks the same, must extract"

Visual similarity is the weakest reason to centralize. Two functions that look identical can be doing different things for different reasons in different domains. Extracting them couples those reasons together for the rest of the system's life.

### "Tests cover both, so refactoring is safe"

Tests cover *current* behavior. Centralization is a bet on *future* behavior. Tests that pass after the refactor don't prove the abstraction will hold up as the subsystems evolve.

### "Premature optimization is the root of all evil — and so is duplication"

The original quote is about performance optimization, where the cost of leaving slow code is usually small. Code duplication's cost is usually small too. The cost of the wrong abstraction is large. The aphorisms cancel out; the analysis matters.

### "It's only a base class, easy to undo"

Untangling a base class that has accumulated references in three subsystems is rarely easy. Adding it is much cheaper than removing it.

### "The abstraction will become real once we have three implementations"

Sometimes true, often not. If you don't yet have three implementations, you don't know what the abstraction will need to be. Introducing it now means you're guessing.

## When to revisit

A locality decision should be re-evaluated when:

- A third use case appears that has the same real contract
- The team has *actually* wanted to change all duplicates the same way three or more times
- The duplicates have started to drift in ways that produce bugs
- A new shared concept has emerged from product/domain conversation, not from code-shape

When you do centralize, do it from a position of evidence, not a position of "this might be useful."

## Output integration

`brainstorm-design` and `cohesive-review` use this reference when answering questions about whether a design's locality choice is sound. See pressure-testing questions 13–17 for the specific battery used during design review.
