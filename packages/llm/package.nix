{
  coreutils,
  curl,
  findutils,
  gawk,
  jq,
  lib,
  opencode,
  systemd,
  util-linux,
  writeShellApplication,
  writeText,
  xdg-utils,

  # set by homeManager.llm (modules/services/llm.nix), which owns the model list
  models ? [ ],
  port ? 8191,
  root ? "/mnt/storage/ai/llm",
}:
writeShellApplication {
  name = "llm";
  meta.description = "local chat and coding models behind one llama-server";

  runtimeInputs = [
    coreutils
    curl
    findutils
    gawk
    jq
    opencode
    systemd
    util-linux
    xdg-utils
  ];

  runtimeEnv = {
    ROOT = root;
    PORT = toString port;
    MODELS_JSON = writeText "llm-models.json" (
      builtins.toJSON (map (m: lib.getAttrs [ "name" "url" "sha256" "file" ] m) models)
    );
  };

  text = builtins.readFile ./llm.sh;
}
