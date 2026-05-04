# History

Dated and preserved artifacts. Read for context; not authoritative for current state.

## Contents

- **`initial-design.md`** — the v0.1 design vision (2026-05-04). Preserved as the original ambitious surface; the actual v0.1 implementation took a trimmed shape (see [`/ARCHITECTURE.md`](../../ARCHITECTURE.md)).
- **`plans/`** — dated milestone plans that drove implementation. Frozen after the work shipped.
- **`reviews/`** — outputs of `cohesive-review`. Each is a snapshot in time; later reviews supersede earlier ones rather than editing them.
- **`design-changes/`** — design delta ledgers produced by `rewrite-specs`. Each captures one substrate-rewrite pass.
- **`transcripts/`** — dogfood transcripts of running Cohesive workflows end-to-end. Currently empty; v0.1 release is gated on having at least two.

## What lives here vs. `substrate/`

- **`substrate/`** — current canonical state. Replace-on-update. Authoritative for what the system claims about itself today.
- **`history/`** — dated artifacts. Accumulate-with-date. Authoritative for "what was true / claimed / decided as of this date."

When current state and historical artifact disagree, current state wins. Historical artifacts are not edited to match new state; they are preserved as records of the past.
