import { execFile } from "node:child_process"
import { homedir } from "node:os"
import { join } from "node:path"
import { promisify } from "node:util"

const execute = promisify(execFile)

/** Plays one managed MP3 through the local Linux audio session, without opening a window. */
export async function playNotification(sound: "complete" | "question", signal: AbortSignal): Promise<void> {
  const configHome = process.env.XDG_CONFIG_HOME || join(homedir(), ".config")
  const file = join(configHome, "opencode", "sounds", sound === "complete" ? "jobs_done.mp3" : "question.mp3")
  await execute("ffplay", ["-nodisp", "-autoexit", "-loglevel", "error", "-nostats", file], { signal })
}
