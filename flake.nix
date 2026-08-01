{
    description = "NixOS Flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/26.05";
        home-manager = {
            url = "github:nix-community/home-manager/release-26.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        noctalia = {
            url = "github:noctalia-dev/noctalia";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        zen-browser = {
            url = "github:0xc000022070/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
        claude-code.url = "github:sadjow/claude-code-nix";
        wayland-select = {
            url = "git+file:///home/boatette/Projects/wayland_select";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        {
            self,
            nixpkgs,
            home-manager,
            zen-browser,
            claude-code,
            ...
        }@inputs:
        {
            nixosConfigurations.redux = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
                modules = [
                    ./configuration.nix
                    home-manager.nixosModules.default
                    {
                        home-manager = {
                            useGlobalPkgs = true;
                            useUserPackages = true;
                            extraSpecialArgs = { inherit inputs; };
                            users.boatette = ./home.nix;
                            backupFileExtension = "bak";
                        };
                    }
                    {
                        nixpkgs.overlays = [
                            inputs.neovim-nightly-overlay.overlays.default
                            claude-code.overlays.default
                        ];
                    }
                ];
            };
        };
}
