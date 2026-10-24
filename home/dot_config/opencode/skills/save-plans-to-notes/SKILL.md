---
name: save-plans-to-notes
description: Use when writing or saving implementation plans; routes them to the active work dossier or standalone notes directory.
---

# Plan storage

Never save plans inside a project repository, including `docs/plans/` or
`.superpowers/`. Active harness/user restrictions take precedence over this skill.

- Active explicitly selected dossier: `~/notes/ai/work/<slug>/plan.md`. Load
  `feature-dossier`, read the existing resume/plan, and preserve unrelated work.
- No active dossier: `~/notes/ai/plans/YYYY-MM-DD-<descriptive-slug>.md`.
- If a multi-session body of work needs a dossier, select its name with the user;
  do not require a ticket ID or derive one from a branch.
- Plans contain intent, acceptance criteria, and verification—not a running
  execution log. Mark completed/superseded dossier plans and archive them safely.
- Report the saved path. Saving/reviewing a plan does not authorize implementation.
