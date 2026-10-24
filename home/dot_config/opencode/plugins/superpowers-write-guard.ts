import { Plugin } from "@opencode/plugin"
import { assertNoSuperpowersWrite } from "../lib/superpowers-write-guard"

/** Resolves each executing session rather than assuming the plugin's location. */
export default Plugin.define({
  id: "superpowers-write-guard",
  async setup(ctx) {
    await ctx.tool.hook("execute.before", async (event) => {
      const session = await ctx.session.get({ sessionID: event.sessionID })
      assertNoSuperpowersWrite(session.location.directory, event.tool, event.input)
    })
  },
})
