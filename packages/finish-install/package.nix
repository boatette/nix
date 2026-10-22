{
  writeShellApplication,
  coreutils,
  gh,
  git,
  gnugrep,
  jq,
  openssh,
  util-linux,
}:
writeShellApplication {
  name = "finish-install";
  meta.description = "enroll Secure Boot and the TPM, log gh in to GitHub and clone the flake, after install-host";

  runtimeInputs = [
    coreutils
    gh
    git
    gnugrep
    jq
    openssh
    util-linux
  ];

  text = builtins.readFile ./finish-install.sh;
}
