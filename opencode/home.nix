{ inputs, pkgs, pkgs-unstable, ... }:

{
  home.stateVersion = "25.11";

  imports = [
    inputs.direnv-instant.homeModules.direnv-instant
  ];

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
      gh
      git
      htop
      nodejs
      openssh
      flyctl
      deno
      tmux
      vim
    ])
    ++ (with pkgs-unstable; [
      opencode
    ]);

  programs.git = {
    enable = true;
  };

  # direnv-instant replaces direnv's normal shell hook, but still relies on
  # direnv itself. Keep nix-direnv enabled alongside it for cached flake envs.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.direnv-instant.enable = true;

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
  };
}
