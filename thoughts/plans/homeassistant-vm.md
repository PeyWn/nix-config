# Home Assistant OS VM migration

## Status

Ready for implementation on NixOS-Server.
This is an evidence-based fallback plan without adversarial review.
The native hyperplan team and the in-process model fallback were unavailable during planning.
No repository or system configuration has been changed yet.

## Goal

Replace the Podman-based Home Assistant deployment with a VM on NixOS-Server.
Test the VM and all production-critical integrations before retiring the container.
Keep a working rollback path until the replacement is explicitly accepted.

## Recommended design

Use the official Home Assistant OS KVM image under libvirt/QEMU, with a new `flake.modules.nixos.homeassistant-vm` module.
Keep the existing native `matter-server` initially.
Pass the Zigbee dongle through to the VM.
Migrate through a full Home Assistant backup rather than copying `/var/lib/hass` into the guest.

HAOS requires UEFI and at least 2 vCPUs and 2 GB RAM.
Start with 2 vCPUs, 4 GB RAM, and a 64 GB state disk, subject to server capacity.

## Current deployment facts

- `modules/features/server/homeassistant.nix` currently merges into `flake.modules.nixos.server`.
- Home Assistant runs as the Podman container `homeassistant`, using host networking and `/var/lib/hass:/config`.
- The Sonoff Zigbee coordinator is passed through by its `/dev/serial/by-id/` path.
- `services.matter-server` runs natively on `wlp4s0`.
- NixOS-Server uses NetworkManager and Avahi.
- The flake tracks `nixos-unstable`.
- `just check` is the repository validator.

## Implementation plan

### 1. Resolve server-specific input gates

- Confirm `/dev/kvm`, available RAM, free storage, and the VM backup location.
- Record the Zigbee adapter's USB vendor/product IDs and verify that nothing else uses it.
- Decide whether Ethernet is available.
- Prefer a normal LAN bridge on Ethernet.
- If the server remains on `wlp4s0`, use libvirt NAT, TCP 8123 forwarding, and Avahi reflection instead of assuming Wi-Fi bridging works.
- Pin the HAOS release and record its image hash.
- HAOS 18.4 was the current official download when this plan was written, but verify the intended release before implementation.

Success criterion: all values are known before implementation, and neither `lsusb` bus/device numbering nor an unstable image URL is treated as permanent.

### 2. Separate the existing container module without changing behavior

- Move the current container definition into `modules/features/homeassistant-container.nix`, exposing `flake.modules.nixos.homeassistant-container`.
- Leave `services.matter-server` in the existing server module.
- Keep TCP 8123 ownership with the selected Home Assistant implementation rather than duplicating it.
- Initially keep `nixos.homeassistant-container` imported by NixOS-Server.

Success criterion: `just check` passes and the evaluated container configuration remains unchanged.

### 3. Implement the HAOS VM module

- Add `modules/features/homeassistant-vm.nix`.
- Enable libvirt and configure QEMU to run unprivileged with `virtualisation.libvirtd.qemu.runAsRoot = false`.
- Fetch the pinned qcow2 image declaratively, then create and resize a writable state disk under `/var/lib/libvirt/images`.
- Generate libvirt domain XML with UEFI, VirtIO storage, a stable MAC address, and USB hostdev passthrough by vendor/product ID.
- Grant only `qemu-libvirtd` access to the specific USB adapter.
- Use an idempotent systemd service to define and manage the domain.
- Keep VM autostart disabled during testing.
- Do not use the removed `virtualisation.libvirtd.qemu.ovmf.enable` option, because current nixpkgs manages firmware differently.

Success criterion: `just check` passes, the server system builds, and `virsh dumpxml` shows the expected disk, UEFI, network, and USB configuration.

### 4. Configure and test networking before migration

- On Ethernet, attach the VM to the LAN bridge.
- On Wi-Fi, create a libvirt NAT network with a DHCP reservation, forward external TCP 8123 to the guest, and restrict Avahi reflection to `wlp4s0` and the libvirt interface.
- Boot the blank VM without stopping the container if the network and USB setup permit.
- Otherwise schedule the maintenance window first.

Success criterion: the HAOS onboarding page is reachable from another LAN client, and multicast discovery works in both directions before restoring production data.

### 5. Migrate through a full Home Assistant backup

- Create and download a full backup from the current instance.
- Stop `podman-homeassistant` cleanly and prevent it from restarting.
- Preserve `/var/lib/hass` unchanged as rollback state.
- Start HAOS and choose **Upload backup** during onboarding.

Success criterion: the restored owner account, dashboards, integrations, automations, HACS content, and history are present.

### 6. Exercise the real integrations

- Verify Zigbee coordinator startup and representative device control.
- Verify the existing host `matter-server` still works with restored Matter devices.
- Verify LAN discovery, automations, recorder history, external access, and name resolution.
- Reboot NixOS-Server and repeat the checks.

Success criterion: all production-critical functions pass after a full host reboot, not merely immediately after restore.

### 7. Enable operations only after acceptance

- Enable VM autostart.
- Configure Home Assistant automatic backups with an off-host destination.
- Optionally enable `services.libvirtd.autoSnapshot` for short-term VM recovery.
- Snapshots do not replace Home Assistant backups.

Success criterion: the VM starts automatically and a current backup can be downloaded and inspected.

### 8. Retire the container after a soak period

- Remove the legacy container module and its host import only after explicit acceptance.
- Update `AGENTS.md` and `docs/SERVER_RECOVERY.md` with VM service names, console access, backup restoration, and rollback instructions.

Success criterion: `podman-homeassistant` is absent, `just check` passes, and the documentation matches the deployed VM.

## Rollback

Stop the VM and restart the unchanged container against the preserved `/var/lib/hass`.
Any changes made inside HAOS after migration must be exported or accepted as lost before rolling back.
Use `nixos-rebuild switch --rollback` for host-configuration rollback.

## Verification notes from planning

Nix MCP confirmed the current unstable options for libvirt, unprivileged QEMU, NAT port forwarding, Avahi reflection, libvirt hooks, and automatic VM snapshots.
It also confirmed that `virtualisation.libvirtd.qemu.ovmf.enable` does not exist in the queried unstable option set.

## Sources

- [Home Assistant KVM installation](https://www.home-assistant.io/installation/alternative/)
- [Backup restoration during onboarding](https://www.home-assistant.io/getting-started/onboarding/)
- [Home Assistant backups](https://www.home-assistant.io/common-tasks/general/backups/)
- [libvirt domain and USB configuration](https://libvirt.org/formatdomain.html)
