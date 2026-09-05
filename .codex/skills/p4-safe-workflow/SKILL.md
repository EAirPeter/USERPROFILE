---
name: p4-safe-workflow
description: Inspect or modify Perforce workspaces safely on Windows, including client context, explicit filespecs, pending changelists, authentication failures, and PowerShell-safe p4 invocation. Do not use for Git repositories or Perforce server administration.
---

# P4 Safe Workflow

Use this Skill for Perforce workspace work on Windows. Apply `powershell-safe-invocation` alongside it when invoking native commands or writing PowerShell.

## Safety Invariants

- Use `p4`, not Git, in a Perforce workspace.
- Never run `p4 submit`.
- Never run `p4 sync` or `p4 resolve` unless the user explicitly requests that operation.
- Never omit a filespec from a command that would otherwise scan, compare, reconcile, clean, or mutate the full workspace or depot. Bare `p4 status`, `p4 reconcile`, `p4 clean`, and `p4 diff` are forbidden.
- Use the narrowest explicit paths or filespecs. Resolve and verify targets before destructive or wide operations.
- Put code and content changes in one task-specific pending changelist. Do not leave ordinary workspace changes in the default changelist.
- Treat local guidance such as `AGENTS.md` as local-only unless the user explicitly asks to version it.

## Establish Context

Before workspace-dependent operations, run `p4 info` and use its resolved user, client, client root, stream, and current directory. Do not guess from a mapped-drive name or use cmd-style `%P4USER%` expansion in PowerShell.

When a path may be outside the active client view, use `p4 where <exact-path>` before changing configuration. Do not silently set `P4CLIENT`, switch clients, or rewrite client mappings to make an operation succeed.

Metadata-only queries such as these are safe without a workspace filespec:

```text
p4 info
p4 opened -c <change>
p4 change -o <change>
p4 changes -s pending -u <resolved-user> -c <resolved-client>
```

Do not rely on a shortened changelist listing to decide whether a pending changelist matches the task. Read candidate specs with `p4 change -o <change>` and compare the complete description and file list.

## Native Invocation

Pass every argument as a separate PowerShell array element and capture the exit code immediately:

```powershell
$p4Exe = 'p4'
$nativeArgs = @('opened', '-c', $changeNumber)

& $p4Exe @nativeArgs
$exitCode = $LASTEXITCODE

if ($exitCode -ne 0) {
    throw "p4 opened failed with exit code $exitCode"
}
```

Interpret the command's documented result, not just a familiar-looking line. For example, `file(s) not opened on this client` is an empty `p4 opened` result when the command otherwise succeeds; it is not a reason to create a changelist or retry with broader scope.

## Pending Changelists

- Reuse the active pending changelist when it still exists and its complete description matches the task.
- Create a new changelist only when no matching active changelist exists.
- Use the configured description format, normally `[Tag] One line description.`.
- Open files directly into the task changelist with explicit paths, or immediately move them there with `p4 reopen -c <change> <explicit-files>`.
- After editing, verify ownership with `p4 opened -c <change>` and narrow file-specific checks.

For creating or updating changelists, read [references/changelists.md](references/changelists.md). It defines the exact standard-input pattern and how to preserve an existing `Files` section.

## Failure And Retry Policy

Classify the failure before retrying:

- **Authentication required or expired:** stop and ask the user to log in. Resume only after confirmation; do not try different clients or credentials.
- **Client/view mismatch:** inspect `p4 info` and `p4 where <exact-path>`. Report the mismatch instead of silently changing client state.
- **Change-spec error:** fetch a fresh complete spec, correct the invalid field, preserve unrelated fields and the full `Files` list, then retry once.
- **PowerShell parsing, quoting, or process-wrapper rejection:** do not repeat the same command string. Remove `cmd.exe`, nested `pwsh -Command`, pipelines, and manual escaping; use argument arrays or `ProcessStartInfo` standard input.
- **Unknown p4 failure:** retain stdout, stderr, and the exit code; stop rather than broadening the filespec or creating replacement state.

One method-changing retry is enough for an invocation-shape failure. Repeated failure, authentication problems, or ambiguous client state require user input or a clear report.

## Verification

Before finishing a change:

- Confirm every intended file is opened in the task changelist.
- Confirm no unintended file was opened, moved, reverted, or added.
- Inspect the complete pending changelist spec when its description or file membership changed.
- Do not submit, sync, resolve, or alter client configuration during verification unless separately authorized.
