local flake = vim.env.HOME .. "/nix"
local self = string.format('(builtins.getFlake "%s")', flake)

local host = string.format('%s.nixosConfigurations."%s"', self, vim.fn.hostname())

return {
    settings = {
        nixd = {
            nixpkgs = { expr = host .. ".pkgs" },
            options = {
                nixos = { expr = host .. ".options" },
                home_manager = {
                    expr = host .. ".options.home-manager.users.type.getSubOptions []",
                },
            },
        },
    },
}
