{ pkgs, zeroclaw, ... }:

{
  imageName = "zeroclaw";
  userRebuild = false;

  daemons = [
    {
      name = "user-rebuild";
      command = [ ./lib/user-rebuild.sh ];
      user = "*";
    }
    {
      name = "setup-ambit-cli";
      command = [ ./lib/setup-ambit-cli.sh ];
      user = "*";
    }
  ];

  entrypoint = {
    command = [
      "zeroclaw"
      "gateway"
      "--bind"
      "0.0.0.0"
      "--port"
      "42617"
    ];
    user = "user";
    port = 42617;
  };

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
    sqlite
    tree
    unzip
    util-linux
    which
    xz
    zip
    zeroclaw
  ];
}
