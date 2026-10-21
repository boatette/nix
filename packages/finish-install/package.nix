{
  writeShellApplication,
  coreutils,
  git,
  gnugrep,
  jq,
  openssh,
  util-linux,
}:
writeShellApplication {
  name = "finish-install";
  meta.description = "enroll Secure Boot and the TPM, and clone the flake, after install-host";

  runtimeInputs = [
    coreutils
    git
    gnugrep
    jq
    openssh
    util-linux
  ];

  text = builtins.readFile ./finish-install.sh;
}
