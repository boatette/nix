{ inputs, ... }:
{
  flake-file = {
    inputs = {
      flake-parts.url = "github:hercules-ci/flake-parts";
      flake-file.url = "github:denful/flake-file";
      import-tree.url = "github:denful/import-tree";
    };

    outputs = "inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)";
  };

  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.flake-file.flakeModules.default
  ];

  systems = [ "x86_64-linux" ];
}
