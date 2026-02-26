#!/bin/bash
set -euo pipefail

# Idempotent setup of ambit-cli, its skill, and system context.
# Runs as a regular user with HOME, git, and nix on PATH.

OPENCODE_DIR="$HOME/.config/opencode"
SKILLS_DIR="$OPENCODE_DIR/skills"
MARKER="$OPENCODE_DIR/.ambit-cli-installed"

[ -f "$MARKER" ] && exit 0

mkdir -p "$SKILLS_DIR"

# --- Install ambit CLI via nix profile ---
if ! command -v ambit >/dev/null 2>&1; then
  nix profile install github:ToxicPine/ambit
fi

# --- Skill: clone ambit-skills repo and install ambit-cli skill ---
if [ ! -d "$SKILLS_DIR/ambit-cli" ]; then
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT
  git clone --depth 1 https://github.com/ToxicPine/ambit-skills.git "$tmpdir/ambit-skills"
  cp -r "$tmpdir/ambit-skills/skills/ambit-cli" "$SKILLS_DIR/ambit-cli"
fi

# --- Skill: inline system-details ---
mkdir -p "$SKILLS_DIR/system-details"
cat > "$SKILLS_DIR/system-details/SKILL.md" << 'SKILLEOF'
# System Details

## Environment

This machine is a cloud container deployed via **Ambit** to Fly.io infrastructure, accessible through a private Tailscale network. It runs NixOS with **Home Manager** for per-user package and configuration management.

## Package Management

All software is managed declaratively through Home Manager and the Nix flake at `~/.nixcfg/`.

### Installing packages

1. Edit `~/.nixcfg/home.nix`
2. Add the package to `home.packages` (e.g. `pkgs.ripgrep`)
3. Run `rebuild` (alias for `cd ~/.nixcfg && home-manager switch --flake .`)

### Removing packages

1. Edit `~/.nixcfg/home.nix`
2. Remove the package from `home.packages`
3. Run `rebuild`

### Searching for packages

Use `nix search nixpkgs <query>` to find available packages.

## Key paths

- `~/.nixcfg/` — User's Nix flake configuration (home.nix, flake.nix, etc.)
- `~/.nixcfg/home.nix` — Home Manager config: packages, shell aliases, programs
- `~/.nixcfg/system.nix` — System-level config: daemons, entrypoint, system packages
- `~/.nixcfg/users.nix` — User account definitions

## Per-project development environments

For project-specific dependencies, prefer **per-project Nix flakes** over installing packages globally in `home.nix`. This keeps the global environment lean and makes projects reproducible.

1. In the project root, run `nix flake init` to scaffold a `flake.nix`
2. Define a `devShell` with the project's dependencies
3. Enter the shell with `nix develop` (or use `direnv` with `use flake`)

Example `flake.nix` for a Node.js project using [flake-parts](https://flake.parts):

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem = { pkgs, ... }: {
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.nodejs pkgs.nodePackages.pnpm ];
        };
      };
    };
}
```

Reserve `home.nix` for tools you need everywhere (editors, git, CLI utilities).

## Important notes

- Do NOT use `apt`, `brew`, or manual installs. Always use Home Manager / Nix.
- Changes to `home.nix` take effect after running `rebuild`.
- The Nix store overlay resets on reboot; user homes under `/data/homes/` are persistent.
- `nix-daemon` runs in the background for multi-user Nix access.
SKILLEOF

touch "$MARKER"
