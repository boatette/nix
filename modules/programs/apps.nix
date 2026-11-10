{
  flake.modules.homeManager.apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        pinta
        blender
        stremio-linux-shell
        qbittorrent
        proton-pass
        proton-vpn
        ventoy
        local.bambu-studio
        local.spotbye
        local.spotbye-bump

        libreoffice-qt
        hunspellDicts.en_AU
      ];
    };
}
