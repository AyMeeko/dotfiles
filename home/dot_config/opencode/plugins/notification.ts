import { Plugin } from "@opencode/plugin"
import { startNotifications } from "../lib/notification"
import { playNotification } from "../lib/notification-playback"

/** One subscription per owning location, not per attached terminal pane. */
export default Plugin.define({
  id: "notification",
  setup(ctx) {
    const stream = startNotifications({
      directory: ctx.location.directory,
      events: (signal) => ctx.event.subscribe({ signal }),
      sessionDirectory: async (sessionID) => (await ctx.session.get({ sessionID })).location.directory,
      parent: async (sessionID) => (await ctx.session.get({ sessionID })).parentID,
      play: playNotification,
      report: (error) => console.error("[notification]", error),
    })
    return stream.dispose
  },
})
