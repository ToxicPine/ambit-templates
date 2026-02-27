# Wetty on Ambit

A persistent cloud terminal you access from any browser, including on iOS. You can run Claude Code, long-running scripts, or a full development shell from your phone, tablet, or laptop without SSH clients, key management, or port forwarding.

## Why This Exists

Sometimes you need a real terminal on your phone. Maybe you want to check on a deploy, run Claude Code, or fix something while you're away from your desk.

This template puts [WeTTY](https://github.com/butlerx/wetty) (a web-based terminal emulator) on [Ambit](https://github.com/ToxicPine/ambit), giving you a persistent shell that lives in the cloud and is accessible from any browser. 

There's no SSH, and no keys to manage, etc: just open the URL and you're in.

## Setup

You can deploy WeTTY to [Ambit](https://github.com/ToxicPine/ambit), which wraps Fly.io.

```bash
npx skills add ToxicPine/ambit-skills --skill ambit-cli  # optional, but helpful for AI agents
npx @cardelli/ambit create lab
npx @cardelli/ambit deploy my-shell.lab --template ToxicPine/ambit-templates/wetty
```

Open `http://my-shell.lab` on any device on your Tailscale network. You'll land in a bash shell immediately.

## Customize Your Environment

All software is managed through [Home Manager](https://nix-community.github.io/home-manager/) and a Nix flake at `~/.nixcfg/`.

**Add a Package:**

1. Edit `~/.nixcfg/home.nix`
2. Add the package to `home.packages` (e.g. `pkgs.python3`)
3. Run `rebuild`

**Search for Packages:**

```bash
nix search nixpkgs <query>
```

Changes persist across restarts via the Fly volume.

## Default Specs (Configurable)

| | |
|---|---|
| CPU | 2x shared |
| Memory | 2 GB |
| Disk | 16 GB persistent volume |
| Auto stop | Suspend when idle |
| Auto start | Wake on HTTP request |

## Files

```
system.nix   — entrypoint (WeTTY), system packages
home.nix     — user packages and shell config (edit this)
users.nix    — user accounts
fly.toml     — Fly.io deployment config
flake.nix    — Nix flake wiring (you shouldn't need to touch this)
lib/         — plumbing (entrypoint, image builder, WeTTY package)
```

> For details on the Nix image builder, daemon system, reload behaviour, and flake layout, see [TECHNICAL.md](./TECHNICAL.md).
