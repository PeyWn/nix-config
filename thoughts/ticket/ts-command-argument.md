---
stage: done
status: done
status: open
created: 2026-08-03
host: WSL-IC
---

# Update `ts` command to accept session name argument

## Description

The `ts` (tmux session switcher) currently only works in interactive fzf mode. Add support for passing a session name directly as an argument:

- `ts work` — Create session "work" if it doesn't exist, or switch to it if it does
- `ts` — Interactive fzf mode (unchanged), but:
  - Add `--select-1` so if the query matches exactly one existing session, auto-select it
  - If the user types "work" and only "New Session" remains → create session "work" without further prompting (use `--print-query` to capture the typed text)

## Acceptance Criteria

- `ts <name>` creates or switches to the named session
- `ts` interactive picker auto-selects when exactly one session matches the filter
- `ts` interactive: when user types a name and only "New Session" remains, create that named session
