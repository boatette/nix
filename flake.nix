{
    description = "NixOS Flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

        flake-parts.url = "github:hercules-ci/flake-parts";
        wrapper-modules = {
            url = "github:BirdeeHub/nix-wrapper-modules";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        home-manager = {
            url = "github:nix-community/home-manager/release-26.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # doesnt follow nixpkgs to allow cachix
        noctalia.url = "github:noctalia-dev/noctalia";
        noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";

        neovim-nightly-overlay = {
            url = "github:nix-community/neovim-nightly-overlay";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixCats.url = "github:BirdeeHub/nixCats-nvim";
        "plugins-everforest-nvim" = {
            url = "github:neanias/everforest-nvim";
            flake = false;
        };
        "plugins-github-monochrome.nvim" = {
            url = "github:idr4n/github-monochrome.nvim";
            flake = false;
        };

        zen-browser = {
            url = "github:0xc000022070/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        millennium = {
            url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        claude-code = {
            url = "github:sadjow/claude-code-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        wayland-select = {
            url = "git+ssh://git@github.com/boatette/wayland_select.git";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        inputs:
        let
            inherit (inputs.nixpkgs) lib;
            inherit (lib.fileset) toList fileFilter;

            isNixModule = file: file.hasExt "nix" && file.name != "flake.nix" && !lib.hasPrefix "_" file.name;

            importTree = path: toList (fileFilter isNixModule path);

            mkFlake = inputs.flake-parts.lib.mkFlake { inherit inputs; };
        in
        mkFlake { imports = importTree ./.; };
}
