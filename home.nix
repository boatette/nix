{ config, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default 
  ];

  home.stateVersion = "26.05";
}

