import { expect, test } from "bun:test"
import { chmod, mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises"
import { join } from "node:path"
import { playNotification } from "../home/dot_config/opencode/lib/notification-playback"

/** Substitutes only the external audio executable; runs the actual process adapter. */
async function withPlayer(script: string, check: (root: string) => Promise<void>) {
  await mkdir("/tmp/opencode", { recursive: true })
  const root = await mkdtemp("/tmp/opencode/sound-player-")
  const previous = { PATH: process.env.PATH, XDG_CONFIG_HOME: process.env.XDG_CONFIG_HOME,
    NOTIFICATION_TEST_LOG: process.env.NOTIFICATION_TEST_LOG }
  try {
    await writeFile(join(root, "ffplay"), `#!/bin/sh\n${script}\n`)
    await chmod(join(root, "ffplay"), 0o755)
    process.env.PATH = `${root}:${previous.PATH}`
    process.env.XDG_CONFIG_HOME = join(root, "config with spaces")
    process.env.NOTIFICATION_TEST_LOG = join(root, "arguments")
    await check(root)
  } finally {
    for (const [key, value] of Object.entries(previous)) {
      if (value === undefined) delete process.env[key]
      else process.env[key] = value
    }
    await rm(root, { recursive: true, force: true })
  }
}

test("plays the correct managed file without a display, honoring XDG paths and spaces", async () => {
  await withPlayer('printf "%s\\n" "$@" > "$NOTIFICATION_TEST_LOG"', async (root) => {
    for (const [sound, file] of [["complete", "jobs_done.mp3"], ["question", "question.mp3"]] satisfies ["complete" | "question", string][]) {
      await playNotification(sound, new AbortController().signal)
      expect((await readFile(join(root, "arguments"), "utf8")).trim().split("\n")).toEqual([
        "-nodisp", "-autoexit", "-loglevel", "error", "-nostats",
        join(root, "config with spaces/opencode/sounds", file),
      ])
    }
  })
})

test("audio process failures propagate for the subscription to report", async () => {
  await withPlayer("exit 7", async () => {
    await expect(playNotification("question", new AbortController().signal)).rejects.toThrow()
  })
})

test("aborting playback terminates its process instead of leaking it on reload", async () => {
  await withPlayer("exec sleep 30", async () => {
    const controller = new AbortController()
    const playback = playNotification("complete", controller.signal)
    controller.abort()
    await expect(playback).rejects.toMatchObject({ name: "AbortError" })
  })
})
