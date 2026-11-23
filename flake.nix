# DO-NOT-EDIT. This file was auto-generated using github:denful/flake-file.
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
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    grok-build-nix = {
      url = "github:AodhanHayter/grok-build-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit.follows = "";
      };
    };
    luciole.url = "github:noctalia-dev/luciole/cachix";
    monitor-autorotate = {
      url = "github:boatette/monitor-autorotate";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf = {
      url = "github:notashelf/nvf";
      inputs = {
        flake-compat.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
    };
    petal = {
      url = "git+file:///home/boatette/Projects/petal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
    rose-pine-btop = {
      url = "github:rose-pine/btop";
      flake = false;
    };
    rose-pine-delta = {
      url = "github:rose-pine/delta";
      flake = false;
    };
    rose-pine-eza = {
      url = "github:rose-pine/eza";
      flake = false;
    };
    rose-pine-lazygit = {
      url = "github:rose-pine/lazygit";
      flake = false;
    };
    rose-pine-qutebrowser = {
      url = "github:aalbegr/qutebrowser-rose-pine";
      flake = false;
    };
    rose-pine-rmpc = {
      url = "github:rose-pine/rmpc";
      flake = false;
    };
    rose-pine-tm-theme = {
      url = "github:rose-pine/tm-theme";
      flake = false;
    };
    rose-pine-yazi = {
      url = "github:rose-pine/yazi";
      flake = false;
    };
    rose-pine-zellij = {
      url = "github:rose-pine/zellij";
      flake = false;
    };
    selector = {
      url = "github:boatette/selector";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    steam-config-nix = {
      url = "github:different-name/steam-config-nix";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    system24 = {
      url = "github:refact0r/system24";
      flake = false;
    };
    toothless = {
      url = "github:boatette/toothless";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
