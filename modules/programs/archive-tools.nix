{
  flake.modules.homeManager.boatette =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ouch
        p7zip
        unzip
      ];
    };
}
