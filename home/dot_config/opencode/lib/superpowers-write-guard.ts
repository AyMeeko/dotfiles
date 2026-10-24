import { resolve } from "node:path"

export const SUPERPOWERS_WRITE_ERROR =
  "Writes to .superpowers directories are blocked. Load save-plans-to-notes and use ~/notes/ai/. For work artifacts, select a dossier and follow feature-dossier. Ask if the destination is unclear."

/** Rejects direct mutations and best-effort literal shell writes, not a shell sandbox. */
export function assertNoSuperpowersWrite(directory: string, tool: string, args: unknown): void {
  if (!isRecord(args)) return
  let targets: string[] = []
  if (tool === "write" || tool === "edit") {
    const path = typeof args.path === "string" ? args.path : args.filePath
    if (typeof path === "string") targets = [path]
  } else if ((tool === "patch" || tool === "apply_patch") && typeof args.patchText === "string") {
    targets = [...args.patchText.matchAll(/^\*\*\* (?:Add File|Update File|Delete File|Move to): (.+)$/gm)]
      .flatMap((match) => typeof match[1] === "string" ? [match[1].trim()] : [])
  } else if ((tool === "shell" || tool === "bash") && typeof args.command === "string") {
    const workdir = typeof args.workdir === "string" ? resolve(directory, args.workdir) : directory
    targets = args.command.split(/&&|\|\||[;\n|]/).flatMap(shellTargets)
      .map((target) => resolve(workdir, target))
  }
  if (targets.some((target) => resolve(directory, target).split("/").includes(".superpowers"))) {
    throw new Error(SUPERPOWERS_WRITE_ERROR)
  }
}

function shellTargets(segment: string): string[] {
  const tokens = (segment.match(/"(?:\\.|[^"])*"|'[^']*'|>>?|[^\s>]+/g) ?? []).map((token) => {
    const first = token[0]
    return (first === '"' || first === "'") && first === token.at(-1) ? token.slice(1, -1) : token
  })
  const command = tokens[0]?.split("/").at(-1)
  const mutations = new Set(["chmod", "chown", "cp", "install", "ln", "mkdir", "mv", "rm", "rmdir", "tee", "touch", "truncate"])
  const candidates = command && mutations.has(command) ? tokens.slice(1) : tokens.flatMap((token, index) => {
    const next = tokens[index + 1]
    return (token === ">" || token === ">>") && typeof next === "string" ? [next] : []
  })
  return candidates.filter((token) => !token.includes("$") && !token.includes("`") && /(?:^|\/)\.superpowers(?:\/|$)/.test(token))
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value)
}
