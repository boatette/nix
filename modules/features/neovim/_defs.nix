{
    inputs,
    # false = ~/.config/nvim is live-editable
    # true = config derivation
    wrapRc ? false,
}:

{
    luaPath = ../../../dotfiles/config/nvim;

    categoryDefinitions = args: {
        lspsAndRuntimeDeps.general = import ./_tools.nix args;
        startupPlugins.general = import ./_plugins.nix args;
    };

    packageDefinitions = {
        nvim =
            { pkgs, ... }:
            {
                settings = {
                    inherit wrapRc;
                    suffix-path = true;
                    suffix-LD = true;
                    neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
                };
                categories.general = true;
            };
    };
}
