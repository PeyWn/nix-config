#!/usr/bin/env bash
# Migrate old Home Assistant data to Nix-managed installation.
# Usage: sudo bash migrate-ha.sh

set -euo pipefail

BACKUP_DATA="/tmp/ha-migration/data"
HA_DIR="/var/lib/hass"

echo "=== Home Assistant Migration ==="
echo "Backup source: $BACKUP_DATA"
echo "Target:        $HA_DIR"
echo ""

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Must run as root (sudo)"
    exit 1
fi

if [ ! -d "$BACKUP_DATA" ]; then
    echo "ERROR: Backup data not found at $BACKUP_DATA"
    echo "Run: tar xf /home/peywn/Downloads/migration.tar -C /tmp/ha-migration"
    echo "     tar xzf /tmp/ha-migration/homeassistant.tar.gz -C /tmp/ha-migration"
    exit 1
fi

echo "[1/5] Stopping home-assistant..."
systemctl stop home-assistant 2>/dev/null || true
systemctl reset-failed home-assistant 2>/dev/null || true

echo "[2/5] Backing up existing HA data (if any)..."
if [ -d "$HA_DIR" ] && [ "$(ls -A "$HA_DIR" 2>/dev/null)" ]; then
    BACKUP_FILE="/tmp/ha-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar czf "$BACKUP_FILE" -C "$(dirname "$HA_DIR")" "$(basename "$HA_DIR")"
    echo "  -> Existing data backed up to $BACKUP_FILE"
fi

echo "[3/5] Copying backup data to $HA_DIR..."
mkdir -p "$HA_DIR"
cp -r "$BACKUP_DATA"/* "$HA_DIR/"

echo "[4/5] Fixing permissions..."
chown -R hass:hass "$HA_DIR"

echo "[5/5] Done! Now run 'rebuild' to apply Nix config."
echo ""
echo "  rebuild"

echo ""
echo "=== Files migrated ==="
echo "  zigbee.db        - ZHA network (Sonoff coordinator)"
echo "  .storage/        - Integrations, users, dashboards, entities"
echo "  automations.yaml - 9 automations"
echo "  scripts.yaml     - 4 scripts"
echo "  scenes.yaml      - 2 scenes"
echo "  blueprints/      - Automation blueprints"
echo "  www/community/   - HACS frontend cards"
echo "  custom_components/ - HACS, Nordpool, MASS"
echo "  configuration.yaml - Includes appended by Nix preStart"
