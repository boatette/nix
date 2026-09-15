{
  writeShellApplication,
  coreutils,
  gnugrep,
  jq,
}:
writeShellApplication {
  name = "finish-install";
  meta.description = "enroll Secure Boot and the TPM after install-host";

  runtimeInputs = [
    coreutils
    gnugrep
    jq
  ];

  text = builtins.readFile ./finish-install.sh;
}
