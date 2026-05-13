---
description: Render Python project scaffold templates into the current directory, substituting {{PROJECTNAME}} with the given project name
---

# py-scaffold-files

Render all Python project scaffold templates into the current working directory.

**Argument**: PROJECTNAME — the Python package name (snake_case)

## Template source

Templates live at `templates/python/` inside the harness repository root — the directory
that contains the `.claude/` configuration directory and the `agents/` directory.

## Rendering steps

For each row in the table:

1. Read the template file from `<harness-root>/templates/python/<Template>`
2. Replace **every** occurrence of `{{PROJECTNAME}}` with the PROJECTNAME argument
3. Create any missing parent directories in the destination path, substituting
   PROJECTNAME for the `{{PROJECTNAME}}` segment where it appears
4. Write the rendered content to `<destination>`

| Template | Destination |
|---|---|
| `pyproject.toml` | `pyproject.toml` |
| `noxfile.py` | `noxfile.py` |
| `init.sh` | `init.sh` |
| `requirements.txt` | `requirements.txt` |
| `gitignore` | `.gitignore` |
| `src/__init__.py` | `src/{{PROJECTNAME}}/__init__.py` |
| `src/__main__.py` | `src/{{PROJECTNAME}}/__main__.py` |
| `tests/test_cli.py` | `tests/test_cli.py` |

After all files are written, make `init.sh` executable:

```bash
chmod +x init.sh
```

## Report

List each file written, and confirm that `{{PROJECTNAME}}` was substituted with the
actual project name everywhere it appeared.
