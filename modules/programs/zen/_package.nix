{ inputs, pkgs }:

let
  package = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
pkgs.symlinkJoin {
  name = "zen-beta-marionette-${package.version or "configured"}";
  paths = [ package ];
  nativeBuildInputs = [ pkgs.makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/zen-beta \
      --set MOZ_MARIONETTE 1 \
      --add-flags -remote-allow-system-access
  '';

  meta = package.meta or { } // {
    mainProgram = "zen-beta";
  };
}
