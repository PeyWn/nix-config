---
description: Update flake inputs with safety verification. Delegates nix operations to nix-debugger agent.
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
   - Spawn **nix-debugger** to analyze the failure
   - Report what broke and suggest next steps

4. If check passes:
   - Report which inputs were updated (check `flake.lock` diff)
   - Remind the user to commit `flake.lock`
   - Ask whether to rebuild on the current host (from HOST.md)
