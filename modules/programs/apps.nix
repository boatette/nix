{
  flake.modules.homeManager.boatette =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        local.bambu-studio
        local.spotbye
        local.spotbye-bump
        pinta
        proton-pass
        qbittorrent
        stremio-linux-shell
      ];
    };
}
