# Global Instructions

## Global VCS And Shell Defaults

- Unless the user or project-specific instructions specify a different format, commit messages and changelist descriptions for any VCS should use the form `[Tag] One line description.` with the tag in square brackets, a capitalized one-line description, and a trailing period.
- For Git workspaces, never run `git push` unless the user explicitly requests it.
- The active shell is PowerShell. Use PowerShell syntax by default, including environment variables such as `$env:NAME`. Invoke `cmd.exe` only when an instruction explicitly requires cmd semantics or a tool-specific command needs them.
- For PowerShell, native-program, quoting, or shell-wrapper work, use the `powershell-safe-invocation` Skill when it is available.

## Conditional Guidance For Perforce Workspaces

- When the current workspace uses Perforce, use `p4`, not `git`, and use the `p4-safe-workflow` Skill when it is available.
- Strictly prohibit any pathless Perforce operation whose omitted filespec would enumerate, scan, reconcile, clean, compare, or mutate the full workspace or depot. Always supply the narrowest explicit path or filespec. Bare forms such as `p4 status`, `p4 status -s`, `p4 reconcile`, `p4 clean`, and `p4 diff` are forbidden. Metadata-only commands that do not scan workspace files, such as `p4 info`, `p4 opened -c <change>`, and `p4 change -o <change>`, are exempt.
- Keep track of an active changelist and reuse it when its topic still matches the current task. Only create a new changelist if the active changelist no longer exists or no longer matches.
- For code or content changes, put all `p4 edit`, `p4 add`, and `p4 delete` actions into a dedicated pending changelist for the task. Except for explicitly local-only files such as `AGENTS.md`, do not leave workspace changes outside a pending changelist.
- `AGENTS.md` is local-only workspace guidance. Edit it directly and leave it out of Perforce unless the user explicitly requests otherwise.
- Never run `p4 submit`.
- Never run `p4 sync` or `p4 resolve` unless the user explicitly instructs it.
- If Perforce reports that login has expired or authentication is required, stop and ask the user to log in. Resume only after the user confirms that login succeeded. Do not continue with speculative Perforce alternatives in the meantime.
- If the requested change would require widening scope into framework or engine infrastructure because the local subsystem API cannot support the requested lifecycle or behavior, stop and ask before changing the broader system.

## Detailed References

Resolve these document links relative to the directory containing this AGENTS.md.

- [Python.md](docs/Python.md) is the canonical detailed reference for Python environment selection, `uv`, and Python package installation.
- [UnrealEngine.md](docs/UnrealEngine.md) is the canonical detailed reference for Unreal Engine file writing, Unreal C++ conventions, and Unreal build-validation behavior.
- [WinDbg.md](docs/WinDbg.md) is the canonical detailed reference for WinDbg usage, symbol loading, dump analysis flow, and crash-debug reporting.
