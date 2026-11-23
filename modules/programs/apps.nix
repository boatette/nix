{
  flake.modules.homeManager.boatette =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        pinta
        blender
        stremio-linux-shell
        qbittorrent
        proton-pass
        local.bambu-studio
        local.spotbye
        local.spotbye-bump

        libreoffice
        hunspellDicts.en_AU
      ];
    };
}
