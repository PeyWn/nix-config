---
description: Show Home Assistant logs — service status, systemd journal, and HA internal log
agent: build
---
Show the current state of Home Assistant: service status, recent systemd journal entries, and errors from the HA log.

Run these and summarize:

1. Service status:
```bash
systemctl status home-assistant --no-pager -l
```

2. Systemd journal (last 50 lines):
```bash
journalctl -u home-assistant --no-pager -n 50
```

3. HA internal log errors (last 30):
```bash
grep -i "error\|exception\|traceback" /var/lib/hass/home-assistant.log 2>/dev/null | tail -30 || echo "(no HA log yet)"
```

4. If the service is failing, also show the preStart script:
```bash
nix eval .#nixosConfigurations.NixOS-Server.config.systemd.services.home-assistant.preStart --raw 2>/dev/null
```

Summarize:
- Is the service running?
- Any errors in systemd journal?
- Any errors in HA's internal log?
- If failing, what's the likely cause? Suggest running the ha-debugger agent for deeper analysis.
