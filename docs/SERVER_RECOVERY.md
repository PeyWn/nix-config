# NixOS-Server Recovery - flake.lock fix (2026-10-26)

Commit `e8d3f57` pushed a `flake.lock` whose `home-manager` entry pointed at the `ogulcancelik/herdr` repo, so no host could evaluate.
`f9ca1b1` restored the lock from `faef76a`, and the commits after it removed noctalia and fixed an avahi deprecation.
The server has not rebuilt since `e8d3f57`, so its first rebuild also rolls out the Home Assistant Wi-Fi wait from that commit for the first time.

## Roll out on the server

1. Pull and rebuild:
   ```bash
   cd ~/.config/nixos
   git pull
   rebuild
   ```
   If `git pull` refuses because of local `flake.lock` changes, check them with `git diff flake.lock`, then discard them with `git restore flake.lock` and pull again.
2. Check the services:
   ```bash
   systemctl status podman-homeassistant matter-server
   ```
3. Check that Home Assistant answers:
   ```bash
   curl -sI http://localhost:8123 | head -1
   ```
   Any HTTP status line means it is up.

## If Home Assistant does not start

- The container waits up to 30 seconds for `wlp4s0` to get an IPv4 address and fails if it does not.
  Check the address with `ip addr show wlp4s0`.
- Read the logs:
  ```bash
  journalctl -u podman-homeassistant -b
  podman logs homeassistant
  journalctl -u matter-server -b
  ```
- To get back to the previous working system while you investigate:
  ```bash
  sudo nixos-rebuild switch --rollback
  ```

## Diagnosing a failed rebuild

1. Get the real error without building, and without letting Nix rewrite the lock:
   ```bash
   nix eval --no-write-lock-file --raw .#nixosConfigurations.NixOS-Server.config.system.build.toplevel.drvPath
   ```
   Read it bottom up: the last `error:` line is the cause, and the nearest `while evaluating definitions from <file>` names the module that hit it.
2. Find out whether the code or the lock is at fault.
   Evaluate an older commit as a whole:
   ```bash
   nix eval --no-write-lock-file --raw "git+file://$PWD?rev=$(git rev-parse HEAD~1)#nixosConfigurations.NixOS-Server.config.system.build.toplevel.drvPath"
   ```
   Or evaluate the current code against an older lock:
   ```bash
   git show HEAD~1:flake.lock > /tmp/good.lock
   nix eval --no-write-lock-file --reference-lock-file /tmp/good.lock --raw .#nixosConfigurations.NixOS-Server.config.system.build.toplevel.drvPath
   ```
3. Before committing a fix, run `just check`; it evaluates all five hosts.

## Open follow-ups

- `mcp-nixos` (`modules/features/llm.nix`) depends on `fastmcp-slim`, which the latest nixpkgs marks broken, so `just update` fails on every host for now.
  Try again in a few days; if it is still broken, remove or pin `mcp-nixos` in its own commit.
- noctalia v5 for the niri sessions on Gaming-PC and Zephyrus is tracked in `thoughts/tickets/feature_noctalia-v5.md`.
