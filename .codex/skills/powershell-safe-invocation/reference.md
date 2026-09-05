# PowerShell Safe Invocation Reference

This file contains detailed and uncommon cases for the accompanying `SKILL.md`. Read only the section relevant to the current failure or invocation shape.

## 1. PowerShell Version And Host Boundaries

PowerShell 7 and Windows PowerShell 5.1 can be installed side by side:

```text
pwsh.exe       -> PowerShell 7
powershell.exe -> Windows PowerShell 5.1
```

Verify the current process:

```powershell
$PSVersionTable
$PSNativeCommandArgumentPassing
```

A command that reports PowerShell 7 once does not prove every later execution uses it. A host API may already wrap the supplied script in `pwsh -Command`; launching another PowerShell creates an additional expansion boundary.

Prefer this shape when the host can select a shell:

```text
host shell = pwsh
host script = the PowerShell body
```

Avoid:

```text
host shell -> pwsh -Command -> cmd.exe /c -> pwsh -Command -> native program
```

Each layer may reinterpret quotes, backslashes, dollar signs, backticks, pipes, redirection, parentheses, regular expressions, and Unicode text.

## 2. Native Argument Arrays And Exit Codes

Correct:

```powershell
$exe = 'C:\Program Files\App\tool.exe'
$nativeArgs = @(
    '--input'
    'C:\Data Folder\input.json'
    '--name'
    'value with spaces'
    '--empty'
    ''
)

& $exe @nativeArgs
$exitCode = $LASTEXITCODE
```

The following are distinct native arguments:

- omitted argument
- empty string `''`
- `$null`

Do not silently remove an empty argument. Do not use `$args` as a custom variable name because it is a PowerShell automatic variable.

Capture `$LASTEXITCODE` before another native process can overwrite it. Then interpret it according to that tool's contract.

### ripgrep

`rg` uses three meaningful exit-code classes:

- `0`: at least one match
- `1`: the search ran successfully and found no matches
- `2` or greater: syntax, I/O, or another execution error

```powershell
$rgExe = (Get-Command rg -ErrorAction Stop).Source
$nativeArgs = @('--hidden', '--no-ignore', '--fixed-strings', 'literal text', $searchRoot)

& $rgExe @nativeArgs
$rgExit = $LASTEXITCODE

if ($rgExit -ge 2) {
    throw "rg failed with exit code $rgExit"
}

$matched = $rgExit -eq 0
```

Use `--fixed-strings` or `-F` when regular-expression behavior is not needed. This removes one parser and avoids errors such as unclosed groups caused by unnecessary escaping.

When regex is required, keep the pattern in one literal string and one native argument:

```powershell
$pattern = '(?i)error|warning'
$nativeArgs = @('-n', '-P', $pattern, $searchRoot)
& $rgExe @nativeArgs
```

Do not embed that call in a second `pwsh -Command` string merely to quote the regex.

## 3. Cmdlet Splatting And Expressions

Use hashtable splatting for cmdlets:

```powershell
$copyParams = @{
    LiteralPath = $source
    Destination = $destination
    Force       = $true
    ErrorAction = 'Stop'
}

Copy-Item @copyParams
```

Use terminating errors for cmdlets. `$LASTEXITCODE` is for native commands and script exit codes, not normal cmdlet success.

PowerShell argument mode may treat an ungrouped expression as literal text. Avoid:

```powershell
Get-Content -LiteralPath $path | Select-Object -Index 100..120
```

Use:

```powershell
Get-Content -LiteralPath $path | Select-Object -Index (100..120)
```

Statements such as `foreach (...) { ... }` are not pipeline expressions. Assign the result first:

```powershell
$rows = foreach ($file in $files) {
    [pscustomobject]@{ File = $file }
}

$rows | Format-Table -AutoSize
```

## 4. Strings, Here-Strings, JSON, And Variables

Use single quotes for literal paths and text:

```powershell
$path = 'C:\Program Files\App\data.json'
```

Use double quotes only when expansion is needed:

```powershell
$message = "Output path: $path"
```

Do not use Bash-style escaping:

```powershell
# Wrong syntax, shown as a comment so this example remains parseable:
# "\"quoted\""

# Literal quoted text
'"quoted"'
```

Use braces when text follows a variable name and subexpressions for properties:

```powershell
"${name}_suffix"
"${name}: value"
"Exit code: $($process.ExitCode)"
```

The colon matters: inside a double-quoted string, `$name:` is parsed like a scoped-variable reference and can raise `Variable reference is not valid`. Delimit the name as `${name}` whenever a colon immediately follows it.

Literal here-string:

```powershell
$text = @'
{
  "name": "$literal"
}
'@
```

The opener must end its line, and the terminator must start at column one and be the only token on its line. If a here-string must cross JSON plus a shell command string, use a temporary `.ps1` file or a process standard-input API instead.

Do not use a Bash heredoc in PowerShell:

```text
python - <<'PY'
```

For JSON, construct an object and serialize it:

```powershell
$data = [ordered]@{
    name = $name
    path = $path
    flags = @('a', 'b')
}

$data |
    ConvertTo-Json -Depth 10 |
    Set-Content -LiteralPath $jsonPath -Encoding utf8
```

PowerShell variable names are case-insensitive. `$HOME`, `$home`, and `$Home` identify the same variable. Do not reuse a reserved or environment-significant name with different casing. Prefer names such as `$workspaceRoot`, `$targetPath`, or `$nativeArgs`.

## 5. Multiline Scripts And Parser Reduction

For multiline code, nested quotes, JSON, XML, regular expressions, pipelines, redirection, or non-ASCII paths that cross an execution boundary:

1. Remove `cmd.exe` unless cmd semantics are essential.
2. Remove a nested `pwsh -Command` when the host already runs PowerShell.
3. Replace command strings with arrays or hashtable splatting.
4. Replace text pipelines to native programs with redirected standard input when exact bytes matter.
5. If the script still crosses a fragile command-string boundary, write a temporary `.ps1` file.

Preferred automation entry point:

```text
pwsh.exe -NoLogo -NoProfile -NonInteractive -File script.ps1
```

Do not add `-ExecutionPolicy Bypass` by habit.

When an outer PowerShell must invoke a short inner `-Command`, use an outer single-quoted script string so the outer process does not expand inner variables:

```powershell
pwsh.exe -NoLogo -NoProfile -Command '$p = "C:\Data Folder\input.txt"; Test-Path -LiteralPath $p'
```

Use a `.ps1` file instead when both layers need variables, paths, pipelines, JSON, or here-strings.

## 6. ProcessStartInfo For Exact Boundaries And I/O

Use `& $exe @nativeArgs` for ordinary foreground execution. `Start-Process -ArgumentList` joins its values into one command-line string and does not preserve structured boundaries reliably.

Use `ProcessStartInfo.ArgumentList` when exact arguments, empty arguments, or stream redirection matter:

```powershell
$psi = [System.Diagnostics.ProcessStartInfo]::new()
$psi.FileName = $exe
$psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true

foreach ($nativeArg in $nativeArgs) {
    $psi.ArgumentList.Add($nativeArg)
}

$process = [System.Diagnostics.Process]::Start($psi)
$process.StandardInput.Write($inputText)
$process.StandardInput.Close()

$stdout = $process.StandardOutput.ReadToEnd()
$stderr = $process.StandardError.ReadToEnd()
$process.WaitForExit()

if ($process.ExitCode -ne 0) {
    throw "Command failed with exit code $($process.ExitCode): $stderr"
}
```

Read stdout and stderr before or while waiting so a child process with large output cannot deadlock on a full pipe. Do not pipe binary data through text cmdlets.

Use `Start-Process` only when you need elevation, a new or hidden window, detached execution, shell association behavior, or its explicit process semantics.

## 7. Command Discovery And Version Differences

`Get-Command` can resolve an alias, shim, application-execution alias, script, function, or actual executable. When availability matters, inspect what was resolved and make a harmless version call before relying on it:

```powershell
$command = Get-Command $toolName -ErrorAction Stop
$command | Select-Object Name, CommandType, Source, Version
```

A Microsoft Store application-execution alias can exist without an installed runtime. Do not treat resolution alone as proof that the command works.

PowerShell 5.1 and 7 may expose different parameters. Check syntax:

```powershell
Get-Command Format-Hex -Syntax
Get-Command Get-FileHash -Syntax
```

For example, if `Format-Hex -Count` is unavailable, limit the pipeline instead:

```powershell
Format-Hex -LiteralPath 'C:\Data\buffer.bin' | Select-Object -First 2
```

If a cmdlet is unexpectedly missing, inspect `$env:PSModulePath` and installed modules before assuming it is unavailable.

## 8. File And Path Safety

Use `-LiteralPath` for real paths and `-Path` only when wildcard expansion is intentional. Normalize with `Resolve-Path -LiteralPath` for existing paths or `[System.IO.Path]::GetFullPath()` for paths that may not exist yet.

Before recursive mutation, verify a separator-aware child relationship:

```powershell
$resolvedRoot = (Resolve-Path -LiteralPath $expectedRoot).Path
$resolvedTarget = (Resolve-Path -LiteralPath $candidate).Path
$rootPrefix = $resolvedRoot.TrimEnd(
    [System.IO.Path]::DirectorySeparatorChar,
    [System.IO.Path]::AltDirectorySeparatorChar
) + [System.IO.Path]::DirectorySeparatorChar

if (-not $resolvedTarget.StartsWith(
    $rootPrefix,
    [System.StringComparison]::OrdinalIgnoreCase
)) {
    throw "Refusing to modify path outside expected root: $resolvedTarget"
}
```

Also reject empty paths, filesystem roots, the intended root itself unless explicitly allowed, and unexpected targets. Keep file enumeration and mutation in one shell.

Some execution hosts reject inline recursive delete or move commands before PowerShell starts. Preserve the complete validation and mutation logic in a temporary `.ps1` file and run it with `pwsh.exe -File`; do not respond by removing containment checks or splitting enumeration from mutation.

### Mapped drives

Mapped drives are scoped to a user and logon session. If `X:\...` works interactively but not in automation:

```powershell
whoami
Get-PSDrive -Name X -ErrorAction SilentlyContinue
Test-Path -LiteralPath 'X:\Expected\file.dat'
```

Use a verified UNC path, create the mapping in the same identity/session, or ask the user. Do not guess a network path.

## 9. Encoding, Binary Data, And Environment Variables

Specify text encoding when another tool consumes a file:

```powershell
Set-Content -LiteralPath $path -Value $text -Encoding utf8
```

Use byte APIs for binary data:

```powershell
[System.IO.File]::WriteAllBytes($path, $bytes)
```

Read and set environment variables with `$env:NAME`. Do not use `%NAME%` inside PowerShell. Environment changes made by a child process do not propagate back to its parent.

Avoid the stop-parsing token `--%` by default. It is Windows-specific and disables normal PowerShell parsing for the remainder of the command, including variables and expressions.

## 10. Failure Classification And Limited Retry

Do not repeat an identical failing command. Diagnose first:

| Symptom | Likely cause | Method-changing response |
| --- | --- | --- |
| `$p` or `$env:NAME` disappears in an inner command | Outer PowerShell expanded it | Remove nested `-Command`, use an outer literal, or use `.ps1 -File` |
| ParserError, missing terminator, unexpected token | Cross-layer quoting or malformed here-string | Remove a parser layer and parse the script locally before running |
| CreateProcess or wrapper rejection | Command string is too complex or disallowed | Direct invocation, argument arrays, or `ProcessStartInfo` |
| `-Index 100..120` fails to bind | Expression not grouped | Use `-Index (100..120)` |
| `foreach { } |` reports an empty pipe element | Statement piped directly | Assign output first or use `ForEach-Object` |
| Native arguments with spaces break | Arguments flattened into one string | Use `& $exe @nativeArgs` or `ArgumentList` |
| `rg` exits 1 with no output | Valid no-match result | Accept code 1 for probe searches |
| `rg` reports regex parse error | Literal text used as regex or over-escaped | Use `-F` or pass one literal regex argument |
| `$home` cannot be assigned | PowerShell variables are case-insensitive | Rename it to a task-specific variable |
| Command resolves but immediately opens Store or fails | Application-execution alias or broken shim | Use the verified bundled/installed executable path |
| Mapped drive is absent | Different identity or logon session | Check identity and mapping; use verified UNC or ask |

Use at most one method-changing retry for an invocation-shape failure. Authentication, authorization, ambiguous external state, or another failed method requires user input or a clear blocker report.

## 11. Diagnostic Checklist

When invocation behavior is surprising, inspect:

```powershell
$PSVersionTable
$PSNativeCommandArgumentPassing
Get-Command pwsh
Get-Command powershell
Get-Command $exe -ErrorAction SilentlyContinue
```

Then simplify in this order:

1. Remove `cmd.exe`.
2. Remove nested `pwsh -Command`.
3. Remove `Invoke-Expression`.
4. Remove manually nested quotes.
5. Use `-F` for literal searches.
6. Put multiline code in a minimal `.ps1` file.
7. Invoke the native executable directly with an argument array.
8. Use `ProcessStartInfo` only when exact streams or argument boundaries require it.
9. Print each native argument and its length.
10. Capture and interpret the exit code immediately.
