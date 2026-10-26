---
type: feature
priority: medium
created: 2026-10-26T12:00:00Z
status: created
tags: [noctalia, niri, desktop, nix-wrapper-modules]
---

# Migrate Gaming-PC and Zephyrus niri sessions to noctalia v5

## Description

Bring back a noctalia shell (bar, notifications, control center) in the niri sessions on Gaming-PC and Zephyrus, this time on noctalia v5.
The v4 shell (`noctalia-shell`) was removed from this config because nixpkgs dropped it.

## Context

nixpkgs removed `noctalia-shell` and `noctalia-qs` in PR #576915 (merged 2026-10-22), because `noctalia-qs` was archived on 2026-07-15 and v4 is no longer maintained.
Evaluation then failed with `'noctalia-shell' has been removed because it is no longer maintained, consider using 'noctalia' (v5) instead`.
The config removed the v4 shell rather than pin an unmaintained package; find that commit with `git log --diff-filter=D -- modules/features/noctalia.nix` and read the old settings with `git show <sha>^:modules/features/noctalia.nix`.
Until this ticket lands, niri on both desktops has no bar, no notification popups and no control center; KDE sessions are unaffected.

## Requirements

### Functional Requirements

- Gaming-PC and Zephyrus install noctalia v5 and niri starts it at login.
- The bar sits on the left with the v4 widget set: control center, workspaces, notification history, volume, battery (hidden when absent), clock, tray.
- Colours come from `config.theme.colors`, so changing the theme recolours the shell.
- Fonts match v4: `Sans Serif` as the default font, `JetBrainsMono Nerd Font` where v5 has a matching key.
- Settings v5 does not support (for example `floating`, `density`, a fixed-width font key) are dropped, not emulated.
- Nix sets the defaults, and changes made in noctalia's settings GUI still take effect and survive a restart, as they did with v4's `outOfStoreConfig`.
- niri reserves space for the bar again, either through noctalia's own reservation or a `struts.left` sized to the bar.

### Non-Functional Requirements

- Prefer the upstream nix-wrapper-modules noctalia v5 wrapper over a hand-written module, matching how `niri` is wrapped.
- `just check` evaluates all five hosts.

## Current State

- No noctalia module exists; `modules/features/noctalia.nix` was deleted and no host imports `nixos.noctalia`.
- niri has no `spawn-at-startup` entry and no `struts.left` (`modules/features/desktop/niri.nix`).
- nixpkgs ships `pkgs.noctalia` 5.3.0 with `meta.mainProgram = "noctalia"`; upstream had tagged 5.4.0 by 2026-10-26.
- nix-wrapper-modules only ships the v4 wrapper `wrapperModules/n/noctalia-shell/module.nix`, which defaults `package` to the removed `pkgs.noctalia-shell`.

## Desired State

Logging into niri on Gaming-PC or Zephyrus shows a themed noctalia v5 bar on the left with the widgets above, notifications pop up, and GUI setting changes persist.

## Out of Scope

- noctalia on NixOS-Server or in KDE sessions - it never ran there.
- A temporary bar such as waybar until v5 lands.
- Replacing fuzzel with noctalia's launcher.
- noctalia's lock screen, idle handling and plugins.

## Research Context

### Keywords to Search

- `wrappers.niri.wrap` (`modules/features/desktop/niri.nix:6`) - the wrapper pattern a v5 module should follow.
- `spawn-at-startup`, `struts` in `modules/features/desktop/niri.nix` - where the shell is launched and space reserved; both were removed with v4.
- `config.theme.colors` (`modules/features/theme.nix:99`) - the base16 palette the v4 colours were built from.
- `nixos.noctalia` in `hosts/Gaming-PC/default.nix` and `hosts/Zephyrus/default.nix` - where the import goes back.

### Patterns to Investigate

- nix-wrapper-modules PR #598 "feat(wrapperModules.noctalia): init" (https://github.com/BirdeeHub/nix-wrapper-modules/pull/598) - open since 2026-08-25, a reviewer flagged that its `settings` and `colors` still assume JSON; check whether it has merged and what options it exposes.
- noctalia v5 configuration (https://docs.noctalia.dev/noctalia/configuration/) - TOML in `~/.config/noctalia/` or `$NOCTALIA_CONFIG_HOME/noctalia/`; the GUI writes `~/.local/state/noctalia/settings.toml`; find out how the two layers merge.
- noctalia v5 palette (https://docs.noctalia.dev/noctalia/theming/palette/) - still JSON, with snake_case roles (`mSurfaceVariant` became `surface_container`, `mOutline` became `outline_variant`); the rest of the mapping is unverified.
- noctalia v5 bar and widgets (https://docs.noctalia.dev/noctalia/bar/, https://docs.noctalia.dev/noctalia/bar/widgets/) - `[bar.<name>]` with `start`/`center`/`end`, `exclusive` became `reserve_space`, `ControlCenter` became `control-center`, `Workspace` became `workspaces`, `NotificationHistory` maps loosely to `notifications`.
- noctalia v5 shell settings (https://docs.noctalia.dev/noctalia/configuration/shell/) - `[shell.animation] speed`, `[shell] corner_radius_scale`, `[shell.screen_corners] size` (pixels), `[shell] font_family`.

### Key Decisions Made

- v4 is not pinned - it depends on the archived `noctalia-qs` and gets no fixes.
- The upstream wrapper is preferred; research decides between it and a hand-written module based on PR #598's state when this ticket is picked up.
- There is no start condition; the ticket can be picked up at any time.
- Parity is best effort: settings without a v5 equivalent are dropped.

## Success Criteria

### Automated Verification

- [ ] `just check` passes.
- [ ] `nix eval --raw .#nixosConfigurations.Zephyrus.config.system.build.toplevel.drvPath` and the same for `Gaming-PC` succeed.

### Manual Verification

- [ ] Logging into niri on Zephyrus and on Gaming-PC starts noctalia with the bar on the left and the listed widgets.
- [ ] Windows do not overlap the bar.
- [ ] `notify-send test` shows a popup.
- [ ] Switching theme with `rebuild --theme <name>` recolours the bar.
- [ ] A setting changed in the noctalia GUI survives a noctalia restart and a `rebuild`.

## Related Information

- nixpkgs PR #576915: https://github.com/NixOS/nixpkgs/pull/576915
- noctalia v5 FAQ (v4 settings are not migrated): https://docs.noctalia.dev/noctalia/getting-started/faq/
- v4 wrapper PR #359: https://github.com/BirdeeHub/nix-wrapper-modules/pull/359

## Notes

- The v5 palette mapping for `mSecondary`, `mTertiary`, `mError`, `mSurface` and the `mOn*` roles was not verified.
- Whether v5 still offers the per-widget options v4 used (`showApplications`, `labelMode`, `hideIfNotDetected`, `usePrimaryColor`, `drawerEnabled`) was not verified.
