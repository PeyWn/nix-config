# NIX-IC

NixOS configuration using the [Dendritic Pattern](https://github.com/vic/import-tree).

## Structure

```
flake.nix          # Entry point — auto-imports modules/ and hosts/ via import-tree
modules/           # Feature modules (flake-parts, each exported as deferredModule)
hosts/NIX-IC.nix   # Machine configuration — imports selected feature modules
```

### Modules

| Module | Purpose |
|---|---|
| `shell.nix` | zsh, starship, zoxide, oh-my-zsh |
| `tmux.nix` | tmux + plugins |
| `git.nix` | git, delta pager, lazygit |
| `ssh.nix` | SSH agent + Azure DevOps client config |
| `nvim.nix` / `lazyvim-home.nix` | neovim + LazyVim |
| `devtools.nix` | ranger and general CLI tools |
| `devenv.nix` | devenv + cachix |
| `claude.nix` | claude-code (unfree) |
| `home.nix` | home-manager integration |

