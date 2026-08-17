{ inputs, ... }:

{
  flake.modules.homeManager.base = {
    imports = [ inputs.areofyl-fetch.homeManagerModules.default ];

    programs.fetch = {
      enable = true;
    };
  };
}
