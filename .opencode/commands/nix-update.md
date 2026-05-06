---
description: Update flake inputs with safety verification
agent: build
---
Update the flake inputs for this NixOS configuration repo safely.

## Workflow

1. If `$ARGUMENTS` is provided, update only that input:
   ```
   nix flake update $ARGUMENTS
   ```
   Otherwise, update ALL inputs:
   ```
   nix flake update
   ```

2. Run `nix flake check` to verify the update didn't break anything.

3. If check fails:
   - Invoke the **nix-debugger** subagent to analyze the failure
   - Report what broke and suggest next steps (rollback, fix, or hold)

4. If check passes:
   - Report which inputs were updated (check `flake.lock` diff)
   - Ask whether to rebuild: `sudo nixos-rebuild switch --flake /home/nixos#WSL-IC`
