{
  coreutils,
  curl,
  diskoScript ? null,
  inputs,
  jq,
  lib,
  mkpasswd,
  nixos-install-tools,
  prebuilt ? null,
  stdenv,
  util-linux,
  writeShellApplication,
}:
writeShellApplication {
  name = "install";
  meta.description = "erase aspire's disk and install it, from a live ISO";

  runtimeInputs = [
    coreutils
    curl
    inputs.disko.packages.${stdenv.hostPlatform.system}.disko
    jq
    mkpasswd
    nixos-install-tools
    util-linux
  ];

  runtimeEnv = {
    FLAKE = "${inputs.self}";
    HOST = lib.head (lib.attrNames (removeAttrs inputs.self.nixosConfigurations [ "iso" ]));
  }
  // lib.optionalAttrs (prebuilt != null) {
    SYSTEM = "${prebuilt}";
    DISKO_SCRIPT = lib.getExe' diskoScript "disko-destroy-format-mount";
  };

  text = builtins.readFile ./install.sh;
}
