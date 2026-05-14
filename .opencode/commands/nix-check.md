---
description: Run nix flake check and debug any failures
agent: build
---
Run nix flake check on this NixOS configuration repo and analyze the results.

1. Run `nix flake check` with show-trace.

2. If it passes cleanly, confirm success with a concise summary.

3. If it fails:
   - Invoke the **nix-debugger** subagent to analyze the error output
   - The debugger should identify the root cause and suggest specific fixes
   - Ask if the user wants to apply the fixes

4. Report final status clearly.
