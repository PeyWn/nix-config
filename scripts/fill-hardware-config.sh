#!/usr/bin/env bash
set -euo pipefail

# Fills placeholder UUIDs in a hardware blueprint using values from
# a freshly-generated hardware-configuration.nix.
#
# Usage (from the live ISO, after partitioning + mounting):
#   ./scripts/fill-hardware-config.sh Zephyrus /mnt
#
# If MOUNT_POINT is omitted, defaults to /mnt.

HOST="${1:?Usage: $0 <HOSTNAME> [MOUNT_POINT]}"
MP="${2:-/mnt}"

CONFIG_DIR="$MP/etc/nixos"
HW_BLUEPRINT="$CONFIG_DIR/hardware/${HOST}.nix"
GENERATED="$CONFIG_DIR/hardware-configuration.nix"

if [[ ! -f "$GENERATED" ]]; then
  echo "ERROR: $GENERATED not found."
  echo "Run: sudo nixos-generate-config --root $MP"
  exit 1
fi

if [[ ! -f "$HW_BLUEPRINT" ]]; then
  echo "ERROR: $HW_BLUEPRINT not found."
  echo "Available blueprints:"
  ls "$CONFIG_DIR/hardware/" 2>/dev/null || echo "  (none)"
  exit 1
fi

echo "==> Reading generated hardware config: $GENERATED"
echo "==> Filling blueprint: $HW_BLUEPRINT"

# Extract UUIDs from generated config
ROOT_UUID=$(grep -oP 'fileSystems\."/"\s*\{[^}]*device\s*=\s*"/dev/disk/by-uuid/\K[^"]+' "$GENERATED" || true)
BOOT_UUID=$(grep -oP 'fileSystems\."/boot"\s*\{[^}]*device\s*=\s*"/dev/disk/by-uuid/\K[^"]+' "$GENERATED" || true)
SWAP_UUID=$(grep -oP 'swapDevices\s*\[[^]]*device\s*=\s*"/dev/disk/by-uuid/\K[^"]+' "$GENERATED" || true)

# Extract kernel modules
AVAIL_MODULES=$(grep -oP 'boot\.initrd\.availableKernelModules\s*=\s*\[\K[^\]]+' "$GENERATED" || true)
KERNEL_MODULES=$(grep -oP 'boot\.kernelModules\s*=\s*\[\K[^\]]+' "$GENERATED" || true)

if [[ -z "$ROOT_UUID" ]]; then
  echo "ERROR: Could not extract root filesystem UUID from $GENERATED"
  exit 1
fi

echo "    ROOT_UUID = $ROOT_UUID"
echo "    BOOT_UUID = ${BOOT_UUID:-(missing — check generated config)}"
echo "    SWAP_UUID = ${SWAP_UUID:-(none / swap file)}"

# Update kernel modules if detected
if [[ -n "$AVAIL_MODULES" ]]; then
  echo "    availableKernelModules = [$AVAIL_MODULES]"
fi

# Substitute placeholders
sed -i.bak \
  -e "s|__ROOT_UUID__|$ROOT_UUID|g" \
  -e "s|__BOOT_UUID__|$BOOT_UUID|g" \
  -e "s|__SWAP_UUID__|$SWAP_UUID|g" \
  "$HW_BLUEPRINT"

echo "==> Backed up original to ${HW_BLUEPRINT}.bak"

# Replace availableKernelModules if we found them
if [[ -n "$AVAIL_MODULES" ]]; then
  sed -i \
    -e "s|boot\.initrd\.availableKernelModules = \[.*\];|boot.initrd.availableKernelModules = [ $AVAIL_MODULES ];|" \
    "$HW_BLUEPRINT"
fi

if [[ -n "$KERNEL_MODULES" ]]; then
  sed -i \
    -e "s|boot\.kernelModules = \[.*\];|boot.kernelModules = [ $KERNEL_MODULES ];|" \
    "$HW_BLUEPRINT"
fi

echo ""
echo "==> Hardware blueprint updated."
echo "    Review $HW_BLUEPRINT, then run:"
echo "    sudo nixos-install --flake \"$CONFIG_DIR#$HOST\""
