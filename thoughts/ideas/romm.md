# RomM ROM Library Manager

RomM ([rommapp.com](https://rommapp.com)) deployed as podman containers on Zephyrus.

## Containers

| Container | Image | Port | Volumes |
|---|---|---|---|
| `romm-db` | `mariadb:latest` | — | `romm-db-data:/var/lib/mysql` |
| `romm-redis` | `redis:latest` | — | `romm-redis-data:/data` |
| `romm` | `ghcr.io/rommapp/romm:latest` | `8080:8080` | `/var/lib/romm/library`, `/var/lib/romm/assets`, `/var/lib/romm/config`, `romm-resources` |

- All `autoStart = true`
- `romm` depends on `romm-db` and `romm-redis`
- Secrets via `environmentFiles = [ "/var/lib/romm/romm.env" ]`
- Firewall TCP port 8080 opened
- Desktop entry `romm.desktop` opens `http://localhost:8080` via `xdg-open`

## Module Code

```nix
{ ... }:
{
  flake.modules.nixos.gaming = { pkgs, ... }: let
    romm-desktop = pkgs.makeDesktopItem {
      name = "romm";
      desktopName = "RomM";
      comment = "ROM Manager web UI";
      exec = "xdg-open http://localhost:8080";
      icon = "applications-games";
      categories = [ "Game" "System" ];
      keywords = [ "roms" "emulator" "library" ];
    };
  in
  {
    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        "romm-db" = {
          image = "mariadb:latest";
          autoStart = true;
          environment = {
            MARIADB_DATABASE = "romm";
            MARIADB_USER = "romm-user";
          };
          environmentFiles = [ "/var/lib/romm/romm.env" ];
          volumes = [ "romm-db-data:/var/lib/mysql" ];
        };
        "romm-redis" = {
          image = "redis:latest";
          autoStart = true;
          volumes = [ "romm-redis-data:/data" ];
        };
        "romm" = {
          image = "ghcr.io/rommapp/romm:latest";
          autoStart = true;
          dependsOn = [ "romm-db" "romm-redis" ];
          environment = {
            DB_HOST = "romm-db";
            DB_NAME = "romm";
            DB_USER = "romm-user";
            ROMM_DB_DRIVER = "mariadb";
            REDIS_HOST = "romm-redis";
            HASHEOUS_API_ENABLED = "true";
          };
          environmentFiles = [ "/var/lib/romm/romm.env" ];
          volumes = [
            "/var/lib/romm/library:/romm/library"
            "/var/lib/romm/assets:/romm/assets"
            "/var/lib/romm/config:/romm/config"
            "romm-resources:/romm/resources"
          ];
          ports = [ "8080:8080" ];
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 8080 ];

    environment.systemPackages = [ romm-desktop ];
  };
}
```

## Setup Required

Create `/var/lib/romm/romm.env` with:
- `MARIADB_ROOT_PASSWORD`, `MARIADB_PASSWORD`, `DB_PASSWD`
- `ROMM_AUTH_SECRET_KEY` (generate with `openssl rand -hex 32`)
- Optional: `IGDB_CLIENT_ID`, `IGDB_CLIENT_SECRET`, `SCREENSCRAPER_USER`, `SCREENSCRAPER_PASSWORD`

ROMs go in `/var/lib/romm/library/<platform>/roms/`.
