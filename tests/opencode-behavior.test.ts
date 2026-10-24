import { expect, test } from "bun:test"
import { assertNoSuperpowersWrite } from "../home/dot_config/opencode/lib/superpowers-write-guard"
import { injectBetterPlanBuildSwitch } from "../home/dot_config/opencode/lib/betterplan-build-switch"
import type { SessionContext } from "@opencode/plugin/promise/session"

test("handoff follows durable agent history, is transient, and is idempotent", () => {
  const messages: SessionContext["messages"] = [{ role: "user", content: [{ type: "text", text: "let's do it" }] }]
  const history = [{ type: "assistant", agent: "betterplan" }, { type: "user", agent: "build" }]
  const original = JSON.stringify(history)
  injectBetterPlanBuildSwitch(messages, "build", history)
  injectBetterPlanBuildSwitch(messages, "build", history)
  expect(messages[0]?.content).toHaveLength(2)
  expect(JSON.stringify(history)).toBe(original)
  expect(JSON.stringify(messages)).toContain("does not authorize")
})

test("handoff does not unlock another agent or a tool-driven continuation", () => {
  for (const [agent, history] of [
    ["betterplan", [{ type: "assistant", agent: "betterplan" }, { type: "user" }]],
    ["build", [{ type: "user" }, { type: "assistant", agent: "betterplan" }]],
    ["build", [{ type: "assistant", agent: "investigate" }, { type: "user" }]],
    ["build", []],
  ] satisfies [string, { type: string; agent?: string }[]][]) {
    const messages: SessionContext["messages"] = [{ role: "user", content: [{ type: "text", text: "hello" }] }]
    injectBetterPlanBuildSwitch(messages, agent, history)
    expect(messages[0]?.content).toHaveLength(1)
  }
})

test("guard blocks all patch mutation headers, not textual mentions", () => {
  for (const header of ["Add File", "Update File", "Delete File", "Move to"]) {
    expect(() => assertNoSuperpowersWrite("/project", "patch", {
      patchText: `*** Begin Patch\n*** ${header}: docs/.superpowers/task.md\n*** End Patch`,
    })).toThrow("select a dossier")
  }
  expect(() => assertNoSuperpowersWrite("/project", "patch", {
    patchText: "*** Update File: README.md\n@@\n+.superpowers/task.md",
  })).not.toThrow()
})

test("guard resolves relative paths against the executing directory", () => {
  for (const input of [{ path: "docs/.superpowers/a" }, { filePath: "/other/.superpowers/a" }]) {
    expect(() => assertNoSuperpowersWrite("/project", "edit", input)).toThrow()
  }
  for (const command of ["mkdir -p .superpowers/sdd", "echo plan > '.superpowers/plan.md'", "touch docs/.superpowers/a"]) {
    expect(() => assertNoSuperpowersWrite("/project", "shell", { command, workdir: "docs" })).toThrow()
  }
  for (const [tool, input] of [
    ["read", { path: ".superpowers/a" }],
    ["edit", { path: "/home/user/notes/ai/work/test/plan.md" }],
    ["shell", { command: "rg .superpowers README.md" }],
    ["write", { path: ".superpowers-old/a" }],
    ["write", null],
  ] satisfies [string, unknown][]) {
    expect(() => assertNoSuperpowersWrite("/project", tool, input)).not.toThrow()
  }
})

test("shell guard deliberately does not claim to parse computed paths", () => {
  expect(() => assertNoSuperpowersWrite("/project", "shell", { command: 'mkdir ".$suffix"' })).not.toThrow()
})
