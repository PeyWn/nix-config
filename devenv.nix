{ pkgs, lib, config, inputs, ... }:

{
  packages = [ pkgs.nixd pkgs.alejandra ];
}
