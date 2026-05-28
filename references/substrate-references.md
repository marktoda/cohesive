# Referencing substrate by category, not by count

Normative for any persisted Cohesive-shaped doc that enumerates substrate types (named invariants, behavior matrices, gotchas, semantic linters, specs, conventions). Loaded at runtime by skills that author substrate (`cohesive:rewrite-specs`, `cohesive:audit-substrate`, `cohesive:init`) and read by reviewer agents that score substrate health (`structure-reviewer`, `substrate-alignment-reviewer`, `spec-cohesion-reviewer`) via the cohesion rubric.

The rule, in one sentence: **when a doc refers to substrate enumerated elsewhere, cite the canonical home of the list — not the cardinality of the list at the moment of writing.**

## Why this exists

Counts are a manual cross-reference. Every "the 7 invariants" written inline is a synchronization point between the prose and the directory listing it summarizes. The directory listing is authoritative; the prose is not. When the inventory changes — a gotcha added, a matrix renamed, an invariant graduated from convention — every count-bearing reference must be re-synced by hand. The count-bearing references are scattered across READMEs, architecture maps, design docs, and skill bodies; nothing greps the cardinality back to its source. Drift is the default outcome, not the exception.

The pattern is structural, not incidental. Each substrate refinement pass introduces new count-drift, because authors writing summary prose reach for cardinality as the easiest way to gesture at "the list." The fix is to push the cardinality back to its canonical home and reference the home instead.

## Constraint counts vs inventory counts

The load-bearing distinction. Not every count is drift bait — some counts are the design itself and load-bearing for the value proposition.

| Count type | Examples | Treatment |
|---|---|---|
| **Constraint count** — the count IS the design constraint. The number expresses a property of the architecture, not a tally of items. | "four-concept core," "seven Tools," "five axioms," "three-tier separation" | **Keep.** The number expresses a design property — "only seven primitives" is a value claim, not an inventory fact. |
| **Inventory count** — a tally of items enumerated elsewhere, where the count happens to be N today but is incidental to the design. | "9 named invariants," "8 gotchas," "the 6 behavior matrices," "ships 7 shipped workflows" | **Replace with categorical reference + canonical-list pointer.** Say "the named invariants" / "the shipped gotchas" / "the behavior matrices" and link to the directory or matrix that lists them. |
| **Per-tier counts in a tiered model** — counts within a layered design. | "5 axiom + 4 shipped-default + 2 opt-in" | **Edge case.** If the count of a *tier* is bounded by design intent (axioms, by definition, are stable across years), keep that count visible. For mutable tiers, soften to a categorical reference ("the shipped defaults," "opt-in invariants") without a number. |

## Worked examples

**Inventory count → categorical reference:**

| Drift-bait | Replacement |
|---|---|
| `Cohesive ships v0.1 with four named invariants:` | `Cohesive ships v0.1 with the following named invariants (categorical reference to the canonical list):` |
| `the 9 Tool-boundary invariants` | `all Tool-boundary invariants ([list](path/to/invariants/))` |
| `the 8 gotchas` | `the documented gotchas ([listing](path/to/gotchas/))` |
| `9 shipped workflows` | `the shipped workflows ([table](path/to/workflows.md))` |
| `the 6 design docs and the 2 invariants by name` | `the design docs and named invariants listed in [README §What's in the box](README.md)` |
| `Read the 4 reviewer outputs` | `Read the reviewer outputs listed in [dispatch.md](path/to/dispatch.md)` |

**Constraint count → keep:**

- "Cohesive's substrate model has a **four-concept core**: invariants, matrices, gotchas, specs." ← The four-ness is a design claim ("we only need four"), not an inventory tally.
- "Three-tier separation." ← The three-ness is the architecture's value prop.
- "Verdict-led skills lead with the verdict within the **first three non-blank lines**." ← The three is a specification of the invariant, not a tally.

## How the rule is loaded

- **At authoring time.** `cohesive:rewrite-specs` cites this doc in §"Rewrite each affected doc to end-state" — when rewriting a normative doc, the rewriter checks each enumeration in the body against the inventory-vs-constraint distinction and replaces inventory counts with categorical references.
- **At review time.** `references/cohesion-rubric.md` axis 1 (Spec coherence) names inventory-count drift as a drift signal. Reviewer agents (`structure-reviewer`, `substrate-alignment-reviewer`, `spec-cohesion-reviewer`) flag inventory-count references in user docs as a `Drifting` finding when the count diverges from the canonical list — and as a `Healthy` confirmation when prose references the list categorically.
- **At discovery time.** `cohesive:audit-substrate` reads this doc when surfacing drift signals — inventory-count phrasings are one of the patterns the audit flags as latent substrate drift.

## What this doc is *not*

- Not a rule for *all* counts. Constraint counts (architectural value props) stay. Only inventory counts (tallies of items enumerated elsewhere) drift.
- Not a forbidden-phrasings list. The distinction is semantic, not syntactic — `"four invariants"` is forbidden when it tallies the directory listing, fine when it states a design constraint. Reviewers judge by intent, not regex.
- Not a chat-render rule. Chat-render voice is governed by [`output-voice.md`](output-voice.md); this rule applies to persisted-file prose (READMEs, architecture maps, design docs, skill bodies).

## Related substrate

- [`cohesion-rubric.md`](cohesion-rubric.md) §"1. Spec coherence" — the review-time enforcement seam
- [`substrate-vocabulary.md`](substrate-vocabulary.md) — the canonical types this rule applies to (named invariants, behavior matrices, gotchas, semantic linters, specs, conventions)
- [`output-voice.md`](output-voice.md) — sister rule for chat-render prose (not persisted-file prose)
