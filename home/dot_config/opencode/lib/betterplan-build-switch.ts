import type { SessionContext } from "@opencode/plugin/promise/session"

export const BUILD_SWITCH = `<system-reminder>
The user has switched from BetterPlan to Build. Planning-only restrictions from
the previous agent no longer apply. Follow the current agent, harness, and user
instructions; implement only the authorized scope. A switch does not authorize
commits, pushes, destructive actions, or unrelated changes.
</system-reminder>
`

/** Adds a transient reminder only after a new user turn switches BetterPlan to Build. */
export function injectBetterPlanBuildSwitch(
  messages: SessionContext["messages"],
  currentAgent: string,
  history: readonly { type: string; agent?: string }[],
): void {
  if (currentAgent !== "build") return
  const assistantIndex = history.findLastIndex((message) => message.type === "assistant")
  const userIndex = history.findLastIndex((message) => message.type === "user")
  if (assistantIndex < 0 || userIndex <= assistantIndex || history[assistantIndex]?.agent !== "betterplan") return
  const index = messages.findLastIndex((message) => message.role === "user")
  const user = messages[index]
  if (!user || user.content.some((part) => part.type === "text" && part.metadata?.betterplanBuildSwitch === true)) return
  messages[index] = {
    ...user,
    content: [...user.content, { type: "text", text: BUILD_SWITCH, metadata: { betterplanBuildSwitch: true } }],
  }
}
