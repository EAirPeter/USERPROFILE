# Personal Codex setup

Personal preferences, instructions, and skills shared across my computers.

## Contents

- [config.toml](config.toml): desktop appearance and input preferences, TUI status line, and the experimental context-management setting.
- [AGENTS.md](AGENTS.md): global working instructions, with references in [docs/](docs/) for Python, Unreal Engine, and WinDbg.
- [skills/](skills/): `karpathy-guidelines`, `p4-safe-workflow`, and `powershell-safe-invocation`.

## Use on another computer

1. Merge `config.toml` into `~/.codex/config.toml`, or the equivalent under a custom `CODEX_HOME`.
2. Copy `AGENTS.md` and `docs/` together into that Codex home directory. Merge any existing instructions you want to retain.
3. Copy the three skill folders into `~/.agents/skills/`. Keep one installed copy of each skill and follow its setup instructions for any required tools.
4. Restart Codex.

On Windows, `~` is your user profile directory. The instructions and skills assume a Windows/PowerShell workflow. Updates in this repository are applied manually on each computer.

See the official documentation for [configuration locations](https://learn.chatgpt.com/docs/config-file/config-basic) and [personal skill locations](https://learn.chatgpt.com/docs/build-skills).
