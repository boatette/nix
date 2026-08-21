{
  inputs,
  stdenv,
  symlinkJoin,
  makeWrapper,
}:
let
  package = inputs.zen-browser.packages.${stdenv.hostPlatform.system}.default;
in

symlinkJoin {
  name = "zen-beta-marionette-${package.version or "configured"}";
  paths = [ package ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/zen-beta \
      --set MOZ_MARIONETTE 1 \
      --add-flags -remote-allow-system-access
  '';

  meta = (package.meta or { }) // {
    mainProgram = "zen-beta";
  };
}
