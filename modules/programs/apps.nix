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

        libreoffice-qt
        hunspellDicts.en_AU
      ];
    };
}
