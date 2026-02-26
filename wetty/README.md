# wetty

A declarative NixOS + Home Manager container image for Fly.io. Everything is built with pure nix — no Dockerfile.

## Structure

```
system.nix        — image name, system packages, entrypoint command, background daemons
users.nix         — user accounts with UIDs and optional per-user HM overrides
home.nix          — shared Home Manager config applied to all users
fly.toml          — Fly.io deployment config
flake.nix         — wiring (you shouldn't need to touch this)
lib/image.nix     — OCI image builder (plumbing)
lib/entrypoint.sh — runtime boot script (plumbing)
```

Edit `system.nix`, `users.nix`, and `home.nix` to configure your machine. The `lib/` directory is infrastructure — you shouldn't need to modify it.

## Prerequisites

- [Nix](https://nixos.org/download/) with flakes enabled
- [Fly.io CLI](https://fly.io/docs/flyctl/install/) (`flyctl`)
- A Fly.io app and volume already created

## Build

```sh
nix build
```

This produces a gzipped OCI tarball at `./result`.

## Push to Fly Registry

Use [skopeo](https://github.com/containers/skopeo) to push directly from the nix-built tarball — no Docker daemon required:

```sh
nix-shell -p skopeo --run \
  "skopeo copy \
    --dest-creds x:$(fly auth token) \
    docker-archive:$(nix build --no-link --print-out-paths) \
    docker://registry.fly.io/$(nix eval --raw .#default.imageName 2>/dev/null || echo wetty):latest"
```

Or step by step:

```sh
# 1. build
nix build

# 2. push (the username is literally "x", the token is the password)
nix-shell -p skopeo --run \
  "skopeo copy \
    --dest-creds x:$(fly auth token) \
    docker-archive:./result \
    docker://registry.fly.io/wetty:latest"
```

## Deploy

```sh
fly deploy
```

Or with [ambit](https://www.npmjs.com/package/@cardelli/ambit) for private Tailscale networks:

```sh
npx @cardelli/ambit deploy wetty --network supercomputer
```

## Configuration

### system.nix

Defines what the machine does:

- `imageName` — name of the OCI image (should match your Fly app name)
- `entrypoint` — the foreground process (`command`, `user`, `port`)
- `daemons` — background processes started after Home Manager activation (see [Daemons](#daemons) below)
- `packages` — system-level packages available to all users (these are infrastructure; user tools go in `home.nix`)

### users.nix

Declares users as an attrset. Each user needs a `uid`. Optional `home` attribute lets you add per-user Home Manager overrides:

```nix
{
  alice = {
    uid = 1000;
    home = { pkgs, ... }: {
      programs.git.userName = "Alice";
      home.packages = [ pkgs.python3 ];
    };
  };
  bob = { uid = 1001; };
}
```

### home.nix

Shared Home Manager module applied to every user. Put common tools, shell config, and program settings here. Uses stable nixpkgs by default; `pkgs-unstable` is available for packages from nixpkgs-unstable.

## Daemons

Background processes are declared in `system.nix` under `daemons`. Each daemon has a `name`, a `command`, and an optional `user` field:

```nix
daemons = [
  { name = "my-agent"; command = [ "my-agent" "--flag" ]; user = "alice"; }
  { name = "setup";    command = [ ./lib/setup.sh ];      user = "*"; }
];
```

The `user` field controls who the daemon runs as:

| Value | Behaviour |
|-------|-----------|
| `"alice"` | Runs once as user `alice` |
| `["alice" "bob"]` | Runs once per listed user |
| `"*"` | Runs once per user defined in `users.nix` |
| _(omitted)_ | Runs as root |

**Path vs string commands:** If a command argument is a Nix path literal (e.g. `./lib/setup.sh`), Nix copies the file into the store and makes it an executable script at build time. If it's a string (e.g. `"my-agent"`), it's resolved at runtime via `PATH`. This means setup scripts live in `lib/` as `.sh` files referenced by path, while installed programs are referenced by name as strings.

## How It Works

At boot, the entrypoint script:

1. Mounts an overlayfs on `/nix` (image store as lower, Fly volume as upper) so nix store changes survive across sessions but reset on redeploy
2. Starts `nix-daemon` for multi-user nix access
3. For each user: bind-mounts persistent home from `/data/homes/<user>`, copies the flake config on first boot, and runs Home Manager activation
4. Starts background daemons (see [Daemons](#daemons))
5. Execs the foreground entrypoint as the configured user

Users can SSH in and run `rebuild` (aliased to `cd ~/.nixcfg && home-manager switch --flake .`) to apply changes interactively. These changes persist across restarts via the Fly volume.

## Flake Layout

```
flake.nix
├── inputs
│   ├── nixpkgs (stable)
│   ├── nixpkgs-unstable
│   ├── flake-parts
│   └── home-manager
├── outputs
│   ├── packages.default        → OCI image tarball (lib/image.nix)
│   ├── homeConfigurations.*    → per-user HM configs (home.nix + users.nix overrides)
│   └── lib.mkHome              → helper to build a HM config for a username
└── helpers (internal)
    ├── resolveCommandArg       → path literal → writeShellScript, string → passthrough
    ├── collectScriptSources    → gathers path-literal scripts from daemons for /etc/nixcfg
    └── resolveDaemons          → maps resolveCommandArg over all daemon commands
```

The flake wires together three user-facing files (`system.nix`, `users.nix`, `home.nix`) with two plumbing files (`lib/image.nix`, `lib/entrypoint.sh`). Daemon command arguments are resolved at build time: Nix path literals (like `./lib/setup.sh`) are copied into the Nix store as executable scripts, while plain strings are left for runtime PATH resolution. The `configSources` list (files baked into `/etc/nixcfg` in the image) is automatically derived from the static flake files plus any path-literal scripts in daemons.
