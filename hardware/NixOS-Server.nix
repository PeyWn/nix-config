{ ... }:
{
  # Replace with output of `nixos-generate-config --show-hardware-config`

  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/...";
  #   fsType = "ext4";
  # };

  # swapDevices = [ { device = "/dev/disk/by-uuid/..."; } ];

  networking.useDHCP = false;
  # networking.interfaces.eth0.useDHCP = true;

  # hardware.opengl.enable = true;
}
