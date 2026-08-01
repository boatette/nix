{
    description = "NixOS Flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/26.05";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        home-manager = {
            url = "github:nix-community/home-manager/release-26.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        noctalia = {
            url = "github:noctalia-dev/noctalia";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        noctalia-greeter = {
            url = "github:noctalia-dev/noctalia-greeter";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
        nixCats.url = "github:BirdeeHub/nixCats-nvim";
        "plugins-everforest-nvim" = {
            url = "github:neanias/everforest-nvim";
            flake = false;
        };
        "plugins-github-monochrome.nvim" = {
            url = "github:idr4n/github-monochrome.nvim";
            flake = false;
        };
        "plugins-select-undo.nvim" = {
            url = "github:SunnyTamang/select-undo.nvim";
            flake = false;
        };

        zen-browser = {
            url = "github:0xc000022070/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        claude-code.url = "github:sadjow/claude-code-nix";

        wayland-select = {
            url = "git+file:///home/boatette/Projects/wayland_select";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        {
            nixpkgs,
            home-manager,
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
                            claude-code.overlays.default
                        ];
                    }
                ];
            };
        };
}
