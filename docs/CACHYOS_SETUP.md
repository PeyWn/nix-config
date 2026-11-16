# Gaming-PC on CachyOS - setup

Gaming-PC runs CachyOS with Nix as a package manager next to pacman.
Terminal tools and their config come from the standalone home-manager config `peywn@Gaming-PC` in this repo.
GUI apps come from pacman.

Before you start, make sure the commit that adds `configurations.home."peywn@Gaming-PC"` is pushed to `origin`.

## 1. Install CachyOS

1. Install CachyOS and create the user `peywn`.
2. Set the hostname to `Gaming-PC`, because `rebuild` looks up `peywn@<hostname>`:
   ```bash
   sudo hostnamectl set-hostname Gaming-PC
   ```
3. Install the GUI apps, zsh and git with pacman:
   ```bash
   sudo pacman -S --needed git zsh alacritty ttf-jetbrains-mono-nerd
   ```

## 2. Install Nix

1. Run the official multi-user installer:
   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```
2. Open `/etc/nix/nix.conf` with `sudo` and add:
   ```
   experimental-features = nix-command flakes
   trusted-users = root peywn
   ```
   `trusted-users` lets the devenv and numtide binary caches from this repo work for your user.
   Without it, those packages build from source.
3. Restart the daemon, then open a new terminal so `nix` is on your PATH:
   ```bash
   sudo systemctl restart nix-daemon
   nix --version
   ```

## 3. Log in to GitHub and create an SSH key

Run the GitHub CLI straight from nixpkgs with `nix run`, without installing it.

1. Log in, choosing SSH as the git protocol:
   ```bash
   nix run nixpkgs#gh -- auth login --hostname github.com --git-protocol ssh --web
   ```
   - When asked `Generate a new SSH key to add to your GitHub account?`, answer yes.
   - Set a passphrase, or leave it empty.
   - Give the key a title such as `Gaming-PC`.
   - Open the URL it prints and enter the one-time code.

   gh writes the key to `~/.ssh/id_ed25519` and uploads the public key to your account.
   This is the default key name, so SSH uses it without a `~/.ssh/config` entry.
2. Check that GitHub accepts the key:
   ```bash
   ssh -T git@github.com
   ```
   It should answer `Hi PeyWn! You've successfully authenticated`.

If you already have a key, or want one with another name, upload it yourself instead:
```bash
ssh-keygen -t ed25519 -C "peywn@Gaming-PC" -f ~/.ssh/id_private
nix run nixpkgs#gh -- auth refresh -h github.com -s admin:public_key
nix run nixpkgs#gh -- ssh-key add ~/.ssh/id_private.pub --title "Gaming-PC"
```
A key not named `id_ed25519` needs this in `~/.ssh/config`:
```
Host github.com
  User git
  IdentityFile ~/.ssh/id_private
  AddKeysToAgent yes
```

## 4. Clone the config

```bash
nix run nixpkgs#gh -- repo clone PeyWn/nix-config ~/.config/nixos
```

## 5. Activate home-manager

1. Run the first switch.
   `-b bak` renames existing dotfiles such as `~/.zshrc` to `*.bak` instead of failing on them:
   ```bash
   nix run home-manager -- switch -b bak --flake ~/.config/nixos#peywn@Gaming-PC
   ```
2. Make zsh your login shell (CachyOS defaults to fish):
   ```bash
   chsh -s /usr/bin/zsh
   ```
3. Log out and back in.
   The shell now has the prompt, aliases, tmux, nvim, lazygit, the LLM tools and everything else in `modules/homemanager/`.

## 6. Check it works

```bash
home-manager --version
which nvim lazygit delta claude devenv
git config --get core.pager
```
`which` should print paths under `~/.nix-profile/bin` or `/nix/store`, and the last command should print `delta`.

## Day to day

- Change the config, then apply it with `rebuild`.
  On CachyOS it runs `home-manager switch` instead of `nixos-rebuild`.
- Change the theme with `rebuild --theme everforest-light`.
- Run `git pull` before `just update` or `rebuild`, as `AGENTS.md` says.
- Free space from old generations with `nix-collect-garbage -d`.
- System packages, drivers and GUI apps stay with pacman: `sudo pacman -Syu`.
