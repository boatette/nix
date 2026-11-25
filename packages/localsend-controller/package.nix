{
  inputs,
  lib,
  rustPlatform,
}:
let
  src = "${inputs.noctalia-community-plugins}/localsend-plus/controller";
in
rustPlatform.buildRustPackage {
  pname = "localsend-controller";
  inherit ((lib.importTOML "${src}/Cargo.toml").package) version;
  inherit src;

  # read from the plugin's lock, so an input update needs no new hash
  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    allowBuiltinFetchGit = true;
  };

  # the tests start daemons that talk over multicast, which the sandbox has no network for
  doCheck = false;

  meta = {
    description = "LocalSend receiver and sender for noctalia's LocalSend Plus plugin";
    license = lib.licenses.mit;
    mainProgram = "localsend-controller";
  };
}
