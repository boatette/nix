{
  writeShellApplication,
  inputs,
  stdenv,
  coreutils,
  curl,
  git,
  jq,
  nixos-install-tools,
  util-linux,
}:
writeShellApplication {
  name = "install-host";
  meta.description = "install one of this flake's hosts from a live ISO";

  runtimeInputs = [
    inputs.disko.packages.${stdenv.hostPlatform.system}.disko
    coreutils
    curl
    git
    jq
    nixos-install-tools
    util-linux
  ];

  runtimeEnv.INSTALL_HOST_REPO = inputs.self.constants.repo;

  text = builtins.readFile ./install-host.sh;
}
