{ lib, config, ... }:
let
  inherit (config.flake) nixosConfigurations;

  root = ../../..;

  uncheckedPackages = [
    "iso"
    "nvim-full"
  ];

  nixFiles = lib.fileset.toSource {
    inherit root;
    fileset = lib.fileset.fileFilter (file: file.hasExt "nix") root;
  };

  treeFiles = lib.fileset.toSource {
    inherit root;
    fileset = lib.fileset.unions [
      (lib.fileset.fileFilter (
        file:
        lib.any file.hasExt [
          "nix"
          "lua"
          "md"
          "html"
          "css"
          "js"
          "mjs"
          "ts"
          "json"
          "jsonc"
          "yaml"
          "yml"
          "sh"
          "bash"
          "py"
          "toml"
        ]
      ) root)
      (root + "/flake.nix")
      (root + "/.editorconfig")
    ];
  };
in
{
  perSystem =
    { config, pkgs, ... }:
    {
      checks =
        lib.mapAttrs' (name: lib.nameValuePair "package-${name}") (
          lib.removeAttrs config.packages uncheckedPackages
        )
        // {
          deadnix = pkgs.runCommandLocal "check-deadnix" { } ''
            ${lib.getExe pkgs.deadnix} --fail ${nixFiles} && touch $out
          '';

          statix = pkgs.runCommandLocal "check-statix" { } ''
            ${lib.getExe pkgs.statix} check ${nixFiles} && touch $out
          '';

          formatting = pkgs.runCommandLocal "check-formatting" { } ''
            cp -r --no-preserve=mode ${treeFiles} tree
            cd tree
            ${lib.getExe config.formatter} --ci
            touch $out
          '';
        };
    };

  flake.checks = lib.foldlAttrs (
    acc: name: host:
    lib.recursiveUpdate acc (
      lib.optionalAttrs (!lib.elem name uncheckedPackages) {
        ${host.config.nixpkgs.hostPlatform.system}."host-${name}" = host.config.system.build.toplevel;
      }
    )
  ) { } nixosConfigurations;
}
