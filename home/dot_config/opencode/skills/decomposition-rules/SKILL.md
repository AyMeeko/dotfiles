---
name: decomposition-rules
description: Use when defining implementation steps and commit boundaries; keep each commit coherent, independently evaluable, and verifiable.
---

# Independently evaluable commits

Discover the complete inventory before ordering work. Order by actual dependency
graph, not the order a feature is described. Every commit leaves the system valid,
with its relevant tests and no broken references or forward dependencies.

Ask: can a reviewer evaluate this change's correctness on its own merits?

- Behavioral helpers/services with meaningful logic and tests can land before
  their consumers when independently useful and evaluable.
- Pure declarations, empty errors, constants, types, or wiring land with their
  first consumer. Avoid scaffolding-only commits and arbitrary class boundaries.
- Isolate schema migrations when deployment compatibility requires it. Do not
  impose a universal migration/consumer split on projects deployed atomically.
- Group tests with the behavior they verify. Respect the repository's test layers;
  do not add duplicate coverage solely to satisfy a proposed commit matrix.

Include verification at each boundary and the expected state after it. A plan is
not permission to commit, push, bypass checks, or fix unrelated code.
