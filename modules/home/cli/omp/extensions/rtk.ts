// Route omp's bash tool through rtk, the way the Claude Code PreToolUse hook
// does. rtk ships no `rtk hook omp`, but its `rtk hook claude` processor is a
// pure stdin/stdout JSON transform, so we speak that wire format instead of
// reimplementing the rewrite engine.
//
//   in : {"tool_name":"Bash","tool_input":{"command":"git status"}}
//   out: {"hookSpecificOutput":{...,"updatedInput":{"command":"rtk git status"}}}
//
// rtk decides what is worth rewriting (git/kubectl/ls/cargo yes, echo/npm no)
// and is idempotent, so an already-prefixed command is left alone.
//
// Fails open by design: any rtk error, timeout, or unparseable reply leaves the
// original command untouched. A token optimiser must never break a shell call.
import { spawnSync } from "node:child_process";

import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

const RTK_TIMEOUT_MS = 5_000;

function rewrite(command: string): string | undefined {
  const result = spawnSync("rtk", ["hook", "claude"], {
    input: JSON.stringify({ tool_name: "Bash", tool_input: { command } }),
    encoding: "utf8",
    timeout: RTK_TIMEOUT_MS,
    maxBuffer: 1024 * 1024,
  });

  // rtk missing, non-zero exit, or killed by timeout -> leave the command be.
  if (result.error || result.status !== 0) return undefined;
  const stdout = result.stdout?.trim();
  if (!stdout) return undefined;

  let parsed: unknown;
  try {
    parsed = JSON.parse(stdout);
  } catch {
    return undefined;
  }

  // Narrow the untrusted reply structurally; `in` keeps each field `unknown`.
  if (typeof parsed !== "object" || parsed === null) return undefined;
  if (!("hookSpecificOutput" in parsed)) return undefined;
  const hook = parsed.hookSpecificOutput;
  if (typeof hook !== "object" || hook === null) return undefined;

  if ("permissionDecision" in hook) {
    const decision = hook.permissionDecision;
    if (typeof decision === "string" && decision !== "allow") return undefined;
  }

  if (!("updatedInput" in hook)) return undefined;
  const updated = hook.updatedInput;
  if (typeof updated !== "object" || updated === null) return undefined;
  if (!("command" in updated)) return undefined;

  const next = updated.command;
  if (typeof next !== "string" || next.length === 0) return undefined;
  return next === command ? undefined : next;
}

export default function rtkExtension(pi: ExtensionAPI): void {
  pi.setLabel("rtk");

  pi.on("tool_call", async (event) => {
    if (event.toolName !== "bash") return;

    const command = event.input.command;
    if (typeof command !== "string" || command.length === 0) return;

    let next: string | undefined;
    try {
      next = rewrite(command);
    } catch (error) {
      pi.logger?.debug?.(`rtk rewrite skipped: ${String(error)}`);
      return;
    }
    if (!next) return;

    pi.logger?.debug?.(`rtk: ${command} -> ${next}`);
    return { input: { ...event.input, command: next } };
  });
}
