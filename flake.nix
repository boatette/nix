# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-file.url = "github:denful/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    millennium = {
      url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    noctalia-community-templates = {
      url = "github:noctalia-dev/community-templates";
      flake = false;
    };
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    plugins-everforest-nvim = {
      url = "github:neanias/everforest-nvim";
      flake = false;
    };
    plugins-github-monochrome-nvim = {
      url = "github:idr4n/github-monochrome.nvim";
      flake = false;
    };
    selector = {
      url = "github:boatette/selector";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    steam-config-nix = {
      url = "github:different-name/steam-config-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    umbriel.url = "github:noctalia-dev/umbriel";
    xdg-desktop-portal-umbriel.url = "github:noctalia-dev/xdg-desktop-portal-umbriel";
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };
  };
}
