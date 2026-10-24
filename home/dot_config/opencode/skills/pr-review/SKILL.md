---
name: pr-review
description: Use when asked to review a pull request; provide findings in conversation without publishing GitHub comments.
---

# PR review

1. Parse owner/repository from a supplied URL and pass `--repo owner/repo` to every
   `gh` command. For a bare number, verify the current repository first.
2. Read PR metadata/body, base/head, changed files, and full diff using `gh pr view`
   and `gh pr diff`. Read full affected files and related tests at the reviewed
   revision, not an unrelated local checkout. Fetch read-only source via GitHub
   when necessary. Clearly label limited/diff-only coverage.
3. Read applicable repository instructions and referenced standards. Review both
   correctness/security and explicit conventions/test quality. If delegating,
   pass the actual checkout, base/head, and rule-discovery requirement.
4. Return scope/base, sources read, actionable findings by severity with file:line
   and concrete failure scenarios, checks performed/skipped, and verdict.

Do not reset, clean, or switch an existing checkout. Do not create a worktree
unless requested. Do not fix code or publish comments/reviews without separate
authorization. Review only introduced issues; investigate uncertain findings and
distinguish suggestions from explicit rules. Show the full review to the user.
