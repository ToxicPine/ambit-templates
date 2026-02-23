{ pkgs, wetty, ... }:

let
  ambitLogin = pkgs.writeShellScriptBin "ambit-login" ''
    cd /home/user
    exec setpriv --reuid=1000 --regid=1000 --init-groups \
      env HOME=/home/user USER=user SHELL=/bin/bash \
      bash -l
  '';
in

{
  imageName = "wetty";

  daemons = [
    # { name = "my-agent"; command = [ "my-agent" ]; user = "user"; }
  ];

  entrypoint = {
    command = [ "wetty" "--port" "3000" "--host" "0.0.0.0" "--command" "ambit-login" "--base" "/" "--title" "Ambit Shell" ];
    user = "root";
    port = 3000;
  };

  packages = with pkgs; [
    bashInteractive
    coreutils
    findutils
    gnugrep
    gnused
    jq
    nix
    util-linux
    wetty
    ambitLogin
  ];
}
