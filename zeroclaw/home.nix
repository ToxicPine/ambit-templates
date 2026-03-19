{ pkgs, pkgs-unstable, zeroclaw, ... }:

{
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''[[ "$PWD" == "/" ]] && cd'';
    shellAliases = {
      ll = "ls -la";
      rebuild = "cd ~/.nixcfg && home-manager switch --flake .";
    };
  };

  home.packages =
    (with pkgs; [
      bun
      curl
      gcc
      gh
      git
      gnumake
      htop
      nodejs
      openssh
      flyctl
      python3
      deno
      tmux
      vim
    ])
    ++ [
      zeroclaw
    ];

  programs.git = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
  };
}
