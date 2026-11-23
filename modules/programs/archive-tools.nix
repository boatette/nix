{
  flake.modules.homeManager.boatette =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ouch
        unzip
        p7zip
      ];
    };
}
