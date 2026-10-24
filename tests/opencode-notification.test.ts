import { expect, test } from "bun:test"
import { startNotifications } from "../home/dot_config/opencode/lib/notification"

const directory = "/workspace/main"

function event(type: string, sessionID: string, location = directory) {
  return {
    id: `evt_${type}_${sessionID}`, type, location: { directory: location },
    data: type === "form.created" ? { form: { sessionID } } : { sessionID },
  }
}

/** Runs the actual filter against a finite event stream, without playing audio. */
async function collect(events: unknown[], location = directory, failFirst = false) {
  const sounds: string[] = []
  const errors: unknown[] = []
  const stream = startNotifications({
    directory: location,
    async *events() { yield* events },
    async sessionDirectory() { return directory },
    async parent(id) { return id === "ses_child" ? "ses_main" : undefined },
    async play(sound) {
      sounds.push(sound)
      if (failFirst && sounds.length === 1) throw new Error("audio unavailable")
    },
    report(error) { errors.push(error) },
  })
  await stream.done
  await stream.dispose()
  return { sounds, errors }
}

test("only main completion/questions and every permission play, not failed/interrupted turns", async () => {
  const result = await collect([
    event("session.execution.succeeded", "ses_main"),
    event("session.execution.succeeded", "ses_child"),
    event("form.created", "ses_main"),
    event("form.created", "ses_child"),
    event("permission.asked", "ses_child"),
    event("session.execution.failed", "ses_main"),
    event("session.execution.interrupted", "ses_main"),
  ])
  expect(result.sounds).toEqual(["complete", "question", "question"])
})

test("locationless completions only play in their owning location", async () => {
  const events = [
    { id: "evt_complete", type: "session.execution.succeeded", data: { sessionID: "ses_main" } },
    { id: "evt_child", type: "session.execution.succeeded", data: { sessionID: "ses_child" } },
    event("permission.asked", "ses_main"),
  ]
  const results = await Promise.all([collect(events), collect(events, "/workspace/other")])
  expect(results.map((result) => result.sounds)).toEqual([["complete", "question"], []])
})

test("replayed events deduplicate, but new turns in the same session still play", async () => {
  const complete = event("session.execution.succeeded", "ses_main")
  const question = event("form.created", "ses_main")
  const permission = event("permission.asked", "ses_child")
  const result = await collect([complete, complete, question, question, permission, permission,
    { ...complete, id: "evt_next_turn" }])
  expect(result.sounds).toEqual(["complete", "question", "question", "complete"])
})

test("malformed events and foreign locations stay silent", async () => {
  const complete = event("session.execution.succeeded", "ses_main")
  const { id, ...withoutID } = complete
  const result = await collect([null, withoutID, { ...complete, id: "" }, { ...complete, id: 42 },
    { ...complete, data: { sessionID: "" } }, { ...complete, data: {} },
    { ...complete, location: null }, event("form.created", "ses_main", "/workspace/other"),
    { ...event("form.created", "ses_main"), data: { form: {} } }])
  expect(result.sounds).toEqual([])
})

test("unavailable session metadata skips that sound and preserves later events", async () => {
  const sounds: string[] = []
  const errors: unknown[] = []
  const stream = startNotifications({
    directory,
    async *events() {
      yield { id: "evt_missing", type: "session.execution.succeeded", data: { sessionID: "ses_missing" } }
      yield event("form.created", "ses_missing")
      yield event("permission.asked", "ses_child")
    },
    async sessionDirectory() { throw new Error("missing location") },
    async parent() { throw new Error("missing parent metadata") },
    async play(sound) { sounds.push(sound) },
    report(error) { errors.push(error) },
  })
  await stream.done
  await stream.dispose()
  expect(sounds).toEqual(["question"])
  expect(errors).toHaveLength(2)
})

test("playback errors do not retry replays or stop subsequent events", async () => {
  const complete = event("session.execution.succeeded", "ses_main")
  const result = await collect([complete, complete, event("permission.asked", "ses_main")], directory, true)
  expect(result.sounds).toEqual(["complete", "question"])
  expect(result.errors).toHaveLength(1)
})

test("dedup memory is bounded to the latest 1024 IDs", async () => {
  const complete = event("session.execution.succeeded", "ses_main")
  const events = Array.from({ length: 1025 }, (_, index) => ({ ...complete, id: `evt_${index}` }))
  expect((await collect([...events, events[0], events[1024]])).sounds).toHaveLength(1026)
})

test("dispose aborts subscription and suppresses late events", async () => {
  const sounds: string[] = []
  let aborted = false
  const stream = startNotifications({
    directory,
    async *events(signal) {
      await new Promise<void>((resolve) => {
        signal.addEventListener("abort", () => { aborted = true; resolve() }, { once: true })
      })
      yield event("permission.asked", "ses_main")
    },
    async sessionDirectory() { return directory },
    async parent() { return undefined },
    async play(sound) { sounds.push(sound) },
    report(error) { throw error },
  })
  await stream.dispose()
  expect(aborted).toBe(true)
  expect(sounds).toEqual([])
})

test("dispose cancels in-flight playback without reporting a shutdown error", async () => {
  let started: () => void = () => {}
  const playing = new Promise<void>((resolve) => { started = resolve })
  let aborted = false
  const errors: unknown[] = []
  const stream = startNotifications({
    directory,
    async *events() { yield event("session.execution.succeeded", "ses_main") },
    async sessionDirectory() { return directory },
    async parent() { return undefined },
    async play(_sound, signal) {
      started()
      await new Promise<void>((_resolve, reject) => {
        signal.addEventListener("abort", () => { aborted = true; reject(new Error("aborted")) }, { once: true })
      })
    },
    report(error) { errors.push(error) },
  })
  await playing
  await stream.dispose()
  expect(aborted).toBe(true)
  expect(errors).toEqual([])
})
