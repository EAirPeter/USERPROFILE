# WinDbg Guidance

## Use This Document When

- Open and follow this document whenever the task involves WinDbg, CDB, crash dumps, symbol loading, exception-context inspection, or postmortem debugging.

## Symbols

- Use `_NT_SYMBOL_PATH` as the default symbol path. Prefer an explicit symbol path supplied by the user or workspace.
- When debugging dumps from another machine or from binaries not built locally, ask for private symbol access first instead of assuming only public symbols are available.
- If the local workspace instructions specify a private symbol server, use that server.

## Debugging Flow

- Open the dump with the WinDbg tooling first to confirm the session is usable and capture the initial exception thread, module, and stack.
- Configure the symbol path on its own line. Do not append `.reload`, `lm`, or stack commands to the same `.sympath` command.
- Force reload the important modules individually after setting the symbol path.
- Verify that symbols really loaded with `lm`, `lm m`, or `lmvm`. Do not assume success from `.reload` alone.
- Switch to the crashing thread, restore the exception context, and only then inspect the stack.
- If the WinDbg tooling becomes unstable or some follow-up commands time out, use crash folder artifacts such as crash context files, logs, and breadcrumbs as secondary evidence instead of primary proof.

## Reporting

- In the final write-up, explicitly separate what was proven from private-symbol stacks, what was inferred from crash context or logs, and what remains unknown.
