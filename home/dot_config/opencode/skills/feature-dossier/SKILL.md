---
name: feature-dossier
description: Use when organizing a body of work's plans, research, decisions, execution artifacts, or resumable context under ~/notes/ai/work.
---

# Work dossiers

A dossier encapsulates a body of work across repositories and sessions. It needs
no ticket service, branch naming convention, completion announcement, or time limit.

## Select context

Use `~/notes/ai/work/<descriptive-slug>/`. Select the slug explicitly with the user
or reuse a dossier already selected in this session. Normalize to lowercase kebab
case; never accept path separators, `..`, or absolute paths as slugs. If several
dossiers could match, ask rather than silently merging unrelated work. Branch
names are supporting context, not routing authority.

Read an existing `resume.md` before writing. Create directories and files lazily
when an artifact is needed; do not generate an empty template tree.

## Artifact ownership

| Artifact | Purpose |
| --- | --- |
| `resume.md` | Current scope, last-verified state, blockers, next steps, durable pointers |
| `plan.md` | Active intent, acceptance criteria, implementation and verification steps |
| `research.md` | Dated findings, evidence, dead ends; mark superseded findings |
| `decisions.md` | Chosen approach, rationale, rejected alternatives; curate as needed |
| `transient/sdd/` | Task briefs/reports, review packages, execution recovery ledger |
| `archive/` | Completed or superseded plans retained as history |

Create optional artifacts only when their distinct content needs a home. Link to
the authoritative artifact rather than copying facts among files. Durable scoped
verification results and reusable runbooks may also live at the dossier root.

## Resume contract

Keep one coherent snapshot, not an append-only session log:

```markdown
# <slug>: <short description>

**Phase:** investigate | plan | build | verify | done
**Last updated:** YYYY-MM-DD
**Last verified:** YYYY-MM-DD — scope checked; name unverified claims

## Scope
Goal, relevant repositories/checkouts, and boundaries.

## Current State
Last-verified state, relevant branch/head/PR, and blockers.

## Next Steps
- Immediate next action

## Context Pointers
- Durable plans, decisions, research, and verification evidence as needed
```

On resume, recheck only state relevant to the requested work. If unavailable,
label old delivery claims historical/unverified; don't invent verification dates.
Updating links does not advance the last-verified date. Dormancy is not completion.

## Superpowers artifacts and safe cleanup

Never write `.superpowers/`. Pass explicit output paths under this dossier's
`transient/sdd/` to scripts. Keep task packaging separate from durable context.

After both spec and quality review pass, promote unique evidence, reusable tooling,
decisions, and findings to durable artifacts; update the transient progress ledger
and current resume. Only then remove that task's disposable briefs/reports/diffs.
Keep the ledger until whole-branch review completes. Preserve interrupted/blocked
execution state. Never link transient files from `resume.md`.

Read before editing. Preserve unrelated user content and unfamiliar/unclassified
files. Cleanup is limited to classified disposable artifacts in the active task,
not broad directory deletion. Archive completed/superseded plans with a status
and evidence/replacement link, repairing references after moves. A merged PR does
not close unrelated or deferred dossier work.
