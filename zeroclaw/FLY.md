# Deploying zeroclaw to Fly.io

## Prerequisites

- [Nix](https://nixos.org/download) with flakes enabled
- [flyctl](https://fly.io/docs/flyctl/install/)

## Build and Push

Authenticate with the Fly registry, then build and push the image:

```sh
fly auth docker

nix build
nix run .#default.copyToRegistry -- docker://registry.fly.io/zeroclaw:latest
```

Then deploy:

```sh
fly deploy
```
