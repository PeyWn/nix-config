{ ... }:
{
  homeManagerModules.starship = { colors, ... }:
    let
      p = colors;
    in
    {
      programs.starship.enable = true;
      programs.starship.settings = {
        directory.style = "fg:#${p.base0D}";
        directory.format = "[ $path ]($style)";
        git_branch.style = "fg:#${p.base0B}";
        git_branch.format = "[ $symbol$branch ]($style)";
        git_branch.symbol = "󰊢 ";
        git_status.style = "fg:#${p.base0A}";
        git_status.format = "([$all_status$ahead_behind]($style) )";
        character.success_symbol = "[❯](bold #${p.base0B})";
        character.error_symbol = "[❯](bold #${p.base08})";
        cmd_duration.style = "fg:#${p.base04}";
        cmd_duration.format = "[   $duration ]($style)";
        nix_shell.style = "fg:#${p.base0E}";
        nix_shell.format = "[$symbol$state]($style)";
        nix_shell.symbol = "❄️  ";
        time.style = "fg:#${p.base04}";
        time.format = "[   $time ]($style)";
      };
    };
}
