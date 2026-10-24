---
name: session-routing
description: Use when the user explicitly starts, picks up, or resumes a named body of work; selects its notes dossier without requiring tickets.
---

# Session routing

Trigger only on an explicit request such as "start the opencode-port work" or
"pick up opencode-port". Do not infer a dossier from every task or branch name.

1. Resolve a lowercase kebab-case slug under `~/notes/ai/work/`. Reject separators,
   traversal, and absolute paths. If the name is ambiguous, inspect candidate
   names read-only and ask the user which one they mean.
2. Existing dossier: read `resume.md` first, not every artifact. Briefly summarize
   phase, state, and next action; verify relevant checkout/head claims before use.
3. New dossier: establish goal and repositories from the conversation; ask only
   for missing context. Load `feature-dossier`. Create a minimal `resume.md` when
   the first persistent artifact is warranted, not a directory of placeholders.
4. State the active dossier path. Pass that path and actual checkout explicitly to
   delegated agents; they start with fresh context.

The user can redirect or change dossiers at any time. Do not silently move or
merge existing work. A standalone plan can be promoted into a dossier when the
user selects one; repair links and preserve its history.
