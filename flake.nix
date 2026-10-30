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
    monitor-autorotate = {
      url = "git+file:///home/boatette/Projects/monitor-autorotate?ref=niri";
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
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    petal = {
      url = "git+file:///home/boatette/Projects/petal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
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
    rose-pine-foot = {
      url = "github:rose-pine/foot";
      flake = false;
    };
    rose-pine-fzf = {
      url = "github:rose-pine/fzf";
      flake = false;
    };
    rose-pine-kde = {
      url = "github:ashbork/kde";
      flake = false;
    };
    rose-pine-konsole = {
      url = "github:rose-pine/konsole";
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
    rose-pine-starship = {
      url = "github:rose-pine/starship";
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
      url = "git+file:///home/boatette/Projects/selector?ref=niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    steam-config-nix = {
      url = "github:different-name/steam-config-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system24 = {
      url = "github:refact0r/system24";
      flake = false;
    };
    toothless = {
      url = "git+file:///home/boatette/Projects/toothless";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
