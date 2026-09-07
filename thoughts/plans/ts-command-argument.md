---
ticket: thoughts/ticket/ts-command-argument.md
created: 2026-08-03
status: approved
---

# Update `ts` Command — Implementation Plan

## Overview
Extend the `ts` tmux session switcher to accept a named session argument for direct create-or-switch, and improve interactive mode with `--select-1` and `--print-query`.

## Findings Summary
- Single file: `modules/features/shell/tmux.nix`
- Existing helpers (`attach_or_switch`, `new_session`) cover all needed logic
- fzf already installed and in use

## Changes Required
- `modules/features/shell/tmux.nix` — add `--select-1 --print-query`, parse 2-line fzf output, add `*)` arm for named session arg

## Implementation Order
1. [x] Replace the `*)` arm in the case statement: parse `--select-1 --print-query` output, use query text as session name when "New Session" selected
2. [x] Add `*)` (3rd case arm) for named session argument: `has-session` → attach or create

## Verification
- [ ] nix flake check (all hosts, at review)
- [ ] Per-subtask nix eval checks

## Out of Scope
- Session management beyond create/switch
- Changes to `new` subcommand behavior
