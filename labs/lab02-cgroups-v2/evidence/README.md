# Evidence Collection

This directory belongs to the fresh Lab 02 rebuild.

## Layout

- `raw/` — command output captured directly from the lab VM.
- `screenshots/` — screenshots with terminal context.
- `manifest.md` — evidence index, provenance, and acceptance mapping.

## Rules

- Save only output from commands actually executed.
- Include timestamp, environment/version, command, actual output, and errors.
- Keep expected output in lab instructions, never in raw evidence.
- Do not copy historical screenshots into this directory and present them as new evidence.
- Redact secrets, tokens, private IPs if sensitive, and personal data before committing.
