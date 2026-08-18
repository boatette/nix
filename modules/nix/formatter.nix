{ inputs, ... }:

{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";

    programs = {
      nixfmt.enable = true;
      stylua.enable = true;
    };

    settings.global.excludes = [
      "*.png"
      "*.jq"
      "*.sh"
      "LICENSE"
      "flake.lock"
    ];
  };
}
