{ pkgs, lib, config, inputs, ... }:

{
  packages = with pkgs; [
    nixd
    mcp-nixos
    alejandra
    nixfmt-rfc-style
    statix
    deadnix
  ];
}
