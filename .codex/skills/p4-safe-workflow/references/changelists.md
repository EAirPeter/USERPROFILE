# Perforce Changelist Specifications On Windows

Read this reference when creating or updating a pending changelist with `p4 change -i` from PowerShell.

## Why Standard Input Needs A Dedicated Pattern

Changelist specs are line-oriented text consumed by `p4 change -i`. PowerShell pipelines, text cmdlets, temporary-file encoding, `cmd.exe type`, nested `pwsh -Command`, and host JSON escaping can each alter the text or add another parser. Historical failures include a leading Unicode marker before `Change`, malformed here-strings, lost quotes, and process-wrapper rejection.

Pass the complete spec directly to the native process through redirected standard input. Do not pipe a PowerShell text cmdlet into `p4`, and do not add a cmd `type` pipeline as an encoding workaround.

## Invoke p4 change -i

Use one structured argument per item and write the spec as a string:

```powershell
$spec = @'
Change: new

Client: example-client

User: example-user

Status: new

Description:
	[Tag] One line description.
'@

$psi = [System.Diagnostics.ProcessStartInfo]::new()
$psi.FileName = 'p4'
$psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.ArgumentList.Add('change')
$psi.ArgumentList.Add('-i')

$process = [System.Diagnostics.Process]::Start($psi)
$process.StandardInput.Write($spec)
$process.StandardInput.Close()

$stdout = $process.StandardOutput.ReadToEnd()
$stderr = $process.StandardError.ReadToEnd()
$process.WaitForExit()

if ($process.ExitCode -ne 0) {
    throw "p4 change -i failed with exit code $($process.ExitCode): $stderr"
}

$stdout
```

The literal here-string terminator must start at column one. Keep the description line tab-indented as required by the Perforce form.

## Creating A Pending Changelist

1. Run `p4 info` and use the resolved user and client.
2. Inspect existing candidates with `p4 changes -s pending -u <user> -c <client>` and `p4 change -o <change>`.
3. If no matching task changelist exists, obtain a fresh new-change template with `p4 change -o` when possible.
4. Change only the intended fields, normally `Description`.
5. Send the complete spec through redirected standard input.
6. Parse the returned changelist number and verify it with `p4 change -o <change>`.

Do not create a second changelist merely because the first invocation failed before Perforce processed the spec. Check whether a changelist was actually created before retrying.

## Updating An Existing Pending Changelist

Always begin with the current complete spec:

```text
p4 change -o <change>
```

Modify only the intended fields and send the whole spec back. Preserve the complete `Files` section unless the explicit goal is to remove or relocate opened files. A minimal replacement spec that omits `Files` can remove files from the changelist.

After the update, verify both metadata and membership:

```text
p4 change -o <change>
p4 opened -c <change>
```

If file membership must change, prefer explicit `p4 reopen -c <change> <files>` operations so the target list is visible and narrow.

## Failure Recovery

- `Error in change specification` or a missing field: fetch a fresh template/spec and correct only the named field.
- Authentication failure: stop and ask the user to log in.
- Client mismatch: inspect the current client and exact paths; do not rewrite `Client:` blindly.
- Process-wrapper rejection or PowerShell parser error: reduce interpreter layers and use the standard-input API above.
- Ambiguous result after a transport failure: query pending changelists before retrying to avoid duplicates.
