import { Plugin } from "@opencode/plugin"
import { injectBetterPlanBuildSwitch } from "../lib/betterplan-build-switch"

export default Plugin.define({
  id: "betterplan-build-switch",
  async setup(ctx) {
    await ctx.session.hook("context", async (event) => {
      if (event.agent !== "build") return
      injectBetterPlanBuildSwitch(event.messages, event.agent, await ctx.session.context({ sessionID: event.sessionID }))
    })
  },
})
