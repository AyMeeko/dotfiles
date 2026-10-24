/** Owns one location's notification subscription, replay memory, and audio lifetime. */
export function startNotifications(deps: {
  directory: string
  events(signal: AbortSignal): AsyncIterable<unknown>
  sessionDirectory(sessionID: string): Promise<string>
  parent(sessionID: string): Promise<string | undefined>
  play(sound: "complete" | "question", signal: AbortSignal): Promise<void>
  report(error: unknown): void
}): { done: Promise<void>; dispose(): Promise<void> } {
  const controller = new AbortController()
  const seen = new Set<string>()
  const done = (async () => {
    try {
      for await (const raw of deps.events(controller.signal)) {
        if (controller.signal.aborted) break
        try {
          const notification = await parseNotification(raw, deps.directory, deps.sessionDirectory)
          if (!notification || seen.has(notification.id)) continue
          seen.add(notification.id)
          if (seen.size > 1024) {
            const oldest = seen.values().next()
            if (!oldest.done) seen.delete(oldest.value)
          }
          // Permissions can block child sessions too; other cues belong to main sessions.
          const main = notification.type === "permission" || !(await deps.parent(notification.sessionID))
          if (main && !controller.signal.aborted) {
            await deps.play(notification.type === "complete" ? "complete" : "question", controller.signal)
          }
        } catch (error) {
          if (!controller.signal.aborted) deps.report(error)
        }
      }
    } catch (error) {
      if (!controller.signal.aborted) deps.report(error)
    }
  })()
  return { done, async dispose() { controller.abort(); await done } }
}

type Notification = { id: string; type: "complete" | "question" | "permission"; sessionID: string }

/** Resolves locationless completion ownership before any plugin instance claims it. */
async function parseNotification(
  raw: unknown,
  directory: string,
  sessionDirectory: (sessionID: string) => Promise<string>,
): Promise<Notification | undefined> {
  if (!isRecord(raw) || !isRecord(raw.data) || typeof raw.id !== "string" || !raw.id) return
  if (raw.location === undefined && raw.type === "session.execution.succeeded" &&
      typeof raw.data.sessionID === "string" && raw.data.sessionID) {
    if (await sessionDirectory(raw.data.sessionID) !== directory) return
  } else if (!isRecord(raw.location) || raw.location.directory !== directory) return
  if (raw.type === "form.created") {
    const form = raw.data.form
    if (isRecord(form) && typeof form.sessionID === "string" && form.sessionID) {
      return { id: raw.id, type: "question", sessionID: form.sessionID }
    }
    return
  }
  if (typeof raw.data.sessionID !== "string" || !raw.data.sessionID) return
  if (raw.type === "session.execution.succeeded") return { id: raw.id, type: "complete", sessionID: raw.data.sessionID }
  if (raw.type === "permission.asked") return { id: raw.id, type: "permission", sessionID: raw.data.sessionID }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value)
}
