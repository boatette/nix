{
  flake.modules.homeManager.archive-tools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ouch
        unzip
        p7zip
      ];
    };
}
