# Personal Codex setup

Personal preferences, instructions, and skills shared across my computers.

Use relative paths, environment variables, or runtime path discovery in shared docs and skills. Keep machine-specific references in the local Codex setup.

## Contents

- [config.toml](config.toml) stores desktop appearance and input preferences and the TUI status line.
- [AGENTS.md](AGENTS.md) contains global instructions and links to the Python, Unreal Engine, and WinDbg references in [docs/](docs/).
- [skills/](skills/) contains `karpathy-guidelines`, `p4-safe-workflow`, and `powershell-safe-invocation`.

## Set up on Windows

Codex home defaults to `~/.codex`, where `~` is your Windows user profile directory. Use the directory specified by `CODEX_HOME` if it is set.

Before replacing a file or link, compare the file contents or link target with the intended setup. Review any differing local instructions before replacing them.

1. Merge the tracked [config.toml](config.toml) into `config.toml` in Codex home. Keep machine-specific settings in the local file.
2. In Codex home, create an `AGENTS.md` file symlink to the tracked [AGENTS.md](AGENTS.md) and a `docs` directory junction to the tracked [docs/](docs/) folder. The relative links in the global instructions resolve through that junction.
3. Link the three [skill folders](skills/) into `~/.agents/skills/` using a directory junction for each skill. Reuse any existing link that Codex already discovers and that points to the corresponding folder in this checkout. Follow each skill's setup instructions for any required tools.
4. Restart Codex.

Updating this checkout refreshes the linked instructions, docs, and skills. Merge changes to the tracked `config.toml` into the local file when updating preferences.

See the official documentation for [configuration locations](https://learn.chatgpt.com/docs/config-file/config-basic) and [personal skill locations](https://learn.chatgpt.com/docs/build-skills).
