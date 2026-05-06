---
description: Add a new NixOS feature — full agentic workflow: plan, implement, check, review, debug
agent: build
---
Add a new NixOS feature to this configuration repo: **$ARGUMENTS**

Follow this agentic workflow using the specialized Nix subagents. Do NOT stop after planning — proceed through all phases automatically.

## Phase 1: Plan (@nix-planner)

Start by invoking the **nix-planner** subagent to explore the codebase and create an implementation plan. The planner should:
- Read relevant existing modules in `modules/features/` and `modules/system/`
- Determine if this is a NixOS module, home-manager module, or both
- Check if external inputs are needed in `flake.nix`
- Identify which host files need updated imports
- Produce a clear step-by-step plan

## Phase 2: Implement (@nix-implementer)

Invoke the **nix-implementer** subagent with the plan to:
- Create the module file(s) in the correct directory
- Update host file imports
- Add any needed flake inputs

## Phase 3: Verify

Run `nix flake check` to verify correctness. If it fails:
- Invoke **nix-debugger** to analyze the error
- Feed the fix back to **nix-implementer**
- Re-run check until it passes

## Phase 4: Review (@nix-reviewer)

Invoke the **nix-reviewer** subagent to audit the final result for:
- Dendritic Pattern compliance
- Code correctness
- Style consistency
- Security

## Phase 5: Rebuild

If all checks pass and review is clean, ask whether to run `sudo nixos-rebuild switch --flake /home/nixos#WSL-IC` to apply.

IMPORTANT: This is a Build-mode task. Use the task tool to invoke subagents. Do not just plan — execute the full workflow.
