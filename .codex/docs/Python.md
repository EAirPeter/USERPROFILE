# Python Guidance

## Use This Document When

- Open and follow this document whenever the task needs Python tooling, Python scripts, Python package installation, or a Python virtual environment.

## Default Policy

- Unless the user or the local workspace instructions specify a different Python environment, reuse an existing workspace-local `.venv` when present.
- Otherwise create `.venv` with `uv venv .venv`.
- Run Python with `.venv\Scripts\python.exe` instead of a global or system interpreter.
- Install packages with `uv pip` against that interpreter, for example `uv pip install --python .\.venv\Scripts\python.exe <package>`.
- Reuse the same `.venv` across agents instead of creating another virtual environment.

## Overrides

- If the workspace already uses a different Python environment manager such as Conda, venv, or Poetry, follow the workspace-local instructions instead of forcing `uv`.
- If the user explicitly requests a different interpreter or environment manager, follow the user instruction instead of this document.
