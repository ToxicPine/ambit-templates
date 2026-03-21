{
  description = "zeroclaw — personal AI assistant on Fly.io";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    inthesky.url = "github:toxicpine/inthesky";
  };

  outputs =
    inputs:
    let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};

      zeroclaw = pkgs.stdenv.mkDerivation {
        pname = "zeroclaw";
        version = "0.5.4";

        src = pkgs.fetchurl {
          url = "https://github.com/zeroclaw-labs/zeroclaw/releases/download/v0.5.4/zeroclaw-x86_64-unknown-linux-gnu.tar.gz";
          sha256 = "0jcpwrc2m13lx64ayw690bq8if6khxb5l3w4xcvk696s8ibppfjl";
        };

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [ pkgs.stdenv.cc.cc.lib ];

        sourceRoot = ".";

        installPhase = ''
          mkdir -p $out/bin
          install -m 0755 zeroclaw $out/bin/zeroclaw
        '';

        meta.mainProgram = "zeroclaw";
      };
    in
    inputs.inthesky.lib.mkFlake {
      inherit system pkgs;
      home-manager = inputs.home-manager;
      userPartitionMount = "/data";
      extraArgs = { inherit pkgs-unstable zeroclaw; };
      systemConfig = import ./system.nix;
      sharedHomeConfig = ./home.nix;
      userConfig = ./users;
      flakeRoot = ./.;
    };
}
