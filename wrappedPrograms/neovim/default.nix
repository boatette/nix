{ inputs, ... }:

{
    flake.homeModules.dev =
        { ... }:
        let
            defs = import ./_defs.nix { inherit inputs; };
        in
        {
            imports = [ inputs.nixCats.homeModule ];

            nixCats = {
                enable = true;

                nixpkgs_version = inputs.nixpkgs-unstable;
                addOverlays = [ (inputs.nixCats.utils.sanitizedPluginOverlay inputs) ];

                packageNames = [ "nvim" ];

                inherit (defs) luaPath;

                categoryDefinitions.replace = defs.categoryDefinitions;
                packageDefinitions.replace = defs.packageDefinitions;
            };
        };

    perSystem =
        { system, ... }:
        let
            # wrapRc = true so the lua config travels with the derivation
            defs = import ./_defs.nix {
                inherit inputs;
                wrapRc = true;
            };
        in
        {
            packages.nvim = inputs.nixCats.utils.baseBuilder defs.luaPath {
                inherit system;
                nixpkgs = inputs.nixpkgs-unstable;
                dependencyOverlays = [ (inputs.nixCats.utils.sanitizedPluginOverlay inputs) ];
                extra_pkg_config.allowUnfree = true;
            } defs.categoryDefinitions defs.packageDefinitions "nvim";
        };
}
