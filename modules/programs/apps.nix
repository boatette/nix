{
  flake.modules.homeManager.boatette =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        blender
        local.bambu-studio
        local.spotbye
        local.spotbye-bump
        pinta
        proton-pass
        qbittorrent
        stremio-linux-shell

        hunspellDicts.en_AU
        libreoffice
      ];
    };
}
