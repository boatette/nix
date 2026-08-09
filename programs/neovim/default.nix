{ inputs, ... }:

{
    flake.nixosModules.base.environment.sessionVariables = {
        EDITOR = "nvim";
        SUDO_EDITOR = "nvim";
    };

    flake.homeModules.dev =
        { config, ... }:
        let
            defs = import ./_defs.nix { inherit inputs; };
        in
        {
            imports = [ inputs.nixCats.homeModule ];

            # wrapRc = false, so nvim reads this live; noctalia writes noctalia.lua into it
            xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/programs/neovim/config";

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
