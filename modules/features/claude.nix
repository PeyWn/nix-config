{ ... }:
{
  flake.modules.nixos.claude = { pkgs, ... }: {
    nixpkgs.config.allowUnfreePredicate = pkg: pkg.pname == "claude-code";
    environment.systemPackages = with pkgs; [ claude-code mcp-nixos ];
  };
}
