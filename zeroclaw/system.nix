{ pkgs, pkgs-unstable, zeroclaw, mkScript, ... }:

{
  imageName = "registry.fly.io/zeroclaw-3iyz8v83";
  userRebuild = false;

  config = {
    ExposedPorts = {
      "42617/tcp" = { };
    };
  };

  entrypoint = {
    name = "zeroclaw";
    command = zeroclaw;
    args = [ "daemon" ];
    user = "user";
  };

  daemons = [
    { name = "user-rebuild"; command = mkScript ./lib/user-rebuild.sh; user = "*"; }
  ];

  packages = with pkgs; [
    bashInteractive
    bzip2
    coreutils
    diffutils
    file
    findutils
    gawk
    gnugrep
    gnused
    gnutar
    gzip
    inetutils
    jq
    less
    ncurses
    nix
    procps
    psmisc
    ripgrep
    rsync
    tree
    unzip
    util-linux
    which
    xz
    zip
  ];
}
