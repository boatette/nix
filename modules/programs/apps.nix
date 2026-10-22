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
        # bambu-studio

        libreoffice-qt
        hunspellDicts.en_AU
      ];
    };
}
