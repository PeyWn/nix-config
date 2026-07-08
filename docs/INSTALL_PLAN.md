# Bare-Metal NixOS Installation — Gaming-PC

## Prerequisites

- NixOS minimal ISO on a USB stick (download from https://nixos.org/download)
- UEFI boot enabled in BIOS
- Internet access (Ethernet recommended during install)

---

## Step 1: Boot the Live ISO

1. Insert the USB stick and boot from it (F12/DEL to enter boot menu).
2. Confirm you have internet: `ping -c 3 nixos.org`
3. If on Wi-Fi, connect via `wpa_supplicant` or use `nmtui`.

---

## Step 2: Partition the Disk

Identify your target disk (`/dev/nvme0n1` or `/dev/sda`):

```bash
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
```

Partition with `gdisk` (GPT layout):

```bash
# Replace /dev/nvme0n1 with your disk
sudo gdisk /dev/nvme0n1
```

| Partition | Size | Type Code | Purpose |
|---|---|---|---|
| 1 | +1G | ef00 | EFI System Partition |
| 2 | Depends | 8300 | Root (ext4) |
| 3 | +32G | 8200 | Swap |

Format:

```bash
# EFI
sudo mkfs.fat -F 32 /dev/nvme0n1p1
# Root
sudo mkfs.ext4 /dev/nvme0n1p2
# Swap
sudo mkswap /dev/nvme0n1p3
sudo swapon /dev/nvme0n1p3
```

Mount:

```bash
sudo mount /dev/nvme0n1p2 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot
```

---

## Step 3: Clone the Configuration Repository

```bash
# IMPORTANT: Replace <YOUR_USER> and <YOUR_REPO> with your actual GitHub details!
git clone https://github.com/<YOUR_USER>/<YOUR_REPO>.git /mnt/etc/nixos/

# Alternative to the one above
nix run nixpkgs#gh repo clone PeyWn/nix-config nixos

```

This one-liner avoids dealing with SSH keys on the live USB.

---

## Step 4: Generate Hardware Configuration

```bash
sudo nixos-generate-config --root /mnt
```

This produces `/mnt/etc/nixos/hardware-configuration.nix`. Copy the block device UUIDs from
the generated file into the placeholders in `/mnt/etc/nixos/hardware/Gaming-PC.nix`:

```bash
# Find the generated UUIDs
grep by-uuid /mnt/etc/nixos/hardware-configuration.nix

# Edit Gaming-PC.nix and replace:
#   __ROOT_UUID__  -> your root partition UUID
#   __BOOT_UUID__  -> your EFI partition UUID
#   __SWAP_UUID__  -> your swap partition UUID
```

After substitution, remove the auto-generated file (only the flake's host definition is used):

```bash
rm /mnt/etc/nixos/hardware-configuration.nix
rm /mnt/etc/nixos/configuration.nix
```

---

## Step 5: Install

```bash
sudo nixos-install --flake "/mnt/etc/nixos#Gaming-PC"
```

When prompted, set the root password. After installation finishes, reboot:

```bash
sudo reboot
```

Remove the USB stick when prompted.

---

## Step 6: First Boot

1. SDDM should appear with session options: Plasma (X11), Niri, and Steam GamepadUI (Gamescope).
2. Log in as user `bjorn` with the initial password `nixos`.
3. Change the password immediately: `passwd`
4. Optional: set up SSH keys and re-key `initialPassword` from `modules/features/shell/zsh.nix`.

---

## Post-Install Verification

### Graphics

```bash
glxinfo | grep "OpenGL renderer"       # Should show AMD Radeon
vulkaninfo | grep "GPU id"             # Should show your AMD GPU
```

### Audio

```bash
pactl info | grep "Server Name"        # Should show PipeWire
```

### Steam & Gaming

```bash
steam                                    # Launch from terminal to see logs
gamemoded -t                             # Verify GameMode is functional
mangohud glxgears                        # Verify MangoHud overlay works
```

### Niri

Select Niri from SDDM or run: `niri --session`

### Services

```bash
systemctl --failed                       # Should be empty
journalctl -b -p 3                       # Check for boot errors
```
