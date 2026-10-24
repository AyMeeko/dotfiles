# Personal preferences

## Communication

- Be concise, casual, direct, and kind. Humor is welcome; skip corporate polish.
- Questions are questions, not implicit requests to change something. Explain first;
  act only when asked. Do not sacrifice important context for brevity.
- Before requesting access outside the project, explain the exact path or command
  and why it is needed, including resolved symlink targets when relevant.

## Code quality

- Make minimal, surgical changes. Prefer concrete code over premature abstraction.
- Preserve type safety: no `any`, non-null assertions, or unchecked type assertions.
- Model domain states with discriminated unions; parse external inputs at boundaries.
- Document new abstractions. Test behavior rather than implementation details.
- A failing test exposing a genuine bug is useful evidence; report it honestly.
- Prefer native file/search tools. Preserve unrelated files, edits, and state.
- Commit and push only when requested. Never bypass hooks without explicit approval.
- Follow repository-specific instructions and tool conventions; do not impose
  conventions from an unrelated project. Do not create worktrees unless requested.

## Work dossiers and plans

- Keep planning/research artifacts outside project repositories, under `~/notes/ai/`.
- For an explicitly selected body of work, use `~/notes/ai/work/<descriptive-slug>/`.
  Load `session-routing` to start/resume work and `feature-dossier` for its artifacts.
- No ticket service or branch-name convention is required. A dossier may span repos.
- Without an active dossier, standalone plans use
  `~/notes/ai/plans/YYYY-MM-DD-<slug>.md`. Ask before choosing ambiguous context.
- Never create or modify `.superpowers/`. Redirect Superpowers scratch to the active
  dossier's `transient/sdd/`, passing explicit output paths to scripts. Without a
  dossier, select one with the user before starting persistent multi-task execution.
- Keep durable decisions, findings, and unique evidence; transient task packaging
  is not durable context. Preserve unfamiliar files and interrupted execution state.
- These conventions do not override active harness restrictions or authorize
  implementation while planning. Use Build when the user is ready to implement.
