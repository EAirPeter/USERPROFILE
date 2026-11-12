---
name: powershell-safe-invocation
description: Use when writing or running PowerShell on Windows, especially native programs, shell wrappers, quoted paths, escaping, pwsh, Start-Process, file operations, exit codes, or shell troubleshooting.
---

# PowerShell Safe Invocation

## Shell And Wrapper Boundaries

Use PowerShell 7 through `pwsh.exe` unless Windows PowerShell 5.1 is explicitly required. When uncertain, verify:

```powershell
$PSVersionTable.PSVersion
$PSNativeCommandArgumentPassing
```

When the host or execution API already launches PowerShell, select `pwsh` there and pass the script directly. Do not add another `pwsh.exe -Command` layer. Every extra JSON, host, cmd, or PowerShell parser can reinterpret quotes, dollar signs, backticks, pipes, parentheses, regular expressions, and Unicode text.

## Native Programs

Never construct one large command string when arguments can be passed separately:

```powershell
$exe = '.\Path With Spaces\tool.exe'
$nativeArgs = @(
    '--input'
    '.\Data Folder\input.json'
    '--flag'
)

& $exe @nativeArgs
$exitCode = $LASTEXITCODE

if ($exitCode -ne 0) {
    throw "$exe failed with exit code $exitCode"
}
```

- Treat every native argument as one array item.
- Invoke executable paths stored in variables with `&`.
- Capture `$LASTEXITCODE` immediately, before another native command overwrites it.
- Do not use `$args` as your own argument-array variable; it is automatic.
- Do not use `Invoke-Expression` for native invocation.
- Do not add `cmd.exe /c` merely to launch an executable.
- Do not use Bash-style `\"` escaping in PowerShell.

Exit-code contracts are command-specific. Do not apply a universal `-ne 0` rule before checking the tool's semantics. For `rg`:

```powershell
& $rgExe @nativeArgs
$rgExit = $LASTEXITCODE

switch ($rgExit) {
    0 { } # matches found
    1 { } # valid search, no matches
    default { throw "rg failed with exit code $rgExit" }
}
```

Use `rg -F` or `--fixed-strings` for literal text. Use a regular expression only when regex behavior is required, and pass the entire pattern as one argument instead of manually escaping it through nested shells.

## Cmdlets

Use hashtable splatting and terminating errors for PowerShell cmdlets:

```powershell
$copyParams = @{
    LiteralPath = '.\Data[1]\input.txt'
    Destination = '.\Output'
    Force       = $true
    ErrorAction = 'Stop'
}

Copy-Item @copyParams
```

- Use `-LiteralPath` for real paths unless wildcard expansion is intentional.
- Do not use `$LASTEXITCODE` to test a cmdlet.
- Wrap expressions used as parameter values: `Select-Object -Index (100..120)`.
- Do not pipe directly from statement syntax such as `foreach (...) { ... } | ...`; assign its output first or use `ForEach-Object`.

## Complex Commands

For multiline code, nested quotes, JSON, XML, regular expressions, pipelines, redirection, or non-ASCII text that must cross an execution wrapper:

1. Remove unnecessary `cmd.exe` and nested `pwsh -Command` layers.
2. Prefer structured arguments or native standard-input APIs.
3. When code still has to cross a command-string boundary, write a temporary `.ps1` file and run:

```text
pwsh.exe -NoLogo -NoProfile -NonInteractive -File script.ps1
```

Do not add `-ExecutionPolicy Bypass` unless a trusted script is actually blocked and policy permits the override.

Execution hosts may reject inline PowerShell that performs recursive delete or move even when its syntax and target checks are valid. Keep target resolution, containment validation, and mutation together in a temporary `.ps1` file and invoke it with `-File`. Do not retry by shortening the command, dropping safety checks, or sending enumerated paths through another shell.

## Strings, Variables, And Multiline Text

- Use single quotes for literal strings and paths; use double quotes only for expansion.
- Avoid backtick line continuation; prefer arrays, hashtables, and natural line breaks.
- Do not use Bash heredocs such as `python - <<'PY'`.
- Use a single-quoted here-string for literal multiline text. Its opener ends the line and its terminator starts at column one.
- Build JSON objects and call `ConvertTo-Json`; do not hand-escape JSON.
- Delimit a variable when a colon or other name-like text immediately follows it: use `"${name}: value"`, not `"$name: value"`.
- Specify encoding when another tool consumes text.
- PowerShell variable names are case-insensitive. Never repurpose `$HOME`, `$home`, `$Codex_Home`, or another casing of a reserved or environment-significant variable. Use task-specific names.

## Process APIs

Use `& $exe @nativeArgs` for normal foreground execution. Use `Start-Process` only for elevation, detached/background execution, new or hidden windows, or shell association behavior.

`Start-Process -ArgumentList` joins values into one command-line string. When exact argument boundaries, redirected standard input, or separate stdout/stderr are required, use `ProcessStartInfo.ArgumentList` and its redirection properties.

## File Operations

Before recursive delete, move, or overwrite:

- Resolve the absolute root and target.
- Verify the target is a child of the intended root using a separator-aware, case-insensitive comparison.
- Reject empty paths, filesystem roots, the intended root itself, and unexpected targets.
- Keep enumeration and mutation in the same PowerShell process.

Mapped drives are scoped to an identity and logon session. If a mapped path fails under automation, check `whoami`, `Get-PSDrive`, and `Test-Path`; use a verified UNC path or ask the user rather than guessing.

## Retry Discipline

Do not repeat an unchanged failing command. Classify the failure and change one relevant dimension:

- Parser, terminator, or quoting error: remove a parser layer or use a `.ps1` file.
- Wrapper or `CreateProcess` rejection: for native programs, invoke the executable directly with argument arrays or `ProcessStartInfo`; for multiline PowerShell or recursive file operations, move the same validated logic to a `.ps1` file and invoke it with `-File`.
- Parameter-binding error: group expressions and use cmdlet splatting.
- Command not found: verify the resolved executable and version instead of assuming an alias is functional.
- Expected nonzero status: handle the tool's documented contract rather than suppressing every error.
- Authentication, authorization, or ambiguous external state: stop and request user action instead of trying speculative alternatives.

Use at most one method-changing retry for an invocation-shape failure before reporting the remaining blocker.

## Version Differences And Decision Order

PowerShell 5.1 and 7 may expose different command types and parameters. Check `Get-Command <name> -Syntax`, `$env:PSModulePath`, and installed modules before assuming a command is missing.

Choose the simplest safe option:

1. PowerShell cmdlet.
2. `& $exe @nativeArgs`.
3. Temporary `.ps1` with `pwsh.exe -File` when an execution boundary would corrupt the script.
4. `ProcessStartInfo.ArgumentList` and redirection when exact process I/O is required.
5. `Start-Process` only for its special behavior.
6. `cmd.exe /c` only when cmd semantics are actually required.
7. `Invoke-Expression` only as a tightly controlled last resort for trusted PowerShell source.

For uncommon cases and complete examples, read `reference.md`.
