{
  coreutils,
  curl,
  inputs,
  jq,
  lib,
  mkpasswd,
  nixos-install-tools,
  stdenv,
  util-linux,
  writeShellApplication,
}:
writeShellApplication {
  name = "install-host";
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
    HOST = lib.head (lib.attrNames inputs.self.nixosConfigurations);
  };

  text = builtins.readFile ./install-host.sh;
}
