{ inputs, ... }:

let
  nvimModule = import ./_config { inherit inputs; };
in
{
  flake.modules.nixos.base.environment.sessionVariables = {
    EDITOR = "nvim";
    SUDO_EDITOR = "nvim";
  };

  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      imports = [ inputs.nixvim.homeModules.nixvim ];

      xdg.configFile."nvim/.keep".text = "";

      programs.nixvim = {
        enable = true;
        imports = [ nvimModule ];

        nixpkgs.pkgs = pkgs;
      };
    };

  perSystem =
    { system, pkgs, ... }:
    {
      packages.nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        module = nvimModule;
      };
    };
}
