{ inputs, pkgs }:

let
  package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

  configToml = (pkgs.formats.toml { }).generate "noctalia-config.toml" (
    import ./_config.nix { inherit pkgs; }
  );

  configHome = pkgs.runCommand "noctalia-config-home" { } ''
    mkdir -p $out/noctalia
    cp ${configToml} $out/noctalia/config.toml
  '';
in
pkgs.symlinkJoin {
  name = "noctalia-${package.version or "configured"}";
  paths = [ package ];
  nativeBuildInputs = [ pkgs.makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/noctalia --set NOCTALIA_CONFIG_HOME ${configHome}
  '';

  meta = package.meta or { } // {
    mainProgram = "noctalia";
  };
}
