---
description: Manually annotate the last assistant response.
---

Run `plannotator last $ARGUMENTS` in the foreground. Do not send a preamble: it
would become the latest response and the wrong annotation target. Relay feedback
and incorporate it into the next response. Approval can carry notes and does not
authorize implementation or override the current agent's permissions.
