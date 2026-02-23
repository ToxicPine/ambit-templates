{ pkgs }:

pkgs.buildNpmPackage {
  pname = "wetty";
  version = "2.7.0";

  src = pkgs.fetchFromGitHub {
    owner = "ToxicPine";
    repo = "wetty";
    rev = "81d08fbb88ec22cb9a035893a89a6c0aa1222d19";
    hash = "sha256-5CgmvB5ZI7bXuD8jX4FQ8hsJshl/kzQj3KgSy745f2c=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    substituteInPlace build.js --replace-fail '"pnpm"' '"npx"'
  '';

  npmDepsHash = "sha256-8yikSum1JZi6IDTZb7sWmoRzVGeZvV8OWWnjp9hmXrU=";

  nativeBuildInputs = with pkgs; [
    (python3.withPackages (ps: [ ps.setuptools ]))
    nodePackages.pnpm
    pkg-config
    makeWrapper
  ];

  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/wetty $out/bin
    cp -r build node_modules package.json conf $out/lib/wetty/
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/wetty \
      --add-flags "$out/lib/wetty/build/main.js"
    runHook postInstall
  '';
}
