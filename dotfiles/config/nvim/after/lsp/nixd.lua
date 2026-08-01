local flake = vim.env.HOME .. "/nix"
local self = string.format('(builtins.getFlake "%s")', flake)

return {
    settings = {
        nixd = {
            nixpkgs = { expr = self .. ".inputs.nixpkgs.legacyPackages.x86_64-linux" },
            options = {
                nixos = { expr = self .. ".nixosConfigurations.redux.options" },
                home_manager = {
                    expr = self .. ".nixosConfigurations.redux.options.home-manager.users.type.getSubOptions []",
                },
            },
        },
    },
}
