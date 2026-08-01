{ inputs, ... }:

{
    imports = [ inputs.nixCats.homeModule ];

    nixCats = {
        enable = true;

        nixpkgs_version = inputs.nixpkgs-unstable;
        addOverlays = [ (inputs.nixCats.utils.sanitizedPluginOverlay inputs) ];

        packageNames = [ "nvim" ];

        luaPath = ../../../dotfiles/config/nvim;

        categoryDefinitions.replace = args: {
            lspsAndRuntimeDeps.general = import ./tools.nix args;
            startupPlugins.general = import ./plugins.nix args;
        };

        packageDefinitions.replace = {
            nvim =
                { pkgs, ... }:
                {
                    settings = {
                        suffix-path = true;
                        suffix-LD = true;
                        wrapRc = false;
                        neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
                    };
                    categories.general = true;
                };
        };
    };
}
