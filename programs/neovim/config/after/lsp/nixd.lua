local flake = vim.env.HOME .. "/nix"
local self = string.format('(builtins.getFlake "%s")', flake)

-- Resolved at runtime so the config works on any machine in the flake. Going
-- through the host's own pkgs also picks up its overlays and allowUnfree,
-- rather than a bare nixpkgs pinned to one system.
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
