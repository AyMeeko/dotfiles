---
name: update-markdown-from-git
description: Use when refreshing a Markdown document from repository changes since its last meaningful update.
---

# Evidence-based documentation updates

Read the whole document and infer relevant paths/topics. Use Git history to find
its last meaningful update; inspect commits rather than assuming a doc-touching
commit establishes full coverage. If no reliable baseline exists, ask for one.

Collect subsequent relevant commits and inspect their actual changes. Do not
exclude dependency/configuration changes automatically when they affect documented
behavior. Record included/excluded commits and reasons.

Group changes by topic, present manageable batches, and confirm which warrant doc
updates before editing. Preserve structure and unrelated sections. Support edits
with commit/source evidence, update an existing datestamp where appropriate, and
report the changes covered plus known gaps. Do not use today's date as an invented
historical baseline.
